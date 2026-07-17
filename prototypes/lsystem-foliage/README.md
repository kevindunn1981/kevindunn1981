# L-System Low-Poly Foliage Generator

First prototype for the "riskiest, most novel piece" called out in
`docs/design-brief.md` §15 (Recommended Next Step): an L-system → mesh
generator for the tropical-plants biome, with tunable "genome"
parameters. Pure Python standard library only — no dependencies to
install, runs anywhere Python 3 runs.

This produces raw geometry only (a faceted low-poly branch skeleton +
leaf cards), with flat placeholder materials. It does **not** implement
the watercolor/cel shader from §10 — that's a separate, engine-side
step. The point of this prototype is to validate the *shape* generation
and confirm genome parameters produce meaningfully different-looking
specimens, per §15's guidance that shape and shader need to be judged
together before either is trusted alone.

## Approach

A parametric recursive turtle walk — the same thing a string-rewriting
L-system produces once interpreted, computed directly via recursion
rather than first materializing a symbol string. Each recursive call:

1. Grows one tapered hex-tube branch segment forward.
2. Spawns 0+ side branches at an angle (with jitter) around the branch
   axis, spaced using the golden angle (137.5°) for a phyllotaxis-like
   arrangement instead of branches all lining up in a plane.
3. Optionally continues the trunk straight-ish ahead.
4. Terminates into a cluster of double-sided diamond leaf cards when
   depth runs out or a branch dead-ends.

## Usage

```
python3 lsystem_foliage.py --seed 1 --out output/my_plant
python3 lsystem_foliage.py --preset bushy-fern --seed 7 --out output/fern
```

Run `python3 lsystem_foliage.py --help` for the full list of genome
parameters (iterations, branch count/angle/jitter, length/radius
falloff, leaf size/count, tube sides). Three starting presets are
included: `sapling`, `bushy-fern`, `windswept-bonsai`.

Output is a `.obj` + `.mtl` pair. In Blender: **File → Import →
Wavefront (.obj)**, then run **Object → Shade Smooth** or leave flat
depending on preference, and **Mesh → Normals → Recalculate Outside**
if any faces look inverted (branch-tip end caps aren't guaranteed
consistently wound in this first pass).

## Samples

`samples/` has four pre-generated specimens (one per preset, plus one
default) so you can open them in Blender immediately without running
anything:

- `default_seed1.obj`
- `sapling_seed2.obj`
- `bushy-fern_seed3.obj`
- `windswept-bonsai_seed4.obj`

## Known gaps / next steps

- No voxelization step yet — this emits a triangle mesh directly rather
  than going through the voxel-grid intermediate described in
  `docs/design-brief.md` §6 (voxel storage) and
  `docs/voxel-format-research.md`. Worth deciding whether the final
  pipeline voxelizes this mesh, or generates directly into a voxel grid
  and meshes via greedy meshing instead (blockier, more "voxel game"
  silhouette vs. this smoother tube-based look).
- Leaf shape is a single fixed diamond card — no per-species leaf shape
  variation yet.
- No watercolor/cel shader applied — flat Bark/Leaf materials only.
- No pruning for self-intersection between branches (unlikely to matter
  much at these growth parameters, but not checked).
