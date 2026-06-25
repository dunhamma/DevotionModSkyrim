# PDV In-Game Run-Sheet -- Argonian (V1)

Status: V1 (Unit D Prisma live `5e9e502`; Hist potion = NEW build item this pass). Created 2026-06-25.
Provenance: `PDV_PreBetaRaceGateLedger.md` (Argonian deferred: Hist/People/Void hook proof outside QASmoke,
Survey display), `PDV_PrismaParityRegistry.csv` + `PDV_PrismaParity_AuthoringDraft.md` (Prisma beats),
the run-sheet format of `PDV_RunSheet_Redguard_BetaFeel.md`. Pair with `PDV_RunSheet_Universal_Prisma_V1.md`.

Tests the Argonian closed cosmology -- **Hist** relation, **People/community**, **Sithis/Void** -- plus the
new Prisma surfacing: the **Hist-Adaptation milestone** beat, **Hist-posture** shifts, the **shadowscale /
posture-dream** flavor toasts, and substrate acts landing **Ledger drivers** (the scaled-curated P0 fix).
The headline new item is the **Hist sap potion**: consumed to receive Hist piety, it re-adds itself to
inventory immediately so the player always keeps it.

---

## Proof-boundary key
- **[R] ROUTE/RUNTIME** -- Papyrus log marker / numeric move / a beat rendered on screen. Objective.
- **[M] MANUAL-ACCEPTANCE** -- tester judgment (reads as earned; legible; potion-loop feels right).
Do not mix them in the ledger; do not mark a race-level `pass` from this sheet.

## Preflight (do once)
- New disposable save (or `coc qasmoke`). Argonian state inits only on a NEW save. **Anvil** instance.
- MO2: DISABLE `Devotion - Living Deities Test`.
- Console seed:
  ```text
  set PDV_GLO_OriginRace to 7
  set PDV_GLO_DebugLevel to 2
  ```
  Origin index `7` is Argonian.
- Debug seeding is the **MCM Debug page** (Player -> Developer Options), NOT `cqf`. Substrate seed action:
  `DebugSeedArgonian(hist, people, void)` (e.g. hist 90 / people 90 / void 0 for a strong Hist build).
- Papyrus log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- Hist posture labels: Normal / Distant / Strained / Silenced / Corrupted (`GetArgonianHistPostureLabel`).

---

## Ordered evidence checklist

### Slot 1 -- assetStatus ([M], desk check)
- **NEW this V1:** the Hist sap potion is a new `ALCH` record (`PDV_Potion_ArgonianHistSap`) + its
  magic-effect/script; it replaces the old reusable BOOK token. Confirm the potion record exists and is
  granted on Argonian race-confirm (`EnsureArgonianHistSapToken` rework). No new mesh required (reuses a
  vanilla potion model). All other Argonian hooks are script + existing-record.
- PASS: the Hist potion record + grant exist; no other Argonian hook needs a new asset.

### Slot 2 -- surveyStatusClarity ([M])
- Seed: origin 7; `DebugSeedArgonian 90 60 0`; select Hist as primary, `Apply target piety` ~85 (Champion).
- Open Survey Devotion. The Argonian lines read the closed cosmology in narrator voice: Hist relation depth,
  People/community standing, Sithis/Void state, and the **Hist posture** readout when not Normal.
- PASS: Hist/People/Void + posture read in plain narrator voice; no raw enum/counter leaks; posture line
  appears only when posture != Normal.

### Slot 3 -- stackSnapshot ([R] numeric + [M] read)
- Hist Champion build. Active Effects shows the Hist reward layer; no rogue/duplicate auras; no cross-mode
  bleed. `player.getav Health`/relevant AV is the baseline (note for any Requiem HP-bar reward check).
- PASS: Hist stack is the expected reward layer only; no rogue aura; magnitudes within the costing ceiling.

### Slot 4 -- immersiveHookProof (Argonian core)

**4a. Hist sap potion -- the new ritual loop ([R] + [M]):**
- Seed: origin 7; confirm the **Hist sap potion** is in inventory (granted on race-confirm).
- Consume the potion (Inventory -> drink). Watch: Hist substrate **piety rises** (Ledger driver + log
  marker for the Hist award), and the **potion re-appears in inventory immediately** (count stays >= 1) --
  it is infinite-use. A substrate toast may fire ("act"/"deepen").
- Anti-farm: consume again the same day -> the Hist award is capped (once/day or soft-decay per the
  substrate cap); the potion still re-adds itself, but the piety does not re-award uncapped.
- PASS: consuming awards Hist piety AND the potion returns to inventory; the award respects its daily cap.

**4b. Hist substrate maintenance -- hook proof OUTSIDE QASmoke ([R]):**
- Organic (the deferred-placement proof): near-water maintenance, rest cadence, people/community acts in
  NORMAL play (walk/fast-travel to water, sleep, etc. -- `coc` skips location hooks). Watch the substrate
  log markers + the Ledger drivers. This is the "Hist/People/Void hook proof outside QASmoke" the gate needs.
- PASS: Hist water/rest, People/community, and a Void/death-change act each fire their marker + Ledger
  driver in normal play (not just via the QASmoke sender).

**4c. Hist-Adaptation milestone -- NEW Prisma beat ([R] + [M]):**
- Seed: meet the adaptation gate (`TryArgonianAdaptationRite`) and take the permanent body-reshaping choice
  (`ApplyArgonianAdaptation`).
- Watch: a **toast** `The Hist has reshaped you.` + a **pinned Book of Days** entry `You took the Hist's
  adaptation into your body. The change is permanent -- the root has answered, and you are remade in its
  image.` (Before Unit D this was Debug.Notification-only.) The guard makes it once/permanent.
