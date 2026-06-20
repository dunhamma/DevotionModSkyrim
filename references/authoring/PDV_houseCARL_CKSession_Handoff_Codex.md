# Handoff → Codex: houseCARL CK session (Requiem-build tail)

**Created:** 2026-06-20. **For:** Codex (incoming coder/engineer). **Companion plan:**
`PDV_houseCARL_CKSession_Plan.md` (the "why"; this doc is the "do"). **Canonical
context:** `AGENTS.md` (Decisions Log top entry, 2026-06-20, summarizes the lead-in).

You're picking up the **CK-blocked tail** of the Requiem-regen conversion. Claude built
+ shipped B1/B2 + the Ash'abah entry fix (all machine-proven, on `main`+`beta` at
`dafea3b`, pushed). What's left needs **CK-semantic record work** — VMAD script attach,
new FormLists, targeted MGEF edits. The `creation-authoring` CK bridge can't do it
headless (it must launch CK; `CK_BRIDGE.md`). **houseCARL (Mutagen) can, headless.**
This session is yours to execute.

---

## 0. Read-me-first: the three things that will bite you

1. **houseCARL writes a NEW patch plugin** (overrides the winner; never edits
   Devotion.esp in place). So every save-attach / FormList lands in a review patch
   (e.g. `PDV_CapstonePatch.esp`) that must load **after Devotion.esp**. Plan the
   install for one extra plugin. (memory: `housecarl-headless-ck-via-mutagen`,
   `housecarl-holds-esp-lock`.)
2. **FormID drift.** `pdv-phase20-race-author` RE-CREATES a reward's MGEFs (new
   FormIDs) every run. A patch override keyed on an MGEF FormID **orphans** if you
   re-author after attaching. → **Author the reward spec FIRST, attach the save
   LAST, never re-author that record without re-attaching.** This is exactly why the
   existing saves (BaanDar, Sovngarde) ride a `preserveAdditionalEffects` EXTRA
   effect.
3. **The live manager is UNTRACKED** (`D:\Wabbajack\modlists\Anvil\mods\Devotion\
   Scripts\Source\PDV__ManagerQuest.psc`). A mod restore already wiped it once.
   **Snapshot to `generated/live-devotion-snapshot/<dated>/Scripts/Source/` before any
   Papyrus edit AND commit after** — the snapshot is the only git-tracked copy.
   (memory: `live-manager-not-in-git-disappearance-risk`.)

## 1. Preflight (every session)
- **Close Skyrim AND the CK** (ESP write lock). If a write fails "used by another
  process" with neither open, it's the houseCARL Mutagen overlay holding the lock —
  re-point houseCARL to the DoD instance, do the read, re-point back to Anvil
  (memory: `housecarl-holds-esp-lock`).
- **Point houseCARL at the Anvil MO2 instance** (`housecarl_set_mo2_instance`
  `D:\Wabbajack\modlists\Anvil`), profile `Devotion Dev`. Always re-point to Anvil
  after any cross-instance read (memory: `compat-reference-instances`).
- Branch: work on `beta/requiem-smoke-session` (== `main` == `dafea3b`). Snapshot the
  live manager before Papyrus edits; commit per item; mirror to `main` the way this
  session did (the user wants both pushed).
- Toolchain (verified this session):
  - Author a race: `dotnet run --project tools/pdv-phase20-race-author/PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --rewards-spec <spec> --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"` (run `--dry-run` first; auto-`.bak`).
  - Readback: `node ./tools/pdv_phase2_reward_readback_audit.mjs` (baseline: FAIL=1 = the unrelated GreenPact KID; **grep the output for the capstone script name to confirm the save survived**).
  - Compile: `node ./tools/pdv_compile.mjs --script PDV__ManagerQuest` (expect 0/0).
  - Verify: `node ./tools/pdv_verify.mjs` (FAIL=0). Daedric gate: `node ./tools/pdv_daedric_beta_gate.mjs`.

## 2. The capstone-save pattern (ground truth — replicate exactly)

The proven template is **Khajiit BaanDar T3** (`PDV_Bless_Khajiit_BaanDar_T3`):
- Spec declares **stat effects ONLY** (`PDV_KhajiitRewardRecords.spec.json` ~L293:
  DamageResist/Health/UnarmedDamage) **plus `"preserveAdditionalEffects": true`**.
- The cheat-death save is an **EXTRA effect** beyond the stat ones (on `Effects[3]`):
  a dedicated **AvoidDeath**-archetype MGEF carrying the script
  `PDV_T3DailyLowHealthSaveEffect`, with an **AvoidDeathHeal** spell the script casts.
  It is NOT in the spec — it's attached externally and KEPT across re-authors by
  `preserveAdditionalEffects`.
- The save script (`...\Scripts\Source\PDV_T3DailyLowHealthSaveEffect.psc`) properties:
  `StorageKey` (per-race daily-cooldown key), `TriggerHealthPercent` (0.20),
  `HealAmount` (0.0 ⇒ restore to full), optional `HealSpell`. **Each save needs its
  OWN `StorageKey`** so cooldowns don't collide.

