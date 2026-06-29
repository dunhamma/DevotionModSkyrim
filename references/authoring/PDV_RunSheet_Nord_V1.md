# PDV In-Game Run-Sheet -- Nord (V1)

Status: V1 (Unit D Prisma live `5e9e502`; the formal commitment-offer accept/refuse surfacing is the
NEW build of this pass). Created 2026-06-25. Pair with `PDV_RunSheet_Universal_Prisma_V1.md`.
Sources: `PDV_PreBetaRaceGateLedger.md` (Nord section), `PDV_PrismaParityRegistry.csv` (Nord beats),
`PDV_PrismaParity_AuthoringDraft.md`, live `PDV__ManagerQuest.psc`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

Nord is the **broad-into-one** race: you worship a whole pantheon at first, and one god eventually steps
forward and *asks* for you. The headline of this run is that **formal commitment-offer** flow and its new
cadence (the pop-up, accepting, refusing, and how often it re-asks).

---

## Preflight (do once)
1. Start a **new save** as a Nord (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 0
   set PDV_GLO_DebugLevel to 2
   ```
   (`0` = Nord. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. **Pick your pantheon baseline early.** Nord chooses **Old Ways** vs **Nine Divines** at startup and it is
   **irreversible**. For a clean run, confirm Old Ways (so Kyne / Shor / Tsun / Stuhn are the offer-eligible
   gods). To test the Nine Divines tree instead, MCM Debug -> **Set Nord Pantheon Baseline** (1 = Nine Divines).
   Talos is **always** offer-eligible under either baseline.
6. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 0`, DebugLevel, baseline choice, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  (Kyne / Talos / Shor capstones) must be proven *here* -- watch the bar actually move.

---

## Tests

### Slot 1 -- pantheon baseline + broad-worship cap  [Tester] [M] + [Dev] [R]
- **Do:** Confirm your baseline at startup (Old Ways or Nine Divines). Then play / seed broad worship of the
  whole pantheon (MCM Debug -> award curated signals across several baseline gods; **Run Dawn**). Open
  **Survey Devotion**.
- **See:** the Survey mode line reads **Broad Old Ways** (or **Broad Nine Divines**). Broad worship **tops out
  at Tier 2 (Faithful)** -- no single god should reach Tier 3 / Champion off broad worship alone. Baseline is
  **locked** (no way to switch it after startup).
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> Force a baseline god's piety to **40**; **Run Dawn**. Open **Survey Devotion**.
- **See:** the Nord lines read like narration -- pantheon baseline, broad/focused state, primary patron,
  Kyne/Talos favor, Hircine price (only when relevant). No raw numbers / enum codes leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** With a patron at Champion, open the **magic menu -> Active Effects**.
- **See:** the patron reward effect(s) present, plus the broad/ambient layer if applicable; **no duplicate
  auras**, nothing bleeding from another race/mode. Kyne / Talos / Hircine must **not** stack into a universal
  build (focused rewards beat broad).
- **Record:** ___

### Slot 4 -- broad-faith book routes + Prisma-first notices  [Tester] [R]
- **Do (play normally, no debug):** read an **Old Ways** lore book and a **Hircine / Arkay** book. (If forcing,
  MCM Debug can fire the route.)
- **See:** a **Prisma overlay toast** on the first read of each (the `po3_book` surfacing), or a vanilla
  top-left fallback only if Prisma is unavailable. Re-reading the same book does not re-fire the notice.
- **[Dev] log:** the `RouteNord*` book route markers in Papyrus.0.log.
- **Record:** ___

---

### Slot 5 -- THE HEADLINE: commitment-offer PRESENT  [Tester] [R]+[M]
The pop-up that asks for your devotion. Two ways to trigger it -- do **both**.

- **Do (forced):** MCM Debug -> **Seed Commitment Signal Days** for one baseline god (e.g. Kyne), then
  **Force Piety** on that god to **55** (above the 50 threshold), then MCM Debug -> **Evaluate Commitment Offer**.
- **Do (organic):** with no debug, **qualify** a god the honest way -- get its piety **>= 50** AND land that
  god a curated signal on **two separate days** (within a 7-day window). Then **Run Dawn** (or the next natural
  dawn) -- the offer fires on the dawn evaluation.
- **See:** a **blocking pop-up (MESG)** in that god's voice, offering to take you as their own. It has three
  choices: **accept** / **not yet** / **refuse**. (The pop-up itself is the surface -- no separate toast at
  present-time.)
- **Record:** ___

### Slot 6 -- offer ACCEPT (new beat)  [Tester] [R]+[M]
- **Do:** trigger an offer (Slot 5), then choose **accept** on the pop-up -- OR force it: MCM Debug ->
  **Accept Pending Commitment**.
- **See:** an immediate **toast** -- *"{patron} has named you their own."* -- and a **pinned Book of Days
  entry** -- *"The broad faith narrows to one; {patron} has named you their own."* You are now **focused** on
  that god (broad -> focused); the god can now climb to **Champion**. Some of your old broad piety carries over.
- **Check the Book of Days line is NOT blank** (a blank line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 7 -- offer REFUSE (new beat, TERMINAL)  [Tester] [R]+[M]
- **Do:** trigger an offer (Slot 5), then choose **refuse** on the pop-up -- OR force it: MCM Debug ->
  **Refuse Pending Commitment**.
- **See:** an immediate **toast** -- *"You turned {patron} away."* -- and a **pinned Book of Days entry** --
  *"The broad faith stays whole; you turned {patron} away, and {patron} will not ask again."* You stay **broad**
  (no patron set).
- **Check the Book of Days line is NOT blank** (blank = FAIL).
- **Record:** ___

### Slot 8 -- offer DECLINE ("not yet")  [Tester] [M]
- **Do:** trigger an offer, then choose **not yet** -- OR force it: MCM Debug -> **Decline Pending Commitment**.
- **See:** the pop-up just closes. **No toast, no Book of Days entry** -- this is the quiet "not now" deferral,
  by design. (The offer can come back later -- see Slot 9.)
- **Record:** ___

### Slot 9 -- the NEW cadence (no re-nag / refuse is terminal / decline re-asks)  [Tester] [R]+[M] + [Dev] [R]
Prove all three rules. Reset between sub-tests with MCM Debug -> **Reset Commitment State** for the god.

- **9a -- ONE offer per qualification (no re-nag):** Accept a god (Slot 6). Then **Run Dawn** several more days.
  - **See:** the same god **does not pop the offer again** -- it's resolved. (The `Offered` flag is set.)
- **9b -- Refuse is TERMINAL:** Refuse a god (Slot 7). Now drive a deep lapse (Force that god's piety to **0**,
  **Run Dawn**), then **rebuild** it back above 50 with fresh signals on two days and **Run Dawn**.
  - **See:** that god **never offers again**, even after the full lapse + rebuild. (`Refused` stays set.)
  - **[Dev] log:** the `pending` evaluation skips the refused god; rupture flag stays 1.
- **9c -- "Not yet" RE-OFFERS only after a dip + climb:** Decline a god (Slot 8). Then **drop** that god's piety
  **below 50** (Force to e.g. 30, Run Dawn), then **climb it back** above 50 with signals on two days and Run Dawn.
  - **See:** the offer **re-fires** for that god (it only re-asks after piety fell under the threshold and came
    back -- it will NOT re-ask while piety simply stays high).
- **Record:** ___

### Slot 10 -- reorientation: devotion-mode (broad -> focused chronicle)  [Tester] [R]+[M]
- **Do:** accept an offer (Slot 6) so your mode flips broad -> focused. Then **sleep to the next dawn**.
- **See:** at the **next dawn** the **Book of Days** records the mode change (the `reorientation.nord.devotion-mode`
  roll-up). This is the dawn snapshot of your new focus -- **no separate immediate toast for the mode line**
  (the accept toast in Slot 6 is the immediate beat; this is the chronicle). Survey mode line now reads
  **Focused {patron}**.
- **Record:** ___

### Slot 11 -- tier-ups to Champion  [Tester] [R]+[M]
- **Do:** with a focused patron (post-accept), MCM Debug -> Force Piety **25**, **Run Dawn**; repeat at **50**,
  then **85**.
- **See:** each step pops a **toast** + a **Book of Days** entry; at **Champion (85)** the entry is **pinned**.
  The patron Champion reward applies (judge HP-bar feel in Authoria).
- **Record:** ___

### Slot 12 -- curse onset / cure (Hircine edge)  [Tester] [R]+[M] + [Dev] [R]
- **Do:** MCM Debug -> force the **Hircine / werewolf** curse on, **Run Dawn**; then force-cure it, **Run Dawn**.
- **See:** a **curse-onset toast + pinned Book of Days note** on onset, and a **cure toast + note** on cure.
  Hircine's price shows in Survey while cursed. (Nord's per-race onset notice is subtle -- if you miss the
  visual, the [Dev] log confirms the curse transition + absence/return sound fired.)
- **Record:** ___

### Slot 13 -- neglect drop  [Tester] [R]+[M]
- **Do:** MCM Debug -> set a worshipped god's piety to **0**, **Run Dawn**.
- **See:** a **"rites thinning / neglect"** toast + a Book of Days note, once, on the first lapse.
- **Record:** ___

### Slot 14 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 7` (Argonian), then fire a Nord seed/act. Reset with
  `set PDV_GLO_OriginRace to 0` after.
- **See:** **nothing Nord moves** -- no baseline gods, no offer, no markers. A non-Nord can't drive Nord state.
- **Record:** ___

### Slot 15 -- generic acts stay silent  [Tester] [R]
- **Do:** as a Nord, do ordinary things that are NOT coded hooks: generic kills, generic travel, generic tomb
  clears, generic anti-Thalmor violence.
- **See:** **none of these score** an offer or a patron boon, and broad worship does **not** inherit every
  patron's reward. (Only the real coded acts / the formal offer move you.)
- **Record:** ___

### Slot 16 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **offer pop-up** feel like a god *choosing you* rather than a menu?
  Does **accept** read as the broad faith narrowing to one (earned, personal)? Does **refuse** read as a door
  you closed for good? Did the **cadence** feel right (no nagging; "not yet" came back, "refuse" never did)?
  Note any deity-name copy that read oddly in the pop-up or toast.
- **Record:** ___

---

## Universal Prisma surfaces
Run `PDV_RunSheet_Universal_Prisma_V1.md` once on this character too (panel cold-open + ESC, tier-ups, dawn
digest, Ledger + substrate driver, Book-of-Days pruning, neglect, overall read). Those cover the shared three
spaces; this sheet covers only the Nord-specific beats below. Don't duplicate them.

## Prisma surfaces (Nord beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force patron piety + Run Dawn |
| commitment-offer PRESENT | Y (the MESG pop-up) | N | N | qualify a god (>=50 + 2 signal-days) + dawn / Debug Evaluate |
| commitment-offer ACCEPT | **Y** | **Y (pinned)** | N (carryover already stored) | accept the pop-up / Debug Accept |
| commitment-offer REFUSE | **Y** | **Y (pinned)** | N | refuse the pop-up / Debug Refuse |
| commitment-offer DECLINE ("not yet") | N | N | N | decline the pop-up / Debug Decline |
| reorientation: devotion-mode (broad->focused) | N | Y (next dawn) | N | accept an offer, then sleep to dawn |
| Nord ancestor substrate act | Y | N | **Y (driver)** | ancestor standing / ancestral rest / hearth return |
| curse onset / cure (Hircine) | Y | Y (pinned) | per universal | force curse on/off + Run Dawn |
| neglect / dawn digest | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **THE OFFER ACCEPT/REFUSE TOAST + PINNED BoD ARE THE NEW BUILD.** The registry historically marked these as
  GAPs (pop-up only, no accept/refuse surface). They are now wired via `DispatchDiegeticCue -> SurfaceTransition`
  (headline = pinned). If accept or refuse fires **no toast** or **no Book of Days entry**, that's the
  regression -> FAIL.
- **Qualification is piety >= 50 AND signals on 2 separate days (in a 7-day window).** Forcing piety alone is
  NOT enough -- you must also **Seed Commitment Signal Days** (or land real signals on two days) or the offer
  won't fire. A false-FAIL here is almost always a missing signal-day seed.
- **Refuse is PERMANENT.** That god never offers again, even after a deep lapse + rebuild. Use **Reset
  Commitment State** to test the same god again.
- **"Not yet" only re-offers after piety dips BELOW 50 and climbs back.** It will not re-ask while piety just
  stays high -- that's the no-nag rule, not a bug.
- **Baseline is irreversible and set at startup.** Old Ways gods (Kyne/Shor/Tsun/Stuhn) vs Nine Divines gods
  are fixed; **Talos is offer-eligible under either**. Pick the baseline you mean to test before you start.
- **Broad worship caps at Tier 2.** Tier 3 / Champion is **only** reachable after a formal commitment.
- **The devotion-mode chronicle lands at the NEXT dawn** (the accept toast is immediate; the mode roll-up is the
  dawn snapshot). Don't expect a second toast for the mode line.
- **`coc` skips location triggers** -- walk/fast-travel for any location-based hook.
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 baseline + cap | baseline locked; broad caps at Tier 2 | | |
| 2 Survey | pantheon/mode/patron legible, no raw codes | | |
| 3 stack | patron reward layer, no rogue/universal stack | | |
| 4 book routes | Old Ways + Hircine/Arkay notices on first read | | |
| 5 offer PRESENT | pop-up fires (forced + organic) | | |
| 6 offer ACCEPT | toast + pinned BoD; broad->focused; non-empty | | |
| 7 offer REFUSE | toast + pinned BoD; stays broad; non-empty | | |
| 8 offer DECLINE | silent "not yet", no surfaces | | |
| 9 cadence | no re-nag / refuse terminal / decline re-asks on dip+climb | | |
| 10 devotion-mode | next-dawn chronicle of broad->focused | | |
| 11 tier-ups | toast + BoD each tier; Champion pinned | | |
| 12 curse | onset/cure toast + pinned BoD (Hircine) | | |
| 13 neglect | toast + BoD once on first lapse | | |
| 14 wrong-origin | Argonian origin: zero Nord movement | | |
| 15 generic silence | kills/travel/tomb/anti-Thalmor do not score | | |
| 16 felt | offer reads as a god choosing you; cadence right | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Nord `pass` until every row is filled.
