# Khajiit

**Status:** Player-facing companion sheet. Implementation authority lives in `PDV_RaceDesign_Khajiit.md`, `PDV_TargetEndStates_1.0.md`, `references/PDV_RaceArchitecture_DesignReference.md`, and `references/phase4/PDV_DaedricRacePrinceMatrix.csv` for Daedric response; reward numbers remain tunable.

> **Current implementation (2026-08-06):** Your first focused god now emerges
> automatically at Seeker with one ceremonial popup, a toast, and a pinned Book
> entry; it is not silently permanent-broad worship. The current god in strength
> does not grant a rotating stat spell or extra piety. If that god matches your
> focus, Lattice Resonance strengthens the focused numeric blessing by 20%.
> Azurah Champions gain the once-daily Portent lesser power; Baan Dar Champions
> gain the guarded once-daily rescue to 50% Health. The road itself is home: any
> completed, uninterrupted outdoor sleep qualifies, with sleep-start context
> authoritative. Older phase, road-home-circuit, silent-emergence, and reward
> descriptions later in this companion sheet are superseded by this notice and
> `PDV_RaceDesign_Khajiit.md`.

> The moons do not ask to be worshipped. They simply are. And so, beneath them, are you.

## Who They Worship

Khajiit religion isn't chosen — it's *inhabited*. The Lunar Lattice (Riddle'Thar, ja-Kha'jay, Jone, Jode) isn't a god you pray to. It's the cosmological structure that determines what you *are*. The moons decided your furstock at birth. They define Khajiit biology, identity, and place in creation.

Within this cosmic order, specific deities serve as expressions of different aspects of Khajiit life: Azurah (twilight, fate, threshold), Khenarthi (wind, guidance, the road), Baan Dar (survival, exile cunning), Rajhin (artful trickery, legend-making), and Alkosh (dragon-order, cosmic stability).

A Khajiit in Skyrim is an exile from Elsweyr's religious infrastructure, living on the road, excluded from hold-temple worship, maintaining connection to the moons under an alien sky.

## How Devotion Works for Khajiit

**Worship type:** Layered Lunar — you're always inside the cosmic order. The question is how deeply you emphasize one face of it.

**No setup choice needed.** All Khajiit begin inside the Lunar Lattice automatically.

- **Layer 1 (always active):** Lunar substrate — moon observance, road life, exile identity. This is cosmological, not optional.
- **Layer 2 (natural broadening):** Major gods within the lattice. Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh — all reachable.
- **Layer 3 (focused commitment):** One deity becomes your strongest emphasis. Unlocks Devoted.

**Broad lunar worship** (Layer 1-2 without focused emphasis) can reach **Faithful**. **Devoted** emerges when one deity's domain has clearly become your life — but you never formally choose it.

**Key distinction:** Khajiit are the only race that never makes a formal commitment to a patron. There is no popup, no shrine event, no "Azurah notices you" moment. Instead, the system silently detects that you've been consistently living one deity's life — and begins weighting them more heavily. The cat was always walking that path. The moons already knew.

This reflects the lore: Khajiit gravitate toward specific gods through life-role (magicians toward Azurah, travelers toward Khenarthi, tricksters toward Rajhin), not through temple declarations. Your patron emerges from who you are, not from what you choose.

## The Lunar Substrate (Always Active)

This is what makes Khajiit unique. Before any focused path, every Khajiit maintains:

**Moon observance** — Acknowledging the sky at dawn, dusk, or night. Not a prayer schedule — a moment of awareness under the visible sky. One or two opportunities per day.

**Open-road exile life** — Sleeping outdoors. Traveling at night. Living outside hold-temple infrastructure. Road life is devotional and practical at once — for a Khajiit, the road *is* the temple.

**Khajiit community ties** — Helping caravans. Protecting Khajiit traders. Supporting marginalized Khajiit. Community solidarity strengthens the substrate.

These aren't separate from focused worship — they *feed into it*. A Khajiit who maintains strong substrate is always building toward deeper devotion regardless of which focused path they eventually choose.

## Emergent Paths

These aren't chosen — they're *recognized*. The system watches your behavior and silently shifts weight toward whichever deity your actions align with. You may notice stronger blessings appearing in a particular domain before you consciously realize you've been living that god's life.

