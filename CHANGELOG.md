# PlayerDevotion Changelog

Notable player- and tester-facing changes. Scripts ship from the live MO2 mod
folder; this file records what changed, not the full source.

## 2026-06-15

- **Added: "Export Devotion Report" MCM button** (Player page, no Developer
  Options required). Writes a full devotion snapshot to `PDV_DevotionReport.txt`
  in the Skyrim game folder so beta testers can attach one file to a bug report
  instead of digging for logs or numbers. The file includes mod/schema versions,
  in-game day, race, the summary/mode/patron/standing/curse/favor/neglect lines,
  the full Survey readout, and a per-deity ledger (tier + piety + scratch).
  Implemented as `PDV__ManagerQuest.ExportDevotionReport()` (writes via
  `MiscUtil.WriteToFile`) wired to the MCM handler in `PDV_MCM`. Pure script;
  no new CK records, properties, or SEQ changes. Save-safe.
- **Added: beta tester guide** (`PlayerDevotion_BetaTesterGuide.docx`) covering
  dependencies, what's in the mod, design intent, known limitations/beta status,
  and how to give useful feedback (including the Export Devotion Report flow and
  a copy/paste report template).
