# PDV Session Handoff — 2026-06-15

Scope: 1.0 final-polish look pass + a run of in-game bug reports (startup copy,
Book of Days journal, D1 diegetic sound + tier dispatch, Kyne reward stacking,
Orc startup order) and one **important design-mechanic clarification** (the Kyne
"champion offer"). Live `.psc` is the untracked canonical source at
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`; repo only tracks
tools + dated snapshots. Nothing committed this session.

---

## ★ MOST IMPORTANT — The Kyne "champion offer" is the Formal Commitment Offer

Terminology correction for session start: **deities do still make formal
patron/deity offers.** The "only Daedric paths have Champion offers" claim is
only true for the extra **Champion-tier milestone / replay offer** path used by
`PDV_DaedricPathBase`. It does **not** mean Kyne, Talos, Shor, Stuhn, Tsun, or
the other formal-offer deities lack patron offers.

The user asked why a "champion offer from Kyne" didn't fire at dawn. This is a
**design-understanding** point, not a bug — capture it so it isn't re-litigated.

- For **Nord/Divine** deities there is **no separate "you reached Champion tier,
  become my champion" prompt**. That Champion-tier offer pattern exists **only for
  Daedric paths** (`PDV_DaedricPathBase` / `ShowDaedricMilestonePresentation` with
  `replayChampionOffer`, `PDV__ManagerQuest.psc:9923`).
- The Kyne "offer" the user expected is the **Formal Commitment Offer** — a god
  formally offering to take you as its **patron**. It is a **pre-patron** event,
  evaluated at dawn: `RunDawnProcessCommitmentOffers` (`:6641`) →
  `EvaluateFormalCommitmentOffer` (`:9203`). Kyne-specific entry:
  `EvaluateKyneCommitmentOffer` (`:9199`).

### Eligibility gates (ALL required) — `IsEligibleForFormalCommitmentOffer` (:9323)
1. **No active patron yet** — `EvaluateFormalCommitmentOffer` returns immediately
   if `GetPatronState() == PATRON_STATE_ACTIVE` (`:9204`). The offer *creates* the
   bond; if already committed to Kyne, it will not re-offer.
2. **Kyne piety ≥ 50** — `COMMITMENT_OFFER_THRESHOLD = 50.0` (`:441`).
3. **2+ commitment signal-days within the last 7** —
   `HasRecentCommitmentSignalDays(Kyne, 2, 7)` (`:9340`, `:9352`).
4. Nord origin + Kyne in baseline pantheon (Old Ways) +
   not on cooldown (`IsNordOfferEligibleDeity` `:9367`, `IsCommitmentOfferOnCooldown`).

### Why it didn't fire (the key trap)
- **A debug piety jump does NOT count as signals.** `ForceSetPiety` /
  `DebugForceSetPietyByIndex` write `PDV.Piety` directly and do **not** call
  `RecordCommitmentSignalDay` (which only runs when piety is *earned* through an
  act — `:1386`, `:6990`). So a debug jump gives piety ≥50 but **zero signal-days**
  → gate #3 fails → no offer, every dawn. The "earn it on 2+ different days" is
  deliberate: the offer comes from a *pattern* of recent devotion, not a spike.
- Alternatively, if the player already shows Kyne's Champion **rewards**
  (Frost Resistance / Stamina Regen are `isActive`-gated), Kyne is already the
  active patron → gate #1 fails.

### How to trigger / test it
- **Organic:** patron-less, earn Kyne piety via real acts on ≥2 different in-game
  days in a week, cross 50 → next dawn fires the offer message
  (`PDV_Msg_Nord_Kyne_Offer`, wired in `GetFormalCommitmentOfferMessage` `:9243`).
- **Debug:** there is a helper `DebugSeedCommitmentSignalDaysByIndex(kyneIndex)`
  (`:9162`). Clear patron → set Kyne piety ≥50 → seed Kyne signal-days → run a dawn.
- **OPEN OFFER (not yet done):** wiring the dev-page piety jump to also seed a
  couple of signal-days, so one debug action satisfies both gates. User was asked;
  awaiting yes/no. If yes: have `ForceSetPiety`/`DebugForceSetPietyByIndex` call
  `RecordCommitmentSignalDay` for ~2 back-dated days (or call the seed helper).

---

## Changes made this session (all live + compiled 0/0, verifier FAIL=0)

Live `.psc` edits (untracked source). `PDV__ManagerQuest`, `PDV_DeityBase`,
`PDV_DiegeticDirector`, `PDV_MCM` compiled clean; verifier PASS=3027, FAIL=0.

### 1. Breton startup flow → 2 screens, narrator voice
- `EnsureExplicitStartupChoice` (`:10756`) restructured: removed the long middle
  detail screen; decline now loops back to the selection in-place.
- `ConfirmStartupSelection` kept 2-param.
- Shared confirm box `PDV_MSG_StartupConfirmChoice` used by ALL four choice races.

### 2. Startup copy trimmed hard (user: "trim ALL messages way down")
- `STARTUP_ADVISORY_TEXT` (`:475`) cut from a 5-sentence wall to one line:
  "The gods weigh how you live, not what you pick from a menu. In time, one may
  become your own."
- All ten per-race `GetStartupCanonicalSummary` (`:11473`) cut to one tight
  sentence each. (Papyrus — already live.)
- Choice **select** boxes (Breton/Redguard/Orc) + confirm tightened in
  `tools/pdv-startup-author/Program.cs`. **Confirm restored to the fuller wording
  the user likes** ("…Walk it? / Nothing is sealed -- how you live from here shapes
  the rest.") after they said they loved it.

### 3. Orc startup button→life-mode order
- User-corrected in `Program.cs` to `City / Stronghold / Legion-Exile` so button
  index matches `ORC_LIFE_MODE_CITY=0 / STRONGHOLD=1 / LEGION_EXILE=2`. Labels are
  value-based (no double-flip). Applied to ESP earlier in the session.

### 4. D1 diegetic SOUND — fixed (PROVEN in log)
- Root cause: `PDV_SND_*` were first authored as SoundDescriptor (SNDR); a Papyrus
  `Sound` property can't hold SNDR, so they baked as `None` on the save. Tool was
  later fixed to author SoundMarker (SOUN) with new FormKeys, but VMAD props never
  re-read → stale `None` bindings, so `EmitSound`'s `if cue` was false.
- Fix (`PDV_DiegeticDirector.psc`): `RebindSounds()` re-resolves the 5 markers via
  `Game.GetFormFromFile(0x0007149B..F, "Devotion.esp")` when a binding is `None`;
  called from `OnLoad` and lazily in `EmitSound`. Added a `TraceDispatch` EmitSound
  trace. **Log confirms working:** `[PDV] EmitSound tone dread played cue [Sound <
  (2607149D)>]`.
- Diagnostic added: `tools/pdv-diegetic-author/Program.cs --dump-sound` (reports
  record type + descriptor + director property wiring).

### 5. D1 tier dispatch on Champion — fixed
- Root cause #1: the active-patron tier branch (`RecomputeTier` `:5501`) only sent
  the Prisma toast; the `SurfaceTransition("tier"...)` call existed ONLY in the
  Khajiit/no-offer branch (`:5513`) and Khajiit reward path (`:8000`). Added it to
  the active-deity branch.
- Root cause #2 (why the user's debug test never surfaced): the dev-page piety
  setters called `RecomputeTier(..., False)` — `surfaceTierUp=False` suppresses the
  WHOLE tier-up surface (toast + D1). Flipped `ForceSetPiety` (`:6754`) and
  `DebugForceSetPietyByIndex` (`:6791`) to `True`. Real players reach Champion via
  `ProcessDawn` (`surfaceTierUp=True`), so they always got it; only the debug jump
  was silent.
- NOTE: `SurfaceTransition` self-guards once per `event.surfaceKey.direction`
  (`:1519`) and `NotifyTierUp` is a one-shot per (deity,tier) (`:5528`) — so a tier
  surfaces ONCE per game. Re-test in a fresh game.

### 6. Kyne reward stacking + bare "Kyne's Blessing +15/+25" — fixed
- Root cause: TWO parallel reward systems. The correct per-tier family
  (`SyncNordRewardFamily` `:7911`) AND a legacy Phase-4 cumulative "Boon" system in
  `PDV_DeityBase.SyncPatronBoonsToTier` still wired on Kyne/Talos/Auri-El QUSTs to
  orphan `PDV_Blessing_Kyne_*` records. The legacy boons WERE the bare-description
  duplicates.
- Fix A (`PDV_DeityBase.psc:332`): `SyncPatronBoonsToTier` now only `ClearAllBoons()`
  and grants nothing. Daedric unaffected (`PDV_DaedricPathBase` overrides it `:113`).
- Fix B (migration): `MigrateLegacyBoonsIfNeeded()` added to the `OnUpdate` 10s
  cadence (alongside `MigrateDaedricPactsIfNeeded`); one-time, re-syncs the active
  deity's boons so existing saves self-clean ~10s after load without a tier change.

---

## Book of Days journal — BACKLOGGED (user's call: design pass)
- The parchment/aged-book restyle IS in the live files (verified: only one
  `PrismaUI/views/Devotion/` exists in the whole Anvil tree; my `#pdv-journal-modal`
  parchment CSS + the "Press your Book of Days key again to close" hint are present;
  app.js `journalClose` handler added; synced to repo mirror
  `native/DevotionPrismaBridge/mod/...`).
