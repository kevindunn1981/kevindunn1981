#!/usr/bin/env python3
"""L-system low-poly foliage generator. Pure stdlib, no dependencies.

Grows a branching plant skeleton via a parametric recursive turtle
(equivalent to a parametric L-system's string-rewrite + turtle
interpretation, computed directly rather than materializing an
intermediate symbol string), then emits a faceted low-poly mesh:
hex-tube branches tapering with depth, plus double-sided diamond leaf
cards clustered at branch tips. Exports Wavefront OBJ + MTL for
inspection in Blender.

Every tunable below is a "genome" parameter in the sense used by the
game's design brief (docs/design-brief.md, §5) — puzzle rewards are
meant to seed exactly these values.
"""

import argparse
import math
import random
from dataclasses import dataclass, replace
from pathlib import Path

Vec3 = tuple


def v_add(a, b):
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def v_sub(a, b):
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def v_scale(a, s):
    return (a[0] * s, a[1] * s, a[2] * s)


def v_dot(a, b):
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def v_cross(a, b):
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def v_length(a):
    return math.sqrt(v_dot(a, a))


def v_normalize(a):
    length = v_length(a)
    return v_scale(a, 1.0 / length) if length > 1e-9 else (0.0, 0.0, 1.0)


def rotate_about_axis(v, axis, angle_deg):
    theta = math.radians(angle_deg)
    c, s = math.cos(theta), math.sin(theta)
    return v_add(
        v_add(v_scale(v, c), v_scale(v_cross(axis, v), s)),
        v_scale(axis, v_dot(axis, v) * (1 - c)),
    )


@dataclass
class Genome:
    seed: int = 0
    iterations: int = 5
    branch_count: int = 3
    branch_angle_deg: float = 32.0
    angle_jitter_deg: float = 8.0
    phyllotaxis_deg: float = 137.5
    branch_skip_chance: float = 0.1
    trunk_continue_chance: float = 0.85
    length: float = 1.0
    length_falloff: float = 0.78
    radius: float = 0.09
    radius_falloff: float = 0.72
    min_radius: float = 0.004
    tube_sides: int = 6
    leaf_size: float = 0.32
    leaves_per_tip: int = 3


class TurtleState:
    __slots__ = ("pos", "heading", "left", "up")

    def __init__(self, pos, heading, left, up):
        self.pos = pos
        self.heading = heading
        self.left = left
        self.up = up

    def copy(self):
        return TurtleState(self.pos, self.heading, self.left, self.up)

    def yaw(self, angle_deg):
        self.heading = rotate_about_axis(self.heading, self.up, angle_deg)
        self.left = rotate_about_axis(self.left, self.up, angle_deg)

    def pitch(self, angle_deg):
        self.heading = rotate_about_axis(self.heading, self.left, angle_deg)
        self.up = rotate_about_axis(self.up, self.left, angle_deg)

    def roll(self, angle_deg):
        self.left = rotate_about_axis(self.left, self.heading, angle_deg)
        self.up = rotate_about_axis(self.up, self.heading, angle_deg)


class Mesh:
    def __init__(self):
        self.vertices = []
        self.bark_faces = []
        self.leaf_faces = []

    def add_vertex(self, p):
        self.vertices.append(p)
        return len(self.vertices)

    def add_tri(self, group, a, b, c):
        group.append((a, b, c))


def add_branch_segment(mesh, p0, p1, r0, r1, left, up, sides):
    ring0, ring1 = [], []
    for i in range(sides):
        angle = 2 * math.pi * i / sides
        offset = v_add(v_scale(left, math.cos(angle)), v_scale(up, math.sin(angle)))
        ring0.append(mesh.add_vertex(v_add(p0, v_scale(offset, r0))))
        ring1.append(mesh.add_vertex(v_add(p1, v_scale(offset, r1))))
    for i in range(sides):
        j = (i + 1) % sides
        mesh.add_tri(mesh.bark_faces, ring0[i], ring0[j], ring1[j])
        mesh.add_tri(mesh.bark_faces, ring0[i], ring1[j], ring1[i])
    return ring1


def cap_tip(mesh, ring, tip_vertex):
    n = len(ring)
    for i in range(n):
        j = (i + 1) % n
        mesh.add_tri(mesh.bark_faces, ring[i], ring[j], tip_vertex)


def add_leaf(mesh, base, heading, left, up, size, rng):
    tilt = rng.uniform(0.15, 0.55)
    h = v_normalize(v_add(v_scale(heading, 1.0 - tilt), v_scale(up, tilt)))
    l = rotate_about_axis(left, h, rng.uniform(0, 360))

    tip = v_add(base, v_scale(h, size))
    mid = v_add(base, v_scale(h, size * 0.4))
    side_a = v_add(mid, v_scale(l, size * 0.28))
    side_b = v_sub(mid, v_scale(l, size * 0.28))

    i_base = mesh.add_vertex(base)
    i_tip = mesh.add_vertex(tip)
    i_a = mesh.add_vertex(side_a)
    i_b = mesh.add_vertex(side_b)

    # Emit both windings so leaf cards are visible from either side.
    for a, b, c in ((i_base, i_a, i_tip), (i_tip, i_b, i_base)):
        mesh.add_tri(mesh.leaf_faces, a, b, c)
        mesh.add_tri(mesh.leaf_faces, a, c, b)


