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

## Promotion

The reviewed movement of generated plugin content into accepted source plugin state.

## Quest-Reaction Faucet

The curated quest/matrix faucet layer compiled from `PDV_QuestReactionMatrix` data. It may use the same PO3 ingress script as generic faucets, but it is not the generic 300+ day-to-day scorer and must not be duplicated by a second same-owner generic route.

## Route Ownership

The rule that each gameplay signal has one owning receiver path. Existing PO3 alias hooks own events they already observe cleanly; Story Manager receiver quests are added only for vanilla SM events not already owned by PO3.
