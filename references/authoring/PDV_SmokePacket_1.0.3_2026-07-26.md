# Devotion 1.0.3 — smoke packet (2026-07-26 rebuild)

Run on a **fresh save**, on the rebuilt zip. The Papyrus surface changed
substantially since the first 1.0.3 packet (the DrHeisen port landed), so this
supersedes it — re-run the whole thing, not just the new rows.

**Setup**
1. Fresh save, 1.0.3 installed, **restart Skyrim** so the rebuilt `.pex` load.
2. **Unlock the debug pages** — there is no in-game toggle. In the console:
   `set PDV_GLO_DebugLevel to 3` (any value >= 1 unlocks; 3 also gives the
   verbose traces the classification probes need). Then **close and re-open the
   MCM** — SkyUI only rebuilds the page list on open. `Debug: State & Rewards`
   and `Debug: Pacing & Pantheons` appear. `set PDV_GLO_DebugLevel to 0` hides
   them again.
3. Confirm the debug page shows the quest-reaction queue **idle** before any
   sitting (a busy queue leaks toasts that look like boon bugs).
4. Version line should read 1.0.3.

Console: press `~`, type `player.getav <value>`, Enter. `player.getavinfo
<value>` additionally splits base / modifiers / damage.

---

## GATE 1 — stat drift is dead (the Recover fix)

The release gate. Proves an apply→remove cycle returns to baseline exactly.

**Correction (2026-07-26):** Use these steps instead of the generic four
steps below. On a throwaway save, MCM → **Debug: State & Rewards** →
**Disfavor (dislikes)**: cycle the domain to `4 WarHonor`, set the band to
`Light`, and use **Apply domain sting**. Record the actual player's non-zero
`player.getav onehanded` baseline; do not use `modav` to manufacture one.
The applied sting must reduce that value by `3`, show **Honor recoils for a
while** under Active Effects, and return exactly to baseline after **Clear
active disfavor**. Repeat 3-4 times. Gate 1 is not race-specific: the
**Curse proof race** control only rewrites PDV's stored origin, so it cannot
provide a Breton racial Magic Resist baseline. An unchanged value while the
Active Effect is visible is a FAIL: verify every `PDV_MGEF_Disfavor_*` record
has `NoDuration` and every parent Ability effect has `Duration = 0`, because
the manager owns the expiry timer.

**A3 resolved (2026-07-26):** `Detrimental` supplies the penalty behavior, so
the stored magnitude must be positive. The expected result is a value going
**DOWN**; an increase is a failure. This supersedes the older open-decision
note below.

**A3 APPLIED (2026-07-26, in the 20260726 zip).** All 22 `Detrimental` records
now carry positive magnitudes — your 14 disfavor flips, plus the 8 finished
afterwards: `Neglect_Kyne` 8, `Neglect_Tsun` 15, `Neglect_{Shor,Stuhn,Talos,
Arkay,Dibella}` 5, and `PDV_Bless_Redguard_Spine_AshAbah` `Effects[2]` 5.
⚠ **WarHonor cannot detect this bug class** — it was already positive before the
flip. To actually exercise it, also run a **Kyne or Talos neglect** case (MCM →
`Prime neglect eligible` / `Run neglect pass` with that patron active) and
confirm the value moves DOWN. The 60 non-`Detrimental` negative-magnitude spells
(9 race neglects, 45 Daedric prices, 4 Breton creed losses) are the other valid
convention and were deliberately left alone.

1. `player.getav magicresist` — record the baseline.
2. MCM debug → **Apply domain sting** → `getav` again (penalty applied).
3. **Clear active disfavor** → `getav` — must be **exactly** baseline.
4. Repeat 3–4 times. Pre-1.0.3 each cycle walked further negative.

**Also record the DIRECTION in step 2** — this is the open A3 decision:
- value goes **DOWN** → stings penalize correctly, nothing further to do.
- value goes **UP** → the `Detrimental` + negative-magnitude pairs are applying
  as buffs; the ~21-record magnitude flip ships before release.

## GATE 2 — curse block

