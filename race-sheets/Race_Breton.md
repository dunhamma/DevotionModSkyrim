# Breton

**Status:** Player-facing companion sheet. Implementation authority lives in `PDV_RaceDesign_Breton.md`, `PDV_TargetEndStates_1.0.md`, and `references/PDV_RaceArchitecture_DesignReference.md`; reward numbers remain tunable.

> Half the court prays at the chapel. The other half meets in the cellar. Some attend both.

## Who They Worship

Bretons are Tamriel's religious pragmatists. Their culture holds Imperial Divines, elven heritage gods, druidic nature spirits, and forbidden witchcraft in uneasy coexistence — sometimes within the same family. A Breton knight might worship Stendarr publicly while his sister communes with Hircine's coven in the Glenmoril Wyrd.

This isn't hypocrisy. It's *syncretism* — the genuine Breton belief that divine truth has many faces, and that a clever worshipper can navigate between them. The risk is that clever navigation sometimes becomes dangerous exposure.

## How Devotion Works for Bretons

**Worship type:** Three-Track Tradition — your primary identity is *which tradition you walk*, not which god you pick from a list.

**Your first choice:** Align with one of three Breton religious traditions. This is the spine of your devotional life — it determines which unique mechanics apply to you, what the system watches for, and how curse states land.

| Tradition | Character | Unique Track |
|-----------|-----------|--------------|
| **The Knight's Road** | Civic honor, protective justice, selfless service | KnightlyVowIntegrity |
| **The Hidden Art** | Occult practice, Daedric dealings, double lives | WitchcraftExposure |
| **The Green Way** | Druidic covenant, standing stones, nature rites | Druidic Standing |

**Broad worship** within your tradition can reach **Faithful**. Within each tradition, you may later commit to a specific deity as a focused flavor layer — adding depth to your tradition rather than replacing it. This focused commitment unlocks **Devoted**.

**The three traditions can pull against each other.** A knight tempted by witchcraft feels their vow integrity strain. A druid exposed as a witch loses standing. The drag is asymmetric: Hidden Art behavior damages the Knight's Road sharply, while Green Way and Knight's Road tension is milder and easier to narrate as honorable difference. The tension between traditions is part of the Breton experience — maintaining balance is harder than it looks.

## The Three Traditions

### The Knight's Road
*For those who serve with honor and ask nothing in return.*

Your tradition is civic virtue, protective justice, and selfless action within the Imperial Divines framework. The knightly orders of High Rock are your spiritual ancestors.

- **What you do:** Complete quests with merciful, helpful outcomes. Protect the vulnerable. Decline payment when possible. Uphold justice. Avoid dishonor.
- **What you get:** Blessings of protective virtue — strongest when defending others or acting without reward.
- **The feel:** A Breton whose faith is proved through selfless action, whose word is bond, and whose honor is measured in what they gave up.

**KnightlyVowIntegrity** — Your vow starts full and degrades through dishonorable acts:
- Joining the Thieves Guild (heavy damage)
- Joining the Dark Brotherhood (severe damage)
- Unprovoked killing of innocents (moderate damage per event)
- Abandoning a quest to help an NPC in need (moderate damage)

Low integrity sharply reduces devotion gain from your patron. Rebuilding requires genuine acts of mercy, justice, and shrine visits with clean hands.

**Focused deity options within the Knight's Road:** Stendarr (mercy, righteous rule), Akatosh (time, order, loyalty), Mara (love, compassion), Arkay (death rites, life cycle), Julianos (wisdom, study), Zenithar (honest work), Kynareth (nature, travel), Dibella (beauty, art)

### The Hidden Art
*For those who deal with darker powers behind a respectable facade.*

Your tradition is the occult undercurrent of Breton society — Glenmoril covens, hedge-witchcraft, Daedric bargains maintained behind a mask of respectability. The risk isn't divine punishment. It's being *caught*.

- **What you do:** Complete Daedric quests. Aid cults. Pursue occult milestones. Oppose the Vigilants of Stendarr.
- **What you get:** Contextual favors from Daedric patrons — growing stronger as commitment deepens, but social cost rises with it.
- **The feel:** A Breton walking the knife's edge between respectability and ruin.

**WitchcraftExposure** — A reputation tracking how *visible* your occult practice is:

| State | What it means | Effect |
|-------|---------------|--------|
| **Hidden** (0-25) | No one knows | Full practice, no social cost |
| **Suspected** (26-50) | Someone's noticed | Mild social friction, Vigilants watching |
| **Known** (51-75) | You're marked | Actively hunted, most distance themselves |
| **Notorious** (76-100) | Full social rupture | Daedric rewards *accelerate* — total isolation as total commitment |

Exposure rises from Daedric quest completion (+15), being caught by Vigilants (+20), reaching Tier 2 Daedric devotion (+10), or killing Vigilants (+25). It falls slowly over time (-1/day) and faster through maintained public Divine worship as cover (-5 per sustained period).

