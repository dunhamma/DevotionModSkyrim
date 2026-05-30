# Phase 18 CK-Safe Nord Dialogue Runbook

Generated dialogue creation remains out of scope for Phase 18. Create these records in Creation Kit, save the framework ESP, refresh SEQ, then run the strict verifier. The vendored `tools/creation-authoring` package can now be used to scaffold future dialogue manifests and verify CK-authored branch/topic/unnamed INFO readback, but strict planning still fails closed without explicit unproven-CK discovery mode and passing CK command evidence.

## Preconditions

- Active profile: `Devotion Dev`.
- Active plugin: `PlayerDevotion_Framework.esp`.
- Script compile is clean for `PDV_MCM`, `PDV__ManagerQuest`, and `PDV_SurveyDevotionEffect`.
- Run `dotnet run --project .\tools\pdv-phase18-author -- --dry-run --create-missing` before live helper application.

## Manual CK Topics

Create one branch/topic/INFO path per row. CK may save INFO records without stable EditorIDs; that is acceptable if speaker, prompt, response, and conditions read back correctly.

| Speaker | Branch EditorID | Topic EditorID | INFO hint | Prompt | Response |
| --- | --- | --- | --- | --- | --- |
| Froki | `PDV_DIAL_Nord_Froki_KyneChampionBranch` | `PDV_TIF_Nord_Froki_KyneChampion` | `PDV_INFO_Nord_Froki_KyneChampion` | `I sleep where Kyne sleeps. I hunt where she hunts.` | `Then you know the old wind. Do not let temple smoke blind you.` |
| Heimskr | `PDV_DIAL_Nord_Heimskr_TalosChampionBranch` | `PDV_TIF_Nord_Heimskr_TalosChampion` | `PDV_INFO_Nord_Heimskr_TalosChampion` | `The old breath is mine to carry. Tell me what is needed.` | `Then let the cowards hear it. Talos needs no quiet servants.` |
| Andurs | `PDV_DIAL_Nord_Andurs_DeathRiteBranch` | `PDV_TIF_Nord_Andurs_DeathRite` | `PDV_INFO_Nord_Andurs_DeathRite` | `I keep the rites. What is owed the dead here?` | `A name, a prayer, and clean hands. That is more than many give.` |
| Aela | `PDV_DIAL_Nord_Aela_HircineTensionBranch` | `PDV_TIF_Nord_Aela_HircineTension` | `PDV_INFO_Nord_Aela_HircineTension` | `The hunt pulls at Sovngarde. What do you see in me?` | `I see someone standing between the hall and the hunt. Choose well.` |

## Condition Contract

- Froki: speaker is Froki, origin is Nord, active deity is Kyne, active tier is at least Champion.
- Heimskr: speaker is Heimskr, origin is Nord, active deity is Talos, active tier is at least Champion.
- Andurs: speaker is Andurs, origin is Nord, patron state is Broad, curse state is not Vampire.
- Aela: speaker is Aela, origin is Nord, and either curse state is Werewolf or the Hircine pilot path is active.

Use globals/properties already surfaced by the manager where possible. If a condition cannot be expressed safely in CK without new helper globals, stop and add the missing readback/global contract before authoring the topic.

## Current CK Readback

Last direct readback found these saved records in `PlayerDevotion_Framework.esp`:

- Froki branch/topic/INFO exists and matches the Kyne Champion contract.
- Heimskr branch/topic/INFO exists and matches the Talos Champion contract.
- Andurs branch/topic/INFO exists and matches the broad death-rite contract.
- Aela branch/topic/INFO exists and matches the werewolf/Hircine tension contract.

`dialogue.implementationStatus` is now `live-dialogue-authored`; strict Phase 18/Nord verification checks branch/topic/INFO payload and condition readback. SEQ has been refreshed for the current save. Runtime proof remains the remaining closeout gate, and future CK dialogue edits must refresh SEQ again before closeout.

Useful CK global conditions:

| Meaning | CK condition |
| --- | --- |
| Nord origin | `GetGlobalValue PDV_GLO_OriginRace == 0` |
| Active Kyne | `GetGlobalValue PDV_GLO_ActiveDeityIndex == 0` |
| Active Talos | `GetGlobalValue PDV_GLO_ActiveDeityIndex == 1` |
| Champion or higher | `GetGlobalValue PDV_GLO_ActiveTier >= 3` |
| Broad patron state | `GetGlobalValue PDV_GLO_PatronState == 1` |
| Active focused patron state | `GetGlobalValue PDV_GLO_PatronState == 2` |
| Not vampire | `GetGlobalValue PDV_GLO_CurseState != 2` |
| Werewolf | `GetGlobalValue PDV_GLO_CurseState == 1` |
| Vampire | `GetGlobalValue PDV_GLO_CurseState == 2` |

Speaker IDs verified from `Skyrim.esm`:

