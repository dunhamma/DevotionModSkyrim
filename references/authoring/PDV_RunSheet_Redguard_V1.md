# PDV In-Game Run-Sheet -- Redguard (V1)

Status: V1 (Unit D Prisma live `5e9e502`; refreshes the live `PDV_RunSheet_Redguard_BetaFeel.md`
gameplay slots and ADDS the Prisma offer/sect-chronicle beats). Created 2026-06-25.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_RunSheet_Redguard_BetaFeel.md`,
`PDV_PreBetaRaceGateLedger.md`, `PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md`,
`PDV_Phase20_RedguardProofPlacement_Runbook.md`.

**How to read this sheet.** Each test is **Do** (the exact in-game actions -- MCM clicks or normal play),
**See** (what should happen on screen), and **Record** (PASS / FAIL / PENDING / N-A). Tags: **[Tester]** =
anyone can run it by playing/clicking; **[Dev]** = needs the console or a Papyrus-log check (owner runs
those). The `[R]`/`[M]` tag is just the proof class -- `[R]` objective (log/number/rendered), `[M]` your judgment.

---

## Preflight (do once)
1. Start a **new save** as a Redguard (or from the main menu console: `coc qasmoke`). State only inits on a new save.
2. In MO2 (**Anvil** instance), make sure `Devotion - Living Deities Test` is **disabled**.
3. Open the console (`~`) and type:
   ```text
   set PDV_GLO_OriginRace to 9
   set PDV_GLO_DebugLevel to 2
   ```
   (`9` = Redguard. DebugLevel 2 turns on the log markers the owner checks.)
4. The **Debug page**: open the MCM (the mod-config menu), go to **Devotion -> Developer Options**. Every
   "seed" below is a labelled control there -- NOT a console `cqf`.
5. A new save as origin 9 prompts the **Redguard sect choice** at startup: **Crown / Forebear / Ash'abah**.
   Most tests want a specific sect -- the slot says which to pick.
6. Owner only: the QASmoke proof REFRs (the **Ash'abah duty** signal etc.) need the 2-hex plugin prefix `XX`.
   Read it once from a NAMED blessing -- `help "HoonDing" 0` -- and take the first two hex of the returned
   `SPEL:` FormID. Fire a proof REFR with `prid XX<refid>` then `activate player` (NOT bare `activate`).
   RefIDs are in `PDV_Phase20_RedguardProofPlacement_Runbook.md`.
7. Owner only: Papyrus log is at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Running in Authoria (Requiem) -- same steps, swap the preflight
**Yes -- the test steps and expected surfaces are identical** (the devotion/Prisma logic is the same
regardless of load order). Only the preflight changes:
- Use the **Authoria** MO2 instance, not Anvil. Requiem + ARR are active.
- `Devotion - Living Deities Test` isn't in that list -- **skip the disable step**. Everything else (new
  save, `set PDV_GLO_OriginRace to 9`, DebugLevel, the MCM Debug page) is the same.
- **Authoria is the right place to judge reward FEEL.** Requiem zeroes regen-rate buffs, so the
  **Tu'whacca death-rite heal** MUST be proven *here* -- watch the HP bar actually move. Daedric shrine
  prayers + quest reactions use the ARR variant under Requiem (same beats, different shrine records).

---

## Tests

### Slot 1 -- new records present  [Dev] [M]
- **Do:** Confirm (desk check / Active Effects) that the B1/B2/tail Redguard hooks are script + existing-record
  changes -- the Tu'whacca death-rite heal, Ash'abah stigma, HoonDing make-way, the named-boss FormList
  (`PDV_FLST_HoonDing_BreakthroughBosses`), and the Ash'abah cleared-site list
  (`PDV_FLST_RedguardAshAbahUndeadClearSites`).
- **See:** no Redguard hook needs a new mesh; notices are top-left fallbacks where used; the low-health save is
  a hidden script-host effect. The **sect Champion-entry** messages
  (`PDV_Msg_Redguard_ChampionEntry_{Crown|Forebear|AshAbah}`) exist.
- **Record:** ___

### Slot 2 -- Survey reads clean  [Tester] [M]
- **Do:** Pick the **Ash'abah** sect at the startup choice (so the Survey sect line reads Ash'abah). Seed
  Tu'whacca as primary and Force Piety to **85** (Champion). Then open **Survey Devotion** (in the panel / MCM status).
- **See:** the Redguard sect line reads the duty fiction in plain narrator voice ("the unclean dead are your
  charge..."); after death-duty acts a **stigma line** appends (>=1 "You are death-touched..."; >=3 "You are
  hollow-eyed: the clean turn their faces..."). No raw enum/counter leaking; the stigma escalates legibly with kept duty.
- **Record:** ___

### Slot 3 -- effect stack is clean  [Tester] [M] + [Dev] [R]
- **Do:** Lawful Tu'whacca build at Champion (no death-duty yet): open the **magic menu -> Active Effects**.
  Then switch the active patron to **HoonDing** (MCM), Champion, and re-check.
- **See:** Tu'whacca shows the ward (ResistMagic) and **NO standalone "Health Regeneration" effect** (the
  swallowed HealRateMult was removed). HoonDing shows its stat reward (OneHanded/SpeedMult) and **no make-way
  aura** (make-way is a piety pulse, not a buff). No duplicate/rogue auras, nothing bleeding from another race/mode.
- **Record:** ___

### Slot 4a -- Tu'whacca death-rite heal (the Requiem core)  [Tester] [R]+[M]
- **Do (run this in Authoria):**
  1. Seed Tu'whacca, Force Piety ~50 (Devoted) for the small heal, or ~85 (Champion) for the large heal.
  2. Damage yourself (`player.damageav health 150` or take a hit) so the HP bar is low.
  3. Fire a death-duty: activate the QASmoke **Ash'abah duty** proof REFR (`prid XX<refid>` + `activate player`).
     Organic: an Ash'abah-coded undead/burial act.
  4. Damage yourself again and fire the death-duty **a second time the same day**.
- **See:** the **HP bar jumps** on the first rite of the day (the load-bearing Requiem check), scaling with
  Tu'whacca tier (Devoted ~30, Champion ~50). The **second same-day rite does NOT move the HP bar** (once/day).
- **[Dev] log:** `Redguard Tu'whacca death-rite heal fired ... tier=2 restore=30` / `tier=3 restore=50`, and on
  the repeat `... heal suppressed (already restored today)`.