def grow(mesh, state, depth, genome, rng):
    if depth >= genome.iterations:
        for _ in range(genome.leaves_per_tip):
            add_leaf(mesh, state.pos, state.heading, state.left, state.up, genome.leaf_size, rng)
        return

    length = genome.length * (genome.length_falloff ** depth)
    r0 = max(genome.radius * (genome.radius_falloff ** depth), genome.min_radius)
    r1 = max(genome.radius * (genome.radius_falloff ** (depth + 1)), genome.min_radius)

    p0, left0, up0 = state.pos, state.left, state.up
    p1 = v_add(p0, v_scale(state.heading, length))
    state.pos = p1

    ring1 = add_branch_segment(mesh, p0, p1, r0, r1, left0, up0, genome.tube_sides)

    side_children = []
    for i in range(genome.branch_count):
        if depth > 0 and rng.random() < genome.branch_skip_chance:
            continue
        child = state.copy()
        angle = genome.branch_angle_deg + rng.uniform(-genome.angle_jitter_deg, genome.angle_jitter_deg)
        child.roll(genome.phyllotaxis_deg * i + rng.uniform(-10, 10))
        child.pitch(-angle)
        side_children.append(child)

    trunk_continues = rng.random() < genome.trunk_continue_chance
    if trunk_continues:
        trunk = state.copy()
        trunk.pitch(rng.uniform(-1, 1) * genome.angle_jitter_deg * 0.4)
        trunk.yaw(rng.uniform(-1, 1) * genome.angle_jitter_deg * 0.4)

    if not trunk_continues:
        tip_vertex = mesh.add_vertex(p1)
        cap_tip(mesh, ring1, tip_vertex)
        if not side_children:
            for _ in range(genome.leaves_per_tip):
                add_leaf(mesh, p1, state.heading, state.left, state.up, genome.leaf_size, rng)

    for child in side_children:
        grow(mesh, child, depth + 1, genome, rng)
    if trunk_continues:
        grow(mesh, trunk, depth + 1, genome, rng)


def generate_tree(genome):
    rng = random.Random(genome.seed)
    mesh = Mesh()
    root = TurtleState(
        pos=(0.0, 0.0, 0.0),
        heading=(0.0, 0.0, 1.0),  # Blender is Z-up.
        left=(1.0, 0.0, 0.0),
        up=(0.0, 1.0, 0.0),
    )
    grow(mesh, root, 0, genome, rng)
    return mesh


def write_obj(mesh, obj_path: Path, mtl_path: Path):
    with obj_path.open("w") as f:
        f.write(f"mtllib {mtl_path.name}\n")
        for v in mesh.vertices:
            f.write(f"v {v[0]:.6f} {v[1]:.6f} {v[2]:.6f}\n")
        f.write("usemtl Bark\n")
        for a, b, c in mesh.bark_faces:
            f.write(f"f {a} {b} {c}\n")
        f.write("usemtl Leaf\n")
        for a, b, c in mesh.leaf_faces:
            f.write(f"f {a} {b} {c}\n")

    with mtl_path.open("w") as f:
        f.write("newmtl Bark\nKd 0.35 0.24 0.15\n\n")
        f.write("newmtl Leaf\nKd 0.27 0.55 0.28\n")


PRESETS = {
    "sapling": Genome(iterations=4, branch_count=2, branch_angle_deg=28, length=0.9, radius=0.06),
    "bushy-fern": Genome(
        iterations=5, branch_count=3, branch_angle_deg=42, angle_jitter_deg=12,
        length=0.55, length_falloff=0.82, radius=0.05, leaves_per_tip=4,
        trunk_continue_chance=0.6,
    ),
    "windswept-bonsai": Genome(
        iterations=5, branch_count=2, branch_angle_deg=55, angle_jitter_deg=18,
        length=1.1, length_falloff=0.7, radius=0.1, radius_falloff=0.65,
        trunk_continue_chance=0.5, leaves_per_tip=5, leaf_size=0.4,
    ),
}

GENOME_FIELDS = [
    "iterations", "branch_count", "branch_angle_deg", "angle_jitter_deg",
    "length", "length_falloff", "radius", "radius_falloff",
    "leaf_size", "leaves_per_tip", "tube_sides",
]


def main():
    parser = argparse.ArgumentParser(description="L-system low-poly foliage generator")
    parser.add_argument("--preset", choices=sorted(PRESETS))
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--out", type=Path, default=Path("output/specimen"))
    for field_name in GENOME_FIELDS:
        parser.add_argument(f"--{field_name.replace('_', '-')}", dest=field_name, type=float)
    args = parser.parse_args()

    genome = PRESETS[args.preset] if args.preset else Genome()
    genome = replace(genome, seed=args.seed)
    overrides = {k: getattr(args, k) for k in GENOME_FIELDS if getattr(args, k) is not None}
    if "iterations" in overrides:
        overrides["iterations"] = int(overrides["iterations"])
    if "branch_count" in overrides:
        overrides["branch_count"] = int(overrides["branch_count"])
    if "leaves_per_tip" in overrides:
        overrides["leaves_per_tip"] = int(overrides["leaves_per_tip"])
    if "tube_sides" in overrides:
        overrides["tube_sides"] = int(overrides["tube_sides"])
    genome = replace(genome, **overrides)

    mesh = generate_tree(genome)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    obj_path = args.out.with_suffix(".obj")
    mtl_path = args.out.with_suffix(".mtl")
    write_obj(mesh, obj_path, mtl_path)
    print(
        f"Wrote {obj_path} ({len(mesh.vertices)} vertices, "
        f"{len(mesh.bark_faces)} bark tris, {len(mesh.leaf_faces)} leaf tris)"
    )


if __name__ == "__main__":
    main()
