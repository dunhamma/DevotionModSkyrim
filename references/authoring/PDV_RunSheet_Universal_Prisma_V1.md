# PDV In-Game Run-Sheet -- Universal Prisma Surfaces (V1)

Status: V1 (Unit D live, commit `5e9e502`). Created 2026-06-25.
Provenance: `PDV_PrismaParityRegistry.csv`, `PDV_PrismaParity_AuthoringDraft.md` (locked copy),
`PDV_PrismaParity_DecidedWorklist.md`. Mirrors the run-sheet format of `PDV_RunSheet_Redguard_BetaFeel.md`.

Run this ONCE per character, alongside any per-race sheet. It proves the cross-race Prisma surfaces --
the three spaces (Toast / Book of Days / Ledger) and the panel itself -- that every race shares. Per-race
beats live in each race's `## Prisma surfaces` section; this sheet is the common floor.

---

## Proof-boundary key
- **[R] ROUTE/RUNTIME** -- a Papyrus log marker / numeric move / a beat actually rendered on screen. Objective.
- **[M] MANUAL-ACCEPTANCE** -- tester judgment ("reads clearly", "felt earned", legible over a busy background).
Do not mix them in the ledger; do not mark a race-level `pass` from this sheet.

## Preflight (do once)
- New disposable save (or `coc qasmoke`). Surfaces + panel state init only on a NEW save.
- MO2: DISABLE `Devotion - Living Deities Test`. Use the **Anvil** instance.
- Console seed: `set PDV_GLO_OriginRace to <index>` (per the race you're pairing with) and `set PDV_GLO_DebugLevel to 2`.
- Debug seeding is the **MCM Debug page** (Player -> Developer Options), NOT `cqf`. Console `set`/`coc` allowed.
- Papyrus log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- The three spaces: **Toast** = transient overlay; **Book of Days** = the modal Chronicle (page 0);
  **Ledger** = the modal "what feeds your gods" (page 1, sortable per-god driver rows).

---

## Ordered evidence checklist

### Slot U1 -- panel open / focus / ESC ([R] + [M]) -- the cold-view trap
- From a COLD game state (first open this session), open the Devotion panel via its MCM/hotkey.
- Watch: it opens **populated and focused** (not an empty focused overlay), and **ESC always releases** --
  both ESC and the in-view X return control. Re-open; switch Chronicle <-> Ledger pages; ESC again.
- PASS: the panel never traps input on a cold/first open; ESC always escapes; `DevotionPrismaBridge.log` clean.

### Slot U2 -- tier-up Seeker / Devoted / Champion ([R] + [M])
- Seed: MCM `Apply target piety` to the active patron at ~25 (Seeker), ~50 (Devoted), ~85 (Champion);
  run dawn (MCM Run Dawn / `ProcessDawn`) after each.
- Watch each crossing: a **toast** ("Devotion deepens / names you ..."), a **Book of Days** entry, and on
  **Champion** the BoD entry is **pinned** (survives the day-window prune). Ledger = no driver from the
  tier-up itself (it's a derived threshold, not an award).
- PASS: each tier fires a toast + a BoD entry; Champion's BoD entry is pinned; no duplicate on re-cross.

### Slot U3 -- routine favor + dawn digest ([R] + [M])
- Seed: award the active patron a curated signal (MCM) so the day has activity; then run dawn.
- Watch: per-act, the **active patron's** favor fires a toast (non-patron stays quiet); at dawn a **"dawn"**
  toast + a **Book of Days digest** line naming up to 3 gods fed that day. No per-act Chronicle spam.
- PASS: active-patron favor toasts; the dawn digest names the fed gods once; non-patron favor is quiet.

### Slot U4 -- Ledger "what feeds your gods" + the scaled-curated driver fix ([R] + [M])
- Open the panel -> **Ledger** page. After awarding a few signals, confirm driver rows appear per god
  (reason + count + net + direction), sortable by god/reaction.
- **P0 regression check:** award a SCALED curated/substrate signal (e.g. a substrate act for the paired race).
  The Ledger row MUST now show a driver for it (the `AwardCuratedSignalScaled` reason fix). Before the fix
  these were invisible -- confirm they now land.
- PASS: the Ledger shows driver rows for awards INCLUDING scaled curated/substrate signals; a pre-pact
  Daedric "watching" row shows if a Prince is building.

### Slot U5 -- Book of Days page + prune ([R] + [M])
- Open the panel -> **Chronicle** (Book of Days). Confirm milestone beats appear (tier-ups, curse, neglect,
  reorientation, offers) in narrator voice, with the right symbol per god.
- Prune: advance ~22+ in-game days. **Unpinned** entries older than the 21-day window drop; **pinned**
  (Champion / curse / reorientation / offer) survive.
- PASS: beats read clearly with correct symbols; unpinned old entries prune; pinned milestones persist.

### Slot U6 -- neglect drop ([R] + [M])
- Seed: drive the active patron's piety to 0; run dawn (the neglect consolidation).
- Watch: a **"neglect"** toast + a Book of Days entry that the rite has gone quiet. (Recovery is the known
  dawn-snapshot beat; surfacing it immediately is post-V1.)
- PASS: the neglect drop toasts + journals once on first lapse, not per-dawn after.

### Slot U7 -- manualFeelNote ([M])
- 1-2 sentences: do the three spaces read as one coherent record (the same beat uses the same symbol/voice
  across toast + Chronicle + Ledger)? Do toasts read over a busy game background? Any beat that fired on the
  wrong surface, double-fired, or rendered blank (the suffix/token trap)?

---

## Known gotchas
- **Blank journal line = the suffix/token trap.** If a beat toasts but its Book of Days line is empty, the
  tone key didn't resolve to an arm -- record it as a FAIL, not a pass.
- **`coc` skips location triggers.** Walk/fast-travel in for any location-anchored beat.
- **New save** -- panel/surface state and VMAD props bake at first init.
- **Champion pins; Seeker/Devoted don't.** Khajiit's champion was the one historic non-pin (fixed Unit-D-era) -- spot-check it pins now.
- **MCM only, not cqf.**

---

## Record results here
Allowed: PASS / FAIL / PENDING / N-A. Label the proof class.

| Slot | Surface | Proof | Status | Note |
|---|---|---|---|---|
| U1 panel/focus/ESC | cold open, ESC always releases | [R]+[M] | | |
| U2 tier-up | Seeker/Devoted/Champion toast + BoD; Champion pinned | [R]+[M] | | |
| U3 favor + dawn digest | active-patron toast; dawn digest names gods | [R]+[M] | | |
| U4 Ledger + scaled-curated fix | driver rows incl. scaled substrate; watching row | [R]+[M] | | |
| U5 Book of Days + prune | beats legible; unpinned prune, pinned persist | [R]+[M] | | |
| U6 neglect drop | toast + BoD once on first lapse | [R]+[M] | | |
| U7 manualFeelNote | three spaces coherent; no blank/double/wrong-surface | [M] | | |

After the run: capture the Papyrus + `DevotionPrismaBridge` logs, record into the V1 beta-readiness gate
(`PDV_V1_BetaReadinessGate.md`) honoring the proof boundary. Do NOT mark any race `pass` from this sheet alone.
