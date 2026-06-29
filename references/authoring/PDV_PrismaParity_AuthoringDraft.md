# PDV Prisma Parity -- Authoring Draft (LOCKED 2026-06-25)

Copy for the parity worklist's authoring beats. Voice authorities: `PDV_FormalOfferWriting_Copy.md`
(per-race offer + response-mirror register), `PDV_BookOfDaysVoice_6g_Handoff_2026-06-25.md`
(per-race `ResolveJournalLine` register), `BuildModeChangeLine`, `GetDaedricMilestoneFlavor`.
ASCII-only; toasts short for the notification lane; "chronicle" = the Book of Days (page 0).
`{patron}` / `{focus}` / `{band}` / `{tradition}` / `{path}` / `{crisis}` = runtime name slots.

Wiring model (for Codex): chronicle lines route through new per-race `ResolveJournalLine` tone keys
(mirroring the Khajiit/Dunmer/Imperial/Altmer bespoke functions); toasts via the named fire site.

---

## 1. Commitment offer ACCEPT  (tone key `offer.accept`; toast + pinned chronicle; fires `DebugAcceptPendingCommitment`)
Consequence-first; god-agent for Nord/Imperial, player-agent for the rest. Nord+Imperial share.

- **Nord / Imperial** -- toast: `{patron} has named you their own.`
  chronicle: `The broad faith narrows to one; {patron} has named you their own.`
- **Dunmer** -- toast: `The ash-prayer has a name: {patron}.`
  chronicle: `The Reclamation deepens in you. You named {patron} as your focus.`
- **Altmer** -- toast: `You name {patron} your focus.`
  chronicle: `The foundation narrows to a single disciplined road. You named {patron} your focus.`
- **Redguard** -- toast: `You walk under {patron} now.`
  chronicle: `The sect's broad worship narrows to one charge. You took {patron} as your own.`

## 2. Commitment offer REFUSE  (tone key `offer.refuse`; toast + pinned chronicle; fires `DebugRefusePendingCommitment`)
Per-deity TERMINAL (verified against the cadence code: refuse sets `Refused`, eligibility reads it, the dawn
pass never clears it). Consequence-first; ends on the definitive "will not ask again". Nord+Imperial share.

- **Nord / Imperial** -- toast: `You turned {patron} away.`
  chronicle: `The broad faith stays whole; you turned {patron} away, and {patron} will not ask again.`
- **Dunmer** -- toast: `You set {patron} aside.`
  chronicle: `The Reclamation holds as it was. You set {patron} aside, and {patron} will not ask again.`
- **Altmer** -- toast: `You keep to the foundation.`
  chronicle: `The foundation stands as it was. You kept to it alone, and {patron} will not ask again.`
- **Redguard** -- toast: `You keep to the sect.`
  chronicle: `The sect's broad worship holds as it was. You set {patron}'s charge aside; {patron} will not ask again.`

## 3. Quiet-emergence cues  (tone key `emergence.onset`; toast + pinned chronicle)
The by-design races' silent commitment -- no popup. Emit direction `onset` (resolves to the existing authored arms).

- **Khajiit focus** (`GetKhajiitFocusDeity`) -- toast: `Your road turns toward {focus}.`
  chronicle: `Under the moons your road turned toward {focus}, and stayed there.`
- **Breton tradition** (`GetBretonTraditionDeity`) -- see beat 5 (the tradition-choice beat IS the Breton quiet-emergence).

---

## 4. Altmer Thalmor-alignment band  (reorientation; toast + chronicle; fires on the COMMITTED band change)
Bands (heterodox <-> Thalmor pole, from `GetAltmerAlignmentSurveyBaseText`): **Open Heterodoxy** (<=-76) /
**Private Heterodoxy** (-51..-75) / **Uncommitted** (-50..+50) / **Public Orthodoxy** (+51..+75) / **Thalmor-Devout** (>=+76).
Fire on the committed band-label change (lock-in grace lags the raw value).

- toast: `The Thalmor question turns in you: {band}.`
- chronicle: `Your soul records where you stand in the Thalmor question: {band}.`

