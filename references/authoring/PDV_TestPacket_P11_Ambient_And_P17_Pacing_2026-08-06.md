# Test packet -- P11 ambient layer + P17 cadence sizing (2026-08-06)

One Altmer save covers both. P11 needs runtime proof it has never had; P17 cannot be tuned
without observed pacing. Do them in one sitting because they need the same save state:
an Altmer carried to Champion with an active patron.

**Scope:** Altmer only. The Khajiit lunar rebalance (`5e712226`) is a separate lane with its own
proof needs and is not covered here.

---

## Front-loaded reference -- pull these up before you start

**Records (all `:Devotion.esp`)**

| FormID | EditorID | Fires when |
|---|---|---|
| `0716E5` | `..._AuriEl_ChampionAmbient_Dawn` | Auri-El patron, variant A |
| `0716E6` | `..._AuriEl_ChampionAmbient_Return` | Auri-El patron, variant B (needs a mark) |
| `0716E7` / `0716E8` | Magnus `_Study` / `_ElderWay` | Magnus patron, A / B |
| `0716E9` / `0716EA` | Xarxes `_Record` / `_Lineage` | Xarxes patron, A / B |
| `0716EB` / `0716EC` | Trinimac `_Watch` / `_Sword` | Trinimac patron, A / B |
| `0716ED` / `0716EE` | Syrabane `_Ward` / `_Guard` | Syrabane patron, A / B |
| `0716EF` | `..._General_HeritageExemplar` | heritage band HIGH, any/no patron |
| `0716F0` | `..._General_HeritageQuiet` | once, on the fall from HIGH |
| `0716E4` | `PDV_MISC_AltmerPracticeFocus` -- the **Calian** | the token itself; mesh `PDV\Clutter\PDV_AltmerCalian.nif` |
| `071706` | `..._Calian_AlreadyKept` | the calian used again the same day |
| `071707` | `..._Calian_Unanswered` | the calian used while the Altmer curse suppresses favour |

**Constants**

- `AMBIENT_CHAMPION_CADENCE_DAYS = 4` (devotional days, 06:00 boundary)
- Champion threshold `85`; `LONG_DEVOTION_MARK_STEP = 15`, so **piety 100 = MarkHigh 1**
- Altmer substrate `HighThreshold = 60` (P2 lowered it from 75 on `0715AC`)
- Substrate budget: **one `+4.0` credit per devotional day**, whatever act claims it

**StorageUtil keys worth watching**

- `PDV.Ambient.Champion.<DeityIndex>.Day` -- cadence stamp (day + 2 encoding)
- `PDV.Ambient.Champion.<DeityIndex>.Count` -- drives A/B alternation
- `PDV.Ambient.Heritage.Day`, `PDV.Ambient.Heritage.WasHigh`
- `PDV.LongDevotion.MarkHigh.<DeityIndex>` -- gates variant B
- `<DeityIndex>` is the deity's own property (Syrabane = `1415`)

**Altmer substrate feeds** (any ONE claims the day): `330` smithing, `331` enchanting,
`340`/`341`/`342` reading, the outdoor dawn observance, the Auri-El shrine rite, the
Ancestral Focus token (`0716E4`, works indoors), sleep dream.

---

## Preconditions -- read this one first, it can invalidate the whole run

**Use a fresh save, or verify the bindings before trusting a negative result.** P11 added 12
`Message` properties to the manager quest's VMAD, and the calian added 2 more (14 in total). VMAD properties bake at first init, so a save
made before those properties existed can read them as `None`. `ShowAltmerNotification` does not
error on `None` -- it falls back to a Prisma toast. On an old save the ambient layer will look
half-broken when the records are fine.

**The two failure modes are visually distinguishable, which is the fastest diagnostic you have:**

- **Corner notification, no title** -> the MESG record fired. Binding resolved. Working.
- **Prisma toast** -> the property read `None`. Either a stale save or an unbound property.

If you see a toast, reload before concluding anything. All 12 bindings were readback-verified
non-null in the plugin on 2026-08-04, so a toast on a fresh save means something regressed since.

