# PDV Faucet Discoverability Spec (L3b)

**For:** Codex (Panel payload + helper). **From:** Claude. **Status:** spec + copy.
**Problem:** faucets are invisible — a player has no way to learn what repeatable acts feed
a thin/Daedric god. **Solution:** surface them on the **Prisma Panel**, not the race
survey (faucet gods are cross-race Daedric/thin; the race survey is patron-by-race and the
wrong home).

Copy source for act labels = `PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` (`act`
column). Exclude any act with `buildability == DEFERRED` (no vanilla hook) so we never
advertise an undetectable act.

---

## 1. Where it surfaces

- **Panel Rites** (`GetPanelRitesJson` ~1402) — when the faucet god **is the active
  patron**: a Rites group "Keep <God>'s rites" listing the buildable faucet acts (label +
  one in-voice body line each).
- **Panel Relations** (`GetPanelRelationsJson` ~1418) — when the god is **approachable but
  not active** (its artifact is owned, e.g. Ring of Namira / Sanguine Rose / the Masque): a
  single Relations hint that the path exists.
- **Not** the medallion hint (stays terse/diegetic, not a tutorial) and **not** the race
  survey.

---

## 2. Per-god copy

Format per act: `label` (from Part D `act`) — `body` (new, in-voice, legible).

### Namira — active Rites
- **Feed on a corpse** — The Ring's hunger, kept once a day.
- **Eat human flesh** — What others revile sustains you.

Relations (Ring owned, not patron): `The Ring's hunger waits; Namira would have you feed.`

### Sanguine — active Rites
- **Drink to excess** — A cup raised in his name, once a day.
- **Summon the Sanguine Rose** — Loose a daedra with his gift.

Relations (Rose owned): `The Rose is yours; Sanguine keeps the revel open to you.`

### Peryite — active Rites
- **Bear an untreated affliction** — Carry the sickness; do not pray it away.
- **Ward with Spellbreaker** — Hold the line behind his shield.

Relations (Spellbreaker owned): `Spellbreaker answers; Peryite tallies the patient.`

### Vaermina — active Rites
- **Harvest dreams** — Reap with the Skull of Corruption.

Relations (Skull owned): `The Skull thirsts; Vaermina waits in the sleeping mind.`

### Clavicus Vile — active Rites
- **Wear the Masque** — Keep the bargain's edge at your brow.

Relations (Masque owned): `The Masque is yours; Clavicus keeps the terms open.`
(Note: "Win a favorable bargain" is quest-situational, not a standing rite — omit from the
list; it scores when it happens but is not advertised as a repeatable act.)

### Hermaeus Mora — active Rites
- **Read a Black Book** — Each book's forbidden knowledge, once.
- **Study rare and forbidden tomes** — Feed the archive its due.

Relations (a Black Book held): `Apocrypha leans close; Mora would have you read on.`

### Dibella — active Rites
- **Adorn in fine apparel** — Wear beauty as devotion.
- **Give alms to a beggar** — Grace shown to the low.
- **Marry or court** — Honor love and the vow.

Relations (broadly devout): `Dibella favors grace; beauty kept is beauty offered.`

(Excluded as DEFERRED: Dibella "Perform music or create art" — no vanilla hook.)

---

## 3. Integration note for Codex

- Add a Panel helper `GetFaucetActsForDeity(deity)` that reads the act **labels** from the
  compiled faucet JSON (`faucet.[key].act`) so the list stays single-sourced with the
  matrix; the **body** strings live with this spec (or a small string table keyed by act).
- Render under Rites only when `deity == active patron`; gate each act on
  `buildability != DEFERRED`. Some acts also have an artifact precondition (Ring/Rose/
  Skull/Spellbreaker/Masque) — show the act regardless (it tells the player what to seek),
  but the Relations hint is what fires in the artifact-owned-but-not-patron state.
- Panel JSON: add fields, never rename/remove. A Rites item already carries a
  title/body shape — reuse it; add `kind:"faucet"` if useful for styling.
- Keep bodies panel-line-safe (≈ <= 48 chars renders cleanly at panel width; confirm
  against the live Rites item rendering before shipping).

---

## 4. Reference mockup (Namira active)
```
RITES — Keep Namira's rites
  Feed on a corpse      The Ring's hunger, kept once a day.
  Eat human flesh       What others revile sustains you.
RELATIONS
  Stendarr turns his face from you.
```

## 5. Acceptance
- Each faucet god's buildable acts appear under Rites only when it is the active patron;
  DEFERRED acts never shown.
- Approachable-not-active state shows the single Relations hint.
- Labels single-sourced from the faucet JSON; bodies ASCII-safe, panel-length-safe.
- Nothing surfaces on the race survey.