**Focused patron options within the Hidden Art:** Hircine (hunt, beast-shape), Hermaeus Mora (forbidden knowledge), Namira (outcast darkness), Nocturnal (shadow-oaths), and other Daedric princes accessible through the Daedric system.

### The Green Way
*For those who hear the Earthbones speak.*

Your tradition is the druidic covenant — Y'ffre worship through nature-site rites, standing stone observance, and wilderness attunement. This is the Breton's elven blood remembering older gods than the Divines.

- **What you do:** Visit standing stones and grove-like wilderness sites. Practice respectful wild living. Rotate between sacred outdoor locations (no immediate repeating at one site).
- **What you get:** Nature-aligned blessings — strongest in the wild, fading behind walls.
- **The feel:** A Breton whose temple is the standing stone circle and whose prayer is silence under ancient trees.

**Druidic Standing** — Your relationship with Y'ffre's covenant, tested most dramatically by curse states (see below).

**Focused deity options within the Green Way:** Y'ffre (primary), Magnus (magical heritage), Phynaster (elven longevity)

## The Daedric Question

Bretons have the most *legible* relationship with Daedric worship of any human race. Where Nords see taboo and Imperials see civic betrayal, Bretons see... complicated tradition. Witchcraft is woven into their culture through the Glenmoril Wyrd, hedge-magic, and generations of occult families.

- **Hircine** — Legible through Glenmoril. The most "natural" werewolf path in all of Tamriel for a witch-tradition Breton.
- **Hermaeus Mora** — Legible through scholarship and secret-seeking. Costly but culturally intelligible.
- **Namira** — Legible through outcast heritage. Dangerous but not alien.
- **Nocturnal** — Shadow bargains fit Breton margins but stain public standing.
- **Azura, Mephala** — More legible than for most humans. Still risky.

For Hidden Art Bretons, Daedric worship is the *core devotional act* — but managed through the WitchcraftExposure system. The deeper you go, the more powerful AND the more dangerous. For Knight's Road and Green Way Bretons, Daedric engagement damages their primary tradition (vow integrity or druidic standing).

## Curse States

Breton curse states are **uniquely tradition-dependent** — the same curse lands completely differently based on which path you walk:

### Vampire

| Tradition | Impact |
|-----------|--------|
| **Knight's Road** | Horror. The Nine Divines are lost. Knightly oaths broken. Social rupture. No theological home. |
| **The Green Way** | Absolute excommunication — the *worst* possible outcome. Y'ffre devotion halts entirely. If cured: difficult ritual restoration (visit ancient outdoor site, make Pact-consistent offering, begin slow rebuilding). Permanent scar remains. |
| **The Hidden Art** | Partial home. Volkihar court acceptance. Witch-mother tolerance. The *least* devastating vampire landing of any tradition. |

### Werewolf

| Tradition | Impact |
|-----------|--------|
| **Knight's Road** | Silent discomfort. No framework. Social penalty, no theological home for the beast. |
| **The Hidden Art** | **Natural fit.** Glenmoril is family. Hircine is already in frame. This is the smoothest werewolf experience in the entire mod. |
| **The Green Way** | **The Druidic Trial fires.** A genuine theological fork — unique in the whole mod: |

**The Druidic Trial** (Green Way + Werewolf only):

After your first transformation, the tradition splits and demands a choice:

- *"The beast serves the Green"* — Your druidic tradition accepts the shape as deepened beast-kinship. Y'ffre resumes at full rate. Hircine path permanently closes. You declared loyalty.
- *"Hircine's gift is mine"* — Druidic tradition rejects you. Excommunication begins. Y'ffre closes. Hircine drift begins. WitchcraftExposure rises.

This fork exists because Druidic Circles in the lore are genuinely split on werewolfism. You get to make the choice the Druids themselves argued about.

## Playing This Race — What to Expect

Playing a Breton in Devotion feels like choosing a life and then feeling it *tested*. Your tradition defines your spine, but the world constantly offers reasons to cross boundaries.

A Knight's Road Breton feels the pull of the Thieves Guild corroding their vow integrity — each dishonorable act measurably weakening the divine relationship they've built. A Green Way Breton faces the werewolf fork as one of the mod's most dramatic theological moments — a permanent choice with real consequences in either direction. A Hidden Art Breton manages exposure like a spy manages cover — every Daedric act is devotionally powerful but socially dangerous, and the system tracks exactly how visible you've become.

The Breton experience is defined by *reputation sensitivity* and *tradition tension*. The three paths can pull against each other. What you do in the shadows matters differently than what you do in the light. And the game always knows the difference.

The unique strength of Breton is that you're never just building devotion — you're *maintaining a position*. Every other race asks "how devoted are you?" The Breton asks "how devoted are you, and what did it cost you to stay that way?"
