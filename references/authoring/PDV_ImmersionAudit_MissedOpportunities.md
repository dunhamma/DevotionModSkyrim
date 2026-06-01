# PDV Immersion Audit — Missed Opportunities (V1) & V2 Notes

**Scope:** End-to-end immersion pass across all ten races plus the shared/Daedric systems,
tracing each race's arc (start → mid-game → curse → neglect → endgame) against both the
narrative sheet (`Race_*.md`) and the locked implementation sheet (`PDV_RaceDesign_*.md`),
the Daedric/race content manifests, and the architecture.

**How to read this:** "V1 missed opportunity" = cheap, high-immersion, achievable with
existing hooks and the already-sanctioned **non-voiced text surface** (no new art, anim, or
voice — stays inside the §21.3 voiced-content non-goal). "V2" = bigger, may need custom
content/quests/voice. Items already in `references/authoring/PDV_V2_Backlog.md` are not
repeated here.

---

## 0. The headline finding

**One gap shows up independently in every race and in the shared-systems review: the mod
computes meaningful state transitions it never tells the player about.** The systems are
sound; they're just silent. The single highest-value, lowest-cost V1 investment is a
**consistent player-facing feedback layer** over moments the engine already detects:

1. **Tier reached** — no diegetic "you've reached Faithful/Devoted" beat for broad worship.
2. **Patron / emphasis emergence** — Khajiit's silent patron and Argonian's Sithis rise
   have *no* notification; the player "notices their blessings shifted" with nothing telling
   them why (`race-sheets/PDV_RaceDesign_Khajiit.md:206`, `PDV_RaceDesign_Argonian.md:139`).
3. **Curse onset _and cure_** — onset often speaks, but **cure is silent** across races even
   though the scar/status is tracked (`PDV_TargetEndStates_1.0.md` Phase-18 vampire rule).
4. **Sect / mode / tradition switch** — Redguard sect, Orc mode, Bosmer path switches are
   architectural but fire no acknowledgement (`PDV_RaceDesign_Redguard.md:47-48`,
   `PDV_RaceDesign_Orc.md:42-54`).
5. **Neglect onset** — rich neglect *texture* is authored per race, but with no defined
   firing cadence the player sees tiers slip without being told a god has gone quiet
   (shared-systems review; `PDV_Architecture_v3.md:1290-1300`).

All five reuse the existing notification slot types (narrator/god-voice MessageBox + HUD
notification already defined in `PDV_ContentDestinationMatrix.md`). Recommendation: treat
this as a single small V1 workstream — **"surface the transitions"** — rather than ten
race-specific tasks. It is the cheapest way to make the whole mod feel alive.

> Note: a few sub-agent flags were over-stated against current build state. The Bosmer
> forced-reckoning **logic** is already runtime-proven (Phase 9 Recommit/Renounce), and the
> Dunmer portable shrine is proven (Phase 10) — so those are *content/copy* gaps, not
> unbuilt features. Claims of "may be unimplemented" should be read as "confirm the authored
> text is attached," not "build the system."

---

## 1. Cross-cutting V1 opportunities (do once, benefits all races)

| # | Opportunity | Why it's cheap | Cite |
|---|-------------|----------------|------|
| C1 | **"Surface the transitions" notification pass** (the five moments above) | Reuses existing MESG/HUD slots; non-voiced | §0 |
| C2 | **Curse-cure recognition** MessageBox per curse type | Curse-state infra already fires on onset; add the exit beat | `PDV_TargetEndStates_1.0.md` Phase-18 rule |
| C3 | **Define neglect firing cadence**: fire once per tier-drop, not again until a tier is recovered | Pure rule + doc; prevents spam and silence both | `PDV_Architecture_v3.md:1290-1300` |
| C4 | **Hook-candidate column** on each race's contextual-favor table (1–3 vanilla quest/location/faction hooks per trigger) | Removes implementer guesswork; format already exists in `Devotion_Races_Overview.md` | shared-systems review |
| C5 | **Onboarding one-shot**: a single MCM/startup line explaining "gods notice your acts daily; reach Faithful to unlock a patron" | One popup | `PDV_Architecture_v3.md:16.1` |

---

## 2. Per-race highlights

Curated to the strongest items; full detail lives in the arc reviews this doc synthesizes.

### Nord
- **V1:** Tier-2 "the pantheon notices" beat; **vampire-cure purification rite** (parity with
  Breton/Imperial recovery — visit shrine / outdoor nights) so cure feels earned, not
  automatic (`PDV_RaceDesign_Nord.md:264-269`); audit Civil-War/Talos quest stages so
  *religious* defiance is tagged distinctly from generic Thalmor violence (`:142,152`).
- **V2:** Broad→patron "a god reaches out" moment; expand focused paths beyond Kyne; make
  Companions/Hircine a real theological fork like the Breton Druidic Trial.

### Imperial
- **V1:** Distinguish *quest-authored mercy* from *bounty-payment* in the Stendarr signal so
  the player sees which acts count (`:70-81`); **Talos-gate rejection notice** at high
  Concordat compliance so the player learns compliance *closed* a path (`:56-60,166`); decide
  & surface whether the Compliance lane is a **loss-path** (no Champion) or an alt-victory.
- **V2:** Concordat Standing as live encounters (Thalmor inspections / secret worshippers);
  Civil War wired to Akatosh/Talos consequence.

### Breton
- **V1:** **Make the three opaque numbers legible** — surface why Stendarr shrine restoration
  caps Integrity at 75 (penance framing), warn the player at the WitchcraftExposure
  point-of-no-return (~70/76), and define what happens to Green Way piety after the 13
  standing stones are exhausted (`:64-67,117-118,246-250`). These are *feel-bad surprises*
  purely from missing communication.
