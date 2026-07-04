# PDV In-Game Run-Sheet -- Imperial (V1)

Status: V1 (Unit D Prisma live `5e9e502`; offer.accept / offer.refuse = NEW surfaces this pass).
Created 2026-06-25. Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources:
`PDV_PreBetaRaceGateLedger.md`, `PDV_PrismaParityRegistry.csv`, `PDV_RunSheet_Imperial_BetaFeel.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as an Imperial (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 1
   set PDV_GLO_DebugLevel to 2
   ```
   (`1` = Imperial. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. The Concordat readout is on that same Debug page under the **`Phase 8 Concordat`** header: four disabled
   text rows (`Raw value`, `Committed state`, `Pending state`, `Extreme gate`) and the action buttons
   `Concordat defiance`, `Concordat compliance`, `Talos shrine defiance`, `Unlock Concordat gate` in the
   right-hand `Race signals` column.
6. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 1`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so any HP-bar heal
  must be proven *here* -- watch the bar actually move. Daedric shrine prayers + quest reactions use the ARR
  variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check) that Imperial needs **NO new custom mesh** for the current V1 packet. Live Imperial
  proof uses vanilla books, exact PO3 quest-stage receivers, MCM Concordat/debug controls, and existing
  Prisma/MCM surfaces.
- **See:** no Imperial hook needs new art, a placed shrine, or a visible proof object for this pass. The retired
  `PDV_REFR_TalosShrineDefianceSignal` must NOT be reattached to the visible Windhelm shrine. If any hook is
  found to need a new mesh, **name it** instead of passing. Do not test Imperial as activator routes 110-113;
  in the live activator script those route IDs belong to Khajiit anti-creed routes.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** MCM Debug -> pick a Divine patron and `Apply target piety` ~30 so the patron line has content;
  leave Concordat at default (Uncommitted). Then open **Survey Devotion** (in the panel / MCM status).
- **See:** the Imperial lines read like narration -- **civic faith** as concrete public practice under law
  ("Your patron has taken note of the civic good you have done in their name."), a **Talos pressure tilt**
  in one of three readable states (defiant / constrained / not yet tilted), the **Concordat standing**
  legible (Uncommitted by default), and **concrete act requirements** (you can tell WHAT to do, not just a
  number). No raw enum codes / route IDs / dev counters leaking.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** with a patron set and ~30 piety, Concordat Uncommitted, open the **magic menu -> Active Effects**.
  Then press `Concordat defiance` a few times and re-check.
- **See:** only legitimate patron blessings -- **NO standalone "ConcordatStanding buff" effect** (the
  Concordat track is *pressure*, not a second buff faucet). Driving Concordat does NOT change the active
  patron and does NOT spawn a reward aura. Nothing bleeding from another race/mode.
- **Record:** ___

### Slot 4a -- the formal commitment OFFER loop (NEW surfaces)  [Tester] [R]+[M]
- **Do:**
  1. MCM Debug -> seed one Divine high enough to qualify for an offer (drive a curated patron toward the
     commitment threshold), then trigger the **formal commitment offer** (MCM Debug presents it).
  2. On the blocking popup, choose **Accept**.
  3. On a fresh save / second qualifying deity, repeat and choose **Refuse**.
- **See:**
  - **Accept:** a toast -- *"{patron} has named you their own."* -- and a **pinned Book of Days entry** --
    *"The broad faith narrows to one; {patron} has named you their own."* Your active patron is now that deity.
  - **Refuse:** a toast -- *"You turned {patron} away."* -- and a **pinned Book of Days entry** --
    *"The broad faith stays whole; you turned {patron} away, and {patron} will not ask again."* Refuse is
    **terminal** -- that deity will not offer again.
  - **Decline** ("not now") is silent by design -- no toast, no Book of Days (cooldown only). That is correct, not a FAIL.
- **Check both Book of Days lines are NOT blank** (a blank line = a wiring bug -> FAIL). Imperial shares the
  generic Nord offer copy -- the `{patron}` slot must read the real deity name, not a blank or a code.
- **Record:** ___

### Slot 4b -- one-offer-per-qualification cadence  [Tester] [R]
- **Do:** after an **Accept** in 4a, keep playing / run more dawns. After a **Refuse** in 4a, drive that same
  deity's piety back up and try to re-qualify it.
- **See:** an accepted patron does **not** re-offer the same deity; a refused deity is **permanently** off the
  offer list (terminal-refuse). A different qualifying deity can still offer (one offer per qualification, not a spam loop).
- **Record:** ___

### Slot 4c -- broad worship caps at Tier 2  [Tester] [R]+[M]
- **Do:** MCM Debug -> stay on **broad** Nine Divines worship (no patron committed), then use
  **Seed broad lane (origin)** and **Run dawn pass**. This uses the Imperial civic-service counter, not
  deity piety.
- **See:** broad civic worship **tops out at Tier 2 (Devoted)** -- you do NOT reach Champion on the broad
  faith. The path to Champion is through the formal commitment offer (Slot 4a). No Champion tier-up toast / no
  pinned Champion Book of Days entry on broad worship alone.
- **Record:** ___

### Slot 4d -- public Talos pressure book route  [Tester] [R] / [Dev] [R]
- **Do:** add and read the approved public Talos book from inventory normally:
  ```text
  player.additem 000ED04D 1
  ```
  (`000ED04D` is `Book2ReligiousTalosWorship`.) Read it from inventory; stand anywhere (inventory read, not a
  location trigger).
- **See:** a top-left notice / proven toast only ("The name of Talos: The question of the Ninth presses
  harder."). **No** forced full Prisma panel.
- **[Dev] log:** Papyrus marker `RouteImperialTalosPressure complete:`. This routes the Talos **PIETY** axis,
  NOT a Concordat point -- do not log it as a Concordat action.
- **Record:** ___

### Slot 4e -- Concordat Standing track (raw value vs band)  [Tester] [R]+[M] / [Dev] [R]
- **Do:** read MCM Debug `Phase 8 Concordat` -> `Raw value` at baseline. Press `Concordat defiance` one or
  more times (drives raw value negative, toward Private Defiant); then `Concordat compliance` (drives it
  positive). For the vanilla hooks: a **Stormcloak join** (CW01B) traces `-20`; the **player's own killing
  blow** on a `ThalmorFaction` Justiciar (`00039F26`, not a pre-set enemy) traces `-10`.
- **See:** the **`Raw value` moves** by the expected amount per press / hook (defiance `-20`, compliance
  `+15`, Talos shrine button `-15`, Justiciar `-10`). The Talos PIETY axis is separate -- driving Concordat
  does not award Talos piety.
- **KEY -- judge by the raw value, NOT the band label.** The committed `Committed state` band LABEL **lags**
  the raw value via the track lock-in grace, so a single signal moves the raw value but may not flip the band.
  If you read the band label you will **false-FAIL**.
- **[Dev] log:** the defiance/compliance route traces (`Concordat pressure -20 ... adjustment -20`, etc.).
- **Record:** ___

### Slot 4f -- Concordat reorientation surfaces in the Book of Days  [Tester] [R]+[M]
- **Do:** drive the Concordat raw value across a band boundary (enough defiance/compliance presses to actually
  shift the committed band past the lock-in grace), then **sleep to the next dawn**.
- **See:** **NO immediate toast** on the band change (by design -- `reorientation.imperial.concordat` is
  dawn-timed, toast=N). At the **next dawn** the **Book of Days** records the standing change. (If you see a
  band-change toast, that's a regression -> note it.) Natural dawn after the three-day lock-in is enough; you
  do not need an extra debug dawn if the entry already appears. Expected line shape:
  `Under the White-Gold Concordat, you are Publicly Compliant.`
- **Record:** ___

### Slot 4g -- Talos offer gated on Concordat Standing  [Tester] [R]
- **Do:** drive the Concordat `Raw value` **above 50** (repeated `Concordat compliance`), then try to qualify
  **Talos** for a formal commitment offer. Then drive it back to **<= 50** and try again.
- **See:** with Concordat Standing **> 50** the **Talos offer does NOT appear** (private conscience -- a Talos
  commitment is never handed out as a compliance reward). With Standing **<= 50** Talos can offer like the
  other eight Divines. The other eight Divine offers are NOT gated this way.
- **Record:** ___

### Slot 4h -- civic substrate driver  [Tester] [R]
- **Do (play normally where possible):** complete one of the wired Imperial civic quest-stage routes, then
  open the panel -> **Ledger**. Controlled test-save options are:
  `setstage MQ103 190` (Bleak Falls Barrow public service),
  `setstage CW02A 200` (Imperial Jagged Crown public service),
  `setstage MS08 200` (Saadia mercy),
  `setstage MS08 201` (Alik'r lawful order),
  `setstage MS13 100` or `setstage MS13 110` (Golden Claw honest work),
  `setstage MS14 200` (Laid to Rest death duty), or
  `setstage T02 200` (Book of Love patron-civic favor).
- **See:** the civic-ancestor substrate act lands a **driver row in the Ledger** (`public civic service`) and a
  **Chronicle entry** in the Book of Days ("Your public service steadies your devotion.", Talos token
  `imperial-civic`). The substrate is reason-bearing -- if the Ledger or Chronicle stays empty after a
  substrate act, FAIL.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 7` (Argonian; use a non-Imperial, non-Nord negative origin),
  then read the Talos book (`player.additem 000ED04D 1`) and try `Concordat defiance`. Reset with
  `set PDV_GLO_OriginRace to 1` after. Do **not** use Nord as the wrong-origin negative: Talos can validly
  hit Nord surfaces.
- **See:** **nothing Imperial moves** -- Concordat `Raw value` does not move, no civic-faith Survey copy, no
  offer, no markers. A non-Imperial origin can't read Concordat / civic state as native.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as an Imperial, do ordinary things that are NOT the coded hooks: gain a **faction rank**, attend /
  activate a **normal vanilla shrine**, pay a **bounty** alone, do **generic anti-Thalmor violence** framed as
  ordinary combat (not a credited Justiciar kill), generic lawfulness, generic Talos proximity, generic trade.
- **See:** **none of these score** -- Concordat `Raw value` unchanged, no patron-took-note Survey line, no
  Talos pressure tilt change, no reward stack. Only the real coded acts move state.
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does Imperial devotion read as **concrete civic practice under public law**
  (not generic faction or morality tracking)? Did the **Survey** teach which acts scored and why
  faction/attendance/bounty did not? Did **public vs private Talos** read as a real fork? Did the **Concordat
  band** feel like a slow political spine, not a per-action toggle? Did the **offer accept/refuse** read as a
  real, earned commitment beat? Note any magnitudes that felt off.
- **Record:** ___

---

## Prisma surfaces (Imperial beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted (broad caps at T2) | Y | Y | N | Seed broad lane (origin) + Run Dawn |
| tier Champion (via offer only) | Y | Y (pinned) | N | accept a formal commitment offer |
| offer.present | Y (the MESG popup) | N | N | MCM Debug present offer |
| offer.accept | **Y** | **Y (pinned)** | N | Accept the offer |
| offer.refuse | **Y** | **Y (pinned)** | N | Refuse the offer (terminal) |
| offer.decline ("not now") | N | N | N | Decline the offer (silent by design) |
| Talos pressure book | Y | N | Y (Talos piety driver) | read `000ED04D` |
| civic substrate act | Y | N | **Y (driver)** | civic-service / patron-civic act |
| reorientation.imperial.concordat | N (by design) | Y (next dawn) | N | cross a Concordat band, then dawn |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **Band LABEL lags raw value.** `PDV_ConcordatStandingTrack` commits its band via a lock-in grace, so a
  single signal moves the raw value but may not flip the `Committed state` label. Prove emitters by `Raw
  value`, not the band -- StateLabels are value-ordered, so a mismatch never self-cancels. Judge by raw or you false-FAIL.
- **The Talos book is a PIETY axis, not Concordat.** Reading `000ED04D` routes `RouteImperialTalosPressure`
  (Talos piety), NOT a Concordat point. Never test the book as a Concordat action.
- **Talos offer is private conscience, gated `<= 50`.** A Talos commitment offer only appears when Concordat
  Standing `Raw value` is **<= 50** -- it is never a reward for high compliance. The other eight Divine offers are ungated.
- **Broad worship caps at Tier 2.** You cannot reach Champion on broad Nine Divines worship -- Champion comes
  through the formal commitment offer. No Champion surface on broad worship alone is correct, not a FAIL.
- **Refuse is terminal; Decline is silent.** Refuse sets a permanent Rupture flag (the deity won't ask again)
  and DOES surface (toast + pinned BoD). Decline is a low-stakes "not now" -- cooldown only, NO surface. Don't FAIL the silent Decline.
- **Kill credit is player-only.** The Justiciar kill scores ONLY the player's own killing blow
  (ATTR_DIRECT_PLAYER). At a crowd fight an ally can steal credit -- land the final hit yourself or it false-FAILs.
- **Concordat band change has NO immediate toast.** `reorientation.imperial.concordat` is dawn-timed by
  design: the Book of Days records the standing shift at the next dawn, with no shift toast. A toast here would be a regression.
- **`coc` skips location triggers.** Today's runnable Imperial hooks are inventory- and MCM-driven, but any
  future location-anchored proof cell needs a load-door / fast-travel entry, never a `coc` straight in.
- **Hidden Talos shrine in-world is retired.** Do not reattach `PDV_REFR_TalosShrineDefianceSignal` to the
  visible Windhelm shrine; use the MCM `Talos shrine defiance` button for the `-15` route proof.
- **Do not use Imperial routes 110-113.** The live activator constants 110-113 are Khajiit anti-creed routes,
  not Imperial. Imperial V1 proof is through book / quest-stage receivers, Concordat mod events, formal-offer
  surfaces, and EventBus route events 140-142.
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | no new mesh or placed proof object required for current V1 packet | PASS | Tester confirmed the slot-1 asset/proof-object check. Imperial V1 uses existing books, quest-stage receivers, MCM Concordat/debug controls, and Prisma/MCM surfaces. |
| 2 Survey | civic faith + Talos tilt + Concordat + act reqs legible | PASS | Tester screenshots confirmed Survey readability after wording polish. Final accepted shape keeps civic faith, standing, Talos posture, and Concordat state player-facing without route IDs. |
| 3 stack | patron blessings only, no rogue Concordat buff | PASS | Tester screenshots confirmed expected civic/patron reward stack and no separate ConcordatStanding buff. Later broad/focused stack checks also showed the active effects stack behaving as expected. |
| 4a offer accept/refuse | toast + pinned BoD, non-empty; decline silent | PASS | Tester confirmed accept/refuse criteria. Follow-up polish removed preamble before `{patron} has named you their own`; active deity effects now grant for accepted patrons. |
| 4b offer cadence | one-offer-per-qualification; terminal refuse | PASS | Tester confirmed accepted patron did not re-offer, refused deity did not re-offer, and a different qualifying deity still could offer. Refuse remains terminal by design. |
| 4c broad caps T2 | no Champion on broad worship | PASS | Tester confirmed broad civic worship capped at Faithful/Tier 2 and did not produce a Champion broad-worship surface. Book of Days and Ledger broad-lane surfaces were patched and retested. |
| 4d Talos book | RouteImperialTalosPressure marker, no panel | PASS | Tester confirmed the Talos book route passed in game. Backend path treats this as Talos piety pressure, not Concordat movement. |
| 4e Concordat track | raw value moves per emitter (judge raw, not band) | PASS | Tester confirmed designated raw-value movement for the Concordat debug buttons. Band label lag remains expected due to lock-in grace. |
| 4f Concordat reorientation | next-dawn BoD, NO immediate toast | PASS | Manual Book of Days screenshot plus backend commit marker: Uncommitted -> PublicCompliant. Copy patched to player-facing Publicly Compliant; restart required before rechecking text. |
| 4g Talos offer gate | Talos offer hidden when Standing > 50 | PASS | Backend confirmed: at Concordat raw 60 / Publicly Compliant, commitment evaluation stayed pending 0 -> 0. Manual/backend allowed-side proof: Talos offer appeared at raw 40. Restarted polish pass confirmed Talos tier toast/diegetic suppression while Concordat blocks offers. |
| 4h civic substrate | civic act lands a Ledger driver | PASS | Confirmed in-game after typo fix: wired Imperial civic route produced the expected Ledger driver / Book of Days civic-service surface. |
| 5 wrong-origin | non-Imperial, non-Nord origin: zero Imperial movement | PASS | Tester confirmed after swapping off Nord, because Talos can validly hit Nord surfaces; Imperial Concordat/civic state stayed silent under the corrected negative origin. |
| 6 generic silence | faction/attendance/bounty/lawfulness do not score | PASS | Tester confirmed 3-5 generic civic/Talos-proximity actions left Concordat raw unchanged and did not move the Imperial surfaces. |
| 7 felt | reads as concrete civic practice under law | PASS | Tester confirmed the generic-silence/felt read based on the full Imperial playthrough. |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md` if that gate is revived. Current 2026-07-04 result: all Imperial V1 rows above
are tester-passed for the current packet; final-world placement remains separate. Imperial activator routes
110-113 are not part of the current V1 gate.