Uses **Curse proof race** (cycle) + **Apply proof race**, then **Curse
werewolf / vampire / none**.

- **Music:** in a safe interior, **Curse werewolf** → one short sting, then
  normal music. No persistent dungeon-music takeover; walk in/out to confirm.
  **Curse none** → cure sting, normal music.
- **Instant restore:** proof race → Redguard. `player.getav magicresist`,
  **Curse werewolf**, **Curse refresh** → penalty present. **Curse none** →
  `getav` **immediately**; penalty must lift at once, not at next dawn.
- **Redguard vampire-cure message:** **Curse vampire** → **Curse none**. Message
  must state the protection returns on death-duty re-entry. ⚠ The −3 ResistMagic
  **staying** is by design — not a bug.
- Reset: **Curse none** + proof race back to your real origin.

## GATE 3 — Daedric pacts

- **Prices:** select Azura (or Vaermina/Sanguine/Clavicus/Peryite). Note max
  Magicka/Health/Stamina. **Force Seeker** → **maximum** pool drops, price shows
  in Active Effects. Devoted/Champion deepen it. **Force lapse** → exact baseline.
- **Pool boons:** Sheogorath / Namira / Hircine → force a tier → max pool rises;
  lapse → baseline.
- **Mora Champion:** select Hermaeus Mora → **Force Champion** → Active Effects
  must show **Alteration +20 AND Fortify Magicka +20** (was doubled Magicka, no
  Alteration). Confirm `player.getav alteration`.
- **Reset Prince path** between Princes.

## GATE 4 — 4K toasts

Trigger any toast. Noticeably larger than 1.0.2 and on screen longer. 1080p
unchanged (optional to verify).

---

## NEW — port regression checks (added 2026-07-26)

The DrHeisen port touched the manager, MCM, player alias, deity base and the
signal/shrine scripts. These are the cheapest checks that the port did not break
something that used to work.

5. **MCM page sanity (B5).** Visit Player → Settings → Status → each debug page,
   then go back to Player and press **2–3 controls you have pressed before**.
   Nothing unexpected should fire. (Every option ID is now reset on page build;
   the failure mode this guards against is a click landing on a *different*
   page's handler — including destructive debug ones.)
6. **Stat repair buttons (new).** Player → Maintenance → **Check stat damage** —
   read-only, must change nothing. Then **Repair stats** on a **throwaway save**
   only: confirm prompt appears, repair runs, residue readout shows afterwards.
7. **Shrine prayer still credits (B14).** Pray at a shrine shortly after a load;
   piety should land. The charge is now spent only when the route succeeds, so
   an early prayer must not silently eat the day.
8. **Piety still accrues normally (C4).** Kill a few things / craft / read a
   book and confirm the usual piety and toasts still arrive. The per-deity
   event cache is new; it fails open, but this is the check that it is not
   silently withholding awards.
9. **Bard performances (B9/C3)** — only if you use a bard mod. Perform, restart
   Skyrim, perform again: the second performance must register (it previously
   went silent for hours after a relaunch).

## NEW — classification probes (needs debug level 3)

Two open findings that need observation, not a fix. The setup command above
already sets `PDV_GLO_DebugLevel` to 3; do the act, then read the Papyrus log
for the routed event.

10. **Brawl an NPC** (a fist-fight brawl, not a real assault). Question: does a
    brawl punch route `EVT_ASSAULT_INNOCENT`? If it does, assault routing needs
    a brawl-quest gate. Record yes/no.
11. **Kill a hostile animal in open combat** (a wolf that attacked you).
    Question: does it classify as a combat kill or a **non-combat** kill? If
    non-combat, the engine is clearing hostility on death and hostility must be
    latched at combat time instead of read off the corpse. Record which.

**Not tested / deliberately untouched:** the Story Manager receivers' 0.1 s
teardown defer (B18). It is a documented fix for the issue #17 CTD class.

---

## Reporting back

For each gate: pass / fail, plus the actual `getav` numbers for GATE 1 and the
**sting direction**, which decides whether the magnitude flip ships.
