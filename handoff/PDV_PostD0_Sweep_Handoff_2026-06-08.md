# PDV Post-D0 Polish Sweep — Session Handoff (2026-06-08)

Self-contained handoff for a fresh session to execute the approved 5-item sweep.
Full plan: `C:\Users\Admin\.claude\plans\check-where-codex-s-daedric-serialized-quokka.md`.

---

## 0. Current live state (all committed + pushed on `main`)
- **Diegetic UX is LIVE at D0** (`D1Enabled=false` → zero behavior change). 17 records + 2 SGE quests (`PDV_DiegeticDeps`, `PDV_DiegeticDirector`) + VMAD + SEQ all authored into `PlayerDevotion_Framework.esp`. D0 smoke **passed** (log clean). D1 not yet enabled.
- **Daedric DeityName fix applied** (the daedric author now binds identity/boon/price/state props onto the *concrete* path script, not just the base entry). Confirmed working **on a new game** (Selected Prince shows "MEPHALA [1]" etc.). Sound records fixed to **SOUN** (SoundMarker wrapping vanilla SNDR).
- Last commits: `5ed23df` (SOUN + DeityName fix), `860a797` (capitalization capture). Working tree clean except a 0-byte `references/authoring/image.png` stray (ignore/delete).
- Tools built this session: `tools/pdv-diegetic-author/` (has a `--dump-daedric` read-only mode that dumps `PDV_DaedricPath_Boethiah` VMAD script entries + DeityName), `tools/pdv-daedric-author/` (DeityName-on-concrete fix in `WirePrinceQuest`).

## 1. CRITICAL operational knowledge (read before any ESP write)
- **ESP writes fail with "used by another process" unless:**
  1. **Skyrim is closed** (the running game holds the ESP).
  2. **houseCARL is parked OFF the Anvil instance.** houseCARL's MCP server keeps a read handle on the Anvil load order. To release: `housecarl_set_mo2_instance` → `D:\Wabbajack\modlists\DoD`, then call `housecarl_load_order_status` (forces it to BUILD the DoD resolver, disposing the Anvil one). Verify free with PowerShell `[System.IO.File]::Open(...,'ReadWrite','None')`. After writing, **restore**: `housecarl_set_mo2_instance` → `D:\Wabbajack\modlists\Anvil`. (You CANNOT kill the houseCARL process — the classifier blocks it.)
