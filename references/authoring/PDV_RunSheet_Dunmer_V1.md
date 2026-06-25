# PDV In-Game Run-Sheet -- Dunmer (V1)

Status: V1 (Unit D Prisma live `5e9e502`; commitment-offer accept/refuse + ancestor-substrate Ledger
driver = NEW Prisma this pass). Created 2026-06-25. Refreshes `PDV_RunSheet_Dunmer_BetaFeel.md` to V1.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, the live `PDV__ManagerQuest.psc` Dunmer + ancestor functions.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as a Dunmer (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 5
   set PDV_GLO_DebugLevel to 2
   ```
   (`5` = Dunmer. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug pages**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options** and unlock
   the two debug pages (`Debug: State & Rewards`, `Debug: Daedric & Curse`). Every "seed" below is a labelled
   control there -- NOT a console `cqf`.
5. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 5`, DebugLevel, the MCM Debug pages) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so the home-prayer
  Health pulse must be proven *here* -- watch the HP bar actually move. The Good-Daedra (Azura / Boethiah /
  Mephala) shrine + book reactions use the ARR variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / inventory) the **ancestral urn** exists as a reusable **BOOK token**
  (`PDV_DunmerAncestralUrn`) and is in your inventory after race-confirm. It is the portable shrine -- you
  carry the infrastructure in exile; reading it prays. No placed worldspace tomb / mesh is required.
- **See:** the urn book is in inventory; no Dunmer hook needs a new mesh.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> `Dunmer ancestor prayer` x2-3 and Force Piety on a Good Daedra (Azura) to **85**. Then
  open **Survey Devotion** (in the panel / MCM status).
- **See:** the Dunmer lines read like narration -- the **ancestor-layer** depth ("the ancestors answer
  readily / steady / are beginning to answer / are quiet"), the **active Reclamation focus** (Azura /
  Boethiah / Mephala, or "the three Good Daedra answer together" when broad), exile/portable burden, and a
  **curse posture** line only when cursed. No raw numbers / route IDs / enum codes leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With a Good Daedra at Champion, open the **magic menu -> Active Effects**.
- **See:** the always-on ancestor substrate (Magic Resistance by tier) + the active focus reward layer; no
  duplicate/rogue auras, nothing bleeding from another race/mode, no generic-Daedric stack accreting.
- **Record:** ___

### Slot 4a -- ancestral urn ash-prayer loop (the substrate + the Ledger fix)  [Tester] [R]+[M]
- **Do:**
  1. Open inventory, **read the ancestral urn** (this is the ash-prayer). Or MCM Debug -> `Dunmer ancestor prayer`.
  2. Open the Devotion panel -> **Ledger** page.
  3. Read the urn **again the same day**.
- **See:** a **substrate toast** ("Ancestor prayer marked.") and the **ancestor-layer rises a tier** across
  2-3 prayers; the **urn stays in your inventory** (it is reusable). **Crucially**, the **Ledger now shows a
  driver row** for the ancestor act -- this used to be MISSING (the scaled-curated P0 fix). The 2nd same-day
  prayer **adds no extra piety** (daily cap) but still marks.
- **[Dev] log:** an ancestor-spine award marker in Papyrus.0.log.
- **Record:** ___

### Slot 4b -- ancestor-home bonus  [Tester] [R]+[M]
- **Do:** sleep in a bed to declare that cell your ancestor-home (watch for the declaration notice), then
  **read the urn AT that home** (or MCM Debug -> `Dunmer home bonus`). Pray with the urn ELSEWHERE for contrast.
- **See:** praying at the declared home fires the **bigger progress step** (a Ledger driver row) plus a timed
  **Health** restoration -- under Requiem watch the **HP bar actually move** (it is a flat Restore-Health, not
  a regen-rate buff). Praying anywhere else = base prayer only, no pulse.
- **Record:** ___

### Slot 4c -- ancestor-layer chronicle (the label deepening)  [Tester] [R]+[M]
- **Do:** raise the ancestor layer a tier (more `Dunmer ancestor prayer`), then **sleep to the next dawn**.
- **See:** when the **layer label changes** (quiet -> beginning -> steady -> strong) the **Book of Days**
  records it at the **next dawn**. There is **no per-act shift toast** here on purpose -- the substrate
  deepens gradually, so the change shows as a dawn chronicle line only.
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 4d -- commitment-offer ACCEPT (new Prisma beat)  [Tester] [R]+[M]
- **Do:** build up a Good Daedra so an offer is pending (MCM Debug can force the offer gate), then take the
  **accept** control.
- **See:** a **toast** -- *"The ash-prayer has a name: {patron}."* -- and a **pinned Book of Days entry** --
  *"The Reclamation deepens in you. You named {patron} as your focus."* ({patron} = Azura / Boethiah /
  Mephala). One offer at a time.
- **Check the Book of Days line is NOT blank** and names the right patron.
- **Record:** ___

### Slot 4e -- commitment-offer REFUSE (new Prisma beat, terminal)  [Tester] [R]+[M]
- **Do:** with an offer pending (fresh save / re-gate), take the **refuse** control instead.
- **See:** a **toast** -- *"You set {patron} aside."* -- and a **pinned Book of Days entry** -- *"The
  Reclamation holds as it was. You set {patron} aside, and {patron} will not ask again."* Refuse is
  **terminal** -- that patron does not ask again (same one-offer / terminal-refuse cadence as the other races).
- **Check the Book of Days line is NOT blank.**
- **Record:** ___

