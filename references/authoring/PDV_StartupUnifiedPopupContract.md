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

## CK Fallback Copy

- CK message records used for explicit-choice fallback:
  - `PDV_MSG_StartupBretonChoice`
  - `PDV_MSG_StartupRedguardChoice`
  - `PDV_MSG_StartupOrcChoice`
  - `PDV_MSG_StartupConfirmChoice`
- Authoring source: `tools/pdv-startup-author/Program.cs`.
- Copy should mirror the same option meaning and advisory line used by the Prisma payload.

## Runtime Boundary

- 2026-06-04 smoke found that sending the Prisma startup payload while the CK
  `Message.Show()` choice flow is still active can stack the custom
  Devotion panel over the vanilla startup MessageBox and block dismissal.
- Current runtime uses the CK MessageBox path only for startup choice/info
  acknowledgement. Re-enable Prisma startup panels only after that path can own
  input/selection without a simultaneous CK MessageBox.
