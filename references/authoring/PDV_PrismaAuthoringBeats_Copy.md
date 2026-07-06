# PDV Prisma Authoring Beats -- Writing Pass Output

> NON-AUTHORITATIVE for beats 1-3: use `PDV_PrismaParity_AuthoringDraft.md` (LOCKED 2026-06-25) for offer accept/refuse and Altmer alignment copy.

**Owner:** Claude writing pass (copy only)
**Created:** 2026-06-30
**Status:** OWNER-APPROVED 2026-06-30. Copy is locked; ready for Codex wire. Handoff:
`references/authoring/PDV_HO_PrismaBeats_CodexWire_2026-06-30.md`. Beat #5 deferred to V2
(`references/authoring/PDV_V2_Backlog.md` section 5).
**Scope source:** `references/authoring/PDV_HO_PrismaToOneOh_2026-06-30.md` group 2 (10 authoring beats)
+ `references/authoring/PDV_PrismaParity_DecidedWorklist.md` authoring queue.
**Voice anchor:** `references/authoring/PDV_FormalOfferWriting_Copy.md` (mythic, second-person,
deed-read god-voice, ASCII-only with `--` and `...`).

This is the human-readable review table. After redline, the approved strings + the per-beat
call-site list go to Codex for the mechanical wire (Codex owns coding; Claude + owner own copy).

---

## IMPORTANT -- scope correction (verified against live-source)

The handoff lists 10 beats as gaps. Re-grepping the **live** source
(`live-source\Scripts\Source\PDV__ManagerQuest.psc` + `PDV_DaedricPath_Hircine.psc` +
`PDV_DiegeticDirector.psc`) shows **6 of the 10 already have finished copy wired** (toast +
chronicle, with real string literals). The handoff's group-2 table appears to have been carried
from the 2026-06-25 worklist without re-verifying each line -- the handoff itself warns
"trust function names, re-grep." This pass therefore splits into **genuine gaps** (new copy) and
a **polish pass** (review of already-shipped copy) per owner ruling.

| Beat | Handoff claim | Verified live-source state | This pass |
|---|---|---|---|
| 1. Nord offer ACCEPT | no beat | **GENUINE GAP** -- `DebugAcceptPendingCommitment` emits nothing | NEW toast + wire existing chronicle |
| 2. Nord offer REFUSE | no milestone | **WIRED** -- direct refusal toast + `SurfaceTransition("offer","refuse",headline,silent=True)` pinned BoD; no director wash/sound | confirm toast + no wash/sound |
| 3. Altmer Thalmor band | invisible to both | **WIRED** -- `MaybeSurfaceAltmerAlignmentBandChange`: toast + reorientation chronicle | polish (optional) |
| 4. Breton tradition | zero surface | **WIRED** -- toast + pinned BoD + emergence transition | accept-as-is |
| 5. Hircine werewolf-onset | chronicle missing | **SURFACED-GENERIC** -- curse seam fires toast + pinned BoD, but chronicle uses the GENERIC line | **DEFERRED to V2** (do all races or none) |
| 6. Hircine renunciation | chronicle missing | **GENUINE GAP** -- `RenouncePath` shows only a modal; residue toast surfaces later, no chronicle | NEW chronicle line (+ optional toast) |
| 7. Redguard sect Champion-entry | chronicle absent | **MOSTLY WIRED** -- per-sect chronicle + modal exist; no Prisma toast on modal path | NEW optional per-sect toast |
| 8. Argonian Hist-Adaptation | Debug.Notification only | **WIRED** -- toast + pinned BoD | accept-as-is |
| 9. Breton druidic-fork | invisible to both | **WIRED** -- toast + chronicle (Werewolf + Betrayed) | accept-as-is |
| 10. Bosmer path-confirm | chronicle absent | **WIRED** -- toast + chronicle | accept-as-is |