- Froki: `dunHunterFroki` / `Skyrim.esm:0185F6`
- Heimskr: `Heimskr` / `Skyrim.esm:013BAC`
- Andurs: `Andurs` / `Skyrim.esm:013BA8`
- Aela: `AelaTheHuntress` / `Skyrim.esm:01A696`

The Aela "active Hircine path" side is not yet a simple CK global condition. If the werewolf condition is not enough for the first CK pass, stop and add a helper global/readback contract rather than embedding a fragile fragment or script workaround in the Topic Info.

## Runtime Matrix

Run the matrix after the helper packet, manual CK dialogue save, SEQ refresh, and strict verifier pass. Use Developer Options for setup/inspection only; the counted proof surface is the Player page, `Survey Devotion`, spell/favor state, dialogue availability, and Papyrus log/readback where relevant.

| Case | Setup | Expected positive | Expected negative |
| --- | --- | --- | --- |
| Player surface fresh Nord | Fresh Nord start with PlayerDevotion initialized | Player page shows thematic summary, mode, patron, standing, curse, favor, neglect, and Survey Devotion | Player page does not expose exact numeric piety |
| Developer Options persistence | Enable Developer Options, save, reload | Status and Debug remain unlocked | With Developer Options disabled, both pages show locked text only |
| Survey broad Old Ways | Nord origin, broad patron state, Old Ways baseline | Survey describes broad Old Ways standing | Focused commitment wording does not appear |
| Survey broad Nine Divines | Nord origin, broad patron state, Nine Divines baseline | Survey describes broad Nine Divines standing | Old Ways-specific wording does not appear |
| Survey focused Kyne | Nord origin, active Kyne, Champion or higher | Survey names the Kyne bond and Player page reports focused standing | Talos wording does not appear |
| Survey focused Talos | Nord origin, active Talos, Champion or higher | Survey names the Talos bond and Player page reports focused standing | Kyne wording does not appear |
| Hircine/werewolf tension | Nord origin, werewolf curse state or active Hircine path | Survey/Player curse status and Aela eligibility show hunt/Sovngarde tension | Hircine is not treated as a normal Nord god in `PDV_FLST_AllDeities` |
| Nord vampire suppression | Nord origin, vampire curse state | Survey says Sovngarde is closed; commitment offers and contextual favors are suppressed | No Molag Bal lane starts and patron piety is not cleared |
| Nord vampire cure scar | Nord origin, vampire -> none transition | Commitment/favor access returns and Survey/Player preserves scar note | Scar does not erase piety or active patron |
| Save/load persistence | Save/load after Survey grant, UI gate change, active favor, vampire scar, and selected Nord posture | State remains consistent after reload | No duplicate Survey power or stale active favor is created |

Dialogue runtime proof:

| Speaker | Positive setup | Negative checks |
| --- | --- | --- |
| Froki | Nord origin, active Kyne, tier >= Champion | non-Nord; active deity not Kyne; tier below Champion |
| Heimskr | Nord origin, active Talos, tier >= Champion | non-Nord; active deity not Talos; tier below Champion |
| Andurs | Nord origin, broad patron state, not vampire | non-Nord; active focused patron; vampire |
| Aela | Nord origin, werewolf curse state or active Hircine path | non-Nord; no werewolf/Hircine state; vampire without Hircine path |

Console shortcuts for dialogue smoke only:

```text
set PDV_GLO_OriginRace to 0
set PDV_GLO_ActiveDeityIndex to 0
set PDV_GLO_ActiveTier to 3
set PDV_GLO_PatronState to 1
set PDV_GLO_CurseState to 0
```

For favor, commitment, decay, and survey proof, prefer the live MCM/debug helper paths that write the real StorageUtil-backed manager state. The mirror globals are acceptable for isolating CK dialogue condition checks, but they are not sufficient proof that the runtime systems themselves are behaving.

## Reusable Dialogue Tooling

For future dialogue packets, start from the generic scaffold in `fixtures/dialogue-v1/` and adapt it into a PDV-specific manifest instead of restoring the old generated Phase 11 dialogue path. The useful command surfaces are:

```powershell
node .\tools\creation-authoring\src\cli.mjs fixture-check .\fixtures\dialogue-v1 --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json --readback .\fixtures\dialogue-v1\dialogue-v1.readback.json --allow-unproven-ck --json
node .\tools\creation-authoring\src\cli.mjs fixture-check .\fixtures\dialogue-v1 --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json --readback .\fixtures\dialogue-v1\dialogue-v1.readback.json --json
```

The first command proves the discovery scaffold can verify branch/topic/INFO/SEQ shape. The second command should fail in strict mode until real CK-owned creation, active-plugin save, and MO2 readback evidence exist. That strict failure is intentional.

## Verification

After saving CK:

```powershell
node .\tools\pdv_refresh_seq.mjs --write --json
node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord --strict-phase13 --strict-phase14 --strict-phase15 --strict-phase16
node .\tools\pdv_content_verify.mjs
```

Runtime proof must cover positive and negative checks for each speaker: wrong race, wrong deity/state, wrong tier, and vampire-blocked cases where applicable.
