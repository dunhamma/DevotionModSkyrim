# Devotion Quest-Mod Patches - Tester Runbook (2026-07-17)

For testers. Everything here is **unproven in game** - that is exactly what you
are helping establish. A patch that awards nothing is the expected failure mode
(we fail closed), so "nothing happened" is a real, useful result. Please report
it rather than assume you did it wrong.

You do not need to do all of this. Even one section is useful. Sections are
ordered cheapest-first.

---

## 0. Install

**Authoria players:** install `Devotion_Authoria_Compatibility_<date>.zip`, OR
run the FOMOD and pick **"Authoria (Requiem Reforged) - All-In-One"**. Do not do
both - they are the same content and one will just overwrite the other.

**Any other load order:** run the FOMOD, pick **"Individual patches"**, and take
the ones it recommends (it auto-detects which target mods you have).

Both lanes ship script overrides for `PDV_PlayerEvents`, `PDV__ManagerQuest`,
and `PDV_EventBus`. **These must win** over Devotion's own copies - put the
patch below Devotion in your mod order. If they lose, everything below silently
does nothing.

Any ESP the patch ships is ESL-flagged (no load-order slot) and should sort
after the mod it patches.

---

## 1. Turn the instruments on (do this first)

1. **Devotion MCM -> dev/debug page -> set debug level 2.**
   (Level 3 for the bard per-tavern cap line specifically.)
2. Enable Papyrus logging. Log lands at:
   `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`
3. Everything Devotion prints is prefixed `[PDV]`. To watch it live:
   ```
   powershell Get-Content "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Wait -Tail 30 | Select-String "\[PDV\]"
   ```

**Before any MCM reading, let the reward queue go idle.** Devotion's
perf-sweep/reward queue can drain for MINUTES after a big event, throwing stray
toasts and racing your reading. If toasts are still landing, wait for quiet.

---

## 2. Static preflight (2 minutes, no play required)

Load any save and check the log for these lines:

| Expect | Meaning |
|---|---|
| `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix): N of N` | core matrix loaded |
| `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix_ARR): ...` | ARR channel loaded (Authoria lane) |
| `Quest reaction channels registered: N.` | **N = how many per-mod patches you installed** |
| `Quest reaction matrix hooks refreshed (PDV_QRM_<Mod>.json): ...` | one line per per-mod channel |

