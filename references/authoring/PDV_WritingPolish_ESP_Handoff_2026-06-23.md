# PDV Writing-Polish ESP Handoff (2026-06-23)

**Status:** Wording LOCKED with the user 2026-06-23. Deployment chosen: **in-place bake into
Devotion.esp** (NOT a houseCARL override patch -- release-clean). Skyrim + CK must be closed for
the ESP lock (was confirmed closed at handoff time: `tasklist` showed no Skyrim/CK process).
All FormIDs verified against the live load order (houseCARL, profile "Devotion Dev",
Devotion.esp ACTIVE).

**Source:** 2026-06-13 nine-race beta audit (`PDV_9Race_BetaAudit_2026-06-13.md` section 4,
needsReauthor). Full comb-through ledger lives in the session plan file. The docOnly fixes
(D3 Breton band ranges, D4/D5 Altmer ASCII) and the R2 manager recompile are already DONE +
live (manager recompiled 0err/0warn, verify FAIL=0). Only these ESP records remain.

**Mechanism notes:**
- The player-facing text for a magic effect is the MGEF `Description`; each PDV reward SPEL also
  carries a mirror `Description` with the same text. **Update BOTH** so they stay in sync.
- For A1, the source of truth is `PDV_BosmerVariety_RecordBatch.manifest.json` `playerFacingText`.
  Per the W0 approvals handoff, the author tool writes `playerFacingText` VERBATIM to the
  Description (clause included) -- so update the manifest strings to the finals below and re-run
  `tools/pdv-bosmer-variety-author --esp`, OR set the fields directly. Confirm the tool does not
  double-append an `(Effect: ...)` clause; the finals below already contain it.
- Clause format matches the shipped reward blessings: `<flavor>. (Effect: +N <Stat>[ for <time>].)`
  (precedent: `PDV_RewardDescriptionClarity_Review_2026-06-09.md`).
- Magnitudes unchanged EXCEPT the ScalesAtRest duration (120 -> 600, see A1 duration).
- All strings below are ASCII-only (straight apostrophes).

---

## A1 -- Bosmer variety spell descriptions (append effect clause)

Field: `Description` on BOTH the MGEF and the SPEL (identical new string on each).

| Spell | MGEF FormID | SPEL FormID | New Description |
|---|---|---|---|
| TaleCarried | 0714F0 | 0714F1 | You told the tale, and others listened. (Effect: +5 Speech for 10 minutes.) |
| ScalesAtRest | 0714F2 | 0714F3 | The account is even. For a while, every bargain falls a little your way. (Effect: +10 Speech for 10 minutes.) |
| BaanDarGap | 0714F4 | 0714F5 | Baan Dar opens a gap. Run. (Effect: +40% Movement Speed for 15 seconds.) |
| Naming_Hunter | 0714F6 | 0714F7 | You told yourself to become the Hunter. Your aim runs truer. (Effect: +5 Archery.) |
| Naming_Speaker | 0714F8 | 0714F9 | You told yourself to become the Speaker. People lean in to listen. (Effect: +5 Speech.) |
| Naming_Wanderer | 0714FA | 0714FB | You told yourself to become the Wanderer. The road tires you less. (Effect: +8% Stamina Regeneration.) |
| Naming_Keeper | 0714FC | 0714FD | You told yourself to become the Keeper. You carry more of what the people need kept. (Effect: +15 Carry Weight.) |

**Scope confirmed with user: all 7** (the 4 Naming told-self magnitudes are also listed in the
Naming choice menu `PDV_MESG_BosmerNaming` 0714FF -- that already shows them; no change there).

### A1 duration change
`PDV_SPEL_BosmerScalesAtRest` (0714F3): `Effects[0].Data.Duration` **120 -> 600** so the buff
matches its new "for 10 minutes" copy. Magnitude stays 10. Update the manifest `duration` too
(currently `"duration": 120`). User-approved balance change (ScalesAtRest becomes +10 Speech /
10 min, i.e. stronger + longer than TaleCarried's +5 / 10 min -- intended).

---

## A2 -- Bosmer path-suggestion messages (article fix)

Field: `Description`. Insert "the" before each path name. Current text reads "...toward Living
Story / Exchange / Bandit Road / Old Contract".

| MESG | FormID | New Description |
|---|---|---|
| SuggestLivingStory | 06FA1E | Your recent life points toward the Living Story. Accept this path offer? A rite still confirms the change. |
| SuggestExchange | 06FA1F | Your recent life points toward the Exchange. Accept this path offer? A rite still confirms the change. |
| SuggestBanditRoad | 06FA20 | Your recent life points toward the Bandit Road. Accept this path offer? A rite still confirms the change. |
| SuggestOldContract | 06FA21 | Your recent life points toward the Old Contract. Accept this path offer? A rite still confirms the change. |

---

## A3 -- Dunmer neglect display name

Field: `Name` on BOTH records (Description unchanged -- it already reads "...fallen silent...").

| Record | FormID | Name: current -> new |
|---|---|---|
| PDV_MGEF_Neglect_Dunmer_Magicka | 071154 | "The Ancestors Silent" -> "The Ancestors' Silence" |
| PDV_SPEL_Neglect_Dunmer | 071155 | "The Ancestors Silent" -> "The Ancestors' Silence" |

---

## A4 -- DEFERRED (Imperial "3 spec strings")

The audit listed "Imperial 3 spec strings" with no specifics. A scan of all 109 Imperial-named
Devotion.esp records (SPEL/MGEF/MESG/FLST) found no obvious copy defect. **Do NOT edit blind.**
Needs the original audit author's note on which 3 strings and what is wrong before actioning.

---

## Verify after bake

- houseCARL readback: each edited record's `Description` / `Name` / `Effects[0].Data.Duration`
  matches the tables above.
- In-game (MCM debug page -- not cqf): apply a Bosmer variety buff, open Active Effects, confirm
  the description shows the `(Effect: ...)` clause; confirm ScalesAtRest now lasts 10 minutes.
  Fire a Bosmer path suggestion -> "toward the <Path>". Confirm Dunmer neglect reads "The
  Ancestors' Silence".
- `node tools/pdv_verify.mjs` FAIL=0 if any reward-readback rows reference these.
