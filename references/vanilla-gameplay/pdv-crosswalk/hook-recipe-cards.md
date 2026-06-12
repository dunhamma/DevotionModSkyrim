# PDV Hook Recipe Cards

Status: living implementation reference

Purpose: turn hook surfaces into repeatable build patterns. Each recipe names
the receiver shape, route, anti-farm contract, and proof path before a hook is
allowed into a deity rubric.

## Shared Contract

Every runtime hook follows the same route:

1. Receiver validates that the event is player-relevant.
2. Receiver maps raw event data into a compact PDV event type plus optional
   target/source forms.
3. `PDV_EventBus` routes the validated event.
4. `PDV__ManagerQuest` writes only `PDV.PietyToday`.
5. Dawn consolidation owns persistent piety, tier, mirrors, decay, neglect, and
   contextual favor refresh.

Do not write persistent piety, mirror globals, or tier state directly inside a
hook receiver.

## Story Manager: Kill Actor

Receiver: non-Start-Game-Enabled Story Manager quest.

Use for: hostile kills, undead/Daedra/beast categories, murder/innocent checks,
hunt rites after validation.

Multi-consumer note: one shared receiver (`PDV_SM_KillActor`) serves multiple
race lanes — Khajiit Alkosh named-dragon classification, Khajiit Baan Dar
combat-session kill counting, and (phase 2) Redguard Ash'abah undead duty. Keep
the SM node unconditioned and classify in script so new consumers ride the same
quest.

Build notes:

- Story Manager node must use `Shares Event`.
- Receiver should be thin: validate, call router, stop/reset.
- Classify target through keywords, factions, actor base, location, and player
  state.

Anti-farm:

- direct-player attribution only unless later assisted-kill attribution is
  explicitly designed
- target category plus daily cap
- de-dupe against PO3 `ActorKilled` if that hook is later enabled

Proof path:

- hostile humanoid kill
- hostile animal kill
- neutral kill rejection
- rapid dual-kill accumulation
- dawn consolidation

## Story Manager: Crime Chain

Receiver: Story Manager quest(s) for crime gold, arrest, jail, escape, pay fine,
served time.

Use for: Imperial civic order, Stendarr justice, Nocturnal/Mephala contrast,
Talos defiance when law pressure is religiously meaningful.

Build notes:

- Treat crime events as a chain, not isolated sins.
- Store a hold-scoped marker so arrest/pay-fine/jail/served-time do not all
  score as separate moral events.
- Hidden crime and witnessed/reported crime are different theology signals.

Anti-farm:

- one chain award per hold/day or per meaningful threshold
- no reward for deliberately toggling tiny bounty states

Proof path:

- witnessed theft or assault
- pay fine
- jail/served time
- escape jail
- no double-score across the chain

## PO3: Book Read

Receiver: player alias or persistent service quest using PO3 event registration.

Use for: sacred texts, Black Books, spell tomes, ancestral records, forbidden
knowledge.

Build notes:

- Source table: `extracted/vanilla-book-signal-candidates.csv`.
- Design table: `semantic-tagging-candidates.csv`.
- Prefer one-shot StorageUtil markers per book or book family.

Anti-farm:

- one score per FormID unless a curated tier family says otherwise
- no generic book spam
- Black Books and spell tomes get their own families

Proof path:

- read ordinary book, verify no score
- read whitelisted sacred/forbidden book, verify one-shot
- save/load and re-read, verify no duplicate

## PO3: Spell Learned

Receiver: player alias or persistent service quest.

Use for: Julianos, Magnus, Syrabane, Hermaeus Mora, Auri-El/Xarxes magical study.

Build notes:

- Classify the learned spell by school, effect keywords, and curated FormLists.
- Book read and spell learned may both fire for spell tomes; choose which one
  owns scoring for that family.

Anti-farm:

- one marker per spell
- school milestone bands rather than raw spell count where possible

Proof path:

- learn a whitelisted spell from tome
- learn a non-whitelisted spell
- verify no duplicate if BookRead also fires

## PO3: Item Harvested

Receiver: player alias or service quest.

Use for: Bosmer Green Pact friction, Kyne/Kynareth nature signals, alchemy/plant
taboos, survival foraging.

Build notes:

- Source table: `extracted/vanilla-item-semantic-candidates.csv`.
- Separate plant matter, fungi, fish, meat, and alchemy ingredients.
- Treat Bosmer taboo as state/neglect pressure, not constant punishment.

Anti-farm:

- cap by ingredient family/day
- ignore repeated harvest loops in safe/farmable spaces unless the design says
  the action is meaningful

Proof path:

- harvest plant ingredient
- harvest fish/meat-like ingredient
- verify Bosmer vs non-Bosmer route differs

## PO3: Quest Stage Change

Receiver: service quest registered for curated quests only.

Use for: Daedric choices, faction commitment, civil-war allegiance, major moral
forks, Solstheim/Apocrypha milestones.

Build notes:

- Source table: `extracted/vanilla-quest-candidates.csv`.
- Design table: `quest-moral-signal-crosswalk.csv`.
- Register only for curated quests; do not listen to every quest in the game.

