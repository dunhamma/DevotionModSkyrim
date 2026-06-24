# PDV Session Handoff -- 6f Rite Build (overnight 2026-06-25 -> for next session)

## TL;DR
All three **6f variety RITE systems are built in Papyrus, committed, and compiling 0/0** --
inert until their ESP records are authored (the `None`-guard pattern). The remaining work is
a **supervised ESP-record authoring pass** (turnkey spec written) plus two env/owner-gated
tracks. Gate state is fully GREEN. Nothing is half-broken; every increment is committed.

## What landed this session (committed to main)
| Commit | What |
|---|---|
| `215348f` | Queue-B release-prep closeout (V1-dialogue removal tool + doc sync) |
| `14d9ac3` | **Orc Trial of Iron** Papyrus rite trio (inert until MESG binds) |
| `9b73bf2` | **Redguard Remembering of Names** Papyrus rite trio (inert until records bind) |
| `2c3e26e` | **Altmer Disciplines of Return** Papyrus rite trio (inert until records bind) |
| (this doc commit) | 6f gate-spec + ratified ledger rows + this handoff |

All three mirror the proven **Bosmer Naming** template (sleep-triggered, 7-day cooldown,
"Not yet" doesn't spend it, one-active clear-before-add, dawn fade/restore on coherence
break). Reuse what's built: Orc/Redguard ride the existing declared-rest-cell
(`IsPlayerAtDeclaredRestCell`); Altmer rides `HandleAltmerSleepEvents` (already curse-guarded).

## Current gate state (all GREEN)
- `pdv_compile` (PDV__ManagerQuest) **0 errors / 0 warnings**, ASCII-clean
- `pdv_verify` **FAIL=0**
- `pdv_signal_e2e_gate` **39 GREEN / 0 RED**, curated parity PASS
- `pdv_signal_floor_audit` **51 PASS / 0 UNDER-FLOOR** (A1 from earlier)
- `pdv_integrity_harness` **PASS**; `pdv_specced_minus_audit` 0; ledger-coverage CLEAN; anti-farm `uncappedGain: []`
- **live-source <-> MO2 manager copies are SYNCED** (I synced after each edit; compile reads MO2).

## THE remaining work -- supervised ESP-record authoring (turnkey)
Full manifest + ratified magnitudes/AVs/button-orders + acceptance refuters:
**`references/authoring/PDV_6f_RiteBuild_GateSpec_2026-06-25.md`**. Summary:
- **Orc** -- author **1 record**: `PDV_MESG_Orc_TrialOfIron` (buttons `[Tusk,Shield,Hammer,Yoke,Not yet]`) + VMAD-wire. SPEL+MGEF already exist. *(smallest -- do first as the pipeline proof.)*
- **Redguard** -- 4 SPEL+MGEF (Blade OneHanded+5 / Road StaminaRateMult+8% / Rest HealRate+5%, both **PeakValueModifier** / Harvest **Speech**+5%) + `PDV_MSG_RedguardRemembering` + wire 5 props.
- **Altmer** -- 4 SPEL+MGEF (Alteration/Destruction/Illusion/Restoration each **-5% school cost**) + `PDV_MESG_AltmerDisciplines` + wire 5 props.
- **Method:** clone `tools/pdv-bosmer-variety-author` (fail-closed `EnsureMessage`/`EnsureSpell`+MGEF + VMAD wire), or route SPEL/MGEF via `pdv-phase20-reward-author`. **`--dry-run` FIRST** (Mutagen ActorValue enum drift: confirm `StaminaRateMult`/`HealRate`/`Speech` + the Fortify-school cost archetype; regen=PeakValueModifier). Backup Devotion.esp, `--esp`, `--check` slot dump, `pdv_verify` FAIL=0, recompile (props now bind), houseCARL readback.
- **Button order == `Get<Race>...Spell(index)` order** (startup-choice index==value lesson) -- a mismatch silently grants the wrong discipline.
- Why not done overnight: in-place Devotion.esp writes + spell-cost-AV verification want a `--dry-run`-then-eyes-on pass (and in-game proof), not an unattended run. The Papyrus is the high-value, low-risk half and it is fully landed.

## Also pending (separate)
- **Nord non-Kyne offers (B10)** -- 12 offer MESGs; copy already written in
  `race-sheets/PDV_RaceContent_Manifest.md:266-278`, manager props exist (~440-451), Nord NOT
  yet in `PDV_FormalOffer_RecordWave.spec.json` (covers Dunmer/Altmer/Imperial/Redguard).
  Same Mutagen-author path; `pdv_formal_offer_check.mjs` is the gate. (No author tool exists
  yet -- only the checker.)
- **Prisma bridge -- REBUILT + REDEPLOYED this session.** The cold-view focus-trap fix
  (`5301ec0`) is now live: rebuilt `native/DevotionPrismaBridge` clean (xmake v3.0.8, 0 warnings,
  `-WX`), deployed the fresh `DevotionPrismaBridge.dll` (413184 b) to
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\` (prior DLL backed up to
  `.dll.bak-20260624`). **xmake is a PORTABLE install at
  `C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe`** (not on PATH -- prepend it).
  Build: `Set-Location native\DevotionPrismaBridge; xmake -y`. REMAINING: in-game smoke of the
  focus-trap fix + the 5-stage UI hardening (`PDV_HO_PrismaHardening.md`) -- that's JS/HTML/CSS
  in `mod/PrismaUI/views/Devotion/` (no build env needed) + in-game iteration.

## Owner-gated (always)
- In-game fresh-save / `coc qasmoke` proof of each rite: menu at sleep, one-active swap,
  7-day cooldown, dawn fade/restore on coherence break (Orc=life-mode change; Redguard=sect
  switch; Altmer=enter a crisis). VMAD props bake at first init -> new save, not an old one.

## First moves next session
1. Author the **Orc MESG** (1 record) end-to-end as the pipeline proof; gate + readback.
2. Then Redguard (5) + Altmer (5) via the same `--dry-run`->`--esp` pass; gate each.
3. Recompile (properties bind, still 0/0); run the full cadence; commit per race.
4. Nord offers (B10) when ready; Prisma when the build env is up.

## Gotchas carried in
- **Sync live-source -> MO2 before every compile** (`.mjs` audits read live-source, `pdv_compile`
  reads MO2; a stale MO2 = false GREEN). I left them synced.
- **Don't re-author Orc SPEL/MGEF** -- they exist + are readback-clean.
- **Rite grants record NO `PDV.Driver.*`** (favor/buff channel, not piety) -- bake the carve-out
  so `pdv_ledger_coverage_audit` doesn't false-flag.
- Model/cadence note for the Claude<->Codex loop: memory `model-choice-for-codex-handoff-loop`.
