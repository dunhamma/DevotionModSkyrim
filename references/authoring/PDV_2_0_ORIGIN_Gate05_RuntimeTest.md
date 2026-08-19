# GATE 0.5 runtime test -- ORIGIN + DAEDRIC

One sitting, two new games. Everything below is already deployed to `Devotion-V3Dev`.

**Why a NEW GAME:** the 11 new host quests are start-game-enabled. An existing save never runs
them, so a loaded save proves nothing here.

---

## Preflight (2 minutes)

1. MO2: profile **Devotion Dev**, with **`Devotion-V3Dev` enabled** and **`Devotion` disabled**.
   That is the 2.0 configuration (the profile is the dev environment; the mod folder picks the
   version).
2. Confirm the SEQ is in place: `Devotion-V3Dev\SEQ\Devotion.seq` should be **220 bytes**
   (55 quests). If it is 180 bytes you are on the pre-ORIGIN copy.
3. Clear the Papyrus log folder so the run is clean:
   `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script`
4. Ignore the MO2 mod `houseCARL - houseCARL_SEQ_003` if you see it -- it is a build artefact,
   not enabled, and not needed.

---

## Run A -- KHAJIIT (the thick adapter: 88 lane fns, 29 signal ids)

New game, Khajiit, get through the intro to where you have MCM access.

### A1. The adapter bound at all
Open MCM -> **Status**. Read **Origin diagnostic**.
- PASS: it names Khajiit.
- FAIL: blank, "unknown", or the wrong race -> `ResolveOriginRuntime()` did not bind. Stop and
  send the log.

### A2. Nothing is None
MCM -> **Debug: State & Rewards**, then **Debug: Daedric & Curse**, then
**Debug: Pacing & Pantheons**. Just opening all three exercises a lot of `OriginRuntime.*` reads.
- PASS: all three pages open and render values. No crash.
- FAIL: a page fails to open, or values render blank/zero across the board.

*(The Daedric page crash from earlier this session is fixed -- it should open cleanly now. If it
still crashes with `Array index 109-127 out of range`, that is a regression worth knowing about.)*

### A3. Race behaviour actually fires
On **Debug: State & Rewards** use the Khajiit buttons:
- **Khajiit moon observance** -- should register.
- **Khajiit lunar posture** -- cycles Normal/Strained/Corrupted/ShadowDrift.
- **Seed lunar metric 25** then **Show lunar budget** -- the metric should move.

These route through `HandleContextualSignal` into the Khajiit adapter. If the adapter were not
bound they would silently no-op, so "nothing happened" is a real FAIL here, not a shrug.

### A4. The value-return path (this one is new plumbing)
Use the **Observe the Moons** power in-world, outdoors, at night.
This is the only path that goes through `HandleContextualQuery` and carries an Int **token**
across a two-second delay. It is the most likely thing to be broken by the split.
- PASS: the observation completes and credits after the delay.
- FAIL: nothing happens, or the log shows `rejected completion: stale_token`.

### A5. Sleep routing
Sleep **outdoors** (bedroll under open sky), then wake.
- PASS: the Khajiit road-home / outdoor-rest reaction fires.
- This exercises the new `"outdoor-rest"` signal that replaced a nine-way race switch.

---

## Run B -- IMPERIAL (the thin adapter: 34 fns, and the other new query path)

New game, Imperial. Same A1/A2 checks first (Origin diagnostic should say Imperial).

### B1. Concordat pressure -- the second query path
On **Debug: Daedric & Curse**, use **Concordat defiance** and **Concordat compliance**.
Then MCM -> **Status** and read **Raw value** / **Committed state** under Phase 8 Concordat.
- PASS: the value moves in the expected direction.
- This routes an Int through `HandleContextualQuery`; a broken route reads as "the number never
  changes".

### B2. Talos shrine defiance
Use **Talos shrine defiance** on the same page.
- PASS: Talos piety awards AND Concordat pressure applies (Imperial only).
- The base now decides this from the signal's Bool return rather than a race check, so an
  Imperial who gets the award but no Concordat movement is a real FAIL.

---

## What to send back

1. The Papyrus log from the run: `.../Logs/Script/Papyrus.0.log`.
2. Which of A1-A5 and B1-B2 passed.
3. Anything that rendered blank or zero when you expected a value.

**The single most useful grep** if you want to pre-check it yourself -- these should return nothing:

```
findstr /C:"OriginRuntime" /C:"cannot be initialized" /C:"None" Papyrus.0.log
```

A few `Property ... cannot be initialized` lines are expected and harmless (stale fills on the
manager quest, ~198 of them, pre-existing). What matters is any error naming **OriginRuntime**,
**PDV_OriginRuntime_<Race>**, or **PDV_DaedricRuntime**.

---

## What this gate does NOT cover

Only two of ten adapters are exercised. The other eight compile and are wired but are unproven at
runtime; they carry the same shape, so the risk is low but not zero. Full per-race coverage is a
later, more expensive pass.