**Net authoring work:** ~3 genuine new-copy items (#1 toast, #5 bespoke chronicle, #6 chronicle),
1 optional minor (#7 toast), and a light polish review of the rest.

---

## FLAG FOR CODEX -- live-source vs deployed drift (per owner)

The handoff (dated today) lists shipped surfaces as gaps. Two possible causes:
1. The handoff table is stale (copied from the 06-25 worklist; not re-verified). OR
2. `live-source` is **ahead of the deployed/MO2 build** -- the documented split-toolchain drift
   (`tools/pdv_compile.mjs` reads the MO2 copy; the `.mjs` audits read git-tracked live-source).

**Codex action:** before wiring the genuine gaps, confirm whether beats #2/#3/#4/#8/#9/#10 are
present in the **deployed** `Scripts\Source\PDV__ManagerQuest.psc` (MO2 copy), not just
`live-source`. If live-source is ahead, the remaining work for those six is a *sync/deploy*, not
authoring. The copy in this doc is the authoring source of truth either way.

---

## Voice reference (for redline)

- Second-person, present/perfect tense, deed-read. The deity or the world reacts to what the
  player did; copy rarely narrates the player's feelings.
- Toasts = a short prominent line (the `shiftMode`/headline) + an optional one-line `context`.
  Keep both compact for a Skyrim overlay (headline <= ~48 chars, context <= ~70).
- Chronicle (Book of Days) = one bespoke sentence (occasionally two). The tone key auto-supplies
  the title + valence/color; do not bake a title into the line.
- ASCII only. Use `--` for em dash, `...` for ellipsis, straight quotes. The `.psc` commit hook
  rejects non-ASCII.
- Use the in-game labels the player already sees: Knight's Road / Hidden Art / Green Way (Breton
  tradition); Druidic / Werewolf / Betrayed (druidic fork); Crown / Forebear / Ash'abah (Redguard
  sect); the deity's public display name for patrons.

Tone keys already defined (`JournalToneToTitle` / `JournalToneToValence`), with the title + color
they render:

| tone key | title | valence | use |
|---|---|---|---|
| `offer.accept` | "Patron accepted" | good | #1 |
| `offer.refuse` | "Offer refused" | warning | #2 |
| `curse.onset` | "A shadow falls" | warning | #5 |
| `reorientation` | "A turning" | neutral | #6, #7 |
| `tier.reach` | "Favor deepened" | good | -- |

---

# GENUINE GAPS (new copy)

## Beat 1 -- Nord offer ACCEPT  [P1]

