# PDV Build-Batch Handoff (2026-06-14)

Resume point for the 9-race beta work. Read this + the smoke-test packet
(`PDV_BuildBatch_SmokeTest_2026-06-14.md`) and the audit report
(`PDV_9Race_BetaAudit_2026-06-13.md`). Memory files also carry the durable context.

## Where we are

- **Audit (done, committed + pushed, `origin/main` @ 70ce882):** the 9-race beta audit
  report + 9 trimmed beta-test packets. Headline: rewards are fully wired (readback 1280/0)
  but the friction/anti-farm/state-gating layer was broadly stubbed; 45 should-have-been-built
  items.
- **Pure-script HIGH build batch (done, compiled 0/0, verifier FAIL=0 PASS=2938, readback
  1280/0, NOT in git -- lives in `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\
  PDV__ManagerQuest.psc`):** all 9 items below + the neglect vanilla fallback + 13 copy fixes
  + the Argonian bed-count packet fix.
- **Smoke test COMPLETE (2026-06-14): tests 1-9 PASS** (all confirmed in `Papyrus.0.log`). Test 10
  (copy spot-checks) FOLDED into the editorial pass per user direction -- the Bosmer/Dunmer/Argonian
  Survey lines are subsumed by the all-10-race Survey rewrite; Nord already passed. In-game evidence
  the rewrite is needed: Bosmer Survey renders `Your Bosmer path is OldContract...` (raw enum via
  `GetBosmerPathLabel()`), Orc opens "Malacath watches the code through City life" (dev language).

## RESUME HERE -- remaining smoke tests

Universal: NEW save / fresh state per race; `set PDV_GLO_OriginRace to <n>`; `set
PDV_GLO_DebugLevel to 2`; click **Curse none** before swapping origin; read
`Logs\Script\Papyrus.0.log`. **qasmoke has only vanilla items** -- PDV's proof objects are
invisible script-activators in the (PDV-overridden) QASmoke cell; fire them by RefID from
anywhere. The activators are NAMELESS and this list does not preserve EditorIDs, so
`help "OrcStrongholdForge"` returns nothing -- get the 2-hex prefix once off a NAMED PDV
blessing instead: `help "HoonDing" 0` -> the `SPEL:` line's FormID `(XX0711A0)` -> the first
two hex digits are your prefix `XX`. Then `prid XX<refid>` + `activate player` (NOT bare
`activate`).

| # | Test | Origin | Trigger | PASS = |
|---|------|:---:|---------|--------|
| 6 | Orc life-mode no-flip | 8 | `prid XX071027` then `activate player` (Stronghold signal) once | Survey life-mode **stays City** (no instant flip); log `Orc Stronghold forge routed` + evidence recorded |
| 7 | Redguard sect no-flip | 9 | `prid XX07102B` then `activate player` (Crown signal) once | Survey sect **stays Forebear** (no flip) |
| 8 | Nord non-Kyne offers | 0 | `Selected deity` -> a non-Kyne baseline god; **Apply target piety** 55; **Seed commitment signals**; **Run dawn pass** | a commitment **offer fires for that non-Kyne god** (was Kyne-only) |
| 9 | Neglect vanilla notice | any | commit a patron, drop its piety (Apply ~5), Run dawn pass until neglect | top-left notice `<Deity>'s regard fades as your devotion goes quiet.` |
| 10 | Copy spot-checks | 4/0/5/7 | open Survey Devotion | Bosmer `the Old Contract`/etc.; Nord `the Old Ways`; Dunmer `The Reclamations have answered...`; Argonian Normal `The Hist is near, as near as exile allows.` |

Signal RefIDs (all in `PlayerDevotion_Framework.esp`, same XX prefix): Altmer Lorkhan `07101F`,
Orc Stronghold `071027` / City `071028` / Legion `071029` / SelfMade `07102A`, Redguard Crown
`07102B` / Forebear `07102C` / AshAbah `07102D` / FarShores `07102E`, Argonian Hist `071023` /
People `071024` / Void `071025` / Bed `071026`, Khajiit `07102F`-`071034`, Bosmer
`071035`-`07103C`. Organic alt for Altmer: `setstage MQ104 160`.

### Smoke results recorded so far (all PASS, evidence in Papyrus.0.log)
1. Imperial halt -- label flip halted->scarred + handler fired. (Deeper accrual-halt: test ONLY
   while still vampire -- the book DOES drop Divine scratch; if you cure before the dawn it
   grows, which is correct. See `imperial-vampire-halt-v2-strictness`.)