- PASS: the adaptation fires the toast + the pinned BoD beat once; the BoD line is non-empty.

**4d. Hist-posture shift ([R] + [M]):**
- Seed: drive a posture change (piety-loss / curse / `DebugSeedArgonian` toward Distant/Strained/Corrupted),
  `RefreshArgonianHistPosture`.
- Watch: a **shift toast** with the new posture label; at next dawn the **Book of Days** captures the posture
  change (mode-snapshot). Corrupted/Distant additionally emit a piety-loss signal (separate Ledger driver).
- PASS: posture shift toasts immediately; the dawn Chronicle records it; Corrupted/Distant also drain piety.

**4e. Shadowscale / posture-dream flavor ([M]):**
- Shadowscale Veil: meet the Void+people thresholds (`HandleArgonianShadowscaleVeilActivation`) -> a
  `shadowscale` flavor toast, no piety. Posture dream: on a strong posture roll
  (`EmitArgonianPostureDream`) -> a posture-keyed `dream` flavor toast, no piety.
- PASS: both fire as pure flavor toasts (no piety move, no Ledger driver) and read in-voice.

### Slot 5 -- wrongOriginRejection ([R])
- `set PDV_GLO_OriginRace to 0` (Nord). Fire an Argonian substrate seed/act. Watch: NO Hist/People/Void
  movement; no Argonian markers. Reset `set PDV_GLO_OriginRace to 7`.

### Slot 6 -- genericHookRejection ([R], negative class)
- Origin 7. Spot-check the rejected-hook list: generic swimming loops, standing in water forever, ordinary
  travel, generic inn sleep, same-bed repetition, generic stealth, ordinary kills, one Dark Brotherhood join
  as full Sithis activation -> NONE score Hist/People/Void.
- PASS: generic acts stay silent; only the coded Hist/People/Void hooks score.

### Slot 7 -- manualFeelNote ([M])
- 1-2 sentences: does the Hist potion ritual loop feel good (drink -> Hist answers -> you keep the vial)?
  Does the Hist-Adaptation read as a permanent, earned remaking? Do posture shifts read as the Hist drawing
  near/away rather than a debuff counter? Record any magnitudes that felt right.

---

## Prisma surfaces (Argonian beats -- verify each renders)
| Beat | Toast | Book of Days | Ledger | Trigger | Expected line / note |
|---|---|---|---|---|---|
| tier.seeker/devoted/champion | Y | Y (pinned Champion) | N | force Hist piety + dawn | universal tier copy |
| substrate.act.hist (Hist potion / water / rest / people) | Y | N | **Y** (driver) | consume potion / organic maintenance | P0 fix: scaled-curated now records a Ledger driver |
| rite.argonian.hist-adaptation | **Y** | **Y (pinned)** | N | ApplyArgonianAdaptation | "The Hist has reshaped you." / "...remade in its image." |
| reorientation.argonian.hist-posture | Y | Y (dawn) | N | RefreshArgonianHistPosture | posture label; Corrupted/Distant also drain (separate driver) |
| substrate.shadowscale | Y | N | N | Void+people thresholds | flavor only, no piety |
| substrate.posture-dream | Y | N | N | strong posture roll | flavor only, no piety |
| neglect.drop / dawn digest / curse | Y | Y | (per universal) | see Universal sheet | run the Universal Prisma sheet alongside |

---

## Known gotchas
- **Hist potion must self-replenish.** The load-bearing check is that the vial returns to inventory on
  consume (infinite-use). If the count drops to 0, the build is wrong -- FAIL.
- **Substrate Ledger driver is the P0 regression.** Argonian substrate routes through
  `AwardCuratedSignalScaled`; pre-fix it recorded NO driver. Confirm the Ledger now shows the substrate driver.
- **Hist-Adaptation is permanent + once.** `TryArgonianAdaptationRite` gates it; you cannot re-run it on the
  same character to re-test -- use a fresh save.
- **`coc` skips location triggers.** Walk/fast-travel to water/rest sites for the organic Hist hook proof.
- **Posture chronicle is dawn-snapshot.** The toast is immediate; the Book of Days entry lands at the next dawn.
- **MCM only, not cqf.**

---

## Record results here
Allowed: PASS / FAIL / PENDING / N-A. Label the proof class.

| Slot | Surface | Proof | Status | Note |
|---|---|---|---|---|
| 1 assetStatus | Hist potion record + grant exist | [M] | | |
| 2 surveyStatusClarity | Hist/People/Void + posture legible | [M] | | |
| 3 stackSnapshot | Hist reward layer; no rogue aura | [R]+[M] | | |
| 4a Hist potion loop | consume awards Hist piety + vial returns; daily cap | [R]+[M] | | |
| 4b Hist maintenance hook proof | water/rest/people/void markers + drivers in normal play | [R] | | |
| 4c Hist-Adaptation beat | toast + pinned BoD, non-empty, once | [R]+[M] | | |
| 4d Hist-posture shift | shift toast + dawn chronicle; Corrupted drains | [R]+[M] | | |
| 4e shadowscale / dream | flavor toasts, no piety | [M] | | |
| 5 wrongOriginRejection | Nord origin: zero Argonian movement | [R] | | |
| 6 genericHookRejection | generic swim/sleep/kill do not score | [R] | | |
| 7 manualFeelNote | potion loop + adaptation feel earned | [M] | | |
| Prisma surfaces table | all Argonian beats render on expected surfaces | [R]+[M] | | |

After the run: capture the Papyrus + `DevotionPrismaBridge` logs, record into `PDV_V1_BetaReadinessGate.md`
honoring the proof boundary. Do NOT mark Argonian `pass` from this sheet alone.