- **Surface:** toast (new) + pinned chronicle (line exists, not yet called).
- **Call-site:** `DebugAcceptPendingCommitment()` -- `PDV__ManagerQuest.psc:13350`.
- **Gap:** the function assigns the patron, awards reason-bearing carryover, and clears the
  pending offer, but surfaces **nothing**. (Carryover already routes through
  `AwardPiety(pendingDeity, carryAmount, "commitment_carryover")` -- the worklist's "route via
  reason-bearing award" sub-item is already done.) This is the asymmetry with REFUSE, which is
  surfaced via `DispatchDiegeticCue`.
- **Existing chronicle line (reuse, Nord branch):** `BuildCommitmentOfferAcceptJournalLine()` ->
  `"The broad faith narrows to one; <Patron> has named you their own."` (race-aware; Dunmer/Altmer/
  Redguard branches already exist). No new chronicle copy needed -- it just needs to be emitted.

**PROPOSED new toast (PLACEHOLDER):**

| field | value |
|---|---|
| headline (`shiftMode`) | `You have given your devotion to <Patron>.` |
| context | `<Patron> takes you as their own.` |
| symbol | deity symbol (`GetPrismaSymbolForDeity(pendingDeity)`) |

- **Chronicle:** tone `offer.accept`, title "Patron accepted", valence good, **pinned=true**,
  magnitude 3, line = `BuildCommitmentOfferAcceptJournalLine(pendingDeity.DeityIndex)`.
- **Codex wire note:** cleanest is to mirror REFUSE -- add
  `DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")`
  after `SetActiveDeity(pendingDeity)` (this fires `SurfaceTransition("offer","accept",headline)`,
  which already appends the pinned accept chronicle line + the director cue). Add the explicit
  toast above so the accept is as visible as the worklist intends. Confirm whether the director
  cue alone already shows a toast; if it does, the explicit toast is belt-and-suspenders.

---

## Beat 6 -- Hircine renunciation chronicle  [P1]

- **Surface:** chronicle (new). A residue-recovery toast already surfaces afterward.
- **Call-site:** `RenouncePath(reason)` -- `PDV_DaedricPath_Hircine.psc:114`.
- **Gap:** renunciation resets piety, begins residue recovery, sets the `Renounced` flag, and
  shows the `Msg_Exit` modal -- but writes **no Book of Days entry**. (A
  `SendPrismaDaedricToast("Hircine","residue",...)` fires later from the manager's residue drain,
  so a toast is present; the chronicle is the gap.)
- **Note:** renunciation is NOT a curse-state transition, so it does not pass through the curse
  seam that chronicles werewolf onset/cure. The entry must be added directly in `RenouncePath`.

**PROPOSED new chronicle (PLACEHOLDER):**

> `You set the hunt down. The pact with Hircine is renounced -- the beast's mark fades slowly, but the road back is yours to walk.`

- tone `reorientation` (title "A turning", valence neutral), **headlinePinned=true**, magnitude 3,
  symbol `hircine`.
- **Companion toast (APPROVED 2026-06-30)** -- distinct from the residue toast, fired at the
  moment of renunciation: headline `You renounce the hunt.` / context `Hircine's pact is set down.`
  / symbol `hircine`.
- **Codex wire note:** add `AppendBookOfDaysEntry(<line>, Utility.GetCurrentGameTime() as Int,
  "reorientation", "hircine", True, 3)` after `ShowIfPresent(Msg_Exit)` in `RenouncePath`. If the
  optional toast is approved, route it through the manager (the Hircine path script should not own
  Prisma toast calls directly -- mirror how onset toasts are emitted from the manager seam).

---

## Beat 5 -- Hircine / Nord werewolf-onset bespoke chronicle  [DEFERRED to V2]

> **OWNER RULING 2026-06-30:** Defer. A bespoke werewolf-onset chronicle line should be authored
> for **every race, not just Nord** -- doing Nord alone is inequitable. That requires threading the
> curse type into `ResolveJournalLine` (see caveat below) plus a per-race line set. Keep the
> generic line for 1.0. Filed in `references/authoring/PDV_V2_Backlog.md` section 5. The analysis
> below is retained as the V2 starting point.


- **Surface:** chronicle line ALREADY fires (pinned) -- but with the GENERIC fallback.
- **Call-site:** centralized curse seam -- `HandleCurseStateTransition()`
  (`PDV__ManagerQuest.psc:13714`) calls `SendPrismaCurseToast` (toast) +
  `SurfaceCurseTransitionDiegetic` -> `SurfaceTransition("curse","werewolf","onset")`
  (`:13728`), which appends a pinned BoD entry.
- **What is already good (keep):** the Nord werewolf-onset toast context is in-voice --
  `GetCurseContextForRace`: `"The hunt pulls against Sovngarde."` (`:13855`).
- **The gap:** the chronicle BoD line for a Nord werewolf resolves via
  `DiegeticDirector.ResolveJournalLine(deityIndex=-1, "curse.onset")`, which dispatches by origin
  race only and has **no Nord curse arm**, so it falls to the generic
  `"A curse changes the shape of devotion."` Khajiit/Dunmer/Imperial/Altmer have bespoke curse
  lines; Nord does not.

**PROPOSED bespoke chronicle (PLACEHOLDER) -- Nord werewolf onset:**

> `The beast-shape takes you. The hunt pulls against Sovngarde, and your devotion bends toward Hircine's pull.`

- tone `curse.onset` (title "A shadow falls", valence warning), pinned (curse class auto-pins).
- **WIRING CAVEAT for Codex (important):** `ResolveJournalLine` currently receives only
  `(deityIndex, toneKey)` and the curse seam passes `deityIndex=-1` -- so it knows the race and
  "curse.onset" but **not** the curse *type* (werewolf vs vampire). A Nord-specific `curse.onset`
  arm added today would also fire for Nord *vampire* onset. To make this werewolf-specific,
  either (a) thread the curse type into the resolver (preferred), or (b) author one Nord
  `curse.onset` line that reads correctly for *both* beast and blood (harder), or (c) keep this as
  a polish item until the resolver carries curse type. Recommend (a). Until then, the GENERIC line
  is acceptable, so this beat is the lowest-urgency of the three gaps.

**Also flagged (separate, broader item -- NOT this beat):** the curse *toast* title/message in
`SendPrismaCurseToast` are explicitly marked `PLACEHOLDER copy` (`:13808`): e.g.
`"Lycanthropy takes hold"` / `"Lycanthropy has taken root in your blood."` These render for ALL
races and curse types, so finalizing them is a standalone curse-toast copy pass, not part of the
Hircine beat. Logged here so it is not lost.

---

## Beat 7 -- Redguard sect Champion-entry toast  [APPROVED 2026-06-30]

- **Surface:** per-sect chronicle ALREADY fires + a modal shows. Gap = no Prisma **toast** on the
  modal path.
- **Call-site:** `MaybeShowRedguardChampionEntry(sectValue)` (`PDV__ManagerQuest.psc:7157`); each
  sect branch calls `ShowRedguardMessage(<msg>, <fallback>, False)` then `AppendBookOfDaysEntry`.
  `ShowRedguardMessage` (`:14841`) only emits a toast when `suppressModal=true`.
- **Existing chronicle lines (keep -- strong):**
  - Crown: `"The Crown way is more than memory in you now. It has become a public shape of your devotion."`
  - Forebear: `"The Forebear way is more than adaptation in you now. It has become a public shape of your devotion."`
  - Ash'abah: `"The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion."`

**PROPOSED per-sect toast (PLACEHOLDER), symbol `sect`:**

| sect | headline (`shiftMode`) | context |
|---|---|---|
| Crown | `The Crown way, made public.` | `More than memory now -- a public shape of your devotion.` |
| Forebear | `The Forebear way, made public.` | `More than adaptation now -- a public shape of your devotion.` |
| Ash'abah | `The Ash'abah duty, made public.` | `More than necessity now -- a public shape of your devotion.` |

- **Codex wire note:** add a `SendPrismaShiftToast(<headline>, <context>, "sect")` in each sect
  branch of `MaybeShowRedguardChampionEntry` alongside the existing `AppendBookOfDaysEntry`.
  APPROVED -- include in the wire.

---

# POLISH PASS (already-shipped copy -- review only)

These are already wired with finished copy. Recommendation per item; owner accepts or redlines.
Default is **accept-as-is** unless a clear win is noted.

## Beat 2 -- Nord offer REFUSE  [WIRED]

- **Call-site:** `DebugRefusePendingCommitment()` -> direct refusal toast plus
  `SurfaceTransition("offer","refuse",headline=true,silent=True)` = **pinned** BoD with no
  director wash/sound.
- **Current chronicle (Nord branch):** `"The broad faith stays whole; you turned <Patron> away,
  and <Patron> will not ask again."` -- strong, permanent-door-closing voice. **Accept-as-is.**
- **Confirm (Codex, not copy):** visible refusal toast + pinned Chronicle entry; no screen wash,
  no D1 sound.

## Beat 3 -- Altmer Thalmor-alignment band  [WIRED]

- **Call-site:** `MaybeSurfaceAltmerAlignmentBandChange()` (`:7519`), reached from
  `ApplyAltmerAlignmentAction` (`:7499`). Fires on **committed** band change (lock-in grace, so it
  lags the raw value -- by design).
- **Current toast:** `"The Thalmor question turns in you: <band>."` -- good. **Accept-as-is.**
- **Current chronicle:** `BuildReorientationJournalLine` -> `"Your soul records where you stand in
  the Thalmor question: <band>."`
  - **APPROVED REWORD 2026-06-30:** replace with `"Where you stand in the Thalmor question shifts:
    <band>."` (drops the clinical "Your soul records"). Codex: update the Altmer branch of
    `BuildReorientationJournalLine` (`PDV__ManagerQuest.psc:2031`).

## Beat 4 -- Breton tradition choice  [WIRED]

- **Call-site:** `ApplyBretonInitialChoice()` (`:15111`) -- toast + pinned BoD + emergence
  transition; runs inside race-setup quiet presentation, so brevity is correct.
- **Current toast:** `"You set your tradition: <Knight's Road|Hidden Art|Green Way>."`
- **Current chronicle:** `"You've chosen your road: <tradition>."`
- **Accept-as-is.** (Both are deliberately terse for the startup beat; the irreversibility reads
  through the pinned, magnitude-3 entry, not extra words.)

## Beat 8 -- Argonian Hist-Adaptation  [WIRED]

- **Call-site:** `ApplyArgonianAdaptation()` (`:4215`).
- **Current toast:** `"The Hist has reshaped you."` **Current chronicle:** `"You took the Hist's
  adaptation into your body. The change is permanent -- the root has answered, and you are remade
  in its image."`
- **Accept-as-is.** Strong, in-voice; the "remade in its image" close lands the milestone.

## Beat 9 -- Breton druidic-fork  [WIRED]

- **Call-site:** `SurfaceBretonDruidicForkChange()` (`:10936`), from `SetBretonDruidicFork`.
- **Werewolf:** toast `"The Green Way turns wild in you."` / chronicle `"The beast-blood took your
  Green Way down a wilder road. The Werewolf path is yours now."`
- **Betrayed:** toast `"You broke faith with the Green."` / chronicle `"You turned from the Green
  Way's trust. The path remembers the betrayal."`
- **Accept-as-is.** Both meaningful forks (R4) are covered with distinct, on-theology voice.

## Beat 10 -- Bosmer path-confirmation  [WIRED]

- **Call-site:** `ConfirmBosmerPendingTransition()` (`:17337`).
- **Current toast:** `<path label>` (e.g. The Living Story / Exchange / Bandit Road).
- **Current chronicle:** `"Y'ffre's song settles within you. Your road through the Green is the
  <path label>."`
- **Accept-as-is.** (Codex note: no `SurfaceTransition` reorientation call here; structurally
  optional, copy is complete either way.)

---

## Conformance summary

| Check | Result |
|---|---|
| All NEW copy ASCII-clean (no char > 127; `--`, `...`, straight quotes) | Pass |
| Toast headlines compact (<= ~48 chars) | Pass |
| Chronicle lines 1-2 sentences, no baked-in title | Pass |
| Uses shipped in-game labels (tradition / sect / fork / patron names) | Pass |
| No internal mechanism names (PDV_, route ids, tone-bucket jargon) in player text | Pass |
| No tester/proof-ledger vocabulary in player text | Pass |

---

## Codex handoff queue (after owner approval)

All wires touch `PDV__ManagerQuest.psc` / `PDV_DaedricPath_Hircine.psc` / `PDV_DiegeticDirector.psc`
-- serialize as ONE manager-owning lane per `PDV_PrismaParity_SerializedHandoffs.md`; do not
interleave with other manager edits.

0. **(Pre-step) Drift check:** confirm beats #2/#3/#4/#8/#9/#10 exist in the **deployed** MO2 copy,
   not only live-source. If live-source is ahead, sync/deploy them (no authoring needed).
1. **[P1] Beat 1 Nord ACCEPT** -- `DebugAcceptPendingCommitment` (`:13350`): add the accept toast
   + `DispatchDiegeticCue("offer", name, "accept", deity, "revelation")` to emit the existing
   pinned accept chronicle.
2. **[P1] Beat 6 Hircine renunciation** -- `RenouncePath` (`PDV_DaedricPath_Hircine.psc:114`): add
   the reorientation chronicle entry + the approved renunciation toast (routed via the manager seam).
3. **[P1] Beat 7 Redguard champion toast** -- add per-sect `SendPrismaShiftToast` in
   `MaybeShowRedguardChampionEntry`.
4. **[polish] Beat 3 Altmer chronicle reword** -- update the Altmer branch of
   `BuildReorientationJournalLine` (`:2031`).
5. **[polish] Beat 2 Nord refuse toast** -- explicit refusal toast is required; director cue stays silent.
6. **[DEFERRED to V2] Beat 5 werewolf-onset bespoke line** -- per-race, needs curse-type threading.
   See `PDV_V2_Backlog.md` section 5. Do NOT wire for 1.0.

## Verify (after each slice -- from the handoff)

1. `node tools/pdv_compile.mjs --script PDV__ManagerQuest` -> 0/0.
2. `node tools/pdv_prisma_ui_audit.mjs` -> still PASS.
3. `node tools/pdv_verify.mjs` -> FAIL=0.
4. Ledger acceptance: every new surfaced beat must record a driver so it lands in the Ledger.
5. Load-bearing FELT proof is in-game (toast fires, chronicle entry appears, Ledger shows the
   driver) -- play-gated.
