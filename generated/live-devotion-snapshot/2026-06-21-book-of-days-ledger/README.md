# 2026-06-21 Book of Days: Ledger page + live-refresh + broad-Nord fixes

POST-edit snapshot of the live untracked manager + MCM after the follow-on fixes to
the Book of Days work (the canonical .psc lives in the untracked live dir; this
preserves the Papyrus backend in git alongside the tracked UI files).

Adds since the 2026-06-21-book-of-days snapshot:
- BROAD-NORD TIER FIX: tier reaches now surface (notice + toast + Book of Days entry)
  for EVERY god regardless of patron state -- a patron-less pantheon Nord previously
  matched neither the active-patron nor Khajiit-emphasis branch and journaled nothing.
- NAMED DAWN DIGEST: RunDawnConsolidateScratch records the day's fed gods into
  PDV.BookOfDays.TodayFed; BuildBookOfDaysDigestLine names them ("...Kyne, Shor and
  Talos heard you...").
- DEBUG-SURFACE: DebugForceSetPietyByIndex now recomputes with surfaceTierUp=True so a
  debug-forced tier reach is testable (only on an up-crossing).
- LEDGER PAGE: BuildJournalPayloadJson takes a page param and ships both the entries
  and the dashboard payload; SendPrismaJournalPayload(playerRequested, page). The Book
  of Days hotkey (PDV_MCM.psc OnKeyDown) now CYCLES closed -> Chronicle (page 0) ->
  Ledger (page 1) -> closed, since a non-focused overlay cannot take an in-view click.
  The Ledger is the read-only "what feeds your gods" (per-god state + recent drivers).
- LIVE-REFRESH: AppendBookOfDaysEntry re-pushes the open book so new entries appear
  live without reopening.

Capstone logging (added in this snapshot):
- PDV_T3DailyLowHealthSaveEffect.ShowCapstoneNotice now appends a Book of Days entry
  (tone substrate.act) when the low-health save fires. Written DIRECTLY to the global
  journal ring (no manager reference / MGEF property wiring needed); manager prunes it
  at dawn / next append. Does not live-refresh an open book (fires mid-combat).

Deferred / next:
- Interactive filtered dashboard in a focused panel (the Today-tab dashboard + filters
  exist in app.js but the panel has no open/close door yet).

Gates at capture: manager + MCM compile 0/0, pdv_prisma_ui_audit PASS (13). (pdv_verify
shows 14 unrelated FAILs from Codex's in-progress shrine-blessing override work, not this.)

Captured files:
- D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc
- D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc
