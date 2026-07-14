# Race Guide Nexus-Final Pass - Cut List and Findings (2026-07-14)

The 10 player race guides (`docs/player-guides/races/*.md`) were taken from review
artifacts to shipping player copy for the Nexus 1.0 release. This is the owner-facing
record of **what was cut, what was found, and what still needs a decision**.

Deliverables:

- `docs/player-guides/races/*.md` - shipping copy. No review tags, no scaffolding, no
  internal identifiers, ASCII-only, numbers regenerated from the shipped records.
- `dist/nexus-articles/*.bb` - paste-ready Nexus BBCode (Nexus has no `[table]` tag, so
  tables render as native `[list]` blocks).
- `tools/pdv_guide_tables_gen.mjs` - generates the bonus tables from the per-race reward
  specs. Re-run it after any balance change and the guides can never drift again.
- `tools/pdv_guide_bbcode.mjs` - converter **and release gate**: hard-fails if any review
  tag, HTML comment, or non-ASCII character reaches shipped copy. `--check` to gate only.
- The stale review artifact moved out of the player-facing tree to
  `references/authoring/PDV_WiredVsStub_ReviewSummary_2026-07-07.md`.

---

## READ THIS FIRST: the cut list is a list of CANDIDATES, not proven-dead features

The cuts below were driven by the `[STUB]`/`[INERT]` tags in the 2026-07-07 wired-vs-stub
review. **Those tags are now demonstrably stale, and they are stale in the dangerous
direction: they under-report wiring.** Four independent passes traced live callers for
lanes the tags called dead:

| Tagged dead | Actually live | Traced to |
|-------------|---------------|-----------|
| Breton knightly-vow honour system | **LIVE** | `DamageBretonPracticePressure` is reached organically from every scored action (ActionRouter + EventBus) |
| Khajiit road-home rest, caravan aid, moon rite | **LIVE** | outdoor-sleep route; caravan route; `PDV_ObserveMoonsEffect` is a real sky-watching rite |
| Bosmer Bandit Road reversal | **LIVE** | first drop below 20% health in combat routes a real gap award |
| Orc Blood-Kin | **LIVE** | dispatched as of commit `97ac3065` |

The Breton case is the warning: **I briefed that agent that the honour mechanic was inert
(from the stale artifact). It checked the code, refused, and kept the mechanic.** Had it
obeyed, a working system would have been deleted from the guide.

**Therefore: before wiring anything on the cut list, reproduce it.** Some entries are
already wired and only need re-tagging. This is the same lesson as the 37 undispatched
signals - three of four layers present makes a feature *look* finished.

---

## The wire-or-accept cut list

Grouped by how much it costs the race to lose. Each entry is a promise the guide no
longer makes.

### Tier 1 - a race's headline identity deed, now missing

| Race | Cut promise | Impact |
|------|-------------|--------|
| **Nord** | **Defying the Talos ban** - helping a worshipper, using a hidden shrine, refusing to report the faithful. Top-3 deed in the old guide. | Nord's signature act. Talos piety now comes only from combat, dragons, Words, and quest rows. |
| **Imperial** | **Serving the civic order** as an earnable act, plus 7 of the 8 acts that were supposed to move the Concordat standing. | The Concordat is now a one-lever mechanic. Imperial's advertised signature system reads thin. |
| **Orc** | **Quality work at the stronghold forge.** It is also the only forge path that stamps a life-mode signal - so a Stronghold Orc who forges daily still slides into neglect. | Fixes the earn AND the neglect framing in one wire. Highest-value Orc target. |
| **Bosmer** | **The respectful hunt** (clean, stalked, first-arrow kill) and forest restraint - both Old Contract lanes. | The strictest path now earns from only three things. Choosing "the hardest path" gives you the least to do. |
| **Redguard** | **Honorable single combat** (Leki), **the Far Shores token**, **Hall of the Dead duty**. | See the neglect bug below - this may be worse than a content gap. |
| **Altmer** | **"Observe the dawn"** as a rite. It only ever fired from reading books. | Copy inversion, now fixed; the dawn is gone as an act. |

### Tier 2 - flavour lanes, safe to accept as cut

Khajiit dawn/dusk threshold rite and Alkosh "order-keeping choices"; Dunmer diaspora
solidarity, Boethiah odds-survival, Mephala Grey-Quarter protection and secret-keeping;
Altmer Syrabane warding, Xarxes record-keeping, Trinimac orthodoxy; Breton uncompensated
help, Daedric/nature/standing-stone visits; Argonian Saxhleel protection and the Sithis
void-milestone; Orc exile-return, endurance, oath-breaking, self-erasure; Nord marriage,
homesteading, prisoner-freeing.

---

## Bugs found (these are NOT copy problems)

Two already have task chips. The rest are new.

**Already chipped:**
1. **8 blessing spells still named "- Faithful"** in the live ESP (retired tier vocabulary
   the player reads in Active Effects). Two are on a *Seeker*-tier record.
