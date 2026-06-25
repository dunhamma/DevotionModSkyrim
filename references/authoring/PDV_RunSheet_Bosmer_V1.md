# PDV In-Game Run-Sheet -- Bosmer (V1)

Status: V1 (Unit D Prisma live `5e9e502`; the path-confirm Book of Days line is the NEW beat this pass). Created 2026-06-25.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_PreBetaRaceGateLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV_BetaTestPacket_Bosmer.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as a Bosmer (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 4
   set PDV_GLO_DebugLevel to 2
   ```
   (`4` = Bosmer. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`. The Bosmer path buttons are
   **Bosmer -> OldContract / LivingStory / Exchange / BanditRoad** plus **Seed Bosmer variety**.
5. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 4`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. The path-family reward ladders (Living Story
  HRegen, Bandit Road HRegen) read differently under Requiem.

---

## Tests

### Slot 1 -- the four paths confirm + path-confirm beat (the NEW Unit D chronicle)  [Tester] [R]+[M]
- **Do:** for each path in turn, MCM Debug -> click the path button (**LivingStory**, then **Exchange**, then
  **BanditRoad**), click **Seed Bosmer variety** to seed evidence, then drive the confirm (the suggestion
  popup / proven-path rite). Open the Devotion panel -> **Ledger** and -> **Chronicle** after each.
- **See:** an **immediate path-shift toast** naming the new road; the **Ledger shows a new driver row** for that
  path's god (Living Story -> Y'ffre, Exchange -> Z'en, Bandit Road -> Baan Dar -- the confirm carries a curated
  signal, so a piety move lands); and a **Book of Days entry** -- *"Y'ffre's song settles within you. Your road
  through the Green is the {path}."* (this is the NEW beat -- before Unit D the confirm had no chronicle line).
- **Check the Book of Days line is NOT blank** and names the right path (a blank/empty line = a wiring bug -> FAIL).
- **Record:** ___

### Slot 1b -- Old Contract is a binding pact, not just a path  [Tester] [R]+[M]
- **Do:** MCM Debug -> click **OldContract**, **Seed Bosmer variety**, then drive the Old Contract confirm.
  Then renounce it (the renunciation route / Apostate drop).
- **See:** confirming Old Contract **binds you to Y'ffre exclusively** (pact-bound; the path-confirm toast +
  Book of Days line fire as in Slot 1). It is **binary** -- you are pact-bound or you are not. **Renouncing
  freezes Y'ffre** (the pact closes; you cannot just slide back). Survey reflects the Pact binding/lapse.
- **Record:** ___

### Slot 1c -- Green Pact compliance meter (Old Contract only)  [Tester] [M]
- **Do:** while on Old Contract, drive compliant vs non-compliant acts (or seed compliance via the Debug page),
  then open **Survey Devotion**.
- **See:** the Survey names a **compliance band** -- **Apostate** (lapsed all the way) / **Lapsed** /
  **Observant** / **Strict** (most devout). The band reads as fiction, no raw 0-100 number leaking. (Strict is
  the high-compliance pole that rewards hardest; Apostate is the fallen pole. Bands gate at raw 0-19 / 20-49 /
  50-79 / 80-100 internally.)
- **Record:** ___

### Slot 1d -- 7-day lockout after a switch  [Tester] [R]
- **Do:** confirm any path, then **immediately** try to switch to a different path (path button + confirm)
  without waiting.
- **See:** the second switch **does not take** within the lockout window -- you cannot ping-pong paths.
  (To test the switch legitimately, use **Seed Bosmer variety** to clear the cooldowns, or wait 7 in-game days.)
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> set a path, cycle the scoring deity, Force Piety to **85**, Run dawn pass. Then open
  **Survey Devotion** (in the panel / MCM status).
- **See:** the Bosmer lines read like narration -- **active path**, **standing**, **Pact binding/lapse** (Old
  Contract), **Green Pact compliance band** (Old Contract), and **recent favor** memory. No raw counters or route
  IDs. (Known editorial gap: the path line may still leak the raw enum like `OldContract` -- note it, not a blocker.)
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** with a path at Champion (85), open the **magic menu -> Active Effects**.
- **See:** **one** path-family reward set present (switching the path button SWAPS the family -- never two at once),
  no duplicate/rogue auras, nothing bleeding from another race/mode. Told-self (Naming) shows at most one.
- **Record:** ___

### Slot 4a -- reward-tier sweep per path  [Tester] [R]+[M]
- **Do:** per path: path button -> cycle `Selected deity` to its scoring god -> set `Target piety`
  **25 -> 50 -> 85**, **Run dawn pass** each step -> open Active Effects.
- **See:** the ladder grows per path (OldContract = Archery/Sneak/PoisonRes on Y'ffre; LivingStory = Speech/HRegen
  on Y'ffre; Exchange = Speech/CarryWt/Armor on Z'en; BanditRoad = Armor/HRegen/Sneak on Baan Dar). Only ONE family
  at a time. T3 (85) is Survey/status recognition, **not** a formal Champion offer prompt for Bosmer.
- **Record:** ___

### Slot 4b -- variety levers in normal play  [Tester] [R]
- **Do (play normally after Seed Bosmer variety):** **Green Dreams** (sleep consecutive nights -> occasional
  path-keyed dream line); **Hearth + Tale Carried** (Living Story: declare a hearth cell, discover 3+ new
  locations, sleep again); **Songs of the Green** (visit the 6 green sites via load-door/fast-travel, NOT `coc`);
  **Scales at Rest** (Exchange signal, once/day); **Baan Dar Gap** (Bandit Road: drop sub-20% health in combat);
  **the Naming** (sleep at hearth/song site -> Hunter/Speaker/Wanderer/Keeper told-self). Open the **Ledger** after.
- **See:** each lever lands its toast/spell and a **driver row** for the path's god where it carries piety; the
  Baan Dar Gap fires **only** sub-20% **in combat** on Bandit Road, **silent** otherwise.
- **Record:** ___

### Slot 4c -- tier-ups  [Tester] [R]+[M]
- **Do:** MCM Debug -> Force the scoring deity's piety to **25**, **Run dawn pass**; repeat at **50**, then **85**.
- **See:** each step pops a **toast** and writes a **Book of Days** entry; at **Champion (85)** the entry is **pinned**.
- **Record:** ___

### Slot 4d -- neglect "The Path Goes Quiet"  [Tester] [R]+[M]
- **Do:** set the active scoring deity's **Target piety to 0** (the gate is piety **<= 10** + bottom-3-lowest, NOT
  "below 25" -- seeding 12-24 reads as a false FAIL). **Run dawn pass.**
- **See:** a **neglect toast** + Book of Days note, once on the first lapse; the path reward removes and **The Path
  Goes Quiet** (StaminaRateMult -5) applies. A committed patron also prints a vanilla top-left
  *"<Deity>'s regard fades as your devotion goes quiet."*
- **Record:** ___

### Slot 4e -- curse  [Tester] [R]+[M]
- **Do:** drive a curse onset (werewolf/vampire) via the Debug page or in play, then cure it.
- **See:** an **onset toast + Book of Days entry**, and a **cure toast + entry**. Per the Universal sheet's curse beats.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 6`, then fire a Bosmer lever/signal (Baan Dar Gap, a path confirm,
  a Songs anchor). Reset with `set PDV_GLO_OriginRace to 4` after.
- **See:** **zero Bosmer movement** -- no path/spell/notification, no manager fired line, no driver row. A
  non-Bosmer can't drive Bosmer state. (The Daedric Hircine route may still fire on DA05; the Bosmer route must not.)
- **Record:** ___

### Slot 6 -- generic acts stay silent (the rejected-hook list)  [Tester] [R]
- **Do:** as a Bosmer, do ordinary things that are NOT the coded hooks: **generic forest travel**, **generic
  trade profit**, **raw theft**, **repeated theft**, **generic crime**, **generic kindness**, **generic bard
  activity**, **random vengeance**, **broad plant detection without tag evidence**, one **generic Bosmer favor**,
  combat above 20% health.
- **See:** **none of these score** any path/god and **none fire** Tale Carried / Scales / Gap / Naming / Song. Only
  the real coded acts do. (Route-only EventBus noise is NOT a pass -- look for a manager fired line / driver row.)
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Do the **four paths** read as real, different roads (chosen vs suggested)? Does the
  **path-confirm** land as a moment -- toast now, then *"Y'ffre's song settles within you..."* in the Chronicle at
  dawn? Does **Old Contract** feel like a binding pact (and renouncing like a door closing)? Does the **Green Pact
  meter** read as devotion, not a number? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Bosmer beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force scoring-deity piety + Run Dawn |
| **path-confirm** (LivingStory/Exchange/BanditRoad/OldContract) | **Y (shift, immediate)** | **Y ("Y'ffre's song settles...", next dawn)** | **Y (driver, the carried signal)** | path button + Seed + confirm |
| variety lever (Tale Carried / Scales / Gap / Song / Naming) | Y | N | Y where it carries piety | the lever in normal play |
| neglect "The Path Goes Quiet" | Y | Y | N | scoring deity Target 0 + Run Dawn |
| curse onset / cure | Y | Y | N | curse onset then cure |
| dawn digest | Y | Y | per universal | see the Universal Prisma sheet |

Rejected hooks (the **genericHookRejection** slot -- these MUST stay silent): generic Bosmer favor, generic
kindness, generic bard activity, generic forest travel, generic trade profit, random vengeance, raw theft,
generic crime, repeated theft, broad plant detection without tag evidence.

---

## Known gotchas
- **The path-confirm Book of Days line is the NEW beat.** Toast is immediate; the *"Y'ffre's song settles
  within you. Your road through the Green is the {path}."* chronicle entry lands at the **next dawn** (snapshot
  diff). If that line is blank or names the wrong path, FAIL.
