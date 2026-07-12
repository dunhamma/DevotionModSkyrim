# Handoff: Prisma JSON escaping audit findings (2026-07-12)

Origin: read-only escaping audit run during the PrismaUI 1.0 cleanup pass
(commits 13bf39c..9962d4c). No manager edits were made in that pass; the items
below are for a scoped follow-up in `live-source/Scripts/Source/PDV__ManagerQuest.psc`.

## Finding 1 - LIVE BUG: panel `summary` embeds raw newlines (HIGH)

- `SendPanelPayload` (~line 2838) builds
  `",\"summary\":\"" + JsonSafeString(GetSurveyDevotionText()) + "\""`
  and sends it via `PDV_PrismaBridge.SendJson` (~2863).
- `GetSurveyDevotionText()` (~20773) is the MessageBox/Survey builder and embeds
  literal `\n` / `\n\n`:
  - `AppendRecentDevotionEvents` ~20851 + `GetRecentDevotionEventsText` ~20841
    (fires whenever `PDV.RecentDevotionEvents` has >=1 entry - routine in play)
  - Nord scar branch ~20814
  - Khajiit lunar posture ~21274
- `JsonSafeString` (~22740) only replaces `"` and `\` with `'`; it passes
  control characters through. JSON forbids literal newlines inside string
  literals, so `JSON.parse` in app.js throws and the ENTIRE panel payload is
  rejected (app.js shows "Bad JSON" status), not just the summary field.
- Fix options (pick one):
  a. Extend `JsonSafeString` to also replace `\n`/`\r`/`\t` (and ideally all
     U+0000-U+001F) with a space or `' / '` separator. Simplest; lossy like the
     existing quote handling, consistent with its design.
  b. Give the panel a single-line summary builder instead of reusing the
     MessageBox text verbatim.
  Option (a) also permanently closes Finding 2.
- Proof: open the focused panel after any piety-moving act (recent-events list
  non-empty) and confirm the Today/summary panel renders instead of "Bad JSON".
  Per project rules, wire the repro to the debug MCM page, not cqf.

## Finding 2 - LATENT: JsonSafeString omits control characters (LOW)

Every dynamic string in every JSON builder IS routed through `JsonSafeString`
(coverage verified complete - no raw dynamic string insertions exist), so
quote/backslash breakage is impossible today. But any future copy string with
`\n` routed into a journal/toast/panel field breaks the same way as Finding 1.
Fixing `JsonSafeString` per option (a) above closes this class.

## Finding 3 - NOTE: PanelEventObject raw `amount` (NEGLIGIBLE)

`PanelEventObject` (~3467) inserts `amount` unquoted. It is always numeric
today (`"" + today`, ~3245). No action needed; just do not route free text in.

## Explicitly ruled out

- Third-party display names (GetName/GetDisplayName from quests, locations,
  books) are NEVER interpolated into Prisma JSON - the hypothesized external
  mod-content risk does not exist in this script.
- Journal builder (~19468) pre-escapes all fields into locals; startup and
  choice payloads are hardcoded or single-line. Safe as-is.

## Related bridge change (already shipped, FYI)

`native/DevotionPrismaBridge/src/main.cpp` (commit 9962d4c) now parses overlay
routing (`mode`/`journal`/`journalClose`) from root-level JSON fields instead
of substring sniffing, guards all bridge state with a recursive mutex, and uses
std::from_chars for choice-index parsing. Papyrus/JS contract unchanged; the
rebuilt DLL is deployed to the Anvil MO2 Devotion mod. In-game smoke for the
panel/journal/choice/toast paths is still pending (user-driven).