Anti-farm:

- one-shot marker per quest/stage/outcome
- mutually exclusive choices must write mutually exclusive markers

Proof path:

- trigger one curated stage
- reload after stage completion
- verify marker prevents duplicate score

## PO3: Shout Attack

Receiver: player alias or service quest. Verify callback name against installed
PO3 source for the selected receiver family before implementation.

Use for: Talos, Kyne, Tongues, Dragonborn identity, Nord old-way expression.

Build notes:

- Shout learning and shout use are different signals.
- Use shout family/FormList and context. Do not reward every cooldown use.

Anti-farm:

- cooldown per shout family
- no training-loop scoring

Proof path:

- use whitelisted shout in combat
- use same shout repeatedly
- use non-whitelisted shout

## PO3: Weather Change

Receiver: service quest.

Use for: Kyne/Kynareth/Khenarthi weather context, storm rites, rare environmental
favor triggers.

Build notes:

- Weather is mostly context, not direct piety.
- Pair with location, active devotional lane, and recent action.

Anti-farm:

- never score weather alone
- environmental favor only while context holds

Proof path:

- trigger weather transition through normal travel/waiting
- verify context-only behavior

## PO3: Filtered Hit / Weapon / Magic / Projectile Hit

Receiver: alias/service/effect script depending on scope.

Use for: hunt precision, martial style, blocks/bashes, spell-domain impact,
projectile hunt validation.

Build notes:

- Use narrow filters.
- Decode hit flags in a small compile-tested helper before using them in deity
  logic.
- For archery/hunting, validate target and location; target dummies should not
  count.

Anti-farm:

- cooldowns by target and family
- no open-ended hit spam
- no training dummy loops

Proof path:

- real hostile target
- blocked/bash/power/sneak variants if used
- target dummy or non-hostile rejection

## Player Combat Session Tracker (OnCombatStateChanged + bounded poll)

Receiver: player alias in the persistent events quest (`PDV_PlayerEvents`).

Use for: adversity/reversal beats — outnumbered wins, near-fatal reversals,
combat-context state that no single event carries (Baan Dar; future
combat-courage signals).

Build notes:

- `OnCombatStateChanged(Actor akTarget, int aeCombatState)` on the player
  alias: state 1 = combat enter (clear session keys, start poll), state 0 =
  combat exit (evaluate, award, stop poll).
- Poll is a `RegisterForSingleUpdate` chain (~4s) that re-registers ONLY while
  the player is in combat; self-terminates on combat exit. Never a perpetual
  `RegisterForUpdate`.
- Session counters (kills, max victim level delta, low-health/near-fatal
  flags) live in StorageUtil keys cleared on combat enter; kill attribution is
  fed by the Story Manager Kill Actor receiver, not by scanning.
- No hostile-scanning cloaks, no FindAllReferences.

Anti-farm:

- adversity gate: award requires the player's health to have actually dropped
  (e.g. below 50%) during the session, so steamroll clears stay silent
- per-day guard on the common award, per-week cap on the rare/marked award
- shared daily-decay multiplier with the matching proof activator key

Proof path:

- desperate multi-kill fight (health dipped) -> award
- steamroll multi-kill fight at full health -> silent
- flee after near-death without a kill -> silent
- second award same day/week -> guard blocks
- save/load mid-combat -> session keys behave

## Alias OnItemAdded: Pickpocket Success

Receiver: player alias in the persistent events quest (`PDV_PlayerEvents`).

Use for: successful undetected theft from a living NPC (Rajhin elegant theft;
future artful-theft families). PO3 has no pickpocket-success event; this is the
only surface that fires on success with the source identity attached.

Build notes:

- `OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference
  akItemReference, ObjectReference akSourceContainer)`; FIRST line must be the
  `akSourceContainer as Actor` cast with early return on `None` so loot
  containers and barter transfers exit in one cast.
- Qualify the act: player sneaking, source actor alive (corpse looting is not
  theft), player undetected by the source (`IsDetectedBy`), source not a
  teammate/follower.
- Qualify the target: curated notable-target FormList membership, or a value
  floor for the generic fallback. Petty grabs from generic NPCs are rejected.

Anti-farm:

- per-target cooldown (StorageUtil key per ActorBase FormID, multi-day)
- value floor on the generic fallback
- shared daily-decay multiplier with the matching proof activator key

Proof path:

- undetected pickpocket of a notable/high-value target -> award
- petty grab from a generic NPC -> silent
- corpse loot -> silent
- detected attempt -> silent (botched-theft contrast routes separately if
  built)
- same target inside cooldown -> blocked

## Custom Activator: Shrine / Offering / Ritual

Receiver: object script or overlay receiver.

Use for: authored devotional actions, offerings, commitment, cure privilege,
portable shrine rites.

Build notes:

- Prefer custom PDV activators for custom rituals.
- Do not replace vanilla shrine scripts unless a later phase explicitly proves a
  safe overlay/patch route.

Anti-farm:

- per shrine/deity/day cooldown
- item whitelist and value bands for offerings

Proof path:

- activate shrine/ritual object
- repeat same day
- save/load and repeat after cooldown
