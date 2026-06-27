# Codex Handoff -- Nord Nine Divines reward-lane gap + eligibility-driven reward audit

Created 2026-06-27. Source: in-session adversarial sweep while wiring Old Ways Mara.
Owner-facing context: this is the gap class that slipped THREE standing audits + an adversarial
pass. Two deliverables: (1) close the Nord Nine Divines reward hole; (2) build the audit that would
have caught it, so the class can't recur silently.

## TL;DR
- A Nord who picks the **Nine Divines** baseline and commits to any of 7 Divines gets **zero tier
  rewards** -- the manager declares `PDV_Bless_Nord_<god>_T1/T2/T3` properties and the reward sync
  references them, but **those SPEL records were never authored in `Devotion.esp`**, so the
  properties are `None` and `SyncRaceRewardSpell(None, ...)` is a silent no-op.
- The sweep proved the gap is **isolated to the Nord Nine Divines lane**. Every other race's
  declared reward spells exist (authoritative diff below).
- **Mara is already fixed** (2026-06-27) by reusing the existing Imperial Mara spells; apply the same
  pattern to the remaining 7.

## Ground-truth diff (houseCARL, Devotion.esp, 2026-06-27)
MISSING (declared in `PDV__ManagerQuest.psc` ~L320-343, referenced in `SyncNordRewards`, NOT present
as SPEL records in `Devotion.esp`):

| Nord god (Nine Divines) | Missing Nord spells | Existing Imperial spells to reuse (FormID) |
|---|---|---|
| Akatosh | `PDV_Bless_Nord_Akatosh_T1/T2/T3` | `PDV_Bless_Imperial_Akatosh_T1/T2/T3` (0710BD/0710C0/0710C3) |
| Arkay | `PDV_Bless_Nord_Arkay_T1/T2/T3` | `PDV_Bless_Imperial_Arkay_T1/T2/T3` (0710CD/0710D0/0710D3) |
| Stendarr | `PDV_Bless_Nord_Stendarr_T1/T2/T3` | `PDV_Bless_Imperial_Stendarr_T1/T2/T3` (0710D5/0710D8/0710DB) |
| Zenithar | `PDV_Bless_Nord_Zenithar_T1/T2/T3` | `PDV_Bless_Imperial_Zenithar_T1/T2/T3` (0710DD/0710E0/0710E3) |
| Dibella | `PDV_Bless_Nord_Dibella_T1/T2/T3` | `PDV_Bless_Imperial_Dibella_T1/T2/T3` (0710E5/0710E8/0710EB) |
| Julianos | `PDV_Bless_Nord_Julianos_T1/T2/T3` | `PDV_Bless_Imperial_Julianos_T1/T2/T3` (0710ED/0710F0/0710F3) |
| Kynareth | `PDV_Bless_Nord_Kynareth_T1/T2/T3` | `PDV_Bless_Imperial_Kynareth_T1/T2/T3` (0710F5/0710F8/0710FB) |

ALREADY FIXED: Mara -> reuses `PDV_Bless_Imperial_Mara_T1/T2/T3` (0710C5/0710C8/0710CB) via the
`SyncNordRewardFamily(playerRef, -1, PDV_Mara, PDV_Bless_Imperial_Mara_T1/T2/T3, "Mara")` line.

The Imperial Mara/Akatosh/etc. spells are generically named ("Mara's Mercy", "Akatosh's ..."), carry
no Imperial-only text, and are Requiem-flat -- safe to reuse for a Nord.

## Deliverable 1 -- close the gap (RECOMMENDED: reuse, like Mara)
In `PDV__ManagerQuest.SyncNordRewards` (the block at ~L10986-10997), change each of the 7 Nine
Divines `SyncNordRewardFamily` calls to pass the **Imperial** spell properties instead of the
unfilled Nord ones. The Imperial properties are already declared (L248-271) and filled. Example
(Akatosh):

```papyrus
; was: PDV_Bless_Nord_Akatosh_T1/T2/T3 (declared but never authored -> None)
SyncNordRewardFamily(playerRef, NORD_BASELINE_NINE_DIVINES, PDV_Akatosh, PDV_Bless_Imperial_Akatosh_T1, PDV_Bless_Imperial_Akatosh_T2, PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
```

