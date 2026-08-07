# Offer-response mirrors: authored copy vs the live built lines (2026-08-07)

Investigation only. No code changed. The owner ruling this asks for is on the
`PDV_Msg_<Race>_OfferResponse_{Accept,NotYet,Refuse}` property family.

## Recommendation up front

**Retire the 18 properties.** The rework was intentional and, contrary to the concern that prompted
this, **no authored copy was lost** -- it was split across two surfaces rather than dropped. See the
table below.

Two things should not be retired with them, because they are real gaps rather than leftovers:

1. **"Not yet" has no surface anywhere.** Six of the eighteen properties serve a player choice that
   produces silence in both systems.
2. The doc corrections in the last section, which are needed whichever way the ruling goes.

## Correcting the numbers first

- **18 properties, not 21.** `PDV__ManagerQuest.psc:537-585`, six races x three states: Nord, Dunmer,
  Altmer, Breton, Imperial, Redguard.
- All 18 have exactly one occurrence tree-wide -- the declaration. Zero consumers.
- Authored copy exists for **four** races (Imperial, Dunmer, Altmer, Redguard) = 12 lines.
  **Nord and Breton have properties but no authored copy.**

## The live path is three surfaces, none of them a modal

On accept (`PDV__ManagerQuest.psc:20585-20592`) and on refuse (`:20872`) the offer resolves as:

1. `DispatchDiegeticCue("offer", ..., "accept"/"refuse", ...)` -- the diegetic cue
2. `SendPrismaToast(...)` fed by `BuildCommitmentOffer*ToastLine` -- the short line
3. a Book of Days entry, routed through `ResolveJournalLine` (`:3799-3802`) to
   `BuildCommitmentOffer*JournalLine` -- the full line

This matches the shipped behaviour already on record: refuse surfaces as toast + pinned Book entry,
no wash and no sound. The MESG mirrors would add a fourth surface, and a **blocking modal** at that --
against the direction the mod has been moving, and the same class of surface that caused the
`Message.Show()`-over-an-open-menu defect that had to be fixed by deferring modals.

## The comparison, per race

The built lines are not thin replacements written in ignorance of the copy. They are the authored
sentence **split in two**: the toast takes the opening clause, the journal takes the rest including
the consequence.

### Dunmer

| Surface | Text |
|---|---|
| Authored accept | "The ash-prayer has a name now. The Reclamation deepens in you, and the ancestors are not set down." |
| Live toast | "The ash-prayer has a name: `<patron>`." |
| Live journal | "The Reclamation deepens in you. You named `<patron>` as your focus." |
| Authored refuse | "You keep to the shared Reclamations. The deepening is set aside, and will not be offered again soon." |
| Live toast | "You set `<patron>` aside." |
| Live journal | "The Reclamation holds as it was. You set `<patron>` aside, and `<patron>` will not ask again." |

### Altmer

| Surface | Text |
|---|---|
| Authored accept | "You name this focus. The foundation narrows to a single disciplined road, and the dawn holds in you." |
| Live toast | "You name `<patron>` your focus." |
| Live journal | "The foundation narrows to a single disciplined road. You named `<patron>` your focus." |
| Authored refuse | "You keep to the foundation alone. The focus is set aside, and the offer will not soon return." |
| Live toast | "You keep to the foundation." |
| Live journal | "The foundation stands as it was. You kept to it alone, and `<patron>` will not ask again." |

### Redguard

| Surface | Text |
|---|---|
| Authored accept | "You walk under this god now. The sect's broad worship narrows to one charge, carried as your own." |
| Live toast | "You walk under `<patron>` now." |
| Live journal | "The sect's broad worship narrows to one charge. You took `<patron>` as your own." |
| Authored refuse | "You keep to the sect's broad worship. The charge is set aside, and will not soon be offered again." |
| Live toast | "You keep to the sect." |
| Live journal | "The sect's broad worship holds as it was. You set `<patron>`'s charge aside; `<patron>` will not ask again." |

### Imperial (falls to the default arm)

| Surface | Text |
|---|---|
| Authored accept | "You take this patron. The broad faith narrows to one, and the order keeps you as its own." |
| Live toast | "`<patron>` has named you their own." |
| Live journal | "The broad faith narrows to one; `<patron>` has named you their own." |
| Authored refuse | "You keep to broad worship. The patronage is declined, and will not be offered again soon." |
| Live toast | "You turned `<patron>` away." |
| Live journal | "The broad faith stays whole; you turned `<patron>` away, and `<patron>` will not ask again." |

### Nord and Breton

No authored response-mirror copy, and both fall to the default arm, which reads correctly for them
("The broad faith narrows to one..."). Their six properties are the clearest leftovers in the set.
Note `PDV_FormalOfferWriting_Copy.md:145` calls Breton a **no-offer race**, so its three properties
should arguably never have existed.

## Why this is a supersession and not a regression

Every authored clause survives:

- the opening clause is the toast
- the second clause -- the state statement ("The Reclamation holds as it was", "The foundation stands
  as it was", "The sect's broad worship holds as it was") -- is the journal line's opening
- the consequence ("will not be offered again soon") is the journal line's close ("will not ask
  again")

The only thing the mirrors would add is the modal itself. That is a delivery-mechanism question, and
the mod has already answered it elsewhere in favour of toast + chronicle.

## The one real gap: "Not yet"

`NotYet` appears **nowhere in the live tree outside the six property declarations**. There is no
`BuildCommitmentOfferNotYetToastLine`, no journal arm for it in `ResolveJournalLine`, and no
`DeferPendingCommitment` function.

So a player offered a patron and choosing "Not yet" gets: no toast, no Book of Days entry, no cue.
The offer presumably stays pending, but nothing tells the player that. Accept and refuse both close
with a clear beat; the middle option closes with silence.

This is a separate defect from the mirror question and should not be resolved by deleting the six
`_NotYet` properties. It needs its own ruling: either build the pair of lines the other two states
have, or decide the silence is intended because nothing changed.

## Doc corrections needed regardless of the ruling

1. **`PDV_FinalPolishLook_Ledger.md:98` (FP-020)** cites props at `PDV__ManagerQuest.psc:388-403`.
   That range holds unrelated `PDV_Bless_*` Spell properties in a CUT-1.0.3 comment block. The line
   anchors do not point at what they claim, and FP-020's "done-on-live" status describes a surface
   the player has never seen.
2. **`PDV_FormalOfferWriting_Copy.md`** marks response mirrors "Pass (enriched from thin
   placeholders)" at line 43 and, at line 153, still lists "decide whether to `.Show()` the
   now-enriched `OfferResponse_*` mirrors after a choice" as open. **That open item is this ruling.**
   The doc should record the outcome rather than keep carrying the question.
3. The count in `PDV_DeadCode_RetiredScaffolding_Verdicts_2026-08-07.md` says 21 properties across
   seven races. It is 18 across six.

## If the ruling is "retire"

The removal packet is: 18 property declarations, their VMAD bindings, and the MESG records. Before
deleting the records, check whether any is shared with a surface that still uses it -- these are
per-race shared records by design, so a record could serve more than the mirror. Re-run
`pdv_formal_offer_check` and `pdv_prisma_ui_audit` after, and correct the three docs above in the
same commit so the mod and its documentation stop disagreeing.
