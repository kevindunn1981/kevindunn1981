# VOIDGRAFT — Development Plan

All requirements trace to [`ORIGINAL_BRIEF.md`](ORIGINAL_BRIEF.md) (the owner's verbatim
brief). This document tracks how each requirement is met and what comes next.

## Name

**VOIDGRAFT** (assigned per the brief's "TBA or assigned by you"). You destroy the
void's tentacles and *graft* their parts onto your own ship. Easy to rename —
it appears only in `project.godot`, the menu title, and docs.

## Engine / target

- Godot **4.4+** (GDScript), Mobile renderer.
- Landscape orientation, `canvas_items` stretch with `expand` aspect — scales to any phone.
- Runs on desktop too (mouse emulates touch; arrow keys as a dev fallback).

## Brief requirement → implementation map

| Brief requirement | Where it lives |
|---|---|
| Top down 3d game | Camera looks down at ~72°, gameplay on the XZ plane |
| spring_arm + camera attached to player | `player.gd` → `_build_camera_rig()`: `SpringArm3D` + `Camera3D` as children of the player body |
| Procedural: splines, primitives, parabolic | Tentacles: `Curve3D` splines skinned by `tube_mesh.gd`; ship/turret/arena: sphere/capsule/cylinder/box/torus primitives; grafted tentacles rise on a parabolic arc; saucer hull is a squashed sphere (parabolic profile). Zero imported assets. |
| Heavy particle use | Thrusters, tentacle tip spores, part trails, ambient dust, kill bursts, hit sparks, laser impacts, death explosion (`spawn_burst()` in `main.gd`) |
| Ship + on-screen joystick | `player.gd` + `virtual_joystick.gd` (floating touch joystick, drawn procedurally) |
| Spline tentacles that wave, swing, swirl from off screen | `tentacle.gd` — three motion styles (`WAVE`, `SWING`, `SWIRL`), anchored outside the visible arena |
| Tentacles grow in size and number | Wave director in `main.gd`: length, girth, HP, tracking speed and alive-count all scale with wave |
| Starting turret | `turret.gd` — auto-aims nearest tentacle, fires projectiles |
| Kill → break apart → parts join ship → new tentacles | `tentacle_part.gd` (tumble, then home to ship) → `Player.add_tentacle()` grafts a `PlayerTentacle` |
| Each new tentacle shoots a laser | `player_tentacle.gd` — hitscan laser via `main.fire_laser()` |
| GUI with typical elements | `ui.gd` — score, best, wave, health bar, graft counter, pause, wave banners |
| High score + high score board | `game_state.gd` autoload — top-10 board persisted to `user://highscores.json`, name entry on qualifying runs, boards on menu and game-over screens |

## Architecture

Everything is constructed in code; the only scene file is `scenes/main.tscn`
(a root node + `main.gd`). This keeps the whole game reviewable as text and
honors the "all elements procedurally constructed" rule.

```
main.gd            game controller: world build, wave director, combat services
├── game_state.gd  (autoload) persistent high scores
├── player.gd      ship (primitives), SpringArm3D+Camera3D, thrusters, mounts
│   ├── turret.gd            starting weapon
│   └── player_tentacle.gd   grafted laser tentacles (0–8)
├── tentacle.gd    enemy spline tentacle (Curve3D + tube_mesh.gd)
├── tentacle_part.gd  homing pickup dropped on kill
├── projectile.gd  turret bolt
├── tube_mesh.gd   shared spline→tube mesh generator (ImmediateMesh)
├── virtual_joystick.gd  procedural touch joystick
└── ui.gd          all GUI (menu / HUD / pause / game over / boards)
```

Combat uses simple distance checks against tentacle spline sample points
(no physics bodies) — cheap, deterministic, and tuned for mobile.

## Tuning knobs (current values)

- Arena radius 22, spawn ring 27, wave every 20 s.
- Tentacle length `15 + 1.8/wave` (cap 34), HP `16 + 7/wave`, alive cap `2 + wave` (max 11).
- Player: 100 HP, 8 graft slots; extra parts → +25 score and small heal.

## Status

- [x] v0.1 — playable core loop (this commit). *Not yet run in the Godot editor — needs a first playtest.*
- [ ] v0.2 — playtest & tune: difficulty curve, joystick feel, camera height, glow strength on real hardware
- [ ] v0.3 — audio (procedural/synth SFX + music), haptics on hit
- [ ] v0.4 — juice: tentacle hit reactions, score popups, combo multiplier, screen-space damage vignette
- [ ] v0.5 — Android export preset (+ iOS later), icon/splash, performance pass on-device
- [ ] v1.0 — store polish: settings (sensitivity, shake toggle), pause-on-focus-loss, privacy page

## Open questions for the owner

1. Name **VOIDGRAFT** — keep, or rename?
2. This is your GitHub *profile* repo (`kevindunn1981/kevindunn1981`) — its README is your public profile page. Move the game to a dedicated repo (e.g. `kevindunn1981/voidgraft`)?
3. Landscape orientation assumed — confirm (portrait is possible but changes joystick/HUD layout).
4. Which phone(s) will you test on? (Android export first?)
