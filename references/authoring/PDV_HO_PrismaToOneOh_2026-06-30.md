# PDV_HO_PrismaToOneOh -- consolidated remaining Prisma UI work to 1.0

**Created:** 2026-06-30
**Purpose:** Single source of truth for "what is actually left for Prisma UI."
Supersedes the scope framing in `PDV_HO_PrismaHardening.md` (that doc was written
off the v3 contract before the recent build wave; most of its hardening steps have
since shipped). Cross-references the owner-ratified worklist for line-level cites.

---

## TL;DR -- status correction

The earlier read ("Prisma hardening is the big remaining front") is **stale**.
Two things changed the picture:

1. **The v3 16.6 hardening sequence is essentially DONE and machine-clean.**
   `node tools/pdv_prisma_ui_audit.mjs` passes **47 checks**. Accessibility
   (aria-live + aria-atomic on the toast stack and both modals, `focus-visible`,
   `prefers-reduced-motion`, capture-phase ESC handlers), the payload/close
   contract (documented in `native/DevotionPrismaBridge/README.md`), and runtime
   routing (favor/dawn/neglect/tier/rivalry/shift/creed/curse/daedric/substrate
   via 14 `SendPrismaEventToast` + 7 fallback + 8 `SendOverlayJson` call sites)
   are all in.

2. **The genuinely-open work is the PARITY thread, not hardening.** It is
   owner-ratified and line-cited in
   `references/authoring/PDV_PrismaParity_DecidedWorklist.md` (2026-06-25).

**Is it coding / building / design?** Entirely **CODING** now. The 9 parity wires
plus the 10 "authoring beats" are all mechanical Papyrus wire-ups in
`PDV__ManagerQuest.psc` (the JS renderers already exist). The beats' player-facing
copy is **APPROVED + LOCKED** in `PDV_PrismaParity_AuthoringDraft.md` (2026-06-25),
so there is no remaining copy/redline gate -- Codex wires the locked strings.
There is **no ESP-record building** here. The one design-heavy item
(substrate-native always-on instruments) is explicitly **V2 / out of 1.0 scope**.

---

## Authoritative source docs (do not duplicate; cite for exact line numbers)

- **`PDV_PrismaParity_DecidedWorklist.md`** -- PRIMARY. Owner-ratified worklist:
  9 coding items + 10 authoring beats + retirements, each with a manager call-site
  and current line cite. Manager line numbers drift -- trust the function/site
  names below and re-grep; use this doc for the current line.
- `PDV_PrismaParityTriage.md` -- full 75-row triage (41 accept-as-is, 3 retire,
  31 wire); the reasoning behind the worklist.
- `PDV_PrismaParity_SerializedHandoffs.md` -- dispatch order + sync rules
  (A = parity fixes, B = offer scale-out, C = hardening, D = future authoring).
- `PDV_HO_PrismaHardening.md` -- the native/xmake hardening track (now mostly done;
  remaining = the focus-trap in-game re-confirm below).
- `PDV_PrismaUXEquityAudit.md` + `PDV_PrismaChoicePanel_CapabilityPlan.md` -- the
  V2 design-exploration material.

---

## DONE -- do NOT rebuild

- Startup modal, medallion roster modal, Book of Days (Chronicle) -- shipping.
- Toast stream: tier / favor / neglect / rivalry / curse / daedric / shift /
  creed -- surfaced, with vanilla fallback (`SendPrismaToastPayloadOrFallback`).
- Weekly tab 7-day sparkline for all gods (commit `3fd82afa`).
- Book of Days close/escape contract centralized + hardened (commits `0ef86d52`,
  `758b5da5`, `30645e16`, `32d0d634`).
- 6f substrate-act rites (Orc Trial, Redguard Remembering, Altmer Discipline) --
  both surfaces wired (Ledger driver + Chronicle entry).
- Signal-equity reason threading -- `AwardCuratedSignalScaled` passes
  `HumanizeCuratedSignalReason(...)` so curated/scaled signals record Ledger
  drivers (closed 2026-06-25).
- Accessibility + payload contract + the 47-check `pdv_prisma_ui_audit` gate.
- Tone/title/valence authored copy for ~60 event types.

---

## OPEN -- group 1: CODING (9 + 1 retirement)