Other preconditions:

- `PDV__ManagerQuest.pex` and `PDV_MCM.pex` must be newer than their `.psc`. Both were recompiled
  2026-08-06 after the likes/dislikes regen.
- `LIKES_DISLIKES_VERSION` is now `20`; the table reloads itself on first load when the stored
  version differs. No action needed, but a Papyrus log line confirms it.
- Notifications must be ON in the MCM -- `NotificationsEnabled()` gates the whole layer.
- Race-setup quiet presentation must be finished; the layer self-suppresses during it.

---

## Part A -- the calian (five minutes, any Altmer save, do this first)

Cheap, immediate, and it exercises the same binding path everything below depends on -- so if the
calian lines arrive as corner notifications, the save is not stale and Parts B and C can be trusted.

1. **Open the inventory.** The item reads **Calian**. Look at the model: it carries two glass shells
   plus a third shape textured from the vanilla Barenziah's jewelry box atlas. **Record whether it
   renders as a bare sphere or a sphere in/on a wooden box** -- that decides whether the third shape
   gets stripped in NifSkope. Geometry, so not a houseCARL job.
2. **Click it.** The practice lands: the idle plays (prayer pose, or a reading pose when the patron
   is Magnus, Xarxes or Syrabane) and the Book of Days takes "You kept the practice where you stood,
   with no shrine and no witness."
3. **Click it again the same day.** -> "Your calian is already warm from today's practice." This
   moment was silent before; a click did nothing visible, so a working item and a broken one looked
   identical.
4. **Drop the calian, then re-open the inventory.** It comes back -- `EnsureAltmerPracticeFocus`
   re-grants whenever the player has none. On a character who already owned one, this is the ONLY
   way to see the granted line, because the one-shot key was never set: a Book of Days entry, "You
   have carried this since you were eighteen..."
5. **Drop it once more.** It returns again and the granted line does NOT repeat. That is the proof
   the line hangs off `PDV.Altmer.Calian.Granted` rather than the `AddItem` -- without it, a
   replacement acquired a minute ago would claim you had carried it since you were eighteen.
6. **Curse arm.** MCM -> Debug: Daedric & Curse -> "Force the curse state to Vampire?", then click
   the calian -> "The calian does not warm to you now." Restore with "Force the curse state to
   None?" afterwards. A non-Altmer holding the calian is told nothing, by design: it is not their
   object and there is no refusal to explain.

**Not testable on Anvil:** the inventory DESCRIPTION only renders where Description Framework is
installed, which is Authoria/ARR 2.5. That is a separate launch on that list, and the instance must
be confirmed before any readback that becomes a claim.

## Part B -- P11 Champion ambient (the core proof)

Reach Champion with one Altmer patron. Auri-El or Syrabane are the easiest to read because their
A-lines are distinctive.

1. **Day 0.** Confirm Champion, confirm patron is ACTIVE (not just high piety -- the ambient
   resolves on `_activeDeity`, the same scope Long Devotion marks use).
2. **Sleep 4 devotional days.** Expect **exactly one** corner notification, variant A.
3. **Sleep 1 more day.** Expect **nothing**. This is the cadence gate; a second line here means
   the stamp is not being written or is being read against the wrong encoding.
4. **Sleep 4 more days.** Expect one notification again. Which one depends on marks:
   - piety below 100 -> **variant A again** (correct -- the B line is gated, not merely alternated)
   - piety 100+ -> **variant B**
5. **Push piety to 100+ and repeat step 4** to see B. This is the arm most likely to be wrong,
   because it is the only one with two conditions (`Count` odd AND `MarkHigh >= 1`).

**What a failure looks like:** a line every day = cadence stamp not persisting. Never any line =
`NotificationsEnabled()` off, patron not ACTIVE, or tier below Champion. Always variant A even at
piety 100+ = the mark gate or the `Count` increment is wrong.

**Non-Altmer check, cheap and worth it:** a Nord with Kyne at Champion should now also get a
recurring line (`071525`, "The wind is blowing your way") every 4 days, on top of her existing
one-shot at the moment of the reach. P11 registered her in the dispatcher. If the Nord one-shot
stopped firing, that is a regression -- it was supposed to be left intact.

