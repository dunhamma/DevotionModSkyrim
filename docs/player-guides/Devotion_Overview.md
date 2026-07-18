# Devotion

The gods of Tamriel are not vending machines. They do not care which shrine you tap on your way past. They watch how you actually live and fight: the storm you walked into, the burial rite you said over a stranger, the oath you kept when it would have been easier to break it. Devotion is a mod about being noticed by the divine for who you really are.

## What Is Devotion

Devotion is a faith system that grows out of your play, not your menus. Every god in your character's world keeps a quiet account of your deeds. Honor a god through the way you travel, fight, trade, mourn, and worship, and your standing with that god rises on its own. There are no chores to grind and no prayer button to spam. You just play your character, and the right god starts to pay attention.

## How It Works (in a nutshell)

Your standing is tracked separately for every god. Pleasing Kyne does nothing for Mara, and an act that delights one god may mean nothing to another. Your race shapes the whole experience: which gods matter to you, what counts as a faithful deed, and how worship even feels. A Nord earns Kyne's regard out on the storm-lashed roads; a Khajiit answers to the moons.

You earn standing simply by playing in a way your god respects. As that standing grows, you climb through three named tiers:

- **Seeker** - the god has noticed you. The first small blessings arrive.
- **Devoted** - the relationship is real and steady, with stronger gifts.
- **Champion** - the god has claimed you. This is recognition, not just a bigger number.

Each tier brings lasting blessings, the occasional fleeting "favor" when you act faithfully in the moment, and a growing sense that something is watching over the way you live.

## What Makes It Different

Most blessing mods hand you a free buff for clicking a statue. Devotion does three things differently.

**The gods react to real behavior.** Standing comes from how you play, judged against what that specific god values. You cannot fake it, and you cannot rush it.

**The theology runs deep and is different for every race.** A Nord's faith feels nothing like a Khajiit's, which feels nothing like a Dunmer's. These are not reskins of the same system. Each race has its own gods, its own idea of a faithful life, and its own way of falling out of grace.

**Faith carries weight, not just upside.** Devotion can cost you. Neglect a god and the small graces fade. Some bargains, especially with the Daedric Princes, come with a real price. Standing is something you earn and keep, not a switch you flip.

## Feature Highlights

- **Per-god standing.** Every god tracks you separately, so your faith reflects your real choices rather than one universal piety score.
- **Ten fully distinct races.** Altmer, Argonian, Bosmer, Breton, Dunmer, Imperial, Khajiit, Nord, Orc, and Redguard each have their own gods, deeds, and feel.
- **Three reward tiers.** Seeker, Devoted, and Champion, each opening new blessings and recognition.
- **Daedric pacts with real prices.** All sixteen Daedric Princes present as temptation, bargain, and stigma, not as free power.
- **Neglect and curse consequences.** Let a relationship lapse, or fall under a curse like vampirism or lycanthropy, and your faith responds.
- **An in-game Devotion panel and journal.** Read your standing through the Devotion panel's Patron, Today, and Book of Days views, plus short notification toasts as things change.
- **MCM options.** Tune your experience and reach developer and debug tools through the standard SkyUI menu.

### A note on the bonuses

Note: these are current beta values and may be tuned before release.

At the Seeker tier, blessings are deliberately gentle - small steadying gifts, not build-defining ones. A Nord on the old roads finds the weather companionable (Fortify Stamina +15). A Dunmer in good standing with the Reclamations is warded against magic (Magic Resistance +5%). An Orc who keeps Malacath's code is harder to put down (Armor +15). A Khajiit inside the Lunar Lattice is simply kept hardy (Disease Resistance +5%). Devoted and Champion tiers build on these with stronger and more characterful gifts. Your race guide lists the exact figures for every tier of every god your people can follow.

Bonuses are given as flat pools and resistances rather than percentage regeneration rates. That is deliberate: it keeps them meaningful under overhauls like Requiem, which switch passive regeneration off entirely.

One thing worth knowing before you commit: a patron god's own blessing begins at the Devoted step. Up until then, the blessing you carry is your people's broad one - the Old Ways, a Breton tradition, the Lattice - and that one does start at Seeker.