Repeat for Arkay/Stendarr/Zenithar/Dibella/Julianos/Kynareth. Keep `NORD_BASELINE_NINE_DIVINES`
(these are Nine-Divines-only, unlike Mara which is both lanes at -1). The dead `PDV_Bless_Nord_<god>_*`
property declarations can stay (harmless) or be removed in a later save-safe migration pass -- do NOT
remove mid-cycle without the version-gated migration discipline.

- Edit BOTH the authoritative live source (`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`)
  AND the tracked mirror (`live-source/Scripts/Source/PDV__ManagerQuest.psc`).
- Compile with `node tools/pdv_compile.mjs --script PDV__ManagerQuest` (expect 0/0, verify FAIL=0).
- Update `PDV_NordRewardRecords.spec.json` deityOwnership note (the GAP sentence) once closed.

DECISION FLAG for owner: reuse-Imperial-wholesale gives the Nord Nine Divines lane the *identical*
Imperial Nine Divines rewards (zero ESP work, consistent with Mara). The alternative -- authoring
Nord-flavored Nine Divines reward records -- is more content + a magnitude/Requiem-proof design pass.
Owner ruling for Mara was "identical to the 9 Divines version" (reuse); default the other 7 the same
unless told otherwise.

## Deliverable 2 -- the audit that would have caught this (the systemic fix)
Build `tools/pdv_eligibility_reward_coverage_audit.mjs` (read-only). The class that slipped every
gate is "a deity the code will make a focusable patron, whose reward chain has no backing ESP record."
No existing audit joins **code-eligibility** to **ESP-record-existence** -- they are all spec-anchored,
and these gods were never in the spec.

Required logic:
1. Enumerate every **focusable/offer-eligible deity per race+lane** from the Papyrus eligibility
   surfaces -- not from the spec:
   - Offer races: `IsNordOfferEligibleDeity`, `IsImperialOfferEligibleDeity`,
     `IsAltmerOfferEligibleDeity`, `IsDunmerOfferEligibleDeity` (parse the deity lists per baseline).
   - No-offer focus systems: Khajiit emphasis (`SyncKhajiitEmphasisRewards`), Bosmer path, Orc
     life-mode, Redguard sect, Argonian focus, Breton tradition.
2. For each focusable deity, resolve the reward spell editorIds it maps to in the `Sync*RewardFamily`
   calls (the (deity -> T1/T2/T3 property) mapping).
3. Ground-truth each reward spell **exists** in `Devotion.esp` (Mutagen read, same path the other
   tools use) AND the manager VMAD property is **filled** (not None) to that record.
4. FAIL (exit 1) on any focusable deity with a missing record or unfilled property; emit a ledger
   `PDV_EligibilityRewardCoverageLedger.md/.csv` of (race, lane, deity, tier, editorId, exists,
   filled).
5. Add it to the gate bundle in `PDV_BetaFeelBurndown.md` and the integrity harness so it runs with
   the others.

This generalizes beyond rewards: the same "enumerate from code, ground-truth in ESP" shape should
later cover offer MESGs, neglect SPELs, and curse records (all declared-property classes). Reward
spells first.

## Sweep scope / what is NOT broken (so this isn't read as a wider panic)
Authoritative diff confirms all declared reward spells EXIST for: Altmer, Argonian, Bosmer, Breton,
Dunmer, Imperial, Khajiit, Orc, Redguard. The ONLY missing reward records are the 7 Nord Nine Divines
gods above. One low-priority footnote to verify: `PDV_Bless_Khajiit_Substrate_Mid` did not appear in
the existence list (Always + High did) and has no `Spell Property` declaration in the grep -- confirm
whether Khajiit mid-substrate is wired under a different name or is a genuine (minor, always-on, not a
focusable-patron) gap.

## Proof boundary
Machine/readback only at handoff time. After the 7-god fix: compile 0/0 + verify FAIL=0 + the new
coverage audit PASS. In-game proof = a Nine Divines Nord commits to (e.g.) Akatosh and sees the tier
reward apply -- separate manual step.

## Implementation closeout update
Implemented 2026-06-27:

- Nord Nine Divines reward sync reuses the Imperial Divine reward SPELs for Akatosh, Arkay, Stendarr,
  Zenithar, Dibella, Julianos, and Kynareth, matching the Mara pattern. No new Nord Divine reward
  records were authored.
