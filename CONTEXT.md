# Context Glossary

## Accepted Mod State

The reviewed source plugin state that the mod author has accepted as real project content.

## CK-Semantic Record

A record whose correctness depends on Creation Kit editor behavior, generated metadata, or editor-owned relationships rather than only binary field values.

## Drift

A disagreement between manifest intent, generated plugin state, accepted source plugin state, or the live winning load-order state.

## Generated Plugin

A reversible plugin produced by automation for review before any source plugin promotion.

## Generic Day-to-Day Faucet

The ambient 300+ event-id likes/dislikes layer. Events route through `PDV_EventBus.RouteActionWithAttribution` into each deity's data-driven `ScoreAction` table and are race-native gated.

## Live Readback

Verification evidence read from the active resolved mod environment, including the actual winning plugin state.

## Manifest Intent

The structured statement of what automation is expected to create, update, verify, and explain.

## Prisma Close Contract

The invariant for dismissing focused Prisma surfaces. For Book of Days, the native
bridge owns the close surface: key toggle, in-view X, Papyrus `journalClose`, and
keyboard Esc must converge on the same native close implementation so state,
focus, cursor behavior, and view visibility cannot drift by route.

## Promotion

The reviewed movement of generated plugin content into accepted source plugin state.

## Quest-Reaction Faucet

The curated quest/matrix faucet layer compiled from `PDV_QuestReactionMatrix` data. It may use the same PO3 ingress script as generic faucets, but it is not the generic 300+ day-to-day scorer and must not be duplicated by a second same-owner generic route.

## Route Ownership

The rule that each gameplay signal has one owning receiver path. Existing PO3 alias hooks own events they already observe cleanly; Story Manager receiver quests are added only for vanilla SM events not already owned by PO3.

## Devotional Progression Language

## Substrate Metric

The origin-specific cultural-practice standing that gates a race's quiet identity boon family independently of deity piety.
_Avoid_: spine, ancestry points

## Broad Pantheon Pool

The shared standing earned from the eligible gods of one active broad-worship baseline without creating an aggregate deity.
_Avoid_: broad deity, pantheon piety sum

## Relation Ledger

An origin-specific relationship standing, such as Argonian Hist, People, or Void, that remains separate from substrate standing and deity piety.
_Avoid_: substrate component, hidden deity

## Logical Devotional Act

One player deed and all of its routed consequences considered as a single scoring event for anti-fan-out rules.
_Avoid_: each reaction row, each deity award

## Relationships

- A **Logical Devotional Act** may affect several deity ledgers but contributes at most one signed delta to one active **Broad Pantheon Pool**.
- A valid cultural act may affect both a **Substrate Metric** and an appropriate deity or **Relation Ledger**, but each lane applies its own rules.
- A **Relation Ledger** never derives or overwrites a **Substrate Metric**.
- A **Broad Pantheon Pool** is worship state and never a deity record.

## Flagged ambiguities

- "Broad piety" previously meant either summed deity piety or a civic-service counter. Resolved: use **Broad Pantheon Pool**, fed once per **Logical Devotional Act**.
- "Substrate" previously described both a cultural metric and Argonian relation values. Resolved: the **Substrate Metric** is separate from every **Relation Ledger**.
- "Spine" previously appeared in internal and player-facing names. Resolved: it may survive only in compatibility identifiers; player-facing language uses the named cultural practice.
