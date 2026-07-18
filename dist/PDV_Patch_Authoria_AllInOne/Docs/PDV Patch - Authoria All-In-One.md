# Devotion Patch - Authoria All-In-One

Every Devotion compatibility patch for the Authoria (Requiem Reforged) list, in
one package. Merges two parallel work streams (2026-07-17).

## What it needs

- Devotion (PlayerDevotion) Beta 1.0 or later.
- The Authoria list. Optional mods are resolved at runtime with
  `GetFormFromFile`; anything absent stays dormant.

## What it contains

**Scripts (override Devotion's own -- install so these win):**
- `PDV_PlayerEvents`, `PDV__ManagerQuest`, `PDV_EventBus` -- carry ALL of:
  - the bard-performance hook (soft-dependent poll: SGT expertise deltas +
    Become a Bard playing-edge, per-tavern daily cap, ovation bonus),
  - the per-mod matrix channel loader (scans `Channels/`),
  - the Papyrus tick optimization (10s cadence for the disfavor sweep),
  - the Paarthurnax/Alkosh double-penalty fix.
  These were MERGED, not taken from one side: a Beta 1.0-based build would have
  reverted the last three.
- 9 dialogue-hook TIF fragments (`PDV_TIF_*`).

**Plugin:**
- `PDV_Patch_Authoria_QuestMods.esp` (ESL-flagged, 21 records) -- adds outcome
  stages to War's Folly / Once We Were Here / Whispers of the Depths and binds
  the fragments to the player's chosen dialogue lines.

**Data:**
- `PDV_QuestReactionMatrix.json` -- core matrix incl. Innocence Lost QE s198
  (the merciful branch: Stendarr, Mara, Stuhn approve; Molag Bal disapproves).
- `PDV_QuestReactionMatrix_ARR.json` -- 64 quest keys (the original 22 ARR
  cells + 42 tranche-2 cells: Wyrmstooth, CC The Cause / Ghosts of the Tribunal
  / Divine Crusader / Gray Cowl, Saturalia, M'rissi, Siege at Icemoth, Taste of
  Death, Forsworn, Hunt for the Spectre, Calling the Watchmaker, Above all Else,
  and the BaB / Bards Reborn milestones).
- `Channels/` -- 10 per-mod channels (Sirenroot, The Rot Below, The Frozen
  Heart, Depths of the Soul, Baba Yaga, Bark and Bite, Before the End, War's
  Folly, Once We Were Here, Whispers of the Depths).
- `PDV_AuthoriaARR_DaedricShrines_SWAP.ini` -- Base Object Swapper lines turning
  the Daedric Shrines AIO statues (and the Wyrmstooth Nocturnal/Vaermina
  placements) into Devotion prayer activators. Jyggalag is classify-only:
  Devotion has no Jyggalag deity, so it must award nothing.

## One deliberate de-duplication

Innocence Lost s198 was authored independently by both streams and the evidence
agreed. The core matrix keeps the fuller four-deity sweep; the ARR channel's
two-deity version was REMOVED rather than shipped, because the resolver reads
core first and the ARR row would have been dead weight -- and a latent trap if
the core row were ever removed.

## Do not

Place this below generated tool output, or copy its data into Requiem for the
Indifferent, ParallaxGen, DynDOLOD, Synthesis, TexGen, xLODGen, or NPC Plugin
Chooser output. Regenerate those tools after source changes.

## Proof state

Machine-verified only: all scripts compile 0 errors / 0 warnings and the PDV
verifier passes (FAIL=0); the plugin's records were read back from disk; every
matrix channel passes the compiler check. Nothing here has run in game. Cells
lacking a terminal-record proof carry `runtimeVerify=pending`. See
`PDV_Phase21_ARR_SmokeRunbook.md` for the runtime gate.
