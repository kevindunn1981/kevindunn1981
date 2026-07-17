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

## 9. UI & Menu System

- **Procedurally generated decoration, not procedurally generated
  layout**: menu panels/screens use rounded-corner containers and clear
  modern sans-serif typography as a stable, legible base — the
  proceduralism goes into decorative flourishes framing that base (vine
  growth around panel edges, small moss/coral accents that match
  whichever biome tier is currently the player's focus), generated with
  the same L-system engine used for plants. Decoration is seeded once
  per screen/theme and cached, not regenerated per frame — the goal is
  charm and variety between sessions, not jitter.
- **Design-token discipline**: corner radius, spacing, and panel color
  values should be defined once as shared tokens so every procedurally
  decorated panel still reads as one consistent system rather than a
  pile of bespoke screens.

## 10. Art Direction: Watercolor / Cel-Shaded Hybrid

- **Goal**: the voxel scene should read as *painted*, not rendered — a
  cel-shaded (quantized toon lighting) base combined with watercolor-style
  post effects (pigment/edge darkening at silhouette edges, noise-driven
  alpha granulation) composited onto a paper background — cold-pressed
  watercolor paper for a rougher, toothier feel, or mulberry paper for a
  softer, fibrous, more translucent feel, chosen per biome/mood.
- **Feasible as a shader stack**: (1) toon banding on lit voxel faces,
  (2) Fresnel/edge-detection pass for pigment-edge darkening, (3)
  noise-driven alpha variation for granulation, (4) multiply/overlay
  blend against a paper texture (optionally with a paper normal map so
  lighting subtly interacts with the paper's tooth). This is genuine
  shader R&D, not a simple reskin, but it's well-precedented (games like
  *Dordogne*, *GRIS*, and *Okami*'s ink-brush styling solve adjacent
  problems) and achievable on mobile as a single lean pass.
- **Prioritization note**: this is arguably as risky/novel as the
  L-system generator itself, since "does this look neat" depends
  entirely on the shader — a technically correct L-system plant rendered
  with flat default shading tells you nothing about whether the final
  art style lands. See §11's updated recommendation.

### Material-Specific Shaders: Wood & Glass

The general voxel watercolor/cel shader above is tuned for organic,
opaque, painted surfaces. Two materials behave differently enough to
need their own treatment, while still reading as part of the same world:

- **Wood** (driftwood/branch hardscape from §13, furniture/decor, PCR
  machine trim): grain generated procedurally — a radial "growth ring"
  gradient distorted by turbulence/fractal noise, the classic procedural
  wood technique — rather than painted texture per piece, keeping wood
  consistent with the game's "nothing is a static asset" philosophy. The
  grain still passes through the same toon-banding + edge-darkening pass
  as everything else, so it shows up as tonal/color variation within the
  painted look rather than as a glossy, photoreal-PBR material that
  would clash with the rest of the scene.
- **Glass** (terrarium/tank walls, the PCR chamber lid from §3): reading
  as "glass" in a watercolor world isn't the same problem as photoreal
  glass. A few cel-banded specular highlights (not a full reflection
  probe), Fresnel-driven edge brightening (glass reads more opaque/bright
  at grazing silhouette edges, more transparent face-on — cheap on
  mobile), and a light screen-space distortion standing in for refraction
  should be enough to sell it without expensive real refraction.
- **Transparency performance note**: true alpha-blended glass needs
  back-to-front sort order, which gets expensive and glitchy fast once a
  room has several tanks/terrariums visible at once (§12). Worth using a
  stylized dithered/stippled transparency (screen-door style) instead of
  real alpha blending for glass — it sidesteps sort-order issues
  entirely, costs less on mobile, and the dither pattern reads as
  watercolor stippling rather than a technical compromise.

## 11. Audio Direction: Generative Ambient Score

- **Palette**: wind in trees, chimes, a quiet breeze across a field,
  Native American and Asian (shakuhachi/dizi-style) flute. These share a
  **pentatonic** scale foundation, which is a genuinely useful
  coincidence: generating melodies restricted to a pentatonic scale is a
  well-known generative-music technique (Eno/Chilvers-style generative
  ambient apps like *Bloom*) precisely because pentatonic intervals are
  hard to make sound "wrong" — it's what makes procedural composition
  tractable without a dedicated composer curating every output.
- **Layered generative system**:
  - *Chime layer* — stochastic (Poisson-timed) note triggers on bell/
    chime timbres, mimicking real wind chimes' irregular triggering.
  - *Flute layer* — breathy, sample-based (or lightly physically
    modeled) pitched phrases with occasional pitch bends/vibrato,
    sparse and slow.
  - *Breeze/field bed* — filtered, slowly amplitude-modulated noise as
    a continuous low bed under the other two layers.
- **Same pattern as the rest of the game**: tie generation parameters to
  game state (biome tiers unlocked so far, room fullness, time of day)
  so the score subtly evolves with progress rather than looping a fixed
  track.
- **Thematic/technical throughline**: L-systems (already the core plant
  generator) have real prior art in algorithmic music composition —
  symbols can map to notes/rhythms instead of geometry. Worth reusing
  the same L-system engine for melodic phrase generation rather than
  building an unrelated system from scratch.

## 12. Biome Backdrops

Two separate backdrop layers, not one: **(a)** the room's own walls/
windows (a decor/economy purchase, §7), and **(b)** each individual
container's (pot/terrarium/tank) internal backdrop — matching how real
aquarists and terrarium-keepers actually stage backgrounds behind their
setups.

Rather than commissioning one static painting per biome, backdrops are
**layered 2D parallax matte paintings**: a gradient sky/water base +
noise-generated silhouette layers (mountains, canopy, cloud/mist) +
optional foreground blur, run through the same watercolor/cel shader
pass as the 3D scene (§10) so the backdrop and the specimens in front of
it read as one consistent painting rather than a 3D model glued onto a
flat photo.

Starting point per biome:
- **Tropical plants** — soft interior wall / blurred window-garden view.
- **Terrarium** — solid-color or soft gradient backing, consistent with
  how real terrariums are staged (foam-board style backgrounds).
- **Riparium** — blurred wetland horizon, muted greens/browns.
- **Paludarium** — jungle canopy silhouette, mist layer, occasional
  waterfall haze.
- **Planted tank** — gradient blue/green depth backdrop (mirrors real
  planted-tank background sheets), subtle light-ray shafts.
- **Coral tank** — deep blue-to-black gradient with animated caustic
  light shimmer.

**Procedural variation instead of more hand-painted assets**: time-of-day
and mood variants (dawn, dusk, overcast, etc.) are regenerations of the
same layered system (gradient stops + noise seed changed), not separate
art assets. This is what gets sold/unlocked as backdrop variety in the
economy system (§7) — real variety without a linear art-asset cost.

## 13. Hardscape Build Workflow

"Hardscape" (aquascaping term) is the inert structural layer — rock,
driftwood/branches, substrate — placed *before* living specimens,
forming the composition's backbone. Real aquascaping is built around this
step, so it deserves its own dedicated build mode rather than being
folded into "place a plant."

- **Palette**: hardscape pieces are procedurally generated, not a fixed
  prop catalog — rocks via fractured/Worley-noise voxel shapes across a
  few families (e.g. layered "seiryu-style" stone, rounded river rock),
  driftwood/branches via the same L-system branching skeletons used for
  plants (unleaved, wood-textured). This gives hardscape the same
  "always unique" quality as the living content.
- **Placement tool**: freeform drag/rotate/scale within the container's
  voxel volume, reusing the puzzle's camera language (swipe to orbit,
  pinch to zoom, §3) for consistency, with an optional grid-snap toggle
  for players who want precision over freeform.