- Why it still looks old in-game: **PrismaUI loads a view once per process and
  caches it** (`PDV_PrismaBridge.OpenDevotionPanel` doc: "Creates the Prisma view if
  needed…"). A save reload does NOT refresh it — needs a **full Skyrim restart**.
- User chose to leave it in the backlog and handle look in their design pass.

---

## Current state: live vs pending

LIVE NOW (compiled / written): all `.psc` fixes (#1,#2 Papyrus, #4,#5,#6),
the Orc ESP order, the loved confirm box (in ESP from an earlier write).

PENDING ESP WRITE (blocked — Skyrim was running, holds `Devotion.esp` lock):
- The trimmed **select** boxes (Breton/Redguard/Orc first screen) are staged in
  `tools/pdv-startup-author/Program.cs` but not yet written. Run
  `dotnet run --project tools/pdv-startup-author` once Skyrim is fully closed; it
  also (re)writes the loved confirm + corrected Orc order (idempotent, backs up).
- Verify after: `rg -a -c "starts with a declared" Devotion.esp` → 0.

NOT COMMITTED: tracked changes are `tools/pdv-startup-author/Program.cs`,
`tools/pdv-diegetic-author/Program.cs`, and the `native/.../PrismaUI` mirror.
The substantive `.psc` logic lives only on `D:\` (untracked by design).

---

## Gotchas / lessons (reusable)
- **Full restart, not save reload.** PrismaUI views are cached per process;
  Papyrus `.pex` can also stick in the VM across reloads. Test fixes after a clean
  Skyrim restart or you chase ghosts.
- **ESP writes need Skyrim closed.** "used by another process" on the author tool =
  the game (or xEdit) holds the lock. Check `Get-Process SkyrimSE`.
- **Debug piety jump ≠ earned piety.** It skips `RecordCommitmentSignalDay` and (was)
  `surfaceTierUp=False` — so it neither records commitment signals nor (previously)
  surfaced tier-ups. Both relevant to testing offers and D1.
- **VMAD property bake.** Re-authoring records with NEW FormKeys orphans baked
  bindings on existing saves; needs a runtime rebind/migration (see #4 RebindSounds,
  #6 MigrateLegacyBoonsIfNeeded).
- **D1 surfaces are one-shot per game** (`SurfaceTransition` guard + `NotifyTierUp`).

---

## Verification
- `node tools/pdv_compile.mjs --script <name>` → 0/0 (manager, DeityBase, director, MCM all green).
- `node tools/pdv_verify.mjs` → FAIL=0, PASS=3027 (WARN=4 expected: 4 unnamed Phase-18 Nord INFOs).
- `node tools/pdv_prisma_ui_audit.mjs` → 13/13.
- Papyrus log: `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Suggested next steps
1. Close Skyrim → write the staged select-box trims to the ESP (one tool run).
2. Decide on the optional dev-page "seed signal-days on piety jump" helper (offer the user made).
3. Full-restart test pass: parchment journal, Champion D1 (fresh game), Kyne boon self-clean, trimmed startup copy.
4. Scoped commit when the user approves (Breton/startup trims, sound rebind, Kyne boon strip, D1 tier+debug surface, Orc order).
5. Bosmer first-screen select still uses an older record — trim to match if the user wants.
