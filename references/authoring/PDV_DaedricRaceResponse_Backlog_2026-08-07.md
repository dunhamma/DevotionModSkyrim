# Daedric race-response family -- finding, ruling, and copy bar before wiring

**Status: BACKLOG. Deliberately not wired.** Owner ruling 2026-08-07.

## The finding

`ShowRaceResponseForPlayer()` has **no organic call site anywhere in the mod**. It is called only
from `ShowControlledProofMessages()`, which is called only from `DebugRunControlledProof(Int
targetTier)` -- a debug function -- in all 16 `PDV_DaedricPath_*.psc` scripts.

Until 2026-08-07 there was exactly **one** organic trigger in the whole family:
`PDV_DaedricPath_Hircine.psc:151` called it from `HandleCurseTransition` on werewolf curse entry.
That was the wrong event. It put a second blocking modal on top of
`PDV_Msg_Nord_CurseState_WerewolfOnset`, fired in the same tick by the Nord curse handler, and the
body reads as nonsense at that moment -- it explains what closing the path costs, delivered before
the player has taken the path at all. That call was removed in `86562a81`.

**So the family is now debug-only across all 16 Princes, and its documented trigger has never
existed.** `race-sheets/PDV_DaedricContent_Manifest.md` says "One-time on a Nord committing" (and
the per-race equivalents). No commitment call site has ever been written. The real commitment beat
is `ShowCommitmentBeat()` -> `Msg_Commitment`, fired from `PDV_DaedricPathBase.AddCommitmentSignal`
when the signal count reaches `CommitmentSignalsRequired`; the race response was never attached to it.

## What the family is, and why it is worth keeping

155 records: one paragraph per Prince per playable race, explaining how **that race's own theology
reads that Prince** -- the specific tension, the social cost, and what leaving requires. It is the
race-aware consequence layer, and it is the content that makes committing to Malacath mean something
different for an Orc than for an Altmer. Examples:

- **Hircine x Khajiit** ("Form Against the Lattice"): moon-identity survives, but the wolf is a
  competing form the moons did not provide, and the caravans keep their distance from the beast-walker.
- **Hircine x Orc** ("The Beast Tested Against the Code"): the wolf may be defensible if disciplined
  and it does not break the kin, but Hircine is not Malacath and the claim competes with the code.
- **Namira x Nord** ("Against Hearth and Honor"): the corpse-and-filth cult attacks the hearth
  directly, and leaving asks sincere cleansing and direct renunciation.

This is also why the family is authored in **Narrator** voice while `Commitment`, `ChampionEntry`
and `Exit` are **God-voice**: it is not the Prince speaking, it is the mod telling the player what
their own people will make of the choice. Hircine has no reason to explain Khajiit caravan politics.
Keep that split when the copy pass happens.

## The ruling

**Destination: a pinned Book of Days entry at commitment.** Not a second modal.

Commitment keeps exactly one modal -- the Prince speaking -- and the race's reckoning is written into
the chronicle, where a 500-character reflective paragraph actually belongs and can be re-read. This
also honours the standing direction away from stacked popups.

**Wiring is deferred to the next big uplift**, because the copy is not good enough to ship as-is.
Wiring it today would make 155 records visible in their current state.

## The copy bar that must be met first

Measured over `references/authoring/PDV_DaedricPrinceRecordContracts.json` on 2026-08-07:

| Scope | Records with a body | Containing `--` | Over the 280-char budget |
|---|---|---|---|
| All Daedric records | 309 | **167 (54%)** | -- |
| Race-response family | 155 | **139 (90%)** | **24** |

Three defects to clear:

1. **`--` in player-facing prose.** This is ASCII-guard output leaking into text a player reads. The
   ASCII rule is correct and stays -- the fix is to **rewrite the sentence so it does not need the
   dash**, using a comma, a semicolon, or a full stop. Do not substitute a Unicode em-dash; the guard
   will reject it and it is the wrong fix anyway.
2. **Length.** 24 Response bodies exceed the stated 280-character body budget. As Book of Days entries
   the constraint changes, so re-derive the budget from the chronicle surface rather than the
   MessageBox one before cutting.
3. **Voice and phrasing.** The Hircine/Nord body is the worked example of the problem: it opens with
   three subordinate clauses before it says anything, and it explains mechanics ("requires cure or
   hard renunciation to close") in the register of a rules note rather than a reflection. Action-first
   lead sentence, per `PDV_STANDARDS.md` section 3.

## When this is picked up

1. Copy pass over all 155 bodies against the three defects above, keeping Narrator voice.
2. Route `ShowRaceResponseForPlayer()`'s content to `AppendBookOfDaysEntry` at commitment, from
   `PDV_DaedricPathBase.AddCommitmentSignal` alongside `ShowCommitmentBeat()`, so all 16 Princes
   inherit it.
3. Correct `race-sheets/PDV_DaedricContent_Manifest.md` -- the "One-time on a <race> committing"
   claim describes the intended destination, not the shipped behaviour, and has never been true.
4. Re-run `pdv_ascii_guard`, `pdv_book_of_days_audit` and `pdv_prisma_ui_audit` by exit code.

## Until then

The 155 records are correctly classified as **unreferenced outside debug**. That is deliberate, not
drift -- do not propose them for removal in a dead-code sweep, and do not re-wire them to the curse
transition. This document is the prior ruling.
