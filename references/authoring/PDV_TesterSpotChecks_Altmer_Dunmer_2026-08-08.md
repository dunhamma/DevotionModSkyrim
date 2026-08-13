# Tester spot checks -- Altmer and Dunmer (2026-08-08)

Short passes, not the full runbook. Each is 10-15 minutes. Report what you saw, not what you
expected -- "nothing happened" is a useful result and we need it stated plainly.

## Before you start -- please read, it decides whether your results mean anything

**Use a NEW character.** Some of this content is attached to the mod's quest at the moment a
character is first created. On a character made before this build, those attachments are empty and
the feature will look broken when it is not. On a new character everything binds correctly.

If you must use an existing character, say so on every result you report. A failure on an old save
proves nothing; a failure on a new one is a real bug and we want it.

Turn notifications ON in the Devotion MCM. The whole layer is gated on them.

**One more:** if you get a burst of unrelated Devotion messages when you open the MCM, wait a minute
and let them finish before starting. Leftover queued messages look exactly like live results.

---

## Altmer -- the calian and the daily practice

The calian is a small prayer-focus item every Altmer carries.

1. **Open your inventory and find "Calian."** It should render as a sphere and be properly textured.
   *A purple or untextured model is a bug -- report it.*
2. **Click it.** Your character performs a short practice (a prayer pose, or a reading pose if your
   patron is Magnus, Xarxes or Syrabane), and a line is written into the Book of Days.
3. **Click it again the same day.** You should be told it is *already warm from today's practice*.
   *Silence here is a bug -- this moment used to do nothing at all.*
4. **Drop the calian, then reopen your inventory.** It returns to you. The first time it comes back
   you should get a line about having carried it since you were eighteen.
5. **Drop it once more.** It returns again, and that carried-since-eighteen line should **not**
   repeat. *A repeat is a bug.*
6. **Over three separate days, click the calian once each day.** The practice line should differ each
   day, and should never repeat two days running. *The same line twice in a row is a bug.*
7. **Curse check.** MCM -> Debug: Daedric & Curse -> `Curse vampire`, then click the calian: it
   should refuse you. Restore with `Curse none` afterwards.

**Known and not a bug:** the calian's inventory *description* only appears if you have Description
Framework installed. If you do not, an empty description is expected.

### Altmer, if you have time -- the recurring Champion line

Reach Champion standing with one Altmer god, then sleep four days. You should get exactly **one**
short corner message. Sleep one more day and you should get **nothing**. Then sleep four more and it
returns. *A line every day is a bug; never any line is a bug.*

---

## Dunmer -- the ancestral urn

**This one is brand new and has never been tested by anyone. You are the first look, so please be
precise about what appears and what does not.**

The urn is a reusable item you keep in your inventory and pray at.

**Do this part WITHOUT choosing a patron god.** That is the whole point of the test -- praying with
no patron is the case that used to record nothing.

1. **Check the urn stays in your inventory after praying.** *If the count drops or it disappears,
   stop and report it -- that is a serious bug.*
2. **Pray at the urn.** You should see progress on your ancestor standing, **and** an entry appear
   recording why you gained standing. *The second half is the new thing. If standing moves but
   nothing records why, that is the bug we are hunting.*
3. **Pray again the same day.** Standing may still move a little, but you should **not** get a second
   "why" entry. *A second one is a bug.*
4. **Sleep past 6am, then pray again.** The "why" entry should come back. *If it never returns, that
   is a bug.*
5. **Now choose a Dunmer patron** (Azura, Boethiah or Mephala) and pray again. You should get the
   usual patron response **and** the ancestor entry. They are separate things and both should appear.
6. **Curse check.** MCM -> Debug: Daedric & Curse -> `Curse vampire`, then pray: you should get
   **nothing at all** -- no standing, no entry. Vampirism cuts an ancestor off completely, by design.
   Restore with `Curse none`. Under `Curse werewolf` instead, praying should still work but count for
   less.

---

## What to send back

For each numbered step: **what you actually saw.** Screenshots help, especially for anything with
text in it.

Please also tell us:

- whether you used a new character or an existing one
- your race and whether you had a patron god at the time
- for the Dunmer test, whether the "why" entry appeared on the very first prayer with no patron

If something surprised you, say so even if you are not sure it is a bug. Several real defects this
week were found by someone saying "this felt wrong" rather than "this is broken."