### Azurah — The Twilight Mother
*For those who feel fate's pull and honor the threshold between states.*

- **What you do:** Complete Azura's Star quest. Honor twilight moments. Cross thresholds deliberately.
- **What you get:** Favors tied to fate, liminal moments, and the protection of crossing safely between states.
- **The feel:** A Khajiit who stands where day becomes night and feels the world's hinges.
- **Accessibility:** One of the most routinely reachable focused paths. Strong quest anchor.

### Khenarthi — The Wind Guide
*For those who walk the road with mercy and guidance.*

- **What you do:** Travel the open road. Complete rescue and mercy quests. Guide the lost. Maintain open-sky movement.
- **What you get:** Blessings of wind, travel, and safe passage — strongest when moving, fading when static.
- **The feel:** A Khajiit whose devotion is motion itself, whose mercy is arriving when needed.
- **Accessibility:** Very reachable. Synergizes naturally with the road-life substrate.

### Baan Dar — The Pariah Survival
*For those who survive by wit when the world offers nothing.*

- **What you do:** Complete exile-mercy quests. Aid outsiders. Achieve evasive success against authority. Win through clever reversal rather than force.
- **What you get:** Favors of pariah resilience — strongest when outmatched and outnumbered.
- **The feel:** A Khajiit who turns rejection into a kind of prayer, whose cleverness is a gift from a god who was himself rejected.
- **Accessibility:** Reachable through specific quest outcomes. Not a generic crime path.

### Rajhin — The Trickster Legend
*For those who steal beautifully and make their name ring.*

- **What you do:** Complete Thieves Guild milestones. Pull off elegant thefts. Build notoriety through style rather than volume. Quest-driven, not petty-theft farming.
- **What you get:** Favors of artful infamy — strongest when the theft is worthy of a story.
- **The feel:** A Khajiit playing for *legend*, not profit. Every job is a performance.
- **Note:** Distinct from Baan Dar (survival cunning) and Nocturnal (criminal oath). Rajhin is *art*.
- **Accessibility:** Behavior-specific. Requires style-gated milestone achievements, not generic stealing.

### Alkosh — The Dragon-Order
*For those who face cosmic chaos and hold the line.*

- **What you do:** Complete main quest dragon milestones. Resolve anti-chaos situations. Face world-threatening forces.
- **What you get:** The rarest religious privileges in the Khajiit system — cosmic weight and dragon-order recognition.
- **The feel:** A Khajiit who holds the world's seams together. Alkosh doesn't notice common deeds.
- **Accessibility:** The rarest and highest-threshold focused path. Should feel *rare*.

## The Daedric Question

Khajiit have an unusually nuanced relationship with Daedric forces because several "Daedric" figures are actually *native* to Khajiit theology under different names:

| Prince | Khajiit treatment | What that means in play |
|---|---|---|
| **Azurah** | Native | Core lunar theology. Not "Daedric worship" in Khajiit terms, and one of the main focused emphases. |
| **Boethra** | Native where supported | Can sit inside the Khajiit frame when explicitly chosen, but does not replace the lunar substrate. |
| **Mafala** | Native where supported | Culturally meaningful as hidden wisdom and social web, but distinct from generic crime. |
| **Malacath** | Foreign | Not a standard lunar lane. Outcast strength can be understood, but it is not Khajiit religion. |
| **Meridia** | Foreign | Anti-undead service can be respected situationally, but it cannot replace moon order. |
| **Hircine** | Curse-access | Beast-shape strains belonging. Moon-identity remains, but the shape is contested and needs cure or controlled distancing. |
| **Molag Bal** | Curse-access | Vampirism corrupts and weakens belonging. The lattice remains, but caravan and community compatibility suffer. |
| **Nocturnal** | Taboo | External shadow pressure even for a thief. Rajhin is the native trickster alternative. |
| **Hermaeus Mora/Hermorah** | Legible | Culturally intelligible as dangerous knowledge, but should not overwrite the lunar substrate. |
| **Mehrunes Dagon** | Taboo | Chaos and ruin conflict with lunar order except as dark pressure. |
| **Sheogorath/Sheggorath** | Taboo | Dark-pressure figure, not normal lunar lane. Keep distinct from Rajhin-style play. |
| **Namira/Namiira** | Legible dark pressure | Exists as a dark mythic pressure, not baseline devotion. Withdraw or cleanse rather than normalize. |
| **Sanguine/Sangiin** | Legible dark pressure | Temptation is intelligible inside the mythic field, but not a core path. |
| **Clavicus Vile** | Foreign | Trickster overlap exists, but Vile is not native cleverness and should not replace Baan Dar or Rajhin. |
| **Peryite** | Foreign | Burden and affliction can be familiar, but this is not a normal lunar lane. |
| **Vaermina** | Foreign | Dream pressure can occur, but it is not native primary devotion. |
- **Baan Dar** — Native. The survival god is not a Prince by the usual reckoning.
- **Rajhin** — Native. Khajiit-specific. Not a generic thief-Prince.