- `PDV_NordRewardRecords.spec.json` now treats the Imperial-reuse model as the closed contract.
- `tools/pdv_eligibility_reward_coverage_audit.mjs` joins live Papyrus reward eligibility/mapping to
  live `Devotion.esp` SPEL existence and `PDV__ManagerQuest` VMAD property fill, writing
  `PDV_EligibilityRewardCoverageLedger.md/.csv`.
- `tools/pdv_integrity_harness.mjs` runs the new audit as a blocking gate.
- Medallion roster builders now use non-selectable live roster entries where a deity record exists,
  and `SelectMedallionEntry` always returns false so medallion display cannot bypass the offer flow.

Verification run 2026-06-27:

| Gate | Result | Notes |
|---|---|---|
| `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` | PASS | 0 errors, 0 warnings; wrapper verifier FAIL=0 |
| `node .\tools\pdv_verify.mjs --strict-neglect-decay --json` | PASS | FAIL=0, WARN=1, PASS=3495; warning is medallion glyph fallback only |
| `node .\tools\pdv_phase2_reward_readback_audit.mjs --json` | PASS | PASS=1325 |
| `node .\tools\pdv_deity_chain_audit.mjs --json` | PASS | blockers=0, resolutionGaps=0, reachabilityGaps=0 |
| `node .\tools\pdv_deity_chain_audit.mjs --self-test` | PASS | Synthetic fixture catches missing reward/offer/reachability failures |
| `node .\tools\pdv_eligibility_reward_coverage_audit.mjs --json` | PASS | 147 rows, 0 failures |
| `node .\tools\pdv_eligibility_reward_coverage_audit.mjs --self-test` | PASS | Catches missing SPEL, unfilled manager property, and ignores pending roster entries |
| `node .\tools\pdv_integrity_harness.mjs` | PASS | New `eligibility_reward_coverage` gate is blocking and clean with the Anvil MO2 MCP available |

Integrity-harness stop condition for smoke prep: `node .\tools\pdv_integrity_harness.mjs` must stay
PASS. If it later reports live-ESP columns as SKIP, that is an MCP/readback availability boundary and
must be cleared before smoke testing.

### Smoke-test checklist

This is runtime/manual proof, not a replacement for the machine gates:

1. Start a fresh Nord path and choose the Nine Divines baseline.
2. Raise or force a non-Mara Divine such as Akatosh to Seeker, Devoted, then Champion.
3. Confirm commitment happens through the offer flow, not by selecting the medallion entry.
4. Confirm the expected Imperial reward spell appears in Active Effects at each tier.
5. Confirm the medallion shows live roster entries as non-selectable display entries.

## Deliverable 3 -- medallion roster honesty (cross-race rollout; Nord DONE)
Owner ruling 2026-06-27: the **medallion is a roster DISPLAY; commitment is the OFFER flow**, not a
direct medallion-pick. Today the medallion's `SelectMedallionEntry(optionId)` calls
`SetActiveDeity(deity)` -- an instant patron commit that bypasses the >=50-piety + offer gate -- wired
for only 6 "reference" deities (kyne/talos/auri-el/yffre/zen/baan-dar); every other native god shows a
FALSE `"Awaiting live deity record and scoring path"` even when live and scorable.

DONE this session (Nord, both authoritative + mirror sources, compiled 0/0):
- Added helper `RosterMedallionEntry(optionId, title, kind, symbol, deity, summary)` -- emits a
  non-selectable entry that reads as a live patron ("...is a living patron your people can name." /
  "Build devotion and this god offers to take you as their own.") when the deity is live
  (`IsMedallionDeitySelectable`), else falls back to `PendingMedallionEntry`.
- Rewrote `GetNordMedallionEntriesJson` to use it for all 13 entries -- this also reconciles Kyne/Talos
  to non-selectable (was selectable), so the Nord medallion is internally consistent and never offers a
  direct-commit button.

DONE (cross-race rollout): the other roster builders now call `RosterMedallionEntry` for live deity
properties and keep no-record gods pending. Redguard Satakal/Ruptga/Tava/Onsi, Breton/Altmer Phynaster,
Altmer Syrabane, and Khajiit Riddle'Thar/Jone-Jode remain pending because no live manager property is
available.

DONE (retire the vestigial backend): `SelectMedallionEntry` and `CanSelectMedallionEntry` now always
return false. The old option-id maps can remain as inert read helpers, but they no longer provide a
commitment path. Acceptance: no medallion entry should be `selectable:true`; `SelectMedallionEntry`
cannot commit a patron; offer flow remains the only commitment path.