2. Dunmer ancestor silence -- full pass (vampire ash-prayer 0x + 4 posture labels).
3. Argonian near-water -- route fired, Hist climbed 0->5 tier 1. (One-time `growing thin`
   posture toast on first maintenance is a pre-existing cosmetic quirk; folded into the editorial sweep.)
4. Breton exposure decay -- exposure 25 then -1/dawn (24/23/22/21).
5. Altmer Lorkhan -- `penalty applied: -7 to auri-el`; Auri-El dropped 50 -> 45.7 at dawn. No
   toast is correct (silent penalty).

## Built this session (the 9 pure-script HIGH items, all PDV__ManagerQuest.psc)

Orc life-mode evidence-gate + `EvaluateOrcLifeModeAtDawn`; Redguard HoonDing weekly cap + sect
evidence-gate + Ash'abah burden gate; Breton tradition setup-lock; Nord `IsNordOfferEligibleDeity`
(all pantheon-baseline gods + Talos); Imperial `ApplyImperialCurseHandlers` +
`GetImperialCurseGainMultiplier` (Nine Divines accrual 0x while halted); Dunmer
`ApplyDunmerCurseHandlers` + `GetDunmerCurseLayerWeight` (4-state posture, ash-prayer silence);
Argonian `TryArgonianNearWaterMaintenance` (IsSwimming daily poll); Altmer
`GetAltmerLorkhanPietyPenalty` (10/7/5/2, faction-mod stub 1.0); Breton
`DecayBretonWitchcraftExposureAtDawn` (-1/dawn). Plus the neglect `Debug.Notification` fallback
and 13 manager copy fixes. Compile: `node tools/pdv_compile.mjs --script PDV__ManagerQuest`.

## NEXT BUILD PASS -- ESP-record items (heavier, author-tool/CK, lock-prone)

Decide record EditorIDs/magnitudes WITH the user (idempotency-trap territory). Items:
- **Altmer ThalmorAlignment** reputation track (mirror Imperial Concordat `PDV_ReputationTrack`)
  + action table; then wire `GetAltmerLorkhanFactionModifier` to its band (x0.75/1.0/1.5).
- **Orc "Witnessed" + Redguard "Far Shores" variety tranches** (records + hooks).
- **Breton** KnightlyVowIntegrity decrement (needs breach hooks: ThievesGuild/DarkBrotherhood
  faction-add, innocent-kill) + access-suppression multipliers + creed-loss spells; Green Way
  DruidicStanding degradation; tradition-differentiated vampire.
- **Dunmer** Layer-2 0.75x werewolf (needs a scaled curated-signal helper); Grey Quarter
  solidarity route; dawn/dusk twilight window.
- **Argonian** Sithis T3 low-health capstone spell; vampire-onset Message record; Corrupted
  posture via DominationPressure; Hist creed-loss dispatch.
- **Imperial** Concordat secondary modifiers on Arkay/Stendarr; per-action Concordat point table.
- **Nord** small-signal ScoreAction vocabulary (likes/dislikes regen); broad-favor daily cap.
- **9 cosmetic ESP text re-authors** (Bosmer variety "(Effect: ...)" clauses x5, path-suggestion
  articles x4, Dunmer/Imperial wording) -- needs Skyrim+CK closed (ESP lock).

## Planned editorial sweep (after smoke test) -- see `survey-toast-narrator-voice-sweep`
Rewrite ALL 10 races' `Get<Race>SurveyText` into narrator voice (Khajiit treatment) + grammar/
voice review of the Prisma toasts + posture labels (Argonian flagged) + the fresh-Argonian
"growing thin" init quirk. needsRecompile; fan out per-race.

Also in the copy pass: **commitment-offer copy parity** -- test 8 opened formal offers to all
Nord pantheon-baseline gods, but offer copy + MCM labels are still Kyne-worded. Write per-god
offer/accept write-ups for the 11 eligible non-Kyne gods (Old Ways Shor/Tsun/Stuhn; Nine Divines
Akatosh/Mara/Arkay/Stendarr/Zenithar/Dibella/Julianos/Kynareth; + Talos) to Kyne parity, and
degenericize the Kyne-worded MCM strings (`IsNordOfferEligibleDeity` is the eligibility source).
Surfacing the offer in-world stays the separate deferred D0 diegetic work.

## Gotchas
- Gate/curse changes only init on a NEW save; old saves keep stale state.
- `Curse none` between races (shared curse state is global; per-race keys are namespaced).
- Imperial halt voids gain at dawn-consolidation, not earn-time (V2 strictness deferred).
- Build .psc are in `D:\...\Devotion\Scripts\Source` -- NOT in the git repo. The audit doc +
  trimmed packets ARE committed (70ce882). This handoff + the smoke-test doc are uncommitted
  working artifacts (commit if you want them durable).