The key insight: for Khajiit, the line between "Daedric" and "native" is drawn differently than for any other race. Azurah, Boethra, and Mafala aren't foreign — they're *family*.

## Curse States

**Vampire:**
The lunar substrate remains active but corrupted and weakened. Normal Khajiit devotion doesn't collapse entirely — identity is cosmological and biological, so vampirism *damages belonging* rather than erasing it. Caravan and community compatibility reduces sharply. Azurah remains a possible protective reading. Nocturnal drift increases as a shadow substitute.

**Werewolf:**
The lunar substrate remains mostly intact but strained. Hircine adds an off-moon shape rather than fully severing Khajiit identity. Caravan and community belonging is damaged but not destroyed. Khajiit devotion remains recognizably Khajiit, but under pressure.

Both curses are less devastating for Khajiit than for many other races — identity is too cosmologically deep to fully break. But "less devastating" still means real damage to belonging and community.

## The Lunar Cycle

The substrate reward isn't static — it *cycles with the moons*. Masser and Secunda move through their phases, and each phase shifts what type of reward is strongest for the Khajiit:

- Different phases favor different aspects of Khajiit life (road-travel, community, reflection, focused deity work)
- Each phase can grant its own temporary emphasis, but your overall substrate strength is determined by *consistent compliance across the full cycle* — not just spiking during one favorable phase
- When the moons overlap or oppose each other, special spiritual states emerge — moments of heightened awareness or tension that a Khajiit would feel in their bones
- The current phase is always visible to the player via the power menu, with flavor text when the cycle shifts

The cycle gives Khajiit devotion a rhythm that no other race has. Other races accumulate steadily. Khajiit *breathe* — the moons inhale and exhale, and living in sync with that rhythm is what the substrate rewards. A Khajiit can enjoy a phase-favored bonus without being deeply aligned overall, but the strongest lunar life requires both: honoring the current phase and staying faithful across the whole cycle.

## Road Homes

Unlike other races who might designate a single sacred place, the Khajiit can establish **multiple rest points** — 2 to 3 locations along their road that serve as spiritual anchors. This mirrors caravan-route thinking: a Khajiit isn't tied to one place. They have a *circuit*.

Returning to your road homes between journeys strengthens the substrate. The rhythm of departure and return — road and rest, road and rest — is itself devotional. A Khajiit who never returns to their rest points is adrift. One who cycles between them reliably is walking the moons' own path.

## Moon Sugar

Moon sugar has religious significance in Khajiit theology. The mod acknowledges this but handles it carefully — only in limited, curated, high-confidence ways. It doesn't become a frequent devotion trigger because Skyrim can't reliably distinguish ritual use from contraband handling.

## Playing This Race — What to Expect

Playing a Khajiit in Devotion feels like being **cosmologically held** even before you make any commitment. The lunar substrate means you're never spiritually homeless — the moons are always there, the road always counts, and community solidarity always registers.

What makes Khajiit unique is that there's no "commitment moment." Other races eventually face a decision — "do you accept this god's offer?" The Khajiit never does. Instead, one day you notice your blessings have shifted. The favors coming your way taste like Khenarthi's wind, or Azurah's twilight, or Rajhin's luck. You were always walking that path. You just didn't name it yet.

The distinctive Khajiit feel is that *exile is already worship*. Where other races lose something in Skyrim's wilderness, a Khajiit's road-life feeds their faith. The caravan isn't just economic — it's religious community. The open sky isn't just scenery — it's a temple roof.
