# PDV Patron-Offer Deity Naming + Player Copy Lint - Scope

Status: LIVING (scope doc, pre-implementation)
Opened: 2026-08-08
Owner ruling on this page: **every commitment where the player accepts or refuses a patron --
Prince or god -- must carry the deity's name. Just the name, no title, at the top, as its own
sentence.**

## The defect

A Dunmer accepting Azura sees a modal reading *"You have lived toward me without naming it... Will
you name me your focus?"* with Accept / Not yet / Refuse buttons. **It never says Azura.** The
player is asked to bind themselves to a god without being told which god.

## Two findings that shaped the scope

Both established by reading records, not by trusting the docs.

**1. The titles already exist and already name every deity.** `Azura's Twilight`, `Boethiah's
Trial`, `Kyne Reaches Back` -- all 45 offers carry one on the `Name` field. They **do not render**:
owner confirmed in game that no heading appears on these boxes. `Name` is editor-facing metadata
only. Any fix that touches titles is wasted work.

**2. The Daedric lane is NOT already compliant.** Of the 16 `PDV_Msg_Daedric_*_Commitment` bodies,
only **two** name their deity (Vaermina, Namira). Mephala's reads *"Three times you chose the hidden
way... Take the threads"* and never says Mephala. Azura's `ChampionEntry` never says Azura. So the
Prince choice-boxes carry the identical defect and are in scope, rather than being the model.

**The model that works already exists in the mod:** Daedric notifications (*"Mephala counts you a
Seeker of the web."*) and all eleven Breton offers (*"Name Stendarr your focus."*). The pattern was
simply never applied to the choice-boxes.

## Scope

Every MessageBox where the player accepts or refuses a patron.

| Set | Count | EditorID shape |
|---|---|---|
| Race patron offers | 45 | `PDV_Msg_<Race>_<Deity>_Offer` |
| Daedric champion offers | 16 | `PDV_Msg_Daedric_<Prince>_ChampionEntry` |

`ChampionEntry` is the Princes' accept/refuse: `PDV_DaedricPath_Hircine.psc` reads its return value
(`Int championChoice = ShowIfPresent(Msg_ChampionEntry)`).

**Out of scope:** the 16 `PDV_Msg_Daedric_*_Commitment` beats. `ShowCommitmentBeat()` calls
`ShowIfPresent(Msg_Commitment)` and discards the result -- a confirmation, not a choice, so it fails
the owner's "accept or refuse" test. Noted for a later ruling: 14 of 16 do not name their deity
either.

## Format

Deity name alone, first, as its own sentence, then the existing body unchanged:

```
Azura

You have lived toward me without naming it, the thresholds kept, the hard truths faced.
This is not leaving the ancestors. It is the ash-prayer deepening toward dawn.
Will you name me your focus?
```

Bare name only -- no possessive, no epithet. The first-person voice stays; the name just tells the
player who is speaking before they read the ask.

**Verify the format renders BEFORE touching 61 records.** PDV uses `String nl = "\n"` for newlines in
script-built strings, but nothing proves a line break inside a MESG `DESC` field renders in a message
box in this mod. Spike one record (`PDV_Msg_Dunmer_Azura_Offer`, `0715DC`), trigger it in game,
confirm the name lands on its own line. If it does not, fall back to `Azura.` as a leading sentence
on the same line and re-verify before proceeding.

## The lint - `tools/pdv_player_copy_lint.mjs`

One tool, two rules, wired into the gate set and judged by **exit code**.

**Rule 1 -- no `--` in player-facing text.** ASCII-guard output leaking into copy a player reads.
`pdv_ascii_guard` cannot catch it: `--` is valid ASCII, so it passes clean. The fix is always to
rewrite the sentence so it does not need a dash -- **never** substitute a Unicode em-dash, which the
ASCII guard rejects and which is the wrong fix regardless. Current scale: 139 of the 155 Daedric
race-response bodies (90%), plus 2 of the 3 Dunmer offers.

**Rule 2 -- a patron-commitment box must name its deity.** For any MESG matching the two EditorID
shapes above, `Description` must contain the deity's shipped `DeityName`. Resolve that from the deity
quest's `DeityName` VMAD property, **not** from the EditorID stem -- three deities ship under a title
and would otherwise false-positive:

- **Orkey** -- display name is an override; see the `orkey-baseline-display-name-override` ruling
- **HoonDing** -- *"the Make-Way God"*
- **Sheogorath** -- *"The Madgod"*

Allow an explicit alias list for those, and **fail closed** on any deity the lint cannot resolve.

**Source of truth is the ESP, not the docs.** Read via `housecarl_cross_plugin_query`
(`type=MESG`, `plugins=["Devotion.esp"]`, `format=json`). The manifest and copy docs have been wrong
about this family before.

## Files

- **New:** `tools/pdv_player_copy_lint.mjs`
- **Records:** 61 MESG `Description` fields in `Devotion.esp`, written via `housecarl_set_field`
- **Docs to correct after:** `race-sheets/PDV_DaedricContent_Manifest.md` and
  `references/authoring/PDV_FormalOfferWriting_Copy.md` both describe this copy; neither records that
  the deity goes unnamed in the body

## Verification

1. **Format spike first** -- one record, in game, before the other 60.
2. `node tools/pdv_player_copy_lint.mjs` exits 0. Then deliberately break one record and confirm it
   exits non-zero -- a lint that has never failed is not a proven lint.
3. `pdv_ascii_guard`, `pdv_verify`, `pdv_formal_offer_check` all exit 0.
4. **In game:** trigger one race patron offer and one Daedric champion offer; confirm each names its
   deity. Reaching a patron offer needs piety >= 50 (`COMMITMENT_OFFER_THRESHOLD`) plus two signal
   days: MCM *Debug: State & Rewards* to select the deity and seed piety, then *Debug: Daedric &
   Curse* -> `Seed commitment signals`, `Evaluate commitment`.
5. Confirm the houseCARL instance reads **Anvil / Devotion Dev** before any readback becomes a claim.

**Do not use `cqf` in any test step** -- it does not work in this user's Skyrim. MCM only.

## Known unknown

The MCM `Evaluate commitment` button did not fire when pressed on 2026-08-08 -- no
`Commitment evaluate debug` trace appeared, though a level-1 trace from `Seed commitment signals` on
the same page did. The offer arrived through the dawn path instead. Unresolved; worth a look if the
button misbehaves again during verification.
