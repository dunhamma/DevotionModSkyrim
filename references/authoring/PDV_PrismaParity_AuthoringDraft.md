# PDV Prisma Parity -- Authoring Draft (for owner redline)

DRAFT copy for the parity worklist's authoring beats. Voice authorities used:
`PDV_FormalOfferWriting_Copy.md` (per-race offer + response-mirror register),
`PDV_BookOfDaysVoice_6g_Handoff_2026-06-25.md` (per-race `ResolveJournalLine` register),
`BuildModeChangeLine` (per-race mode voice), `GetDaedricMilestoneFlavor` (Prince voice).
ASCII-only; toasts short for the notification lane; chronicle = 1-2 sentences, past-tense reflective.
`{patron}` / `{focus}` / `{band}` etc. = runtime name slots. **Provisional** flags mark names to
confirm against live track labels before wiring.

Wiring model (for Codex): the chronicle lines route through new per-race `ResolveJournalLine` tone
keys (mirroring the Khajiit/Dunmer/Imperial/Altmer bespoke functions); toasts via the existing
toast channel at the named fire site.

---

## 1. Commitment offer ACCEPT  (tone key `offer.accept`; toast + pinned chronicle; fires `DebugAcceptPendingCommitment` :12256)
LOCKED 2026-06-25. Consequence-first; god-agent for Nord/Imperial, player-agent for the rest. Nord+Imperial share.

- **Nord / Imperial** -- toast: `{patron} has named you their own.`
  chronicle: `The broad faith narrows to one; {patron} has named you their own.`
- **Dunmer** -- toast: `The ash-prayer has a name: {patron}.`
  chronicle: `The Reclamation deepens in you. You named {patron} as your focus.`
- **Altmer** -- toast: `You name {patron} your focus.`
  chronicle: `The foundation narrows to a single disciplined road. You named {patron} your focus.`
- **Redguard** -- toast: `You walk under {patron} now.`
  chronicle: `The sect's broad worship narrows to one charge. You took {patron} as your own.`

## 2. Commitment offer REFUSE  (tone key `offer.refuse`; toast + pinned chronicle; fires `DebugRefusePendingCommitment`)
LOCKED 2026-06-25. Per-deity TERMINAL (R5 + offer-cadence ruling): a refused god never offers again -- even
after a deep lapse-and-rebuild. Consequence-first; ends on the definitive "will not ask again". Nord+Imperial share.

- **Nord / Imperial** -- toast: `You turned {patron} away.`
  chronicle: `The broad faith stays whole; you turned {patron} away, and {patron} will not ask again.`
- **Dunmer** -- toast: `You set {patron} aside.`
  chronicle: `The Reclamation holds as it was. You set {patron} aside, and {patron} will not ask again.`
- **Altmer** -- toast: `You keep to the foundation.`
  chronicle: `The foundation stands as it was. You kept to it alone, and {patron} will not ask again.`
- **Redguard** -- toast: `You keep to the sect.`
  chronicle: `The sect's broad worship holds as it was. You set {patron}'s charge aside; {patron} will not ask again.`

## 3. Quiet-emergence cues  (tone key `emergence.onset`; toast + pinned chronicle)
The by-design races' silent commitment -- no popup. Backs the un-built `quietEmergenceSnippets`.
**Codex note:** emit direction `onset` (not `reach`) so the key resolves to the authored
`emergence.onset` arms -- see the decided-worklist direction-token reconciliation.

- **Khajiit focus** (`GetKhajiitFocusDeity`) -- toast: `Your road turns toward {focus}.`
  chronicle: `Under the moons your road turned toward {focus}, and stayed there. No vow, no shrine -- only the way you walk.`
- **Breton tradition** (`GetBretonTraditionDeity`) -- see beat 5 (the tradition-choice beat IS the Breton quiet-emergence; use the same line).

---

## 4. Altmer Thalmor-alignment band  (reorientation; toast + chronicle; fires on band change)
**Provisional:** confirm the 5 band labels from `PDV_ThalmorAlignmentTrack` (Concordat -100..+100 mirror with a rebel pole) before wiring.

- toast: `Your standing with the Dominion shifts: {band}.`
- chronicle: `The old line marks where you stand with the Dominion now: {band}.`

## 5. Breton tradition choice  (reorientation; toast + pinned chronicle; irreversible startup choice)
Tradition labels: `Knight's Road` / `Hidden Art` / `Green Way`.

- toast: `You set your road: {tradition}.`
- chronicle: `You chose your road today, and it will not be unchosen: the {tradition}. The mixed inheritance settles into one shape.`

## 6. Hircine werewolf-onset (curse-entry)  (curse.onset, Hircine-specific; chronicle; toast already via race-response MESG)
- chronicle: `The beast-blood took you, and Hircine was watching. The Hunt is in you now.`

## 7. Hircine renunciation  (chronicle; toast + ledger already present)
- chronicle: `You set the Hunt down. Hircine's mark fades from your blood, and the pack is no longer yours.`

## 8. Redguard sect Champion-entry  (chronicle; toast already via the sect-entry MESG)
Echoes the existing `ShowRedguardMessage` lines, as persistent journal entries.

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

- chronicle: `You confirmed your road through the Green: the {path}. Y'ffre's song settles into one shape in you.`

---

## 12. Daedric offer titles  (16; ruling R3 -- name the Prince in the TITLE; bodies unchanged)
Epithet titles matching `GetDaedricMilestoneFlavor` voice + the racial-offer title style (`{Prince}'s {epithet}`).

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
- **Corrupted** -- chronicle: `The moons curdled over your road. A corruption is on you now.`
- **ShadowDrift** -- chronicle: `You slipped into the moons' shadow. The dark road has you.`

## 14. Altmer crisis-state toast  (P2, R3; SendPrismaShiftToast at :7417)
**Provisional:** confirm crisis labels (None/Dissonant/Questioning/Reasserting/Scarred-Resolved).
- toast: `The old line strains: {crisis}.`

---

## Status
- **Beats 1-2 (offer accept/refuse) -- LOCKED 2026-06-25** (per-race templated, Nord+Imperial shared, refuse terminal).
  The offer-cadence ruling (one offer per qualification, refuse permanent, re-offer only on lapse+rebuild) is
  in `PDV_PrismaParity_SerializedHandoffs.md` Handoff B.
- **Beats 3-14 + Daedric titles -- drafted, accepted-as-is for now** (redline later if desired).

## Open items (non-blocking)
- **Altmer band labels (beat 4)** -- provisional; confirm against `PDV_ThalmorAlignmentTrack` before wiring.
- **Daedric titles (beat 12)** -- epithet style (`{Prince}'s {epithet}`); flip to bare Prince name if preferred.
