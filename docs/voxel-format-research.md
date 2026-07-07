# Research: Sparse Voxel Formats

*Supporting research for design-brief.md §5 (Voxels: Why and How). Scope:
how to store and manipulate voxel data for procedurally-generated,
per-specimen models (plants, terrarium contents, coral) on mobile.*

## 1. Why not a dense grid

A dense 3D array (`bool[x][y][z]` or `byte[x][y][z]`) is the simplest
representation and is fine for small, mostly-full shapes, but our
specimens are branching/organic — mostly empty space around a thin
structure. Memory scales as O(n³) regardless of occupancy, so a detailed
plant or coral at a resolution high enough to look good up close (say
128³) wastes the overwhelming majority of its memory on air. Dense grids
are the right baseline to generate *into* during algorithm execution
(L-system rasterization, cellular automata step), but not what should be
kept resident for many simultaneous room specimens.

## 2. Format families surveyed

### Sparse Voxel Octree (SVO)
Recursively subdivides a cube into 8 children; subtrees with no
occupancy are pruned/never allocated. Classic large-scale approach
(Laine & Karras, "Efficient Sparse Voxel Octrees," 2010) for huge static
scenes (terrain, planet-scale data).
- **Strengths**: excellent compression for large empty regions;
  well-suited to LOD (coarser octree levels double as pre-computed
  mip/LOD data).
- **Weaknesses**: pointer-chasing traversal cost (several indirections
  per voxel access); mutating structure (adding/removing voxels) means
  re-splitting/merging nodes, which is more bookkeeping than a flat
  array; most value shows up at scales (planet/city) larger than a
  single potted plant or coral head.

### Sparse Voxel DAG (Directed Acyclic Graph)
An SVO where identical subtrees are deduplicated and shared (Kämpe,
Sintorn, Assarsson, "High Resolution Sparse Voxel DAGs," 2013).
- **Strengths**: dramatic memory reduction when a scene has many
  repeated substructures (famous demo: entire detailed voxel scenes in
  a few hundred MB).
- **Weaknesses**: the dedup benefit depends on repeated identical
  substructure. Our specimens are each procedurally *unique* by design
  (that's the whole point), so cross-specimen sharing is weak; DAGs are
  also read-optimized/hard to mutate cheaply, since editing one instance
  of a shared node must first detect the sharing and unshare it. Better
  fit for static, baked, rarely-edited worlds (think Minecraft-scale
  worlds, not a single growing fern).

### Brick map / bricked sparse grid (OpenVDB, NanoVDB, Teardown-style engines)
A coarse sparse top-level index (hash map or small grid) maps occupied
regions to small **dense bricks** (e.g. 8³ or 16³ voxels each). Only
allocate bricks that contain any voxels.
- **Strengths**: cheap, predictable traversal (top-level lookup + one
  dense brick access — no deep pointer chains); bricks are cheap to
  mutate in place (rewrite a brick when a branch grows); maps directly
  onto GPU-friendly 3D textures per brick; this is what OpenVDB (the
  film/VFX industry standard for sparse volumes) and NanoVDB (its
  GPU-read-optimized counterpart) are built around, and it's the
  approach real-time voxel-destruction games like Teardown use.
- **Weaknesses**: less extreme compression than a full DAG for very
  large uniform-empty scenes, but that's not our use case (specimens are
  small/medium, per-object).

### Palette-indexed dense array (Minecraft chunk format)
Each chunk stores a small per-chunk palette (list of distinct
block/material types actually present) plus a dense array of small
integer indices into that palette, bit-packed to the minimum width
needed. Not sparse in the octree sense, but very cheap and simple, and
works well when data is "mostly one or two materials" per local region.
- **Strengths**: trivial to implement, fast to iterate/mesh, good fit
  when the *number of distinct materials* per specimen is small (a
  coral has maybe 2–4 voxel "species": tissue, skeleton, algae, water
  line).
- **Weaknesses**: still O(n³) per chunk/brick — this is really a
  *value-encoding* trick, complementary to sparsity, not a substitute
  for it. Combine it with brick-based sparsity above (dense array
  *inside* each brick, palette-indexed).

### Flat sparse list (MagicaVoxel `.vox`)
A simple list of `(x, y, z, palette_index)` tuples plus a global color
palette. The de facto interchange format for indie voxel art tools and
readable by Blender via community importers/exporters.
- **Strengths**: dead simple, human-debuggable, excellent as an
  **authoring/interchange format** — directly relevant to the
  Blender add-on idea for hand-authored decor/furniture pieces, and a
  reasonable save-file format for a player's collected/completed
  specimens.
- **Weaknesses**: not meant for real-time large-scene rendering or
  frequent mutation at runtime; historically capped at 256³ per model
  (newer tooling raises this, but it's still an authoring format, not a
  runtime one).

## 3. Recommendation

Use **different formats for different jobs** rather than one format
everywhere:

1. **Generation-time**: run L-system / CA / space-colonization /
   reaction-diffusion generators into a dense scratch grid (or directly
   into bricks if the generator naturally has spatial locality, e.g.
   growing outward from a seed point). This is short-lived, CPU-side,
   and doesn't need to be sparse — it's discarded after meshing.
2. **Per-specimen runtime storage (for growth animation)**: a **bricked
   sparse grid** (8³ or 16³ dense bricks, palette-indexed within each
   brick). This is what supports incremental growth — new bricks get
   allocated and filled as an L-system branch extends or a coral head
   grows, without needing to touch unaffected regions. Small specimen
   size (tens of thousands of voxels, not millions) means the top-level
   sparse index stays tiny.
3. **Rendered representation**: once a specimen (or a growth keyframe)
   is finalized, run **greedy meshing** over the bricks to bake a
   low-poly triangle mesh, matching design-brief §5's "bake once, cache,
   treat as a static asset" plan. Real-time voxel ray-marching (direct
   SVO/brick ray casting instead of meshing) is a valid technique in
   some engines but is a poor fit for mobile GPU/power budgets — meshing
   to triangles keeps us on the same rendering path as any other mobile
   3D game asset.
4. **Authoring/interchange/save format**: a **MagicaVoxel-style flat
   sparse list** (`x,y,z,palette_index` + palette). Good for: reading
   assets made in Blender/MagicaVoxel for hand-authored furniture/decor,
   and for serializing a player's collected specimens to disk/cloud save
   without inventing a bespoke format.
5. **Room-level composition**: the room itself doesn't need a voxel
   spatial structure at all — it's a coarse scene graph of specimen
   instances (each one a baked mesh + transform), so standard
   engine-level culling/LOD applies. No SVO/DAG needed at the whole-room
   scale; that would be solving a problem we don't have (our "world" is
   a room, not a planet).

This combination avoids the two temptations that don't fit our scale:
full SVOs/DAGs (built for planet/city-scale static worlds we don't have)
and pure dense grids (fine for generation scratch space, wasteful to
keep resident for many simultaneous specimens).

## 4. Open question for engine selection

Godot has a mature open-source voxel module (Zylann's `godot_voxel`)
already implementing bricked sparse voxel storage, meshers (including
greedy/marching-cubes/transvoxel), and LOD — worth evaluating directly
rather than reimplementing this layer from scratch, if Godot is in
consideration for the engine. Unity and Unreal have third-party voxel
plugins with similar ideas but less directly reusable for a from-scratch
mobile project. Engine choice isn't decided yet — flagging this here
since it affects whether we build the brick/mesh pipeline ourselves or
adopt/extend existing tooling.
