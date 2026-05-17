# Bosmer

> The Pact was not a promise. It was a contract. And contracts have terms.

## Who They Worship

Bosmer religion is built on Y'ffre — the Earth-Bones, the god who gave the world its shape and made a specific covenant with the Bosmer people. But unlike most races, Bosmer don't choose from a pantheon of interchangeable gods. They choose *how they relate to the covenant itself*.

The Green Pact is the defining theological fact of Bosmer life: Y'ffre gave them form in exchange for specific obligations. In Valenwood, this means strict dietary and ecological rules. In Skyrim exile, the question becomes — how much of that old contract do you still carry? And what fills the space if you don't?

## How Devotion Works for Bosmer

**Worship type:** Multi-Path (closed system) — not a pantheon of gods to choose between, but four distinct *interpretations* of Bosmer religious life.

**Setup choice:** At the start of play, you choose one of four devotional paths. This is the central decision for a Bosmer character — more defining than any other race's initial choice.

**Path switching is possible but costly.** You're not permanently locked, but changing paths requires meaningful threshold events and carries real spiritual cost. The Old Contract is hardest to leave and hardest to re-enter. The Living Story is the easiest bridge between paths.

## The Four Paths

### The Old Contract — Strict Y'ffre Orthodox
*The Pact is the Pact. You obey or you break.*

- **What you do:** Hunt with respect. Protect forests from desecration. Maintain ecological balance. Honor carcass-respect practices. Anti-desecration quest choices.
- **What you get:** The highest devotion ceiling of any Bosmer path. Powerful blessings tied to the primal covenant between Y'ffre and the Bosmer people.
- **The feel:** A Bosmer who carries the full weight of the Green Pact in exile. Harder. Narrower. But deeper than any other Bosmer will ever reach.
- **The catch:** This is the only path with hard compliance mechanics. The Pact has terms, and breaking them matters. You earn more, but you carry more burden. Uses PDV's own Green Pact tagging layer rather than depending on another mod's food or ecology tags.

**Path commitment is binary.** Taking the Pact (`PactBound = true`) makes Y'ffre your exclusive deity; other Bosmer-recognized gods freeze at their current devotion and remain inert until you leave. There is no "partial Pact" — you are bound or you are not.

**Compliance bands while bound.** GreenPactCompliance is a 0–100 meter, act-driven, no passive decay. It scales Y'ffre devotion gains by band: Apostate (0–19) locks gains out entirely, Lapsed (20–49) at 50%, Observant (50–79) at 100%, Strict (80–100) at 120%. Single accidental violations do not lock you out — they cost compliance, not membership.

**Forced reckoning.** When compliance stays in Apostate for three consecutive in-game days, the mod surfaces a one-shot prompt: re-commit (compliance snaps to 30) or renounce. No silent auto-renunciation — the decision is always yours.

**One cycle, then the door closes.** You may leave the Pact and return exactly once. The second renunciation — voluntary or forced — is terminal: Y'ffre's ledger freezes permanently, and the Pact toggle disables. The other Bosmer gods remain open; only the Pact itself closes. See `references/PDV_BosmerPactModel_Planning.md` for the full transition spec.

### The Living Story — Moderate Y'ffre
*The forest speaks. You listen. But you live in the world as it is.*

- **What you do:** Visit forest sites and wilderness locations. Maintain community ties. Protect kin. Preserve continuity. Practice respectful living without strict Pact enforcement.
- **What you get:** Broader, steadier blessings. Strengthened by secondary gods (Arkay, Xarxes, Mara, Stendarr) who round out the moderate Y'ffre reading.
- **The feel:** A Bosmer whose faith is diaspora spirituality — genuine Y'ffre devotion adapted to exile rather than failed orthodoxy. Not "Y'ffre-lite" but Y'ffre *translated*.
- **Note:** Uses high-confidence detectable triggers only. The mod is honest about what Skyrim can observe.

### The Exchange — Z'en
*What is owed must be returned. What is taken must be balanced.*

- **What you do:** Settle debts. Restore balance through redress. Pursue proportional vengeance. Complete justice-restoring quest resolutions.
- **What you get:** Blessings of reciprocal justice — strongest when restoring balance or settling what's owed.
- **The feel:** A Bosmer for whom justice is the first principle and commerce is its language. Not a merchant path — a *balance* path.
- **Note:** Killing for payment doesn't count. Looting for profit doesn't count. This is theological justice, not economic gain.

