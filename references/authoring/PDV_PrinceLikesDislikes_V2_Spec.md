# PDV Prince Likes/Dislikes — V2 Path-Gated Layer (Spec)

**Created:** 2026-06-09 (Claude, continuing Codex's likes/dislikes work)
**Companion data:** `references/authoring/PDV_DeityLikesDislikes_Princes_V2.csv`
**Status:** CONTENT AUTHORED + **ENGINE WIRED 2026-06-09** (compiled FAIL=0). The V2
path-gated loader + fan-out are live in Papyrus (see "Engineering — DONE" below). V1 is
unchanged. In-game runtime proof still pending (no behaviour change to uncommitted players).

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
| What an act feeds | the player's ambient `PDV.PietyToday` pool (→ dawn bank) | the **path's OWN piety** (`AdjustStoredPiety` → path tiers/boons/prices), NOT the ambient V1 pool |
| Can it start the relationship? | yes (build from zero) | **no** — deepen an **already-open path** only |
| Gate | race-native (`IsRaceNativeForPlayer`) | **path-open** (`HasCommitmentSignalGateOpen`, i.e. committed) |
| Cost | none | stigma stays on the deliberate commitment/quest layer (ambient V2 does not auto-add stigma) |

Every row carries `stanceGate = PathOpen`. **Implementation note:** the gate is enforced
in `PDV_DaedricPathBase.ScorePrinceAction` (`if !HasCommitmentSignalGateOpen() return 0.0`);
an open path's act deepens that path's *own* piety. (We do **not** call `AddCommitmentSignal`
here — once the gate is open, more signals are moot; the path's piety is the progression
currency. The lock's "never initiate" is satisfied because an uncommitted path scores 0.)

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

## Engineering — DONE 2026-06-09 (compiled FAIL=0)

1. **Generator:** `tools/pdv_princeld_gen.mjs` reads this CSV, strips the `Daedric:` prefix
   to match `PDV_DaedricPath_*.DeityName` (verified values: Hircine, Namira, Molag Bal,
   Mehrunes Dagon, Hermaeus Mora, Clavicus Vile, Sheogorath, Meridia, Nocturnal, Peryite,
   Sanguine, Vaermina), and emits `LoadPrinceRowsForPath` (12 paths / 74 rows).
2. **Table namespace:** `WritePLD` writes `PDV.PLD.<evt>.{D,C,O}` on the path form —
   **separate** from the V1 `PDV.LD.*` deity table, so the two never collide and Prince rows
   never leak into the race-gated V1 `ScoreFromTable`.
3. **Scorer:** `PDV_DaedricPathBase.ScorePrinceAction(eventType)` — path-open gate
   (`HasCommitmentSignalGateOpen`) + the shared dawn-aligned `ScoreRepeatableAction`
   anti-farm (`dailyCap`/`cooldown`).
4. **Fan-out:** `PDV__ManagerQuest.RouteActionToOpenPaths` iterates
   `PDV_FLST_DaedricPaths_All`; an open path's act → `path.AdjustStoredPiety(delta)`
   (deepen the path's own progression). Hooked into `PDV_EventBus.RouteActionWithAttribution`
   (live) and `PDV_ActionRouter` (fallback), after the deity fan-out.
5. **Version gate:** `EnsurePrinceLikesDislikesTable` / `PRINCE_LD_VERSION = 1`, called from
   the same OnInit + slow-tick sites as the V1 `EnsureLikesDislikesTable` (existing saves
   reload on a bump). Re-run the generator + bump `PRINCE_LD_VERSION` when this CSV changes.

**Curse coordination:** Hircine (kill-beast) / Molag Bal (vampire-feed) deepen *path piety*,
which is a different channel from the curse-state **transition** system — so there is no
double-fire of curse transitions to guard against here. (If a future curse-state piety hook
is added, re-check.) Marked in the CSV `notes` for traceability.

**Remaining:** in-game runtime proof — open a Prince path (≥3 commitment signals), perform a
liked ambient act, confirm `[PDV] PrinceV2: <Prince> event <id> deepen <x>` and path-piety
progression; confirm an *unopened* path scores nothing (deepen-not-initiate); confirm a
non-native player's ambient act still does not touch the path pre-commit.

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