- **Record:** ___

### Slot 4b -- Ash'abah stigma  [Tester] [R]+[M]
- **Do:** continue from 4a (origin 9, Ash'abah sect). Fire the death-duty proof REFR repeatedly.
- **See:** the first death-duty -> top-left notice "The mark of the death-duty settles on you..."; keep firing
  and at the 3rd act the band crosses to hollow-eyed -- "The tomb-smell never fully leaves you now...". Notices
  fire **only on a band crossing** (no per-act spam). Confirm the **Tu'whacca piety did NOT drop** from the
  stigma itself (text-only; the death-duty's own piety award is separate and positive).
- **[Dev] log:** `Redguard Ash'abah stigma marked ... stigma=1 (was 0)`, then `... stigma=3 (was 2)`.
- **Record:** ___

### Slot 4c -- HoonDing make-way  [Tester] [R]
- **Do:** make HoonDing the **active focused patron** (MCM select HoonDing + Force Piety ~30 so it is active;
  make-way gates on `_activeDeity == PDV_HoonDing`).
  1. Kill a **dragon** with your own killing blow (a wild dragon, or `player.placeatme` a dragon base then land
     the final hit). Kill a **second** dragon the same day.
  2. Kill one **V1 listed boss** with your own killing blow (a base in `PDV_FLST_HoonDing_BreakthroughBosses`).
  3. Negative: kill a generic **bandit/draugr**; and trigger a **Forebear road-passage** act.
- **See:** the dragon kill fires `HoonDing make-way fired: breakthrough dragon kill multiplier=1` and HoonDing
  piety rises; the 2nd same-day dragon soft-decays (~0.7, smaller award). The listed boss fires through the
  separate boss route. The **generic kill and the road-passage do NOT fire make-way** (road-passage routes to
  the Forebear lane / Leki; the old weekly-cap suppression line no longer appears).
- **Record:** ___

### Slot 4c2 -- HoonDing Champion low-health save  [Tester] [R]+[M]
- **Do:** HoonDing active, Champion tier, with `PDV_Bless_Redguard_HoonDing_T3` active. Drop below 20% Health.
  Then drop below 20% again the same day.
- **See:** the first low-health edge **saves the player once**; the same-day repeat does **not** save again
  (once/day, storage key `PDV.Capstone.LowHealthSave.HoonDing`).
- **Record:** ___

### Slot 4d -- sect Champion-entry chronicle (NEW Prisma beat)  [Tester] [R]+[M]
- **Do:** on a confirmed-sect Redguard, drive the sect's anchor deity to **Devoted+** (Crown/Ash'abah anchor
  Tu'whacca; Forebear anchors HoonDing). MCM Force Piety on the anchor, then re-sync rewards / Run Dawn.
- **See:** a sect-entry **toast/modal** ("The Crown way has become more than memory...") AND a **pinned Book of
  Days entry** for your sect:
  - Crown: *"The Crown way is more than memory in you now. It has become a public shape of your devotion."*
  - Forebear: *"The Forebear way is more than adaptation in you now. It has become a public shape of your devotion."*
  - Ash'abah: *"The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion."*
- **Check the Book of Days line is NOT blank** (before Unit D the sect-entry MESG had no chronicle; a blank line
  now = a wiring bug -> FAIL). Fires once per sect (`PDV.Redguard.ChampionEntryShown.<sect>`).
- **Record:** ___

### Slot 4e -- commitment offer ACCEPT (NEW Prisma beat)  [Tester] [R]+[M]
- **Do:** Redguard sect with **broad worship** active (no single named patron yet). Drive a qualifying deity to
  the commitment threshold (MCM Force Piety past the offer gate), then **Run Dawn** to trigger the formal offer.
  When the offer prompt appears, **accept** it (MCM Debug `Accept pending commitment` if the prompt path needs it).
- **See:** a **toast** -- *"You walk under {patron} now."* -- and a **pinned Book of Days entry** -- *"The
  sect's broad worship narrows to one charge. You took {patron} as your own."* ({patron} = the offered deity's name.)
- **Check the Book of Days line is NOT blank.** One offer per character; the cadence is one-offer / terminal.
- **Record:** ___

### Slot 4f -- commitment offer REFUSE (NEW Prisma beat)  [Tester] [R]+[M]
- **Do:** on a FRESH save (the offer is terminal -- accept and refuse cannot both be tested on one character),
  reach the same offer, then **refuse** it (MCM Debug `Refuse pending commitment` if needed).
- **See:** a **toast** -- *"You keep to the sect."* -- and a **pinned Book of Days entry** -- *"The sect's
  broad worship holds as it was. You set {patron}'s charge aside; {patron} will not ask again."*
- **Check the Book of Days line is NOT blank.** After a refuse, **{patron} never asks again** (Rupture set);
  confirm no second offer from that deity on a later dawn.
- **Record:** ___

### Slot 4g -- sect substrate act + Ledger driver  [Tester] [R]+[M]
- **Do:** on a confirmed-sect Redguard, do a **sect-coded act that matches your current sect** (Crown/Forebear/
  Ash'abah signal). Open the Devotion panel -> **Ledger** page.
- **See:** a **substrate toast** -- *"The Yokudan path was marked."* -- and the **Ledger shows a new driver row**
  for the act (the reorientation.redguard.sect / substrate path records through the reason-bearing ledger).
  No per-act Book of Days entry (chronicle is the sect SWITCH, not each act).
- **Record:** ___

### Slot 4h -- Ash'abah mid-game entry (named-undead flips sect)  [Tester] [R]+[M]
- **Do:** start a **Crown or Forebear** Redguard (do NOT start as Ash'abah; confirm the Survey sect line).
  - POSITIVE: land the player's **own killing blow on a UNIQUE/named undead** -- `player.placeatme` a Dragon
    Priest base (Krosis/Morokei) or a named lich, then kill it. Also test one unique hostile living humanoid in
    `NecromancerFaction` or `WarlockFaction`.
  - NEGATIVE: kill a **routine draugr/skeleton** (not Unique). Then a second same-day named-undead kill.
- **See:** the named-undead defeat fires `Redguard Ash'abah major burden fired` + the Ash'abah **sect-entry
  notice**, and the Survey sect line now reads Ash'abah (the death-rite heal + stigma also fire, shared rewards).
  The **routine draugr does NOT switch sect** (it stays Crown/Forebear); the second same-day named kill
  soft-decays (`...major burden decayed out for today`).
- **Record:** ___

### Slot 4i -- Ash'abah cleared-undead-site burden  [Tester] [R]+[M]
- **Do (play normally, no `coc`):** walk or fast-travel into an **approved uncleared** undead site (one of the
  43 entries in `PDV_FLST_RedguardAshAbahUndeadClearSites` -- draugr crypts, vampire lairs, dragon-priest lairs
  with `LocTypeClearable`), clear it, and leave if the final kill does not immediately trip the cleared state.
- **See:** `redguard_ashabah_burden_undead_site_clear` routes **once** for that site (sect/reward/stigma
  movement where eligible), then the site key is consumed. A **non-listed** clearable dungeon stays silent.
  Old-save guard: a site must have been observed while uncleared before it can pay.
- **Record:** ___

### Slot 5 -- wrong-origin rejection  [Dev] [R]
- **Do:** console `set PDV_GLO_OriginRace to 0` (Nord), then fire the **Ash'abah duty** proof REFR. Reset with
  `set PDV_GLO_OriginRace to 9` after.
- **See:** **nothing Redguard moves** -- no sect/stigma/heal, no Tu'whacca death-rite marker, the HP bar does
  not move. A non-Redguard origin can't drive Redguard-native state.
- **Record:** ___

### Slot 6 -- generic acts stay silent  [Tester] [R]
- **Do:** as a Redguard, do ordinary things that are NOT the coded hooks: kill a bandit, clear a **non-listed**
  clearable dungeon, pay a bounty, generic combat.
- **See:** **none of these score** the Redguard sect/stigma, fire make-way, or grant Ash'abah cleared-site
  credit (only the real coded acts do).
- **Record:** ___

### Slot 7 -- how it felt  [Tester] [M]
- **Do/Write:** 1-2 sentences. Does the **Tu'whacca death-rite heal** FEEL real (HP visibly restored) where
  before it was an invisible regen %? Does the **Ash'abah stigma** read as an earned social weight (not a
  punishment)? Does **HoonDing make-way** feel like a marked breakthrough (a dragon falling), not a road-walk
  toggle? Do the **offer accept/refuse** and the **sect Champion-entry** read as one-time character milestones?
  Note any magnitudes that felt off (for tuning: Tu'whacca 30/50, HoonDing decay).
- **Record:** ___

---

## Prisma surfaces (Redguard beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| tier Seeker/Devoted/Champion | Y | Y (pinned Champion) | N | Force patron piety + Run Dawn |
| sect Champion-entry (Crown/Forebear/Ash'abah) | **Y** | **Y (pinned)** | N | anchor deity to Devoted+ on a confirmed sect |
| sect switch (reorientation.redguard.sect) | Y | Y (next dawn snapshot) | N | sect signal / named-undead flip |
| sect substrate act (substrate.act.sect.redguard) | **Y** | N | **Y (driver)** | sect-coded act matching current sect |
| offer.accept | **Y** | **Y (pinned)** | N | accept the formal commitment offer |
| offer.refuse | **Y** | **Y (pinned)** | N | refuse the formal commitment offer (fresh save) |
| Tu'whacca death-rite heal | Y (notice) | N | per substrate | death-duty rite, Tu'whacca tier |
| Ash'abah stigma | Y (band crossing) | N | N | repeated death-duty acts |
| HoonDing make-way | N (piety pulse) | N | per substrate | dragon / listed-boss kill, HoonDing active |
| neglect / dawn digest / curse | Y | Y | per universal | see the Universal Prisma sheet |

---

## Known gotchas
- **HP-bar proof needs a Requiem list.** Under vanilla regen the death-rite heal still adds flat HP, but the
  POINT is that it works where a HealRateMult would be swallowed -- prove it under the actual Authoria/Requiem
  load order.
- **Tu'whacca heal is once/day** (`PDV.Redguard.TuwhaccaDeathRiteHealDay`). Damage yourself before each test; a
  second same-day rite logs "suppressed".
- **Make-way needs HoonDing ACTIVE** (`_activeDeity == PDV_HoonDing`). A HoonDing-patron Redguard; otherwise
  dragon kills do not fire make-way (by design). V1 make-way = dragons plus the conservative named-boss FormList.
- **Stigma is text-only.** It builds per death-duty act (caps at 5), notice only on a band crossing, does NOT
  decay, and applies **NO piety penalty**. The Survey stigma LINE only shows for an Ash'abah-sect player -- so
  start as Ash'abah to see both the line and the notice.
- **Sect Champion-entry chronicle is NEW (Unit D).** Before Unit D the sect-entry MESG fired with NO Book of
  Days line. It must now write a pinned chronicle entry -- a blank line is the wiring bug to FAIL.
- **The commitment offer is one-shot and terminal.** Accept and refuse cannot both be tested on one character;
  use a fresh save for the refuse path. After a refuse the deity never asks again (Rupture).
- **The Far Shores token test is DEFERRED to V2** -- it is intentionally NOT in this sheet. Do not test a Far
  Shores token rite here.
- **Mid-game Ash'abah entry needs a UNIQUE/named undead** (`ActorBase.IsUnique`) -- lich, Dragon Priest, named
  draugr overlord, or a unique hostile necromancer/warlock. Routine draugr/skeletons are not Unique, so casual
  undead fighting cannot switch sect.
- **Ash'abah cleared-site credit is armed while uncleared.** Enter/visit the approved location before it is
  cleared, then clear it -- existing saves don't get retroactive credit.
- **`coc` skips location triggers.** Walk or fast-travel into cells for any location-anchored Redguard act
  (cleared-site burden especially); do not `coc` straight in.
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Slot | What it proves | Status | Note |
|---|---|---|---|
| 1 new records | script/record hooks + sect-entry MESGs exist; no new mesh | | |
| 2 Survey | Ash'abah sect + stigma line legible | | |
| 3 stack | Tu'whacca ward, no rogue Health-Regen aura; HoonDing stat reward | | |
| 4a Tu'whacca death-rite heal | HP bar moves; tier 30/50; once/day | | |
| 4b Ash'abah stigma | builds + band-crossing notice; NO piety drop | | |
| 4c HoonDing make-way | dragon/listed boss fires; generic/road negative | | |
| 4c2 HoonDing Champion save | low-health save fires once/day | | |
| 4d sect Champion-entry chronicle | toast + pinned BoD per sect, non-empty | | |
| 4e offer.accept | "You walk under X now." + pinned BoD, non-empty | | |
| 4f offer.refuse | "You keep to the sect." + pinned BoD; never asks again | | |
| 4g sect substrate act | toast + Ledger driver row | | |
| 4h Ash'abah mid-game entry | named undead flips sect; routine undead do not | | |
| 4i Ash'abah cleared-undead site | approved newly-cleared site pays once; non-listed silent | | |
| 5 wrong-origin | Nord origin: zero Redguard movement | | |
| 6 generic silence | generic kills/non-listed clears/bounty do not score | | |
| 7 felt | heal/stigma/make-way/offer read as earned | | |

Owner, after the run: capture the Papyrus + `DevotionPrismaBridge` logs and record into
`PDV_V1_BetaReadinessGate.md`. Don't mark Redguard `pass` until every row is filled.
