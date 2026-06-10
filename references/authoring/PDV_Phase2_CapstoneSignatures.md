# PDV Phase 2 — T3 Capstone Signature Effects

**Created:** 2026-06-07
**Status:** Living design record for the scripted T3 capstone signatures (Decision: "signatures at
T3 capstone only" — T1/T2 stay plain stat bumps).
**Owner:** Companion to the per-race reward specs and `PDV_Phase2_DeityRoster_and_ArchitectureRulings.md`.

## Structure (binding)

- The **T3 Champion ability** for each focused patron/path carries **both** its stat lines (the
  existing ~12% combat-stat magnitudes, under the Decision-2 ceiling) **AND** the scripted signature
  below — the signature is **additive, on top of** the tier buff.
- Stat half stays capped; "special" lives in the **qualitative** signature (procs, auras,
  cheat-death), so capstones feel like an event without stat power-creep.
- One active focused family at a time (one-active-emphasis/path/patron rule), so only one capstone
  signature is ever live per character.

## Shared mechanism library (reused across races)

| ID | Mechanism | Build pattern | First used by |
|----|-----------|---------------|---------------|
| M1 | Animal calm + once/day beast ally | vanilla Aspect of Kyne / Animal Allegiance pattern | Bosmer Old Contract |
| M2 | Stacking kill-momentum: all-weapon damage + small speed, 5 stacks / 30 s window; + small stamina restore per kill, credited max 5 kills / 30 s | scripted stacking buff (AttackDamageMult + SpeedMult) on the existing player-kill hook | Bosmer Old Contract |
| M3 | Companion-conditional heal-rate passive | `IsPlayerTeammate` poll → HealRateMult while a companion is present | Bosmer Living Story |
| M4 | Low-health once/day save (ward + heal) + rally allies | health watch ≤10% + daily cooldown; courage area effect on teammates | Bosmer Living Story |
| M5 | Debt repaid: damage taken remembered and added to next strike vs that foe; + bonus damage vs already-hostile targets | scripted OnHit ledger + perk attack-damage entry | Bosmer Exchange (Z'en) |
| M6 | Cheat-death → brief invisibility (escape) + attacker stagger + lingering luck (sneak/crit) | scripted OnHit lethal-check + 24-hour cooldown (locked "all cheat-deaths once/day" rule); apply Invisibility + stagger | Bosmer Bandit Road (Baan Dar) — REUSED by Khajiit Baan Dar |
| M7 | Post-sleep outdoor stealth buff | `OnSleepStop` outdoor check → timed Sneak buff | Bosmer Bandit Road |
| M8 | Travel momentum: reduced sprint stamina cost + out-of-combat speed ramp | scripted sprint-cost mod + moving/not-in-combat speed poll | Khajiit Khenarthi |
| M9 | Twilight sight: night magicka surge + detect-life aura + foresight magic-ward proc | night-conditioned regen + Detect Life + scripted ward | Khajiit Azurah |
| M10 | Thief's fade: brief invisibility on successful steal/sneak-attack + sneak muffle | hook steal/sneak-attack → Invisibility; Muffle ability (fallback trigger: sneak attack) | Khajiit Rajhin |
| M11 | Order's Roar: vs-dragon/great-foe damage + breath resist + once/day area stagger+slow | perk condition vs dragon + cooldown'd Slow Time / stagger area | Khajiit Alkosh |

(New mechanisms get appended as later races are designed.)

---

## LOCKED — Bosmer (4 paths) — agreed 2026-06-07

### Old Contract — Y'ffre · "Keeper of the Pact"
- **Passive (stat):** Archery +12, Sneak +12, ResistPoison +10 (existing T3).
- **Signature:** beasts won't attack unprovoked + once/day call a nearby beast ally (M1); each kill
  (ANY kill) grants a stacking all-weapon damage surge + small speed, 5 stacks / 30 s, and restores
  a small burst of stamina capped to 5 kills / 30 s (M2).

### Living Story — Y'ffre · "Story-Keeper"
- **Passive (stat):** Speech +12, HealRateMult +15, MagickaRateMult +5 (existing T3).
- **Signature:** warmer disposition/prices + heal-rate boost while traveling with a companion of any
  kind (M3); once/day, a PROACTIVE rally — "you tell the tale that lifts them": rally + minor ward to
  nearby allies (M4 rally, NOT a low-HP save). *Re-flavored 2026-06-07 off the 10%-HP save to keep
  Bosmer's single cheat-death on Bandit Road (≤1 save/race rule).*

### The Exchange — Z'en · "Z'en's Reckoning"
- **Passive (stat):** Speech +12, CarryWeight +50, DamageResist +8 (existing T3).
- **Signature:** the ledger repays — a portion of damage an enemy deals you is added to your next
  strike against them; + bonus damage vs targets already hostile to you; settling a real debt briefly
  steadies all actions (M5).

### Bandit Road — Baan Dar · "Baan Dar's Luck"
- **Passive (stat):** Armor +12, HealRateMult +15, Sneak +10 (existing T3).
- **Signature:** sleeping rough sharpens next-day stealth (M7); once per 24 hours a killing blow is
  survived — you vanish briefly (escape), attacker staggers, with a lingering luck streak (M6;
  cadence per the locked "all cheat-deaths once/day" rule -- corrected 2026-06-10 from
  "every few days" drift).

---

## LOCKED — Khajiit (5 emphases) — agreed 2026-06-07 (back-fills shipped pilot)

Stat tweaks vs. shipped records: Baan Dar +Unarmed 10; Rajhin +Unarmed 10; Alkosh ResistMagic 8 -> 15
(deliberate capstone exception above the ~12% universal ceiling). Unarmed is the Khajiit clawed-build
niche — Baan Dar (survivor brawler) + Rajhin (clawed thief).

### Khenarthi — "Khenarthi's Wind" (road & sky)
- **Passive (stat):** Stamina +10%, Carry +50, Speed +3.
- **Signature:** sprinting costs little/no stamina + out-of-combat travel-speed ramp the longer you
  move uninterrupted ("the wind at your back"), bleeding off in combat/at rest (M8).

### Azurah — "Azurah's Sight" (twilight & moons)
- **Passive (stat):** Magicka +10%, Magic Resist +10%.
- **Signature:** at night, magicka surges + you sense living things (detect-life aura); once in a
  while Azurah's foresight turns a spell that would have hit you (magic-ward proc) (M9).

### Baan Dar — "Baan Dar's Luck" (the Pariah)
- **Passive (stat):** Armor +15, HealRate +15%, **Unarmed +10**.
- **Signature:** once per 24 hours a killing blow is survived — vanish (escape) + attacker stagger +
  lingering luck pulse on use (M6; shared with Bosmer Bandit Road; cadence per the locked
  "all cheat-deaths once/day" rule -- corrected 2026-06-10 from "every few days" drift).

### Rajhin — "Rajhin's Shadow" (the Purring Liar)
- **Passive (stat):** Sneak +12, Lockpicking +15, Pickpocket +15, **Unarmed +10**.
- **Signature:** a successful steal/sneak-attack briefly fades you (slip away) + shadows cloak you
  (sneak muffle) (M10; fallback trigger = sneak attack if pickpocket-success detection is unreliable).

### Alkosh — "Alkosh's Roar" (Dragon King, order vs chaos)
- **Passive (stat):** Fire Resist +12, **Magic Resist +15** (capstone exception).
- **Signature:** bonus damage + breath resistance vs dragons/great chaotic foes; once a day, the Roar
  staggers and slows nearby enemies (order imposed on chaos) (M11).

Note: Khajiit records already ship; the capstone re-author adds the scripted signatures + the three
stat tweaks above.

---

## DRAFT — remaining races (designed 2026-06-07; PENDING talk-through)

Format: **Patron/Lane — "Signature":** effect (mechanism family; ✅ buildable / ⚠️ fiddly + fallback).
Signature rides on top of the existing T3 stat half. New mechanism patterns are named; final M#
numbers assigned at implementation. Many low-health "saves" reuse the M4/M6 skeleton with different
payloads.

### Imperial — Nine Divines + Talos (shared Aedric set; reused by Breton/Nord)
- **Akatosh — "Endurance of the Covenant":** multi-day cheat-death — the killing blow is refused, brief ward + slow-time "temporal stand" (M4-variant + slow-time; ✅, fallback: drop slow-time).
- **Mara — "Compassion of the Mother":** your self-heals echo a HoT to nearby allies + companion heal/disposition (M3 + heal-echo; ✅, fallback: trigger on ally low-HP). *Reused by Breton Knight's Road.*
- **Arkay — "Ward of the Cycle":** bonus damage + turn vs undead, heal pulse when you put one to rest, necro ward (perk-vs-undead + kill-heal; ✅, fallback: flat ward). *Breton KR.*
- **Stendarr — "Bulwark of Mercy":** guardian aura (nearby allies gain armor) + bonus vs daedra/undead + block-reactive stagger (ally-aura + perk; ✅, fallback: drop block-stagger). *Breton KR.*
- **Zenithar — "Prosperity of Fair Dealing":** first good trade/craft each day → gold rebate + focus buff; better barter (NEW economic; ✅ once/day).
- **Dibella — "Inspiration of Beauty":** warmer disposition/prices/persuasion + occasional pacify of a hostile (Calm-based; ✅, fallback: once/day pacify).
- **Julianos — "Insight of Law and Lore":** incoming hostile spell turned + magicka refunded; spell-cost discipline (M9 ward + perk cost; ✅). *Breton Hidden Art lawful.*
- **Kynareth — "Open Sky":** outdoors, stamina barely depletes + fall protection + occasional storm-stagger answer (env-poll; ✅, fallback: drop fall). *Breton Green Way; Bosmer Y'ffre proxy.*
- **Talos — "Triumph of Faithful Defiance":** stacking conquest momentum on kills + bonus vs great foes, gated/scaled by ConcordatStanding defiance (M2 + perk; ✅). *Reused by Nord Talos.*

### Altmer (Auri-El foundation + one secondary; coherence axis)
- **Auri-El — "Ascendant Light":** luminous cheat-death — ward + heal + brief slow-time + coherence resolve (M4/M6-variant; ✅, fallback: drop slow-time).
- **Magnus — "The Architect's Aperture":** by day/outdoors, magicka surge + disciplined-school cost reduction + foresight ward (M9 daytime-inverse; ✅).
- **Xarxes — "The Long Ledger":** study/record acts inscribe a stacking, decaying coherence buff (ResistMagic + MagickaRate) + once/day recorded self-restoration (M2-variant, study-hooked; ✅, fallback: decay-per-dawn).

### Dunmer (ancestor substrate + one Reclamation foreground)
- **Azura — "The Moonshadow Warden":** dusk/dawn detect-life + magicka surge + foresight ward that also steadies allies (M9 + ally-steady; ✅).
- **Boethiah — "The Duel of the Worthy":** bonus vs the strongest foe; felling it rallies you + cows weaker bystanders (NEW champion-duel; ⚠️ live target-marking → fallback: kill-higher-level trigger).
- **Mephala — "The Spinner's Web":** web-sense (detect-life) + sneak-attack fade (M10) + frays nearby foes (Illusion) (M10 + web-sense; ⚠️ Illusion level-cap → fallback: stagger).

### Nord — Old Ways (Kyne/Shor/Tsun/Stuhn) + Talos (from Imperial). NOTE: Shor/Tsun/Stuhn become NEW focusable deities → 3 new QUSTs + 9 new T1/T2/T3 records + Nord spec R5 rework.
- **Kyne — "The Storm Answers":** beasts won't attack + outdoors-in-storm power-attack stamina relief + Shout recharge (M1 + weather-poll; ⚠️ power-attack-stamina needs a perk → fallback: outdoor-only).
- **Shor — "Sovngarde Looks Back":** honorable kill heals you (level-scaled) + near-death last-stand surge (kill-hook + health-watch; ⚠️ honorable detection → fallback: reject sneak/bash + per-30s cap).
- **Tsun — "The Shield-Thane's Trial":** surviving a severe-disadvantage fight grants a 24h stamina-endurance vigil (combat-threat sample; ⚠️ stamina-floor → fallback: strong StaminaRate buff).
- **Stuhn — "Just Spoils, Honored Bonds":** sparing/freeing a captive grants an ally-defense + armor shield (M4 rally) + bonus vs captor-tagged foes (curated mercy trigger; ⚠️ no surrender detection → authored quest-stage trigger).

### Orc — Malacath life-modes (Berserker-Rage readings; ally vector deliberately opposed)
- **Stronghold — "Blood-Kin of the Forge":** while followers/blood-kin are near, you and they gain damage resistance + your power attacks stagger — the more kin near, the stronger; NO low-HP trigger (guardian aura; ✅). *Re-flavored 2026-06-07 off the cheat-death to keep Orc's single save on Legion; also sharpens the Stronghold(with-kin)-vs-City(alone) opposition.*
- **City — "Unbroken Alone":** stronger the longer you fight ALONE/outnumbered — scaling resist + block (M2-cadence on defense; ✅, fallback: binary no-ally buff).
- **Legion/Exile — "Hold the Line":** low-HP → stand-fast (resist + stamina + stagger-immunity) + rally allies (M4 + poise rider; ✅, fallback: drop poise).

### Redguard — Yokudan (sect-filtered)
- **Tu'whacca — "Keeper of the Far Shores":** ward/turn vs the restless dead + once/day Far-Shores cheat-death (perk-vs-undead + M4 no-rally; ✅). Copy says Tu'whacca, never Arkay.
- **HoonDing — "The Way Is Made":** weekly-capped forward break-through — knockback/stagger enemies in your path + brief unstoppable advance (M11-cousin knockback; ⚠️ cone → fallback: radial).
- **Leki — "The Ephemeral Feint":** single-foe duel crit bonus (fades when mobbed) + feint riposte after a 1H power/crit (M5-ledger + single-foe; ⚠️ crowd-count → fallback: engage-flag).

### Argonian — People focus + Sithis/Void (+ primal-unarmed home)
- **People — "Pillar of the Saxhleel":** ally-projected heal/disease aura + once/day, an ally at low HP triggers ward + rally (M3-variant + M4 retarget; ✅, fallback: single-follower).
- **Sithis/Void — "The Fearless Nothing":** immune to fear/flee + cheat-death Void-slip (M6) + **Unarmed +10** (M6 + fear-dispel; ⚠️ fear-immunity → fallback: once-per-combat auto-dispel). **This is the recommended home for the Argonian primal-unarmed build** (Void-feral savagery — tail/teeth/raw might, not claws), parallel to Khajiit.

### Breton — NO new capstone signatures; the focused god's signature is REUSED per tradition
- Knight's Road → Stendarr / Mara / Arkay / Julianos signatures (above). Green Way → Kynareth (above) + Hircine fork via 20C. Hidden Art → Daedric via 20C + Julianos (lawful). Breton's capstone = whichever god it focuses within the active tradition.

### New mechanism patterns to formalize into the M-library (post-talk-through)
Economic tithe (Zenithar); pacify/Calm proc (Dibella); fear/flee-immunity dispel (Argonian Void);
generalized environmental-surge (M8/M9 + Magnus/Kynareth/Kyne); generalized ally-buff aura
(M14/Mara/Argonian People/Azura); generalized vs-keyword perk (M11/Arkay/Stendarr/Tu'whacca);
single-foe duel + feint (Leki/Boethiah); forward knockback (HoonDing); stacking-on-non-kill (Orc City
defense, Xarxes study). Cheat-death/low-HP saves are M4/M6 variants, not new mechanisms.

### Flags for the talk-through
1. **Cheat-death density:** Akatosh, Auri-El, Tu'whacca, Orc Stronghold/Legion, Shor, Argonian Void all use a low-HP/killing-blow save. Flavored differently but mechanically related — worth deciding if that's fine or if some should pivot to a non-save signature.
2. **Nord R5 drift:** Shor/Tsun/Stuhn focusable = real new records + Nord spec rework (3 deities, 9 reward records).
3. **⚠️ fiddly detections** (honorable-kill, surrender, fear-immunity, live target-marking, crowd-count) each have a buildable fallback — decide accept-fallback-as-V1 per item at implementation.
4. **Capstone magnitude exceptions** (e.g. Alkosh ResistMagic 15) are deliberate; signatures otherwise add qualitative power, not stat %.

---

## LOCKED implementation rules (2026-06-07)

1. **Cheat-death cooldown:** every killing-blow/low-HP save is **once per day** (StorageUtil daily key).
2. **One save per race:** each race's capstone set carries **at most one** cheat-death/low-HP save.
   Resolved exceptions: Orc Stronghold re-flavored to a kin-aura (save stays on Legion); Bosmer Living
   Story re-flavored to a proactive rally (save stays on Bandit Road). Remaining single saves: Imperial
   Akatosh, Altmer Auri-El, Redguard Tu'whacca, Nord Shor (last-stand surge), Orc Legion, Argonian Void,
   Khajiit Baan Dar, Bosmer Bandit Road. (Argonian People's once/day proc targets an *ally*, not the
   player — not counted as the player's save.)
3. **Fallback-as-floor (graceful degradation):** for every ⚠️ fiddly-detection signature, the robust
   fallback is built as the GUARANTEED baseline; the precise detection layers on top; if the precise
   path fails to fire/detect, the effect silently degrades to the fallback. No capstone may end up
   non-functional because a detection didn't fire. This is binding for the Phase B build.
