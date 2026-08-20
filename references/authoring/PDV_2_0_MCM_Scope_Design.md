# PDV 2.0 -- MCM Cleanup / Revamp Scope (design pre-work)

Status: RATIFIED 2026-08-20 for implementation after Gate 1 runtime acceptance. The MCM build is a
single focused pass at the END of 2.0; the existing MCM remains the first human acceptance driver.
The full ST rewrite and the complete opt-in accessibility set are owner-approved. No MCM revamp
code lands until `tools/pdv_v3_runtime_acceptance.mjs --check --gate gate1` passes with fresh logs.

Grounding (all facts re-derived from the current tree this session):
`live-source/Scripts/Source/PDV_MCM.psc` (4320 lines), `PDV__ManagerQuest.psc`,
`native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/{index.html,styles.css,app.js}`,
`references/authoring/PDV_MCMPropertyWiring.manifest.json`,
`references/PDV_ExperienceMode_DesignReference.md`, `tools/skyui_compile_shim/SKI_ConfigBase.psc`,
`tools/pdv_prisma_ui_audit.mjs`, `PDV_Architecture_v3.md` Sec 16.

---

## 1. Committed by the rebuild (not up for debate)

These ride the module extraction and are fixed by the finish plan:

- **F1 debug rewire.** 51 direct `PDV_Manager.Debug*` MCM sites -> `PDV_Manager.DebugRuntime.Debug*`
  (the ~220 figure counts the register-dispatch path too). `RunDebugCommand` + its 4 scratch
  registers stay on the manager. See `PDV_2_0_DEBUG_ModuleBoundary_Design.md`.
- **F2 by-module debug reflow** (this doc, Sec 3/2).
- **F4 stale-FILL strip.** ~34 stale property FILLs / 198 "cannot be initialized" warnings.
- **Standing compile rule.** MCM must be recompiled AFTER the manager, or the Prisma PEX-freshness
  gate FAILs (`tools/pdv_prisma_ui_audit.mjs:165-183`, `verifyJournalBytecodeFreshness`). The MCM
  Book-of-Days hotkey calls `PDV_Manager.SendPrismaJournalPayload`, so its `.pex` must be >= both
  the manager source and pex. During 2.0 the manager churns constantly -> MCM compiles LAST, every
  batch that touches the journal path.

## 2. Information architecture

Today: shipped build = 2 tabs (`Player`, `Settings`); dev build = 6 (adds `Status` + 3 `Debug:` pages).
Both shipped pages are 100% `AddTextOption`/`AddHeaderOption`/`AddKeyMapOption` -- no native controls.

Target shipped IA: **4 tabs** -- `Player`, `Settings`, `Experience Mode`, `Accessibility`. Dev build
keeps the module-themed debug pages from F2. Inherit `PDV_Architecture_v3.md` Sec 16 principles
(thematic-first; numeric behind the dev toggle; MCM stays config/opening-support, not a daily
management surface). Sec 16 always framed a "later player-facing MCM pass" but never spec'd it --
this revamp defines it; there is no prior native-control or layout blueprint to inherit.

Current shipped-page content (restructure baseline):
- **Player**: readouts (Summary/Startup/Path/Mode/Patron/Standing/Curse/Favor/Neglect), actions
  (Survey, Export, Check/Repair stats, Prepare uninstall), Book-of-Days open + 2 keymaps, conditional
  Khajiit moon-path rows.
- **Settings**: Experience-mode toggle ("Current path"), presentation toggles (In-Game Effects,
  Notifications, Toast size), NPC-recognition toggles, dev-gated custom-race + survival + CC toggles.

## 3. Native-control migration (full ST rewrite)

Ruling: move from `AddTextOption`-as-toggle to native SkyUI controls with per-control ST callbacks,
retiring the ~180 `_oid` dispatch variables and the monolithic `OnOptionSelect` chain. Justified by
the deferred single end-phase pass (no concurrent manager churn), the wholesale revamp, and the
same-phase 10-race in-game test that catches runtime issues.

Shim work (`tools/skyui_compile_shim/SKI_ConfigBase.psc` currently declares only Header/Text/Empty/
Slider/KeyMap): add `AddToggleOption`, `AddMenuOption`, `AddColorOption`, `AddInputOption`; the
`Set{Toggle,Menu,Text,Color,Input}OptionValue` + `SetOptionFlags` setters; the menu/color dialog
helpers; and the `*ST` callback + `Add*ST` family if ST is adopted.

**Mandatory de-risk:** the real `SKI_ConfigBase.psc` is NOT in-tree (only the stub). Source the real
signatures from the installed SkyUI BSA before extending the shim -- signature drift compiles GREEN
against the stub but binds wrong / breaks at runtime. Do not hand-author from memory. The owner chose
the full ST rewrite; the hybrid path is not a time-pressure fallback. If a real SkyUI signature or
runtime-binding defect blocks ST, stop with the reproduced evidence instead of silently retaining
two dispatch paradigms.

## 4. Experience Mode page + records

Today: a single "Current path" toggle on Settings + a mirror readout on Player, backed by
`PDV_ModePresetRef` and StorageUtil `PDV.Mode`. The dedicated page + records were blocked only
because the retired `pdv_author` could not mint GLOB/QUST; **houseCARL mints both**, so it is
unblocked.

