# Devotion - the mod, plus optional per-mod quest patches

This archive is the whole distribution. Install it with your mod manager and run the
installer; there is no separate core download.

- **Devotion core installs automatically.** It is a required part of the installer, not an
  option you can miss.
- **The 77 per-mod patch options are optional.** Each one is locked to its source plugin: if
  the mod it patches is not active in your load order, the option cannot be selected and
  nothing for it is installed.

Place `Devotion.esp` late in your load order by hand rather than letting LOOT decide. Do not
keep `PDV_AuthoriaARR_Combined.esp`, `PDV_QuestReactionMatrix_ARR.json`, or any older Devotion
compatibility package alongside this one -- those overwrite Devotion's core scripts.

Most options install a single per-mod reaction channel. Five install an ESP:

- Aetherium Forge Destroys Items installs `PDV_Patch_AFDI.esp`, an observer quest, its
  `.seq`, and its script. Load it after `Aetherium Forge Destroys Items.esp` and
  `Devotion.esp`.
- Daedric Shrines AIO installs `PDV_Patch_DaedricShrinesAIO.esp` and matching BOS swaps.
  Load the patch after `Devotion.esp`.
- Once We Were Here, War's Folly, and Whispers of the Depths each install an ESL-flagged
  dialogue-fragment patch. Load each `PDV_Patch_*.esp` after its named source quest plugin.

Keeping all five `PDV_Patch_*.esp` files below `Devotion.esp` and below their source
plugins satisfies those master and override relationships. Thieves Guild Alternative
Endings remains data-only: its quest-stage adapter is JSON, not an ESP.

## Included patch integrations

- Above All Else
- Aetherium Forge Destroys Items
- Baba Yaga and the Labyrinth
- Bards Reborn - Student of Song
- Bark and Bite
- Become a Bard
- Before the End
- Beyond Skyrim - Bruma
- Calling the Watchmaker
- Caught Red Handed - Quest Expansion
- College of Winterhold - Quest Expansion
- DAc0da
- Daedric Shrines AIO prayer activators
- Defeat the Dragon Cult
- Depths of the Soul
- Destroy the Acolyte Priests
- Destroy The Dark Brotherhood - Quest Expansion
- Ebony Blade Curse
- Forsworn Conspiracy - Quest Expansion
- Glenmoril
- Gore - A Companion Mod
- Heart of the Reach
- Hunt for the Spectre
- Ill Met by Moonlight - Dialogue Expansion
- Immersive Kaidan AIO
- Infiltration - Quest Expansion
- Inigo
- Innocence Lost - Quest Expansion
- Interesting NPCs SE (3DNPC)
- Kaidan 2
- Khajiit Will Follow
- Legacy of the Dragonborn
- Legends of Aetherium
- Lucien
- M'rissi's Tails of Troubles
- Merlin the Corgi
- Moon and Star
- Moonpath to Elsweyr
- Nilheim - Misc Quest Expansion
- Olenveld
- Once We Were Here
- Paarthurnax - Quest Expansion
- Penitus Oculatus
- Project AHO
- Redcap the Riekling
- Remiel
- Return Aegisbane
- Revealing Rune
- Sa'chil - Custom Voiced Khajiit Follower
- Save the Icerunner
- Siege at Icemoth
- Sirenroot
- Skyrim Extended Cut - Saints and Seducers
- Sleepwalking Into A Nightmare
- Song of the Green - Auri
- The Thalmor's Shadow - Taliesin
- Taste of Death Addon
- The Forgotten City
- The Frozen Heart
- The Gift of Saturalia
- The Gray Cowl of Nocturnal
- The Heart of Dibella - Quest Expansion
- The Rot Below
- The Sinister Seven
- The Tools of Kagrenac
- The Whispering Door - Quest Expansion
- There Is No Umbra - Chapter III
- Thieves Guild Alternative Endings
- Thieves Guild For Good Guys
- Thogra
- Unslaad
- Val Serano - Pirate Follower and Quest Adventure
- Vigilant
- War's Folly
- Whispers of the Depths
- Wyrmstooth
- Xelzaz

## KID integrations

- Skyrim and Dragonborn food, drink, trade goods, hunt trophies, funerary
  offerings, Orcish equipment, and Divine amulets
- Requiem
- Requiem - Food and Beverages Redone

KID identifies additional Green Pact meats from the Requiem food stack and applies
Devotion's seven item-action families wherever configured names match.

## SPID integrations

- Skyrim religious orders, temples, named adherents, cultural institutions, and
  explicit Daedric cult cohorts
- Dragonborn Reclamation temple cohorts

SPID adds only Devotion faith keywords and hidden recognition factions. It does not
distribute AI packages, aggression, spells, perks, outfits, or inventory.

## In game

When a patched quest reaction fires, its source mod is named in the Prisma toast and retained
on the matching Book of Days entry. One resolved act produces at most one reaction toast and
one Book entry, even when several deities respond. A separate Chronicle entry can appear when
the act also causes a real tier transition.

Report anything that looks wrong on the mod page rather than assuming it is your load order.