Mechanical manager wire-ups; the renderers already exist. 2-40 LOC each.
Independent parallel edits, but ALL touch `PDV__ManagerQuest.psc` (the
high-contention, snapshot-risk file) -- **serialize against any other manager
edit**. See DecidedWorklist Codex queue for line cites.

| # | Item | Site (function) | Note |
|---|------|-----------------|------|
| 1 | Rivalry-drain Ledger driver | `AwardPietyInternal` (rival-drain caller) | Pass a reason so the drain records a driver |
| 2 | Khajiit lunar-posture chronicle | Corrupted/ShadowDrift transition | Add `AppendBookOfDaysEntry`; dawn-diff structurally can't catch posture |
| 3 | Emergence.onset wire (BLOCKING) | add `GetKhajiitFocusDeity` + `GetBretonTraditionDeity` + 2 `SurfaceTransition("emergence",...)` | DIRECTION MISMATCH: gate uses `reach`, arms use `onset` -- reconcile first |
| 4 | Neglect-recovery direction | `PatronToastState` reset | Wire `SurfaceTransition("neglect",...,"recover",...)`; tone table exists, callsite missing |
| 5 | Substrate.thin branch | `SendPrismaSubstrateProgress` | Add `phase="thin"` when tier drops (all substrate races) |
| 6 | Khajiit Champion pin | Champion surface | Pass `headline=true` + tier band so the chronicle is pinned (currently prunable) |
| 7 | Orc lapse-to-City toast | route through `ApplyOrcLifeModeSwitch` | Silent lapse currently bypasses surfacing |
| 8 | New-pact Daedric toast | first Prince activation, no prior patron | `SendPrismaEventToast("shift",...)` (overlaps the Daedric-surfacing Seam-2 follow-up) |
| 9 | Altmer crisis-state toast | crisis transition | `SendPrismaShiftToast` for immediate crisis (chronicle already wired) |
| 10 | Hircine residue onset/fade toasts | `BeginNordResidueRecovery` + residue-clear branch | Renderer built, producer absent |
| 11 | Daedric boon "rite answered" toast | Daedric rite completion | `SendPrismaDaedricToast(prince,"boon",...)`; renderer built |
| R | RETIRE drift.warn dead branch | `drift` branch + its 2 tone entries | Orphan producer; pre-neglect warning already covered by neglect-drop |

(P1 = #1-3; rest P2. Item 3 is the only blocker -- the gate/arm direction
mismatch must be reconciled before its two callsites land.)

---

## OPEN -- group 2: AUTHORING beats (10) -- DESIGN/COPY then CODE

Copy is **APPROVED + LOCKED 2026-06-25** in `PDV_PrismaParity_AuthoringDraft.md`
(per-race toast + chronicle lines, tone keys, runtime name slots, and the wiring
model). No redline gate remains -- each beat is now a mechanical wire: route the
chronicle line through the new per-race `ResolveJournalLine` tone key and fire the
toast at the named site. All ASCII.