- **Every VMAD/record change needs a NEW GAME to validate** — existing saves bake script-instance state and won't pick up new VMAD properties. This is confirmed (the DeityName fix only showed on a new game).
- **Bash commit messages:** do NOT use PowerShell `@'...'@` here-strings in the Bash tool (adds a stray `@`). Write the message to a temp file and `git commit -F`.
- Mutagen authors load the ESP standalone (`SkyrimMod.CreateFromBinary`) → release the handle after; they self-backup to `...\Backups\`. Reusable scaffolding lives in `tools/pdv-daedric-author/Program.cs` (FormKeyAllocator, WriteModIfNeeded, VMAD helpers `ObjProp`/`BoolProp`/`WireQuestScript`, SPEL/MGEF creation) and `tools/pdv-diegetic-author/Program.cs` (record duplication via `DeepCopyIn`, SoundMarker creation, quest+VMAD authoring).

## 2. Step 0 verification — FINDINGS (done this session)
**Spell types (resolves the "L/R-hand equip" complaint):** queried via houseCARL.
- **ALL 194 `PDV_Bless_*` reward/boon spells = `Type=Ability, CastType=ConstantEffect`** (passive — correct). All `PDV_SPEL_Favor_*`, `PDV_SPEL_Neglect_*`, `PDV_SPEL_HircinePrice_*` = `Ability` too. Daedric boon/price (`PDV_Bless_Daedric_*`) = `Ability`.
- **`PDV_SPEL_SurveyDevotion` = `LesserPower`** (voice power — correct).
- **CONCLUSION:** *nothing* is authored as a hand-equippable `Type=Spell`. Passive abilities correctly appear in **Active Effects** (the shield-icon list the user saw — "Azura Boon - Seeker", "Resist Fire"). **So the user's "uses L/R hands / make it like Ancestor's Wrath" is likely a misread of the Active-Effects list, OR about one specific item.** → **NEW SESSION: ask the user to point at the EXACT power that equips into a hand** (name + which menu) before changing any record. Do not bulk-convert — the records are already correct.

**DeityName lowercase root: NOT yet confirmed.** The roster (`PDV_MCM.psc:842` prints `deity.DeityName`) and ProcessDawn traces show lowercase (`kyne`, `azurah`, `xarxes`…) for all deities EXCEPT the manager-runtime-set ones (Talos/Y'ffre/Z'en/Baan Dar, set proper in `PDV__ManagerQuest.psc:570-694`). Lowercase values exactly match the `GetPrismaSymbolForDeity` keys. **TODO:** dump `PDV_Deity_Kyne`'s VMAD `DeityName` value (extend `pdv-diegetic-author --dump-daedric` to accept a quest editorid, or read `tools/pdv-phase20-race-author/Program.cs` to see what case it bakes DeityName). Determine: baked-lowercase (fix = re-author proper-case on the **concrete** deity script entry, mirroring the daedric `concreteProps.AddRange(baseProps)` fix) vs runtime-set-lowercase (fix = manager). NOTE: the deity quests likely have the SAME base-vs-concrete two-script pattern as the daedric paths — if so, the proper-case must go on the concrete entry.

## 3. The 5 work items (with verified file:line)
Tasks #14–18 in the tracker. User decisions: **boon/price = passive abilities** (already true); **ancestor prayer = bowl-triggered** (animation deferred to V2); **committing to a Prince makes it the active patron, exclusive** (replaces Aedra patron — user to confirm if coexist preferred).

**A. Daedric patron wiring (#15)** — `PDV__ManagerQuest.psc`:
- `SetActiveDeity(PDV_DeityBase)` is at `:1562` (calls `OnPatronStart` → for a path applies the contract). `_activeDeity` is `PDV_DeityBase`; `PDV_DaedricPathBase` extends it, so a path CAN be the patron.
- Gap: nothing sets a path as patron. The commitment flow (`UsesFormalCommitmentOffersForDeity` `:5506` true only for Kyne; scans only `PDV_FLST_AllDeities`) never offers paths.
- Fix: when a path commits/reaches Seeker (in `HandleDaedricPrinceSignal` on tier-up + the MCM force-tier `PDV_MCM.psc` `DebugForceSelectedDaedricTier` ~:1174), call `SetActiveDeity(path)`.
- `GetSurveyDevotionText` `:7779` has no Daedric branch (falls to a generic tier label). Add one reading path name/state/piety/tier/stigma/commitment/boon+price summary, parity with the per-race survey handlers.

**B. Spell descriptions + equip slot (#16)** — see Step 0: spells already passive. Remaining = **description clarity**: boon/price/reward descriptions are thematic but don't state the MECHANICAL effect (e.g. "+8 Illusion"). The user wants deity-parity clarity. The descriptions are written by the author tools from `playerFacingText` in the contracts/specs (`references/authoring/PDV_DaedricPrinceRecordContracts.json`, `PDV_{Race}RewardRecords.spec.json`) → MGEF/SPEL `Description`. Decide whether to append the literal magnitude to each, then re-author. **Confirm the "hand-equip" item with the user first.**

**C. Dunmer ancestor prayer via bowl (#17)** — mechanic EXISTS but trigger-orphaned:
- `HandleDunmerPortableShrinePrayer` (`PDV__ManagerQuest.psc:1831`) → `PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled` (+5 piety), routed via `PDV_EventBus.RouteDunmerPortableShrinePrayer` (route 30). Also `HandleDunmerPlayerHomeBonus` `:1845`.
- Reuse the **Green Pact food `OnObjectEquipped`** pattern (`PDV_PlayerEvents.psc:208`) to detect a bowl MISC → route the prayer.
- Startup grant: no `AddItem` pattern exists; model is `EnsureSurveyDevotionPower` (`PDV__ManagerQuest.psc:7744`, called from OnInit + the 10-tick OnUpdate). Add `EnsureStartupItems()` that `AddItem`s the bowl once for Dunmer.
- Bowl asset: relabel a vanilla wooden bowl MISC as "Ancestral Shrine" (author/duplicate via the diegetic-author pattern, or reuse vanilla directly + a name override). Add description: *"As a Dunmer, honoring your ancestors is important. Use your ancestral shrine to pay homage to your ancestors."*

**D. All-race startup copy rewrite + naming (#18)** — `GetStartupCanonicalSummary` (`PDV__ManagerQuest.psc:6822-6841`) holds all 10 race blurbs as inline string literals (Dunmer at `:6827`, flagged poorly worded) + `STARTUP_ADVISORY_TEXT` (`:353`). **One function, no MESG records — pure string rewrite.** Draft new copy for all 10 + advisory for user review. Also: Azura (Daedric) vs `azurah` (Khajiit focus) — `azurah` is `GetKhajiitFocusSymbol` lowercase (`:5956`) vs `GetKhajiitFocusLabel` proper (`:2597`); ensure Azura the Prince is selectable once paths are patron-wired. Hircine VMAD warnings: the hand-written `PDV_DaedricPath_Hircine.psc` doesn't declare the message props the contract bakes → benign init warnings; align the script's declared props or stop baking absent message props on Hircine.

**E. Capitalization sweep (#14)** — see Step 0 DeityName-root TODO. Focus survey text at `:8130` already uses proper `GetKhajiitFocusLabel`; find where the lowercase "Current focus: azurah" actually came from (a different focus readout). Roster lowercase is the `deity.DeityName` data → fix at the data source (proper-case re-author) so roster + dawn traces + everywhere read proper.

## 4. Execution sequence (batches ESP writes once)
1. **Step 0 finish:** confirm DeityName root (dump Kyne) + get the user to identify the exact hand-equip power.
2. **Papyrus + copy** (compile only, no ESP records): patron wiring + Daedric survey branch; all-race startup copy; Dunmer bowl `OnObjectEquipped` routing + `EnsureStartupItems`; focus-label casing. Compile via `node tools/pdv_compile.mjs --script ...`.
3. **One ESP author session** (houseCARL→DoD, Skyrim closed): DeityName proper-case re-author; description clarity re-author; bowl MISC; any confirmed spell-Type change; Hircine prop alignment. Then `pdv_refresh_seq` only if new SGE quests (none expected).
4. **Verify:** `pdv_verify` 0 FAIL, `pdv-daedric-author --check` PASS, `pdv_content_verify` clean, `pdv_diegetic_ux_check` clean. Restore houseCARL→Anvil. Commit (ESP/SEQ live in the MO2 folder, outside the repo; commit the author/script/doc changes).
5. **Hand the user a NEW-GAME test checklist** per item.

## 5. Out of scope (tracked)
- Diegetic **D1 enable + proof** (set `PDV_DiegeticDirector.D1Enabled=true` — add an `--enable-d1` switch to `pdv-diegetic-author`, then in-game counted-transition proof).
- Daedric **long-term depth** (contextual favors + Champion capstone) — `PDV_GameplayAudit_2026-06-07.md` §5.
- Daedric **runtime beta proof** (beta gate `PENDING=16`).
- Ancestor prayer **animation** (V2).
