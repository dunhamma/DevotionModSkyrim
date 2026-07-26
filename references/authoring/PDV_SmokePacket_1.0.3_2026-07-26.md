# Devotion 1.0.3 — smoke packet (2026-07-26 rebuild)

Run on a **fresh save**, on the rebuilt zip. The Papyrus surface changed
substantially since the first 1.0.3 packet (the DrHeisen port landed), so this
supersedes it — re-run the whole thing, not just the new rows.

## Results so far (owner, 2026-07-26)

| Item | Result |
|---|---|
| **GATE 1** stat drift / disfavor sting | **PASS** — WarHonor Light: OneHanded −3 on apply, exact baseline on clear, stable across repeats. Confirms both the `Recover` fix and the `Detrimental` + positive-magnitude convention. |
| **GATE 3** Daedric prices | **PASS** — family repaired (48/48 `Detrimental` + `PowerAffectsMagnitude`, 0 negative magnitudes) and runtime-proven. See `handoff/PDV_AzuraPrice_ActorValueDiagnosis_Handoff_2026-07-26.md`. |
| **GATE 2** curse music (vampire) | **PASS** — no persistent dungeon bed; interior music continued normally; short sting heard on **both** onset and cure. |
| GATE 2 instant restore + vampire message | assigned to second tester (her Tests 5 and 6) |
| GATE 4 4K toasts | size confirmed bigger; **box-width fix landed afterwards** — needs one more glance |
| Checks 5, 7, 8, 9 | assigned to second tester |
| Check 6 stat-repair buttons | owner, throwaway save, still open |
| Probes 10, 11 | still open, observation-only, feed 1.0.4 |
| Faucet cache (C2) — see below | still open, highest silent-failure risk in the port |

**Faucet cache spot check (not a numbered gate, but the one worth doing).**
The C2 port replaced a per-call JSON scan with a cache built once at load from a
hand-transcribed 21-key list; a typo there kills a faucet silently. With debug
level 3: `player.additem 34C5D 1` (Nord Mead, on Sanguine's `revel_indulge`
faucet), drink it, then search `Papyrus.0.log` for `RouteQuestReactionFaucet`.
Either `RouteQuestReactionFaucet complete: Sanguine.revel_indulge` **or**
`QuestReaction faucet repeat blocked: Sanguine ...` is a pass — both mean the
form was recognised. Neither line appearing is the failure.

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
flip. To actually exercise the disfavor/neglect convention, also run a **Kyne
or Talos neglect** case (MCM →
`Prime neglect eligible` / `Run neglect pass` with that patron active) and
confirm the value moves DOWN.

**Daedric price repair (2026-07-26):** all 48 price MGEFs now use
`Detrimental + PowerAffectsMagnitude`, and all 48 carrier spells store the
positive absolute price magnitude. Their contract values remain negative
because those values describe the player-facing penalty. Direct readback and
the standard verifier pass all 48. The GATE 3 Azura and Mephala representative
runtime sweeps passed on 2026-07-26.

Do not use the older generic `magicresist` steps for this gate. The concrete
WarHonor / `onehanded` route above is the authoritative repeat-cycle proof, and
its downward direction has already passed.

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

- **Post-repair Azura tier sweep:** use the same Redguard save. Wait five
  seconds after load, select **Azura**, then **Reset Prince path**. Close the
  MCM and record:

  ```text
  player.getavinfo stamina
  player.getav stamina
  ```

  Reopen the MCM and test each tier separately. After every click, close the
  MCM, confirm the named Azura price in Active Effects, and repeat both console
  commands:

  1. **Force Seeker** — Stamina is 10 below the Reset baseline.
  2. **Force Devoted** — Stamina is 20 below the Reset baseline.
  3. **Force Champion** — Stamina is 30 below the Reset baseline.
  4. **Force lapse** — Stamina returns exactly to the Reset baseline and the
     Azura price disappears.

  Compare every tier with the Reset baseline, not with the preceding tier.
  The Redguard Spine Forebear +10 reward can mask the net modifier: on the
  proven save, Reset was +10, Seeker netted to 0, Devoted should net to -10,
  and Champion should net to -20.
  **PASS 2026-07-26:** all three deltas, named Active Effects, and exact Lapse
  restoration confirmed.
- **Post-repair non-resource sweep:** **Reset Prince path**, select
  **Mephala**, and record `player.getavinfo speechcraft` plus
  `player.getav speechcraft`. Test Seeker / Devoted / Champion exactly as
  above. Each tier must show its Mephala price in Active Effects and lower
  Speech by 8 / 12 / 15 from the Reset baseline. **Force lapse** must restore
  the exact baseline.
  **PASS 2026-07-26:** all three deltas, named Active Effects, and exact Lapse
  restoration confirmed.
- **Optional second resource family:** repeat with **Vaermina** and Health.
  Expected deltas from Reset are -8 / -15 / -20.
- **Redguard masking regression:** after loading a completed Redguard save,
  wait five seconds, then **Reset Prince path**. Before pressing **Force
  Seeker**, `Redguard Spine Forebear` must already be present and
  `player.getavinfo stamina` must expose its +10 modifier. Force Azura Seeker
  must change that modifier from +10 to 0; it must not be the action that first
  grants Forebear. Lapse must restore +10.
  **PASS 2026-07-26:** load reconciliation granted Forebear first; Seeker
  produced the -10 delta and lapse restored the +10 baseline.
- **Pool boons:** Sheogorath / Namira / Hircine → force a tier → max pool rises;
  lapse → baseline.
  No additional 2026-07-26 rerun is required for the price repair: these
  unchanged positive-boon mechanics are already covered by the existing
  Daedric runtime ledger.
- **Mora Champion:** select Hermaeus Mora → **Force Champion** → Active Effects
  must show **Alteration +20 AND Fortify Magicka +20** (was doubled Magicka, no
  Alteration). Confirm `player.getav alteration`.
  **PASS 2026-07-26:** Alteration +20, maximum Magicka +20, Stamina price -30,
  correct Active Effects, and tested baselines restored on Lapse.
- **Reset Prince path** between Princes.

## GATE 4 — 4K toasts

Trigger any toast. Noticeably larger than 1.0.2 and on screen longer. 1080p
unchanged (optional to verify).

**PASS 2026-07-26:** owner confirmed the enlarged 4K presentation and longer
onscreen duration. No repeat is required.

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

   **PASS 2026-07-26:** Owner visited all named MCM/debug pages, returned to
   Player, and exercised familiar controls without cross-page or destructive
   debug misrouting.

6. **Stat repair buttons (new).** Player → Maintenance → **Check stat damage** —
   read-only, must change nothing. Then **Repair stats** on a **throwaway save**
   only: confirm prompt appears, repair runs, residue readout shows afterwards.

   **DEFERRED 2026-07-26 — not a failure:** The owner does not currently have a
   suitable damaged-stat test state. Leave this manual-proof slot open for an
   external tester with a disposable save; continue the owner run at B14.

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
