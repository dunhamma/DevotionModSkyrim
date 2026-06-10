# PDV W0 — Pending-Copy Approvals Handoff (#16 + #18)

**For:** Codex (owns the spec/contract JSON edits, the Mutagen re-author, the `.psc`
paste, and compile). **From:** Claude. **Status:** both copy sets are authored and
review-ready; this handoff is the source→destination→action map to land them.

Both are **independent of the faucet/quest-reaction wiring** and can land in parallel
with it. No new wording is produced here — the approved text already exists in the two
review docs.

---

## Item #16 — Reward / boon / price description clarity (107 ADD rows)

**Source of approved text:** the **`Proposed description`** column (col 3) of
`references/authoring/PDV_RewardDescriptionClarity_Review_2026-06-09.md`. Each row keeps
its existing thematic line and appends a literal `(Effect: <magnitude>.)` clause for
deity-parity. The 151 "clear" rows in that doc need **no change**.

**Destination:** the `playerFacingText` field of the matching record in the spec/contract
JSONs under `references/authoring/`. The audit tool and the author tool both read
`playerFacingText`, so updating it there and re-authoring is idempotent.

**Row → destination file (107 ADD, all confirmed by grep):**

| Destination JSON | ADD rows | Which |
|---|---|---|
| `PDV_DaedricPrinceRecordContracts.json` | **96** | every `PDV_Bless_Daedric_*` (48 = 16 Princes × 3 tiers) + `PDV_Price_Daedric_*` (48). Structure: `princes[].boons[]` / `princes[].prices[]`, each with `playerFacingText`. |
| `PDV_BretonRewardRecords.spec.json` | 4 | `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal`, `_Excommunication`, `_ExposureRupture`, `_VowIntegrity` |
| `PDV_RedguardRewardRecords.spec.json` | 3 | `PDV_Bless_Redguard_AncestorSpine_T1`, `_HoonDing_T2`, `_HoonDing_T3` |
| `PDV_KhajiitRewardRecords.spec.json` | 2 | `PDV_Bless_Khajiit_Khenarthi_T3`, `_Substrate_High` |
| `PDV_ArgonianRewardRecords.spec.json` | 1 | `PDV_Bless_Argonian_Substrate_High` |
| `PDV_DunmerRewardRecords.spec.json` | 1 | `PDV_Bless_Dunmer_Substrate_High` |
| **Total** | **107** | |

**Codex action:**
1. For each ADD row, set the record's `playerFacingText` to the row's `Proposed
   description` text verbatim (it already includes the `(Effect: …)` clause).
2. Re-author the MGEF/SPEL `Description` via the Phase20 race-author Mutagen tool
   (`tools/pdv-phase20-race-author`), per-race spec + the Daedric contract. Idempotent —
   it reads `playerFacingText` and writes `Spell.Description` / `MagicEffect.Description`.
   For ESP writes, follow the houseCARL park-off-Anvil rule (memory
   `compat-reference-instances`).

**Design flag (carry, do not fix here):** several Daedric boons have flavor loosely
coupled to their ActorValue (e.g. Azura "foresight" backed by +MagickaRegen). Stating the
magnitude is honest clarity; whether the *effect* should match the flavor is a separate
design pass, out of scope for #16.

---

## Item #18 — Startup canonical copy (10 race blurbs + advisory)

**Source of approved text:**
`race-sheets/PDV_StartupCanonicalSummary_Rewrite_2026-06-09.md` — the 10 per-race blurbs
under "GetStartupCanonicalSummary - per-race blurbs" + the `STARTUP_ADVISORY_TEXT` block.
ASCII-safe (uses `'` and ` - `, no smart quotes/em-dashes); no embedded double-quotes, so
no Papyrus escaping needed.

**Destination (in `D:\…\Devotion\Scripts\Source\PDV__ManagerQuest.psc`):**
- The 10 blurbs → the per-race branches of `GetStartupCanonicalSummary(Int originRace)`.
- The advisory → the `STARTUP_ADVISORY_TEXT` AutoReadOnly String property.

> **Locate by symbol name, not line number.** The rewrite doc cites ~:6822-6841 / ~:353
> (an older snapshot); the live Anvil source had these nearer ~:7583-7607 and ~:356. Line
> numbers drift — find `GetStartupCanonicalSummary` and `STARTUP_ADVISORY_TEXT` directly.

**Race → branch:** Nord, Imperial, Breton, Dunmer, Altmer, Redguard, Orc, Bosmer,
Khajiit, Argonian — 10 blurbs map 1:1 to the 10 `originRace` branches (`ORIGIN_NORD` …).

**Codex action:** paste each blurb into its branch + the advisory into the property →
`node tools/pdv_compile.mjs` (NOT the generic MO2 compile) → `node tools/pdv_verify.mjs`.

---

## Verification gates
1. **#16:** all 107 ADD `playerFacingText` values updated; re-author run clean; spot-check
   a Daedric (`PDV_Bless_Daedric_Namira_Champion`) and a race row
   (`PDV_Bless_Redguard_HoonDing_T3`) show the new `(Effect: …)` clause on the in-game
   Spell/MGEF Description. The 151 "clear" rows untouched.
2. **#18:** compile 0/0; `pdv_verify` FAIL=0; startup MessageBox shows the new blurb for
   ≥2 races (one multi-god e.g. Nord, one substrate e.g. Khajiit).
3. **ASCII:** content verifier clean on both — 0 non-ASCII, no smart quotes/em-dashes.
