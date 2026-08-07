# Merged in-game runbook -- 2026-08-07

Supersedes nothing; it **sequences** two existing packets and adds the surfaces wired today.
Source packets, still authoritative for their own detail:

- `PDV_TestPacket_P11_Ambient_And_P17_Pacing_2026-08-06.md` (Altmer: calian, Champion ambient,
  heritage band, P17 cadence sizing, copy-in-situ)
- `PDV_KhajiitLunarChampionRebalance_InGameRunbook_2026-08-06.md` (Khajiit: outdoor sleep,
  substrate/focus, rewards/resonance, Azurah's Portent, Baan Dar rescue)

## One honest correction before you start

**This cannot be done on one save.** The two packets need different races, and the two surfaces
wired today need a third. Three characters:

| Session | Race | Covers | Rough cost |
|---|---|---|---|
| **1** | Nord | the two surfaces wired today (`d6759eab`) | ~10 minutes |
| **2** | Altmer | P11 Part A-E, P17 sizing | one sitting + ~a week of observed play for P17 |
| **3** | Khajiit | the whole lunar/Champion rebalance runbook | one long sitting |
| **4** | Dunmer | the ancestral-layer Ledger driver wired in `29f5243d` | ~10 minutes |

Session 1 first because it is ten minutes and it proves the VMAD binding path on the newest build
before you invest a long sitting in sessions 2 and 3.

**Fresh save is a hard precondition for all three.** VMAD properties bake at first init. The three
lanes degrade differently, and knowing which is which is the fastest diagnostic you have:

| Lane | On a stale save an unbound property... |
|---|---|
| Altmer ambient (`ShowAltmerNotification`) | falls back to a **Prisma toast** -- visible, wrong surface |
| Nord curse / champion (`ShowNordMessage`) | falls back to `Debug.MessageBox` with the compiled fallback text -- visible, no title |
| Khajiit focus (`GetKhajiitFocusEmergenceMessage`) | shows **nothing at all** -- indistinguishable from a broken feature |

A corner notification or a titled MessageBox means the record fired and the binding resolved.

---

## Front-loaded reference -- pull all of this up before you start

### MCM controls (exact labels, verified against live `PDV_MCM.psc` 2026-08-07)

All debug pages require **Developer Options enabled** first, or the page shows a locked placeholder.

| Page | Exact label | Kind |
|---|---|---|
| Debug: Daedric & Curse | `Curse none` / `Curse werewolf` / `Curse vampire` | state force |
| Debug: State & Rewards | `Target piety` (slider) + `Apply target piety` | **direct-seed** (persistent) |
| Debug: State & Rewards | `Target scratch` (slider) + `Apply target scratch` | **organic mirror** -- shares the daily budget |
| Debug: State & Rewards | `Run dawn pass` | runs `ProcessDawn()` now |
| Debug: State & Rewards | `Khajiit focus -> Baan Dar` / `-> Rajhin` / `-> Alkosh` | force focus |
| Debug: State & Rewards | `Quest reaction queue` | **read-only report** |
| Debug: Pacing & Pantheons | `Race` (cycle) + `Apply test origin` | substrate target selector |
| Debug: Pacing & Pantheons | `Seed 0` / `Seed 24` / `Seed 25` / `Seed 74` / `Seed 75` | **direct-seed** substrate |
| Debug: Pacing & Pantheons | `Trigger approved source` | organic (real handler route) |
| Debug: Pacing & Pantheons | `Reset substrate` | reset |

Two label corrections against the P11 packet, which quotes a UI string that does not exist:
the curse buttons read `Curse vampire` / `Curse none`, **not** "Force the curse state to Vampire?".

**There is no Khajiit focus button for Khenarthi or Azurah** -- only Baan Dar, Rajhin and Alkosh
exist. Reach those two by seeding piety instead (see Session 3).

**There is no drain control for the quest-reaction queue** -- only the read-only reporter. If it is
not idle, play on until it is rather than trying to clear it.

### Records (all `:Devotion.esp`)

Wired today:

| FormID | EditorID | Fires when |
|---|---|---|
| `071523` | `PDV_Msg_Nord_CurseState_WerewolfCured` | Nord, werewolf curse lifted |
| `071526` | `PDV_Msg_Nord_Kyne_ChampionEntry` | Nord, Kyne crosses UP into Champion, once ever |

Altmer P11 set (12 ambient + 2 calian): `0716E5`-`0716F0`, `0716E4`, `071706`, `071707`.
Nord/Kyne recurring ambient: `071525`. Full table in the P11 packet, section "Front-loaded
reference"; it is correct and not repeated here.

### Constants worth having in front of you

- Champion threshold **85**; `LONG_DEVOTION_MARK_STEP = 15`, so **piety 100 = MarkHigh 1**
- `AMBIENT_CHAMPION_CADENCE_DAYS = 4` (devotional days, 06:00 boundary)
- Altmer substrate `HighThreshold = 60`; budget **one `+4.0` credit per devotional day**
- Daily piety clamp **4.3/day**

### StorageUtil keys new today

- `PDV.Nord.WerewolfCureFeedbackShown` -- one-shot guard on the cure message; cleared on a fresh onset
- `PDV.Nord.ChampionEntryShown.Kyne` -- one-shot guard on the Kyne recognition

---

## Session 1 -- Nord, the two surfaces wired today (~10 minutes)

Fresh Nord. Both MESGs (`071523`, `071526`) were confirmed present and already bound on
`PDV__ManagerQuest` VMAD (`00C325`) against **Anvil / Devotion Dev** on 2026-08-07, so a failure
here on a fresh save is a real regression.

### 1.1 Werewolf cure -- read this before you judge the surface

MCM: `Curse werewolf`, then `Curse none`.

**Expect a Kyne-toned Prisma toast reading "The hunt is set down. Hircine's hold is broken, and your
seat on the bridge holds firm once more." -- NOT the MessageBox.** That is correct, not a bug: the
MCM buttons pass `mcm_force_none` / `mcm_force_werewolf`, and `ShouldSuppressNordCurseModal`
deliberately routes forced transitions to a toast so a debug sweep does not throw modals. The
MessageBox ("The Bridge Holds Again") only appears on a real in-game cure.

Before today this branch produced **nothing at all** -- so *any* surface here is the proof.

1. `Curse werewolf` -> onset line appears.
2. `Curse none` -> the cure toast appears. **This is the fix.**
3. `Curse none` again -> silence. That is `PDV.Nord.WerewolfCureFeedbackShown` holding.
4. `Curse werewolf` then `Curse none` again -> the cure line returns, because the onset branch
   clears the cure guard. If step 4 stays silent, the guard is not being cleared.
5. **Vampire path unchanged:** `Curse vampire` -> `Curse none` must still behave exactly as before.
   That branch was not touched; a change there is a regression.

*Optional, only if you are already doing a werewolf playthrough:* take the real cure (Ill Met By
Moonlight) and confirm the titled MessageBox "The Bridge Holds Again" instead of the toast.

### 1.2 Kyne champion recognition

The seed path only surfaces on an **UP-crossing** -- `DebugForceSetPietyByIndex` says so in its own
comment. If Kyne is already at or above Champion, reset her first or nothing will fire.

1. Debug: State & Rewards -> select **Kyne**. If her piety is already >= 85, `Reset` her first.
2. `Target piety` -> a value below 85 (e.g. 40), `Apply target piety`. Confirm the tier is *not*
   Champion.
3. `Target piety` -> **85+**, `Apply target piety`.
4. **Expect all four, in one beat:** the standard tier toast, the Book of Days entry, the Ledger
   feed, **and** the authored modal "Kyne's Recognition" -- "You sleep where the storm sleeps. You
   walk where the wind walks. Kyne has named her hunter."

   The modal is deliberately **additive**: it was wired on top of the universal tier surface rather
   than replacing it, so if the toast or the Book entry went missing that is the regression, not the
   modal.
5. Reset Kyne below Champion and re-seed to 85+. **Expect the modal NOT to repeat** (the toast and
   Book entry may, per their own guards). That is `PDV.Nord.ChampionEntryShown.Kyne`.
6. Do the same seed on a **non-Kyne Nord deity** (Shor, Tsun) -- expect the standard tier surface
   and **no** Kyne modal.

### 1.3 Free while you are here

Take a Nord to Kyne Champion and sleep four devotional days: the recurring ambient `071525` ("The
wind is blowing your way") should arrive on the 4-day cadence, **on top of** the one-shot from 1.2.
The P11 packet lists this as a check and assumed the one-shot already worked; until today it did not.

---

## Session 2 -- Altmer (P11 + P17)

Run `PDV_TestPacket_P11_Ambient_And_P17_Pacing_2026-08-06.md` as written, with these deltas:

- **Part A step 6** says 'MCM -> "Force the curse state to Vampire?"'. The real label is
  `Curse vampire`, on Debug: Daedric & Curse. Restore with `Curse none`.
- **Part C** ("get the heritage metric to `>= 60`"): use Debug: Pacing & Pantheons -> `Race` cycle
  to Altmer -> `Apply test origin` -> `Seed 75`. Do not grind it organically.
- **Part E** references "the `practice_focus` arm, which before `029e641c` fell through to the
  orthodoxy default". That arm was **removed today** (`d6759eab`) as a dead second draw site --
  `AppendAltmerHeritageVoice` intercepts `practice_focus` first and always has. The player-facing
  text is unchanged; the pooled calian lines are still what you should be reading. If you see the
  orthodoxy default ("You upheld the orthodoxy at real cost...") on a calian practice, that is a
  regression worth reporting immediately.
- **New, cheap:** the Altmer practice pool now caches its structural validation per VERSION.
  Draw a calian line on three separate devotional days and confirm the lines still vary and no
  line repeats back-to-back. A frozen or empty line would mean the cache is holding a bad verdict.

Part D (P17 cadence sizing) is observation-only across about a week of play and is the last Altmer
packet. Do not change numbers during the run.

---

## Session 3 -- Khajiit

Run `PDV_KhajiitLunarChampionRebalance_InGameRunbook_2026-08-06.md` as written, with these deltas:

- **Focus forcing is only wired for three of five deities.** `Khajiit focus -> Baan Dar`,
  `-> Rajhin` and `-> Alkosh` exist as buttons; **Khenarthi and Azurah do not.** For the Azurah's
  Portent card and the Khenarthi observation pool, reach focus by seeding piety
  (`Target piety` / `Apply target piety`) to satisfy the `25` weight / `15` lead rule instead.
- **The moon-observation pool now caches its structural validation per VERSION *and* per deity
  key.** The runbook already asks you to "temporarily remove or invalidate the JSON and prove the
  compiled four-line fallback" -- do that test **after** a game restart, not mid-session: the cache
  holds a good verdict within a session once validated, so an in-session file swap may not be seen.
  That is the intended trade (the file is static shipped content), but it changes how that one card
  must be run.
- While cycling god-strength slots, confirm observation lines still vary per deity. A deity showing
  another deity's pool would mean the per-key half of the cache is wrong.

---

## Session 4 -- Dunmer, the ancestral-layer Ledger driver (~10 minutes)

Wired in `29f5243d`. Before it, a Dunmer praying at the portable urn recorded a Ledger driver **only**
with an active patron and **only** on the first prayer of the day; a patronless Dunmer got substrate
progress and an empty Ledger. It now fires on the first prayer of the devotional day regardless of
patron, because it feeds the ancestral layer rather than the Reclamation lane.

Fresh Dunmer, and deliberately **do not commit to a patron** -- the whole point is the patronless case.

1. Pray at the ancestral urn (the reusable MISC token; it must stay in inventory -- if the count
   drops, that is its own FAIL per the Dunmer run sheet).
2. **Expect a Ledger driver.** Before this fix, with no patron, there was none. Also expect the
   substrate toast "Ancestor prayer marked." as before.
3. Pray again the same day. **Expect no second driver** -- the pulse self-caps to one per devotional
   day. The substrate side still decays normally by its own repeat multiplier.
4. Cross 06:00 and pray again. **Expect the driver to return.**
5. Now commit to a patron (Azura, Boethiah or Mephala) and pray. Expect the Reclamation-memory
   signal as before **and** the ancestral driver -- they are separate lanes, not a double pulse on
   one lane.
6. **Curse check:** MCM `Curse vampire`, then pray. Vampirism silences the ancestral layer entirely,
   so **expect no driver and no substrate progress**. Restore with `Curse none`.

Under the beast (`Curse werewolf`) the layer is halved rather than silenced, so the driver should
still appear.

## Traps that will waste the sitting

1. **Confirm `Quest reaction queue` reports idle before any MCM sitting.** A stray queued toast reads
   exactly like a live award and has caused false bug reports before. There is no drain control.
2. **Organic debug buttons share the daily budget.** `Apply target scratch` and
   `Trigger approved source` are organic; a second press the same day silently no-ops. Use
   `Apply target piety` and the `Seed NN` buttons when you need a specific state.
3. **`coc` skips Story Manager location-change triggers.** Walk in through a load door.
4. **The substrate takes one credit per devotional day whatever claims it.** A second act granting
   nothing is the design.
5. **A tier seed only surfaces on an up-crossing.** Reset before re-seeding.
6. **Confirm the MO2 instance before any readback that becomes a claim.** Everything above assumes
   **Anvil / Devotion Dev**. ARR 2.5 is a different build and served four-day-old records last
   session, producing two false RED results.

---

## What to bring back

**Session 1 (blocks nothing else, but it is today's proof):**
- Werewolf cure: did a surface appear at all on `Curse none`? Toast or MessageBox?
- Did it stay silent on a repeat, and return after a fresh onset?
- Kyne recognition: did all four beats land (toast, Book entry, Ledger, modal)?
- Did the modal stay silent on a second up-crossing, and stay absent for Shor/Tsun?

**Sessions 2 and 3:** the "What to bring back" lists in the two source packets, unchanged, plus:
- Altmer: did calian lines still vary across three days?
- Khajiit: did per-deity observation pools stay distinct?

Anything surprising is worth a Papyrus log excerpt; the ambient layer traces at level 2.
