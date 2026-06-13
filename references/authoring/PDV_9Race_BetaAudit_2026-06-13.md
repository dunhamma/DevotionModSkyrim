# PDV 9-Race Beta Audit (2026-06-13)

Same audit treatment Khajiit got, applied to the other nine races: Orc, Redguard,
Breton, Dunmer, Imperial, Nord, Altmer, Argonian, Bosmer. Four workstreams:
**enablement/completeness**, **Papyrus optimization**, **player-facing copy/editing**,
and **beta-test packet trimming**.

Method: machine baseline (the existing toolchain) + a 20-agent fan-out (2 per race:
wiring/enablement/papyrus and copy/tests; plus shared-engine Papyrus and a
cross-cutting surfacing agent). Live scripts at
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\`; specs/packets in this repo.

## Machine baseline (all green)

| Check | Result |
|---|---|
| `pdv_content_verify` | FAIL=0, WARN=0, PASS=1080 |
| `pdv_phase2_reward_readback_audit` | **1280 / 0** — every race's T1/T2/T3 + T3 capstone authored in the ESP |
| `pdv_completeness_audit` | PASS, 768 rows; 79 GAP-REVIEW adjudicated below |
| `pdv_paired_equity_audit` | PASS, 0 name errors |
| `pdv_verify --strict-phase20-*` | PASS |

**The reward layer is fully enabled for all nine races.** The Orc spec's
"design-draft / pending authoring" status line is stale. Gaps are not in the reward
records — they are in the **friction, anti-farm, state-gating, and surfacing** layers.

## Headline verdict

Every race **scores piety and grants rewards**, but the **consequence machinery that
gives each race its character is broadly stubbed or inert.** Switch-gates that should
make life-mode / sect / tradition stable instead flip on a single stray act;
anti-farm caps that should make rare beats rare are missing; curse postures that
should bite collapse into one generic "strained"; and several signature mechanics
(Altmer's Lorkhan penalty, Breton's vow integrity, Nord's non-Kyne offers) are
telemetry-only — they narrate in the Survey but change no piety. None of this is a
Papyrus-performance problem (all race scripts are clean); it is **design-vs-build
drift**. 45 distinct "designed but not coded" items surfaced; the HIGH ones are below.

Per-race Papyrus health: **all GREEN.** Beta-test packets can be trimmed ~40%
(~148 -> ~90 steps) with zero loss of safety coverage.

---

## 1. Should-have-been-built (the build list)

Grouped by race, HIGH first. "where" = design source; "fix" = the wiring path. None of
these were built inline — they are implementation decisions for you to prioritize.

### Altmer (P0 "spine" — most surprising, since it is marked PASS)
- **[HIGH] Lorkhan Adjacency Penalty deducts NO piety (telemetry-only).** The defining
  Altmer mechanic. `HandleAltmerLorkhanPressure` (~`PDV__ManagerQuest.psc:4441`) only
  increments a pressure counter and may set crisis state; it never calls any piety-adjust
  path and never applies the x0.75/x1.0/x1.5 faction modifier. An Altmer can use Talos
  shrines, join Stormcloaks, marry, and homestead at **zero** cost while the Survey
  narrates "Lorkhan pressure has been named." where: `PDV_RaceDesign_Altmer.md` Lorkhan
  Adjacency Penalty System + economy lock.
- **[HIGH] ThalmorAlignment track entirely unbuilt.** The secondary friction spine and
  gating axis (faction setup bands, x1.5/x0.75 signal multipliers, the Lorkhan faction
  modifier, the +15/+20/-25 action table). Design says it reuses the same
  `PDV_ReputationTrack` as Imperial Concordat (which exists), but **no Altmer alignment
  property is declared** (0 grep hits). where: `PDV_RaceDesign_Altmer.md` ThalmorAlignment.
- [MED] No automatic daily dawn-rite faucet (the +2 Auri-El upkeep that keeps a normal
  Altmer net-positive); fires only off curated content today.
- [MED] No MCM debug buttons for Altmer (the `DebugRecordAltmer*` manager functions exist
  but have no MCM caller — blocks your MCM-driven smoke lane).
- [MED] Syrabane T3 focus unbuilt as a reward patron (no deferral note, unlike Trinimac).
- [LOW] "The Return Made Daily" variety tranche absent (gated behind the effect-review ledger).

### Orc (P1)
- **[HIGH] Life-mode switch-gate uncoded.** `RecordOrcLifeModeSignal`
  (`:3912`) `SetState`s the instant a single differing-mode signal arrives — one stray
  City act flips a Stronghold Orc to City. Violates the LOCKED two-signal/7-day/3-day-lock
  rule. The `StateTrack` primitives (HasRecentEvidenceDays, lockout) already exist and are
  even recorded at `:3906`, just never read back.
- **[HIGH] No `EvaluateOrcLifeModeAtDawn` dawn evaluator** — no consolidation point to
  confirm/demote a mode; mode can only ratchet on the latest signal.
- **[HIGH] Entire "Witnessed" variety tranche uncoded** (Trial of Iron, Four Holds of the
  Code, The Watchers, The Code Holds, Hearth-Held) — the design-locked content whose
  explicit purpose is to close the City/Legion-Exile felt-content gap. Zero grep hits.
- [MED] Oath-breaking negative signal has no detector (vocabulary defined in the deity
  script, never fed).
- [MED] Everyday forge/strength hooks missing — quality-craft and outleveled-kill earn no
  Malacath piety unless routed through a curated quest source.

### Nord (P2 audit-only lane)
- **[HIGH] Only Kyne can fire a primary-patron commitment offer.**
  `UsesFormalCommitmentOffersForDeity` returns True for `PDV_Kyne` only, so a Nord who
  fights for the Stormcloaks (Talos), builds a home (Mara), or tends the dead (Arkay) never
  gets an offer. **All 13 Nord gods' T1/T2/T3 reward spells are authored but stranded with
  no organic path.** Biggest Nord gap. fix: generalize the gate to any pantheon-baseline
  deity (the eligibility/cooldown machinery is already generic).
- [MED] Small-signal ScoreAction vocabulary thin (Tsun/Stuhn no per-event drip).
- [MED] Broad-favor route families have no shared daily anti-farm cap on the piety pulse.
- [LOW] Focused favor lane is Kyne-only (largely V2-deferred).

### Redguard (P1)
- **[HIGH] HoonDing make-way weekly cap missing** — `AwardRedguardForebearSignal`
  (`:4114`) fires with no weekly gate, so the deliberately-rare make-way is farmable.
- **[HIGH] Sect-switch evidence gate bypassed** — `RecordRedguardSectSignal` flips sect on
  the FIRST signal; a single tomb visit rewrites sect identity. Ash'abah entry/exit burden
  gate also absent. (StateTrack evidence machinery exists, unused.)
- [MED] Make-way-Champion and Honorable-Duel senders never fire (the strongest Redguard
  payoffs are unreachable); Tu'whacca vampire-cure re-entry credit is cosmetic-only.
- [MED] "Far Shores Keep Watch" variety tranche unbuilt.
- [LOW] Death-duty abandonment anti-creed sender unwired.

### Argonian (P1)
- **[HIGH] Ambient near-water Hist recovery missing.** The design centerpiece ("Hist
  recovers from being near water") is inverted: recovery only fires from curated FormList
  nodes, so ordinary river/lake/swamp play earns nothing and the -1/day decay wins.
- [MED] Vampire-onset has no explicit notification (design wants this grief state surfaced
  loudly); Corrupted posture is unreachable (DominationPressure key never set); the Hist
  creed-loss signals (abandonment/corruption/void-overreach) are never dispatched.
- [LOW] Sithis T3 near-death capstone (Void-Held) not a named record.

### Imperial (P2 audit-only lane)
- **[HIGH] Vampire rupture does not halt Divine accrual.** No `ORIGIN_IMPERIAL` branch in
  the curse handler; an Imperial vampire keeps earning Divine piety while the Survey label
  *says* "civic faith halted" — the mechanic lies to the player.
- [MED] Concordat secondary modifiers on Arkay/Stendarr missing (only Talos is Concordat-bound).
- [MED] Per-action Concordat point table not wired — track moves in flat +/-15 steps
  regardless of the political act's magnitude.
- [LOW] Anti-farm piety caps on curated civic signals missing.

### Breton (P2 audit-only lane)
- **[HIGH] KnightlyVowIntegrity never decrements** — only ever set to 100. None of the
  documented breaches fire (Thieves Guild -30, Dark Brotherhood -40, etc.) and none of the
  access-suppression effects exist. A Knight's-Road Breton can join the Thieves Guild and
  Dark Brotherhood at zero theological cost; the vow always reads "intact."
- **[HIGH] WitchcraftExposure is a one-way ratchet** — only increments +25; the -1/day
  decay and the public-Divine cover path are unbuilt, so "stay hidden vs go Notorious"
  collapses to "always rupture."
- **[HIGH] Tradition silently overwritten by last-touched source** — `HandleBretonTraditionChoice`
  re-runs `ApplyBretonInitialChoice` on every routed source with no SetupComplete gate,
  violating the LOCKED "no mid-game switching" criterion.
- [MED] DruidicStanding is a decorative number (never gates rewards, never degrades).
- [MED] No QASmoke route-proof infra / author tool for Breton.
- [MED] Tradition-differentiated vampire outcomes unimplemented (all traditions get the
  same generic posture).

### Dunmer (P2 audit-only lane)
- **[HIGH] Curse posture collapses all curses to "strained"** — no Silent vampire state,
  no Layer weight modulation. The vampire ash-prayer silence the design calls "the hardest
  consequence in the mod" does not exist; vampirism feels identical to a stubbed strain.
- [MED] Grey Quarter / diaspora solidarity Layer-1 route missing.
- [MED] Dawn/dusk twilight time-window scoring absent (the everyday Dunmer rhythm).
- [LOW] Stale Boethiah/Mephala deity-script header comments (claim handlers are telemetry
  stubs; they now route).

### Bosmer (P1 — most mature; only MED/LOW gaps)
- [MED] Z'en Exchange daily FLOOR family (Reciprocity transaction + production hooks) — the
  Exchange path goes quiet between milestone beats.
- [MED] Vampire -> PactBound break not wired (an Old-Contract vampire keeps Y'ffre against
  locked theology).
- [MED] Organic "proper hunt kill" + "sleep outdoors / road-life" detection fire only from
  placed activators, not generic Story-Manager hooks.
- [LOW] Plant-potion and woodcutting GPC penalties (only plant-food is coded).

### Read on the P2 lane
Breton/Dunmer/Imperial/Nord "full wiring" is an explicit **deferred "P2 audit-only lane"**
(GAP ledger FUTURE rows BC-0706/0758/0759/0763). Much of their unbuilt friction is
*intentional deferral*. The exceptions worth treating as bugs regardless of lane: **Breton
tradition silent-overwrite** (violates a LOCKED criterion), and the surprising **Altmer**
findings (P0, marked PASS, yet its two signature mechanics are inert).

---

## 2. Transition surfacing — resolved (cross-cutting)

The §16.7 per-race transition toasts route through `SurfaceTransition()` ->
`PDV_DiegeticDirector.Dispatch()`, whose visible output is gated by `D1Enabled`.

- **D1 is OFF by default (D0) and should stay off for beta.** The diegetic
  medallion/journal/shader layer is staged behind its own counted-transition proof gate
  with placeholder records. Do not enable it for beta.
- **Generic fallbacks cover the load-bearing beats (D0-safe):**
  - **Tier-up:** `Debug.Notification("<Deity> marks you as <Tier>.")` always fires (guarded once per deity+tier).
  - **Curse onset/cure:** per-race `Show<Race>Message` modals with **hardcoded lore
    fallbacks** that work even if the ESP record is missing. Nord/Khajiit/Altmer/Redguard
    have bespoke text; others get generic. (Orc has no bespoke curse Message property —
    falls through to generic.)
- **GENUINE SOFT GAP [MEDIUM]: neglect surfacing has no vanilla fallback.** On a patron
  lapse the only D0 surface is a Prisma-overlay toast (`:5637`); without the overlay the
  player gets **zero** textual notice (the `PDV_SPEL_Neglect_*` penalty still applies
  silently). Affects all 10 races. **Recommended pre-beta fix:** add a `Debug.Notification`
  fallback at the neglect drop site.
- The per-race `PDV_Notif_*` tier/emergence/neglect/reorientation records are
  **draft-in-manifest, promoted for ZERO races.** Acceptable for technical beta (generic
  toasts cover tier/curse); a content-feel-beta polish item (CAT-6/Phase 19).
- `emergence` and `reorientation` transition classes have **no live call sites** — even
  with D1 on they would never fire.

## 3. Papyrus optimization

- **Every race's own scripts: GREEN.** Deity shells are stateless table lookups; substrates
  and handlers are event-driven; no bare `RegisterForUpdate`/`OnUpdate` polling, no
  cloak/aura scans, no `Utility.Wait` chains, no `GetFormFromFile`-in-loop, no uncapped
  loops, no per-tick StorageUtil churn. Day-keys correctly use the `today+1` convention
  (avoids the day-0 self-suppression trap).
- Minor yellows (none blocking): uncached `Game.GetPlayer()` in the cold reward-sync
  `Sync*Spell` paths (Breton/Argonian/Orc) — trivial, not hot; Bosmer `Utility.Wait(0.5)`
  before a sleep-menu MessageBox — acceptable on the rare sleep path.
- **Shared engine: EXCELLENT — ship as-is for beta.** Dedicated review confirms textbook
  discipline everywhere: the 1s manager `OnUpdate` throttles real work to a 10s sub-interval;
  `OnHitEx`/`OnItemAdded` lead with stacked early-outs; `GetFormFromFile` is lazily cached;
  registrations are single-update with exits. The only optimization on the table is the known
  `Game.GetPlayer()` -> `GetActorRef()` swap at 5 `PDV_PlayerEvents` sites (`:403/451/491/553/1112`
  — a couple mildly hot: per-kill, per-stolen-item, 4s combat poll) plus optional spell-add
  caching in `DeityBase`/`SubstrateBase`. All low-risk, ~0.5-5ms/combat-session, post-beta polish.
- Orc's `RecordOrcLifeModeSignal` is flagged yellow as a **design-correctness** issue (the
  switch-gate bug above), not a performance defect.

## 4. Player-facing copy (29 findings)

Risk-tagged for the agreed apply policy (apply safe; confirm before ESP/recompile):

- **docOnly (6)** — spec/manifest/packet/design-doc text, safe to edit:
  - Argonian packet drift: bed-of-choice count says 3, live gate is **12** (`:2292`) — would
    cause a false-FAIL; and the "reward redesign snapshot" magnitudes disagree with the spec.
  - Breton spec WitchcraftExposure enum comment vs design-sheet band names.
  - Altmer design-doc `ThalmorAlignment` mis-spelled with non-ASCII `o-slash`; dash/quote hygiene.
  - Orc creed text — reviewed clean, no change.
- **needsRecompile (14)** — hardcoded strings in `PDV__ManagerQuest.psc` (need a source edit
  + manager recompile): Bosmer Survey path labels leak CamelCase enum tokens
  ("OldContract" -> "the Old Contract"); Songs-of-the-Green vision reword (name Y'ffre);
  Dunmer 4 Survey strings; Nord 2 Survey strings ("old road" -> "Old Ways"); Breton Survey
  "Fork: None." suppression + an unreachable DruidicStanding "frayed" band; Argonian Survey
  Normal-posture diegetic opener; Redguard Crown fallback string; Orc toast substrate token.
- **needsReauthor (9)** — ESP record displayName/description text (need housecarl re-author):
  Bosmer 5 variety SPEL descriptions should append the "(Effect: ... )" magnitude clause the
  reward blessings carry, + 4 path-suggestion MESG records ("toward the Exchange"); Dunmer
  neglect displayName "The Ancestors Silent" -> "Fall Silent"; Imperial 3 spec strings.

No reward magnitudes were touched (idempotency trap).

## 5. Beta-test packet trimming

The packets are trimmable ~40% with **no loss of safety coverage** (wrong-origin rejection,
generic-source silence, anti-farm/silence checks, and every unique reward/curse/variety
lever are preserved). Recurring cut patterns: (a) reading every approved book when one
proves the route; (b) running BOTH the QASmoke route-marker check AND an organic proof of
the same route; (c) PENDING/blocked "Edge Build" stubs with no runnable step -> replace with
a one-line deferred pointer; (d) exhaustive rejected-hook enumerations -> one combined
silence assertion over 2-3 representative triggers; (e) standalone "reward/stack snapshot"
sections that re-prove the machine-verified readback.

| Race | Before | After | Notable cuts |
|---|---:|---:|---|
| Orc | 13 | 8 | both-books -> one; 7-trigger silence -> one combined |
| Redguard | 6 | 4 | PENDING Edge stub -> pointer; merge negative checks |
| Breton | 6 | 4 | PENDING Edge stub; dual route proof -> machine + one clarity |
| Dunmer | 13 | 7 | 4 books -> 2; PENDING Edge; redundant stack snapshot |
| Imperial | 11 | 7 | PENDING Edge; 7-trigger silence -> representative; trim evidence |
| Nord | 11 | 7 | 3 books -> 1; defer focused-survey matrix to the Phase 18 runbook |
| Altmer | 10 | 6 | fold anti-farm into Edge; fold stack snapshot into Expected |
| Argonian | 20 | 13 | 6-site walk -> 1 + milestone seed; collapse seeders; fix bed-count drift |
| Bosmer | 58 | 34 | make Single-Session the canonical run; demote DA05/QASmoke/Variety to referenced procedures; merge the two DA05-105 setups |

Bosmer is the largest win — its packet has grown three overlapping full run-throughs
(DA05, QASmoke fallback, Variety addendum, Single-Session) that each re-prove routes,
negatives, and the runtime-check; collapsing to one canonical Single-Session pass that
*references* the others removes the duplication while keeping the Baan Dar Gap silence
battery and the single-family-swap sweep intact.

---

## Action plan

1. **Apply now (safe, authorized):** the beta-test packet trims and the docOnly copy fixes
   (incl. the Argonian bed-count false-FAIL fix). Doc edits, reversible.
2. **Confirm before doing (per your "ask before risky"):**
   - the **needsRecompile** copy fixes (they recompile the 11k-line manager),
   - the **needsReauthor** ESP edits (housecarl re-author),
   - the recommended **neglect `Debug.Notification` fallback** (small, but a manager recompile),
3. **Your call — the build list (Section 1):** these are real implementation work, not
   inline fixes. The HIGH items in particular (Altmer Lorkhan penalty + ThalmorAlignment,
   Orc switch-gate + Witnessed tranche, Nord non-Kyne offers, Redguard caps, Argonian water
   recovery, Imperial vampire halt, Breton vow/exposure/overwrite, Dunmer curse posture)
   determine how close each race really is to beta-feel.