- **Composition aids**, gamifying real aquascaping guidance rather than
  just explaining it in text: a toggleable rule-of-thirds/golden-ratio
  overlay grid, a soft focal-point highlight, and a live height-gradient
  hint (taller hardscape toward the back/sides, open space and lower
  material toward the front, for a sense of depth) — presented as gentle
  visual guides, not hard constraints, in keeping with the relaxing tone.
- **Auto-arrange option**: a one-tap procedural layout generator for
  players who don't want to hand-place every rock — a constraint-based
  placement pass (avoid overlap, favor odd-numbered groupings per the
  classic aquascaping "rule of odds," height gradient front-to-back) that
  the player can then hand-tweak rather than starting from a blank tank.
- **Planting integration**: once hardscape is placed, it defines *where*
  subsequently grown organisms are allowed to root/attach — moss and
  epiphytic plants bind to rock/wood surfaces, substrate-rooted plants go
  in open substrate pockets, coral frags mount onto rock faces. Hardscape
  placement isn't just decorative — it's the scaffold the procedural
  growth systems (§5) attach to.
- **Save/undo**: hardscape layouts should be freely undoable/swappable
  before living specimens attach to them (since grown organisms are
  harder to relocate once rooted, both thematically and technically), and
  worth supporting saved hardscape presets/templates the player can reuse.

