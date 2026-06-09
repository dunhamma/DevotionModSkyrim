# PDV Prince Likes/Dislikes — V2 Path-Gated Layer (Spec)

**Created:** 2026-06-09 (Claude, continuing Codex's likes/dislikes work)
**Companion data:** `references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv`
**Status:** CONTENT AUTHORED (reference). **Not wired into runtime** — the V2 path-gated
loader/routing is the engineering follow-on (below). Authoring this does NOT change V1.

## Why this is a separate layer (not the V1 CSV)

`PDV_DeityLikesDislikesMatrix.md` §8 + Decision #2 **LOCK** the 12 transgressive Daedric
Princes *out* of the V1 ambient day-to-day matrix. Two reasons, one design one mechanical:

1. **Design (the lock's intent):** ambient acts must never *initiate* transgressive
   worship — "a stray lockpick must not drift a Nord toward Molag Bal." Transgressive
   devotion is deliberate and chosen (commitment-signal + stigma), never accrued.
2. **Mechanical (why V1 can't even hold them):** the V1 generator (`pdv_likesdislikes_gen.mjs`)
   emits `LoadRowsForDeity` keyed by `DeityName` over `PDV_FLST_AllDeities`. The 12
   transgressive Princes exist as `PDV_DaedricPath_*` actors, **not** `PDV_Deity_*` forms
   in that FormList — so Prince rows in the V1 CSV would be **dead code**. And the
   race-native gate (Decision #6) zeroes any non-native deity's ambient score anyway; the
   Princes are native to no race via their deity face.

So this layer is the **V2 face**: the same authoring shape, gated and routed differently.

## V2 semantics (what the engine must honor)

| Aspect | V1 (accepted patrons) | V2 (this layer) |
|---|---|---|
| What an act feeds | `Piety` directly | a **commitment signal** (`AddCommitmentSignal`), NOT piety |
| Can it start the relationship? | yes (build from zero) | **no** — deepen an **already-open path** only |
| Gate | race-native | **path-open** (the `stanceGate = PathOpen` column) |
| Cost | none | stigma (race-scaled, existing `GetStigmaModifierForRace`) |

Every row carries `stanceGate = PathOpen`: the engine applies it **only** when the player
has already opened/committed that Prince's path. On an open path, the act deepens the
commitment; off-path, the row is inert.

## Relationship to the faucet system (do not double-count)

The Princes' **primary** repeatable signals are their **faucet acts** (Part D / the faucet
detection work): drink (Sanguine), feed/cannibalize (Namira), harvest dreams (Vaermina),
bear disease (Peryite), wear Masque / win bargain (Clavicus), read Black Book (Mora). This
V2 layer adds **ambient breadth** (kills, transgressions, artifact claim, study) on top —
it does not replace the faucets. Rows whose concept is faucet-carried are marked in `notes`
and kept `reference only` where detection is HARD (cannibalize 367, persuade 354). Do not
fire both the faucet and a V2 row for the same act.

## Curse coordination (locked rule)

Hircine and Molag Bal arrive via curse (werewolf / vampire). Their V2 kill/feed rows
(`kill-hostile-beast`, `vampire-feed`) **must coordinate with the curse-state rows and not
double-fire curse transitions** (existing rule, §8.4). Marked in the CSV `notes`.

## Detection status of the events used

All eventIds are the 300+ vocabulary (§4). Wired (Codex's receivers): kills (1/2/300/301/
302/304), reads (341/342), sleep (313/314), craft (330/333), increase-skill (344),
discover-location (345), pick-lock (360), trespass (361, root pending), assault (364),
learn-word (343), accept-daedric-artifact (368). **Unwired / faucet-carried (reference
rows):** vampire-feed (366, MODERATE), cannibalize-corpse (367, HARD), persuade-success
(354, HARD). These are authored for completeness; they score nothing until detection +
the V2 loader exist.

## Engineering follow-on (to wire V2)

1. **Loader variant:** a `LoadPrinceRowsForPath(path)` (or extend the generator with a
   `--princes` mode reading this CSV) that writes the `PDV.LD.*` keys onto the
   `PDV_DaedricPath_*` actor when its path is open.
2. **Routing:** on a scored act for an open Prince path, route the delta to
   `AddCommitmentSignal(...)` (deepen), **not** `AwardPiety`. Respect the `PathOpen` gate
   and the per-row `dailyCap`/`cooldown` via the existing `ScoreRepeatableAction` anti-farm.
3. **Stigma:** apply `GetStigmaModifierForRace` so off-race transgressive worship stays
   costly.
4. **Curse guard:** gate Hircine/Molag Bal kill/feed rows behind the curse-state check so
   they don't double-fire transitions.
5. **Bump** a `PRINCE_LD_VERSION` (parallel to `LIKES_DISLIKES_VERSION`) when this CSV
   changes; re-run the loader.

## Coverage
12 transgressive Princes, ~4-5 ambient rows each (~50 rows): Mehrunes Dagon, Hircine,
Meridia, Molag Bal, Hermaeus Mora, Namira, Nocturnal, Peryite, Sanguine, Sheogorath,
Vaermina, Clavicus Vile. The 4 *accepted* Prince faces (Azura/Boethiah/Mephala/Malacath/
Azurah) stay in the V1 CSV — they are full patrons, not this layer.

## Acceptance (content)
- ASCII-safe; schema matches the V1 CSV (so a V2 generator can reuse the parser).
- Every row `PathOpen`-gated; faucet-carried/HARD rows marked reference-only.
- Curse-coordinated rows flagged.
- No transgressive Prince added to the V1 CSV / ambient piety.