**Red flags:**
- `Quest reaction channel folder empty or absent` -> the `Channels/` folder did
  not deploy, or the scripts lost (Devotion's originals are winning).
- `Quest reaction channel listed but unreadable: <file>` -> a corrupt JSON.
- **No `channels registered` line at all** -> you are running Devotion's stock
  scripts. The patch scripts lost the conflict. Fix mod order first; nothing
  else in this runbook will work.

Also confirm Base Object Swapper loaded `PDV_AuthoriaARR_DaedricShrines_SWAP.ini`
(Authoria lane only).

---

## 3. The debug method (how to test a hook without playing the quest)

You do **not** have to play a 4-hour quest mod to test its hook. Drive the stage
directly.

### 3a. Get the plugin's runtime prefix - never guess it

A patch's FormIDs are written `PLUGIN:XXXXXX`. In game the real FormID is the
plugin's **load-index byte** + that local id. The index changes per load order,
so look it up, don't guess:

```
help "Sandor" 0
```

Find a record that plugin owns and read the leading 2 hex digits (for an
ESL-flagged plugin it will look like `FE:xxx`). That prefix + the local id is
your runtime FormID.

### 3b. Drive the stage

```
setstage <runtimeFormID> <stage>
```

Example - War's Folly stance "pride in slaughter" (local `000001`, stage 20).
If `help` showed War's Folly at index `A3`:
```
setstage A3000001 20
```

### 3c. What you should see

In the log:
```
[PDV][QR_QUEUE] ENQUEUE qr_<n> key=<decimalForm>|<stage> cells=<n> pending=<n>
[PDV][QR_QUEUE] START qr_<n> key=<decimalForm>|<stage> cells=<n>
```
`cells=` is **how many gods reacted**. That number should match the table below.

Then confirm the piety actually moved: **MCM -> Survey**, or **Export Devotion
Report**, or the **Book of Days** entry.

**Reaction is deliberately asynchronous** - cells apply a couple per tick so a
big fan-out never monopolises the script engine. Give it a few seconds.

### 3d. Reading nothing?

- `REJECT malformed reaction <key>` -> bad row, tell us the key.
- `COALESCE recent <key>` -> you fired the same stage twice quickly; expected.
- `OVERFLOW rejected <key>` -> queue was saturated; note what else was running.
- **No `[PDV][QR_QUEUE]` line at all** -> the stage fired but no cell matched.
  That is the interesting failure: **the stage number is probably wrong.** It is
  a one-line CSV fix on our side, no script change. Please report the key.

---

## 4. The per-mod test table

Every row below is `setstage`-able per section 3. `cells` = gods expected to react.

### Dialogue-hook patches (the stances are the point - play these if you can)

| Quest | Local FormID | Stage | cells | Trigger |
|---|---|---|---|---|
| War's Folly | `War's Folly.esp:000001` | 20 | 4 | tell Sandor everyone you killed deserved it |
| | | 21 | 2 | "most earned it, some shame me" |
| | | 22 | 3 | "I cannot excuse any of them" |
| | | 23 | 2 | "this war is righteous" |
| | | 24 | 2 | "this war isn't my fight" |
| | | 25 | 2 | "war is all I'm built for" |
| Once We Were Here | `Once We Were Here - Quest Mod.esp:000002` | 60 | 3 | hope the Falmer can be redeemed |
| | | 61 | 1 | "the damage is irreparable" |
| | | 50 | 1 | see the encounters through |
| Whispers of the Depths | `Slays-Many-Beasts Quest Mod.esp:000001` | 45 | 1 | offer the old sailor condolences |

**Please play War's Folly for real if you can.** It is the one patch whose whole
design is the dialogue, and it also repairs two of that mod's own endings that
never set their quest stage. `setstage` proves the rows; only real dialogue
proves the fragments fire.

### Data-only patches

| Quest | Local FormID | Stage | cells |
|---|---|---|---|
| Sirenroot | `evgSIRENROOT.esm:026BC5` | 150 | 10 |
| The Rot Below | `CJ03Elroy.esp:02DA43` | 120 (kill Adabelle) | 9 |
| | | 130 (spare her) | 9 |
| The Frozen Heart | `ksws07_quest.esm:002086` | 1300 (cure her) | 3 |
| | | 10000 (refuse) | 3 |
| | | 20100 (kill her) | 5 |
| Bark and Bite | `Tree Contract Mod.esp:000009` | 25 (kill Frija) | 2 |
| | | 45 (spare Frija) | 3 |
| Baba Yaga | `ksws03_quest.esp:000AA2` | 600 | 1 |
| Depths of the Soul | `Dungeon Delver Mod.esp:000000` | 40 | 1 |
| Before the End | `PrisonerMod.esp:000007` | 5 | 2 |

### Core matrix (Authoria lane; needs Innocence Lost QE)

| Quest | Stage | Expect |
|---|---|---|
| DB01 Innocence Lost | 198 | Stendarr + Mara + Stuhn approve, Molag Bal disapproves (**4 cells**) |
| | 199 / 201 | **NOTHING.** Grelod dies in jail by other hands - not your act. A reaction here is a BUG. |

Sirenroot s150 (10 gods) and The Rot Below (9) are the best single checks: a big
fan-out proves the queue drains correctly.

### ARR 2.5 T13 test-candidate cases

These channels are **machine-verified experimental**, not supported. For each
case, capture the `ENQUEUE` and `START` route markers, the before/after piety
values, exactly one toast, exactly one Book of Days beat, and behavior after a
save/load made before the outcome. Values below are the raw cell awards before
origin-roster gating; an unreachable non-Prince deity must not create dead-state
piety. Use the structured evidence ledger shipped beside this runbook.

| Case | Quest key | cells | expected raw piety delta |
|---|---|---:|---|
| T13-001 | `Wyrmstooth.esp:028F01` s260 | 17 | Kyne +4; Alkosh +4; Talos +4; Baan Dar +2; Boethiah +4; HoonDing +4; Khenarthi +2; Kynareth +2; Leki +2; Malacath +2; Mara +2; Shor +4; Stendarr +4; Stuhn +2; Syrabane +4; Trinimac +2; Tsun +4 |
| T13-002 | `ccbgssse067-daedinv.esm:19952A` s1000 | 3 | Mehrunes Dagon -18; Stendarr +4; Akatosh +2 |
| T13-003 | `ccasvsse001-almsivi.esm:0990EF` s100 | 2 | Zenithar +4; Malacath +4 |
| T13-004 | `ccmtysse001-knightsofthenine.esl:000865` s100 | 9 | Akatosh, Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Talos, and Zenithar each +18 |
| T13-005 | `TasteOfDeath_Addon_Dialogue.esp:000050` s100 | 9 | Namira -2; Stendarr +4; Akatosh, Alkosh, Auri-El, Julianos, Stuhn, Z'en, and Zenithar each +2 |
| T13-006 | `Siege at Icemoth.esp:5A079F` s30 | 11 | Arkay +18; Meridia +18; Azura +2; Boethiah +4; HoonDing +4; Malacath +2; Shor +4; Stendarr +2; Tsun +4; Tu'whacca +2; Y'ffre +2 |
| T13-007 | `Siege at Icemoth.esp:59F97E` s20 | 3 | Hermaeus Mora +18; Julianos +2; Magnus +2 |
| T13-008 | `Hunt for the Spectre.esp:000800` s55 | 6 | Arkay +18; Meridia +18; Azura +2; Stendarr +2; Tu'whacca +2; Y'ffre +2 |
| T13-009 | `Sithis Mod - Lovecraftian Inspired Quest.esp:000892` s40 | 16 | Sithis +4; Molag Bal +4; Stendarr -6; Stuhn -4; Baan Dar, Dibella, HoonDing, Khenarthi, Kynareth, Kyne, Leki, Mara, Rajhin, Shor, Talos, and Tsun each -2 |
| T13-010 | `TheGiftofSaturalia.esp:0008AA` s20 | 5 | Mara +18; Stendarr +18; Dibella +2; Stuhn +2; Syrabane +4 |
| T13-011 | `TheGiftofSaturalia.esp:0008D3` s8 | 2 | Mara +18; Dibella +18 |
| T13-012 | `TheGiftofSaturalia.esp:000963` s10 | 2 | Mara +18; Dibella +2 |
| T13-013 | `TheGiftofSaturalia.esp:0009A4` s10 | 4 | Mara +18; Stendarr +18; Dibella +2; Kynareth +2 |
| T13-014 | `TheGiftofSaturalia.esp:0009D2` s30 | 6 | Mara +18; Stendarr +18; Dibella +18; Y'ffre +4; Stuhn +2; Syrabane +4 |

**T13-004 must be played organically.** The stage-100 row is derived from the
stage-10 pilgrimage objective and the later completion stage. `setstage` may
prove routing but cannot prove that the nine-shrine progression resolves there
or that the semantic credit is truthful. The other cases should also be played
organically before support promotion; controlled stages establish route only.

---

## 5. Bard hook (needs Become a Bard and/or Skyrim's Got Talent)

No console needed - just perform.

1. **New game with NO bard mods:** Devotion must initialise normally. The poll
   self-disables. (This is the "does it break anyone else" check.)
2. **Skyrim's Got Talent only:** perform badly, then perform well. Expect ONE
   Dibella pulse each, scaled by quality:
   ```
   [PDV] Bard performance routed quality=<1-8> ovation=<bool> multiplier=<n>
   ```
   Get an ovation -> `ovation=true` and a bigger multiplier. **You should not see
   two pulses for one performance.**
3. **Become a Bard - the anti-farm check:** perform **twice in one tavern**, then
   **once in a different tavern, same day**. Expect: first tavern pays once, the
   repeat is capped, the second tavern still pays.
   At debug level 3 the block prints:
   ```
   [PDV] Bard performance blocked by per-tavern daily cap.
   ```
4. **Budget exhaustion** (perform a lot in one day):
   ```
   [PDV] Bard performance decayed out for today; no Dibella award.
   ```
   That is the global anti-farm budget, not a bug.
5. **Milestones (one-time):** BaB tavern quest s100, BaB Jarl quest s100, and
   both Bards Reborn college quests -> one-time Dibella milestones.

**Known question worth your eye:** the bard signal currently rides Dibella's
`PATRON_CIVIC_FAVOR` channel. If the toast/Book of Days wording reads like civic
favour rather than performance, that is a copy bug we already suspect - please
quote what it actually said.

---

## 6. Daedric shrine prayers (Authoria lane)

**Travel by load door or fast-travel, NOT `coc`** - `coc` skips the location
triggers.

1. Visit any Daedric Shrines AIO statue. It should now offer a **Pray** prompt.
   No prompt -> the BOS INI did not load (check it is in the Data root and BOS is
   active).
2. Pray -> that Prince gains piety. Pray again the same day -> **nothing**
   (once/day). Next day -> works again.
3. Covered: Azura, Vaermina, Molag Bal, Mephala, Mehrunes Dagon, Sheogorath,
   Namira, Sanguine, Hermaeus Mora, Hircine, Peryite. Plus the Wyrmstooth
   Nocturnal and Vaermina placements.
4. **Jyggalag's shrine must award NOTHING** - Devotion has no Jyggalag. Any
   credit there, especially credited to another god, is a bug worth reporting
   loudly.

---

## 7. Lower priority (if you have appetite)

- Sacrilege / Manbeast / Requiem VampireCollection state transitions.
- An Alternate Perspective start with Starting Choices active.
- JS Shrines / CC Survival "Disable Shrine Menu" - does shrine activation still
  route?
- Any cell marked `runtimeVerify=pending` in the JSON (these are rows whose stage
  we inferred structurally rather than proved).

---

## 8. What to send back

Even partial is useful:

1. Which lane you installed, and the `channels registered: N` number.
2. For each hook you drove: the key, the `cells=` count, and whether piety
   actually moved.
3. **Anything that fired that should not have** - especially DB01 s199/s201 or
   Jyggalag. A false award is worse than a missing one.
4. Any `[PDV]` error, `REJECT`, or `OVERFLOW` line.
5. For bard: quality numbers seen, and whether the per-tavern cap held.
6. Papyrus log if anything looks wrong.

**Please do not report "it worked" without the log line.** The whole point of
this pass is that we have machine proof and zero runtime proof - a green
eyeball is not the evidence we're missing.