**Execution recipe (per save):**
1. Edit the reward spec: stat effects only + `"preserveAdditionalEffects": true`.
2. Author the race (settles MGEF FormIDs).
3. houseCARL: **read the live BaanDar T3 save MGEF + its VMAD as the template**
   (`housecarl_read_record <BaanDar T3 spell FormID> depth=2` → its Effects → the
   AvoidDeath MGEF → `VirtualMachineAdapter.Scripts`). Replicate onto the target:
   - `housecarl_create_record` an AvoidDeath MGEF (+ AvoidDeathHeal SPEL if not
     reusing BaanDar's) OR reuse the shared AvoidDeathHeal spell;
   - `housecarl_set_field` on the new MGEF's `VirtualMachineAdapter.Scripts`
     (verb=Add a ScriptEntry, `Name=PDV_T3DailyLowHealthSaveEffect`, property
     `StorageKey=<race key>`) — this is the `vmad.attach_script` op headless;
   - `housecarl_set_field` Add the AvoidDeath MGEF as an extra effect on the target
     reward SPEL (`Effects`, verb=Add).
4. Readback — confirm `PDV_T3DailyLowHealthSaveEffect` reads back on the target spell
   (the audit scans ALL effect indices, not just `Effects[0]` — fixed 2026-06-13;
   memory: `reward-readback-effects0-blindspot`).

> Resolve EditorID→FormID with `housecarl_cross_plugin_query type=Spell
> editorid_contains=Bless_Khajiit_BaanDar_T3` (etc.).

---

## 3. Work items (sequenced — saves in one patch, FormLists in another)

### Item 1 — Nord Shor conversion + "Sovngarde Looks Back" re-attach *(the deferred race)*
- **Spec** `PDV_NordRewardRecords.spec.json`, Shor T1/T2/T3
  (`PDV_Bless_Nord_Shor_T1/T2/T3`): convert `HealRateMult` → `Health` (Fortify Health,
  PROVISIONAL ~10/20/30), rewrite `playerFacingText`. On **Shor T3** (currently
  HealRateMult 27 + OneHanded 18 + TwoHanded 10 + the save) keep the stat lines
  (Health 30 + OneHanded 18 + TwoHanded 10) and add `"preserveAdditionalEffects":
  true`. The save currently rides the *spec'd* HealRateMult MGEF (the original
  blocker) — converting it MUST move the save onto a dedicated AvoidDeath EXTRA effect
  (the BaanDar pattern, §2), or it's dropped again.
- **Author Nord** → **houseCARL re-attach** `PDV_T3DailyLowHealthSaveEffect` to the new
  Shor T3 AvoidDeath extra effect, `StorageKey="PDV.Capstone.LowHealthSave.Nord"`
  (reuse the existing Nord key if the live record already has one — read it first).
- **Readback** (capstone script present) + in-game: Champion, drop <20% HP → save
  fires once/day; Shor T1/T2/T3 max-HP felt under Requiem.

### Item 2 — HoonDing Champion cheat-death save *(replaces retired signal 2502)*
- **Spec** `PDV_RedguardRewardRecords.spec.json`, `PDV_Bless_Redguard_HoonDing_T3`
  (currently OneHanded 25 + SpeedMult 6, no save): keep the stats, add
  `"preserveAdditionalEffects": true`. Author Redguard.
- **houseCARL** attach the save to a HoonDing T3 AvoidDeath extra effect,
  `StorageKey="PDV.Capstone.LowHealthSave.HoonDing"`. HoonDing-flavored "the way is
  made" copy on the AvoidDeathHeal/effect description.
- Confirm the HoonDing T3 spell is granted at Champion (the reward-grant path is
  already wired by the existing reward family sync). Readback + in-game (once/day
  cheat-death at <20% HP).

### Item 3 — HoonDing named-boss FormList *(extend make-way beyond V1 dragons)*
- `housecarl_create_record record_type=FormList` `PDV_FLST_HoonDing_BreakthroughBosses`;
  populate (curation is the real work — start with the **8 Dragon Priests** + named
  world-boss / unique hostile actors + final bosses).
- Wire: `housecarl_set_field` the manager quest's VMAD property
  `PDV_FLST_HoonDing_BreakthroughBosses` → the patch FormList FormID (cross-plugin),
  then extend **`HandleHoonDingBreakthroughKill`** (live manager ~L5093 region;
  currently dragon-only via `eventType != 302`) to ALSO qualify if the victim's
  `GetLeveledActorBase()` is in the FormList. Keep the dragon path + the daily decay.
- Verify the manager property resolves the patch FormID at runtime (Devotion.esp quest
  → patch FLST is cross-plugin; confirm load order).

