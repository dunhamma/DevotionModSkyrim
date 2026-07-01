# PDV In-Game Run-Sheet -- Daedric Princes (V1, 16-Prince group)

Status: V1 (Unit D Prisma live `5e9e502`; 16 epithet titles = title author-run this pass). Created 2026-06-25.
Pair with `PDV_RunSheet_Universal_Prisma_V1.md`. Sources: `PDV_AllRaceDaedricBetaReadinessLedger.md`,
`PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md` (the 16 titles + Hircine beats).

**How to read this sheet.** Each test is **Do / See / Record**. Tags: **[Tester]** = play/click; **[Dev]** =
console or log check. The Daedric path is **separate from patron worship and mutually exclusive** -- you
commit to a Prince OR a patron, never both. You can run this on any race (no origin gate); a couple of
Princes have a curse/race flavor noted inline.

The 16 Princes: Azura, Boethiah, Clavicus Vile, Hermaeus Mora, Hircine, Malacath, Mehrunes Dagon, Mephala,
Meridia, Molag Bal, Namira, Nocturnal, Peryite, Sanguine, Sheogorath, Vaermina.

---

## Preflight (do once)
1. **New save** (or `coc qasmoke`). **Anvil** instance; `Devotion - Living Deities Test` disabled.
2. Console: `set PDV_GLO_DebugLevel to 2`. (Daedric paths don't need an origin seed -- any race can walk a path.)
3. Seeds = **MCM -> Devotion -> Developer Options**: the Daedric controls (force a Prince's stored piety,
   fire a controlled Daedric signal, accept/decline a Champion offer, renounce a path).

## Running in Authoria (Requiem) -- same steps, swap the preflight
Same tests + surfaces. Use the **Authoria** instance; **skip** the Living-Deities disable. **One real
difference:** Daedric **shrine prayers** route through the **ARR/Requiem shrine** records (the shrines revert
to Requiem's own with the same FormIDs) -- so in Authoria, pray at the actual Requiem Daedric shrine; the beat
is the same, the shrine object differs.

---

## Tests

### D1 -- pre-pact "a Prince takes notice"  [Tester] [R]+[M]
- **Do:** pick a Prince you have NOT committed to. MCM Debug -> push its stored piety to about **half of
  Seeker** (a pre-pact build), while you have no active patron/pact. Open the **Ledger**.
- **See:** the Prince shows as a **"watching"** row in the Ledger (pre-pact visible -- this used to be
  invisible), and once it crosses the notice threshold a **Book of Days** entry fires *"The world tilts
  toward {Prince}."* It fires **once** (won't spam).
- **Record:** ___

### D2 -- shrine prayer (daily)  [Tester] [R]+[M]
- **Do:** pray at the Prince's shrine (Authoria: the Requiem shrine). MCM Debug can fire the controlled
  prayer signal if you can't reach one.
- **See:** a **toast**, a small **piety** rise (+~2), and a **Ledger driver** row ("Daedric prayer"). Pray
  again the same day -> capped (no double award).
- **Record:** ___

### D3 -- milestone Seeker / Devoted / Champion  [Tester] [R]+[M]
- **Do:** MCM Debug -> raise the Prince's stored piety across **Seeker (~25)**, **Devoted (~50)**, then
  **Champion (~85)**.
- **See:** at EACH step the Prince's milestone fires on all three spaces -- a **toast** (carrying the
  boon/price flavor), a **Book of Days** entry, and a **Ledger** driver. At **Champion** a **blocking
  Accept / Decline** message appears (the pact/champion offer) and its Book of Days entry is **pinned**.
  Check the Book of Days lines are **not blank**.
- **Record:** ___

### D4 -- the 16 offer titles (new this V1)  [Tester] [M]
- **Do:** reach the Champion offer for a few different Princes (D3) so their **offer message** shows. (The
  16 epithet titles were authored into the offer MESGs this pass.)
- **See:** the offer pop-up **TITLE names the Prince** in voice -- e.g. *Mephala's Web*, *Molag Bal's Grip*,
  *Sheogorath's Madness*, *Azura's Twilight*. The body is unchanged. Spot-check 3-4 Princes.
- **Record:** ___

### D5 -- commitment gate  [Tester] [R]+[M]
- **Do:** accumulate the Prince's commitment signals (the 3rd commitment-class act opens the pact gate;
  varies by Prince -- Hircine hunt rites, summoning, shrine prayers).
- **See:** on the 3rd, a **blocking commitment message** opens the pact. No piety jump from the gate itself
  (that belongs to the signals).
- **Record:** ___

### D6 -- Champion accept / decline  [Tester] [R]+[M]
- **Do:** at the Champion offer (D3), choose **Decline** once, then on another Prince choose **Accept**.
- **See:** **Decline** reverts piety to just below Devoted (a **Ledger** driver records it; no toast/chronicle
  -- intentional). **Accept** seals the pact (becomes your active commitment; a patron, if you had one, is severed).
- **Record:** ___

