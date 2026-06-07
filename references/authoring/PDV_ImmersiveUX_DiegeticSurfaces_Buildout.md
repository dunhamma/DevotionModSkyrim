# PDV Diegetic UX Build-Out — Tier B in depth, plus a soft Tier C

**Status:** Design build-out / exploration. Companion to
`PDV_ImmersiveUX_BeyondPrisma_ThinkPiece.md`. Not a locked build spec — but written to be
spec-ready per surface.
**Date:** 2026-06-05

## Decisions locked this session (the frame for everything below)

- **No skill tree.** The Custom Skills Framework "Devotion tree" idea is **dropped** — it adds
  in-game progression cost to the player and crosses the experience line PDV is protecting.
  Devotion is felt and reflected, never *spent and leveled*.
- **Soft dependencies are acceptable**, and PDV should **package its own assets** to shrink the
  hard-dependency surface. The pattern is "require the *engine*, ship the *content*":
  - **Animations:** require only **OAR** (the runtime); ship PDV's prayer/offer/rite animations as
    a PDV-owned **OAR submod folder**. OAR reads any submod folder, so users need no third-party
    animation mod ([OAR](https://www.nexusmods.com/skyrimspecialedition/mods/92109)).
  - **RaceMenu / NiOverride** is treated as a **baseline given** for PDV's modlist targets and most
    of the people in this space — overlays can be authored against it directly, with a soft guard.
- **Everything in Tier B is non-voiced** and therefore inside the §21.3 voiced-content non-goal.
- **Everything is event-driven** — these surfaces subscribe to transitions PDV *already detects*;
  no polling loops, honoring the "Compatibility is trust" hygiene rule.

---

## 1. The backbone: one transition, many channels

Tier B is not nine unrelated features. It is **one feedback bus with nine output channels.** The
audit's headline (`PDV_ImmersionAudit_MissedOpportunities.md` §0) and the §16.7 transition-surfacing
contract already define the moments; the existing `SurfaceTransition()` helper is the single
entry point. Tier B just gives that helper *more than text to emit*.

**Proposal — a "surface profile" per transition.** Each transition declares a **tone** and a
**channel combo** instead of defaulting to "a notification." `SurfaceTransition()` (or a thin
`SurfaceTransitionDiegetic()` sibling) reads the profile and fires the channels.

| Transition moment (audit) | Tone | Imagespace | Aura/shader | Sound | Music | Journal | Medallion | Body mark | Notification |
|---|---|---|---|---|---|---|---|---|---|
| Tier reached (broad) | reverent rise | warm gold bloom (1s) | brief gold pulse | soft chime | — | dated line | tier text updates | — | optional 1 line |
| **Patron emergence** | revelation | gentle white bloom | white pulse | low swell | — | "a god reaches out" line | active-deity flips | faint warpaint appears | 1 MessageBox (already a choice) |
| **Curse onset** | dread | grey/cold vignette | cold shroud shader | hollow tone | dissonant bed (while active) | line in god's voice | medallion "dims" | **scar appears** | MessageBox (god-voice) |
| **Curse cure** (audit C2: silent today) | release | clearing cross-fade | cleansing shimmer | rising chime | resolve cue | "the scar closes" line | medallion brightens | **scar fades** | 1 MessageBox |
| Sect / mode / path switch | turning | brief neutral fade | — | tonal click | sect motif | line | instrument label flips | — | optional |
| **Neglect onset** (audit C3) | absence | slow desaturate | — | distant/hollow tone | thinning ambient | "X has gone quiet" line | medallion greys | — | rare warning + recovery hint |
| Champion entry | apotheosis | strong gold | sustained aura | full swell | Champion motif | line | medallion radiant | full warpaint | MessageBox (god-voice) |
| Daily favor noted (routine) | quiet ack | — | — | tiny chime (optional) | — | **batched** at dawn | live | — | **silent** (policy default) |

This table *is* the design: it operationalizes the lessons-doc policy ("routine piety silent;
transitions legible; recovery hints on neglect") and turns the audit's five silent moments into
multi-sensory, mostly wordless beats. Each column below is one Tier-B surface.

A profile lives as data (a struct/JSON the helper reads), so **tuning tone per race/deity is a copy
+ table edit, not new code** — matching how `symbolSpecs` / `eventLanguage` already work.

---

## 2. Tier B surfaces — in depth

Each surface: **concept → tools & exact API → PDV wiring → packaging/deps → persistence gotchas →
asset cost → restraint rules → worked example.**

---

### B1. The living medallion — `Description Framework` (MISC item)

**Concept.** A single carried **Devotional Medallion** (MISC item) whose hover-description *is* the
status panel. No menu opened: the player reads their faith in their own inventory. This is the
zero-menu expression of `handoff/PrismaMedallionRoster_DesignHandoff.md`.

**Tools & API.** [Description Framework](https://www.nexusmods.com/skyrimspecialedition/mods/105799)
exposes Papyrus `AddDescription` / `SetDescription` / `GetDescription`. po3 PE's `GetDescription`
also reads DF descriptions ([po3 PE](https://www.nexusmods.com/skyrimspecialedition/mods/22854)).
**Use a MISC item** — DF targets Misc/Food/Potion/Scroll/Weapon/Armor; **BOOK is not a DF target**,
so the existing token (`PDV_PortableDevotionalToken_BuildSpec.md`, a BOOK ritual focus) stays the
*read-view rite*, and the medallion is a *new MISC* for the *hover status*. Two items, two jobs.

**PDV wiring.** On every relevant EventBus transition and at dawn consolidation, a helper rebuilds
the medallion string from StorageUtil piety:
`SetDescription(PDV_Medallion, BuildMedallionText(activeDeity, tier, daysSinceHeard, curseState))`.
Text reads e.g. *"Kyne's favor — Devoted. She has not heard you in 3 days."* For non-patron broad
worship, summarize the top one or two deities.

**Packaging / deps.** Soft-dep on Description Framework: guard with `IsPluginInstalled` /
availability check; if absent, the medallion still exists as a flavor item and PDV falls back to the
Survey-Devotion spell readout it already has. **No PDV DLL needed.**

**Persistence gotcha (verified).** DF Papyrus descriptions **do not survive a game restart** —
reapply in `OnPlayerLoadGame()`. Wire the rebuild into PDV's existing load hook.

**Asset cost.** One MISC record + one inventory icon/mesh (can reuse a vanilla amulet). No new art
strictly required for v1.

**Restraint.** Pure pull — never pushes. The description can be rich because the player chose to
look. This is the safe place to put *numbers* the audit says are currently opaque (Breton Integrity,
Witchcraft exposure proximity) without violating "debug is not UX."

**Worked example (Khajiit silent patron — audit #2).** Khajiit patron emergence is invisible today.
The medallion makes it *discoverable*: before emergence it reads "the moons watch, undecided"; after,
"Khenarthi claims your road." The player who checks understands; the player who doesn't isn't
spammed.

---

### B2. The self-writing devotional journal — `Dynamic Book Framework`

**Concept.** A carried **"Book of Days"** the gods/ancestors write into. Each transition appends a
dated, in-voice line. Converts the audit's core complaint ("computes things it never tells you") into
a **browsable history** rather than a nagging meter — and is the natural home for the per-race
"neglect texture" copy that's authored but currently has nowhere quiet to land.

**Tools & API.** [Dynamic Book Framework](https://www.nexusmods.com/skyrimspecialedition/mods/152364)
— SKSE; books load text from external `.txt`; **Papyrus + C++ append API** (`AppendEntry`-style;
key by book title). A [Journal-UI companion](https://www.nexusmods.com/skyrimspecialedition/mods/176672)
exists if a nicer read view is wanted. Lighter alternative for pure Papyrus authoring:
[Note Crafting](https://www.nexusmods.com/skyrimspecialedition/mods/119569) ships `NoteCrafting.psc`.

**PDV wiring.** `SurfaceTransition()` calls `AppendDevotionEntry(deity, toneKey, dateString)` which
selects authored copy (the same `PDV_Notif_*` / texture strings already written) and appends it.
**Neglect cadence (audit C3) is solved structurally here:** fire one journal line per tier-drop, and
*not again until recovery* — the book shows the slip once, legibly, instead of repeating a toast.

**Packaging / deps.** Soft-dep on DBF; if absent, fall back to a static BOOK that PDV updates less
granularly (or skip the journal channel). Ship the seed `.txt` and the BOOK record with PDV.

**Persistence.** DBF persists entries to its own files — durable across saves; just guard
re-registration on load.

**Asset cost.** One BOOK record + authored line bank (reuse existing texture/notification copy).
Zero new art.

**Restraint.** Append-only, read on demand. Batch routine favor into a **single dawn digest line**
("*Sundas — the day's small devotions noted*") so the book doesn't bloat — directly implementing the
policy table's "one quiet daily resolution."

**Worked example (Dunmer ancestor silence — audit).** Layer-1 ancestor movement is imperceptible to
non-combat players. The journal gives ancestors a quiet voice: "*The ash remembers you came to the
shrine today.*" — perceptible without forcing a combat trigger.

---

### B3. Auras & marks of presence — effect shaders / art objects / light

**Concept.** A brief, wordless **shader pulse** on the player at the tonal peak of a transition: gold
at a tier/Champion beat, a cold shroud at curse onset, a **cleansing shimmer at curse cure** (the
universally-silent moment, audit C2).

**Tools & API.** Two routes:
- **Vanilla baseline:** a self-targeted ability/spell carrying a **Visual Effect (RFCT)** with an
  **Effect Shader (EFSH)** and optional **Art Object (ARTO)**; add/remove the ability to start/stop.
  No SKSE needed.
- **po3 PE direct route:** apply/stop effect shaders and play art objects on a reference directly
  (po3 PE adds EffectShader/ObjectReference functions) — cleaner for timed one-shots.
- **Light:** attach a faint light at a private-shrine rite via po3 PE / a placed LIGH.

**PDV wiring.** `SurfaceTransition()` → `PlayDevotionShader(toneKey)` picks the EFSH per tone from a
small table. Tie to the same events; **duration ≤ ~1.5s** for pulses; the only *sustained* shader is
a curse "shroud" that maps to a tracked curse-state and clears on cure.

**Packaging / deps.** Vanilla route = **zero dependency**. po3 PE route = soft-dep (po3 PE is
near-ubiquitous and already assumed elsewhere). Ship EFSH/ARTO/RFCT records with PDV.

**Asset cost.** Effect-shader textures (gradient/particle) — can start from vanilla EFSH (e.g. heal,
ash, frost) recolored. Low-to-moderate art.

**Restraint.** Rare and short. A lingering shader reads as a bug. Never on routine favor.

**Worked example (curse cure parity — audit C2).** Vampirism/lycanthropy cure is silent across
races. A 1s cleansing shimmer + clearing imagespace (B4) + rising chime (B5) makes the cure *feel
earned* with zero text — exactly the "cure should feel earned, not automatic" Nord note.

---

### B4. The screen reacts — imagespace modifiers (IMAD)

**Concept.** A momentary screen tint for the *mood* of a state change: warm gold bloom at patron
emergence, grey desaturate as neglect deepens, blood-dim on a taboo breach, clearing fade at cure.

**Tools & API.** **Pure vanilla Papyrus:** `ImageSpaceModifier.Apply(strength)`,
`ApplyCrossFade()`, `PopTo()`, `Remove()` on IMAD records. po3 PE has helpers but isn't required.

**PDV wiring.** `SurfaceTransition()` → `ApplyMoodImagespace(toneKey)` with a 1–2s cross-fade; for
the slow neglect mood, a very subtle, brief desaturate at the moment of onset only (not persistent —
a persistent grade would fight ENB and read as "broken").

**Packaging / deps.** **Zero dependency** (base CK records).

**Asset cost.** A handful of IMAD records (tints/blooms/desaturates). Authored in CK; no textures.

**Restraint.** Short cross-fades only. This is the most "felt, least read" channel — perfect for the
patron-emergence "revelation" the audit flags as currently having *nothing* tell the player why their
blessings shifted.

**Worked example (Altmer Lorkhan penalty — audit).** First time the Lorkhan-adjacency penalty bites,
a brief cold imagespace + the naming MessageBox the sheet already wants makes the signature mechanic
*felt*, not just numerically present.

---

### B5. Favor you can hear — sound & music

**Concept.** Audio is the lowest-friction "quiet" channel: it never occludes the screen or demands a
dismiss. Two layers — **discrete cues** (a chime on favor, a hollow tone on disfavor) and
**ambient music** (a reverent bed at patron-shrine prayer, a dissonant bed during a curse, a distinct
tell on Khajiit full-moon nights).

**Tools & API.**
- **Cues:** custom **SNDR/SOUN** records + `Sound.Play(ref)`. Distribute existing sounds onto forms
  with [Sound Record Distributor](https://www.nexusmods.com/skyrimspecialedition/mods/77815) if
  useful.
- **Music:** **MUSC/MUST** records ([UESP MUSC](https://en.m.uesp.net/wiki/Skyrim_Mod:Mod_File_Format/MUSC));
  add/remove a music type by entering/leaving a state (the formlist-swap pattern from
  [Combat Music Fix - Papyrus](https://www.nexusmods.com/skyrimspecialedition/mods/78057)); or
  [Music Type Distributor] to attach types by condition.

**PDV wiring.** Discrete cue table keyed by tone (`PlayDevotionCue(toneKey)`); ambient music via a
state-scoped music type added when the player prays at a patron shrine / enters a curse state, removed
on exit. Routine favor cue is **off by default**, opt-in via MCM (policy: routine is silent).

**Packaging / deps.** Cues = **zero dependency** (ship the .wav/.xwm + records). Conditional music
distribution = soft-dep on the distributor of choice, or do it script-side with no dep.

**Asset cost.** A small bank of short audio stings + 1–3 ambient loops. Moderate (audio sourcing/
licensing) — but a couple of chimes is cheap and high-impact.

**Restraint.** Sparse. A cue per *transition*, never per piety tick. Music swaps must be reversible
and not stomp combat/quest music (respect the Combat Music Fix lesson).

**Worked example (Khajiit moon cycle — audit).** The moon cycle is currently invisible. A distinct,
quiet musical tell on full-moon nights (paired with B4 moonlight bloom) surfaces it without a HUD
element, on the verified 8-phase clock the instrument spec already computes.

---

### B6. Devotion you perform — prayer / offering animations (PDV-bundled OAR submod)

**Concept.** Rites should be *performed*, not poked through a menu. A kneel/offer/meditation
animation at shrines and on the BOOK ritual-focus turns devotion into an action — answering the
lessons-doc rule "roleplay friction should open a decision," not be a menu chore.

**Tools & API.**
- **Engine (only hard-ish dep):** [OAR](https://www.nexusmods.com/skyrimspecialedition/mods/92109).
- **Content (PDV-owned):** ship a **PDV OAR submod folder** with prayer/offer/meditate clips and
  per-condition JSON (active deity, shrine type, race). OAR reads any submod folder, so **no
  third-party animation mod is required** — this is the "bundle to reduce dependency" plan made
  concrete.
- **Trigger:** play via the shrine activation / BOOK fragment; optionally
  [Immersive Interactions](https://www.nexusmods.com/skyrimspecialedition/mods/47670)-style Shift+E
  if we want a dedicated interact key, but PDV can trigger animations itself without it.
- **Reference build:** how [Pilgrim](https://www.nexusmods.com/skyrimspecialedition/mods/54099) pairs
  prayer mechanics with [Divines Prayer Animations](https://www.nexusmods.com/skyrimspecialedition/mods/109175)
  (OAR-based).

**PDV wiring.** The existing `EVT_DUNMER_PORTABLE_SHRINE` / token routes and shrine co-attachment
(the §21.3 "per-reference co-attachment" posture) gain an animation play call before the EventBus
fire. Race-specific postures (Dunmer ash-shrine, Orc forge dedication, Khajiit moon rite) are just
different submod conditions over the same trigger.

**Packaging / deps.** Hard-dep on OAR engine only; **all clips shipped by PDV**. Soft-guard so that
if OAR is absent the rite still fires its event/effects without the animation.

**Asset cost.** Animation clips — the **highest-skill** Tier-B item (needs an animator or
appropriately-licensed source clips). Mitigated by reusing/retargeting existing idle/pray anims.

**Restraint.** Skippable/interruptible; never locks the player in a long forced animation.

**Worked example (token rites).** Today the token is a silent book-read. With a bundled kneel-offer
animation the three exile-race tokens (`PDV_PortableDevotionalToken_BuildSpec.md`) become a visible
act of faith, anywhere, with one shared clip + per-race conditions.

---

### B7. Marks of devotion & curse on the body — RaceMenu / NiOverride (baseline)

**Concept.** What PDV tracks, the player can *see on themselves*: a **visible curse scar**
(vampire/werewolf onset), a faint **devotion warpaint/tattoo** at Champion tier, an **ancestor-ash
mark** for deep Dunmer ancestor depth. The curse state becomes embodied, not just a stat.

**Tools & API.** RaceMenu's `NiOverride.AddNodeOverrideString` (slot texture) /
`AddNodeOverrideInt` (tint/emissive) to apply body/face overlays at runtime
([overlay how-to](http://winkingskeever.com/how-to-create-new-body-paints-and-overlays-for-racemenu-part-2/)).
Treated as **baseline** per this session's decision.

**PDV wiring.** `SurfaceTransition()` for curse onset/cure and Champion entry calls
`SetDevotionOverlay(slot, texture, tint)` / clears it on the inverse transition. Reapply on
`OnPlayerLoadGame` (overlays are runtime-applied). Respect overlay-slot budget
(`NiOverride.ini`) — PDV should use one or two named slots, not hog the pool.

**Packaging / deps.** RaceMenu/NiOverride is the baseline; still **soft-guard** the calls so a
missing NiOverride degrades gracefully (no scar art, everything else works). Ship overlay textures
with PDV.

**Asset cost.** Overlay textures (scar, warpaint, ash) — moderate art, but a small set covers many
moments via tint variation.

**Restraint.** Marks should be subtle and lore-true; tie strictly to *major* embodied states (curse,
Champion), never to routine tier-ups, so seeing one always means something.

**Worked example (curse states across races).** The audit wants curse onset *and cure* legible
per race. A scar that appears on onset and **fades on cure** gives a permanent-feeling,
non-textual record of the arc — and pairs with the B3 cleansing shimmer at the cure beat.

---

### B8. The world recognizes you — SPID stance recognition (non-voiced, V1-legal)

**Concept.** Priests of your patron warm to you; zealots of a rival cool. Delivered as
**disposition / faction / stance** effects — the explicitly §21.3-legal "non-voiced equivalent
(disposition/stance effect)" — *not* spoken lines.

**Tools & API.** [SPID](https://www.nexusmods.com/skyrimspecialedition/mods/36869) attaches
keywords/factions/packages to NPCs by condition (e.g. priest class + patron temple). PDV flips a
global/keyword the SPID-applied faction reacts to.

**PDV wiring.** PDV sets CK-readable globals it already maintains
(`PDV_GLO_ActiveDeityIndex`, `PDV_GLO_ActiveTier`); SPID-distributed factions/relationship ranks key
off those for disposition shifts. No new NPC records edited (avoids the compatibility cost the §21.3
notes call out re: edited dialogue records).

**Packaging / deps.** Soft-dep on SPID (near-ubiquitous). Ship the `_DISTR.ini`.

**Asset cost.** Config only. Zero art/audio.

**Restraint.** Stance only for V1. The *spoken* recognition lines stay V2 (voiced) — consistent with
the existing V1/V2 split and `PDV_RecognitionDialogueScalePacket.md`.

**Worked example (Orc stronghold acceptance — audit).** Forge-quality / stronghold-acceptance
recognition can surface as a Malacath-faction disposition warming at stronghold NPCs — felt as
"they treat you differently," no voice required.

---

### B9. Quiet ambiance — weather & light (low priority, include for completeness)

**Concept.** Subtle environmental tells: Kyne worship faintly favoring clear skies after a clean
hunt; an oppressive sky at deep neglect. A faint light kindling at a shrine you've prayed at.

**Tools & API.** po3 PE weather functions / WTHR records; placed LIGH or po3 light-attach for the
shrine glow.

**PDV wiring.** Gate behind explicit, rare conditions; **opt-in via MCM** because weather is
high-visibility and easy to overdo.

**Packaging / deps.** Soft-dep on po3 PE for weather control; light glow can be vanilla.

**Asset cost.** Low (reuse vanilla weathers/lights).

**Restraint.** *Use sparingly.* Listed last on purpose — highest risk of feeling gimmicky.

---

## 3. Soft Tier C — a wider, more exploratory idea bank

"Soft" = lower-confidence, lighter-detail, opt-in or supplementary. These either harden existing
surfaces or add texture; pick the ones that earn their dependency.

### C0. Notification discipline (the cheapest win, no new feature)
- **Cooperate, don't fight,** [iHUD](https://www.nexusmods.com/skyrimspecialedition/mods/12440) /
  ImmersiveHUD SKSE — never force-show something the player's HUD-fader is hiding.
- Ship PDV's notification policy (the lessons-doc draft table) as **MCM verbosity presets**
  (Silent / Transitions-only / Verbose), echoing why
  [Configurable Notification Messages](https://www.nexusmods.com/skyrimspecialedition/mods/65573)
  exists. **This is a design choice, not a dependency**, and it's the highest ROI of all: route
  routine piety to silence + journal + (optional) sound, reserve corner text for true transitions.

### C1. The shrine remembers you — diegetic shrine state
- A **candle/bowl that lights** (or a faint glow, B9) on shrines of a deity you favor; a swapped
  reverent **idle marker**. Via [Base Object Swapper](https://www.nexusmods.com/skyrimspecialedition/mods/)
  for patron-themed shrine dressing, or per-reference co-attachment (PDV's sanctioned posture).
- *Soft:* art/condition cost; keep to patron shrines.

### C2. Pilgrimage made spatial — map notes & markers
- Drop a **custom map marker / map note** when a god "calls" you somewhere (a far shrine, the Bosmer
  "living story" location, the Redguard Far Shores beat). Turns devotion into *places to go* without a
  quest.
- *Soft:* uses vanilla map-marker/note APIs; risk of clutter — make it one active "call" at a time.

### C3. The god in a dream — sleep interstitial
- On a major neglect threshold or a patron's first reach, intercept **sleep**: fade-to-black → a
  short god-voice MessageBox or a journal page → wake. A diegetic "vision" beat with **zero voice and
  zero new art**.
- *Soft:* must be rare (sleep is frequent); one-shot guards per arc. Pairs naturally with B2/B4.

### C4. Themed loading screens — LSCR records
- A handful of **devotion-themed loading screens** (lore text + a deity model) that appear once the
  player has a patron. Free worldbuilding on a surface players already stare at.
- *Soft:* LSCR authoring; keep the pool small so it feels curated, not spammy.

### C5. The relic that grows — charge/state on the token
- The BOOK ritual-focus / a relic MISC gains **visible charges or a state name** as devotion deepens
  (via Description Framework text, B1, or enchant-charge meter). A tangible "this object is becoming
  holy" read.
- *Soft:* overlaps B1; decide if relic and medallion are one item or two.

### C6. Followers notice — comment hooks (non-voiced)
- Hook existing **follower/comment frameworks** so a companion silently reacts (a generic
  acknowledgement line that already has voice, or a subtitle-free emote) when you perform a rite.
- *Soft / careful:* anything *spoken and new* is V2 per §21.3; keep this to reusing existing voiced
  generic lines or pure emote/stance.

### C7. Persistent ambient meter — iWant Widgets (only if playtesting demands it)
- If players say they *want* an always-on piety/neglect read without opening anything, a single
  [iWant Widgets NG](https://www.nexusmods.com/skyrimspecialedition/mods/96410) meter/icon —
  **Papyrus-only, no PDV DLL** — is the lightest way, and it cooperates with iHUD fading.
- *Soft:* risks the "second hunger meter" feeling the lessons doc warns against — **off by default**,
  opt-in, and never required to understand PDV.

### C8. Transient stateful bar — TrueHUD special bar
- For a **timed** curse-drain or a Champion-window countdown only,
  [TrueHUD](https://www.nexusmods.com/skyrimspecialedition/mods/62775)'s special-bar API shows a bar
  that *fills/drains and then goes away*. Good for momentary tension, wrong for steady status.
- *Soft:* hard SKSE dep; justify only if a real timed mechanic ships.

### C9. Vanilla-menu injection — Infinity UI
- Add a **devotion line to the vanilla Active-Effects / Magic menu** or a glyph to the shrine
  activation prompt via [Infinity UI](https://www.nexusmods.com/skyrimspecialedition/mods/74483) —
  diegetic-adjacent because it lives in the menu the player already uses.
- *Soft:* needs SWF authoring; revisit if a native-menu read is wanted over the Prisma panel.

---

## 4. Asset & dependency summary (what each surface actually costs)

| Surface | Hard dep | Soft dep | PDV-shipped assets | Build skill | Art/audio cost |
|---|---|---|---|---|---|
| B1 Medallion text | — | Description Framework | MISC + icon | Papyrus | tiny |
| B2 Journal | — | Dynamic Book Framework | BOOK + .txt + copy | Papyrus + writing | tiny |
| B3 Aura/shader | — (vanilla) | po3 PE (cleaner) | EFSH/ARTO/RFCT + SPEL | CK + Papyrus | low–med (textures) |
| B4 Imagespace | — | — | IMAD records | CK + Papyrus | none |
| B5 Sound/music | — | SRD / Music Type Distributor | SNDR/MUSC + audio | CK + audio | med (audio) |
| B6 Prayer anims | **OAR engine** | Immersive Interactions | **PDV OAR submod (clips)** | anim | high (animation) |
| B7 Body marks | — | RaceMenu/NiOverride (baseline) | overlay textures | Papyrus + texture | med |
| B8 SPID stance | — | SPID | _DISTR.ini | config | none |
| B9 Weather/light | — | po3 PE | WTHR/LIGH | CK | low |

---

## 5. Recommended build order

1. **C0 notification discipline + B4 imagespace + B5 cues** — near-zero dependency, immediately makes
   the five silent transitions *felt*. Start here.
2. **B1 medallion + B2 journal** — the diegetic status/history pair; light deps, high legibility,
   solves the audit's headline and the neglect-cadence problem.
3. **B3 auras + B7 body marks** — embody the curse onset/**cure** and Champion beats (parity gaps the
   audit calls out across races).
4. **B6 prayer animations (bundled OAR submod)** — the highest-craft item; lands when an animator/
   source is available; everything else degrades gracefully without it.
5. **B8 SPID stance** — cheap world reactivity once globals are stable.
6. **Soft Tier C** — pick per playtest: dream interstitial (C3) and shrine memory (C1) are the most
   evocative low-risk adds; meters (C7/C8) only if players ask.

All six steps feed the **one `SurfaceTransition()` backbone** (§1) — so this is incremental: each
surface is another channel on a profile table, not a new system.

---

## Appendix — sources

Repo: `PDV_ImmersiveUX_BeyondPrisma_ThinkPiece.md`,
`references/vanilla-gameplay/pdv-crosswalk/immersive-ux-lessons.md`,
`references/authoring/PDV_ImmersionAudit_MissedOpportunities.md`,
`references/authoring/PDV_PortableDevotionalToken_BuildSpec.md`,
`handoff/PrismaMedallionRoster_DesignHandoff.md`, `PDV_Architecture_v3.md` §16.7 / §21.3.

Web:
- Description Framework — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/105799)
- Dynamic Book Framework — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/152364) · Journal UI — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/176672) · Note Crafting — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/119569)
- powerofthree's Papyrus Extender — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/22854) · [github](https://github.com/powerof3/PapyrusExtenderSSE)
- OAR — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/92109) · Divines Prayer Animations — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/109175) · Immersive Interactions — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/47670) · Pilgrim — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/54099)
- RaceMenu overlay how-to — [winkingskeever](http://winkingskeever.com/how-to-create-new-body-paints-and-overlays-for-racemenu-part-2/)
- SPID — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/36869)
- Sound Record Distributor — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/77815) · MUSC — [UESP](https://en.m.uesp.net/wiki/Skyrim_Mod:Mod_File_Format/MUSC) · Combat Music Fix — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/78057)
- iWant Widgets NG — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/96410) · TrueHUD — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/62775) · Infinity UI — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/74483)
- iHUD — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/12440) · Configurable Notification Messages — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/65573)