Build (per `PDV_ExperienceMode_DesignReference.md` Sec 5.4): a dedicated **Experience Mode** page
(`BuildModePage`: path toggle showing Pilgrim's/Wayfarer's + a "what changes" read-only block --
gain rate, ceilings, neglect decay, everyday-work), the `OnOptionSelect_Mode` confirm flow, and a
Status "current path" row. Mint `PDV_GLO_Mode` (GLOB, int 0/1 CK-condition mirror) and
`PDV_ModePreset` (QUST); keep StorageUtil `PDV.Mode` as the source of truth; wire the manifest's
`PDV_ModePresetRef` onto MCM/manager/ActionRouter.

**Future-proofing note (owner):** keep the non-survival / non-Requiem experience smooth -- Wayfarer
is the gentler path for players without Requiem's regen zeroing; leave room for the deferred
Wayfarer-V2 cheap-signal taxonomy (currently narrowed to the Akatosh level-up route).

## 5. Accessibility

The view is already a11y-aware (redundant color+text+shape encoding, `prefers-reduced-motion`,
`.sr-only`, ARIA). This closes modest gaps, gated by an **aesthetic test**: a change is ALWAYS-ON
only if it is a strict clarity win that fits the existing visual language; anything that trades
aesthetics is OPT-IN so the default look is untouched.

**Always-on (no aesthetic cost):**
- Toast **valence glyph** -- a small directional mark / one-word tag on good/warning toasts, matching
  the dashboard driver-row's existing "carried four ways (glyph, side, sign, colour)" language. Today
  toast valence is border-color only (`styles.css:1367-1373`, `app.js:2283`).
- Weekly sparkline **`.sr-only` text + keep the tooltip** -- screen-reader values with ZERO visual
  change (today the spark is `aria-hidden`, value only in `title=`, `app.js:2138-2157`).

**Opt-in controls (dedicated Accessibility page, all owner-approved):**
- **Reduce motion** -> body class duplicating `styles.css:1624` (today only the OS query drives it; a
  CEF overlay may not inherit the OS setting).
- **Font scale** -> root/`rem` control covering panel + Book of Days (today only toasts have "Large");
  values 90%, 100%, 110%, 120%, 130%, and 140%, default 100%.
- **High-contrast / colorblind palette** -> override the `:root` CSS variables (`styles.css:1-19`,
  Book-of-Days block `:1659-1665`) under a body class -- theming is already variable-based. One menu
  exposes Default, High Contrast, and Colorblind Safe; Default preserves the current view exactly.
- Aesthetic-cost items (VISIBLE sparkline numbers, stronger contrast, larger glyph strokes) surface
  ONLY under these modes, never on the default view.

**Conditional:** D1 audio stings / screen tint (`PDV_DiegeticDirector.psc`) lack a guaranteed text
caption; only relevant if D1 ships on (off by default). If enabled, each `Dispatch` must emit a
paired toast/Book-of-Days line.

**Mechanics:** any view edit must bump BOTH cache keys (`index.html:9` and `:236`). The MCM toggles
write StorageUtil/manager state the view reads as a body class. Any new static MCM field that can
equal "None" needs the explicit-phrase mapping already used at `PDV__ManagerQuest.psc:9099-9106`
(the Anvil font blanks a bare "None").

## 6. Localization (translation support)

Externalize MCM labels to `$`-keys + ship `Interface/Translations/Devotion_ENGLISH.txt`, so a
translator drops in `Devotion_<LANG>.txt` with no code edits. Done DURING the revamp (cheaper than a
second pass). Convert every `AddXOption` literal + the label helpers (`OnOffLabel`, `ToastSizeLabel`,
`GetExperienceModeLabel`, ...). Source stays ASCII (`PDV_Architecture_v3.md:544`). The ~122 existing
`$OK`/`$Yes`/`$No` are SkyUI stock strings -- leave them.

## 7. Hygiene

- **Property-wiring overlay** (`PDV_MCMPropertyWiring.manifest.json`) fills only 7 of MCM's 16
  bindable properties -- regenerate to the full post-extraction set (add the `DebugRuntime` path,
  cover `EventBus`/`CurseState`/`ModePreset`/`QuestReactionRuntime` + the 5 FormLists). Converges
  with F4's stale-FILL strip.
- **Stale Diegetic D1 help text** (`PDV_MCM.psc:507`) says "Default off" but ships ON -- fix during
  the reflow (dev page, low urgency).
- **Startup-row line** appears already fixed in V3Dev (`GetStartupMcmLine` returns "Set: ..." post-
  confirm) -- verify only.

## 8. Sequencing and deferrals

Build order: Gate 1 runtime acceptance on the existing MCM, then one end-of-2.0 MCM pass on the same
feature branch; MCM compiled last. Gate 2 and the final critical regression must pass before PR #82
can merge. Out of scope / deferred: MCM verbosity preset (Silent/Transitions/Verbose), per-axis
difficulty sliders (permanently out), a broader daily-management player surface.

## 9. Locked control order

The Accessibility page order is: explanatory header, Reduce Motion, Font Scale, Palette, then a
read-only note that defaults preserve the existing presentation. Stronger contrast and larger glyph
strokes appear only inside High Contrast or Colorblind Safe; they do not alter Default. The full ST
rewrite is required.