### D7 -- lapse (decay to nothing)  [Tester] [R]+[M]
- **Do:** on an active pact, drive the Prince's piety to **0**; Run Dawn.
- **See:** a **"the hold breaks / neglect"** toast + a **Book of Days** entry; the Ledger shows the drop.
- **Record:** ___

### D8 -- Hircine specials  [Tester] [R]+[M]  (run on a Hircine path)
- **Do (a):** become a **werewolf** while on the Hircine path.
  **See:** the race-response message (toast) **and** a new **Book of Days** entry *"The beast-blood took you
  and stirred Hircine. The Hunt is in you now."* (this chronicle was added in Unit D -- confirm it's not blank).
- **Do (b):** **renounce** the Hircine path (MCM Debug / RenouncePath).
  **See:** the exit message, a Prisma toast *"You renounce the hunt."*, and a pinned **Book of Days** entry:
  *"You set the hunt down. The pact with Hircine is renounced -- the beast's mark fades slowly, but the road
  back is yours to walk."*
- **Do (c):** cure the werewolf curse -> **residue** onset.
  **See:** a **residue** toast at onset (renderer was built; producer wired in this pass).
- **Do (d):** during a hunt rite, push **stigma** past its thresholds.
  **See:** a **stigma price** toast (toast-only by ruling R6 -- no chronicle yet, that's intentional).
- **Record:** ___

### D9 -- Daedric "boon" (rite answered)  [Tester] [M]
- **Do:** complete a Prince's rite (the per-rite "answered" beat, analogous to a substrate deepen).
- **See:** a **boon** toast *"{Prince} is satisfied / The rite was answered."* (renderer was built; producer
  wired this pass).
- **Record:** ___

### D10 -- how it reads  [Tester] [M]
- **Do/Write:** 1-2 sentences. Do the Prince beats read in-voice and distinct per Prince? Do the **titles**
  land? Does a pre-pact Prince feel like it's *watching* (Ledger) before you commit? Any blank line, double-fire,
  or wrong-surface beat?
- **Record:** ___

---

## Prisma surfaces (Daedric beats -- confirm each renders)
| Beat | Toast | Book of Days | Ledger | How to trigger |
|---|---|---|---|---|
| pre-pact watching / "takes notice" | N | Y (once) | **Y (watching row)** | half-Seeker piety, no pact |
| shrine prayer | Y | N | Y (driver) | pray daily |
| milestone Seeker/Devoted/Champion | Y | Y (pinned Champion) | Y (driver) | raise stored piety past each |
| commitment gate | Y (msg) | N | N | 3rd commitment signal |
| Champion decline | N | N | Y (driver) | decline the offer |
| lapse | Y | Y | (drop) | piety -> 0 + Run Dawn |
| Hircine curse-entry | Y (msg) | **Y (new)** | N | become werewolf on Hircine path |
| Hircine renunciation | Y (msg + toast) | **Y (pinned)** | (drop) | renounce |
| Hircine residue | Y (new) | N | N | cure the curse |
| Hircine stigma-price | Y | N (by R6) | N | hunt-rite stigma threshold |
| Daedric boon | Y (new) | N | N | complete a rite |
| 16 offer titles | (title) | -- | -- | the Champion offer message |

---

## Known gotchas
- **Prince OR patron, never both.** Committing to a Prince severs an active patron (and vice-versa). Use a
  fresh save to test a clean pre-pact path.
- **Pre-pact piety was historically invisible in the Ledger.** D1's "watching" row + the once-fire notice are
  the fix -- if the Ledger stays empty pre-pact, FAIL.
- **Champion offer is a BLOCKING message.** If it fires while the MCM is open it defers (replay) -- close the
  MCM to see it.
- **Authoria:** Daedric shrine prayers use the Requiem shrine records (same beat).
- **Blank Book of Days line = a wiring bug** -> FAIL (esp. the new Hircine + milestone "PLACEHOLDER" copy).
- **MCM Debug page, not `cqf`.**

---

## Record results here
| Test | What it proves | Status | Note |
|---|---|---|---|
| D1 pre-pact watching | Ledger watching row + once-fire notice | | |
| D2 shrine prayer | toast + piety + Ledger driver; daily cap | | |
| D3 milestones | toast+BoD+Ledger each tier; Champion pinned + offer | | |
| D4 16 titles | offer titles name the Prince in voice | | |
| D5 commitment gate | 3rd signal opens the pact | | |
| D6 accept/decline | accept seals (severs patron); decline reverts + Ledger | | |
| D7 lapse | toast + BoD + Ledger drop | | |
| D8 Hircine specials | curse-entry + approved renounce chronicle/toast; residue + stigma toasts | | |
| D9 boon | rite-answered toast | | |
| D10 reads | in-voice, distinct, titles land, no blank/double | | |

Owner: capture the Papyrus + `DevotionPrismaBridge` logs, record into `PDV_V1_BetaReadinessGate.md` and the
Daedric runtime evidence ledger. (The 16-Prince runtime gate may finish during the beta.)
