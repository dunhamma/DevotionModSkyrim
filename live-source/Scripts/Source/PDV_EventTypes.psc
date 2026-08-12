;/
    PDV_EventTypes.psc
    PlayerDevotion - V3 Preflight event constant owner
    -----------------------------------------------------------------------
    Centralizes event IDs and attribution IDs so future signal expansion does
    not scatter integer literals across Story Manager receivers, the event
    bus, and deity rubrics.
    -----------------------------------------------------------------------
/;

Scriptname PDV_EventTypes extends Quest

Int Property FRAMEWORK_SCHEMA_VERSION = 3 AutoReadOnly

Int Property EVT_NONE = 0 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_BEAST = 1 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2 AutoReadOnly
Int Property EVT_SLEEP_MOON_OBSERVANCE = 10 AutoReadOnly
Int Property EVT_CONCORDAT_COMPLIANCE = 20 AutoReadOnly
Int Property EVT_CONCORDAT_DEFIANCE = 21 AutoReadOnly
Int Property EVT_DUNMER_PORTABLE_SHRINE = 30 AutoReadOnly
Int Property EVT_DUNMER_HOME_BONUS = 31 AutoReadOnly
Int Property EVT_GREEN_PACT_VIOLATION = 32 AutoReadOnly
Int Property EVT_KHAJIIT_ROAD_HOME = 33 AutoReadOnly
Int Property EVT_HIRCINE_HUNT_RITE = 34 AutoReadOnly
Int Property EVT_TALOS_SHRINE_DEFIANCE = 35 AutoReadOnly
Int Property EVT_SHOUT_ATTACK = 40 AutoReadOnly
Int Property EVT_BOSMER_LIVING_STORY = 41 AutoReadOnly
Int Property EVT_BOSMER_EXCHANGE = 42 AutoReadOnly
Int Property EVT_BOSMER_BANDIT_ROAD = 43 AutoReadOnly
Int Property EVT_BOSMER_PACT_POSITIVE = 44 AutoReadOnly
Int Property EVT_STATE_TRANSITION_CONFIRM_RITE = 45 AutoReadOnly
Int Property EVT_ALTMER_LORKHAN_PRESSURE = 50 AutoReadOnly
Int Property EVT_ALTMER_CRISIS_SOURCE = 51 AutoReadOnly
Int Property EVT_ALTMER_DAWN_STEADINESS = 52 AutoReadOnly
Int Property EVT_ALTMER_ORTHODOX_COST = 53 AutoReadOnly
Int Property EVT_ARGONIAN_HIST_MAINTENANCE = 60 AutoReadOnly
Int Property EVT_ARGONIAN_PEOPLE_SUPPORT = 61 AutoReadOnly
Int Property EVT_ARGONIAN_VOID_SIGNAL = 62 AutoReadOnly
Int Property EVT_ARGONIAN_BED_OF_CHOICE = 63 AutoReadOnly
Int Property EVT_ORC_STRONGHOLD_FORGE = 70 AutoReadOnly
Int Property EVT_ORC_CITY_DIGNITY = 71 AutoReadOnly
Int Property EVT_ORC_LEGION_SERVICE = 72 AutoReadOnly
Int Property EVT_ORC_SELF_MADE_COMMUNITY = 73 AutoReadOnly
Int Property EVT_ORC_OATH_BREAK = 74 AutoReadOnly
Int Property EVT_ORC_FOUR_HOLDS_VISIT = 75 AutoReadOnly
Int Property EVT_REDGUARD_CROWN_TOMB_RESPECT = 80 AutoReadOnly
Int Property EVT_REDGUARD_FOREBEAR_ROAD = 81 AutoReadOnly
Int Property EVT_REDGUARD_ASHABAH_DEATH_DUTY = 82 AutoReadOnly
Int Property EVT_REDGUARD_FAR_SHORES_TOKEN = 83 AutoReadOnly
Int Property EVT_KHAJIIT_BAANDAR_ROAD_TRICK = 90 AutoReadOnly
Int Property EVT_KHAJIIT_RAJHIN_ELEGANT_THEFT = 91 AutoReadOnly
Int Property EVT_KHAJIIT_ALKOSH_DRAGON_ORDER = 92 AutoReadOnly
Int Property EVT_BOSMER_OLD_CONTRACT_PROPER_HUNT = 100 AutoReadOnly
Int Property EVT_BOSMER_OLD_CONTRACT_FOREST_KEPT = 101 AutoReadOnly
Int Property EVT_BOSMER_LIVING_STORY_COMMUNITY = 102 AutoReadOnly
Int Property EVT_BOSMER_LIVING_STORY_NATURE_SITE = 103 AutoReadOnly
Int Property EVT_BOSMER_EXCHANGE_DEBT_SETTLED = 104 AutoReadOnly
Int Property EVT_BOSMER_EXCHANGE_PROPORTIONATE_VENGEANCE = 105 AutoReadOnly
Int Property EVT_BOSMER_BANDIT_ROAD_ROAD_LIFE = 106 AutoReadOnly
Int Property EVT_BOSMER_BANDIT_ROAD_REVERSAL = 107 AutoReadOnly
Int Property EVT_BRETON_TRADITION_CHOICE = 120 AutoReadOnly
Int Property EVT_BRETON_KNIGHTLY_VOW = 121 AutoReadOnly
Int Property EVT_BRETON_HIDDEN_ART_EXPOSURE = 122 AutoReadOnly
Int Property EVT_BRETON_GREEN_WAY_STANDING = 123 AutoReadOnly
Int Property EVT_DUNMER_RECLAMATION_FOCUS = 130 AutoReadOnly
Int Property EVT_DUNMER_DEVIATION_PRICE = 131 AutoReadOnly
Int Property EVT_IMPERIAL_CIVIC_SERVICE = 140 AutoReadOnly
Int Property EVT_IMPERIAL_TALOS_PRESSURE = 141 AutoReadOnly
Int Property EVT_IMPERIAL_PATRON_CIVIC_FAVOR = 142 AutoReadOnly
Int Property EVT_NORD_OLD_WAYS_STATE = 150 AutoReadOnly
Int Property EVT_NORD_KYNE_TALOS_CONTEXT = 151 AutoReadOnly
Int Property EVT_NORD_HIRCINE_ARKAY_EDGE = 152 AutoReadOnly
Int Property EVT_DAEDRIC_PRINCE_SIGNAL = 200 AutoReadOnly
Int Property EVT_DAEDRIC_GENERIC_SILENCE = 201 AutoReadOnly

