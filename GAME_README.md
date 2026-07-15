# VOIDGRAFT

A top-down 3D mobile arcade game built in **Godot 4.4+**. Pilot a lone ship with an
on-screen joystick while spline-animated tentacles wave, swing and swirl in from off
screen. Shoot them down with your turret — every kill breaks apart and the pieces fly
back and **graft onto your hull as laser-firing tentacles of your own**. Survive the
waves, build your monster-ship, chase the high score.

Every model, effect and UI element is procedurally constructed from splines,
primitives and parabolic curves — there are zero imported art assets.

> The founding design brief is recorded verbatim in
> [`docs/ORIGINAL_BRIEF.md`](docs/ORIGINAL_BRIEF.md).
> The roadmap and requirement-to-code map live in
> [`docs/DEVELOPMENT_PLAN.md`](docs/DEVELOPMENT_PLAN.md).

*(This file is `GAME_README.md` because `README.md` in this repository is the
GitHub profile page.)*

## Run it

1. Install [Godot 4.4+](https://godotengine.org/download) (standard build).
2. Open this folder with the Godot Project Manager (it finds `project.godot`).
3. Press **F5** / Play.

On desktop the mouse emulates touch (click-drag the left half of the screen to fly);
arrow keys also work as a dev fallback.

## Controls

- **Drag on the left side of the screen** — fly the ship (floating joystick).
- Turret and grafted tentacles aim and fire automatically.
- **II** button — pause.

## Project layout

| Path | Purpose |
|---|---|
| `scenes/main.tscn` | The only scene file — everything else is built in code |
| `scripts/main.gd` | Game controller, wave director, combat services, world build |
| `scripts/player.gd` | Ship (primitives), SpringArm3D + Camera3D rig, graft mounts |
| `scripts/tentacle.gd` | Enemy spline tentacle (Curve3D, wave/swing/swirl) |
| `scripts/tube_mesh.gd` | Spline → tube mesh generator shared by all tentacles |
| `scripts/turret.gd`, `scripts/projectile.gd` | Starting weapon |
| `scripts/player_tentacle.gd` | Grafted laser tentacles |
| `scripts/tentacle_part.gd` | Homing part pickups dropped on a kill |
| `scripts/virtual_joystick.gd` | Procedural on-screen joystick |
| `scripts/ui.gd` | Menu, HUD, pause, game over, high-score boards |
| `scripts/game_state.gd` | Autoload — persistent top-10 high scores |