## 14. Floorplan Designer

The room isn't one fixed space that just gets more crowded forever — it's
a **modular floorplan** the player builds out over time, structurally
separate from the cosmetic wallpaper/backdrop system (§12) and the
furniture/decor economy (§7). This gives "the room slowly filling out"
(§1) real spatial weight: progression naturally unlocks new rooms and
expansions, and each biome tier can get a room genuinely suited to it,
rather than every biome tier's contents piling into one increasingly
cluttered space.

- **Editing model**: a grid-based, top-down "build mode" (same lineage as
  *The Sims*/*House Flipper*/mobile home-design games), toggled
  separately from the normal 3D orbit "living view" (§3's swipe/pinch
  camera language carries over once back in living view). Walls, doors,
  and windows are modular pieces that snap to a grid rather than
  freeform wall-drawing — keeps geometry/collision generation tractable
  while still giving real layout freedom.
- **Progression tie-in**: each biome tier unlock grants a themed
  room/expansion module rather than just "more floor space" — e.g.
  unlocking terrariums grants a sunroom-style module with more window
  walls (suited to terrarium light), unlocking coral tanks grants a room
  styled around a reef theme. New floor tiles/rooms cost currency from
  the puzzle economy (§7), same as other unlocks — the floorplan itself
  becomes a progression reward, not just a sandbox tool available from
  the start.
- **Windows tie into backdrops**: a window placed on an exterior wall
  displays the layered procedural backdrop system from §12 rather than
  needing bespoke window art per floorplan configuration — one more
  place the generative backdrop system pays for itself twice.
- **Validity rules**: standard floorplan-builder constraints — wall
  segments align to the grid, and every room needs door connectivity
  back to an entrance (a flood-fill reachability check, the same
  technique sim-style building games use to prevent sealed/unreachable
  rooms).
- **Scale note**: this is house-scale, not open-world-scale, space — a
  full floorplan of modular rooms stays comfortably within mobile
  budget. Simple per-room occlusion (render only the current room plus
  immediately adjacent ones) is enough; no streaming/LOD system needed.

## 15. Recommended Next Step

Prototype the two riskiest, most novel pieces together rather than in
isolation: a standalone L-system → voxel-grid → mesh generator for a
single biome (tropical plants), rendered through a first pass of the
watercolor/cel shader from §10, with tunable "genome" parameters — before
building any puzzle-game or room/economy scaffolding. Geometry and shader
have to be judged together, since "does it look neat" is a property of
the combination, not either piece alone; a correct L-system plant in flat
shading and a great shader on a boring shape are both dead ends on their
own. This validates the visual bar, the mobile meshing/performance
approach, and the shader's mobile cost all at once, before investing in
the rest of the game's systems.