| # | Beat | Site (function) | Gap today |
|---|------|-----------------|-----------|
| 1 | Nord offer ACCEPT | `DebugAcceptPendingCommitment` | No "you have given your devotion to X" beat; also route carryover via reason-bearing `AwardPiety` |
| 2 | Nord offer REFUSE | `DebugRefusePendingCommitment` | No permanent-refusal milestone when Rupture=1 |
| 3 | Altmer Thalmor-alignment band | `ApplyAltmerAlignmentAction` | HIGHEST-severity Altmer gap: band invisible to BOTH surfaces |
| 4 | Breton tradition choice | `ApplyBretonInitialChoice` | Irreversible startup choice has ZERO immediate surface |
| 5 | Hircine werewolf-onset chronicle | `HandleCurseTransition` werewolf branch | Chronicle missing |
| 6 | Hircine renunciation chronicle | `RenouncePath` | Toast + ledger present, chronicle missing |
| 7 | Redguard sect Champion-entry | after `ShowRedguardMessage` | Per-sect (Crown/Forebear/Ash'abah) journal copy + wire |
| 8 | Argonian Hist-Adaptation milestone | `ApplyArgonianAdaptation` | Debug.Notification only today; NOT a 6f rite |
| 9 | Breton druidic-fork | `SetBretonDruidicFork` | Betrayed/Werewolf fork invisible to both surfaces |
| 10 | Bosmer path-confirmation chronicle | `ConfirmBosmerPendingTransition` | Toast + ledger wired, chronicle missing |

Leverage order (per DecidedWorklist): the Nord offer accept/refuse beats unlock
the broader "emergence" pattern, so draft those first.

---

## OPEN -- group 3: in-game PROOF (play-gated)

- **Cold-view focus-trap re-confirm.** Fix is in source (`5301ec0`,
  `g_panelFocusPending` defer). After an xmake rebuild + redeploy, open the panel
  from a cold game state and confirm ESC always releases; `DevotionPrismaBridge.log`
  clean. ~15 min. (This is the only remaining piece of the old hardening handoff.)
- **Prisma choice-panel capability** (`PDV_PrismaChoicePanel_CapabilityPlan.md`):
  Phase 0 plumbing landed in source 2026-06-19, DLL rebuilt; awaiting in-game
  `DebugPrismaChoiceGo` test. Low priority, beyond the current sprint -- pilot is
  the Argonian Hist Adaptation rite with a clean MESG fallback.

---

## DEFERRED -- V2 / out of 1.0 scope (DESIGN exploration only, no code)

From `PDV_PrismaUXEquityAudit.md` and `PDV_HO_PrismaHardening.md`:

- **Substrate-native always-on instruments** -- Khajiit Lunar Lattice, Dunmer
  Ancestors, Argonian Hist, Orc Stronghold Code, Redguard Sword-Sects. Highest
  creative-expansion potential, but needs a design handoff + a Prisma payload
  schema extension. Aspirational; NOT 1.0.
- Promoting the full panel to a player-facing default opener (stays MCM/debug).
- Player-facing MCM pass. Separate Prisma repo split. New NPC dialogue/voice (V2).

---

## Classification summary (answers "coding / building / design")

| Bucket | Count | Kind |
|--------|-------|------|
| Coding wires (manager Papyrus) | 9 + 1 retire | CODING |
| Authoring beats (copy LOCKED) | 10 | CODING -- wire the locked lines |
| In-game proof | 2 | TESTING (play-gated) |
| V2 substrate instruments | 5 races | DESIGN (deferred, not 1.0) |
| ESP / record building | 0 | -- none -- |

So for 1.0: ~20 small manager edits, all now pure wiring (the beats' copy is
locked), one 15-minute in-game focus-trap check, and zero record building.
Hardening is done and there is no open copy/redline gate.

---

## Dispatch / serialize notes

- All group-1 and group-2 wires touch `PDV__ManagerQuest.psc`. Serialize the
  whole Prisma-parity batch as ONE manager-owning lane (per
  `PDV_PrismaParity_SerializedHandoffs.md`); do not interleave with the Daedric
  surfacing / Requiem / other manager edits.
- BOTH groups can dispatch to Codex immediately. Group 2's copy is APPROVED +
  LOCKED in `PDV_PrismaParity_AuthoringDraft.md` (2026-06-25); Codex wires the
  locked toast/chronicle lines via the per-race `ResolveJournalLine` tone keys
  named there. No redline round-trip remains.
- Reconcile item 3's `reach` vs `onset` direction mismatch before wiring its two
  callsites (it is the only cross-item blocker).
- Keep all new copy PLACEHOLDER + ASCII; the `.psc` commit hook rejects non-ASCII.

## Verify (after each slice)

1. `node tools/pdv_compile.mjs --script PDV__ManagerQuest` -> 0/0.
2. `node tools/pdv_prisma_ui_audit.mjs` -> still PASS (extend the gate if a new
   contract surface is added -- toolchain edit needs sign-off).
3. `node tools/pdv_verify.mjs` -> FAIL=0.
4. `node tools/pdv_integrity_harness.mjs` -> PASS.
5. Ledger acceptance check: every new signal/award must record a driver so it
   lands in the Ledger (the standing "Ledger monitors all data points" rule).

Load-bearing FELT proof for each surfaced beat is in-game (toast fires, chronicle
entry appears, Ledger shows the driver) -- play-gated, tracked with the rest of
the in-game proof bucket.