### Slot 4f -- curse silences / halves the ancestor layer  [Tester] [R]+[M]
- **Do:** raise the ancestor layer a tier, then Debug: Daedric & Curse -> **`Curse vampire`**. Read the urn /
  press `Dunmer ancestor prayer` again. Then **`Curse werewolf`**, pray again. Then **`Curse none`**.
- **See:** under **vampire** the posture reads *"silent, the ancestors cannot reach you"* and the prayer does
  **NOT** raise the layer (Layer 1 = 0x -- the signature consequence). Under **werewolf** the posture reads
  *"strained, the beast pulls at the ancestors"* and the prayer credits at **half** (still routes). After
  `Curse none` the posture reads *"restored, but scarred"* and the prayer credits **fully** again.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 4` (non-Dunmer), then fire a Dunmer ancestor seed / read an Azura
  book. Reset with `set PDV_GLO_OriginRace to 5` after.
- **See:** **nothing Dunmer moves** -- no ancestor layer, no Reclamation focus, no markers. A non-Dunmer can't
  drive native Dunmer state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as a Dunmer, do ordinary things that are NOT the coded hooks: a generic vanilla Daedric shrine
  activation, a theft, a murder, walking through ash, tomb travel.
- **See:** **none of these score** the ancestor layer or a Reclamation focus (only the urn read / MCM prayer /
  approved book sources do). Other Princes land as priced **deviation**, never as a fourth Reclamation.
- **Record:** ___

### Slot 7 -- neglect drop  [Tester] [R]+[M]
- **Do:** let the ancestor practice / a Good Daedra lapse (MCM Debug set piety to 0), then **Run Dawn**.
- **See:** a **"rites thinning / neglect"** toast + a Book of Days note, once, on the first lapse. (See the
  Universal Prisma sheet for the shared neglect surface.)
- **Record:** ___

### Slot 8 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **ancestor layer** feel quiet, identity-defining, and cumulative
  (always counting, never zero) while the **Reclamation focus** is the loudest reward? Does **accepting an
  offer** read as naming your patron, and **refusing** as closing a door for good? Does the **curse silence**
  read as the ancestors going unreachable rather than a debuff counter? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Dunmer beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force Good-Daedra piety + Run Dawn |
| ancestor substrate act (urn read / MCM prayer / home bonus) | Y | N | **Y (driver)** | read urn / MCM prayer |
| ancestor-layer deepening (quiet/beginning/steady/strong) | N | Y (next dawn) | N | raise practice a tier |
| commitment-offer ACCEPT | **Y** | **Y (pinned)** | N | accept a pending offer |
| commitment-offer REFUSE | **Y** | **Y (pinned)** | N | refuse a pending offer (terminal) |
| curse silence/half | Y (posture) | per universal | N | `Curse vampire` / `Curse werewolf` |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **The ancestral urn MUST stay in inventory.** It is a reusable BOOK token (portable shrine) -- if the count
  drops after reading, the grant is wrong -> FAIL.
- **Substrate Ledger driver is the key regression.** The Dunmer ancestor act used to record NO Ledger driver
  (the scaled-curated P0 bug); it now should (`AwardDunmerAncestorSpinePulse` -> `AwardCuratedSignalScaled`).
  If the Ledger stays empty after an ancestor prayer, FAIL.
- **The ancestor-layer change is a DAWN chronicle, NOT a toast.** Don't wait for a per-act shift toast on the
  layer label -- the substrate toast ("Ancestor prayer marked.") is the immediate piece; the label line lands
  at the **next dawn**.
- **Vampire = 0x, werewolf = 0.5x.** Under vampire the ancestor prayer must NOT raise the layer; under
  werewolf it credits at half. Anything else is a curse-posture bug.
- **Offer accept/refuse are one-at-a-time and refuse is terminal.** Re-test refuse on a fresh save -- a
  refused patron will not ask again.
- **Broad "ancestor + Reclamations" caps at Tier 2.** Worshipping all three Good Daedra broadly (no named
  focus) does not climb to Champion; only a named Reclamation focus does.
- **`coc` skips location triggers** -- walk in via a load door / fast-travel for the home / outdoor-shrine
  hooks. The urn read and MCM substrate buttons are not location-gated and work anywhere.
- **MCM Debug pages, not `cqf`.** Buttons are `Dunmer ancestor prayer`, `Dunmer home bonus`; curse buttons are
  `Curse none`, `Curse werewolf`, `Curse vampire`.

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | ancestral urn book token in inventory | | |
| 2 Survey | ancestor layer + focus + posture legible | | |
| 3 stack | ancestor + focus reward layer, no rogue aura | | |
| 4a urn ash-prayer loop | prayer -> layer rise + urn kept; **Ledger driver row**; daily cap | | |
| 4b ancestor-home bonus | home pulse: bigger step + HP-bar heal; elsewhere = base only | | |
| 4c ancestor-layer chronicle | label deepening lands at next dawn, non-empty | | |
| 4d offer ACCEPT | "ash-prayer has a name" toast + pinned BoD, names patron | | |
| 4e offer REFUSE | "set {patron} aside" toast + pinned BoD; terminal | | |
| 4f curse silence/half | vampire 0x silent + werewolf 0.5x + 3 posture labels | | |
| 5 wrong-origin | non-Dunmer origin: zero Dunmer movement | | |
| 6 generic silence | shrine/theft/murder/ash/tomb do not score | | |
| 7 neglect | toast + BoD once on first lapse | | |
| 8 felt | substrate-is-identity / Reclamation-is-foreground; offers land | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Dunmer `pass` until every row is filled.
