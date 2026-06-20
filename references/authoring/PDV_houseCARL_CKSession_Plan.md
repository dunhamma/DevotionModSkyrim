# PDV houseCARL CK-Session Plan — finishing the Requiem-build tail

Status: PLAN (no-deploy prep). Created 2026-06-20.
Owner of remaining items: tasks #10 (Namira contract), #11 (HoonDing Champion save
+ named-boss FormList), Nord Shor conversion. Tracker:
`PDV_RequiemSmokeTest_Tracker.md`. Reference: `PDV_Phase2_CapstoneSignatures.md`,
`PDV_RequiemRegenConversion_Plan.md`.

## Why this exists

The Requiem-build tail needs **CK-semantic record work** — VMAD script attach,
FormList creation, targeted MGEF edits — that the `creation-authoring` CK bridge
can only do by **launching CK interactively** ("UI automation is not part of the
shippable green path", `tools/creation-authoring/docs/CK_BRIDGE.md`). That can't run
headless here. **houseCARL (Mutagen) does the same operations headless** via review
patch plugins, so a dedicated houseCARL session can finish the tail.

## houseCARL capability + deployment model (READ FIRST)

- houseCARL **writes to a NEW review patch plugin** (originals untouched); it
  overrides the load-order winner. So save-attaches and new FormLists land in a
  patch (e.g. `PDV_CapstonePatch.esp`) that must load **after Devotion.esp**. (This
  is the one architectural difference from the in-place CK flow — accepted here as
  the price of headless.)
- **VMAD script attach** = `housecarl_set_field` on the target MGEF's
  `VirtualMachineAdapter.Scripts` (verb=Add a ScriptEntry: `Name` =
  `PDV_T3DailyLowHealthSaveEffect`, properties `StorageKey`, optional `HealAmount`).
  Mirrors the CK packet's `vmad.attach_script` op (`script` + `properties`).
- **New FormList / MGEF / SPEL** = `housecarl_create_record` (record_type `FormList`
  / `MagicEffect` / `Spell`) with `operations` adding entries/effects.
- **Targeted field edits** = `housecarl_set_field` (e.g. flip a Namira boon MGEF's
  actorValue/magnitude, edit a description) — overrides only that record, leaving the
  other 15 Princes untouched.
- **FormID-drift discipline (load-bearing):** the reward author RE-CREATES a record's
  MGEFs (new FormIDs) each run, which orphans a patch override keyed on the old FormID.
  So per record: (1) finalize the reward-author run FIRST, (2) houseCARL-attach the
  save / read the settled FormID LAST, (3) NEVER re-author that reward after attaching
  without re-attaching. The save is always the LAST step. (Same discipline as the CK
  flow; this is why BaanDar/Sovngarde rode EXTRA effects.)
- **Pre-flight:** point houseCARL at the Anvil MO2 instance (Devotion Dev profile);
  re-point after any cross-instance reads (memory: compat-reference-instances /
  housecarl-holds-esp-lock). Skyrim + CK CLOSED (ESP lock). Snapshot the live manager
  before any Papyrus edit; commit after.

## Work items (sequenced; do saves in one patch, FormLists in another)

### 1. Nord Shor conversion + "Sovngarde Looks Back" re-attach (the deferred race)
1a. Spec `PDV_NordRewardRecords.spec.json`: Shor T1/T2/T3 `HealRateMult` → `Health`
    (Fortify Health, ~10/20/30, PROVISIONAL); rewrite `playerFacingText`. **Restructure
    Shor T3 so the save rides an EXTRA effect** (add a token/0-mag effect for the save
    to host) + `preserveAdditionalEffects: true` — so future authors keep it (BaanDar
    pattern), not the fragile "save on the spec'd effect" that caused the block.
1b. Author Nord (`pdv-phase20-race-author --author-rewards`) → settles new Shor MGEFs.
1c. houseCARL: read `PDV_Bless_Nord_Shor_T3` → its save-host extra-effect MGEF;
    `set_field` Add `PDV_T3DailyLowHealthSaveEffect` to that MGEF's VMAD, property
    `StorageKey = "PDV.Capstone.LowHealthSave.Nord"`.
1d. Readback (`pdv_phase2_reward_readback_audit`) — confirm the capstone script reads
    back (audit scans all Effects indices). In-game: Champion, drop <20% HP → save
    fires once/day; T1/T2/T3 max-HP felt under Requiem.

### 2. HoonDing Champion cheat-death save (replaces retired signal 2502)
2a. Spec `PDV_RedguardRewardRecords.spec.json`: add a save-host extra effect to
    `PDV_Bless_Redguard_HoonDing_T3` + `preserveAdditionalEffects: true`. Author Redguard.
2b. houseCARL: attach `PDV_T3DailyLowHealthSaveEffect` to the HoonDing T3 save-host
    MGEF, `StorageKey = "PDV.Capstone.LowHealthSave.HoonDing"`.
2c. Confirm the HoonDing T3 spell is granted at Champion (reward grant path). Readback +
    in-game ("the way is made" cheat-death once/day). HoonDing-flavored copy.

### 3. HoonDing named-boss FormList (extend make-way beyond V1 dragons)
3a. houseCARL `create_record` FLST `PDV_FLST_HoonDing_BreakthroughBosses`; populate with
    curated named bosses — the 8 Dragon Priests, named/unique world-boss actors, final
    bosses. (Curation list is the real work; start with Dragon Priests + obvious uniques.)
3b. Wire: `set_field` the manager quest VMAD property
    `PDV_FLST_HoonDing_BreakthroughBosses` → the patch FormList FormID (cross-plugin);
    extend `HandleHoonDingBreakthroughKill` (Papyrus) to also qualify on FormList
    membership of the victim base. Keep the dragon path + daily decay.
3c. Verify the manager property resolves the patch FormID at runtime (it's cross-plugin).

### 4. Ash'abah named-necromancer detection (extend mid-game entry beyond unique undead)
4a. Prefer FACTION detection over a FormList: a named necromancer is a LIVING humanoid
    (classify as humanoid kill, not undead) in a Necromancer/Conjurer faction. houseCARL
    FormList of the relevant factions OR a curated named-necromancer-leader FormList.
4b. Extend `HandleRedguardAshAbahMajorBurden` (Papyrus) to also accept a unique living
    humanoid in that faction → reason `"redguard_deathduty_major"`. Keep the unique-undead
    path. (Comment in the live code already names this as the deferred follow-up.)

### 5. Namira Daedric contract cleanup (finish the lifesteal's stale text)
- **Use houseCARL TARGETED edits, NOT a full Daedric re-author** (avoids the 16-Prince
  blast radius / curse-script drop risk): `set_field` the 3 Namira boon MGEFs
  (`PDV_MGEF_Bless_Daedric_Namira_*`) to remove/zero the `HealRateMult`, and edit the 3
  boon `playerFacingText`/descriptions to the lifesteal framing. The scripted feed-heal
  (already live) is the felt effect. Re-prove Namira display in the Daedric smoke packet;
  confirm Molag/Hircine curse no-double-fire is untouched (`pdv_daedric_beta_gate`).
- IF a full Daedric re-author is ever chosen instead: first verify
  `pdv-daedric-author`'s blast radius (single-Prince vs all-16) and that no boon carries
  an attached script.

## Verification (every item)
- Readback `pdv_phase2_reward_readback_audit` (capstone scripts present; effects correct).
- Compile any Papyrus (`pdv_compile --script PDV__ManagerQuest`), verify FAIL=0.
- In-game: HP-bar cheat-death proof; named-boss make-way; named-necromancer sect entry;
  Namira display + curse no-double-fire.
- Snapshot the live manager + commit; document the new patch plugin(s) in the install model.

## Risks
- **FormID drift** orphans a patch save-attach if rewards are re-authored → attach LAST,
  re-attach after any re-author.
- **Extra plugin** (capstone/FormList patches) → must load after Devotion.esp; fold into
  the install (FP-053 single-folder decision may need a patch sub-plugin).
- **Cross-plugin FormList property** → verify the manager property resolves the patch
  FormID at runtime (a Devotion.esp quest pointing at a patch FLST).
- **Daedric blast radius** → the houseCARL targeted-edit path sidesteps it; do not full
  re-author for cosmetic boon text.
