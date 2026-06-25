# PDV In-Game Run-Sheet -- Altmer (V1)

Status: V1 (Unit D Prisma live `5e9e502`; the Thalmor-alignment band beat, the crisis-state
toast, and the formal-offer accept/refuse surfaces are the NEW build items this pass -- they were
invisible before Unit D). Created 2026-06-25.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as an Altmer (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 3
   set PDV_GLO_DebugLevel to 2
   ```
   (`3` = Altmer. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 3`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. Daedric shrine prayers + quest reactions use the ARR
  variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects) the **Auri-El dawn foundation** reward is granted after
  race-confirm, and that the Altmer crisis-state and ThalmorAlignment tracks (`PDV_AltmerCrisisTrack`,
  `PDV_ThalmorAlignmentTrack`) exist. No new mesh/potion item this race -- the foundation is the boon.
- **See:** the Auri-El foundation effect is present in Active Effects; no other Altmer hook needs a new mesh.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> Force Auri-El piety to **85**. Then open **Survey Devotion** (in the panel / MCM status).
- **See:** the Altmer lines read like narration -- Auri-El as the **foundation**, the **Thalmor-alignment**
  stance (uncommitted / private or open heterodoxy / public orthodoxy / Thalmor-devout), a **crisis** sentence
  only when a crisis is active, last favor, and the Aldmeri **heritage** layer. No raw numbers/enum codes leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With Auri-El at Champion, open the **magic menu -> Active Effects**.
- **See:** the Auri-El foundation + at most **one secondary focus** + **one active favor** present. Broad
  worship **caps at Tier 2 (Faithful)** -- no Champion-tier broad stack. No duplicate/rogue auras, nothing
  bleeding from another race/mode. ThalmorAlignment is NOT a third boon engine (it gates/pressures, it does not buff).
- **Record:** ___

### Slot 4a -- formal OFFER accept (new Prisma beat)  [Tester] [R]+[M]
- **Do:** drive Auri-El (or Magnus / Xarxes) high enough to trigger the **formal commitment offer** (MCM Debug can
  force the pending offer). When the offer pops, choose **accept** ("name them your focus").
- **See:** an **offer pop-up** naming the patron; on accept a **toast** -- *"You name {patron} your focus."* -- and a
  **pinned Book of Days entry** -- *"The foundation narrows to a single disciplined road. You named {patron} your
  focus."* The patron becomes your active focus.
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 4b -- formal OFFER refuse (new Prisma beat)  [Tester] [R]+[M]
- **Do:** on a fresh offer (fresh save or re-trigger), choose **refuse** (the permanent "keep to the foundation alone" door-closing pick).
- **See:** a **toast** -- *"You keep to the foundation."* -- and a **pinned Book of Days entry** -- *"The foundation
  stands as it was. You kept to it alone, and {patron} will not ask again."* Refuse is permanent -- that patron
  will not offer again (re-test on a fresh save).
- **Record:** ___

### Slot 4c -- Thalmor-alignment band beat (the headline new beat)  [Tester] [R]+[M]
- **Do:** push the ThalmorAlignment track across a **committed band boundary** -- e.g. enforce orthodoxy / complete a
  Thalmor mission to climb toward **Public Orthodoxy / Thalmor-Devout**, or kill a Thalmor agent / consort with Daedra
  to fall toward **Private / Open Heterodoxy**. MCM Debug can drive the alignment action. Cross a band, then let the
  **committed band lock in**.
- **See:** on the **committed band change** a **toast** -- *"The Thalmor question turns in you: {band}."* -- and a
  **Book of Days entry** -- *"Your soul records where you stand in the Thalmor question: {band}."* Bands:
  **Open Heterodoxy** (<= -76) / **Private Heterodoxy** / **Uncommitted** / **Public Orthodoxy** / **Thalmor-Devout** (>= +76).
- **This is the headline regression: before Unit D the alignment axis was invisible to BOTH surfaces.** If you cross a
  committed band and get neither toast nor Book of Days line -> FAIL.
- **Record:** ___

### Slot 4d -- crisis-state toast (new Prisma beat)  [Tester] [R]+[M]
- **Do:** apply Lorkhan / Dragonborn-identity pressure to enter a crisis (MCM Debug -> seed Lorkhan pressure or
  Dragonborn crisis). Crisis labels: **Dissonant / Questioning / Reasserting / Scarred resolved** (None = no crisis).
