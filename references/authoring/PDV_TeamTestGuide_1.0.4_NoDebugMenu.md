# Devotion 1.0.4 — team test guide (no debug menu)

For the mod team. Every test below uses **`coc` (teleport) and standard vanilla
console commands only** — nothing from Devotion's own debug pages. Two checks
near the end are the only exception, clearly marked, because they need a game
state that's genuinely hard to guarantee without either a debug forcer or a
long real playthrough.

This is an **unreleased build**. Use a save you don't mind losing.

## Setup

1. Install `Devotion-1.0.4-20260726.zip` as a normal mod.
2. **Place `Devotion.esp` manually, late in your load order** — don't let LOOT
   sort it.
3. Start a **new game**.
4. Console: press **`~`** (the key left of `1`, above Tab). Type a command,
   press **Enter**, press **`~`** again to close. (`` ` `` on some layouts.)
5. Check MCM → Devotion → Player shows **Version 1.0.4**.

---

## Test 1 — curse: no persistent dungeon music

Devotion used to replace your music entirely, with dungeon tracks, for as
long as you were "cursed" (vampire or werewolf) — even in an inn. This checks
that's gone.

1. `coc WhiterunBanneredMare` — you're now in the inn. Listen for ten seconds.
2. Console: `player.addspell ed0a8` — this is Skyrim's actual vampirism ability
   (the same spell a real infection grants); Devotion reads it the same way
   it would read a real vampire.
3. ✅ Expected: **one short sound**, then the inn music **keeps playing
   normally**.
   ❌ Fail: dungeon/combat music takes over and doesn't stop.
4. Wait ~20 seconds, still listening. Walk outside, then back in — still
   normal music both places.
5. Console: `player.removespell ed0a8` (cures the "vampirism" as far as
   Devotion is concerned).
6. ✅ Expected: one short cure sound, music unaffected.

**Werewolf variant (optional, same idea):** `player.addfac 91822 0` to add the
werewolf state, `player.removefac 91822` to remove it. Same pass/fail rules.

---

## Test 2 — the vampire-cure message (read carefully — one part is *supposed* to look odd)

1. Still in the Bannered Mare (or anywhere). `player.getav magicresist` — note
   the number, but this is Redguard-specific, so this full test only applies
   if your character is a **Redguard**. If not, skip to Test 3.
2. `player.addspell ed0a8`, then `player.removespell ed0a8`.
3. A message should appear when you cure it. **Copy down the exact wording.**
4. ✅ The message should say the ancestors' protection returns once you take up
   the "death-duty" again.
5. ✅ **A −3 Magic Resist penalty staying in place after the cure is correct,
   not a bug** — it's meant to hold until you re-enter that duty in game.
6. ❌ Only report a problem if the message is missing, cut off, or shows raw
   symbols like `%s`.

---

## Test 3 — Green Pact: Bosmer eating meat is now rewarded

Previously, meat and insects were supposed to reward a Wood Elf keeping the
old pact, but the list of qualifying food was empty — nothing could ever
match. That's fixed. This test also needs no debug tool: origin is read from
your actual race.

1. `showracemenu` → pick **Wood Elf** → confirm and close the menu (this is
   how you'd actually play a Bosmer; Devotion re-detects your race the moment
   the menu closes, same as it would for a real character).
2. Console: `player.additem 065C99 1` (Raw Beef) or `player.additem 0721E8 1`
   (Cooked Beef) — either works.
3. Eat it from your inventory.
4. Open `Papyrus.0.log`:
   ```
   C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
   ```
5. ✅ Search for `Green Pact meat food positive routed.` — that line appearing
   is the pass. (Whether it also shows a piety line for Y'ffre depends on
   whether you've triggered this same signal already today — a shared daily
   throttle applies across several Green Pact and pact-loyalty triggers, so a
   missing piety line on a second attempt same day is expected, not a fail.)
6. ❌ Fail: the line never appears.

**Reminder for the eating-plants side (already working, not new):** eating a
listed plant as a Bosmer should cost piety instead — that's the existing
Green Pact violation, unchanged by this release.

---

## Test 4 — Daedric artifacts still signal their Prince

Equipping a Daedric artifact should register with Devotion, the same as any
other faucet interaction. This confirms the routing table (which changed
significantly this release) still recognizes real game items — it does
**not** by itself jump you to a full pact tier; reaching Seeker/Devoted/
Champion needs sustained worship over real play, same as before.

Pick any one:

| Prince | Item | Console command |
|---|---|---|
| Boethiah | Ebony Mail | `player.additem 052794 1` |
| Molag Bal | Mace of Molag Bal | `player.additem 233e3 1` |
| Meridia | Dawnbreaker | `player.additem 4e4ee 1` |
| Sheogorath | Wabbajack | `player.additem 2ac6f 1` |
| Hircine | Savior's Hide | `player.additem 2ac61 1` |

1. Add and **equip** the item (armor: wear it; weapon: it's enough to have it
   equipped in a hand).
2. Check `Papyrus.0.log` for a line containing `RouteQuestReactionFaucet` or
   `RouteDaedricPrinceSignal` with that Prince's name.
3. ✅ The line appearing is the pass.

---

## Test 5 — 4K / high-res toast size and box shape

(Skip if you're not on a 1440p or 4K display.)

1. Do anything that triggers a Devotion notification — Test 3 or Test 4 both
   work, or just play normally for a few minutes.
2. ✅ Text should be visibly larger than a normal 1080p toast, and the box
   should size itself to the message — a short toast should NOT have a large
   empty gap on the right.
3. ❌ Report it if the box still looks oversized/empty for a short message.

---

## Test 6 — shrine prayer still credits piety

1. `coc WhiterunTempleOfKynareth`.
2. Activate the shrine and pray.
3. Check `Papyrus.0.log` for `RouteShrinePrayer complete`.
4. ✅ That line appearing is a pass **if** the deity is one your character's
   race actually reveres — Kynareth/Kyne credit Nord, Imperial and Breton
   characters; they will NOT credit, say, a Dunmer, and that's correct
   behaviour, not a bug. If you want a guaranteed-credit shrine for your race,
   ask before assuming a "no credit" result is a failure.

---

## Optional, needs the debug menu (the only exception in this document)

These two need a game state that's genuinely impractical to force with a
single console command — one needs a very specific disliked action logged
against an active patron, the other needs a lot of real accumulated piety.
If you want a fast, deterministic check rather than playing it out over real
time, unlock the debug pages:

```
set PDV_GLO_DebugLevel to 3
```
Then fully close and reopen the MCM (it only rebuilds its page list on open).

- **Stat-penalty stings apply and fully clear** — Debug: State & Rewards →
  Disfavor (dislikes) → domain `4 WarHonor`, band `Light` → Apply domain
  sting → confirm `player.getav onehanded` drops by exactly 3 and returns to
  baseline after Clear active disfavor.
- **Daedric price tiers** — Debug: State & Rewards → pick a Prince → Force
  Seeker/Devoted/Champion → confirm your maximum Health/Magicka/Stamina
  changes, and Force lapse restores it exactly.

Set `PDV_GLO_DebugLevel` back to `0` when you're done if you don't normally
run with it on.

---

## Reporting back

For each test: pass, or exactly what you saw. For Tests 1–4 and 6, a copy of
the relevant `Papyrus.0.log` lines is the most useful thing you can send back.
