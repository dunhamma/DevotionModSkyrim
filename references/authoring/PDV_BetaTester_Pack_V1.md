# Devotion (PDV) -- V1 Beta Tester Pack

Welcome, and thank you for testing. **Devotion** tracks your character's faith through their race, their
deeds, the patron (or Daedric Prince) they commit to, and the world around them -- and surfaces it through
three in-game "spaces" (a pop-up **Toast**, a **Book of Days** journal, and a **Ledger** of what's feeding
your gods). Your job is to confirm the features **work** and **feel right** in real play.

This pack is a set of run-sheets. You don't need to be a modder -- each test is written as **Do this -> you
should see that -> mark it**.

---

## Before you start (once)
1. **Start a brand-new character** of the race you're testing. (Devotion only sets up on a fresh save.)
2. Tell the mod your race so the test hooks turn on -- open the console (`~` key) and type:
   ```text
   set PDV_GLO_OriginRace to <your race number>
   set PDV_GLO_DebugLevel to 2
   ```
   Race numbers: **0** Nord · **1** Imperial · **2** Breton · **3** Altmer · **4** Bosmer · **5** Dunmer ·
   **6** Khajiit · **7** Argonian · **8** Orc · **9** Redguard.
3. Some tests use a **Debug page** to set things up fast: open the **MCM** (mod config menu) ->
   **Devotion -> Developer Options**. The buttons there are labelled by what they do (e.g. "Force Piety",
   "Run Dawn"). You never need to type `cqf`.
4. (Only on the standard list) make sure the mod `Devotion - Living Deities Test` is **disabled** in your mod manager.

## How to read a run-sheet
- Each test is **Do** (the steps), **See** (what should happen), **Record** (write PASS / FAIL / PENDING / N-A
  in the table at the bottom).
- **[Tester]** tests anyone can do by playing or clicking. **[Dev]** tests need the console or a log -- skip
  those unless you're comfortable; the team will cover them.
- The **three spaces** to watch: **Toast** = the little pop-up that flashes at the top; **Book of Days** =
  the journal page in the Devotion panel; **Ledger** = the "what feeds your gods" page in the panel.
- **A blank Book of Days line is a bug** -- if a journal entry shows up empty, mark it FAIL and note it.

## What to run
1. **Everyone:** the **Universal Prisma checklist** once on your character (the shared panel / journal / ledger checks).
2. **Your race's sheet** (below).
3. If you commit to a **Daedric Prince**, also run the **Daedric** sheet.

## Running on the Requiem list (Authoria)
Every sheet has a **"Running in Authoria (Requiem)"** note. Short version: the tests and what you should see are
**the same** -- just use the Authoria mod list, skip the "disable Living Deities Test" step, and everything
else is identical. If a reward is a **heal**, the Requiem list is the best place to confirm the **HP bar
actually moves**. Likewise, the magicka/stamina rewards are now flat **Fortify
Magicka/Stamina** pool boosts (2026-07-13) -- on the Requiem list confirm the
**Magicka/Stamina bar MAX rises** in Active Effects, the same way heals move the HP bar.

## Reporting back
- Fill the **Record results here** table at the bottom of each sheet.
- For anything odd, jot a sentence: what you did, what you saw, what you expected. Screenshots of a toast or
  journal entry are gold.
- The **"how it felt"** test on each sheet matters as much as the pass/fails -- tell us if something read
  oddly or didn't feel earned.

---

## Run-sheet index
**Start here:** [Universal Prisma checklist](PDV_RunSheet_Universal_Prisma_V1.md)

**Your race:**
[Nord](PDV_RunSheet_Nord_V1.md) ·
[Imperial](PDV_RunSheet_Imperial_V1.md) ·
[Breton](PDV_RunSheet_Breton_V1.md) ·
[Altmer](PDV_RunSheet_Altmer_V1.md) ·
[Bosmer](PDV_RunSheet_Bosmer_V1.md) ·
[Dunmer](PDV_RunSheet_Dunmer_V1.md) ·
[Khajiit](PDV_RunSheet_Khajiit_V1.md) ·
[Argonian](PDV_RunSheet_Argonian_V1.md) ·
[Orc](PDV_RunSheet_Orc_V1.md) ·
[Redguard](PDV_RunSheet_Redguard_V1.md)

**If you walk a Daedric path:** [Daedric Princes (all 16)](PDV_RunSheet_Daedric_V1.md)

---

## Known "not yet" -- please DON'T report these as bugs
- **Experience Mode** (an easier/harder difficulty toggle) isn't in V1 yet.
- Some rewards still live in a **test cell** rather than their final world spots -- that's a release-polish step;
  the rewards themselves work.
- A **Far Shores token** (Redguard) is planned for a later version -- it's intentionally not here.
- A few **Daedric Princes** are still having their final in-game proof recorded -- if a Prince beat looks
  incomplete, flag it and we'll confirm.
- The **6f discipline rites** (e.g. Orc Trial of Iron) use a plain top-left notice, **not** a Prisma toast --
  that's intentional, not a miss.

Thank you -- this is the pass that gets Devotion ready. Have fun with it.