2. **37 curated signals declared + scored + phrased but never dispatched** - including
   Shor, Leki, Talos, which were believed done. The missing layer is always the trigger.

**New, found during this pass:**

3. **19 blessing records the manager refuses to grant, but which the specs and ESP still
   carry.** `SyncRaceRewardSpell(..., False, ...)`, labelled "retired" / "T1 compatibility":
   Imperial's 9 patron Seeker tiers, Nord's 5, Breton Tradition T1+T2, Argonian Hist
   T1+T2+Signature. The guides were about to advertise every one of them. The generator now
   suppresses them (`NEVER_GRANTED` + the `runtimeStatus` flag).

   **RESOLVED - NOT A BUG (owner, 2026-07-14).** The consequence - *a patron's blessing
   begins at Devoted; there is no patron Seeker tier* - is **intended and stays**. The 19
   are retired-compatibility records kept so old saves do not break. The guides now state
   the Devoted-start rule plainly (Devotion_Overview, How_Devotion_Works, Nord, Imperial).
   **A future audit that flags these as "unreachable, wire them" is wrong.**

4. **Altmer: the crisis may have no exit.** The resolution routine is defined and never
   called, and a discipline boon is suppressed while a crisis is open. If nothing closes the
   crisis, an Altmer who is declared Dragonborn loses that boon **permanently**. Reproduce.

5. **Redguard: possible permanent neglect.** Ancestor-distance neglect trips after 5 days
   with no sect signal - but all three sect signal lanes are dev-only. If the named-undead
   kill does not also stamp the sect clock, a normal Redguard is permanently neglected, with
   a permanent magic-resistance penalty and no in-game way to clear it. **Reproduce before
   release - this is the most serious find in the pass.**

6. **Nord: Shor's Champion last-stand save appears to be gone.** The shipped record generates
   stats only. Matches the known "reward-author drops capstone save on converted MGEF" pattern.

7. **Khajiit: all five Champion "signature moments" do not exist.** The wind that builds
   speed, Azurah's foresight ward, Baan Dar's cheat-death, Rajhin's shadow-slip, Alkosh's
   roar. The Champion records carry stat effects only. Five capstone fantasies, nothing behind
   them.

8. **Orc: `PDV_SPEL_OrcHearthHeld` is double-dead.** Never granted, *and* its effect is a
   `StaminaRateMult` that the Requiem conversion missed - so it would do nothing even if it
   were granted.

9. **Altmer: the Orthodox start is a trap.** It takes 1.5x Lorkhan pressure, and every organic
   track mover is negative - there is no organic way to defend the position that earns it.

10. **Breton: Akatosh's Endurance and Julianos's Insight are identical** (Fortify Magicka +40,
    Magic Resistance +15%). Looks like a copy-paste in the champion-boon authoring.

11. **Imperial: the quest matrix is badly under-promoted.** The review's promoted counts
    (e.g. Stendarr 8) are far below the shipped CSV (Stendarr 45). The guides deliberately
    under-report. A re-promotion pass would add a lot of real content for free.

**Checked and NOT a bug:** the Argonian Void-Held near-death burst is a `StaminaRateMult`
spell, which is inert under Requiem - but the manager already pairs it with a flat
`RestoreActorValue("Stamina", 100.0)` for exactly that reason. Working as intended. Its
spec `playerFacingText` ("Stamina returns 50% faster") is misleading, though.

---

## Copy inversions fixed (the guide said the opposite of the truth)

- **Argonian:** "brief generic swimming does not count" - swimming is *the* Argonian
  maintenance act, the only swim mechanic in the mod. Now leads the guide.
- **Imperial:** dragon-slaying was listed as an Akatosh *gain*. It is Talos +1.5 and
  Akatosh **-0.75**. Moved to the loss list.
- **Nord:** a clean animal hunt was listed as a Kyne *gain*. Killing beasts is a Kyne
  **penalty**. Also: werewolf/neglect effects only bite *after* a god has claimed you.
- **Breton:** the Hidden Art's curated god is **Magnus**, not Julianos; the Green Way's is
  **Y'ffre**, not Kynareth. Both were mis-attributed.
- **Bosmer:** the Bandit Road hook rewards *dropping below a fifth of your health* - win or
  lose. The guide demanded a win.
- **Orc:** "raw spam at a workbench does not count" - generic smithing IS the wired earn;
  the curated "quality" lane is the dead one. Exactly backwards.
- **Altmer:** the alignment track was framed as a two-way meter. Every organic mover is
  negative. Rewritten one-directional, which reads better as theology anyway.
- **Dunmer:** carrying a Daedric artifact was framed as betrayal. It is a **positive** for
  Boethiah and Mephala.

---

## Follow-ups worth doing before launch

- Re-tag the wired-vs-stub artifact, or retire it. Anyone working from it will cut live code.
- Reproduce findings 4 and 5. Both are potentially unescapable player states.
- `--penalties` mode on the table generator: neglect/creed-loss magnitudes are still
  hand-copied from the specs and unverified against the ESP.
- Imperial quest-matrix re-promotion (finding 11) - cheapest content win available.