- **V2:** NPC-visible Integrity; exposure encounters; distinct per-tradition vampire recovery
  arcs. (The Druidic Trial is already the crown jewel — protect it.)

### Altmer
- **V1:** First-trigger **Lorkhan-penalty notification** naming the theology (the sheet
  already wants this via the "Obviousness rule", `:199-200`); werewolf-onset one-time line
  explaining why beast-form annihilates Apotheosis.
- **Design check (not just content):** confirm the Lorkhan Adjacency Penalty is actually
  *felt* in mid-game; if it's "lightly weighted" to the point of being trivial (`:128`), the
  signature Altmer mechanic becomes flavor-only. Worth a balance pass before lock.
- **V2:** Heterodox scholarship arc; Thalmor-alignment showdown.

### Bosmer
- **V1:** Path-choice flavor at setup so the four paths' *costs* are legible before a blind
  pick; **define the path-switch destination signals concretely** — currently under-specified
  ("path-coded signals") and game-able (`:34-36,233`). Map each to a concrete vanilla
  checkpoint. (Green Pact tagging #4 and the Y'ffre scene #5 are covered in
  `PDV_Bosmer_OldContract_ContentSpec.md`.)
- **V2:** Y'ffre communion scene; Living Story "story you add to" location; Baan Dar road hub.

### Dunmer
- **V1:** Make ancestor **Layer-1 silence perceptible** — ensure ancestor flavor fires on
  non-combat triggers (shrine, diaspora aid), or neglect is invisible to non-combat players
  (`:213` vs `:100-102`); curse-transition explanations (vampire opens Good Daedra / werewolf
  narrows — say *why*). Azura threshold flavor is content #6 in the ledger.
- **V2:** Grey Quarter questline; post-cure ancestor-restoration rite; Mephala hidden-network
  as a real system.

### Argonian
- **V1:** The **Hist sap** (now spec'd in `PDV_PortableDevotionalToken_BuildSpec.md`) is the
  fix for the biggest Argonian gap — without an active rite the Hist layer is purely passive
  water-proximity (`:51,192`); add the explicit **Hist-thinning notification** the sheet
  already calls for (`:193`); recognition beat at the Windhelm Assemblage.
- **V2:** Community sanctuary (parity with Orc self-made community); Sithis acknowledgement
  dialogue; multi-day vampire-cure Hist-restoration arc.

### Khajiit
- **V1:** **Patron-emergence notification** (the whole "silent emergence" design is invisible
  without it — `:56,206`); make the moon cycle *visible* (full-moon line on outdoor
  dawn/dusk/night) even on the 28-day fallback (`:46-48`); caravan-recognition and
  outdoor-vs-inn sleep flavor.
- **V2:** In-character "you walk Khenarthi's path" realization moment; phase-specific
  challenges; caravan-leadership arc.

### Orc
- **V1:** Forge-quality and stronghold-acceptance recognition beats; **oath-acceptance
  framing line** on accepting hard quests — primes the Malacath "keep your word" theme even
  before full oath-breaking detection ships (`:84,206,222`); mode-switch acknowledgement.
- **Design check:** oath-breaking detection is the hardest signal and currently speculative
  (`:222`); decide if 1.0 ships real detection or just the framing.
- **V2:** Full oath-breaking quest-abandonment tracking; werewolf-discipline proving arc;
  self-made-community unlocks.

### Redguard
- **V1:** Far Shores token (spec'd) is the active Tu'whacca surface; sect-switch and
  death-duty recognition flavor (Crown vs Ash'abah colored); confirm Ash'abah light social
  stigma is in or out (`:51,245`).
- **Gap worth a decision:** **Alkosh is under-developed** as a focused path despite being a
  major Redguard/dragon-order god — not integrated into the Champion tables (`:80-87`).
  Decide V1-light vs V2-full.
- **V2:** Vampire-cure-through-Tu'whacca arc; Ash'abah social-stigma dialogue pack; Alkosh
  Champion path; ancestor-veneration shrine.

---

## 3. Shared-system / Daedric design decisions to ratify (not pure content)

These are flagged because they affect consistency across races and are best resolved before
content lock:

- **Curse-access template asymmetry.** Hircine (werewolf) and Molag Bal (vampire) use
  different "is the path now open vs mandatory vs severance" framing per race, and the Orc
  Molag Bal response is missing. Ratify one consistent rule
  (`PDV_DaedricContent_Manifest.md:6.5,279-284`; `PDV_Architecture_v3.md` D-16).
- **Peryite / Namira commitment signals** are narrow and quest-anchored — verify 3+ non-gated
  signals actually exist so a committed player isn't stranded at endgame
  (`PDV_DaedricContent_Manifest.md:7.12-7.13`).
- **Sanguine / Sheogorath / Clavicus Vile** boon prose currently reads near-identical
  ("opens a door / success sideways"); distinct god-voice in the Champion entry is a cheap
  way to separate them — flagged V2 unless promoted.
- **Survey Devotion readouts** appear incomplete for Breton / Bosmer / Argonian — confirm
  each has rows matching its internal structure (traditions / paths / Hist-People-Void).

---

## 4. Consolidated V2 backlog candidates (record, don't build)

Beyond the per-race V2 notes above, recommend recording in `PDV_V2_Backlog.md`:
the Section-23 architectural deferrals not currently listed there (per-race ESP split,
JContainers per-Prince stigma history, SPID, custom-race support, cross-save patron memory,
string-table localization), and the Daedric boon-voice distinctness pass for the
indulgence-trio.
