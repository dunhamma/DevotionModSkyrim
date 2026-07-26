# Devotion 1.0.3 — tester instructions

Thanks for helping test! This is an **unreleased build**, so please use a save
you don't mind losing. Everything below takes about 20 minutes.

You don't need to know anything about the mod. Each test is: press a button,
read a number, tell me if it did what it says.

---

## Setup (once)

1. Install `Devotion-1.0.3-20260726.zip` as a normal mod.
2. **Place `Devotion.esp` manually, late in your load order** — don't let LOOT
   sort it. (If you use Wintersun, put Devotion where Wintersun would go.)
3. Start a **new game**. Not an existing save.
4. Wait until you get a notification that Devotion has started (a few seconds
   after you're in the world), then check **MCM → Devotion → Player** shows a
   **Version** line reading 1.0.3.

### Using the console

Press the **`~` key** — the one directly left of the `1` key, above Tab. The game
dims and a text prompt appears at the bottom. Type the command, press **Enter**,
read what it prints, then press **`~`** again to close.

If `~` does nothing, try the **`` ` ``** key in that same spot — on some keyboard
layouts it's labelled differently.

### Unlocking the test menus ⚠ required

The debug pages are **hidden by default** and there is **no button** for them —
they only appear after a console command. In the console, type:

```
set PDV_GLO_DebugLevel to 1
```

Press Enter, close the console, then **exit and re-open the MCM** (all the way
out to the pause menu and back in — SkyUI only rebuilds the page list on open).

You should now see two extra pages in the Devotion menu:

- **Debug: State & Rewards** ← the one these tests use
- **Debug: Pacing & Pantheons**

If those pages are visible but say **"Developer Options — Locked"**, the command
didn't take. Re-check you typed it exactly (the global name is case-sensitive),
and that you closed and re-opened the MCM.

To hide them again when you're done: `set PDV_GLO_DebugLevel to 0`.

---

## Test 1 — penalties should subtract, not add ⭐ most important

Devotion applies penalties as toggled effects. This checks they subtract the
right amount and fully undo themselves when removed.

1. Console: `player.getav onehanded` → **write the number down.**
2. MCM → Devotion → **Debug: State & Rewards** page → scroll to the
   **Disfavor (dislikes)** section:
   - Cycle **domain** to `4 WarHonor`
   - Set **band** to `Light`
   - Press **Apply domain sting**
3. Console: `player.getav onehanded` again.
   - ✅ Expected: **exactly 3 lower** than step 1.
   - ❌ Report it if it went **up**, or didn't change.
4. Check **Magic → Active Effects** — you should see *"Honor recoils for a while."*
5. MCM → **Clear active disfavor**.
6. Console: `player.getav onehanded` → must be **exactly** your step 1 number.
7. **Repeat steps 2–6 three or four times.** The number must land on the same
   value every single time. If it drifts a little further each cycle, that's the
   bug we're hunting — tell me immediately.

**Then do the same thing again with a different one:** set domain to
`2 DeathAncestors`, band `Light`, and watch `player.getav destruction`
(down by 2, back to baseline). Same pass/fail rules.

---

## Test 2 — curse music

1. Go inside an inn and listen to the normal music for a few seconds.
2. MCM → **Debug: State & Rewards** → **Curse werewolf**.
   - ✅ Expected: one short sound, then the **normal inn music continues**.
   - ❌ Report it if dungeon/combat music takes over and stays.
3. Walk outside and back in — music should still be normal.
4. Same page → **Curse none**. One short sound, music stays normal.

---

## Test 3 — menu safety

1. Visit each MCM page in turn: **Player → Settings → Status → Debug: State &
   Rewards → Debug: Pacing & Pantheons**.
2. Go back to **Player** and press two or three controls you've already used.
3. ✅ Expected: each control does its own thing.
4. ❌ Report it if pressing something makes an **unrelated** thing happen — a
   message about a god you didn't touch, a reset you didn't ask for, anything
   surprising. That's the exact bug this build fixes, so it's worth watching for.

---

## Test 4 — normal play still works

Just play for 10–15 minutes. Kill some bandits, pick a lock, read a book,
craft something.

- ✅ Expected: occasional pop-up notifications about gods noticing what you did.
- ❌ Report it if you get **no notifications at all** across that whole stretch,
  or if you get a **flood** of them.

---

## Test 5 — praying at a shrine

1. Load your save, and within the first minute or so pray at any shrine.
2. ✅ Expected: you get some acknowledgement (a notification or piety gain).
3. ❌ Report it if praying does nothing at all.

---

## Optional — only if it applies to you

- **Big monitor (1440p or 4K):** do the corner pop-ups look readable, and stay
  up long enough to read? They were about half size before.
- **Bard mod (Become a Bard / Skyrim's Got Talent):** perform, fully quit
  Skyrim, relaunch, perform again. The second performance should still register.

---

## Please don't press

**"Repair stats"** on the Player → Maintenance page. It clears permanent stat
modifiers — including ones placed by *other* mods on your character. It's meant
for repairing damaged old saves and isn't part of this test.

**"Check stat damage"** right next to it is safe — it only reads and reports.

---

## What to send back

For each test: **pass**, or what went wrong.

For Test 1, please include the actual numbers — your baseline, the value after
the sting, and the value after clearing, for each repeat. Those numbers are the
most useful thing in the whole packet.

If anything crashes or you see a wall of error text, note roughly what you were
doing at the time.
