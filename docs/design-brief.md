# Design Brief: Untitled Voxel Ecosystem Game

*Living design document — expect this to change as the concept is prototyped.*

## 1. High-Concept

A mobile game where the player solves DNA-themed match-3/Tetris puzzles to
"unlock" living organisms, then places and grows those organisms as
procedurally generated **voxel** ecosystems inside a room they're slowly
filling out — plants, then aquatic/terrarium setups, then coral, alongside
a growing colony of personality-driven cats and purchasable furniture/decor.

The hook: nothing placed in the room is a static asset. Plants, coral,
and terrarium contents are generated on the fly by procedural rules
(L-systems, space colonization, cellular automata, reaction-diffusion),
so each specimen is unique, and being voxel-based means the player can
walk the camera in close (individual leaves/polyps) or pull back to see
the whole room, at consistent visual fidelity.

## 2. Core Loop

1. **Puzzle** — play a DNA-themed match-3/Tetris session (matching
   base-pair symbols, combo mechanics tied to "gene" tiles) to earn a
   specimen unlock (a plant species, tank type, or coral variant) or
   currency.
2. **Grow** — the unlocked specimen is generated procedurally as a voxel
   model and placed into the player's room/tank/terrarium. Growth may be
   animated over real or accelerated time (sprouting, branching, polyp
   budding).
3. **Curate** — player arranges specimens, buys furniture/decor/ambient
   music tracks, and tends to cats that accumulate in the room over time.
4. **Progress** — completing puzzle milestones unlocks the next biome
   tier and new puzzle mechanics/tile types themed to that tier.

## 3. Progression Tiers (Biomes)

Unlocked roughly in this order, each introducing new procedural-generation
rules and new puzzle tile types:

1. **Tropical plants** (potted, windowsill) — L-systems, branching foliage.
2. **Terrariums** (closed glass, moss/springtail ecosystems) — cellular
   automata for substrate/moss spread, small L-system plants.
3. **Ripariums** (part-land, part-water tanks) — combines terrarium rules
   with simple water-line simulation and emergent plants.
4. **Paludariums** (larger land/water, more vertical) — adds fauna
   placement logic (frogs, small climbers) and waterfall/mist elements.
5. **Planted tanks** (fully aquatic, aquascaping) — space-colonization
   algorithm for aquatic plants, current/sway animation.
6. **Coral tanks** (reef) — reaction-diffusion and space-colonization
   hybrids for branching/plate/brain coral morphotypes, plus fish.

Each tier's specimens stay visible/interactive after unlocking the next
tier — the room keeps accumulating, it doesn't replace.

## 4. Procedural Generation Approach (per biome)

| Biome | Primary algorithm(s) | Notes |
|---|---|---|
| Tropical plants | L-systems | Parametrized by species "genes" won in puzzle (branching angle, leaf shape, height) |
| Terrarium | Cellular automata + L-systems | CA for moss/substrate coverage and moisture spread; small-scale L-systems for ferns/mosses |
| Riparium | CA + L-systems + simple fluid/waterline sim | Waterline is likely a fixed plane + shader effect rather than true fluid sim (mobile perf) |
| Paludarium | Above + rule-based fauna placement | Frogs/climbers placed via constraint rules (near water, on vertical surfaces) |
| Planted tank | Space colonization algorithm | Better than L-systems for organic, attraction-point-driven aquatic plant shapes |
| Coral | Reaction-diffusion + space colonization | Reaction-diffusion for plate/brain coral surface patterns; space colonization for branching coral (staghorn, etc.) |

All outputs are generated as voxel grids, then meshed for rendering
(greedy meshing / marching cubes depending on desired look — sharp
"blocky" vs. smoothed organic). A shared **specimen "genome" parameter
set** (won from the puzzle game) seeds each generator, so puzzle rewards
map directly to visual variation — this is the throughline between the
puzzle meta-game and the generative art.

## 5. Voxels: Why and How

- Consistent art style across macro (whole room) and micro (single
  polyp) zoom levels — no LOD art switch, since voxel resolution can just
  increase for a close-up mesh regen or shader-based detail.
- Real-time or precomputed generation: for mobile, precomputing the
  voxel grid at unlock time (not regenerating per frame) keeps runtime
  cost bounded. Growth animation can be done as either (a) a sequence of
  precomputed voxel-grid keyframes crossfaded, or (b) simple prefix-reveal
  of an L-system's already-computed structure (branch-by-branch) — no
  need for live-fluid-style simulation.
- Meshing strategy is the main mobile-perf risk: naive per-voxel cubes
  won't scale to many specimens visible in a room. Greedy meshing
  (merging coplanar faces) or a fixed low-poly "cube-marching" pass at
  unlock time (bake mesh once, cache it, treat as a static asset from
  then on) keeps runtime cost equivalent to any other 3D game asset.

## 6. Non-Procedural Systems (well-understood, lower risk)

- **Puzzle engine**: match-3/Tetris hybrid, DNA theming (base-pair
  matches, "gene" combo tiles). Standard mobile puzzle-game architecture;
  main design work is the reward-mapping (puzzle outcome → genome
  parameters) rather than the puzzle mechanics themselves.
- **Cats**: simple personality/behavior-tree driven idle animals —
  wander, react to player taps, occasional unique "personality" barks/
  animations. Not simulation-heavy; can reuse existing idle-pet game
  patterns.
- **Economy**: furniture/decor/ambient-music purchases, likely on a soft
  currency earned via puzzle play plus optional IAP. Standard mobile
  free-to-play shop pattern.

## 7. Biggest Risks / Open Questions

1. **Scope**: this is six distinct procedural-generation domains plus a
   full puzzle game plus a decor/economy layer plus a pet system — a
   full commercial game's worth of systems. Needs to be built and proven
   incrementally, one biome at a time, not designed monolithically up
   front.
2. **Mobile performance**: voxel meshing and multiple simultaneously
   visible generated specimens. Mitigated by baking meshes once at
   generation time rather than simulating live.
3. **"Looks neat" vs. "looks like a real plant/coral"**: player-facing
   bar is aesthetic charm, not botanical/biological accuracy — generator
   parameters should be tuned by eye, not by trying to model real
   species precisely.
4. **Genome → visual mapping**: designing the parameter space so that
   puzzle rewards feel meaningfully different (not just re-skins) across
   dozens/hundreds of unlockable specimens is a content-design problem as
   much as a tech problem.

## 8. Recommended Next Step

Prototype the riskiest, most novel piece first: a standalone L-system →
voxel-grid → mesh generator for a single biome (tropical plants), with
tunable "genome" parameters, before building any puzzle-game or
room/economy scaffolding. This validates both the visual bar ("does it
look neat?") and the mobile meshing/performance approach before investing
in the rest of the game's systems.
