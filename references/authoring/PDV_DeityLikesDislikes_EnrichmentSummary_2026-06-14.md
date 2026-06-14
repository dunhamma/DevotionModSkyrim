# PDV Likes/Dislikes Enrichment -- Coverage Before/After Summary

**Created:** 2026-06-14
**Status:** CSV authoring complete (offline prep). BOTH generators HELD -- no codegen run, no
manager edit, no ESP write. The new rows are inert until the held codegen step runs in the later
consolidated manager pass.
**Companion data:** `references/authoring/PDV_DeityLikesDislikes.csv` (V1 deity faces),
`references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv` (V2 path faces)
**Owner:** Companion to `PDV_DeityLikesDislikesMatrix.md` and `PDV_PrinceLikesDislikes_V2_Spec.md`

---

## 1. Why this pass happened

The original task assumed the day-to-day small-signal tables were "Nord-only (3/48)". That is a
STALE snapshot of the *live-in-manager* state. Audit found the CSVs were already at full deity
coverage (the 2026-06-09 codegen shipped all 32 deities into `LoadRowsForDeity`; names verified
against the runtime `ldName ==` block in the 2026-06-10 manager backup). The actual gap was not
missing deities but THIN, often one-sided per-deity tables.

Ruling (user, 2026-06-14): enrich for RICHNESS of experience, broaden each being across more of
daily life, and ensure every deity AND prince is TWO-SIDED (authentic likes AND dislikes). Inversion
is per-being and welcome -- an inverted god (Void, ruin, plots, the hunt, domination, madness, the
thief) LIKES what order-gods condemn and DISLIKES preservation/order/comfort. The 4.3/deity/day cap
plus 0.7^n repeat decay protect pacing, so breadth is safe; authenticity, not over-feed, was the bar.

## 2. Scope

- The "~48" decomposes as 32 focusable deities (V1 CSV) + 16 Daedric paths (V2 Princes CSV).
- BOTH tables were enriched (user brought princes in scope: "per deity/prince").
- The Daedric Princes V2 layer keeps `stanceGate = PathOpen` on every row (deepen-an-open-path only;
  never initiates). Faucet-carried / curse / HARD acts (366 vampire-feed, 367 cannibalize,
  354 persuade, 363 pickpocket) were treated as FORBIDDEN -- no ambient rows added for them.

## 3. Before / after

| Table | Before (data rows) | After | Added |
|---|---|---|---|
| `PDV_DeityLikesDislikes.csv` (32 deities) | 188 | 315 | +127 |
| `PDV_DeityLikesDislikes_Princes_V2.csv` (16 paths) | 99 | 160 | +61 |
| **Total** | 287 | 475 | **+188** |

Two-sided actors: **30 / 48 before -> 48 / 48 after.** Every formerly zero-dislike being gained an
authentic dislike side: Julianos (6/0 -> 7/4), magnus (5/0 -> 5/2), Mephala-deity (6/0 -> 7/3),
Mephala-path (6/0 -> 8/3), Hermaeus Mora (7/0 -> 10/2, see section 6).

## 4. Method

- 96 agents total via a draft -> adversarial-verify pipeline (one loremaster drafter + one strict
  lore/balance reviewer per actor). The reviewer defaulted to REJECTING filler; it killed forced
  "inversions" and off-theology rows (e.g. a Kyne anti-sleep penalty, Z'en scoring generic combat,
  Hircine "discover-location" cartography), preserving authentic inversions.
- A transient server-side rate-limit failed 12 verify agents (drafts survived); those 12 were
  re-verified in a second gentle pass (12 agents). All 48 actors carry a verdict.
- Merge into the CSVs was deterministic and idempotent: schema/band/sign/cap/gate/dedup/ASCII
  enforced; 0 rejects on the final merge; 11-column integrity and ASCII-only confirmed.
- Magnitude discipline held to the locked band policy (small +/-0.25..0.5 cap2-3 cd0;
  medium +/-0.75..1.0 cap1-2 cd0.5; large +/-1.5..2.0 cap1 cd1.0; large reserved for defining acts).

## 5. Detection status of the new rows

Most new rows use LIVE (proven-receiver) events. The following 11 new rows use PENDING-detection
events (theologically apt, but INERT until the router/receivers are extended -- they score nothing
until then, exactly like the matrix's "build CLEAN first" guidance):

- 334 harvest-ingredient: Kynareth(+), The Hist(+), Hermaeus Mora-path(+)
- 335 mine-ore-or-chop-wood: Zenithar(+)
- 351 clear-bounty-serve-time: Mara(+), Stendarr(+), Zenithar(+), Boethiah-path(-), Hermaeus Mora-path(-)
- 303 kill-animal-noncombat: Hircine-path(+), Meridia-path(-)

No new row uses a FORBIDDEN event. No row was added for an (actor,eventId) pair that already existed.

## 6. The Hermaeus Mora exception (resolved)

Mora's verifier refused to fabricate a dislike, arguing the all-knowing AMORAL archive opposes
nothing a player routinely does ("better one-sided than fabricated"). Per the user's two-sided
directive, two DELIBERATE thin dislikes were authored by hand, tied to Mora's actual domains
(memory and the record) rather than generic morality:

- 314 sleep-in-bed (-, small): oblivious sleep surrenders memory; the keeper of memory gains nothing.
- 351 clear-bounty-serve-time (-, small, PENDING): buying the record clean offends the keeper who
  suffers nothing to be unwritten.

These are a documented designed stretch, not emergent from the theology faucet. Mora is now 10/2.

## 7. Constraints honored

- `pdv_likesdislikes_gen.mjs` and `pdv_princeld_gen.mjs` NOT run; `LIKES_DISLIKES_VERSION` /
  `PRINCE_LD_VERSION` NOT bumped. The CSVs are intentionally inert until the held codegen lands.
- No edit to `PDV__ManagerQuest.psc` or `race-sheets/PDV_RaceContent_Manifest.md` (voice pass owns).
- No ESP write. ASCII-only. Actor strings exact-matched to the runtime `DeityName` set.

## 8. Next step (for the later consolidated manager pass -- NOT this session)

After the Voice Conformance Pass ports + recompiles the manager: re-run `pdv_likesdislikes_gen.mjs`
(bump `LIKES_DISLIKES_VERSION`) and `pdv_princeld_gen.mjs` (bump `PRINCE_LD_VERSION`), then prove on
a fresh save. Optionally extend the router/receivers for the PENDING events in section 5 to light up
those 11 rows.