How standing accrues is just as deliberate. Each god can warm to you by only a limited amount per day, so faith grows over a campaign rather than in an afternoon. Repeating the exact same deed earns less and less each time, so variety in how you honor a god matters far more than grinding one trick. Reaching Champion takes roughly 30 to 45 days of normal play, perhaps one or two devotional acts a day, or around 20 days if you focus hard. Only one temporary favor blessing can be active at a time across all your gods. And worshipping broadly, honoring several gods at once, caps you at Devoted: to be claimed as a Champion you must commit to a single god.

## Your Race, Your Gods

Every race plays its own faith. Start with your character's race below, then read its guide for the gods, deeds, and rhythms that shape your path.

- **Altmer** - orthodox devotion to Auri-El, Magnus, and Xarxes, lived under the long shadow of Lorkhan and the Thalmor's demands. See the Altmer race guide.
- **Argonian** - the Hist comes first, with People and the cold pull of the Void behind it. See the Argonian race guide.
- **Bosmer** - Y'ffre and the Green Pact, the living story, and the trickster road of Baan Dar. See the Bosmer race guide.
- **Breton** - a single chosen tradition: knightly vow, hidden art, or the old Green Way. See the Breton race guide.
- **Dunmer** - the Reclamations of Azura, Boethiah, and Mephala, layered over ancestor reverence. See the Dunmer race guide.
- **Imperial** - civic faith in the Nine, lawful service, and the private question of Talos. See the Imperial race guide.
- **Khajiit** - the moons and the Lunar Lattice, the road home, and gods like Azurah, Rajhin, and Alkosh. See the Khajiit race guide.
- **Nord** - the Old Ways or the Nine Divines, Kyne on the storm and Talos in defiance. See the Nord race guide.
- **Orc** - Malacath's hard code, lived through the stronghold, the city, or the legion. See the Orc race guide.
- **Redguard** - the ancestors' regard and the death-duty of Tu'whacca, pulled between Crown, Forebear, and Ash'abah. See the Redguard race guide.

## Requirements and Compatibility

### Required (install and load these first)

- **SKSE64** - the script extender everything is built on; match it to your Skyrim Special Edition version.
- **PapyrusUtil** - the data library Devotion stores your standing in. Without it, piety cannot be saved.
- **powerofthree's Papyrus Extender** - the runtime hooks Devotion reads your deeds through.
- **powerofthree's Tweaks** - a supporting dependency for the Papyrus Extender chain.
- **Address Library for SKSE Plugins** - lets the SKSE plugins load on your game version.
- **SkyUI** - provides the in-game MCM, where you set the panel hotkey and reach settings.

### Recommended (optional)

- **Prisma UI** - the interface framework the in-game Devotion panel is drawn with. Devotion ships the panel's own views and its bridge, but not the framework itself. Without Prisma UI the mod plays normally and the MCM still reports your standing; you simply do not get the Devotion panel, its Book of Days journal view, or its toasts.
- **A survival or needs mod** - Skyrim's built-in Survival Mode, Frostfall, or Sunhelm all work. Devotion plays fully without one, but several outdoor, weather, and rest blessings are felt more keenly when cold, exposure, and hunger actually matter, because there is more for your faith to push against. A survival mod only ever shapes how rewards feel; it never changes how piety is earned.

### Compatibility

- **Devotion replaces other religion systems.** Run it instead of another deity-worship or religion overhaul, not alongside one. Stacking two religion systems is not supported.
- **It respects your load order** and is balanced with Requiem's scale in mind. List-specific compatibility patches for major overhaul setups are in development; if you run a heavy overhaul or modlist, check the compatibility notes for your setup before installing.

## Getting Started

Install the requirements above, add Devotion, and start a new game. Devotion needs a save that has never had it installed; adding it partway through a playthrough is not supported. For setup help and your first steps, see the FAQ and Quick Start article. To understand what the gods are actually watching and how standing grows, read the How Devotion Works primer, then dive into your race's guide.

## A Note on Scope

This build focuses on the systems: per-god standing, race-specific theology, blessings, favors, and consequences that respond to how you play. Some flavor, such as new voiced NPC dialogue, is planned for later rather than promised today. What ships now is meant to make your faith feel earned and alive.
