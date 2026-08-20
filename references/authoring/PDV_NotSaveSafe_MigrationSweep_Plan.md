# Not-save-safe migration/old-message sweep — PLAN

**Status:** LIVING · **Opened:** 2026-08-13 · **Part A pure-legacy migrations implemented
2026-08-13** (shipped in #79; e.g. `39fb7aa4`, `af7e668e`) — `MigrateDaedricPactsIfNeeded`,
`MigrateBroadPantheonPools`, `RunAuthoriaQuestReactionKeySweep`, and
`MigrateLegacyCompositeMetricOnce` are verified absent from `live-source`. **Still deferred**
the handoff. Audits/contracts reconciled to the removal on `feature/v3-big-update` 2026-08-17
(broad-pantheon + substrate-pacing audits green). · **Prereq:** the owner has committed to a
**not-save-safe** next update (fresh saves required).

**UPDATE 2026-08-18 (on `feature/v3-big-update`, post-1.5.0e-merge `65ca5c89`):** `RepairBookOfDaysJournalText`
was removed earlier (FAVOR-handoff step 1). This pass landed the rest of the static sweep:
- **AncestorSpine_T1 strip (step 2):** grant-fact resolved by *code* (the correct liveness test, not
  the two wrong ones) — `GetFirstTierRaceRewardSpellForOrigin()` returns `None` for Redguard, so the
  `SyncFirstTierRaceRewardRuntime` line only ever stripped. Removed that runtime descope line; property
  `PDV_Bless_Redguard_AncestorSpine_T1` + reward fns + uninstall teardown preserved.
- **Part B:** `ReadZeroReservedDevotionalDayStamp` legacy `.Encoding<2` branch (verified 0 other
  `.Encoding` readers; `+2` write scheme kept); `EnsureHistMaintenanceStampEncoding` legacy body
  (`PDV_Substrate_ArgonianHist`); book-read `.Seen` legacy branch (`PDV_PlayerEvents.MarkGenericBookRead`,
  verified the `PDV.P2Source.*.Seen` sibling is a different, live key).
- **Part C:** write-only `PDV.Startup.OriginHandled` (x3), `PDV.Orc.SetupComplete`,
  `PDV.Nord.SetupComplete`+`StartupReason` (all verified 0 reads). Redguard/Breton/Bosmer kept.
- **Part D (Prisma dead-path): DEFERRED** — optional; it pulls the Prisma bridge + mandatory
  `index.html` cache-key recompute into scope, out of this sweep.
- **New candidate flagged, NOT touched:** `MigrateDaedricConsentIfNeeded` (1.5.0e fn, live in V3 via the
  merge) is likely dead on a not-save-safe fresh save — needs an owner call before removal.
Proof: 3 files compile 0/0; parity vs HEAD = changed=8 (exactly the edited fns), removed=0, added=0.

> Focused follow-up to the startup-message removal (`bec76abc`, `7afd5396`). Precedence for any
> "is it done": live readback / re-run gate > `AGENTS.md` > this doc. Every anchor below is in
> `live-source/Scripts/Source/PDV__ManagerQuest.psc` unless another file is named — and the
> compile-authoritative tree is the MO2 folder, so edit canonical source, regenerate/compile,
> mirror per the source-drift rule.

## Context

Because the update no longer preserves old saves, all code that exists *only* to fix up legacy
save state is dead — a fresh save never carries the state it migrates. This sweep removes that
scaffolding. Two things make it non-trivial and worth a plan rather than a blind delete:

1. **Some "migrations" also initialize fresh-save state** — the init must stay; only the
   legacy-fixup lines go.
2. **Some version-gated code that reads like a migration is actually the load mechanism** (the
   likes/dislikes table loaders). Removing it would break fresh saves.

The owner's phrase was "remove the old **messages**." Exactly **one** migration path shows a
user-facing message; the rest are `Trace`-only. That one is the highest-value removal.

---

## Guardrail — do NOT remove (reads like migration, is not)

- `EnsureLikesDislikesTable` version gate (`:12502`, `LIKES_DISLIKES_VERSION`) and
  `EnsurePrinceLikesDislikesTable` (`:12629`, `PRINCE_LD_VERSION`) — the **fresh-save table-load**
  mechanism. Keep.
- `FRAMEWORK_SCHEMA_VERSION` stamp (`:12462-64`) — no-op stamp, nothing to remove.
- `KHAJIIT_MOON_OBSERVATIONS_VERSION` (`:822`) / `ALTMER_PRACTICE_LINES_VERSION` (`:829`) —
  external-JSON-asset content validation, not a save migration. Keep.
- `AUTHORIA_REPAIR_VERSION` / `RunAuthoriaActorValueRepair` (`:28800`) — on-demand MCM "Repair
  stats" + uninstall only; never runs on load. Keep.
- `ShouldSyncLegacyPatronBoons` (`PDV_DeityBase.psc:615` + overrides), `ClearLegacyTalosBoons`
  (`PDV_Deity_Talos.psc:108`) — runtime boon gates, run identically on fresh saves. Keep.

---

## Part A — Remove: pure legacy migrations (fresh save never needs them)

Delete the function + its call sites + (once callers are gone) its version constant.

| Item | Anchor | Calls | Notes |
|---|---|---|---|
| **`MigrateDaedricPactsIfNeeded`** | `:12641` | `:1005`, `:1112` | **★ Removes the ONLY migration user-facing messages** — the Prisma toast + Book-of-Days line at `:12685-86` ("Your devotion has resolved to …"). Retire `DAEDRIC_PACT_VERSION` (`:644`). |
| **`MigrateBroadPantheonPools`** | `:15021` | `:1006`, `:1113` | Seeds pools from legacy counters → all-zero on fresh save. Also drop the MCM debug fixture `DebugRunBroadPantheonMigrationFixture` (`:20006`). Retire `BROAD_PANTHEON_SCHEMA_VERSION` (`:675`). |
| **`RunAuthoriaQuestReactionKeySweep`** | `:2222` | `:1231` | One-time clear of leaked `PDV.QR.Job.*` co-save keys. Retire `AUTHORIA_QR_KEY_SWEEP_VERSION` (`:862`). |
| **`MigrateLegacyCompositeMetricOnce`** | `PDV_Substrate_ArgonianHist.psc:275` | manager `:1015-17` | Retire `CulturalMetricMigrationVersion`. |
| Breton `SubstrateLegacyCleared` one-shot | `:23016-19` | in `AwardBretonAncestorSpinePulse` | Enclosing handler is itself a retired no-op (candidate for the dead-code sweep too). |
| **`RepairBookOfDaysJournalText`** | `:24606` | `:999`, `:1101` | Normalizes stored journal text + prunes mis-authored Altmer beats; fresh journal is empty. |
| Khajiit obsolete hand-slot cleanup | `:8196-8204` | in `EnsureKhajiitObserveMoonsPower` | Remove inner block only; keep the surrounding grant/remove. |
| Retired Breton Tradition T1/T2 force-remove | `:17094-95` | Breton reward sync | `RemoveSpell` no-op on fresh saves. |
| Legacy "Ancestors' Regard" (`AncestorSpine_T1`) strip | `~:18587` | generic-floor loop | Verify exact lines before cutting. |

---

## Part B — Strip fixup lines, KEEP the init (init-that-also-migrates)

- **`ReadZeroReservedDevotionalDayStamp`** (`:15105-15116`) — **highest-touch (~40 call sites)**.
  Remove only the `.Encoding < 2` "+1 legacy stamp" branch (`:15108-15113`); keep the plain
  read/return. The `+2` write scheme (`WriteZeroReservedDevotionalDayStamp` `:15118`) stays live —
  many gates compare `== GetDevotionalDay()+2`. **Needs-care:** confirm no reader keys off the
  `.Encoding` sibling before dropping it.
- **`EnsureHistMaintenanceStampEncoding`** (`PDV_Substrate_ArgonianHist.psc:137`) — remove body
  `:142-147`; keep the version-stamp guard.
- **Book-read legacy branch** (`PDV_PlayerEvents.psc:2989-2993`) — remove; keep the fresh-first-read
  init (`:2994-95`).

---

## Part C — Vestigial state left by the removed startup branch (cosmetic)

Write-only after the startup-migration branch removal — safe to drop the writes (not required
for save-safety, tidy-up only):
- `PDV.Startup.OriginHandled` (`:22693`, `:22711`, `:22776`) — no reads anywhere.
- `PDV.Orc.SetupComplete` (`:22905`) — no reads.
- `PDV.Nord.SetupComplete` (`:22925`, + `StartupReason` `:22926`) — no reads.

**Keep** `Redguard.SetupComplete` (read `:28751`), `Breton.SetupComplete` (read `:22941`, `:23199`),
`Bosmer.SetupComplete` (read via `HasBosmerSetupCompleted`).

---

## Part D — Prisma UI changes (the explicit ask)

**Headline: removing the migration messages requires NO functional Prisma change.** Verified:
the Skyrim startup flow is Papyrus-only (`Debug.MessageBox` / `Message.Show`); the Prisma startup
view has **no** migration branch (`grep -i migrat|legacy|silent` over the view tree = 0 matches);
and the sole migration-related Prisma emission is a **Papyrus-side toast call**
(`SendPrismaEventToast("shift", …)` at `:12685`) that disappears when `MigrateDaedricPactsIfNeeded`
is removed — no view edit.

Prisma asset tree (repo, what the DLL packages):
`native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/{index.html, app.js, styles.css}`
(mirrored in MO2 at `…\mods\Devotion\PrismaUI\views\Devotion\`).

**Optional cleanup (recommended, but it is what pulls Prisma into scope):** there is a **dead**
Prisma startup path — `SendPrismaStartupPayload` (`:24211`, builds the `"mode":"startup"` JSON at
`:24246`) has **zero callers**, and `app.js` `renderStartup` (`~1540`) / `renderStartupDetails`
(`~1528`) consume a payload nothing feeds. If we delete the dead Papyrus emitter, we should also
delete the unfed JS path. **If and only if `app.js`/`styles.css` bytes change:**

- **Cache-key bump is mandatory.** `index.html` carries `?v=pdv-<hash>` on both `styles.css`
  (`~:9`) and `app.js` (`~:236`), and `tools/pdv_prisma_ui_audit.mjs`
  (`verifyPrismaAssetCacheContract`, `:171-190`) **FAILs** unless both equal
  `pdv-${hash16(app.js + styles.css)}`. The value is content-derived — recompute it and set both
  strings; you cannot invent one.

Decision for the executor: **either** leave the dead Prisma startup path in place (migration
removal touches only `.psc`, so **no cache-key bump, no Prisma edit at all**), **or** fold the
dead-path deletion into this sweep and do the cache-key bump. Recommend the latter for hygiene,
but it is the only reason Prisma is touched.

---

## Verification

1. **Compile**: `tools/pdv_compile.mjs` clean (0/0) after each cluster; targeted `--script` for speed.
2. **Full verify**: `tools/pdv_verify.mjs` — no VMAD/property/SEQ regressions from removed functions.
3. **Prisma gate** (only if the optional cleanup is taken): `tools/pdv_prisma_ui_audit.mjs` must
   PASS — i.e. the cache-key was recomputed to match the edited `app.js`/`styles.css`.
4. **Fresh-save smoke** (the real proof, since the point is fresh-save behavior): new game per an
   affected race — Nord (startup choice once), a Daedric-path character (no "resolved to" toast),
   Argonian (Hist metric initializes), Breton (no retired-boon flicker) — confirm no migration
   message fires and no init regressed. MCM-driven per project convention.
5. **Negative check**: the `LIKES_DISLIKES`/`PRINCE_LD` version gates still load their tables on a
   fresh save (dashboard/Ledger shows deity rows) — proof the guardrail items were left intact.

---

## Risks / needs-care (verify before cutting)

- `ReadZeroReservedDevotionalDayStamp` `.Encoding` sibling — the highest-blast-radius edit; keep
  the `+2` write scheme.
- Altmer crisis stamp `:11419-22` (`PDV.Altmer.CrisisSettledAt`) — the `settledAt<=0 → nowTime`
  write may be the only initializer for a freshly-scarred save, not just a pre-P6 migration.
  Confirm the scar-entry path writes it elsewhere first.
- `EnsureDunmerAncestralUrn` (`:25729`) / `EnsureArgonianHistSapToken` — stale-token removal is
  entangled with the fresh grant; leave unless the old BOOK records are confirmed never granted.
- Don't retire a version constant until its last reader is gone (a stale gate elsewhere would then
  read a never-set key).

## Suggested sequencing (each its own commit, gate-green)
1. Part A message-bearing removal first (`MigrateDaedricPactsIfNeeded`) — highest value, self-contained.
2. Remaining Part A pure-legacy functions + retire their constants.
3. Part B fixup-line strips (careful, `ReadZeroReserved` last).
4. Part C vestigial-write cleanup.
5. Part D optional Prisma dead-path deletion **+ cache-key bump** (only if taken).

Own branch off `main` (independent of the Daedric PR); the startup-fix commits already on the
Daedric branch can be cherry-picked alongside.