## Part C -- heritage band (deity-agnostic, no patron required)

This arm reaches a broad worshipper with no patron at all, so it is worth a separate look.

1. Get the Altmer heritage metric to the top band (`>= 60`). One `+4.0` credit per day means
   roughly 15 days of any qualifying practice, so use the substrate pacing debug rather than
   waiting.
2. At the band, expect `0716EF` on the same 4-day cadence.
3. **Drop below the band.** Expect `0716F0` **once**, on the transition down -- not repeating.
   A repeat here means `PDV.Ambient.Heritage.WasHigh` is not being cleared.
4. Under an active Altmer curse, expect silence from this arm entirely.

## Part D -- P17 cadence sizing (observation only, tune afterwards)

Do not change numbers during the run. The point is to watch the shared clamp.

Ships today: Xarxes `RECORD_KEPT` **1.5**, Magnus `APERTURE_KEPT` **1.2**, Trinimac
`CIVILIZATION_DEFENDED` 1.2, Syrabane `PROTECTIVE_WARDING` 1.8, Auri-El shrine rite 2.0/day.
Proposed: Xarxes -> 2.0, Magnus -> 1.5.

**The question to answer is not "is it slow" but "is the 4.3/day clamp saturated".** Over-tuning
presents as "the cap is always full and nothing feels earned", which no gate catches. Record, for
about a week of play:

- how often the daily clamp is hit, and by which lanes
- whether the scholar lanes (Xarxes, Magnus) actually lag the others or only feel like it
- whether a day ever passes with no renewable available at all

**One constraint on what a single save can prove.** Xarxes' 1.5 is a literal at the dawn award
site, so a recompile applies it to your existing save immediately. Magnus' 1.2 is
`DELTA_APERTURE_KEPT`, an `Auto` property that bakes at first init -- editing the script default
will NOT move a save already in progress. To A/B Magnus inside this save, retune at the award-site
multiplier instead of the property.

## Part E -- copy in situ (free, do it while the above runs)

The 2026-08-05 rewrite has only ever been read in a table. Read each line as it appears in the
corner, at speed, with the game moving. Specifically:

- the Book of Days heritage lines, one per accepted day credit, per source
- the `practice_focus` arm, which before `029e641c` fell through to the orthodoxy default and was
  the highest-frequency Altmer journal line in the game
- the 12 ambient lines from Part B, and the calian's three from Part A

---

## Traps that will waste your session if you skip them

1. **Confirm the quest-reaction perf-sweep queue is idle before an MCM sitting.** A stray queued
   toast reads exactly like a live award and has caused false bug reports before.
2. **Organic debug buttons share the daily budget.** Two organic-mirror presses in one day silently
   no-op the second. Use direct-seed controls when you need a specific state, not the organic path.
3. **`coc` skips Story Manager location-change triggers.** Walk in through a load door when a
   location trigger matters.
4. **The substrate takes one credit per day whatever claims it.** If you enchant and then read, the
   second act legitimately grants nothing -- that is the design, not a bug. Watch for the "already
   marked" presentation rather than a second grant.
5. **Judge a gate by exit code**, not by a grepped line, if you run any repo-side checks alongside.

## What to bring back

- **Calian:** bare sphere or sphere-in-a-box; whether the repeat-use and curse lines appeared; and
  whether the granted line fired once on the drop and stayed silent on the second drop
- Which of the 14 records you actually saw, and whether each arrived as a corner notification or a
  Prisma toast (that distinction is the binding proof)
- The four-day cadence: confirmed, or what it actually did
- Whether variant B ever appeared, and at what piety
- The heritage fall line: once, or repeating
- Nord/Kyne: recurring line present, one-shot still intact
- For P17: clamp saturation notes, enough to set two numbers with

Anything that surprises you is worth a Papyrus log excerpt -- the ambient layer traces at level 2
(`Champion ambient surfaced for <deity> (standing|long-devotion)`).
