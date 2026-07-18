# PDV ARR tranche 2 implementation

Built against the Authoria instance at `C:\1. AUTHORIA` on 2026-07-16.

- Source CSV: `tools/PDV_QuestReactionMatrix_ARR_Tranche2.csv`
- Compiler: `tools/pdv_quest_matrix_compile.mjs`
- Generated channel: `Devotion/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR.json`
- Every cell without a `Complete Quest`/terminal record proof is marked
  `runtimeVerify=pending` in the generated JSON.

## Innocence Lost QE

Winner-level SSEDump text proof:

- s198: Grelod is imprisoned for the rest of her days. This is the merciful
  branch and awards Mara/Stendarr.
- s199: Grelod is killed while imprisoned. No mercy row.
- s201: the same killed-in-prison outcome. No mercy row.

## Seeking The Cure / VC01

Enumerated stages:

`0,1,2,3,4,5,6,7,25,50,60,61,62,63,64,65,70,100,125,150,175,180,185,195,196,197,200,201`

s200 and s201 are explicitly failed Falion rituals (s201 also kills Falion).
No cure-success terminal was proven on VC01, so an incorrect
`cure_undeath` row was deliberately not authored.

## Bard hook

`PDV_PlayerEvents` now resolves all bard forms with `GetFormFromFile`, polls at
five seconds, detects SGT expertise deltas and the Become a Bard playing
1-to-0 edge, debounces the two signals, and uses the 25-entry tavern-count list
for a per-tavern daily cap. `PDV__ManagerQuest` applies SGT quality/ovation
scaling behind Devotion's existing daily repeat multiplier. Missing bard mods
leave the poll disabled.

BaB tavern/Jarl s100 and the two Bards Reborn completion stages are matrix
milestones for Dibella.

## Kynareth Replaces Talos

The new spell `MissileKynarethsWatchfulEye` (`0x00080C`) was inspected in
`Kynareth Replaces Talos - Civil War Consequence.esp`. Its three effects are
hidden script/quest-stage trackers, not a vanilla-style blessing or stat buff.
It was therefore not added to the shrine-blessing neutralization targets.

## Supplemental quest-mod FOMOD

`PDV_QuestModPatches_FOMOD_20260716.zip` was retained as supporting input, but
its ten standalone channel files were not folded into the ARR matrix. Devotion
Beta 1.0 currently scans the core and ARR matrices rather than arbitrary channel
files, and several of those quests still require the requested stage/log-text
readback. Integrating them without that verification would overstate TODO-5.