## 5. Breton tradition choice  (reorientation; toast + pinned chronicle)
Tradition labels: `Knight's Road` / `Hidden Art` / `Green Way`. Start-locked in 1.0; off-tradition acts build
`CrossTraditionPressure` (surfaced in Survey) but never rewrite the tradition -- so "not easily swayed" is
forward-compatible with the deferred pressure-switch and honest for 1.0 (verified `:14474-14483`).

- toast: `You set your tradition: {tradition}.`
- chronicle: `You've chosen your road: {tradition}.`

## 6. Hircine werewolf-onset (curse-entry)  (curse.onset, Hircine-specific; chronicle; toast already via race-response MESG)
- chronicle: `The beast-blood took you and stirred Hircine. The Hunt is in you now.`

## 7. Hircine renunciation  (chronicle; toast + ledger already present)
- chronicle: `Hircine's mark fades from your blood, and the pack is no longer yours.`

## 8. Redguard sect Champion-entry  (chronicle; toast already via the sect-entry MESG)
- **Crown** -- chronicle: `The Crown way is more than memory in you now. It has become a public shape of your devotion.`
- **Forebear** -- chronicle: `The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.`
- **Ash'abah** -- chronicle: `The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.`

## 9. Argonian Hist-Adaptation  (milestone; toast + pinned chronicle; permanent body change)
- toast: `The Hist has reshaped you.`
- chronicle: `You took the Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its image.`

## 10. Breton druidic-fork  (toast + chronicle; Betrayed / Werewolf only, per R4)
- **Werewolf** -- toast: `The Green Way turns wild in you.`
  chronicle: `The beast-blood took your Green Way down a wilder road. The Werewolf path is yours now.`
- **Betrayed** -- toast: `You broke faith with the Green.`
  chronicle: `You turned from the Green Way's trust. The path remembers the betrayal.`

## 11. Bosmer path-confirm  (chronicle; toast + ledger already present)
Path labels: `Living Story` / `Exchange` / `Bandit Road` / `Old Contract`.

- chronicle: `Y'ffre's song settles within you. Your road through the Green is the {path}.`

---

## 12. Daedric offer titles  (16; ruling R3 -- name the Prince in the TITLE; bodies unchanged)
LOCKED -- epithet style (`{Prince}'s {epithet}`).

| Prince | Title |
|---|---|
| Azura | Azura's Twilight |
| Boethiah | Boethiah's Trial |
| Clavicus Vile | Clavicus Vile's Bargain |
| Hermaeus Mora | Hermaeus Mora's Unread Pages |
| Hircine | Hircine's Hunt |
| Malacath | Malacath's Oath |
| Mehrunes Dagon | Mehrunes Dagon's Ruin |
| Mephala | Mephala's Web |
| Meridia | Meridia's Light |
| Molag Bal | Molag Bal's Grip |
| Namira | Namira's Dark |
| Nocturnal | Nocturnal's Shadow |
| Peryite | Peryite's Order |
| Sanguine | Sanguine's Revel |
| Sheogorath | Sheogorath's Madness |
| Vaermina | Vaermina's Dream |

---

## 13. Khajiit lunar-posture chronicle  (P1, R2; severe transitions only; direct AppendBookOfDaysEntry at :5342)
- **Corrupted** -- chronicle: `The moonlight scatters from your path. Corruption is upon you.`
- **ShadowDrift** -- chronicle: `You slipped into the moons' shadow. Darkness is upon you.`

## 14. Altmer crisis-state toast  (P2, R3; SendPrismaShiftToast at :7417)
Labels (from `GetAltmerCrisisStateLabelForValue`): **Dissonant / Questioning / Reasserting / Scarred resolved**
(None = no crisis). Fire on a transition INTO a crisis state; the clear-to-None can stay silent or use a resolved line.
Verb is `turns` (state-neutral shift), since "strains" only fit the worsening states, not Reasserting/Scarred-resolved.

- toast: `The old line turns: {crisis}.`

---

## Status -- ALL LOCKED 2026-06-25
- Beats 1-14 + the 16 Daedric titles (epithet) locked; beats 8/9/10 accepted as drafted.
- Offer-cadence ruling: `PDV_PrismaParity_HandoffB_OfferCadence.md` (built + committed `f97b7db`).
- Ready for Unit D wiring.
