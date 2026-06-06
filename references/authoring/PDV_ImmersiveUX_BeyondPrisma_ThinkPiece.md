# PDV Immersive UX — Beyond Prisma: A Think Piece on Alternative & Complementary Surfaces

**Status:** Exploration / think piece. Not a build spec, not a scope commitment.
**Date:** 2026-06-05
**Question asked:** *"Can we find other options outside of Prisma UI for immersive UX? Use the repo as a
reference for what we want, then go wide and deep on Nexus / the modding world for both ideas and the
tools to build them."*

**One-line answer:** Yes — and the framing that gets the best result is **not "replace Prisma" but "stop
treating Prisma as the whole UX."** Prisma is one (excellent) surface in a portfolio. PDV's own design law
says the best religion feel is *quiet, diegetic, and recoverable*
(`references/vanilla-gameplay/pdv-crosswalk/immersive-ux-lessons.md`). Most of that law is best served by
surfaces that are **not a custom canvas at all** — item text, screen tints, auras, music, animation,
recognition. This doc maps that whole space, names the tool for each, and ranks the bets.

> **Decisions made after this doc was first drafted (2026-06-05) — read alongside it:**
> - **No skill tree.** The Custom Skills Framework "Devotion tree" (Tier A / Tier 3 #8 below) is **dropped** —
>   it adds in-game progression cost and crosses PDV's experience line. Devotion is felt and reflected, never
>   spent and leveled. Strikethrough left in place below for the record.
> - **Soft dependencies are acceptable; PDV bundles its own assets** to shrink the hard-dep surface (require
>   the *engine*, ship the *content* — esp. animations as a PDV-owned OAR submod).
> - **RaceMenu / NiOverride is treated as a baseline given** for PDV's modlist targets.
> - **The detailed build-out of the diegetic surfaces (Tier B) and a soft Tier C now lives in
>   `PDV_ImmersiveUX_DiegeticSurfaces_Buildout.md`** — that doc supersedes the brief Tier-1/2/3 sketch here.

---

## 0. What Prisma actually buys us (so we know what we'd be replacing or keeping)

From `native/DevotionPrismaBridge/README.md` and the instrument specs, Prisma UI currently owns five jobs:

1. **Overlay toasts** — transient favor / dawn / neglect / tier / rivalry pops.
2. **A focused devotion panel** — the "open my devotion screen" pull surface.
3. **Startup commitment popups** — stylized option cards at first load.
4. **Per-race "instruments"** — bespoke data-viz: Khajiit lunar dial, Argonian Hist tree, Dunmer ancestor
   masks, Orc forge, Redguard sect blades, Bosmer bound branch, patron piety bar.
5. **Deity glyphs** — the 49+ symbol roster.

**Prisma's genuine moat is #4.** Nothing else in the Skyrim toolchain renders *arbitrary, live, lore-shaped
data visualization* — a moon that drifts through eight verified phases, a tree that grows roots — the way an
HTML/JS canvas does ([Prisma UI](https://www.nexusmods.com/skyrimspecialedition/mods/148718),
[docs](https://www.prismaui.dev/getting-started/introduction/)). Keep that.

**Prisma's costs**, which justify looking wider:

- **A hard C++/SKSE native dependency** PDV authored and must maintain (`DevotionPrismaBridge.dll`), plus the
  Prisma plugin itself. The `immersive-ux-lessons.md` "Compatibility is trust" rule says every hard
  SKSE-plugin dep is a trust tax in long modlists.
- **It is a menu/overlay** — i.e. abstract, on-glass, "UI." The same lessons doc warns repeatedly that PDV
  must "default to diegetic surfaces" and not "feel like UI spam instead of religion."
- **It is a pull or push-popup surface.** It is *seen*, then dismissed. It does not persist in the world.

So the strategic gap is: **diegetic, persistent, in-world surfaces that the player encounters rather than
opens.** That is where almost all the "other options" live.

---

## 1. The design space (two axes)

Plot every surface on two axes and the gaps become obvious:

```
                         DIEGETIC (in-world fiction)
                                   ^
        prayer animation •         |        • self-writing devotional journal
        effect-shader aura •       |        • dynamic medallion description
        divine imagespace tint •   |        • books / notes that rewrite
        temple music swell •       |        • body "marks of devotion"
        favor/disfavor sound cue • |        • NPC recognition (V2 voiced / Mantella)
   -------------------------------+--------------------------------> PULL
   PUSH (mod tells you)            |        (player checks)
        HUD notification (MESG) •  |        • Prisma devotion panel
        Prisma overlay toast •     |        • Survey Devotion spell readout
        tier-up MessageBox •       |        • Custom Skills devotion tree
        widget meter (TrueHUD) •   |        • MCM status page
                                   |
                                   v
                          ABSTRACT (on-glass UI)
```

PDV today is **heavy in the bottom half** (notifications, MessageBoxes, Prisma overlay/panel, MCM, Survey
spell) and **light in the top half** (the diegetic quadrant the lessons doc says wins). Every recommendation
below is really an argument for *moving mass into the top-left quadrant.*

This also re-frames the "Surface the transitions" headline finding from
`references/authoring/PDV_ImmersionAudit_MissedOpportunities.md`: the five silent moments (tier, patron
emergence, curse onset/cure, sect/mode switch, neglect onset) don't *need* a Prisma toast each. Each could
be a tint, a sound, a journal line, an aura — chosen for tone, not defaulted to "a notification."

---

## 2. Catalog — Tier A: custom-canvas UI (Prisma's peers, if we ever wanted off Prisma)

These are the **direct alternatives** to Prisma as a UI engine. None beats Prisma at the instruments, but each
has a niche where it's lighter or more native.

| Tool | What it is | Where it'd fit PDV | Trade vs Prisma |
|---|---|---|---|
| **SKSE Menu Framework / SSE ImGui** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/120352), [SDK](https://github.com/Thiago099/SKSE-Menu-Framework-SDK)) | Dear ImGui windows registered by SKSE plugins | A dev/debug devotion inspector; a lightweight panel | Pure C++, no HTML/art pipeline; looks like a tool, not lore. Great for **debug UX** (which the lessons doc says must be *off* the player path), weak for player immersion. |
| **iWant Widgets (NG)** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/36457), [NG](https://www.nexusmods.com/skyrimspecialedition/mods/96410)) | **Flash-free** Papyrus-driven HUD widgets (labels, meters, icons) — solves the "no Adobe Flash" barrier | A persistent piety/neglect meter or patron glyph on the HUD, driven straight from Papyrus | **No native DLL of our own**, no C++ — Papyrus-only. Can't do the instruments' bespoke vector art, but can do meters/icons cheaply and is a far lighter dependency. |
| **SkyUI HUD Widget Framework** ([source](https://github.com/schlangster/skyui)) | The original SWF widget base/meter classes | Same meter/icon role, if we wanted to author SWF | Needs Flash authoring tools (the barrier iWant exists to remove). Mostly legacy; prefer iWant. |
| **TrueHUD widget API** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/62775)) | SKSE hub for HUD bars; exposes a "special bar" API other plugins drive | A "divine favor" special bar above health during a Champion/curse moment | Hard SKSE dep; designed for combat bars. Good for **transient** stateful bars (a curse "draining" bar), overkill for steady status. |
| **Infinity UI** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/74483)) | Inject/replace elements in *any* vanilla or modded menu via SWF + an event API | Add a devotion line to the vanilla Magic/Active-Effects menu, or a glyph to the shrine activation prompt | Patches the **vanilla** UI the player already uses (very diegetic-adjacent) instead of a separate canvas. Needs SWF authoring. |
| **Wheeler / radial-menu pattern** ([Wheeler](https://www.nexusmods.com/skyrimspecialedition/mods/97345), [LamasTinyHUD lineage]) | ImGui radial action wheel; co-save data, no script bloat | A "devotional acts" radial: pray / offer / meditate / dedicate-kill, per active deity | Different *interaction model* from Prisma — an input surface, not a display. Could replace fiddly hotkeys for rites. |
| ~~**Custom Skills Framework**~~ **(DROPPED — see decision box at top)** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/41780)) | Adds real perk-tree "skill" menus with a Papyrus API | ~~Devotion as a levelled skill tree~~ — **rejected**: adds player-facing progression cost and crosses the experience line. | Kept in the table only so the rejection is on the record. Devotion is reflected, not spent. |

**Read on Tier A (post-decision):** with the skill tree rejected, the only Tier-A item still worth carrying is
**iWant Widgets** (a far lighter way to get an *optional* persistent HUD meter without our own DLL — and even
that risks the "second hunger meter" feeling, so it stays opt-in; see the build-out's soft Tier C7). The ImGui
tools are best confined to **debug UX**, honoring rule #3 of the lessons doc ("Debug is not UX"). The real
energy goes to Tier B below.

---

## 3. Catalog — Tier B: diegetic, in-world surfaces (the real opportunity)

This is the top-left quadrant. None of these is a menu. Each one makes the gods *part of the world* instead of
part of the HUD. Most are **cheap**, most are **non-voiced** (so they sit inside the §21.3 voiced-content
non-goal), and most reuse hooks PDV already fires.

### B1. The medallion / token speaks for itself — **Description Framework**
- **Tool:** [Description Framework](https://www.nexusmods.com/skyrimspecialedition/mods/105799) + po3's
  `GetDescription` in [Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854). Supports
  runtime, Papyrus-set descriptions on MISC/BOOK/SPEL/active-effects/etc.
- **PDV fit:** PDV already plans a portable **BOOK "ritual focus"** per exile race
  (`PDV_PortableDevotionalToken_BuildSpec.md` §2). A Description-Framework layer turns that token — and a
  single carried **devotional medallion** — into a **living status surface**: hover it and the description
  reads *"Kyne's favor: Devoted. She has not heard you in three days."* The medallion idea in the Prisma
  handoff (`handoff/PrismaMedallionRoster_DesignHandoff.md`) gets a **zero-menu** expression: the *item* is
  the panel.
- **Why it's strong:** diegetic, persistent, pull-on-demand, no notification spam, and it reuses the
  StorageUtil piety PDV already owns. This is the single best "instrument-without-Prisma" play.

### B2. A self-writing devotional journal — **Dynamic Book Framework / Note Crafting**
- **Tools:** [Dynamic Book Framework](https://www.nexusmods.com/skyrimspecialedition/mods/152364) (SKSE; books
  load text from external files; Papyrus + C++ API to append entries to *any* journal at runtime);
  [Note Crafting](https://www.nexusmods.com/skyrimspecialedition/mods/119569) ships `NoteCrafting.psc` as a
  Papyrus modder resource for creating/editing notes in script.
- **PDV fit:** A carried **"Book of Days"** the gods/ancestors *write into*. On each transition the audit
  flags, append a dated line in the deity's voice ("*Tirdas, 17th of Last Seed — the Hist drank deep of you
  today.*"). The player reads it like any in-world book; no toast required. This turns the **neglect cadence**
  problem (audit C3) into a *legible history* instead of a nagging meter.
- **Why it's strong:** it converts "the mod computes things it never tells you" (the audit's headline) into a
  permanent, browsable, diegetic record — and it's the natural home for the per-race "texture" copy that's
  already authored but has nowhere quiet to land.

### B3. Auras & marks of divine presence — **effect shaders / art objects / light**
- **Tools:** po3 [Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854) functions to
  apply/remove effect shaders, attach lights, and play art objects on a reference; vanilla `EffectShader.Play`
  / `ObjectReference` art-object hooks; [Enchantment Art Extender] for extra art slots. CK records: ARTO
  (art object), EFSH (effect shader), RFCT (visual effect).
- **PDV fit:** A brief **shader pulse** on the player at a tier-up ("the pantheon notices") or a Champion
  beat; a **cold desaturating shader** for a curse onset; a faint **standing light** at a private-shrine
  rite. The curse-*cure* beat the audit calls universally silent (C2) becomes a visible *cleansing* shimmer.
- **Why it's strong:** wordless, tonal, unmistakably "something divine happened," and entirely non-voiced.
  Pairs with B6 (sound). Caution: keep it **rare and short** — shaders that linger read as a bug.

### B4. The screen itself reacts — **imagespace modifiers (ISM)**
- **Tools:** ImageSpaceModifier (IMAD) records applied via `ImageSpaceModifier.Apply/ApplyCrossFade`, or po3
  helpers. ([technique discussion](https://forums.nexusmods.com/topic/8276748-le-how-to-apply-and-remove-image-space-modifiers/))
- **PDV fit:** a momentary **warm gold bloom** when a god first reaches out (patron emergence — audit's silent
  moment #2); a **grey vignette** as neglect deepens; a **blood-dim** on a taboo breach. One- to two-second
  cross-fades, not persistent grading.
- **Why it's strong:** the most "felt," least "read" surface there is. Communicates *mood* of a divine state
  change with zero text and zero dependency beyond base CK records.

### B5. Marks of devotion on the body — **RaceMenu / NiOverride overlays**
- **Tools:** RaceMenu's `NiOverride.AddNodeOverrideString/Int` to apply body/face overlay textures and tint at
  runtime ([overlay how-to](http://winkingskeever.com/how-to-create-new-body-paints-and-overlays-for-racemenu-part-2/)).
- **PDV fit:** a **visible curse scar** (vampire/werewolf onset), a faint **devotion tattoo/warpaint** that
  appears at Champion tier, an **ancestor-ash mark** for high Dunmer ancestor depth. The curse *state* PDV
  already tracks becomes something the player and (later, via SPID) NPCs can *see*.
- **Trade:** RaceMenu is a heavy, near-ubiquitous dependency but **already present in most load orders**; soft
  dependency (apply only if NiOverride is present) keeps trust intact. Art cost: overlay textures.

### B6. Favor / disfavor you can hear — **sound & music**
- **Tools:** custom SNDR/SOUN records via `Sound.Play`;
  [Sound Record Distributor](https://www.nexusmods.com/skyrimspecialedition/mods/77815);
  [Music Type Distributor]; MUSC/MUST records ([UESP MUSC](https://en.m.uesp.net/wiki/Skyrim_Mod:Mod_File_Format/MUSC));
  [Combat Music Fix - Papyrus](https://www.nexusmods.com/skyrimspecialedition/mods/78057) shows the
  formlist-driven music-swap pattern.
- **PDV fit:** a soft **chime** on favor noted / a **hollow tone** on disfavor (replaces or accompanies the
  silent piety changes the policy table marks "Silent by default"); a **reverent music type** that swells when
  praying at a shrine of your patron, or a **dissonant** bed during a curse. Khajiit's full-moon nights could
  carry a distinct musical tell — surfacing the moon cycle the audit says is currently invisible.
- **Why it's strong:** audio is the lowest-friction "quiet" feedback channel — it never occludes the screen
  and never demands a dismiss.

### B7. Devotion you perform — **prayer / offering animations**
- **Tools:** [OAR](https://www.nexusmods.com/skyrimspecialedition/mods/) (Open Animation Replacer) /
  [Divines Prayer Animations](https://www.nexusmods.com/skyrimspecialedition/mods/109175);
  [Immersive Interactions — Animated Actions](https://www.nexusmods.com/skyrimspecialedition/mods/47670)
  (kneel/offer at shrines on Shift+E, with an FLM/Pilgrim patch);
  [Dynamic Animation Casting] for rite gestures.
- **PDV fit:** the BOOK "ritual focus" rites (`PDV_PortableDevotionalToken_BuildSpec.md`) gain an actual
  **kneel/offer animation** instead of a silent book-read; Khajiit moon rites, Dunmer ash-shrine prayers, Orc
  forge dedications each get a posture. Devotion becomes something you *do*, not a menu you poke — directly
  answering the lessons doc's rule #4 ("roleplay friction should open a decision," not be a menu chore).
- **Trade:** soft dependency on an animation framework; reference how **Pilgrim** pairs prayer mechanics with
  Divines Prayer Animations ([Pilgrim](https://www.nexusmods.com/skyrimspecialedition/mods/54099)).

### B8. The world recognizes you — **SPID-distributed reactions** (non-voiced now, voiced/AI later)
- **Tools:** [SPID](https://www.nexusmods.com/skyrimspecialedition/mods/36869) to attach keywords / factions /
  packages to NPCs by condition (e.g. "priest of Kyne + player is Kyne Champion"); this drives
  **disposition/stance** effects *now* (non-voiced, V1-legal) and **voiced dialogue** later.
- **PDV fit:** priests of your patron warm to you (faction/disposition), zealots of a rival cool — the
  §21.3-legal "non-voiced equivalent (notification, MessageBox, **disposition/stance effect**)." SPID is how
  you target *the right NPCs* without editing their records.
- **V2/optional ceiling — AI recognition:** [Mantella](https://www.nexusmods.com/skyrimspecialedition/mods/98631)
  lets NPCs react to game state in natural language ("Mantella handles conversation, Papyrus handles state").
  A Mantella context-bridge could let a priest *actually comment* on your devotion. This is **squarely past the
  §21.3 voiced-content non-goal** and a heavy optional dep — flag as a far-future, opt-in integration, not a
  core surface. Same caution the github webhook/external-data note implies: it's an external service.

### B9. Quiet ambiance — weather & light
- **Tools:** po3 Papyrus Extender weather functions; WTHR/region records.
- **PDV fit:** Kyne worship that subtly favors clear skies after a clean hunt; an oppressive sky during deep
  neglect. Use *sparingly* — weather is high-visibility and easy to overdo. Listed for completeness; low
  priority.

---

## 4. Catalog — Tier C: make the surfaces we ALREADY use feel good (notification discipline)

PDV already emits MESG/HUD notifications and MessageBoxes (`PDV_ContentDestinationMatrix.md`). The lessons
doc's loudest complaint is **notification spam**. These tools are the discipline layer:

- **[Immersive HUD - iHUD](https://www.nexusmods.com/skyrimspecialedition/mods/12440) /
  [ImmersiveHUD SKSE](https://www.nexusmods.com/skyrimspecialedition/mods/166799)** — fade HUD when not
  needed; PDV should *cooperate* with these, not fight them (don't force-show a meter iHUD is hiding).
- **[Configurable Notification Messages](https://www.nexusmods.com/skyrimspecialedition/mods/65573)** — proves
  players want fewer, slower corner messages; PDV's notification policy (the draft table in
  `immersive-ux-lessons.md`) should be MCM-tunable in the same spirit.
- **Design takeaway, not a dependency:** the cheapest UX win is *restraint* — route routine piety to silence
  + the journal (B2) + sound (B6), and reserve a notification for genuine transitions.

---

## 5. Master tooling matrix

| Idea | Surface quadrant | Primary tool(s) | Dep weight | Build skill | Voiced-content §21.3 | PDV moment it serves |
|---|---|---|---|---|---|---|
| Living medallion/token text | diegetic / pull | Description Framework + po3 PE | light (soft) | Papyrus + copy | ✅ clear | status check, neglect legibility |
| Self-writing journal | diegetic / pull | Dynamic Book Framework / Note Crafting | light–med | Papyrus + copy | ✅ clear | transition history, neglect cadence (C3) |
| Aura / shader pulse | diegetic / push | po3 PE effect shaders, ARTO/EFSH | light | CK + Papyrus + art | ✅ clear | tier-up, Champion, curse onset **and cure** (C2) |
| Imagespace tint | diegetic / push | IMAD + Apply | none (base) | CK + Papyrus | ✅ clear | patron emergence, neglect mood, taboo |
| Body mark of devotion/curse | diegetic / persistent | RaceMenu NiOverride | med (common) | Papyrus + texture art | ✅ clear | curse states, Champion identity |
| Favor/disfavor sound cue | diegetic / push | SNDR + Sound.Play / SRD | light | CK + audio | ✅ clear | routine piety (replace silence), rites |
| Devotional music type | diegetic / ambient | MUSC/MUST, Music Type Distributor | light | CK + audio | ✅ clear | temple prayer, curse bed, moon nights |
| Prayer/offer animation | diegetic / perform | OAR / Immersive Interactions | med (soft) | anim integration | ✅ clear | every rite; BOOK ritual focus |
| NPC stance recognition | diegetic / world | SPID (factions/keywords) | light | SPID config | ✅ (stance only) | patron priests warm, rivals cool |
| AI recognition dialogue | diegetic / world | Mantella + context bridge | **heavy/opt** | C++/Papyrus bridge | ❌ V2+ / opt-in | spoken recognition (far future) |
| Persistent HUD meter | abstract / push | iWant Widgets NG | light (no own DLL) | Papyrus | ✅ clear | optional always-on piety/neglect |
| Curse "drain" bar | abstract / push | TrueHUD special-bar API | med | C++/Papyrus | ✅ clear | transient curse/Champion timers |
| Devotion skill tree | abstract / pull | Custom Skills Framework | med–heavy | framework + perk authoring | ✅ clear | **structural alt to Prisma panel** |
| Vanilla-menu injection | abstract-diegetic | Infinity UI | med | SWF authoring | ✅ clear | devotion line in Active Effects/shrine prompt |
| Radial rite menu | input | Wheeler pattern | med | ImGui/config | ✅ clear | pray/offer/meditate input |
| Dev/debug inspector | abstract / debug | SKSE Menu Framework / ImGui | light | C++ | n/a (debug) | replace console-debug UX |

---

## 6. The recommendation — a layered portfolio, not a swap

**Keep Prisma for what only Prisma does** — the per-race **instruments** and the glyph roster. That's its moat
and it's already specced and partly built (`handoff/PrismaInstruments_*`). Don't throw away a moat to chase
"alternatives" for their own sake.

**Then build the diegetic quadrant out from under it,** in three tiers of ambition:

### Tier 1 — Quiet baseline (cheap, non-voiced, high feel, low dep)
The five silent transitions from the audit, expressed *diegetically* instead of as five more toasts:
1. **Living medallion/token text** (Description Framework) — the always-available status surface.
2. **Imagespace + short shader + sound** for the five transition moments (tier, patron emergence, curse
   onset/cure, sect/mode switch, neglect onset) — tonal, wordless, rare.
3. **Devotional music type** at patron-shrine prayer.

These three alone move PDV from "computes things it never tells you" to "the world quietly responds," using
mostly base CK records + po3 PE + one light framework. This is the highest ROI in the whole doc.

### Tier 2 — Earned depth (still non-voiced)
4. **Self-writing devotional journal** (Dynamic Book Framework) — the legible history that fixes neglect
   cadence and houses authored race "texture."
5. **Prayer/offering animations** (OAR / Immersive Interactions) on the BOOK ritual-focus rites.
6. **Body marks** (RaceMenu) for curse states and Champion identity — soft-dependency.
7. **SPID stance recognition** — priests/rivals react via disposition (V1-legal, non-voiced).

### Tier 3 — Structural bets (bigger, revisit at V2)
8. ~~Custom Skills Framework "Devotion" tree~~ — **DROPPED** (adds player progression cost; crosses the
   experience line). Devotion is reflected, never levelled.
9. **iWant Widgets** persistent meter — *only* if playtesting shows players want an always-on piety read
   without opening anything; opt-in, off by default (risks the "second hunger meter" feeling).
10. **Mantella recognition bridge** — explicitly opt-in, V2+, past the voiced-content non-goal; the ceiling
    of "the world knows you," not a core surface.

### Where each tier honors the repo's own laws
- **"Quiet immersion wins" / "default to diegetic"** → the entire Tier-1/2 push into the top-left quadrant.
- **"Never a second hunger meter"** → no new persistent meter is *required*; B-surfaces are event-driven, the
  meter (iWant) is optional and tucked behind iHUD cooperation.
- **"Compatibility is trust"** → prefer base CK records (imagespace, sound, music, shaders via po3 which is
  near-ubiquitous) over new hard DLL deps; make RaceMenu/animation/Mantella **soft** dependencies; keep our
  one authored native (the Prisma bridge) as the only DLL PDV ships.
- **§21.3 voiced-content non-goal** → everything in Tier 1 and 2 is non-voiced and legal for 1.0; only SPID
  *voiced* lines and Mantella are deferred, consistent with the existing V1/V2 split.
- **Event-driven hygiene (no polling)** → all B-surfaces fire on the EventBus transitions PDV already detects;
  the only per-frame concern is a live widget/instrument, which stays native-driven.

---

## 7. Open questions for you (decisions this doc can't make)

1. ~~Prisma panel vs. a devotion skill tree~~ — **resolved:** no skill tree. The Prisma panel stays as the
   deep pull surface; the diegetic medallion (B1) becomes the *quick* read. (See remaining fork in #3.)
2. **How hard a stance on dependencies?** — **partly resolved:** soft deps are accepted and PDV bundles its
   own assets (animations as a PDV OAR submod; RaceMenu is a baseline given). Open sub-question: confirm the
   *hard* dependency list stays minimal (ideally just SKSE + the existing Prisma bridge + OAR engine), with
   everything else soft-guarded.
3. **Does the medallion concept move off Prisma?** The Description-Framework medallion (B1) and the Prisma
   medallion roster (`handoff/PrismaMedallionRoster_DesignHandoff.md`) are two answers to the same need. The
   build-out's working assumption is **they coexist** (MISC item = quick hover read, Prisma = deep panel) —
   confirm or collapse to one.

---

## Appendix — sources

Repo: `references/vanilla-gameplay/pdv-crosswalk/immersive-ux-lessons.md`,
`references/authoring/PDV_ImmersionAudit_MissedOpportunities.md`,
`references/authoring/PDV_PortableDevotionalToken_BuildSpec.md`,
`race-sheets/PDV_ContentDestinationMatrix.md`, `native/DevotionPrismaBridge/README.md`,
`handoff/PrismaInstruments_VisualSpec.md`, `handoff/PrismaMedallionRoster_DesignHandoff.md`,
`PDV_Architecture_v3.md` §16.7 / §21.3.

Web (selected):
- Prisma UI — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/148718) · [docs](https://www.prismaui.dev/getting-started/introduction/) · [github](https://github.com/PrismaUI-SKSE)
- SKSE Menu Framework / ImGui — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/120352) · [SDK](https://github.com/Thiago099/SKSE-Menu-Framework-SDK)
- iWant Widgets — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/36457) · [NG](https://www.nexusmods.com/skyrimspecialedition/mods/96410) · SkyUI [source](https://github.com/schlangster/skyui)
- TrueHUD — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/62775)
- Infinity UI — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/74483)
- Wheeler — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/97345)
- Custom Skills Framework — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/41780) · [menu](https://www.nexusmods.com/skyrimspecialedition/mods/62423) · [source](https://papyrus.bellcube.dev/skyrimse/source/custom-skills/)
- Description Framework — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/105799)
- Dynamic Book Framework — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/152364) · Note Crafting — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/119569)
- powerofthree's Papyrus Extender — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/22854) · [github](https://github.com/powerof3/PapyrusExtenderSSE)
- SPID — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/36869) · [github](https://github.com/powerof3/Spell-Perk-Item-Distributor)
- RaceMenu / NiOverride overlays — [how-to](http://winkingskeever.com/how-to-create-new-body-paints-and-overlays-for-racemenu-part-2/)
- Sound Record Distributor — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/77815) · MUSC [UESP](https://en.m.uesp.net/wiki/Skyrim_Mod:Mod_File_Format/MUSC) · Combat Music Fix [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/78057)
- Prayer animation / Immersive Interactions — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/47670) · Divines Prayer Animations [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/109175) · Pilgrim [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/54099)
- Mantella — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/98631) · [docs](https://art-from-the-machine.github.io/Mantella/)
- Wintersun (religion-feel reference) — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/22506)
- iHUD — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/12440) · Configurable Notification Messages — [nexus](https://www.nexusmods.com/skyrimspecialedition/mods/65573)
- SKSE frameworks master list — [github (GroundAura)](https://github.com/GroundAura/SKSE-Frameworks)
