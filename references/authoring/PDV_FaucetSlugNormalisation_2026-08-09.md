# Faucet-lane Daedric slug normalisation — 2026-08-09

STATUS: ARCHIVE. Records a completed change. The durable rule lives in the "Canonical
Prince slugs" roster in Part B-2 of `PDV_QuestReactionMatrix.md`; that roster is the
authority, not this file.

## What was wrong

The Part D faucet lane spelled two Princes differently from the quest matrix:

| Prince | quest matrix | faucet lane | canonical |
| --- | --- | --- | --- |
| Molag Bal | `molagbal` | `molag_bal` | `molagbal` |
| Mehrunes Dagon | `mehrunesdagon` | `mehrunes_dagon` | `mehrunesdagon` |

Twelve of the fourteen faucet Princes already matched the roster; only these two did not.

## What this was NOT

An earlier draft of this document claimed the two spellings put the faucet and the quest
matrix in competing daily anti-farm buckets. **That was wrong, and it is recorded here so
the next reader does not rediscover it as a bug.**

`MarkQuestReactionFaucet` does build the cap key from the tag —

    "PDV.QuestReaction.Faucet." + deityName + "." + sourceTag + ".Day"

— but it is reached only through `ApplyDeityReaction(..., isFaucet = True, ...)`, and
`isFaucet` is `True` at exactly ONE call site in `PDV__ManagerQuest.psc`: inside
`ApplyQuestReactionFaucet`. Every quest-row path passes `False`. The cap key space is
therefore faucet-only; a quest row spelled `serve_a_daedra:molagbal` never touched it.
With one faucet per Prince, nothing was double-bucketed and no award was lost or
duplicated. **The rename is behaviour-neutral.**

The cap-alias mechanism is real, but it is faucet-to-faucet: Sheogorath has two faucets
(bear the Wabbajack, fire it) and `FAUCET_CAP_TAG_ALIASES` makes the second share the
first's bucket. That is why the alias exists, not because faucets bridge to quest tags.

## Why it was worth doing anyway

Consistency and enforceability, not a bug fix:

- One slug per Prince across the repo, so a single canonical roster can be the authority
  and the lint can enforce it. Two spellings defeat that by construction.
- The Part D lane could not be linted against the roster while it disagreed with it; the
  ratchet below only became possible after the rename.
- A reader who sees two spellings for one Prince reasonably concludes one of them is a
  typo, and the cost of that confusion is exactly the hour this correction took.

## What was deliberately NOT changed

`serve_a_daedra:sheogorath_fire` stays. It is a distinct faucet act — firing the Wabbajack
as opposed to merely bearing it — and it already shares Sheogorath's bucket through
`FAUCET_CAP_TAG_ALIASES` in `pdv_quest_matrix_compile.mjs`, which maps it to
`serve_a_daedra:sheogorath` for cap purposes while keeping its own valence and intensity.
That is the intended pattern for a compound faucet act, not drift.

## Save-game consequence, accepted

The cap key is persisted StorageUtil state on the save (`None` scope). Renaming the tag
orphans the old key rather than migrating it, so on an existing save:

- the stale `...serve_a_daedra:molag_bal.Day` / `...mehrunes_dagon.Day` ints remain as a
  few dead bytes, read by nothing;
- a player who already tripped one of these two faucets on the day they upgrade can trip
  it **once more** that day, because the new key starts unset.

Bounded to two faucets, one extra award each, once, self-healing at the next dawn. A
migration shim was considered and refused: the code to walk and rewrite two StorageUtil
keys carries more risk of a real bug than the one-off it would prevent.

## Change surface — all of it moves together

A rename that lands in some of these and not others silently breaks the faucet, because
every link is matched by exact string.

1. `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` — the `act_tag`
   column, 2 rows. This is the source.
2. `tools/pdv_quest_matrix_compile.mjs` — 2 `FAUCET_FORM_LISTS` keys, which are built as
   `faucetForms.<deity>.<act_tag>` and must agree with the CSV.
3. `live-source/Scripts/Source/PDV_PlayerEvents.psc` — 12 occurrences over 10 lines, 6 per
   Prince: the `CacheQuestReactionFaucetList` registration, a `ShouldRouteQuestReactionFaucet`
   guard that names the tag TWICE (once as the cap key, once as the form-list key), the
   `RouteQuestReactionFaucet` call, and a `listKey ==` arm in each of the two resolver blocks.
4. `D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV_PlayerEvents.psc` — the MO2
   mirror. `pdv_compile.mjs` reads MO2 as `DEVOTION_SOURCE` by default, so the repo copy
   alone does not reach the compiler.
5. Generated artifacts: `PDV_QuestReactionMatrix.json` (re-run `pdv_quest_matrix_compile.mjs`)
   and `PDV_PlayerEvents.pex` (re-run `pdv_compile.mjs`).

The JSON carries each faucet under both a cased and a lower-cased deity key
(`faucet.Molag Bal....` and `faucet.molag bal....`), six fields each, so the rename moves
24 JSON keys.

## Ratchet added

The lint skipped the faucet table entirely — it is keyed on having an `outcome_stage`
column and Part D has none — which is why this drift survived the 2026-08-09 slug check.
`pdv_qrm_lint.mjs` now checks the faucet table's namespaced act tags too, under a rule that
fits what the lane actually needs:

> a faucet slug is valid if it is a roster slug, **or** if it is `<base>_<qualifier>` where
> `<base>` is a roster slug.

That accepts `sheogorath_fire` as the deliberate compound act it is, and rejects both of
the spellings this pass removed — `molag_bal` splits to a base of `molag`, and
`mehrunes_dagon` to `mehrunes`, neither of which is a Prince. Quest-outcome rows keep the
stricter exact-match rule; only the faucet lane may compound.

## Verification

- `node tools/pdv_qrm_lint.mjs` — exit 0, and now covers Part D.
- `node tools/pdv_quest_tranche_merge.mjs --check` — exit 0.
- `node tools/pdv_external_support_inventory.mjs --check` — exit 0.
- `node tools/pdv_quest_matrix_compile.mjs --check` — exit 0.
- `node tools/pdv_compile.mjs --script PDV_PlayerEvents` — compiled, `.pex` refreshed.
- Zero occurrences of the old spellings outside this file, the Part B-2 rationale, and the
  dated 2026-06-24 design handoff (left as the archive record it is).