### The Bandit Road — Baan Dar
*When the world rejects you, survival becomes devotion.*

- **What you do:** Survive through cunning. Escape authority. Aid other outcasts. Win through cleverness rather than force. Complete exile-survival quest outcomes.
- **What you get:** Favors tied to road life, evasion, and the divine reward for staying alive when everything says you shouldn't.
- **The feel:** A Bosmer for whom the road itself is sacred — survival as prayer, cunning as worship.
- **Note:** Distinct from Rajhin (polished trickster mystique) and Nocturnal (criminal oath cult). This is raw survival, not art or shadow-dealing.

## Secondary Religious Layer

All Bosmer paths have access to secondary gods who influence devotion without replacing the primary path:
- **Arkay** — death order and proper passage
- **Xarxes** — ancestry and record-keeping
- **Mara** — community bonds and protection
- **Stendarr** — mercy and restraint

These are strongest on The Living Story path but present across all four.

## The Daedric Question

Bosmer have their own native trickster-survival theology through Baan Dar, which means they don't *need* most Daedric princes to fill that role. The distinction matters:

- **Baan Dar** — Native. The Bosmer trickster-survival path is a legitimate religious lane, not a crime spree.
- **Hircine** — Legible but not orthodox. Beast-shape is intelligible to Bosmer theology as external pressure without being welcomed. Note: the Wild Hunt is canonical horror, not a player-facing devotional track — it is the lore reason the Pact exists, never a state the mod invites you into.
- **Nocturnal** — Foreign. The Thieves Guild's Nightingale oath is a *Skyrim criminal* overlap, not Bosmer theology. Baan Dar is the native alternative.
- **Hermaeus Mora** — Foreign. Bosmer Herma-Mora is kept explicitly separate from the general knowledge-corruption reading.
- **Azura, Mephala** — Foreign but intelligible. Not core Bosmer, but not alien either.
- **Molag Bal** — Taboo. Hard theological break across all paths.

## Curse States

**Vampire — hard break across all paths:**
Vampirism is a harder theological break than werewolfism for Bosmer. All four paths are damaged. No Bosmer path accommodates undeath naturally.

**Werewolf — path-dependent:**

- *The Old Contract:* Serious theological violation. Hircine provides an illicit rival route to shapeshifting that echoes the Wild Hunt without Y'ffre's sanction. The Pact treats this as breach.
- *The Living Story / The Exchange / The Bandit Road:* Contested strain rather than automatic collapse. The Wild Hunt linkage makes werewolfism *intelligible* to Bosmer theology — it doesn't make it approved, but it's not the catastrophe it would be under strict Pact reading.

## Path Switching

Switching between Bosmer paths is possible but not casual:

- **The Living Story** is the easiest bridge path — it accepts transfers most readily.
- **The Old Contract** is the hardest to leave and the hardest to re-enter. The Pact is governed by an explicit one-cycle rule: you may leave and return exactly once, and the second renunciation closes Y'ffre permanently. See the Old Contract section above and `references/PDV_BosmerPactModel_Planning.md` for full mechanics.
- **The Exchange** and **The Bandit Road** sit between those poles.

Switching into or out of the Living Story, Exchange, or Bandit Road requires meaningful threshold events and carries real spiritual cost. Entering or leaving the Old Contract is gated by a qualifying in-world act plus an MCM confirmation — the toggle exists, but the friction is structural rather than purely UI.

## Playing This Race — What to Expect

Playing a Bosmer in Devotion feels like **path divergence** rather than pantheon selection. Your initial choice doesn't just change which god you focus on — it changes what the mod *watches for* and what it rewards. A Bandit Road Bosmer and an Old Contract Bosmer are playing functionally different devotional games.

The Old Contract is the prestige path — highest ceiling, heaviest burden. It asks you to engage with Skyrim's ecology deliberately rather than passively. The Living Story is the broadest and steadiest experience. The Exchange makes justice-facing quests feel theologically loaded. The Bandit Road turns survival into worship.

The Bosmer experience is defined by *commitment to interpretation*. Every race in the mod asks "which god?" — the Bosmer asks "which version of yourself?"