### Item 4 — Ash'abah named-necromancer detection *(extend mid-game entry beyond unique undead)*
- The live `HandleRedguardAshAbahMajorBurden` (manager ~L4993; UNIQUE undead via
  `ActorBase.IsUnique()`) already names this as the deferred follow-up. A named
  necromancer is a **LIVING humanoid** (classify as humanoid kill, NOT undead — it
  won't hit the `eventType==300` undead branch). Prefer **faction detection**
  (Necromancer/Conjurer faction) over a hand-curated FormList; a houseCARL FormList of
  the target factions works too.
- Extend `HandleRedguardAshAbahMajorBurden` to also accept a unique living humanoid in
  that faction → reason `"redguard_deathduty_major"`. Keep the unique-undead path.

### Item 5 — Namira boon contract cleanup *(finish the lifesteal's stale text)*
- **Use houseCARL TARGETED edits — do NOT full-re-author the Daedric ESP** (avoids the
  16-Prince blast radius / Molag-Hircine curse-script-drop risk). The scripted
  feed-heal (`TryNamiraFeedHeal`, live) is the felt effect; only the boon DESCRIPTION
  is stale.
- `housecarl_set_field` the 3 boon MGEFs
  (`PDV_MGEF_Bless_Daedric_Namira_Seeker/Devoted/Champion`, currently `HealRateMult`
  10/15/20): remove/zero the HealRateMult. Edit the 3 boon SPELs
  (`PDV_Bless_Daedric_Namira_*`) / descriptions
  (`PDV_DaedricPrinceRecordContracts.json` `playerFacingText`) to the lifesteal
  framing ("Namira sustains you: feeding on the dead restores your flesh").
- Re-prove Namira display in the Daedric smoke packet; confirm Molag/Hircine curse
  no-double-fire intact (`pdv_daedric_beta_gate`).

---

## 4. Verification gates (every item)
- **Machine:** readback (`pdv_phase2_reward_readback_audit` — capstone scripts present;
  effects correct), compile 0/0, `pdv_verify` FAIL=0, `pdv_daedric_beta_gate` (item 5).
- **In-game (the load-bearing proof):** per the run-sheet
  `PDV_RunSheet_Redguard_BetaFeel.md` and `PDV_RequiemSmokeTest_Tracker.md` Sweep
  B1/B2 + the new cheat-death rows. MCM-driven seeding (NOT `cqf`); HP bar must move
  under a Requiem list. Magnitudes are PROVISIONAL — the sweep is the tuning pass.
- **Tracker:** update `PDV_RequiemSmokeTest_Tracker.md` (CK-session rows → DONE) and add
  an `AGENTS.md` Decisions Log entry per item, preserving the proof boundary
  (machine vs in-game).

## 5. Snapshot + commit discipline (per item)
1. Snapshot live `PDV__ManagerQuest.psc` (+ any touched `.psc`) to
   `generated/live-devotion-snapshot/<dated>/Scripts/Source/` BEFORE editing.
2. Make the change; author/houseCARL/compile.
3. Re-snapshot + commit (snapshot dir + spec + the houseCARL patch under
   `D:\...\mods\<patch mod folder>` — note: the patch plugin lives in the MO2 mods
   tree, untracked like Devotion.esp; capture its review state in the snapshot/commit
   notes and the install model).

## 6. File map (what you'll touch)
| Path | Role |
|---|---|
| `references/authoring/PDV_houseCARL_CKSession_Plan.md` | the plan / rationale (companion) |
| `references/authoring/PDV_NordRewardRecords.spec.json` | item 1 — Shor T1/T2/T3 |
| `references/authoring/PDV_RedguardRewardRecords.spec.json` | item 2 — HoonDing T3 (+ item 3 wiring lives in the manager) |
| `references/authoring/PDV_KhajiitRewardRecords.spec.json` | item-2/1 template — BaanDar T3 (`preserveAdditionalEffects`) |
| `references/authoring/PDV_DaedricPrinceRecordContracts.json` | item 5 — Namira boons |
| `D:\...\Devotion\Scripts\Source\PDV__ManagerQuest.psc` | items 3/4 — `HandleHoonDingBreakthroughKill`, `HandleRedguardAshAbahMajorBurden` (UNTRACKED) |
| `D:\...\Devotion\Scripts\Source\PDV_T3DailyLowHealthSaveEffect.psc` | the save script (read its properties) |
| `references/authoring/PDV_RequiemSmokeTest_Tracker.md` / `PDV_RunSheet_Redguard_BetaFeel.md` | tracker + in-game proof |

## 7. Open decisions to confirm with the user before shipping
- **Patch deployment:** one capstone/FormList patch plugin loading after Devotion.esp
  is acceptable vs. wanting these folded into Devotion.esp (which would need the
  interactive-CK path, deferred). Recommend the patch.
- **Provisional magnitudes:** Nord 10/20/30, the cheat-death heal amounts — tune in the
  in-game sweep, then hand-edit the spec/records (do NOT re-run the cumulative
  rebalance tools; not idempotent — memory: `rebalance-tool-idempotency`).
- **Namira boon:** confirm "no passive stat at all, lifesteal is the whole boon" vs.
  leaving a small non-health passive.
