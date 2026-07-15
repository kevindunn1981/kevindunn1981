# Owner Directives — Verbatim Log

Per the founding brief's rule ("Please record this exact message and no paraphrased
development"), every design directive from the owner is recorded here word-for-word,
newest last. The founding brief itself is in [`ORIGINAL_BRIEF.md`](ORIGINAL_BRIEF.md).

---

## 2026-07-15 — Directive 2

> VoidGraft sounds cool. Sure move it to the repo. Landscape is fine. Eventually we'll add the full SNES control pads so make sure the on screen joystick is on the left. Android will work.

**Decisions taken from this directive:**

1. **Name confirmed: VoidGraft** (stylized VOIDGRAFT in the game's title screen).
2. **Move the game to a dedicated repo** → `kevindunn1981/voidgraft`. *Status: blocked —
   the Claude GitHub integration cannot create repositories (403). Owner needs to create
   the empty repo on GitHub, then the game gets pushed there.*
3. **Landscape orientation confirmed.**
4. **Future: full SNES control pads.** The on-screen joystick must stay on the LEFT
   (it already is — it occupies the left 46% of the screen). The right side of the
   screen is reserved from now on for the future A/B/X/Y button cluster; no HUD
   elements may claim the lower-right touch zone except the button pad when it lands.
5. **Android is the export target.** Android export preset added (`export_presets.cfg`).

---

*End of log. Append new directives above this line's section, never edit old ones.*
