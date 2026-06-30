# PDV In-Game Run-Sheet -- Universal Prisma Surfaces (V1)

Status: V1 (Unit D live `5e9e502`). Created 2026-06-25. Sources: `PDV_PrismaParityRegistry.csv`,
`PDV_PrismaParity_AuthoringDraft.md`.

Run this **once per character**, alongside any race sheet. It proves the Prisma pieces every race shares --
the three spaces and the panel itself. Each test is **Do / See / Record**. Tags: **[Tester]** = play/click;
**[Dev]** = needs console or a log check (owner).

The three spaces: **Toast** = the pop-up that flashes top-of-screen; **Book of Days** = the modal journal
(Chronicle page); **Ledger** = the modal "what feeds your gods" (per-god list of recent reasons).

---

## Preflight (do once)
1. **New save** (or `coc qasmoke`). 2. MO2 **Anvil**; `Devotion - Living Deities Test` **disabled**.
3. Console: `set PDV_GLO_OriginRace to <your race index>` and `set PDV_GLO_DebugLevel to 2`.
4. Seeds = the **MCM -> Devotion -> Developer Options** page (not `cqf`).

## Running in Authoria (Requiem) -- same steps, swap the preflight
Same tests, same expected surfaces. Use the **Authoria** instance; **skip** the Living-Deities disable (not in
that list); everything else is identical. Authoria is also where you judge **HP-bar reward feel** (Requiem
zeroes regen buffs, so flat heals must show the bar move here).

---

## Tests

### U1 -- panel and Book of Days open, focus, and close  [Tester] [R]+[M]
- **Do:** the **first** time this session, open the Devotion panel (hotkey/MCM). Try **ESC** and the in-panel
  **X**. Re-open; switch **Chronicle <-> Ledger**; ESC again. Then open **Book of Days** and close it with
  the **same Book of Days key**. Re-open with the key, close with the in-book close button, then press the key
  again and confirm it **opens**. Re-open once more, close with **ESC**, then press the key again and confirm it
  **opens**.
- **See:** each surface opens **already filled in and focused** (not a blank frozen screen), and **ESC always
  gives you control back**. The Book of Days has a visible close button. Closing by key, X, or ESC never leaves
  the key stuck in a stale "close" state; the next key press opens the book.
- **Record:** ___

### U2 -- tier-ups (Seeker / Devoted / Champion)  [Tester] [R]+[M]
- **Do:** MCM Debug -> Force Piety on your patron to **25**, **Run Dawn**. Repeat at **50**, then **85**.
- **See:** each step pops a **toast** and writes a **Book of Days** entry; at **Champion (85)** the Book of Days
  entry is **pinned** (it won't get pruned later). No double entries on re-cross.
- **Record:** ___

### U3 -- daily favor + the dawn digest  [Tester] [R]+[M]
- **Do:** MCM Debug -> award your patron a curated signal (so the day has activity). **Run Dawn.**
- **See:** acts for your **active patron** flash a favor toast (other gods stay quiet); at dawn a **"dawn"**
  toast + a **Book of Days "the day's devotions"** line naming up to 3 gods. No spam of one-line entries.
- **Record:** ___

### U4 -- the Ledger + the substrate-driver fix  [Tester] [R]+[M]
- **Do:** after a few awards, open the panel -> **Ledger**. Then award a **substrate** act for your race (e.g.
  the Argonian Hist potion, a Khajiit lunar act). Re-check the Ledger.
- **See:** the Ledger lists **driver rows per god** (the reason + how many + net). **Crucially**, the substrate
  act now shows a row -- before the fix these were invisible. (A Prince you're building toward shows a "watching" row.)
- **Record:** ___

### U5 -- the Book of Days + pruning  [Tester] [R]+[M]
- **Do:** open the panel -> **Chronicle**. Read the entries. Then sleep/wait **22+ in-game days**.
- **See:** entries read like a journal (right god symbol, narrator voice). After 21 days, **ordinary entries
  drop off**, but **milestones** (Champion, curse, path/tradition changes, accepted/refused offers) **stay**.
- **Record:** ___

### U6 -- neglect drop  [Tester] [R]+[M]
- **Do:** MCM Debug -> set your patron's piety to **0**. **Run Dawn.**
- **See:** a **"rites thinning / neglect"** toast + a Book of Days note, once, on the first lapse.
- **Record:** ___

### U7 -- neglect recovery  [Tester] [R]+[M]
- **Do:** after U6, MCM Debug -> award your active patron one curated signal, set patron piety to **15**,
  then **Run Dawn**. Use 15 so this proves recovery without also proving a Seeker tier-up.
- **See:** a recovery / renewal beat appears in the player-owned Prisma surfaces, with no forced full panel.
  Book of Days / Chronicle text is readable and not blank. The old neglect line does not repeat as a fresh lapse.
- **Record:** ___

### U8 -- how it reads  [Tester] [M]
- **Do/Write:** 1-2 sentences. Do the three spaces feel like **one record** (same beat, same symbol/voice across
  toast + Chronicle + Ledger)? Do toasts read over a busy background? **Any beat that double-fired, hit the wrong
  space, or showed a BLANK line?** (A blank Book of Days line is a bug -> FAIL it.)
- **Record:** ___

---

## Record results here
| Test | What it proves | Status | Note |
|---|---|---|---|
| U1 panel/Book close | cold open focuses; ESC/X always release | | |
| U2 tier-ups | toast + BoD each tier; Champion pinned | | |
| U3 favor + digest | patron favor toasts; dawn names the gods | | |
| U4 Ledger + substrate fix | driver rows incl. substrate; watching row | | |
| U5 Book of Days + prune | legible; ordinary prune, milestones persist | | |
| U6 neglect | toast + BoD once on first lapse | | |
| U7 neglect recovery | recovery beat surfaces; no repeat lapse or forced panel | | |
| U8 reads | one coherent record; no blank/double/wrong-space | | |

Owner: capture the Papyrus + `DevotionPrismaBridge` logs, record into `PDV_V1_BetaReadinessGate.md`.