; --- Day-to-day like/dislike vocabulary (ID block 300+) ---
; Locked contract for the per-deity likes/dislikes table; see
; references/authoring/PDV_DeityLikesDislikesMatrix.md. IDs are reserved here; the
; Story Manager receivers and router classifier that emit them are Phase C/D work.
; Combat by victim type (existing EVT_KILLED_* 1/2 extend this group)
Int Property EVT_KILL_UNDEAD = 300 AutoReadOnly
Int Property EVT_KILL_DAEDRA = 301 AutoReadOnly
Int Property EVT_KILL_DRAGON = 302 AutoReadOnly
Int Property EVT_KILL_ANIMAL_NONCOMBAT = 303 AutoReadOnly
Int Property EVT_MURDER_DEFENSELESS = 304 AutoReadOnly
; Combat method (2026-08-12): how a kill is delivered, not the victim type
Int Property EVT_SNEAK_ATTACK_KILL = 305 AutoReadOnly
; Devotional / observance
Int Property EVT_REST_UNDER_OPEN_SKY = 313 AutoReadOnly
Int Property EVT_SLEEP_IN_BED = 314 AutoReadOnly
; Labor / craft (one Story Manager Craft Item node covers smith/enchant/brew/cook)
Int Property EVT_SMITH_ITEM = 330 AutoReadOnly
Int Property EVT_ENCHANT_ITEM = 331 AutoReadOnly
Int Property EVT_BREW_POTION = 332 AutoReadOnly
Int Property EVT_COOK_MEAL = 333 AutoReadOnly
Int Property EVT_HARVEST_INGREDIENT = 334 AutoReadOnly
; Knowledge
Int Property EVT_READ_SKILL_BOOK = 340 AutoReadOnly
Int Property EVT_READ_SPELL_TOME = 341 AutoReadOnly
Int Property EVT_READ_LORE_BOOK = 342 AutoReadOnly
Int Property EVT_LEARN_WORD_OF_POWER = 343 AutoReadOnly
Int Property EVT_INCREASE_SKILL = 344 AutoReadOnly
Int Property EVT_DISCOVER_LOCATION = 345 AutoReadOnly
; Civic / charity / order
Int Property EVT_HEAL_OR_CURE_NPC = 350 AutoReadOnly
Int Property EVT_CLEAR_BOUNTY = 351 AutoReadOnly
; Transgression (the dislikes surface)
Int Property EVT_PICK_OWNED_LOCK = 360 AutoReadOnly
Int Property EVT_TRESPASS = 361 AutoReadOnly
Int Property EVT_STEAL_ITEM = 362 AutoReadOnly
Int Property EVT_ASSAULT_INNOCENT = 364 AutoReadOnly
Int Property EVT_RAISE_UNDEAD = 365 AutoReadOnly
Int Property EVT_VAMPIRE_FEED = 366 AutoReadOnly
Int Property EVT_ACCEPT_DAEDRIC_ARTIFACT = 368 AutoReadOnly
; HARD-detection acts dropped per matrix doc decision 3 (IDs reserved, not authored):
; 352 give-gold-charity, 353 free-captive, 354 persuade-success, 367 cannibalize, 369 desecrate-shrine

