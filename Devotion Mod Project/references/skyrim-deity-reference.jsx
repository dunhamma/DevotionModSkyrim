import { useState } from "react";

const gods = [
  // ==========================================
  // THE NINE DIVINES
  // ==========================================
  {
    id: 1,
    domain: "Sun, Light, Time, Governance",
    imperial: "Akatosh",
    nordic: "Auri-El",
    altmeri: "Auri-El",
    bosmer: "Auri-El",
    dunmer: "Auri-El (rejected)",
    khajiit: "Alkosh",
    redguard: "—",
    orcish: "—",
    argonian: "Akha (partial)",
    notes: "Chief deity of the Eight/Nine Divines. Auri-El is the Aldmeri name for effectively the same being. Alkosh is the Khajiit Dragon-King of Cats. Dunmer acknowledge Auri-El but reject his primacy in favour of the Tribunal. Argonians have Akha the First Serpent — a dragon-time deity who wandered the stars (see own row). Redguard and Orcish cultures have no direct equivalent; their chief deities are Ruptga and Malacath respectively.",
    tier: "divine",
  },
  {
    id: 2,
    domain: "Magic, Wisdom, Knowledge, Logic",
    imperial: "Julianos",
    nordic: "Jhunal",
    altmeri: "Syrabane (partial)",
    bosmer: "—",
    dunmer: "Sotha Sil (parallel)",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "God of wisdom and logic. Jhunal is the old Nordic rune-god of language and hermetic orders, largely abandoned in favour of Shor. The Dunmer parallel is Sotha Sil, the Clockwork God of reason (see Tribunal section). Altmer associate Julianos loosely with Syrabane. Bosmer, Khajiit, Redguard, Orcish, and Argonian cultures have no recorded direct equivalent.",
    tier: "divine",
  },
  {
    id: 3,
    domain: "Commerce, Communication, Work",
    imperial: "Zenithar",
    nordic: "Tsun (labour aspect)",
    altmeri: "Z'en",
    bosmer: "Z'en",
    dunmer: "Zenithar (Imperial import)",
    khajiit: "Zenithar (Imperial import)",
    redguard: "Zeht",
    orcish: "—",
    argonian: "—",
    notes: "God of work and commerce. Z'en is the Bosmeri version. Zeht is the Redguard equivalent — god of toil and agriculture, though far more bitter and punitive in character (see own Redguard row). Dunmer and Khajiit acknowledge Zenithar mainly through Imperial contact. Orcish labour is attributed to Malacath's trials, not a commerce deity. Argonians have no recorded equivalent.",
    tier: "divine",
  },
  {
    id: 4,
    domain: "Love, Beauty, Art, Music",
    imperial: "Dibella",
    nordic: "Dibella",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Dibella (Imperial import)",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Goddess of beauty and erotic art. Primarily Imperial/Nordic with no native equivalents in Bosmer, Dunmer, Redguard, Orcish, or Argonian traditions. Khajiit adopt Dibella loosely through Imperial cultural contact. Dunmer beauty ideals fall under Mephala's seductive portfolio.",
    tier: "divine",
  },
  {
    id: 5,
    domain: "Sky, Air, Nature, Storms",
    imperial: "Kynareth",
    nordic: "Kyne",
    altmeri: "Kyne",
    bosmer: "Y'ffre (overlapping)",
    dunmer: "—",
    khajiit: "Khenarthi",
    redguard: "Tava",
    orcish: "—",
    argonian: "Tsun-Kali (partial)",
    notes: "Goddess of air and nature. Kyne is the Nordic form — 'the Widow of Shor,' considered the true High God of the Nords. Khenarthi is the Khajiit wind and death-guide goddess (see own Khajiit row). Tava is the Redguard sky-bird goddess (see own Redguard row). Argonians have Tsun-Kali, a serpentine marsh goddess (see own Argonian row). Dunmer have no direct sky goddess; that domain falls under Azura's twilight. Orcish tradition assigns no sky deity.",
    tier: "divine",
  },
  {
    id: 6,
    domain: "Mercy, Justice, Law, Charity",
    imperial: "Stendarr",
    nordic: "Stuhn",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "S'rendarr",
    redguard: "Onsi (partial)",
    orcish: "—",
    argonian: "—",
    notes: "God of mercy and righteous rule. Stuhn is the Nordic shield-thane of Shor associated with ransom and fair dealing. S'rendarr is the direct Khajiit name for this deity — god of mercy and compassion. Onsi covers the Redguard martial-code aspect (see own row). Altmer, Bosmer, Dunmer, Orcish, and Argonian cultures have no recorded equivalent.",
    tier: "divine",
  },
  {
    id: 7,
    domain: "Life-Death Cycle, Burials, Souls",
    imperial: "Arkay",
    nordic: "Arkay",
    altmeri: "Xarxes",
    bosmer: "Xarxes",
    dunmer: "Arkay (Imperial import)",
    khajiit: "Khenarthi (death aspect)",
    redguard: "Tu'whacca",
    orcish: "Arkay (Imperial import)",
    argonian: "Xol (partial)",
    notes: "God of the life-death cycle and the right of burial. Xarxes is the Altmeri scribe-god who records the dead (see own Aldmeri row). Tu'whacca is the Redguard soul-guide — a far more personal death deity (see own Redguard row). Khajiit place death under Khenarthi's wing. Dunmer and Orcs acknowledge Arkay mainly through Imperial contact. Argonians associate the corrupted boundary of life and death with Xol the Worm (see own Argonian row).",
    tier: "divine",
  },
  {
    id: 8,
    domain: "War, Honour, Strategy",
    imperial: "Talos (war aspect)",
    nordic: "Tsun / Talos",
    altmeri: "—",
    bosmer: "Ius (conflict aspect)",
    dunmer: "Vivec (warrior aspect)",
    khajiit: "Alkhan",
    redguard: "HoonDing",
    orcish: "Malacath",
    argonian: "Sithis (conflict aspect)",
    notes: "War does not map to a single deity uniformly. HoonDing is the Redguard Make-Way god who manifests in a mortal when obstacles must be overcome (see own row). Tsun is the Nordic god of trials in combat. Vivec is the Dunmer warrior-poet god. Alkhan is the Khajiit Devourer-king. Ius is the wrathful Bosmeri Animal God. Argonians relate all conflict and change to Sithis (see own row).",
    tier: "divine",
  },
  {
    id: 9,
    domain: "Kingship, Empire, Mankind",
    imperial: "Talos (Tiber Septim)",
    nordic: "Talos / Ysmir",
    altmeri: "Rejected / heresy",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Disputed",
    orcish: "—",
    argonian: "—",
    notes: "Deified man-hero and god of mankind's dominion. Ysmir ('Dragon of the North') is his Nordic aspect. Altmer reject him outright as heresy — driving the Thalmor ban that ignites the Civil War. Bosmer, Dunmer, and Argonians have no native equivalent to a deified human emperor. Redguard opinion is deeply split. Khajiit lore alludes to a figure called Ragnthar but this is extremely obscure.",
    tier: "divine",
  },
  {
    id: 17,
    domain: "Love, Compassion, Family",
    imperial: "Mara",
    nordic: "Mara",
    altmeri: "Mara",
    bosmer: "Mara",
    dunmer: "Almalexia (aspect)",
    khajiit: "Mara",
    redguard: "Morwha",
    orcish: "—",
    argonian: "—",
    notes: "One of the most universally shared goddess figures — appearing nearly identically across Imperial, Nordic, Aldmeri, and Khajiit cultures. Morwha is the distinct Redguard goddess of love and fertility — four-armed, wife of Tall Papa (see own Redguard row). Dunmeri maternal devotion falls under Almalexia. Orcish culture has no goddess of romantic love. Argonians attribute all community bonds to the Hist collective.",
    tier: "divine",
  },
  // ==========================================
  // ALDMERI / ELVEN GODS
  // ==========================================
  {
    id: 10,
    domain: "Magic, The Sun, The Creator's Retreat",
    imperial: "Magnus",
    nordic: "Magnus (the sun)",
    altmeri: "Magnus",
    bosmer: "Magnus",
    dunmer: "Magnus",
    khajiit: "Magnus",
    redguard: "Magnus",
    orcish: "Magnus (acknowledged)",
    argonian: "—",
    notes: "The god who drew the schematics for Mundus and fled to become the sun. His departure tore the Veil of Mundus, creating the sun and the stars (his fellow Magna Ge). Shared almost universally across elven and human pantheons by the same name — one of the few truly pan-Tamrielic deities. Argonians have no recorded equivalent; their cosmology centres on the Hist and Sithis.",
    tier: "aldmeri",
  },
  {
    id: 11,
    domain: "Patron of Altmer, Elven Warrior-Champion",
    imperial: "—",
    nordic: "—",
    altmeri: "Trinimac",
    bosmer: "—",
    dunmer: "Malacath (corrupted)",
    khajiit: "—",
    redguard: "Mauloch (corrupted)",
    orcish: "Malacath",
    argonian: "—",
    notes: "Trinimac was the strongest of the Aldmeri gods and champion of Auri-El. He was devoured and excreted by Boethiah, his form corrupted into Malacath. His followers who ate Boethiah's excrement became the Orsimer (Orcs), who now worship him as Malacath. Redguards know the corrupted form as Mauloch, god of outcasts and curses.",
    tier: "aldmeri",
  },
  {
    id: 12,
    domain: "Nature, The Green, Song, Stories",
    imperial: "—",
    nordic: "—",
    altmeri: "Jephre (early form)",
    bosmer: "Y'ffre",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "Hist (parallel)",
    notes: "The first spirit to become Ehlnofey (Earth Bones). The eternal storyteller who fixed the nature of living things and gave the Bosmer their form, enforcing the Green Pact. Also called Jephre in early Aldmeri texts. The Hist serves a parallel role for Argonians as a living divine network that defines and calls back their souls. All other cultures have no equivalent Green-God.",
    tier: "aldmeri",
  },
  {
    id: 13,
    domain: "Time, Elven Ancestry, Memory, Records",
    imperial: "—",
    nordic: "—",
    altmeri: "Xarxes",
    bosmer: "Xarxes",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Scribe-god and keeper of the Book of Life and Book of Hours. Created by Auri-El to record all great deeds. Uniquely Aldmeri/Bosmeri — his record-keeping role is not replicated in other cultures' pantheons. Dunmer use Tribunal ancestor rites instead. All other cultural entries are legitimately blank.",
    tier: "aldmeri",
  },
  {
    id: 36,
    domain: "Elven Longevity, Protection, Patron of High Elves",
    imperial: "—",
    nordic: "—",
    altmeri: "Phynaster",
    bosmer: "Phynaster",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "The Altmeri patron deity who taught the High Elves to take shorter steps to live longer lives — extending their already considerable lifespan. A hero-deity primarily of the Summerset Isles. Also worshipped by Bosmer. Credited with creating the Isle of Vvardenfell's barrier in some accounts. Unique to elven tradition with no equivalents in other cultures.",
    tier: "aldmeri",
  },
  {
    id: 37,
    domain: "The Sea, Magical Wards, Plague-Warding",
    imperial: "—",
    nordic: "—",
    altmeri: "Syrabane",
    bosmer: "Syrabane",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "The Aldmeri Warlock's God — also called the Apprentice's God. A mortal Aldmer who achieved divinity by saving the elves from the Thrassian Plague through masterful ward magic. Associated with the sea and magical protection. His Ring of Syrabane is one of the most powerful artifacts in existence. Uniquely Aldmeri/Bosmeri with no equivalents in other cultures.",
    tier: "aldmeri",
  },
  // ==========================================
  // DUNMERI TRIBUNAL
  // ==========================================
  {
    id: 14,
    domain: "Wisdom, Machinery, Logic (Tribunal)",
    imperial: "Julianos (parallel)",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "Sotha Sil",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "One of the three Dunmeri god-kings. The Clockwork God — a mortal ascended to godhood via the Heart of Lorkhan. Creator of the Clockwork City and student of all laws of nature. His combination of magic, reason, and clockwork machinery is unique to Dunmeri theology. Murdered by Almalexia at the end of the Tribunal's age. All non-Dunmer entries are legitimately blank.",
    tier: "tribunal",
  },
  {
    id: 15,
    domain: "War, Poetry, Love, Lies (Tribunal)",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "Vivec",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Poet-warrior god of the Dunmer. A mortal ascended via the Heart of Lorkhan. Simultaneously a god of war, art, love, and lies — his paradoxical nature has no equivalent elsewhere. He held the Ministry of Truth (a suspended meteor) over Vivec City with divine power. Author of the cryptic Thirty-Six Lessons of Vivec. Disappeared before the events of Skyrim.",
    tier: "tribunal",
  },
  {
    id: 16,
    domain: "Motherhood, Healing, Mercy (Tribunal)",
    imperial: "Mara (parallel)",
    nordic: "Mara (parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "Almalexia",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "The Mother Morrowind. Called 'Our Lady of Mercy.' Analogous to Mara in her healing and maternal domain, though she is a mortal ascendant. Her madness after losing divine power led her to murder Sotha Sil and attempt to kill the Nerevarine, precipitating the fall of the Tribunal. All non-Dunmer entries are legitimately blank.",
    tier: "tribunal",
  },
  // ==========================================
  // DAEDRIC PRINCES
  // ==========================================
  {
    id: 18,
    domain: "Darkness, Night, Shadows, Luck",
    imperial: "Nocturnal",
    nordic: "Nocturnal",
    altmeri: "Nocturnal",
    bosmer: "Nocturnal",
    dunmer: "Nocturnal",
    khajiit: "Nocturnal",
    redguard: "Nocturnal",
    orcish: "Nocturnal",
    argonian: "Nocturnal",
    notes: "Lady Luck, the Mistress of Shadow. Patron of thieves and the Thieves Guild. Unusually consistent name and identity across all cultures. In Khajiit lore, Nocturnal is the shadow left when Lorkhaj's corrupted heart was removed — she is the darkness beneath the moons.",
    tier: "daedric",
  },
  {
    id: 19,
    domain: "Chaos, Madness, Change",
    imperial: "Sheogorath",
    nordic: "Sheogorath",
    altmeri: "Sheogorath",
    bosmer: "Sheogorath",
    dunmer: "Sheogorath (Bad Daedra)",
    khajiit: "Sheggorath",
    redguard: "Sheogorath",
    orcish: "Sheogorath",
    argonian: "Sheogorath",
    notes: "The Mad God. Name and portfolio almost perfectly consistent across all cultures. Khajiit call him Sheggorath, the Skooma Cat — believed to be the corrupted heart of Lorkhaj not fully destroyed. Dunmer classify him among the four Bad Daedra. He is actually the Hero of Kvatch from the Oblivion Crisis, who took Sheogorath's mantle.",
    tier: "daedric",
  },
  {
    id: 20,
    domain: "The Hunt, Predators, Lycanthropy",
    imperial: "Hircine",
    nordic: "Hircine",
    altmeri: "Hircine",
    bosmer: "Hircine",
    dunmer: "Hircine",
    khajiit: "Hircine",
    redguard: "Hircine",
    orcish: "Hircine",
    argonian: "Hircine",
    notes: "The Huntsman, Father of Manbeasts. Patron of lycanthropes and the Wild Hunt. Claims the souls of all his werewolves in his realm, the Hunting Grounds. Name is uniform across all cultures — one of the most consistently named Daedric Princes.",
    tier: "daedric",
  },
  {
    id: 21,
    domain: "Plots, Lies, Conspiracy, Revolution",
    imperial: "Boethiah",
    nordic: "Boethiah",
    altmeri: "Boethiah",
    bosmer: "Boethiah",
    dunmer: "Boethiah (Good Daedra)",
    khajiit: "Boethra",
    redguard: "Boethiah",
    orcish: "Boethiah",
    argonian: "Boethiah",
    notes: "Prince of Plots. Responsible for devouring Trinimac and corrupting him into Malacath. Dunmer consider Boethiah a Good Daedra — the first to teach the Chimer to turn from Auri-El toward their own destiny. Khajiit know this prince as Boethra, a warrior and rebel against oppressive cosmic rule.",
    tier: "daedric",
  },
  {
    id: 22,
    domain: "Ancient Knowledge, Forbidden Lore, Fate",
    imperial: "Hermaeus Mora",
    nordic: "Herma-Mora",
    altmeri: "Hermaeus Mora",
    bosmer: "Hermaeus Mora",
    dunmer: "Hermaeus Mora",
    khajiit: "Hermorah",
    redguard: "Hermaeus Mora",
    orcish: "Hermaeus Mora",
    argonian: "Hermaeus Mora",
    notes: "Keeper of the Apocrypha, Prince of Fate and forbidden knowledge. Nordics call him Herma-Mora — a sinister boogeyman who steals babies and tempts heroes with dark secrets. Khajiit call him Hermorah the Tidal Lord. His realm Apocrypha is an endless library of forbidden texts. Central villain of the Dragonborn DLC.",
    tier: "daedric",
  },
  {
    id: 23,
    domain: "Plague, Pestilence, Tasks, Natural Order",
    imperial: "Peryite",
    nordic: "Peryite",
    altmeri: "Peryite",
    bosmer: "Peryite",
    dunmer: "Peryite",
    khajiit: "Peryite",
    redguard: "Peryite",
    orcish: "Peryite",
    argonian: "Peryite",
    notes: "The Taskmaster. Dragon-formed Daedric Prince of disease and natural order. Despite a weak reputation among the Princes, Peryite governs the lowest-ranked Daedra and maintains the order of the natural world. His realm is the Pits. Uniform name across all cultures.",
    tier: "daedric",
  },
  {
    id: 24,
    domain: "Domination, Enslavement, Vampirism",
    imperial: "Molag Bal",
    nordic: "Molag Bal",
    altmeri: "Molag Bal",
    bosmer: "Molag Bal",
    dunmer: "Molag Bal (Bad Daedra)",
    khajiit: "Molag Bal",
    redguard: "Molag Bal",
    orcish: "Molag Bal",
    argonian: "Molag Bal",
    notes: "The King of Rape, Lord of Domination, father of vampirism. Primal enemy of Boethiah. Dunmer consider him one of the four Bad Daedra. Created the first vampire. Seeks to drag Nirn into his realm Coldharbour. Name is entirely consistent across all cultures.",
    tier: "daedric",
  },
  {
    id: 25,
    domain: "Bargains, Wishes, Trickery",
    imperial: "Clavicus Vile",
    nordic: "Clavicus Vile",
    altmeri: "Clavicus Vile",
    bosmer: "Clavicus Vile",
    dunmer: "Clavicus Vile",
    khajiit: "Clavicus Vile",
    redguard: "Clavicus Vile",
    orcish: "Clavicus Vile",
    argonian: "Clavicus Vile",
    notes: "The Prince of Bargains and wishes granted with cruel twists. His power is split with his companion Barbas — a dog who is literally a portion of Vile's own power made manifest. Uniform name across all cultures. His realm is the Fields of Regret.",
    tier: "daedric",
  },
  {
    id: 26,
    domain: "Debauchery, Pleasure, Corruption",
    imperial: "Sanguine",
    nordic: "Sanguine",
    altmeri: "Sanguine",
    bosmer: "Sanguine",
    dunmer: "Sanguine (Bad Daedra)",
    khajiit: "Sangiin",
    redguard: "Sanguine",
    orcish: "Sanguine",
    argonian: "Sanguine",
    notes: "The Prince of Debauchery, Lord of the Myriad Realms of Revelry. Khajiit call him Sangiin, god of death and secret murder — a notably darker interpretation of the same Prince. Dunmer classify him among the four Bad Daedra.",
    tier: "daedric",
  },
  {
    id: 27,
    domain: "Decay, Ancient Darkness, the Grotesque",
    imperial: "Namira",
    nordic: "Namira",
    altmeri: "Namira",
    bosmer: "Namira",
    dunmer: "Namira (Bad Daedra)",
    khajiit: "Namiira",
    redguard: "Namira",
    orcish: "Namira",
    argonian: "Namira",
    notes: "The Lady of Decay, the Spirit Daedra. Rules over all things considered repulsive — vermin, cannibalism, dark and forgotten places. Dunmer list her as a Bad Daedra. Khajiit know her as Namiira, the Great Darkness — the ancient evil that Azurah drove back when she shaped the Khajiit people.",
    tier: "daedric",
  },
  {
    id: 28,
    domain: "Destruction, Change, Revolution, Ambition",
    imperial: "Mehrunes Dagon",
    nordic: "Mehrunes Dagon",
    altmeri: "Mehrunes Dagon",
    bosmer: "Mehrunes Dagon",
    dunmer: "Mehrunes Dagon (Bad Daedra)",
    khajiit: "Merrunz",
    redguard: "Merrunz",
    orcish: "Mehrunes Dagon",
    argonian: "Mehrunes Dagon",
    notes: "Prince of Destruction, Change, Revolution, and Ambition. Triggered the Oblivion Crisis. Khajiit call him Merrunz, a reckless child-god of fire and violence cast out by Alkosh. Redguards also use the name Merrunz. Dunmer classify him as a Bad Daedra.",
    tier: "daedric",
  },
  {
    id: 29,
    domain: "Illusion, Sex, Murdering Secrets",
    imperial: "Mephala",
    nordic: "Mephala / Webspinner",
    altmeri: "Mephala",
    bosmer: "Mephala",
    dunmer: "Mephala (Good Daedra)",
    khajiit: "Mephala",
    redguard: "Mephala",
    orcish: "Mephala",
    argonian: "Mephala",
    notes: "The Webspinner, Anticipation of Vivec. Patron of the Morag Tong and spiritual progenitor of the Dark Brotherhood. Dunmer consider Mephala a Good Daedra who taught the Chimer the skills of assassins and spies necessary to survive. Nordic kenning is the Webspinner or Spinner. Governs the domain of murdering secrets — not just lies, but the kind that kill.",
    tier: "daedric",
  },
  {
    id: 30,
    domain: "Light, Beauty, Opposition to Undeath",
    imperial: "Meridia",
    nordic: "Meridia",
    altmeri: "Meridia",
    bosmer: "Meridia",
    dunmer: "Meridia",
    khajiit: "Meridia",
    redguard: "Meridia",
    orcish: "Meridia",
    argonian: "Meridia",
    notes: "Lady of Infinite Energies, ruler of the Coloured Rooms. A fierce enemy of the undead and of Molag Bal. Originally an et'Ada expelled from the Aurbis by Magnus for consorting with illicit substances related to Lorkhan. Consistent name and portfolio across all cultures.",
    tier: "daedric",
  },
  {
    id: 31,
    domain: "Dawn, Dusk, Fate, Prophecy",
    imperial: "Azura",
    nordic: "Azura",
    altmeri: "Azura",
    bosmer: "Azura",
    dunmer: "Azura (Good Daedra)",
    khajiit: "Azurah",
    redguard: "Azura",
    orcish: "Azura",
    argonian: "Azura",
    notes: "Queen of Dawn and Dusk, mother of the Rose. Dunmer patron and Good Daedra — she warned the Chimer of Tribunal treachery and cursed them with dark skin and red eyes to become Dunmer. Khajiit know her as Azurah, who shaped the Khajiit from the Wandering Ehlnofey and gave them their many moon-forms.",
    tier: "daedric",
  },
  {
    id: 32,
    domain: "Dreams, Nightmares, Memory Theft",
    imperial: "Vaermina",
    nordic: "Vaermina",
    altmeri: "Vaermina",
    bosmer: "Vaermina",
    dunmer: "Vaermina",
    khajiit: "Vaermina",
    redguard: "Vaermina",
    orcish: "Vaermina",
    argonian: "Vaermina",
    notes: "The Dreamweaver, Queen of Nightmares. Extracts memories from sleeping mortals and uses them to craft personalised horrors. Her realm is Quagmire — an eternal nightmare where reality shifts constantly. Uniform name across all cultures.",
    tier: "daedric",
  },
  {
    id: 33,
    domain: "Spurned Outcasts, Broken Oaths, Orsinium",
    imperial: "Malacath",
    nordic: "Malacath / Orkey",
    altmeri: "Trinimac (original)",
    bosmer: "—",
    dunmer: "Malacath",
    khajiit: "—",
    redguard: "Mauloch",
    orcish: "Malacath / Mauloch",
    argonian: "—",
    notes: "Patron of the spurned and ostracised. Originally Trinimac before being devoured and excreted by Boethiah. His followers who consumed Boethiah's excrement became the Orsimer (Orcs). Orcish name is Mauloch. Nordic kenning Orkey ('Old Knocker') is a trickster who stole years from men (see own Nordic row). Bosmer, Khajiit, and Argonians have no recorded equivalent.",
    tier: "daedric",
  },
  // ==========================================
  // NORDIC TRADITION
  // ==========================================
  {
    id: 34,
    domain: "The Dead, Underworld, Champion of Men",
    imperial: "Arkay (parallel)",
    nordic: "Shor",
    altmeri: "Lorkhan (negative)",
    bosmer: "Lorkhan (negative)",
    dunmer: "Lorkhan (negative)",
    khajiit: "Lorkhaj",
    redguard: "Sep",
    orcish: "Lorkhan (ambiguous)",
    argonian: "Sithis (parallel)",
    notes: "The most contested deity in all of TES lore. Shor is the Nordic hero-champion of men, now dead and feasting in Sovngarde. All elves view Lorkhan negatively — the trickster who convinced them to create the mortal world and diminish themselves. Sep is the Redguard form: a greedy serpent who tricked the other gods (see own row). Lorkhaj is the Khajiit Moon Beast whose corrupted heart birthed Sheggorath. Orcs see an ambiguous parallel in their own outcast-god narrative. Argonians map the void-and-change role to Sithis.",
    tier: "nordic",
  },
  {
    id: 38,
    domain: "Trials Against Adversity, Honour Combat",
    imperial: "—",
    nordic: "Tsun",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Shield-thane of Shor and guardian of the whalebone bridge to Sovngarde. He tests the worthy dead in single combat before permitting them to feast with Shor. God of trials against adversity — to fight Tsun and be deemed worthy is among the highest honours a Nord can achieve in death. Unique to Nordic theology with no equivalents in other cultures.",
    tier: "nordic",
  },
  {
    id: 39,
    domain: "World-Eater, Dragons, Cyclic Destruction",
    imperial: "—",
    nordic: "Alduin",
    altmeri: "Auri-El (disputed aspect)",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Satakal (thematic parallel)",
    orcish: "—",
    argonian: "—",
    notes: "First-born of Akatosh and the World-Eater. Ancient Nords revered and feared him as a god-dragon destined to devour the world at the end of time. His relationship to Akatosh is deeply disputed — some texts suggest he is Akatosh's destructive aspect, others that he is wholly separate. The Redguard Satakal (world-devouring serpent) is a strong thematic parallel. The primary antagonist of Skyrim's main quest.",
    tier: "nordic",
  },
  {
    id: 40,
    domain: "Trickery, Stolen Time, Ill Fate (Nordic)",
    imperial: "—",
    nordic: "Orkey",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "Malacath (thematic parallel)",
    argonian: "—",
    notes: "Orkey, the Old Knocker — a Nordic trickster figure associated with Malacath in some texts; both represent betrayal and ill fortune. He stole years from mortal men, cutting their lifespans, until Shor (or Ysmir Wulfharth in later accounts) defeated him and restored those years. Represents the treachery that shortens life and the ill luck that befalls men.",
    tier: "nordic",
  },
  // ==========================================
  // KHAJIIT PANTHEON (Two-Moons / Riddle'Thar)
  // ==========================================
  {
    id: 41,
    domain: "Spiritual Law, the Lunar Lattice, Cosmic Order",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Riddle'Thar",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "The Riddle'Thar is both a spiritual revelation and a divine principle — the 'Lunar Lattice' governing Khajiit society, birth-forms, and cosmic order. Revealed to the Mane Rid-Thar-ri'Datta by Azurah and/or the moons. It dictates the rules of Khajiiti existence, including which lunar phase at birth determines a Khajiit's sub-species. Unique to Khajiit theology with no equivalent in any other culture.",
    tier: "khajiit_pantheon",
  },
  {
    id: 42,
    domain: "The Big Moon (Masser), Masculine Lunar Principle",
    imperial: "Masser (acknowledged)",
    nordic: "Masser (acknowledged)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Jode",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Jode is the Khajiit name for Masser, the larger of Nirn's two moons. Together with Jone (Secunda), the moons govern all Khajiit birth-forms through the Lunar Lattice — a Khajiit's exact sub-species is determined by the lunar phase at the moment of birth. Imperial scholars call this moon Masser. In some traditions both moons are the decaying flesh of Lorkhaj.",
    tier: "khajiit_pantheon",
  },
  {
    id: 43,
    domain: "The Little Moon (Secunda), Feminine Lunar Principle",
    imperial: "Secunda (acknowledged)",
    nordic: "Secunda (acknowledged)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Jone",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "Jone is the Khajiit name for Secunda, the smaller of Nirn's two moons. Partners with Jode (Masser) in governing the Lunar Lattice and all Khajiit birth-forms. Imperial scholars call this moon Secunda. The disappearance of both moons — the Void Nights — was a catastrophe for all Khajiit, as no Khajiit could be born during that period.",
    tier: "khajiit_pantheon",
  },
  {
    id: 44,
    domain: "Warrior-King, the Devourer, Righteous Destruction",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Alkhan",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "A fearsome Khajiit deity, the Devourer — associated with righteous war and the destruction of enemies. Some texts link Alkhan to the darker and more destructive aspects of Akatosh in Khajiit theology. Distinct from Alkosh (the Dragon-King parallel to Akatosh), though the two share etymological roots and may represent two aspects of the same divine force.",
    tier: "khajiit_pantheon",
  },
  {
    id: 45,
    domain: "Wind, Weather, Death, the Breath of Khajiit",
    imperial: "Kynareth (parallel)",
    nordic: "Kyne (parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Khenarthi",
    redguard: "Tava (parallel)",
    orcish: "—",
    argonian: "—",
    notes: "Khajiit goddess of wind and weather, sister of Azurah. She ferries the souls of worthy Khajiit dead to the Sands Behind the Stars. Her domain covers both the living breath of Khajiit and the final exhalation at death — making her a sky goddess and a psychopomp simultaneously. Parallels Kynareth/Kyne but with a distinct and significant death-guide aspect those goddesses lack.",
    tier: "khajiit_pantheon",
  },
  // ==========================================
  // REDGUARD PANTHEON (Yokudan)
  // ==========================================
  {
    id: 46,
    domain: "Chief Deity, Sky, Endurance, Survival",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Ruptga / Tall Papa",
    orcish: "—",
    argonian: "—",
    notes: "The greatest god of the Yokudan/Redguard pantheon. The first to discover the 'trick of living' — how to dodge Satakal's endless devouring cycle by moving through the world cleverly. Created the stars as way-markers for lost spirits. Father of the gods in Redguard tradition, husband of Morwha. When the trick became too complicated, he created Tu'whacca to tend to the souls of the dead.",
    tier: "redguard_pantheon",
  },
  {
    id: 47,
    domain: "Souls, the Afterlife, the Far Shores",
    imperial: "Arkay (parallel)",
    nordic: "Arkay (parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Khenarthi (parallel)",
    redguard: "Tu'whacca",
    orcish: "—",
    argonian: "—",
    notes: "Redguard god of souls and guardian of the Far Shores — their eternal afterlife realm. Originally an unimportant Yokudan deity who was elevated when Tall Papa made him caretaker of the dead. Parallels Arkay in the death/afterlife domain but is distinct — Tu'whacca actively guides and tends souls rather than merely recording the cycle of life and death.",
    tier: "redguard_pantheon",
  },
  {
    id: 48,
    domain: "Love, Fertility, Abundance",
    imperial: "Mara (parallel)",
    nordic: "Mara (parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Morwha",
    orcish: "—",
    argonian: "—",
    notes: "Four-armed goddess of love and fertility, wife of Tall Papa (Ruptga). One of the most important Redguard gods — she 'grabs' men and ensures the continuation of life. Morwha is a distinct deity from Mara with her own mythology and iconography, though the two share a fertility-and-love portfolio. Central to Yokudan creation theology.",
    tier: "redguard_pantheon",
  },
  {
    id: 49,
    domain: "Swordsmanship, Martial Excellence, the Sword-Singers",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Leki",
    orcish: "—",
    argonian: "—",
    notes: "Daughter of Tall Papa and goddess of aberrant swordsmanship. She invented unorthodox blade techniques that founded the legendary Sword-Singer tradition — warriors who could destroy their enemies' weapons through pure martial skill. Her style is called Leki's Blade. Central to Redguard warrior culture and their unique martial identity. No equivalent in any other culture.",
    tier: "redguard_pantheon",
  },
  {
    id: 50,
    domain: "The World-Serpent, Cyclic Destruction and Rebirth",
    imperial: "—",
    nordic: "Alduin (thematic parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Namiira (partial parallel)",
    redguard: "Satakal",
    orcish: "—",
    argonian: "—",
    notes: "The Worldskin — a great serpent who devours everything and is reborn only to devour again, endlessly. Represents the pre-creation cycle of destruction that preceded Ruptga's discovery of the trick of living. The entire Redguard religion is fundamentally about escaping Satakal's consumption. Thematically parallels Alduin as a World-Eater and Namiira as an all-consuming ancient darkness.",
    tier: "redguard_pantheon",
  },
  {
    id: 51,
    domain: "Warfare, Drawn Blades, Martial Transformation",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Onsi",
    orcish: "—",
    argonian: "—",
    notes: "The Boneshaver. Taught the Yokudans how to pull their blades — that is, how to make war in the first place. Before Onsi's gift, the Yokudans allegedly had no concept of drawing a weapon in battle. A foundational deity of Redguard martial culture alongside Leki. His name is sometimes invoked before combat.",
    tier: "redguard_pantheon",
  },
  {
    id: 52,
    domain: "Sky, Winds, Birds, Navigation",
    imperial: "Kynareth (parallel)",
    nordic: "Kyne (parallel)",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "Khenarthi (parallel)",
    redguard: "Tava",
    orcish: "—",
    argonian: "—",
    notes: "Redguard sky-goddess of birds and wind, symbolised by the roc. She helped the Redguard navigate to Hammerfell by guiding them across the Eltheric Ocean. Parallels Kynareth and Kyne in the sky-nature domain but with distinctly Redguard iconography centred on birds and sea navigation rather than storms and war.",
    tier: "redguard_pantheon",
  },
  {
    id: 53,
    domain: "The Make-Way God, Unstoppable Force, Overcoming Obstacles",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "HoonDing",
    orcish: "—",
    argonian: "—",
    notes: "The Make-Way God. Not a permanent deity but a divine force that manifests within a chosen mortal when the Redguard people face an impossible obstacle. The HoonDing has incarnated multiple times in Redguard history — most notably as the legendary hero Frandar Hunding, and possibly as Cyrus the Restless. Unique among all TES deities as an avatar-force that incarnates in mortals rather than existing independently.",
    tier: "redguard_pantheon",
  },
  {
    id: 54,
    domain: "Agriculture, Toil, Hunger",
    imperial: "Zenithar (parallel)",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Zeht",
    orcish: "—",
    argonian: "—",
    notes: "Redguard god of toil and agriculture. Became bitter and vengeful, cursing men to labour for food as punishment. Parallels Zenithar in the domain of work, but with a starkly different character — Zeht gives labour as a burden while Zenithar rewards it. In some accounts Zeht abandoned his wife Morwha, causing strife among the gods.",
    tier: "redguard_pantheon",
  },
  {
    id: 55,
    domain: "The Greedy Serpent, False Promise, Mortal World's Deceiver",
    imperial: "—",
    nordic: "Shor (hero-form)",
    altmeri: "Lorkhan (deceiver)",
    bosmer: "Lorkhan (deceiver)",
    dunmer: "Lorkhan (deceiver)",
    khajiit: "Lorkhaj (Moon Beast)",
    redguard: "Sep",
    orcish: "—",
    argonian: "—",
    notes: "The Redguard interpretation of Lorkhan. Sep is a greedy serpent-god who convinced the other gods to create the mortal world with false promises, then was destroyed for it. His 'skin' became the world and his 'hunger' drives mortals to foolish ambitions. A far more malevolent reading of Lorkhan than the Nordic hero-god Shor. See also the main Shor/Lorkhan entry (row 34).",
    tier: "redguard_pantheon",
  },
  // ==========================================
  // ARGONIAN BELIEFS
  // ==========================================
  {
    id: 56,
    domain: "Divine Trees, Collective Memory, Argonian Identity",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "Y'ffre (parallel)",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "The Hist",
    notes: "Ancient sentient trees forming the entire spiritual foundation of Argonian civilisation. Not a single deity but a collective divine presence — a hive-mind of living gods rooted across Black Marsh. The Hist share sap with Argonians, shaping them in the womb, granting their soul-essence at birth, and calling souls home at death. Among the oldest beings on Nirn, predating the Aldmer. Parallel to Y'ffre as a nature-divinity that defines and shapes a race's identity.",
    tier: "argonian",
  },
  {
    id: 57,
    domain: "The Void, Primordial Chaos, Change, All Endings",
    imperial: "Sithis (Dark Brotherhood)",
    nordic: "Sithis (Dark Brotherhood)",
    altmeri: "Padomay (philosophical equivalent)",
    bosmer: "—",
    dunmer: "Sithis (the Void)",
    khajiit: "—",
    redguard: "Satakal (partial parallel)",
    orcish: "—",
    argonian: "Sithis (primary)",
    notes: "The primordial void/chaos — the antithesis of Anu (stasis). From their interplay all things were born. Argonians believe all life ultimately returns to Sithis. The Dark Brotherhood serves Sithis across all cultures as an assassins' cult. Dunmer cosmology acknowledges Sithis as the Void equal to Anu. Altmer philosophers equate Sithis to Padomay, the principle of change and chaos.",
    tier: "argonian",
  },
  {
    id: 58,
    domain: "The First Serpent, Star-Paths, Ancestral Dragons",
    imperial: "Akatosh (distant parallel)",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "Sep (thematic parallel)",
    orcish: "—",
    argonian: "Akha",
    notes: "The First Serpent of Argonian theology — the original wanderer who created the paths of stars by his travels through the heavens. His children are the constellations and planets. A dragon-time deity analogue paralleling Akatosh in his serpentine nature and association with time and celestial order. Some texts describe his later wanderings leading to corruption and all-consuming hunger.",
    tier: "argonian",
  },
  {
    id: 59,
    domain: "Undeath, Corrupted Cycle, Anti-Hist Force",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "Xol",
    notes: "Xol the Worm — an Argonian spirit of undeath and corruption. Represents the corruption of the natural cycle by which souls return to the Hist. Where the Hist calls Argonian souls home, Xol holds them in unnatural undeath — preventing the sacred return. His lore is sparse and regionalised within Black Marsh.",
    tier: "argonian",
  },
  {
    id: 60,
    domain: "Wild Marshes, Serpentine Nature, Growth",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "—",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "Tsun-Kali",
    notes: "A serpentine goddess of the Black Marsh in some Argonian regional traditions. Her domain covers the wild and predatory nature of the swamp — the marsh as a living divine entity separate from the Hist collective. Partially parallels Kynareth's nature domain but in a distinctly reptilian and swamp-specific form. Lore on Tsun-Kali is sparse and not consistent across all Argonian groups.",
    tier: "argonian",
  },
  // ==========================================
  // BOSMERI SPECIFIC
  // ==========================================
  {
    id: 61,
    domain: "Animals, the Green Pact, Wild Justice",
    imperial: "—",
    nordic: "—",
    altmeri: "—",
    bosmer: "Ius",
    dunmer: "—",
    khajiit: "—",
    redguard: "—",
    orcish: "—",
    argonian: "—",
    notes: "The Animal God of the Bosmer, enforcer of the Green Pact through animal surrogates. Distinct from Y'ffre — while Y'ffre gave the Bosmer their form and the stories of the Green, Ius is the wrathful force that punishes violations. In one famous myth he swallowed the Khajiit child-god Merrunz (Mehrunes Dagon) whole as punishment for violence against animals. A uniquely Bosmeri deity.",
    tier: "bosmer_pantheon",
  },
];

