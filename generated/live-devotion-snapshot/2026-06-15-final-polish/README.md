# Live Devotion Snapshot - 2026-06-15 Final Polish Baseline

This directory is a narrow copy of live MO2 artifacts from:

`D:\Wabbajack\modlists\Anvil\mods\Devotion`

It exists so the `claude/final-polish-look` branch contains a tracked baseline of
the live Papyrus source and the consolidated framework plugin AFTER the 2026-06-15
`PlayerDevotion_Framework.esp -> Devotion.esp` rename and the 10-race
voice-conformance pass. Every later polish diff (ESP MESG wiring wave, diegetic D1,
reward-description clarity) is measured against this base.

Captured: all `Scripts/Source/*.psc`, `Devotion.esp`, and `Seq/Devotion.seq`.
Compiled PEX are intentionally excluded (regenerable via `tools/pdv_compile.mjs`).
The live folder's overlay/patch ESPs (`PDV_*WirePatch.esp`, `PDV_*Overlay.esp`) and
`.bak` backups are NOT part of the consolidated baseline and are excluded by design.

Normal source authority remains the authored contracts, tools, and live MO2 mod folder.
`manifest.json` records original paths, byte counts, timestamps, and SHA-256 hashes
for each copied artifact.