- **Old Contract is binary + exclusive.** Pact-bound to Y'ffre only; you can renounce, which **freezes Y'ffre** --
  it is not a soft slide back. Renouncing has a terminal flag, so a renounced save can't re-confirm Old Contract.
- **7-day lockout after a switch.** You can't ping-pong paths; **Seed Bosmer variety** clears the cooldowns for testing.
- **Neglect gate is piety <= 10** (plus bottom-3-lowest), NOT "below 25" -- drop the scoring deity to **0**, or
  you get a false FAIL.
- **`coc` skips location triggers** -- walk/fast-travel into the Songs anchors (and Eldergleam), never `coc` straight in.
- **Baan Dar Gap is sub-20% health IN COMBAT on Bandit Road only** -- above-20%, out-of-combat, second-same-day,
  off-path, and non-Bosmer all stay silent; route-only EventBus noise is not a pass.
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 four paths + confirm beat | shift toast + driver + new BoD line, non-empty | | |
| 1b Old Contract pact | binds Y'ffre exclusive; renounce freezes | | |
| 1c Green Pact meter | Apostate/Lapsed/Observant/Strict band legible | | |
| 1d 7-day lockout | no instant re-switch after a confirm | | |
| 2 Survey | path/standing/Pact/compliance/recent favor legible | | |
| 3 stack | one path family, no rogue aura | | |
| 4a reward sweep | per-path T1/T2/T3 ladder + single-family swap | | |
| 4b variety levers | Dreams/Hearth/Songs/Scales/Gap/Naming + drivers | | |
| 4c tier-ups | toast + BoD each tier; Champion pinned | | |
| 4d neglect | "The Path Goes Quiet" once at piety 0 | | |
| 4e curse | onset + cure toast + BoD | | |
| 5 wrong-origin | origin 6: zero Bosmer movement | | |
| 6 generic silence | rejected-hook list does not score/fire | | |
| 7 felt | paths + confirm + pact + meter read earned | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Bosmer `pass` until every row is filled.