const tierConfig = {
  divine:            { label: "Nine Divines",       color: "#c9a84c", bg: "#1a1408" },
  aldmeri:           { label: "Aldmeri / Elven",    color: "#7ec8a4", bg: "#081a10" },
  tribunal:          { label: "Dunmeri Tribunal",   color: "#c47a5a", bg: "#1a0a06" },
  daedric:           { label: "Daedric Princes",    color: "#9b6bb5", bg: "#100814" },
  nordic:            { label: "Nordic / Shor",      color: "#6baec4", bg: "#061018" },
  khajiit_pantheon:  { label: "Khajiit Pantheon",  color: "#d4a840", bg: "#1a1200" },
  redguard_pantheon: { label: "Redguard Pantheon", color: "#c45a2a", bg: "#1a0800" },
  argonian:          { label: "Argonian Beliefs",   color: "#3ab880", bg: "#001a0e" },
  bosmer_pantheon:   { label: "Bosmeri Specific",   color: "#7ec440", bg: "#081600" },
};

const cultures = [
  { key: "imperial", label: "Imperial" },
  { key: "nordic",   label: "Nordic" },
  { key: "altmeri",  label: "Altmeri" },
  { key: "bosmer",   label: "Bosmer" },
  { key: "dunmer",   label: "Dunmeri" },
  { key: "khajiit",  label: "Khajiit" },
  { key: "redguard", label: "Redguard" },
  { key: "orcish",   label: "Orcish" },
  { key: "argonian", label: "Argonian" },
];

