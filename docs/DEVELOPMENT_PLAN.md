# VoidGraft — Development Plan

All requirements trace to [`ORIGINAL_BRIEF.md`](ORIGINAL_BRIEF.md) (the owner's verbatim
brief); later owner directives are logged verbatim in [`DECISIONS.md`](DECISIONS.md).
This document tracks how each requirement is met and what comes next.

## Name

**VoidGraft** — assigned per the brief's "TBA or assigned by you", **confirmed by the
owner** (Directive 2). You destroy the void's tentacles and *graft* their parts onto
your own ship. Stylized VOIDGRAFT on the title screen.

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

## Touch layout rule (Directive 2)

The on-screen joystick lives on the **left** (left 46% of the screen). The **right
side — especially the lower-right — is reserved** for the planned full **SNES-style
control pad** (A/B/X/Y cluster, and shoulder-button zones at the top corners if we
add L/R). No HUD element may claim the lower-right touch zone.

## Status

- [x] v0.1 — playable core loop. *Not yet run in the Godot editor — needs a first playtest.*
- [x] v0.1.1 — owner decisions applied: name **VoidGraft**, landscape confirmed, Android
      export preset (`export_presets.cfg`, arm64, immersive landscape), lower-right HUD
      zone cleared for the future pad
- [ ] repo move — push to dedicated `kevindunn1981/voidgraft` once the owner creates it
      (Claude's GitHub integration cannot create repositories)
- [ ] v0.2 — playtest & tune on Android: difficulty curve, joystick feel, camera height, glow strength on real hardware
- [ ] v0.3 — audio (procedural/synth SFX + music), haptics on hit
- [ ] v0.4 — juice: tentacle hit reactions, score popups, combo multiplier, screen-space damage vignette
- [ ] v0.5 — SNES-style on-screen control pad (D-pad option on the left, A/B/X/Y on the right), mappable to game actions as they grow
- [ ] v1.0 — store polish: settings (sensitivity, shake toggle), pause-on-focus-loss, icon/splash, privacy page

## Resolved questions

All four v0.1 open questions were answered by Directive 2 (see `DECISIONS.md`):
name kept, dedicated repo approved, landscape confirmed, Android first.
