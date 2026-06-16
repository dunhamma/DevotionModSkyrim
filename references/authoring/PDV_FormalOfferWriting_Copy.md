# PDV Formal Deity Offer -- Writing Pass Output

**Owner:** Claude writing pass (copy only)
**Status:** Ready for copy review / conformance, then codex authoring
**Implementation anchor:** `references/authoring/PDV_FormalOffer_RecordWave.spec.json`
**Handoff:** `references/authoring/PDV_FormalOfferWriting_Handoff.md`

This is the Required Output for the formal-offer writing pass. Final copy is committed in the
record-wave spec above; this document is the human-readable review table plus the Nord audit.

## Record-requirement notes (for codex)

- Copy is consumed by `tools/pdv-phase20-race-author --author-rewards --rewards-spec
  references/authoring/PDV_FormalOffer_RecordWave.spec.json --esp <Devotion.esp>`, then verified with
  `--check-rewards` (read-only: confirms title, body, MessageBox flag, button count/text).
- `messageRecords[]` fields: `editorId` (unique key), `kind` (`messageBox` for offers), `title`,
  `body`, `messageBox: true`, `buttons[]`. The tool enforces ASCII-only on title/body.
- **Response mirrors are per-race shared records**, one `OfferResponse_Accept / _NotYet / _Refuse`
  set per race -- NOT per deity. The `response_*` columns below therefore repeat across a race's
  rows by design. No per-deity response records were created (that would be record authoring,
  outside this pass's scope).
- Runtime maps MessageBox button index 0/1/2 -> Accept / Not yet / Refuse
  (`PDV__ManagerQuest.psc` `ShowFormalCommitmentOffer()`). Refuse sets the rupture flag + 14-day
  cooldown; Not yet = escalating 7/14-day cooldown (no rupture); Accept = focus assignment. The
  Accept / Not yet / Refuse copy is written to match those stakes.
- Offer buttons use the handoff baseline labels `Accept` / `Not yet` / `Refuse` (short, one
  horizontal MessageBox row).

## Conformance summary

| Check | Result |
|---|---|
| All offer bodies ASCII-clean | Pass (no char > 127; uses `--`, `...`, straight quotes) |
| Titles <= 40 chars | Pass |
| Bodies <= 280 preferred / 500 hard | Pass (longest in-scope body ~230) |
| Exactly 3 buttons per offer | Pass |
| Response mirrors present (Imperial, Dunmer, Altmer, Redguard) | Pass (enriched from thin placeholders) |
| No no-offer race converted to an offer race | Pass |
| No out-of-scope deity added | Pass (Trinimac/Syrabane excluded; Redguard limited to the three) |

## Imperial (9 offers)

Institutional / civic voice; Talos is private conscience, never granted by compliance.

Shared response mirrors (Imperial):
- `response_accept` (`PDV_Msg_Imperial_OfferResponse_Accept`): "You take this patron. The broad faith narrows to one, and the order keeps you as its own."
- `response_not_yet` (`PDV_Msg_Imperial_OfferResponse_NotYet`): "Not yet. Broad worship holds, and the patron waits on your word."
- `response_refuse` (`PDV_Msg_Imperial_OfferResponse_Refuse`): "You keep to broad worship. The patronage is declined, and will not be offered again soon."

| editorId | title | body | buttons | notes |
|---|---|---|---|---|
| PDV_Msg_Imperial_Akatosh_Offer | Akatosh's Order | Your devotion has not wavered through upheaval. Carry the god of time as your own, and the long order becomes your faith. Will you? | Accept / Not yet / Refuse | Names steadiness through upheaval, not generic devotion. |
| PDV_Msg_Imperial_Talos_Offer | Talos Calls the Defier | You kept faith with me where the law forbade it. Carry the old breath openly, and the Empire's own god answers a treason of conscience. Will you? | Accept / Not yet / Refuse | Private/defiant conscience. Must remain gated off Compliant/Concordat lanes -- do not wire as compliance reward. |
| PDV_Msg_Imperial_Kynareth_Offer | Kynareth's Road | The open way has been kind to you. Carry Kynareth as your own, and the road and the sky answer. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Mara_Offer | Mara's House | You have built and mended where you could. Carry the mother of the people as your own, and the civic heart is yours to keep. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Zenithar_Offer | Zenithar's Trade | Your work is honest and your weight is true. Carry the trade-god as your own, and the day's labor becomes worship. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Arkay_Offer | Arkay's Covenant | You have kept the rites the war neglected. Carry Arkay as your own, and the death-cycle is your charge. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Stendarr_Offer | Stendarr's Mercy | You have stayed the killing hand where the province wanted it loosed. Carry Stendarr as your own. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Julianos_Offer | Julianos' Code | You study, you weigh, you judge with care. Carry Julianos as your own, and the written truth is your devotion. Will you? | Accept / Not yet / Refuse | -- |
| PDV_Msg_Imperial_Dibella_Offer | Dibella's Grace | You make beauty and speak well where it matters most. Carry Dibella as your own. Will you? | Accept / Not yet / Refuse | -- |

## Dunmer (3 offers)

Reclamation focus inside living ancestor / ash-prayer structure; never "Daedric Prince over your people."

Shared response mirrors (Dunmer):
- `response_accept` (`PDV_Msg_Dunmer_OfferResponse_Accept`): "The ash-prayer has a name now. The Reclamation deepens in you, and the ancestors are not set down."
- `response_not_yet` (`PDV_Msg_Dunmer_OfferResponse_NotYet`): "Not yet. The ash-prayer holds as it was, and the threshold stays open to you."
- `response_refuse` (`PDV_Msg_Dunmer_OfferResponse_Refuse`): "You keep to the shared Reclamations. The deepening is set aside, and will not be offered again soon."

| editorId | title | body | buttons | notes |
|---|---|---|---|---|
| PDV_Msg_Dunmer_Azura_Offer | Azura's Twilight | You have lived toward me without naming it -- the thresholds kept, the hard truths faced. This is not leaving the ancestors. It is the ash-prayer deepening toward dawn. Will you name me your focus? | Accept / Not yet / Refuse | Threshold/twilight/truth; explicit "not leaving the ancestors." |
| PDV_Msg_Dunmer_Boethiah_Offer | Boethiah's Trial | You have proven yourself against the unworthy again and again. The ancestors witnessed it; now I ask for it by name. This deepens the Reclamation; it does not replace the ash. Will you name me your focus? | Accept / Not yet / Refuse | Trial/overthrow/hard becoming. |
| PDV_Msg_Dunmer_Mephala_Offer | Mephala's Whisper | You have kept the web whole without being asked. The hidden people are safer for you. Name me your focus, and the ash-prayer deepens into the web -- nothing of the ancestors is set down. Will you? | Accept / Not yet / Refuse | Web/hidden people/clan secrecy. |

## Altmer (3 offers)

Disciplined orthodox focus; Auri-El is the foundation; Trinimac/Syrabane excluded; avoid Thalmor-only language.

Shared response mirrors (Altmer):
- `response_accept` (`PDV_Msg_Altmer_OfferResponse_Accept`): "You name this focus. The foundation narrows to a single disciplined road, and the dawn holds in you."
- `response_not_yet` (`PDV_Msg_Altmer_OfferResponse_NotYet`): "Not yet. The foundation stands as it was, and the path waits for you."
- `response_refuse` (`PDV_Msg_Altmer_OfferResponse_Refuse`): "You keep to the foundation alone. The focus is set aside, and the offer will not soon return."

| editorId | title | body | buttons | notes |
|---|---|---|---|---|
| PDV_Msg_Altmer_AuriEl_Offer | Auri-El's Path | You have kept the dawn through every temptation to forget it. Make the return your focus, and the foundation becomes the whole of your faith. Will you name me? | Accept / Not yet / Refuse | Foundation deepening, not a new patron. |
| PDV_Msg_Altmer_Magnus_Offer | Magnus and the Elder Way | You study as escape, not as utility. That is my path. Name me your focus, and the arts become the road back. Will you? | Accept / Not yet / Refuse | Names the behavior (study as escape). |
| PDV_Msg_Altmer_Xarxes_Offer | Xarxes and the Record | You trust what is written over what is enforced. Name me your focus, and the lineage and the quiet truth become your devotion. Will you? | Accept / Not yet / Refuse | "written over enforced" keeps it orthodox, not Thalmor-only. |

## Redguard (3 offers)

Deity-in-sect offers; read through Crown/Forebear/Ash'abah identity, but the patron is one of the three.

Shared response mirrors (Redguard):
- `response_accept` (`PDV_Msg_Redguard_OfferResponse_Accept`): "You walk under this god now. The sect's broad worship narrows to one charge, carried as your own."
- `response_not_yet` (`PDV_Msg_Redguard_OfferResponse_NotYet`): "Not yet. The sect's worship holds as it was, and the charge waits for you."
- `response_refuse` (`PDV_Msg_Redguard_OfferResponse_Refuse`): "You keep to the sect's broad worship. The charge is set aside, and will not soon be offered again."

| editorId | title | body | buttons | notes |
|---|---|---|---|---|
| PDV_Msg_Redguard_Tuwhacca_Offer | Tu'whacca's Charge | You tend the dead and turn back the undead. Carry Tu'whacca as your own, and the guidance of souls to the Far Shores is your charge. Will you? | Accept / Not yet / Refuse | Death duty / passage / Far Shores. |
| PDV_Msg_Redguard_Leki_Offer | Leki's Blade | Your sword-work is disciplined and honest. Carry Leki as your own, and the blade becomes devotion made exact. Will you? | Accept / Not yet / Refuse | Disciplined sword art, not generic combat. |
| PDV_Msg_Redguard_HoonDing_Offer | HoonDing's Call | Again and again you have made a way where there was none. Carry the Make-Way God as your own, and the impossible passage becomes your devotion. Will you? | Accept / Not yet / Refuse | Rare make-way moment, not generic victory. |

## Nord Audit (audit only)

Source of truth: `references/authoring/PDV_ConsolidatedBuildPass_RecordWave.spec.json`. Per the handoff,
Kyne is the **anchor voice** and is not to be rewritten; the audit checks non-Kyne offers for parity
*with* Kyne's deed-read god-voice.

**Accepted as-is (no change):** all 13 Nord offers conform to the established mythic/deed-read
god-voice. Each opens on a recognized deed, frames the bond in that deity's domain, and closes with
an explicit "take the name now / or defer and be tested further" choice -- consistent with Kyne.
Specifically accepted: Kyne, Shor, Tsun, Stuhn, Akatosh, Mara, Arkay, Stendarr, Zenithar, Julianos,
Dibella, Talos, Kynareth. ASCII-clean; titles/bodies within budget. No style-only rewrites proposed.

**Small diff list (concrete, optional -- live/stable copy, defer to design):**

1. **Button-label parity (optional).** Nord offers use god-voice button labels
   `Accept the bond.` / `Not yet.` / `Refuse the offer.`, while the four scaled-out races and the
   handoff baseline use the shorter `Accept` / `Not yet` / `Refuse`. `Refuse the offer.` is the
   longest label and is the tightest fit in a single-row MessageBox. Two consistent options for a
   future pass (no change made here, since Nord is live and stable):
   - Shorten Nord buttons to the baseline `Accept` / `Not yet` / `Refuse`, **or**
   - Adopt Nord-style god-voice buttons across all races for tone parity.
   Flagging only; not drafting a change to live copy on style grounds.

No other defects found. Kyne's relative brevity is intentional anchor voice, not a parity defect, and
is left untouched.

## Acceptance Checks (handoff)

- [x] All formal-offer bodies are ASCII-clean and within title/body budgets.
- [x] Each offer has exactly three short button labels.
- [x] Response mirrors exist for Imperial, Dunmer, Altmer, and Redguard (enriched from placeholders).
- [x] Nord is explicitly accepted as-is, with a small justified diff list (optional button-label parity).
- [x] No no-offer race (Bosmer, Breton, Khajiit, Orc, Argonian) has been converted into an offer race.

## Codex wire-in step

1. Confirm copy in `PDV_FormalOffer_RecordWave.spec.json` (already authoring-ready).
2. Run `--author-rewards` against the live `Devotion.esp` to create/update the message records.
3. Extend `GetFormalCommitmentOfferMessage()` / `UsesFormalCommitmentOffersForDeity()` in
   `PDV__ManagerQuest.psc` to map the Imperial/Dunmer/Altmer/Redguard offers (currently Nord-only),
   and decide whether to `.Show()` the now-enriched `OfferResponse_*` mirrors after a choice.
4. Validate with `--check-rewards`; expect no message-record errors.
