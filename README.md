# DevotionModSkyrim

Immersive religion mod for Skyrim Special Edition. Tracks the player's devotion
through their race's own theological tradition -- daily behaviour, patron
commitments, and religious context -- rather than generic shrine-visiting bonuses.

**Current public release: 1.0.4** (2026-07-27) -- see
[Releases](https://github.com/dunhamma/DevotionModSkyrim/releases) and
[CHANGELOG.md](CHANGELOG.md). No new game required to update.

> **Requiem users:** Devotion ships its own `Scripts\TempleBlessingScript.pex`.
> Requiem's bugfix packs ship the same file, so in MO2 **Devotion must sit below
> them** (below = higher priority = wins the file). Nothing warns you if this is
> wrong. Confirm under MO2's **Data** tab: `Scripts\TempleBlessingScript.pex`
> should list **Devotion** as its provider.

## Repository layout

This repo is the project's reasoning and resource layer for the mod -- architecture,
design references, ledgers, and the toolchain -- alongside the Papyrus source.
Compiled scripts and the plugin ship from the live mod folder, not from git.

| Path | What it is |
|------|------------|
| `AGENTS.md` | Canonical project context: build status, file map, decisions log |
| `PDV_Architecture_v3.md` | Forward architecture and roadmap |
| `PDV_TargetEndStates_1.0.md` | Per-race launch acceptance tracker |
| `PDV_MOD_SETUP.md` | Dev environment, build toolchain, conventions |
| `PDV_STANDARDS.md` | Operating rules and doc hygiene |
| `live-source/Scripts/Source/` | Tracked mirror of the live Papyrus source |
| `references/` | Design references, authoring contracts, ledgers |
| `tools/` | Compile, verify, audit, and release-packaging scripts |
