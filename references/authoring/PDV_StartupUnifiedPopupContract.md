# PDV Startup Unified Popup Contract (V1)

## Direction

- Keep original race startup behavior (no universal god picker).
- Standardize presentation shell across races (stylized popup + side description).
- Advisory line (global): `This begins your journey; your devotion evolves through your choices.`

## Startup Modes

- `explicit_choice`: Breton, Bosmer, Redguard, Orc.
- `info_only`: Nord, Imperial, Dunmer, Altmer, Khajiit, Argonian.

## Payload Contract

- `race_id`
- `startup_mode` (`info_only | explicit_choice`)
- `options[]` (`option_id`, `title`, `summary`, `description`)
- `default_option_id`
- `advisory_line`
- `confirm_required`

## Event Names

- `startup_shown`
- `startup_confirmed` (explicit choice only)
- `startup_info_acknowledged` (info-only and migration-info path)

## Existing Save Rule

- Preserve state.
- Show one-time informational startup card.
- Do not force re-pick.
