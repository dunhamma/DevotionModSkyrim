# Table Conventions

CSV files in this folder are compact reference indexes, not exhaustive wiki mirrors.

## Required Habits

1. Keep one row per stable concept.
2. Include a `source_id` column when the row depends on an external or local source.
3. Use source IDs from `../sources.yaml` where possible.
4. Use `pdv_use` or `pdv_implication` to explain why the row matters to PlayerDevotion.
5. Use `needs_validation` when a row is plausible but not yet verified from local game data.
6. Prefer `EditorID` and `source_plugin` columns for extracted records.
7. Do not hand-copy long wiki tables. Add enough rows to guide design, then expand by extraction or focused verification.

## CSV Encoding

- UTF-8, ASCII text content preferred.
- Comma-separated with a header row.
- Quote fields that contain commas.
- Use `none`, `unknown`, or `todo` instead of blank cells when absence is meaningful.

## Suggested Columns By Table Type

| Table type | Suggested columns |
|---|---|
| CK records | `editor_id,form_id,signature,source_plugin,category,pdv_use,source_id,notes` |
| Gameplay mechanics | `mechanic,vanilla_behavior,pdv_use,caution,source_id` |
| UX findings | `theme,evidence,pdv_rule,risk_if_ignored,source_id` |
| Crosswalks | `pdv_signal,vanilla_surface,capture_pattern,scoring_use,anti_farm_rule,source_id,status` |

## Validation States

| State | Meaning |
|---|---|
| `source-backed` | Verified from UESP, CK Wiki, official documentation, or a named mod page/community source. |
| `local-data-backed` | Verified from local master/plugin data or live PDV source. |
| `design-inference` | Reasoned from source-backed facts, but not itself a direct source claim. |
| `needs-local-extraction` | Should be expanded from local plugin data before implementation. |
| `needs-runtime-test` | Needs in-game verification before being treated as behaviorally proven. |