export default function GodsReference() {
  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState(null);

  const tiers = [
    "all","divine","aldmeri","tribunal","daedric","nordic",
    "khajiit_pantheon","redguard_pantheon","argonian","bosmer_pantheon",
  ];

  const filtered = gods.filter((g) => {
    const matchTier = filter === "all" || g.tier === filter;
    const q = search.toLowerCase();
    const matchSearch =
      !q ||
      g.domain.toLowerCase().includes(q) ||
      cultures.some((c) => g[c.key].toLowerCase().includes(q)) ||
      g.notes.toLowerCase().includes(q);
    return matchTier && matchSearch;
  });

  return (
    <div style={{ fontFamily: "'Palatino Linotype', Palatino, 'Book Antiqua', serif", background: "#0a0906", minHeight: "100vh", color: "#d4c5a0" }}>
      <div style={{ borderBottom: "1px solid #3a2e1a", background: "linear-gradient(180deg, #12100a 0%, #0a0906 100%)", padding: "2rem 2rem 1.5rem" }}>
        <div style={{ maxWidth: 1600, margin: "0 auto" }}>
          <div style={{ display: "flex", alignItems: "baseline", gap: "1rem", flexWrap: "wrap" }}>
            <h1 style={{ margin: 0, fontSize: "clamp(1.4rem, 3vw, 2rem)", color: "#e8d5a0", letterSpacing: "0.08em", textTransform: "uppercase", fontWeight: 400 }}>
              ⚔ Elder Scrolls Pantheon
            </h1>
            <span style={{ color: "#6b5c3a", fontSize: "0.85rem", letterSpacing: "0.15em", textTransform: "uppercase" }}>Complete Cross-Reference Framework</span>
          </div>
          <p style={{ margin: "0.5rem 0 0", color: "#7a6a4a", fontSize: "0.82rem", letterSpacing: "0.04em" }}>
            All deity equivalencies across all nine racial traditions — for mod development reference
          </p>
        </div>
      </div>

      <div style={{ borderBottom: "1px solid #2a2010", background: "#0d0b07", padding: "0.9rem 2rem" }}>
        <div style={{ maxWidth: 1600, margin: "0 auto", display: "flex", gap: "0.8rem", flexWrap: "wrap", alignItems: "center" }}>
          <input
            placeholder="Search domain, deity name, culture…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            style={{
              background: "#18140c", border: "1px solid #3a2e1a", borderRadius: 4, color: "#d4c5a0",
              padding: "0.4rem 0.8rem", fontSize: "0.82rem", width: 240, outline: "none", fontFamily: "inherit",
            }}
          />
          <div style={{ display: "flex", gap: "0.35rem", flexWrap: "wrap" }}>
            {tiers.map((t) => (
              <button
                key={t}
                onClick={() => setFilter(t)}
                style={{
                  background: filter === t ? (t === "all" ? "#3a2e1a" : tierConfig[t]?.bg) : "transparent",
                  border: `1px solid ${filter === t ? (t === "all" ? "#c9a84c" : tierConfig[t]?.color) : "#2e2412"}`,
                  borderRadius: 3,
                  color: filter === t ? (t === "all" ? "#c9a84c" : tierConfig[t]?.color) : "#5a4c2e",
                  padding: "0.28rem 0.6rem",
                  fontSize: "0.68rem",
                  cursor: "pointer",
                  letterSpacing: "0.07em",
                  textTransform: "uppercase",
                  fontFamily: "inherit",
                  transition: "all 0.15s",
                }}
              >
                {t === "all" ? "All" : tierConfig[t].label}
              </button>
            ))}
          </div>
          <span style={{ color: "#4a3c24", fontSize: "0.72rem", marginLeft: "auto", whiteSpace: "nowrap" }}>
            {filtered.length} / {gods.length} entries
          </span>
        </div>
      </div>

      <div style={{ maxWidth: 1600, margin: "0 auto", padding: "1.2rem 2rem" }}>
        <div style={{ display: "flex", gap: "0.8rem", flexWrap: "wrap", marginBottom: "1rem" }}>
          {Object.entries(tierConfig).map(([k, v]) => (
            <div key={k} style={{ display: "flex", alignItems: "center", gap: "0.35rem" }}>
              <div style={{ width: 8, height: 8, borderRadius: "50%", background: v.color, flexShrink: 0 }} />
              <span style={{ fontSize: "0.68rem", color: "#6b5c3a", letterSpacing: "0.05em" }}>{v.label}</span>
            </div>
          ))}
        </div>

        <div style={{ overflowX: "auto" }}>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: "0.77rem" }}>
            <thead>
              <tr style={{ borderBottom: "2px solid #3a2e1a" }}>
                <th style={{ ...th, width: 22 }}></th>
                <th style={{ ...th, textAlign: "left", minWidth: 165 }}>Domain</th>
                {cultures.map((c) => (
                  <th key={c.key} style={{ ...th, minWidth: 84 }}>{c.label}</th>
                ))}
                <th style={{ ...th, minWidth: 44 }}>Notes</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((g, i) => {
                const tc = tierConfig[g.tier];
                const isSelected = selected === g.id;
                return (
                  <>
                    <tr
                      key={g.id}
                      onClick={() => setSelected(isSelected ? null : g.id)}
                      style={{
                        background: isSelected ? tc.bg : i % 2 === 0 ? "#0d0b07" : "#0a0906",
                        borderLeft: `3px solid ${tc.color}`,
                        cursor: "pointer",
                        transition: "background 0.1s",
                      }}
                    >
                      <td style={{ ...td, paddingLeft: 8 }}>
                        <div style={{ width: 7, height: 7, borderRadius: "50%", background: tc.color, margin: "0 auto" }} />
                      </td>
                      <td style={{ ...td, color: "#c8b87a", fontStyle: "italic" }}>{g.domain}</td>
                      {cultures.map((c) => (
                        <td key={c.key} style={{ ...td, textAlign: "center", color: g[c.key] === "—" ? "#272010" : "#d4c5a0" }}>
                          {g[c.key]}
                        </td>
                      ))}
                      <td style={{ ...td, textAlign: "center", color: "#5a4c2e" }}>
                        {isSelected ? "▲" : "▼"}
                      </td>
                    </tr>
                    {isSelected && (
                      <tr key={`${g.id}-note`} style={{ background: tc.bg, borderLeft: `3px solid ${tc.color}` }}>
                        <td colSpan={cultures.length + 3} style={{ padding: "0.6rem 1rem 0.8rem 1.4rem", color: "#a89060", fontStyle: "italic", fontSize: "0.76rem", borderBottom: `1px solid ${tc.color}30` }}>
                          📜 {g.notes}
                        </td>
                      </tr>
                    )}
                  </>
                );
              })}
            </tbody>
          </table>
        </div>

        {filtered.length === 0 && (
          <div style={{ textAlign: "center", padding: "3rem", color: "#4a3c24", fontStyle: "italic" }}>
            No deities match your search.
          </div>
        )}

        <div style={{ marginTop: "2rem", padding: "1rem", borderTop: "1px solid #2a2010", color: "#4a3c24", fontSize: "0.7rem", lineHeight: 1.85 }}>
          <strong style={{ color: "#6b5c3a" }}>Mod Dev Notes:</strong>{" "}
          Click any row to expand full lore notes. "—" denotes no recorded equivalent in that culture's canon.
          Daedric Prince names are largely consistent across cultures (regional variants noted in expanded notes).
          The Nine Divines show the most cross-cultural variation.
          Tribunal gods are mortal ascendants unique to Dunmeri tradition — all other columns are legitimately blank.
          The Shor/Lorkhan/Sep/Lorkhaj cluster (row 34) is the most theologically contested deity in Tamriel.
          The Khajiit Two-Moons pantheon (Riddle'Thar, Jode, Jone) has no equivalent in any other culture.
          The Redguard pantheon is the most internally complete — Ruptga, Tu'whacca, Leki, Onsi, Satakal, and HoonDing form a fully self-contained theology.
          Argonian spirituality centres on the Hist collective and Sithis rather than named personal gods, making direct cross-referencing difficult.
        </div>
      </div>
    </div>
  );
}

const th = {
  padding: "0.45rem 0.45rem",
  color: "#8a7550",
  fontWeight: 400,
  letterSpacing: "0.07em",
  textTransform: "uppercase",
  fontSize: "0.65rem",
  textAlign: "center",
  borderBottom: "1px solid #2a2010",
};

const td = {
  padding: "0.4rem 0.45rem",
  borderBottom: "1px solid #1a1608",
  verticalAlign: "middle",
  lineHeight: 1.35,
};
