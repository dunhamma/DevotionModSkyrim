# PDV Formal Deity Offer Writing Handoff

**Owner:** Claude writing pass only
**Status:** Ready for copy review/conformance
**Implementation anchor:** `references/authoring/PDV_FormalOffer_RecordWave.spec.json`

## Scope

Claude owns the player-facing copy for formal deity offer messages and their response-copy mirrors. Claude does not author ESP records, edit Papyrus, change eligibility, add gods, or change race design.

Offer races in this packet:

| Race | Offer deities | Notes |
|---|---|---|
| Nord | Kyne, Shor, Tsun, Stuhn, Akatosh, Mara, Arkay, Stendarr, Zenithar, Julianos, Dibella, Talos, Kynareth | Existing live copy. Audit only unless a concrete voice defect is found. |
| Imperial | Akatosh, Talos, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella | Talos is Concordat-gated. Keep the offer private/defiant in tone, not generic rebellion. |
| Dunmer | Azura, Boethiah, Mephala | Reclamation focus. Do not imply abandoning ancestor reverence. |
| Altmer | Auri-El, Magnus, Xarxes | Trinimac and Syrabane are out of scope until promoted by a later design/record pass. |
| Redguard | Tu'whacca, HoonDing, Leki | Deity-in-sect offers. The sect is presentation/identity context, not the offered patron. |

No-offer races in this packet:

| Race | Surface | Writing rule |
|---|---|---|
| Bosmer | Path setup, path reorientation, Champion entries | No Redguard-style deity offer. The path change should feel chosen or ritually confirmed, not patron-solicited. |
| Breton | Tradition setup and focus emergence | No bespoke formal offer in this pass. The player gets parity through clear tradition/focus surfacing. |
| Khajiit | Lunar/focus emergence | No accept/decline box. The focus quietly emerges from behavior. |
| Orc | Life-mode reorientation under Malacath | No offer box. Malacath is the spine; the experience shift is life-mode legibility. |
| Argonian | Hist/People/Void substrate posture | No deity offer. The Hist relation and posture do the work. |

## Required Output

Return one table or JSON array with these fields for every formal-offer record reviewed:

| Field | Requirement |
|---|---|
| `editorId` | Exact EditorID from the record-wave spec. |
| `title` | MessageBox title, max 40 chars preferred. |
| `body` | God-voice or sacred institutional voice, max 500 chars hard cap, 280 preferred. |
| `button0_accept` | Short button label. Implementation baseline is `Accept`. |
| `button1_not_yet` | Short button label. Implementation baseline is `Not yet`. |
| `button2_refuse` | Short button label. Implementation baseline is `Refuse`. |
| `response_accept` | Richer mirror text for `PDV_Msg_*_OfferResponse_Accept`. |
| `response_not_yet` | Richer mirror text for `PDV_Msg_*_OfferResponse_NotYet`. |
| `response_refuse` | Richer mirror text for `PDV_Msg_*_OfferResponse_Refuse`. |
| `notes` | Only concrete implementation/writing concerns. |

## Voice Rules

- ASCII only: straight quotes, `--`, `...`; no curly quotes, em dashes, bullets, or special glyphs.
- Offer bodies are sacred voice, not UI explanation.
- Buttons are short because Skyrim MessageBox buttons render in one horizontal row.
- Do not mention internal systems: piety, tier, signal, route, cooldown, record, hook, D1, Prisma, StorageUtil.
- Do not use generic "you have gained enough devotion" phrasing. The offer should name the behavior or covenant the deity noticed.
- Accept copy should sound like commitment.
- Not Yet copy should sound like postponement, not rejection.
- Refuse copy should sound final enough to justify the longer cooldown/rupture flag, without overclaiming permanent exile.

## Per-Race Writing Intent

Nord:
- Keep the existing mythic/deed-read voice.
- Kyne is storm/hunt/spirit, Shor is hall/dead/seat, Tsun is weighing/trial, Stuhn is mercy/ransom, Talos is defiant old breath.
- Audit for non-Kyne parity only; do not rewrite stable copy for style preference alone.

Imperial:
- Institutional and civic, with private conscience where Talos is involved.
- Akatosh/Zenithar may feel stronger in compliant civic-order play, but compliance never grants Talos.
- Public Compliant and Concordat Enforcer block Talos offers unless a future costly-defiance rupture source is authored; do not write around that as if it exists.

Dunmer:
- The Reclamations deepen a focus inside a living ancestor/ash-prayer structure.
- Azura = threshold/twilight/truth; Boethiah = trial/overthrow/hard becoming; Mephala = web/hidden people/clan secrecy.
- Do not write this as "choose a Daedric Prince over your people."

Altmer:
- Auri-El remains the foundation; Magnus and Xarxes are disciplined orthodox focus paths.
- Exclude Trinimac/Syrabane from this pass.
- Avoid Thalmor-only language unless the specific offer body already requires it.

Redguard:
- Tu'whacca = death duty, passage, Far Shores.
- HoonDing = rare make-way moment, not generic victory.
- Leki = disciplined sword art, not generic combat.
- The offer should read through Crown/Forebear/Ash'abah identity as context, but the patron is one of the three offerable deities.

## Stop Rules

Stop and flag instead of drafting if:

- A requested EditorID is not in `PDV_FormalOffer_RecordWave.spec.json`.
- A draft adds Breton, Bosmer, Khajiit, Orc, or Argonian formal accept/decline deity offers.
- A draft promotes Altmer Trinimac/Syrabane into formal offers.
- A draft adds a new Redguard offer deity beyond Tu'whacca, HoonDing, and Leki.
- The body needs mechanics text to make sense; that means the design surface is unclear and should come back to implementation/design.

## Acceptance Checks

The writing pass is done when:

- All formal-offer bodies are ASCII-clean and within title/body budgets.
- Each offer has exactly three short button labels.
- Response mirrors exist for Imperial, Dunmer, Altmer, and Redguard.
- Nord is either explicitly accepted as-is or has a small, justified diff list.
- No no-offer race has been converted into a formal offer race.
