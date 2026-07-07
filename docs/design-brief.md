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

1. **Puzzle** — play a round of the PCR Cycle puzzle (see §3) to produce
   matched codons, which become collected DNA.
2. **Grow** — collected DNA is spent to generate a specimen (a plant
   species, tank type, or coral variant) procedurally as a voxel model,
   placed into the player's room/tank/terrarium. Growth may be animated
   over real or accelerated time (sprouting, branching, polyp budding).
3. **Curate** — player arranges specimens, buys furniture/decor/ambient
   music tracks, and tends to cats that accumulate in the room over time.
4. **Progress** — completing puzzle milestones unlocks the next biome
   tier and new puzzle mechanics/tile types themed to that tier.

## 3. Puzzle Mechanic: The PCR Cycle

The puzzle is a 3D voxel Tetris/match-3 hybrid, themed and structured
around real **PCR (polymerase chain reaction)** thermal cycling rather
than DNA being a cosmetic skin over a generic match-3.

**Setting**: the play area is a cube-shaped voxel grid that sits inside
a cute, stylized PCR machine — visually, the player is looking into the
PCR chamber itself. The grid starts small and grows larger over
successive rounds, which is the game's primary difficulty ramp.

**Camera controls**:
- Swipe left/right to rotate the whole play cube.
- Pinch to zoom in/out.
- Selecting a piece can zoom the camera onto it, with occluding pieces
  in front turning transparent so the selected piece stays reachable.
- A tray on the left lists pieces currently hidden/out of view, so the
  player can select them directly instead of hunting for them in 3D.

**Two-phase cycle** (mirrors real PCR's denature → anneal → extend
cycling):

1. **Drop phase (denature-equivalent)** — Tetris-style: fixed-shape
   pieces (tetromino-like clusters of voxels) fall into the cube, each
   containing a random codon (a triplet of DNA bases). The player moves/
   rotates each piece as it falls, same as Tetris.
2. **Anneal phase (candy-crush-equivalent)** — shape stops mattering
   entirely; every voxel in the cube is now an individual base. The
   player can only swap adjacent pieces (match-3 style), trying to line
   up matching **codons** (not shapes, not single bases).

**Resolution**: when a codon match is made, that group of voxels
animates — spiraling into a double-helix shape — and flies off to the
player's scoreboard/collection as a piece of completed DNA. The cycle
then repeats (new drop phase, new anneal phase), mirroring PCR's
repeated thermal cycles amplifying DNA.

**Payoff — Genome → organism link**: collected DNA is the resource
spent to grow specimens in the bioroom. The *type* of DNA produced by a
given codon match directly determines the resulting organism's species,
shape, color, and L-system/generator parameters (§5's "genome" parameter
set) — so the puzzle's output is literally the generative art system's
input, not a currency abstraction bolted on top.

## 4. Progression Tiers (Biomes)

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

## 5. Procedural Generation Approach (per biome)

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

## 6. Voxels: Why and How

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
- **Storage format decision** (see `voxel-format-research.md` for full
  survey): generate into a dense scratch grid, hold each growing
  specimen in a **bricked sparse grid** (small dense bricks, palette-
  indexed, allocated only where occupied — the same family of structure
  as OpenVDB/NanoVDB and Teardown-style engines), bake to a greedy-meshed
  triangle mesh once finalized, and use a MagicaVoxel-style flat sparse
  list only as the authoring/interchange/save format. Full sparse voxel
  octrees/DAGs are overkill here — those solve planet/city-scale static
  worlds, not room-scale unique specimens.

## 7. Non-Procedural Systems (well-understood, lower risk)

- **Puzzle engine**: the PCR Cycle described in §3. Standard mobile
  puzzle-game architecture underneath (falling-piece + swap-match
  engines are both well-trodden); the real design work is the codon →
  genome reward-mapping, not the puzzle mechanics themselves.
- **Cats**: simple personality/behavior-tree driven idle animals —
  wander, react to player taps, occasional unique "personality" barks/
  animations. Not simulation-heavy; can reuse existing idle-pet game
  patterns.
- **Economy**: furniture/decor/ambient-music purchases, likely on a soft
  currency earned via puzzle play plus optional IAP. Standard mobile
  free-to-play shop pattern.

## 8. Biggest Risks / Open Questions

1. **Scope**: this is six distinct procedural-generation domains plus a
   full 3D puzzle game plus a decor/economy layer plus a pet system — a
   full commercial game's worth of systems. Needs to be built and proven
   incrementally, one biome at a time, not designed monolithically up
   front.
2. **Mobile performance**: voxel meshing and multiple simultaneously
   visible generated specimens. Mitigated by baking meshes once at
   generation time rather than simulating live (see
   `voxel-format-research.md`).
3. **Puzzle onboarding**: the PCR Cycle's two-phase (drop then anneal)
   structure with codon (not shape/color) matching is more novel than a
   standard match-3, so first-time tutorialization needs real design
   attention to avoid feeling confusing.
4. **"Looks neat" vs. "looks like a real plant/coral"**: player-facing
   bar is aesthetic charm, not botanical/biological accuracy — generator
   parameters should be tuned by eye, not by trying to model real
   species precisely.
5. **Genome → visual mapping**: designing the parameter space so that
   puzzle rewards feel meaningfully different (not just re-skins) across
   dozens/hundreds of unlockable specimens is a content-design problem as
   much as a tech problem.

## 9. Recommended Next Step

Prototype the riskiest, most novel piece first: a standalone L-system →
voxel-grid → mesh generator for a single biome (tropical plants), with
tunable "genome" parameters, before building any puzzle-game or
room/economy scaffolding. This validates both the visual bar ("does it
look neat?") and the mobile meshing/performance approach before investing
in the rest of the game's systems.
