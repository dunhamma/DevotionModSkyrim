# PDV Diegetic D0->D1 Buildout Plan (2026-06-15)

Source: read-only investigation workflow (`diegetic-d1-understand`, 8 agents, run
`wf_940b12ea-bda`). Scope: ENABLE + TUNE the diegetic visual surfacing layer (screen
IMAD + shader SPEL, sound SNDR, music MUSC, journal/DBF, medallion/DF, notify). Bodymark
(NiOverride) + OAR anim are EXCLUDED in V1.

## Headline

**D1 is already built on live Devotion.esp.** All 17 channel records exist + all 23
`PDV_DiegeticDirector` properties are wired + the D0 scaffold is complete and compiled.
The only live change to enable D1 is the Director VMAD flag **`D1Enabled: false -> true`**
(quest `PDV_DiegeticDirector` = `07149A:Devotion.esp`). No record creation, no property
wiring, no `.psc` change is required to enable.

## 1. D0 status -- fully in place

| element | state | evidence |
|---|---|---|
| `PDV_DiegeticDirector` quest | EXISTS, SGE | `07149A:Devotion.esp` |
| `PDV_DiegeticDeps` quest | EXISTS, SGE | `071499:Devotion.esp` |
| `D1Enabled` | **False** (correct at D0) | Director ScriptBool |
| `TraceDispatch` / `ForceAllDepsAbsent` | True / False | normal trace+detect path |
| 8 named Director D0 props | FILLED | DepsService + 4 globals + AllDeities FormList |
| `PDV__ManagerQuest.PDV_DiegeticDirectorService` | FILLED -> `07149A` | manager VMAD |
| compiled PEX | present | `...\Devotion\Scripts\PDV_DiegeticDirector.pex`, `...\PDV_DiegeticDeps.pex` |

## 2. D1 records -- all 17 already exist (verify-only, do NOT create)

IMAD: `PDV_IMAD_Reverent 071484`, `Revelation 071485`, `Dread 071486`, `Release 071487`,
`Absence 071488`. SPEL shader abilities: `Reverent 071492`, `Revelation 071494`,
`Dread 071496`, `Release 071498` (paired MGEFs `071491/3/5/7`). SNDR: `Chime 07149B`,
`Swell 07149C`, `Hollow 07149D`, `RisingChime 07149E`, `Distant 07149F`. MUSC:
`PDV_MUS_CurseBed 07148E`. MISC: `PDV_DevotionMedallion 07148F`. BOOK: `PDV_BookOfDays 071490`.
All duped+recolored from vanilla per the manifest. **No `turning` or `apotheosis` records
exist** (by design) -> those tones fall back to default chime + no screen.

## 3. Property wiring -- all 23 props filled; net D1 action = flip `D1Enabled`

Everything is wired on live. The only property *change* at D1 is `D1Enabled false->true`.
Read-back verification of all 23 props on `07149A` is recommended before the flip.

## 4. The three caveats that change the decision

1. **VMAD save-bake (HIGH) -> D1 proof MUST run on a NEW save.** Per
   [[deity-stance-wiring]]: VMAD prop values bake into the save at first init and are never
   re-read. Flipping `D1Enabled` in the ESP will NOT take effect on a save created while it
   was false. Prove on a fresh game (or add a runtime version-gated migration to re-assert).
2. **Medallion + Journal will NOT visibly surface.** DF (Description Framework) and DBF
   (Dynamic Book Framework) are **not installed** in the Anvil load order, so those two
   channels fall back gracefully (cache-only). The visible V1 channels are really just
   **screen (IMAD+shader), sound, music, notify**. (Also GAP-3: the director script reads
   only `ActiveTier` + `OriginRace`; the medallion/book props are wired but unread -> double
   placeholder.) The fallback is correct-by-design; just don't claim medallion/journal as
   visible D1 channels.
3. **Default stays Silent; the MCM verbosity toggle (GAP-2) was never built.** Constants +
   reader exist (`PDV.Diegetic.Verbosity`, default 0=Silent) but no writer/toggle. Verbosity
   only gates notify/Prisma-toast/routine-chime -- **screen/sound/music fire regardless** --
   so the toggle is NOT required to see/prove the visuals. Silent is the correct beta ship
   state. Building the toggle is a small `PDV_MCM.psc` add (optional this pass).

## 5. Tuning (records already authored; remaining = in-game feel + 3 candidate picks)

Per-tone feel is baked into the records (duped+recolored). Remaining tuning is in-game-feel
iteration, plus three manifest-flagged `candidate=true` picks to confirm or swap:
dread shader EFSH `0ABEFF` (AbsorbHealthFXS), Hollow SNDR `057C63`, Distant SNDR `03F363`.
Tone map: reverent (tier/recover) gold bloom+chime; revelation (emergence) white bloom+swell;
dread (curse onset) cold tint+vignette held + hollow + curse-bed music ON; release (cure)
clearing fade + rising chime + curse-bed OFF; absence (neglect) desaturate + distant, no shader.

## 6. Enable sequence (collapses to verify -> flip -> prove)

1. (Only if a source edit is in scope, e.g. building the verbosity toggle) clear the scratch
   parity FAIL in `pdv_diegetic_ux_check.mjs` (scratch manager 9277 vs live 14275 lines) and
   recompile. A pure `D1Enabled` flip needs NO source change, so this is avoidable.
2. Read-back verify the 17 records + 23 props on live (houseCARL).
3. Flip `D1Enabled = true` on `07149A:Devotion.esp` (live VMAD write -- see ESP-lock risk).
4. SEQ refresh (likely no-op; both SGE quests already exist) + `node tools/pdv_verify.mjs`.
5. Counted proof on a NEW save via the MCM dev page.

`tools/pdv_diegetic_ux_author.mjs` is **plan-only (`liveWriteBlocked`)** -- it does NOT write;
the flip goes through CK or the PDV VMAD author path (with the houseCARL-off-Anvil dance).

## 7. Counted proof checklist (MCM-driven, NEW save)

tier-up x1 (reverent: IMAD+shader+chime) - neglect drop x1 (absence: IMAD+distant, no shader) -
curse onset x1 (dread: IMAD held + shader + hollow + curse-bed ON) - curse cure x1 (release:
remove dread, IMAD + rising chime + curse-bed OFF) - save/load mid-curse re-asserts music with
no double-fire - deps-absent graceful (medallion->Survey, journal->cache) - routine favor does
NOT one-shot. Confirm via raw trace keys `PDV.Diegetic.LastDispatch/LastTone`, not labels.

## 8. Risks

- VMAD save-bake (HIGH) -> new-save proof (above).
- ESP lock (MED): houseCARL on Anvil blocks the PDV author tool ([[housecarl-holds-esp-lock]]);
  re-point to DoD, write the flip, re-point to Anvil.
- Scratch parity FAIL (MED) gates source promotion -- avoidable if no source change.
- Notification dwell (LOW-MED): dread holds IMAD+shader until cure; Silent verbosity mitigates
  notify spam; watch the day-key-zero anti-spam pattern ([[storageutil-day-key-zero-default]]).
- `turning`/`apotheosis` content gap (LOW, design): default chime + no screen; confirm acceptable.

## Open checks before execution

1. Confirm D1 is a pure `D1Enabled` flip (no source promotion) -> then the scratch-parity FAIL
   is not a blocker. 2. Live VMAD read-back of all 23 props on `07149A` before the flip.
3. Confirm/swap the 3 candidate records (dread shader, Hollow, Distant).
