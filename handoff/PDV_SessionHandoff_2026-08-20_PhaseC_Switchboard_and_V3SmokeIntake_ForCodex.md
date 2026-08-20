# Session handoff -- 2026-08-20: Phase C switchboard done + V3 smoke intake (-> Codex)

Resume pointer for the 2.0 rebuild. Owner is swapping to Codex for the remaining work.
All work committed on **`feature/v3-origin-extraction`** (nothing pushed). HEAD is
**`ba05afbb`** (12 commits this session, from `5dde5858`).

Prior handoffs (same branch, this session's earlier state): 
`handoff/PDV_SessionHandoff_2026-08-20_PhaseC_Wave2_and_SwitchboardScoping.md` (has the full
switchboard lane-status table + the DEFER-lane rationale). Wave-1: 
`handoff/PDV_SessionHandoff_2026-08-20_PhaseC_Wave1_Validated.md`.

---

## 1. What shipped this session (12 commits)

Base `PDV_OriginRuntimeBase.psc` went **613 -> 561 functions**. 52 dead per-lane base
declarations removed across 5 switchboard lanes; 24 base bodies emptied (waves 2a/2b).

| Commit | What |
|---|---|
| `85b69aa5` | Wave 2a -- emptied 21 provably-safe base duplicate bodies |
| `5538a907` | Wave 2b -- emptied 3 read-only bodies + recorded the empty-body ceiling |
| `6d7d46d2` | docs: wave-2 + switchboard scoping |
| `f50a743f` | Switchboard reward/neglect slice 1 -- per-cycle loop over `PDV_FLST_OriginAdapters` |
| `1fe0ff28` | Switchboard reward/neglect slice 2 -- removed 27 dead per-lane decls |
| `c776f6a6` | docs: mark reward/neglect migrated |
| `c4a6257a` | Switchboard `IsOfferEligibleDeity` lane -- migrated 5 callers, removed 6 decls |
| `e63d6e74` | Switchboard offer-message + survey lanes -- migrated, removed 16 decls |
| `67b99f7a` | Switchboard presentation -- removed 3 callerless `Show*Message` decls |
| `8f64ec83` | docs: switchboard lane-status table (5 done, 3 DEFER) |
| `d4fcba90` | fix: MCM dev tabs on menu open + corrected the stale unlock hint |
| `ba05afbb` | fix: suppress "public recognition changed -> off" nag when the feature is off |

Every code change: isolated compile 0/0 + static parity (`removed=N, changed=0, added=0`)
via `tools/pdv_parity_snapshot.mjs`. Compile verifier's `[FAIL]` block is the documented
default-to-1.5-folder trap (audits `D:/.../Devotion/`, not V3) -- ignore it; read the compile
block only.

---

## 2. DEPLOYED to Devotion-V3Dev + smoke-tested LIVE

houseCARL/MO2 confirmed on the **V3 build**: profile `Devotion Dev`, `Devotion` (1.5)
DISABLED, `Devotion-V3Dev` ENABLED, active `Devotion.esp` resolves `PDV_OriginRuntime_Altmer`
(`071797`, a V3-only record). 6 fresh `.pex` deployed into `Devotion-V3Dev\Scripts`
(`PDV_OriginRuntimeBase`, `PDV_DevotionLedger`, `PDV_QuestReactionRuntime`, `PDV__ManagerQuest`,
`PDV_MCM`, + the recognition-fix manager rebuild). Prior 4 `.pex` backed up in the session
scratchpad. **A running game will not hot-swap a redeployed `.pex` -- relaunch to load new builds.**

Deploy recipe (per script): copy the changed `.psc` into `Devotion-V3Dev\Scripts\Source`, then
`PDV_COMPILE_SOURCE_ROOT=<...V3Dev/Scripts/Source> PDV_COMPILE_OUTPUT_ROOT=<...V3Dev/Scripts>
node tools/pdv_compile.mjs --script <Name>`. (V3Dev source must be synced first; compile reads MO2.)

### Live smoke results (owner, Altmer, V3 build)
- **Test A -- reward grant + within-Altmer strip: PASSED.** Seeded Auri-El patron+piety 85 ->
  Champion blessing granted; switching patron to Magnus dropped Auri-El's and granted Magnus's.
  This validates the reward/neglect switchboard loop (the highest-coupling change).
- **Test C -- Survey devotion: PASSED.** Altmer survey text renders correctly (screenshot: "You
  remain uncommitted in the Thalmor question, holding Auri-El's foundation... Standing: Distant...").
- **Test B -- commitment offer: PARTIAL** (see open items 3b/3c).
- **Race-change / foreign-strip test: NOT DONE.** Still the key remaining runtime check for the
  reward lane (become race A, gain a blessing, `player.setrace`, MCM Compat -> Re-detect origin,
  sleep, confirm A's blessings drop + B's appear -- no double-dip).

---

## 3. OPEN ITEMS / BACKLOG (owner-flagged during smoke -- for Codex)

### 3a. Lowercase deity name in Prisma surfacing -- DEDICATED PASS (2nd occurrence)
Owner: "put the name on backlog, dedicated pass -- that's the second lowercase name problem."
First was **Talos** (wave-1 open bug, quest-reaction line). Now **Auri-El** in the tier-reach
card: *"Favor deepened / Your devotion to auri-el has reached Champion."*

**Traced -- it is NOT the Papyrus layer:**
- `GetPublicDeityDisplayName` (`PDV__ManagerQuest.psc:7689`) = `NormalizePublicDeityDisplayText(deity.DeityName)`;
  for non-Nord returns `deity.DeityName` unchanged.
- Auri-El ESP `DeityName` (QUST `03DE88:Devotion.esp`, VMAD Scripts[0].Properties[1].Data) = **"Auri-El"** (correct).
- The tier-reach BoD line builder `BuildTierReachJournalLine` (`PDV__ManagerQuest.psc:1674`) uses
  `GetJournalDeityName` -> `GetPublicDeityDisplayName` -> "Auri-El" (correct).
- The tier toast `SendPrismaEventToast` (`PDV__ManagerQuest.psc:1415`) also sets
  `deityName = GetPublicDeityDisplayName(deity)` -> JSON `"deity":"Auri-El"` (correct).
- The MessageBox/survey path renders "Auri-El" correctly (owner screenshot).

So every Papyrus source is correct-cased. The lowercase **"auri-el"** is Altmer's **Prisma
SYMBOL/key** (used ~20x as the symbol arg in `AppendBookOfDaysEntry`/`SendPrisma*` calls, e.g.
`PDV_OriginRuntime_Altmer.psc` and `PDV_OriginRuntimeBase.psc`; also the roster medallion id).
**Conclusion: the lowercasing is in the Prisma BRIDGE JS/view rendering** -- the tier toast/journal
template is composing the sentence from the `symbol` field (or lowercasing `deity`) instead of using
the correct-cased `deity` field. Look at the Prisma view templates (the bridge's `index.html` /
toast+journal view JS; per memory `prisma-bridge-build-xmake` views are editable, no C++ build, and
toast payload fields ride raw JSON). Fix the tier/journal template to render the `deity` field; then
recheck Talos and every other multi-word/hyphenated name (Tu'whacca, Z'en, Baan Dar, Auri-El).
Note the Prisma view-edit cache-key gate (`pdv_prisma_view_cache_key`) -- bump `index.html` cache key.

### 3b. Formal offer must NAME the deity + wording rewrite -- DEDICATED PASS
Owner: "offer doesn't name Auri-El. Dedicated pass for the offer at Devoted (50) -- I think for ALL
offers to make sure they have the name. And the wording was mediocre; I need to re-write the drafts."
- `GetXFormalCommitmentOfferMessage` (per adapter, e.g. `PDV_OriginRuntime_Altmer.psc`
  `GetAltmerFormalCommitmentOfferMessage`) returns a **Message record** (`PDV_Msg_Altmer_AuriEl_Offer`,
  `..._Magnus_Offer`, `..._Xarxes_Offer`, `..._Trinimac_Offer`, `..._Syrabane_Offer`, and the same
  shape for the other 5 offer races: Breton/Dunmer/Imperial/Nord/Redguard).
- The fired offer did not name Auri-El -> the **Message record TEXT** lacks the deity name (or a
  generic message fired). Pass: audit all per-race per-deity offer Message records; ensure each
  includes the deity name; owner will supply rewritten drafts (append them to
  `references/authoring/PDV_WordingRevisionBacklog.md`).
- Offer gate = broad worship + deity piety >= **50** (`COMMITMENT_OFFER_THRESHOLD`,
  `PDV_DevotionLedger.psc:109`) + `HasRecentCommitmentSignalDays(deity, 2, 7)` (`:4130`).

### 3c. Negative-test toast-vs-offer wiring -- VERIFY
Owner: "swapping to Baan Dar to test, applying piety still made a toast pop but no offer happened.
May be how the buttons are wired -- flagging as needing a fix."
- LIKELY CORRECT, needs confirmation: applying piety crosses a tier -> the **tier-reach** surface
  ("Favor deepened" toast) fires for ANY deity (`PDV_DevotionLedger.psc:~1137` `SendPrismaEventToast`
  + `SurfaceTransition`). The **offer** correctly did NOT fire because Baan Dar is not Altmer-eligible
  (`IsAltmerOfferEligibleDeity` excludes it). So "toast but no offer" is expected -- the toast is the
  tier surface, not an offer. Codex: confirm the popped toast is the tier-reach card (not a spurious
  offer/recognition toast), and confirm the negative case (ineligible deity -> no offer) holds via
  the MCM Commitment group. If the toast is undesired for an ineligible deity on an offer-race, that's
  a design call for the owner.

### 3d. Recognition toast nag -- FIXED this session (`ba05afbb`)
`SurfaceNpcRecognitionTransition` (`PDV__ManagerQuest.psc:9236`) toasted "public recognition
changed -> off" on every identity/band change even when recognition is off (shipped default).
Guarded to suppress when neither friendly nor hostile recognition is enabled (signature still
recorded). Deployed; takes effect next launch.

---

## 4. Remaining Phase C switchboard (DEFER lanes -- scoped, not started)

Mechanical switchboard migration is near-exhausted; the remaining base per-lane decls are pinned
by base-internal `Self` callers from OTHER lanes still living in the base. Full detail + rationale
in `8f64ec83` and the wave-2 scoping handoff. Summary:
- **Show\*Notification** -- DEFER (BLOCKED): decls pinned by internal callers from other lanes;
  external callers are deity-gated (not race-gated) -- a non-owner Auri-El/Kyne champion reaches them.
- **State/detail cluster** (`GetOriginStateLabel/Value`, `GetOriginDetailLabel/Value`) -- DEFER
  (COMPLEX): parameterized methods the key-generic can't carry; dense base-internal Self callers;
  Bool->Int round-trips in gameplay branches; Argonian arm divergence.
- **`HandleContextualSignal`/`HandleContextualQuery`** -- DEFER (HIGH RISK): ~166 stringly-typed
  action->piety call sites, silent-misroute risk, partial routing coverage, NO coverage gate, thin
  payoff. Would need a per-site audit table + new adapter switch arms for uncovered methods + a NEW
  coverage gate + full per-race runtime proof. Also trips a name/string pin at
  `tools/pdv_substrate_pacing_audit.mjs:299`.
- **Optional cleanups (non-blocking):** ladder collapses in `GetFormalCommitmentOfferMessage`
  (ledger) and `GetSurveyDevotionText` (manager, minus the Nord scar-label tail) -- each branch now
  calls the identical generic. Dead helper subtrees from the reward lane (`SyncAltmerRewardFamily`,
  `SyncAltmerAncestorSubstrate`, ...) -- a dead-code sweep.

Recommendation for after the runtime checks: either extract another lane's bodies out of the base
(to unpin the state/detail + notification decls), OR build the coverage gate + do the dedicated
review for the signal router, OR call the base dedup "good enough" and move to Phase E
(RECOGNITION -> PRISMA, producer-first; PRISMA hook design already drafted, `b492bfa3`).

---

## 5. Corrected MCM test procedures (for continuing the smoke)

### Dev tab unlock (owner-only)
Debug tabs are gated by `DeveloperOptionsEnabled()` = `PDV_GLO_DebugLevel >= 1`. `Pages` rebuilds on
`OnGameReload`; the `d4fcba90` `OnConfigOpen` fix should also rebuild on menu-open but is **unverified
in-game** (may not fire before SkyUI reads the tab list). **Guaranteed path:** `set PDV_GLO_DebugLevel
to 3` -> **save -> load that save** -> open MCM (the 3 Debug tabs appear).

### Test A (reward grant/strip) -- PASSED, for reference
`Debug: State & Rewards`: Selected deity -> Auri-El; Debug patron override; Target piety 85 -> Apply;
check Active Effects + Player page (Patron/Standing). Strip: switch Selected deity -> Magnus -> patron
override -> seed 85; Auri-El drops, Magnus grants. (`SyncFirstTierRaceRewardRuntime` fires on Apply /
patron override.)

### Test B (offer) -- CORRECTED (original steps used the Imperial/Nord-only "Prepare patron offer")
Use the **Commitment offer group** on the **Debug: Daedric & Curse** tab: (1) Set Broad worship;
(2) Selected deity -> Auri-El; (3) Target piety 50 -> Apply; (4) **Seed signals** (seeds the 2-day
window on the selected deity -- the piece "Prepare patron offer" did only for Imperial/Nord);
(5) **Evaluate commitment** (dawn-equivalent) -> offer surfaces; (6) confirm it names an Altmer-eligible
god only, then **Accept/Decline commitment**. Negative: an ineligible Selected deity -> Seed signals ->
Evaluate -> no offer. (NOTE the 3b naming bug and 3c toast question apply here.)

### Test 2 (race-change / foreign-strip) -- NOT DONE
Nord blessing active -> `player.setrace HighElfRace` -> MCM **Compat -> Re-detect origin -> Run now**
(re-captures + rebinds; `PDV_MCM.psc:ReDetectOrigin` -> `PDV_Origin.InitializeOrigin` ->
`ResolveOriginRuntime`) -> sleep -> confirm Nord blessings drop + Altmer lane engages, no double-dip.

---

## 6. Key references

- **Cast-safety audit (switchboard input):** `references/authoring/PDV_2_0_ORIGIN_CastSafetyAudit_2026-08-19.md`
- **Switchboard lane-status + DEFER rationale:** the wave-2 scoping handoff (updated) + commit `8f64ec83`.
- **Core source:** `PDV_OriginRuntimeBase.psc` (561 fns), `PDV_DevotionLedger.psc`, `PDV__ManagerQuest.psc`,
  `PDV_OriginRuntime_<Race>.psc` (10 adapters), `PDV_MCM.psc`.
- **The reconcile loop:** `PDV_DevotionLedger.psc` `SyncFirstTierRaceRewardRuntime` (now a generic
  loop over `Manager.PDV_FLST_OriginAdapters` calling `SyncRaceRewards()` + `SyncNeglectSpells()`).
  Non-bound adapters ARE `Manager`-wired (houseCARL ESP readback Altmer `071797` + Nord `071794`:
  `Manager -> 00C325`) -- that's what makes `foreignAdapter.SyncRaceRewards()` valid.
- **Lowercase-name bug:** Prisma bridge view/JS (tier + journal toast templates); Papyrus emitters
  at `PDV__ManagerQuest.psc:1415/1674/7689`; Auri-El QUST `03DE88` `DeityName` (correct).
- **Offer:** per-adapter `GetXFormalCommitmentOfferMessage` -> `PDV_Msg_<Race>_<Deity>_Offer` records;
  threshold `COMMITMENT_OFFER_THRESHOLD=50` (`PDV_DevotionLedger.psc:109`); recency gate
  `HasRecentCommitmentSignalDays` (`:4130`).
- **Tools:** `tools/pdv_compile.mjs` (env-scoped source/output roots), `tools/pdv_parity_snapshot.mjs`
  (`--snapshot` / `--compare`, exits 1 on CHANGED/REMOVED unless `--allow-removed`).
- **Memory hooks (this machine):** `phase-c-empty-body-ceiling`, `v3-tools-need-pdv-devotion-root`
  (set `PDV_DEVOTION_ROOT` or gates audit 1.5), `mo2-profile-is-dev-not-version`,
  `prisma-view-cache-key-gate`, `wording-revision-backlog-location`.

## 7. Environment / gotchas

- Branch `feature/v3-origin-extraction`, HEAD `ba05afbb`, **unpushed**. 12 commits this session.
- Working tree is **CRLF** while git index is **LF** (autocrlf + `eol=lf`); edit scripts must preserve
  the working-tree newline (the session used newline-detecting Node scripts). `PDV_MCM.psc` is LF.
- houseCARL instance pointer unchanged this session (`D:/Wabbajack/modlists/Anvil`, profile
  `Devotion Dev`, with `Devotion-V3Dev` enabled = V3). Confirm before any readback that becomes a claim.
- Runtime not-yet-validated: Test B naming/wording (3b), race-change (Test 2), waves 2a/2b spot-check
  beyond Test A's class. Test A + Test C passed.