- **See:** a **toast** on the transition INTO a crisis state -- *"The old line turns: {crisis}."* The crisis is also
  recorded in the **Book of Days** at the next dawn snapshot and named in Survey.
- **Note:** the toast fires only on entering/changing a crisis state. **Clearing back to None is silent** (no toast) -- that is correct, not a FAIL.
- **Record:** ___

### Slot 4e -- broad caps at Tier 2  [Tester] [R]+[M]
- **Do:** worship broadly (no single focus) and drive overall devotion up via Debug. Open Survey + Active Effects.
- **See:** broad worship **tops out at Tier 2 (Faithful)** -- it does **not** reach Devoted/Champion without a focused
  patron. Naming a focus (Slot 4a) is what unlocks the higher tiers. Pure flavor here -- watch that the broad cap holds.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 0` (Nord), then fire an Altmer alignment/crisis seed/act. Reset with
  `set PDV_GLO_OriginRace to 3` after.
- **See:** **nothing Altmer moves** -- no crisis-state, no ThalmorAlignment, no markers. A non-Altmer can't drive Altmer state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as an Altmer, do ordinary things that are NOT the coded hooks: ordinary travel, generic spellcasting, generic
  combat, generic helping, generic College membership, generic anti-Thalmor violence, repeated Dragonborn-identity bragging.
- **See:** **none of these score** crisis / ThalmorAlignment / piety (only the real coded acts -- dawn steadiness,
  Lorkhan pressure, orthodox costly enforcement, Dragonborn declaration -- do).
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does **naming a focus** (offer accept) read as the foundation narrowing to one disciplined
  road, and does **refuse** read as a door deliberately closed? Does the **Thalmor-alignment band** read as where you stand
  in the Thalmor question rather than a number? Does the **crisis-state toast** land as an identity reorientation, not a
  debuff counter? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Altmer beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force Auri-El piety + Run Dawn |
| Auri-El substrate / heritage act | Y | N | **Y (driver)** | sleep dreams / magic milestones (organic) |
| offer.accept | **Y** | **Y (pinned)** | N | formal offer -> accept |
| offer.refuse | **Y** | **Y (pinned)** | N | formal offer -> refuse |
| Thalmor-alignment band | **Y** | **Y** | N | cross a committed alignment band |
| crisis-state | **Y** (into crisis; silent on clear-to-None) | Y (next dawn) | N | Lorkhan / Dragonborn pressure |
| broad cap at Tier 2 | N | N | N | broad worship, no focus |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **The Thalmor-alignment band + crisis-state + offer accept/refuse are the NEW Unit-D surfaces.** They were invisible
  before this pass -- if any of them fire the underlying state change but produce NO toast/Book-of-Days line, FAIL it
  (that is exactly the regression being closed).
- **The alignment beat fires on the COMMITTED band, not the raw value.** A single signal can move the raw track in the log
  but not yet flip the committed journal band -- prove the band change by the surfaced band label, not the raw number.
- **Crisis-state clears to None silently.** A toast only fires entering/changing a crisis -- no toast on clear is correct.
- **Refuse is permanent.** That patron will not offer again -- re-test offers on a fresh save.
- **Broad caps at Tier 2.** Reaching Devoted/Champion needs a named focus, not more broad worship.
- **ThalmorAlignment is not a boon track.** It modifies access/pressure; do not expect a third steady buff from it.
- **Crisis/alignment Book-of-Days lines land at the NEXT dawn snapshot** for state-diff entries (the toast is immediate).
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | Auri-El foundation + crisis/alignment tracks exist | | |
| 2 Survey | foundation/alignment/crisis/heritage legible | | |
| 3 stack | foundation + 1 focus + 1 favor; broad caps T2; align != boon | | |
| 4a offer accept | toast + pinned BoD, non-empty; focus set | | |
| 4b offer refuse | toast + pinned BoD, non-empty; permanent door closed | | |
| 4c Thalmor-alignment band | committed-band toast + BoD (the headline beat) | | |
| 4d crisis-state | toast into crisis; silent on clear; BoD next dawn | | |
| 4e broad cap | broad worship stops at Tier 2 | | |
| 5 wrong-origin | Nord origin: zero Altmer movement | | |
| 6 generic silence | travel/spell/combat/anti-Thalmor do not score | | |
| 7 felt | focus/refuse + alignment + crisis read as earned | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Altmer `pass` until every row is filled.
