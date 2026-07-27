# Devotion 1.0.4 — team test guide

**Four tests. Everything else is already confirmed** — stat drift, curse music,
the Daedric price family, toast sizing, the faucet cache, menu safety, piety
accrual and the vampire-cure message have all been runtime-tested and passed.
Please don't re-run those; the four below are the only things with no eyes on
them yet.

No Devotion debug menu needed — `coc` and standard console commands only.

This is an **unreleased build**. Use a save you don't mind losing.

## Setup

1. Install `Devotion-1.0.4-20260726.zip` as a normal mod.
2. **Place `Devotion.esp` manually, late in your load order** — don't let LOOT
   sort it.
3. Start a **new game**.
4. Console: press **`~`** (left of `1`, above Tab). Type, press **Enter**, press
   **`~`** to close. (Some keyboards: **`` ` ``**.)
5. ⚠ **REQUIRED — turn on Devotion's logging, or the log stays empty.** In the
   console:
   ```
   set PDV_GLO_DebugLevel to 3
   ```
   Devotion writes **no** log lines at the default setting, so without this
   every test below looks like a failure even when it worked. This is a single
   console command — you do **not** need the debug menu, and no restart is
   needed. Set it back to `0` when you're finished if you like.
6. The Papyrus log you'll be reading is at:
   ```
   C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
   ```
   Replace the username with your own. If the folder is empty or missing,
   Papyrus logging is off in your INI — enable it, or just report what you saw
   on screen.

**Sanity check that logging is on:** after setting the debug level, wait a few
seconds and search the log for `[PDV]`. You should see Devotion lines appearing.
If you see none at all, stop — the tests below cannot produce a meaningful
result until that's fixed.

---

## Test 1 — Green Pact: Bosmer eating meat ⭐ most important

**Why this one matters most:** the list of qualifying meat was empty until
yesterday, so this reward could never fire. The list is now populated but has
never been observed working. If there's a mistake in it, nothing matches and
it fails silently — no error, no log line, it just never rewards.

1. `showracemenu` → choose **Wood Elf** → confirm and close.
   (This is a real race change; Devotion re-detects your race when the menu
   closes, exactly as it would for a real character.)
2. Console: `player.additem 065C99 1` — Raw Beef.
   (Cooked Beef also works: `player.additem 0721E8 1`.)
3. **Eat it** from your inventory.
4. Search the Papyrus log for:
   ```
   Green Pact meat food positive routed.
   ```

✅ **Pass:** that line appears.

❌ **Fail:** it doesn't. Report it — that's the failure we're looking for.

*Note:* a piety line for Y'ffre may or may not follow, depending on whether a
related Green Pact trigger already fired that in-game day (they share one daily
throttle). Its absence is **not** a failure — only the line above matters.

*If you're re-running this test:* the meat reward is capped once per in-game
day. If you already ate a listed meat today, it won't fire again. Either sleep
24 in-game hours first, or use a different item from the list —
`player.additem 0722BD 1` is Venison Chop.

---

## Test 2 — Daedric artifacts still signal their Prince

The faucet routing table was substantially rewritten this release. This
confirms it still recognises real game items.

1. Pick any one and add it:

   | Prince | Item | Command |
   |---|---|---|
   | Boethiah | Ebony Mail | `player.additem 052794 1` |
   | Molag Bal | Mace of Molag Bal | `player.additem 233e3 1` |
   | Meridia | Dawnbreaker | `player.additem 4e4ee 1` |
   | Sheogorath | Wabbajack | `player.additem 2ac6f 1` |
   | Hircine | Savior's Hide | `player.additem 2ac61 1` |

2. **Equip it** (wear the armour / hold the weapon).
3. Search the log for `RouteQuestReactionFaucet` or `RouteDaedricPrinceSignal`
   with that Prince's name in it.

✅ **Pass:** the line appears.

❌ **Fail:** nothing appears for that Prince.

*This does not grant a pact tier* — reaching Seeker/Devoted/Champion needs
sustained worship over real play. Equipping one artifact only proves the signal
is recognised.

---

## Test 3 — shrine prayer actually shows something

⚠ **The trap:** praying at a shrine whose god your race doesn't revere
correctly produces **nothing at all**. That's intended behaviour, not a bug —
so "no toast" is only meaningful if the god matches your race.

To make it a valid test, match them deliberately:

1. `showracemenu` → choose **Nord** → confirm and close.
2. `coc WhiterunTempleOfKynareth`
3. Activate the shrine and pray.

✅ **Pass:** you get a visible acknowledgement — a notification and/or a Book
of Days entry. The log should also show `RouteShrinePrayer complete`.

❌ **Fail:** the log line appears but **nothing shows on screen**. That's the
specific thing being checked here — the routing is already known to work, the
open question is whether the player actually *sees* the result.

---

## Test 4 — werewolf curse (vampire already passed)

The vampire path is confirmed. Werewolf uses a different detection route and
hasn't been run.

1. `coc WhiterunBanneredMare` — stand in the inn, listen to the music for ten
   seconds.
2. Console: `player.addfac 91822 0` — puts you in the werewolf state Devotion
   watches for.

✅ **Pass:** one short sound, then **the inn music carries on normally**.

❌ **Fail:** dungeon or combat music takes over and *stays* — walk outside and
back in to be sure.

3. Console: `player.removefac 91822`
4. ✅ **Pass:** one short cure sound, music still normal.

---

## Reporting back

Per test: **pass**, or exactly what happened. For Tests 1, 2 and 3 the most
useful thing is a copy of the matching lines from `Papyrus.0.log`.

If the game crashes or you see a wall of red error text, note roughly what you
were doing.