Int Property ATTR_NONE = 0 AutoReadOnly
Int Property ATTR_DIRECT_PLAYER = 1 AutoReadOnly
Int Property ATTR_FOLLOWER = 2 AutoReadOnly
Int Property ATTR_SUMMON_OR_CHARMED = 3 AutoReadOnly
Int Property ATTR_TRAP = 4 AutoReadOnly
Int Property ATTR_ENVIRONMENT = 5 AutoReadOnly

Bool Function CanScoreAttribution(Int attributionType)
    return attributionType == ATTR_DIRECT_PLAYER
EndFunction

String Function AttributionLabel(Int attributionType)
    if attributionType == ATTR_DIRECT_PLAYER
        return "direct-player"
    elseIf attributionType == ATTR_FOLLOWER
        return "follower"
    elseIf attributionType == ATTR_SUMMON_OR_CHARMED
        return "summon-or-charmed"
    elseIf attributionType == ATTR_TRAP
        return "trap"
    elseIf attributionType == ATTR_ENVIRONMENT
        return "environment"
    endIf

    return "none"
EndFunction

String Function EventLabel(Int eventType)
    if eventType == EVT_KILLED_HOSTILE_BEAST
        return "killed-hostile-beast"
    elseIf eventType == EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
        return "killed-hostile-humanoid"
    elseIf eventType == EVT_SLEEP_MOON_OBSERVANCE
        return "sleep-moon-observance"
    elseIf eventType == EVT_CONCORDAT_COMPLIANCE
        return "concordat-compliance"
    elseIf eventType == EVT_CONCORDAT_DEFIANCE
        return "concordat-defiance"
    elseIf eventType == EVT_DUNMER_PORTABLE_SHRINE
        return "dunmer-portable-shrine"
    elseIf eventType == EVT_DUNMER_HOME_BONUS
        return "dunmer-home-bonus"
    elseIf eventType == EVT_GREEN_PACT_VIOLATION
        return "green-pact-violation"
    elseIf eventType == EVT_KHAJIIT_ROAD_HOME
        return "khajiit-road-home"
    elseIf eventType == EVT_HIRCINE_HUNT_RITE
        return "hircine-hunt-rite"
    elseIf eventType == EVT_TALOS_SHRINE_DEFIANCE
        return "talos-shrine-defiance"
    elseIf eventType == EVT_SHOUT_ATTACK
        return "shout-attack"
    elseIf eventType == EVT_BOSMER_LIVING_STORY
        return "bosmer-living-story"
    elseIf eventType == EVT_BOSMER_EXCHANGE
        return "bosmer-exchange"
    elseIf eventType == EVT_BOSMER_BANDIT_ROAD
        return "bosmer-bandit-road"
    elseIf eventType == EVT_BOSMER_PACT_POSITIVE
        return "bosmer-pact-positive"
    elseIf eventType == EVT_STATE_TRANSITION_CONFIRM_RITE
        return "state-transition-confirm-rite"
    elseIf eventType == EVT_ALTMER_LORKHAN_PRESSURE
        return "altmer-lorkhan-pressure"
    elseIf eventType == EVT_ALTMER_CRISIS_SOURCE
        return "altmer-crisis-source"
    elseIf eventType == EVT_ALTMER_DAWN_STEADINESS
        return "altmer-dawn-steadiness"
    elseIf eventType == EVT_ALTMER_ORTHODOX_COST
        return "altmer-orthodox-cost"
    elseIf eventType == EVT_ARGONIAN_HIST_MAINTENANCE
        return "argonian-hist-maintenance"
    elseIf eventType == EVT_ARGONIAN_PEOPLE_SUPPORT
        return "argonian-people-support"
    elseIf eventType == EVT_ARGONIAN_VOID_SIGNAL
        return "argonian-void-signal"
    elseIf eventType == EVT_ARGONIAN_BED_OF_CHOICE
        return "argonian-bed-of-choice"
    elseIf eventType == EVT_ORC_STRONGHOLD_FORGE
        return "orc-stronghold-forge"
    elseIf eventType == EVT_ORC_CITY_DIGNITY
        return "orc-city-dignity"
    elseIf eventType == EVT_ORC_LEGION_SERVICE
        return "orc-legion-service"
    elseIf eventType == EVT_ORC_SELF_MADE_COMMUNITY
        return "orc-self-made-community"
    elseIf eventType == EVT_ORC_OATH_BREAK
        return "orc-oath-break"
    elseIf eventType == EVT_ORC_FOUR_HOLDS_VISIT
        return "orc-four-holds-visit"
    elseIf eventType == EVT_REDGUARD_CROWN_TOMB_RESPECT
        return "redguard-crown-tomb-respect"
    elseIf eventType == EVT_REDGUARD_FOREBEAR_ROAD
        return "redguard-forebear-road"
    elseIf eventType == EVT_REDGUARD_ASHABAH_DEATH_DUTY
        return "redguard-ashabah-death-duty"
    elseIf eventType == EVT_REDGUARD_FAR_SHORES_TOKEN
        return "redguard-far-shores-token"
    elseIf eventType == EVT_KHAJIIT_BAANDAR_ROAD_TRICK
        return "khajiit-baandar-road-trick"
    elseIf eventType == EVT_KHAJIIT_RAJHIN_ELEGANT_THEFT
        return "khajiit-rajhin-elegant-theft"
    elseIf eventType == EVT_KHAJIIT_ALKOSH_DRAGON_ORDER
        return "khajiit-alkosh-dragon-order"
    elseIf eventType == EVT_BOSMER_OLD_CONTRACT_PROPER_HUNT
        return "bosmer-old-contract-proper-hunt"
    elseIf eventType == EVT_BOSMER_OLD_CONTRACT_FOREST_KEPT
        return "bosmer-old-contract-forest-kept"
    elseIf eventType == EVT_BOSMER_LIVING_STORY_COMMUNITY
        return "bosmer-living-story-community"
    elseIf eventType == EVT_BOSMER_LIVING_STORY_NATURE_SITE
        return "bosmer-living-story-nature-site"
    elseIf eventType == EVT_BOSMER_EXCHANGE_DEBT_SETTLED
        return "bosmer-exchange-debt-settled"
    elseIf eventType == EVT_BOSMER_EXCHANGE_PROPORTIONATE_VENGEANCE
        return "bosmer-exchange-proportionate-vengeance"
    elseIf eventType == EVT_BOSMER_BANDIT_ROAD_ROAD_LIFE
        return "bosmer-bandit-road-road-life"
    elseIf eventType == EVT_BOSMER_BANDIT_ROAD_REVERSAL
        return "bosmer-bandit-road-reversal"
    elseIf eventType == EVT_BRETON_TRADITION_CHOICE
        return "breton-tradition-choice"
    elseIf eventType == EVT_BRETON_KNIGHTLY_VOW
        return "breton-knightly-vow"
    elseIf eventType == EVT_BRETON_HIDDEN_ART_EXPOSURE
        return "breton-hidden-art-exposure"
    elseIf eventType == EVT_BRETON_GREEN_WAY_STANDING
        return "breton-green-way-standing"
    elseIf eventType == EVT_DUNMER_RECLAMATION_FOCUS
        return "dunmer-reclamation-focus"
    elseIf eventType == EVT_DUNMER_DEVIATION_PRICE
        return "dunmer-deviation-price"
    elseIf eventType == EVT_IMPERIAL_CIVIC_SERVICE
        return "imperial-civic-service"
    elseIf eventType == EVT_IMPERIAL_TALOS_PRESSURE
        return "imperial-talos-pressure"
    elseIf eventType == EVT_IMPERIAL_PATRON_CIVIC_FAVOR
        return "imperial-patron-civic-favor"
    elseIf eventType == EVT_NORD_OLD_WAYS_STATE
        return "nord-old-ways-state"
    elseIf eventType == EVT_NORD_KYNE_TALOS_CONTEXT
        return "nord-kyne-talos-context"
    elseIf eventType == EVT_NORD_HIRCINE_ARKAY_EDGE
        return "nord-hircine-arkay-edge"
    elseIf eventType == EVT_DAEDRIC_PRINCE_SIGNAL
        return "daedric-prince-signal"
    elseIf eventType == EVT_DAEDRIC_GENERIC_SILENCE
        return "daedric-generic-silence"
    elseIf eventType == EVT_KILL_UNDEAD
        return "kill-undead"
    elseIf eventType == EVT_KILL_DAEDRA
        return "kill-daedra"
    elseIf eventType == EVT_KILL_DRAGON
        return "kill-dragon"
    elseIf eventType == EVT_KILL_ANIMAL_NONCOMBAT
        return "kill-animal-noncombat"
    elseIf eventType == EVT_MURDER_DEFENSELESS
        return "murder-defenseless"
    elseIf eventType == EVT_SNEAK_ATTACK_KILL
        return "sneak-attack-kill"
    elseIf eventType == EVT_REST_UNDER_OPEN_SKY
        return "rest-under-open-sky"
    elseIf eventType == EVT_SLEEP_IN_BED
        return "sleep-in-bed"
    elseIf eventType == EVT_SMITH_ITEM
        return "smith-item"
    elseIf eventType == EVT_ENCHANT_ITEM
        return "enchant-item"
    elseIf eventType == EVT_BREW_POTION
        return "brew-potion"
    elseIf eventType == EVT_COOK_MEAL
        return "cook-meal"
    elseIf eventType == EVT_HARVEST_INGREDIENT
        return "harvest-ingredient"
    elseIf eventType == EVT_READ_SKILL_BOOK
        return "read-skill-book"
    elseIf eventType == EVT_READ_SPELL_TOME
        return "read-spell-tome"
    elseIf eventType == EVT_READ_LORE_BOOK
        return "read-lore-book"
    elseIf eventType == EVT_LEARN_WORD_OF_POWER
        return "learn-word-of-power"
    elseIf eventType == EVT_INCREASE_SKILL
        return "increase-skill"
    elseIf eventType == EVT_DISCOVER_LOCATION
        return "discover-location"
    elseIf eventType == EVT_HEAL_OR_CURE_NPC
        return "heal-or-cure-npc"
    elseIf eventType == EVT_CLEAR_BOUNTY
        return "clear-bounty"
    elseIf eventType == EVT_PICK_OWNED_LOCK
        return "pick-owned-lock"
    elseIf eventType == EVT_TRESPASS
        return "trespass"
    elseIf eventType == EVT_STEAL_ITEM
        return "steal-item"
    elseIf eventType == EVT_ASSAULT_INNOCENT
        return "assault-innocent"
    elseIf eventType == EVT_RAISE_UNDEAD
        return "raise-undead"
    elseIf eventType == EVT_VAMPIRE_FEED
        return "vampire-feed"
    elseIf eventType == EVT_ACCEPT_DAEDRIC_ARTIFACT
        return "accept-daedric-artifact"
    endIf

    return "none"
EndFunction
