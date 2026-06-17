# PDV Cleanup Debt Handoff — 2026-06-17

**Status:** Known inert debt, deliberately deferred. Pre-live final-polish is done;
none of this is functional or player-visible. Execute in a dedicated ESP-cleanup /
pre-release housekeeping pass, not mid-feature.

**Source of truth:** live `.psc` at `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`
(untracked); ESP at `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp`.

**Why deferred:** every item below is *inert* — nothing grants/calls it. Removing
records is ESP surgery with low upside this close to live, and existing beta saves
self-heal (see item 2). Verified clean: compile 0/0, verifier FAIL=0 with all of it
in place.

---

## Item 1 — Dead Papyrus: `GetStartupOptionDetailText`

- **Where:** `PDV__ManagerQuest.psc:12022` (`String Function GetStartupOptionDetailText(Int originRace, Int optionValue)`).
- **Why dead:** it built the old middle "detail" startup screen. Its only caller was
  `Debug.MessageBox(GetStartupOptionDetailText(...))` in `ConfirmStartupSelection`,
  removed when the startup flow went 2-screen (select -> per-path confirm). Grep of
  the live manager shows the definition with **zero callers**.
- **Action:** delete the whole function body. It builds text from
  `GetStartupOptionSummary` + `GetStartupOptionDescription` + `STARTUP_ADVISORY_TEXT`
  — do NOT delete those helpers (still used by the Prisma startup payload,
  `SendPrismaStartupPayload`, and the per-path confirm copy was baked from the
  descriptions).
- **Gate:** `node tools/pdv_compile.mjs --script PDV__ManagerQuest` -> 0/0, verifier FAIL=0.
- **Risk:** none (unreferenced). Lowest-hanging fruit; safe to do anytime.

---

## Item 2 — Orphaned legacy-boon records (the old "Kyne's Blessing" duplicates)

The Kyne reward-stacking fix decommissioned the Phase-4 boon system
(`PDV_DeityBase.SyncPatronBoonsToTier` now only `ClearAllBoons()` and grants
nothing). These records are no longer granted by anything.

**Orphan SPEL records (9) + their MGEFs:**
- `PDV_Blessing_Kyne_Seeker` (`03235A`), `PDV_Blessing_Kyne_Devoted` (`032360`),
  `PDV_Blessing_Kyne_Champion` (`03522D`)
- `PDV_Blessing_Talos_Seeker` / `_Devoted` / `_Champion`
- `PDV_Blessing_AuriEl_Seeker` / `_Devoted` / `_Champion`
  (Talos/Auri-El FormIDs not captured here — resolve by EditorID; the player-facing
  names are "Kyne's Blessing - Seeker", "Kyne's Blessing", etc.)

**Still-wired but never-called:** the `Boon_Seeker` / `Boon_Devoted` / `Boon_Champion`
VMAD properties on the three quests that point at the orphans:
- `PDV_Deity_Kyne` (`0120B6`), `PDV_Deity_Talos` (`03DE87`), `PDV_Deity_AuriEl` (`03DE88`).

**No `.psc` references them by name** — only those QUST props + the (now no-op)
base-class boon code, which is itself kept (see "Do NOT remove" below).

### Removal procedure (when you do it)
1. Author a small Mutagen tool (clone the pattern of `tools/pdv-stance-author` /
   `pdv-startup-author`) that, on `Devotion.esp`:
   - removes the 9 `PDV_Blessing_{Kyne,Talos,AuriEl}_{Seeker,Devoted,Champion}` SPEL
     records and their backing MGEFs (resolve by EditorID),
   - nulls `Boon_Seeker`/`Boon_Devoted`/`Boon_Champion` on the three QUSTs above.
2. **Do NOT touch the Daedric boon records or Daedric QUST `Boon_*` props** —
   `PDV_DaedricPathBase` overrides `SyncPatronBoonsToTier` and grants those for real.
3. houseCARL holds the Anvil ESP lock even with Skyrim closed — re-point to
   `D:\Wabbajack\modlists\DoD`, run the write, re-point to `D:\Wabbajack\modlists\Anvil`
   (see memory `housecarl-holds-esp-lock`).
4. `node tools/pdv_verify.mjs` -> FAIL=0; `node tools/pdv_refresh_seq.mjs --write`.

### Save-safety note
Removing a SPEL the player currently has would leave a dangling FormID in that save.
This is handled: `MigrateLegacyBoonsIfNeeded` + `ClearAllBoons` (`RemoveSpell`) strip
the baked boon from the player on next load (`OnUpdate` 10s cadence). So either
(a) ship the removal to NEW players (records never granted — fully clean), or
(b) for existing beta saves, let the migration run once before removing the records.
Lowest-risk: leave records inert until you're regenerating/cleaning the ESP anyway.

---

## Item 3 — Stale `.psc.bak_*` backups in the source dir

- `PDV__ManagerQuest.psc.bak_v2b_20260610`, `PDV__ManagerQuest.psc.bak_ld_20260609`
  in `...\Scripts\Source\`. Not compiled (wrong extension), just clutter. Delete only
  if you're sure no one wants them as manual rollback points.

---

## Do NOT remove (looks dead, isn't)

- **`PDV_DeityBase` boon code** (`ClearAllBoons` + the no-op `SyncPatronBoonsToTier`,
  `Boon_*` property declarations): required for the existing-save migration AND for
  the Daedric override that grants real pact boons.
- **`GetStartupOptionSummary` / `GetStartupOptionDescription`**: feed the Prisma
  startup payload; the per-path confirm copy was derived from the descriptions.
- **`PDV_MSG_StartupConfirmChoice`** (generic confirm): now a never-hit fallback
  (all four choice races have per-path confirms) but a cheap defensive backstop.
- The 4 unnamed INFO records in the ESP: live Phase-18 Nord status dialogue
  (memory `unnamed-info-records-are-live`) — never clean up.

---

## Recommended sequencing

1. Item 1 (dead function) — do whenever; zero risk.
2. Items 2/3 — fold into a single pre-release ESP-cleanup pass; not worth a
   standalone ESP write before live. Mark done in `PDV_FinalPolishLook_Ledger.md`.
