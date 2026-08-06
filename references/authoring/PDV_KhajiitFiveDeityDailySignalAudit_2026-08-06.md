# Khajiit Five-Deity Signal Audit -- Corrected Inventory and Wealth Spec

**Revision 2, 2026-08-06.** This revision supersedes the original five-row
verdict table in this same file. The original was written from design intent
rather than from the shipped code, and two of its five rows were wrong. Every
claim below was re-read against `live-source/Scripts/Source/` and against the
compiled quest matrix at write time.

This document is the signal-coverage authority for the five focused Khajiit
deities: Khenarthi, Azurah, Baan Dar, Rajhin, and Alkosh.

Scope: **review and specification only.** Nothing here is built. No `.psc` was
edited, no matrix row was authored, and no artifact was recompiled. Parity is
specified, not achieved.

---

## 1. Corrections to revision 1

### 1.1 Alkosh -- "generic dragon kills renew" is false

Revision 1 gave Alkosh a "Thin" verdict on the grounds that generic dragon kills
renew while named dragons and Words are finite. The renewing half of that claim
does not exist.

`HandleKhajiitAlkoshGenericDragon` (`PDV__ManagerQuest.psc:8551`) awards
`KHAJIIT_FOCUS_SIGNAL_DELTA * 0.25` = `6.25` focus weight, emits **no curated
signal at all**, and is hard-capped to once per game week by
`PDV.Signal.KhajiitAlkoshGenericDragon.Week`. A generic dragon kill grants
Alkosh **zero piety**, ever.

Alkosh's only piety pulse, `SIGNAL_DRAGON_ORDER` (901), reaches
`PulseKhajiitFocusPiety` only through `HandleKhajiitAlkoshDragonOrder`
(`PDV__ManagerQuest.psc:8497`), whose sole ingresses are MQ104 stage 160 (a
one-shot quest source) and CK activator route 92
(`PDV_EventSignalActivator.psc:57`). `SIGNAL_NAMED_DRAGON` (902) is one-shot per
named ActorBase (`PDV_PlayerEvents.psc:1143`).

**Corrected finding: Alkosh has no repeatable curated piety faucet of any kind.**

### 1.2 Azurah -- the described mechanism is not the implemented one

Revision 1 said the `Observe the Moons` rite gives "raw `+0.4` piety for the god
in strength" and that "Azurah receives it only in either of her two strength
slots." The outcome is right; the mechanism matters and was not stated.

The rite never emits `SIGNAL_MOON_OBSERVANCE` (701). `CompleteKhajiitMoonObservation`
(`PDV__ManagerQuest.psc:8148`) awards raw piety directly through
`AwardPietyInternal(presidingDeity, 0.4, True, "observe_moons_power")`
(`:8171`), where `presidingDeity = GetKhajiitEmphasisDeity(GetLunarPresidingFocus(phase))`.
The recipient is chosen by the sky. The player's focus is never consulted, and
the rite grants **zero focus weight to anybody**. The legacy
`HandleKhajiitMoonObservance` ingress is deliberately inert.

Separately, `SIGNAL_THRESHOLD_RITE` (702) is declared with
`DELTA_THRESHOLD_RITE = 1.5` (`PDV_Deity_Azura.psc:19`) and scored in
`ScoreCuratedSignal`, but its only dispatch site is the Dunmer Reclamation
route. **It has no Khajiit ingress.** Azurah's designed 1.5-magnitude threshold
beat is unreachable for a Khajiit player.

### 1.3 "Daily cap" overstates the mechanism nearly everywhere

`ConsumeDailyRepeatMultiplier` (`PDV__ManagerQuest.psc:27103`) is a `0.7^n` soft
decay, not a cap. It returns `1.00`, `0.70`, `0.49`, `0.343` and never reaches
zero, so repeated same-day acts keep paying. Every downstream
`if multiplier <= 0.0 / return` guard is a dead branch.

The only true hard caps in this cluster are explicit StorageUtil stamps:

| Key | Cadence | Site |
|---|---|---|
| `PDV.Khajiit.MoonRite.PietyDay` | 1 / devotional day | `PDV__ManagerQuest.psc:8166` |
| `PDV.Khajiit.BaanDar.OutnumberedDay` | 1 / devotional day | `PDV_PlayerEvents.psc:1022` |
| `PDV.Khajiit.BaanDar.ReversalWeek` | 1 / game week | `PDV_PlayerEvents.psc:1008` |
| `PDV.Signal.KhajiitAlkoshGenericDragon.Week` | 1 / game week | `PDV__ManagerQuest.psc:8557` |
| `PDV.Khajiit.AlkoshNamed.<formid>` | one-shot per base | `PDV_PlayerEvents.psc:1143` |
| `PDV.Khajiit.Rajhin.Target.<formid>` | 7 game days per target | `PDV_PlayerEvents.psc:1262` |

Note the two weekly stamps use `(gameDay / 7) + 1`, a fixed integer bucket off
game-day zero. They roll at midnight, not at the 06:00 devotional boundary.

### 1.4 Revision 1 was blind to the likes/dislikes layer

Revision 1 judged daily agency entirely from curated signals. Most ordinary-play
piety for these five actually comes from the likes/dislikes action table
(section 3). Judging from curated signals alone both overstates the gap for
Baan Dar and *understates* it for Alkosh.

### 1.5 Baan Dar's row conflated two lanes

Revision 1 folded the road trick and the near-fatal reversal into one "Thin"
verdict. They are separate signals with different gates and different cadences:
road trick (505) is hard once per devotional day; near-fatal reversal (501) is
hard once per game week and pays `3.0`, the largest repeatable curated delta of
the five.

### 1.6 Mechanism worth carrying forward

`PulseKhajiitFocusPiety` (`PDV__ManagerQuest.psc:8623`) routes on the
**detector's** god, not on the player's current emphasis. A Rajhin theft pulses
Rajhin whoever the player follows. The single exception is
`HandleKhajiitFocusedSource` (`:8505`), whose no-focus fallback hard-codes
Azurah at `:8515`.

---

## 2. Layer A -- curated signal inventory

`AwardCuratedSignal` / `AwardCuratedSignalScaled` (`PDV__ManagerQuest.psc:4798`,
`:4822`) are the only emit paths. Every dispatch site in the mod lives in
`PDV__ManagerQuest.psc`.

### Khenarthi

| ID | Delta | Trigger | Control | Real cap | Handler |
|---|---:|---|---|---|---|
| 601 `ROAD_HOME` | `+0.4` | Any completed, uninterrupted sleep whose **start** was outdoors | **Player-owned** | `0.7^n` soft | `:8379` |
| 603 `CARAVAN_AID` | `+1.5` | Kill a hostile while a living Khajiit caravan leader is loaded nearby and the victim is not a caravan member | Encounter | `0.7^n` soft | `:8690` |
| 604 `CARAVAN_HARM` | `-2.0` | **Activator only** (route 111) | Authored content | none | `:8648` |

Road-home presentation is decoupled from the substrate budget: the first outdoor
rest each devotional day always gets one toast and Book entry via
`PDV.Khajiit.RoadHome.PresentationDay` (`:8398`), even when the shared `+4` was
already spent.

### Azurah

| ID | Delta | Trigger | Control | Real cap | Handler |
|---|---:|---|---|---|---|
| 701 `MOON_OBSERVANCE` | `+0.4` | Only via `HandleKhajiitFocusedSource`, i.e. a P2 lunar source resolving to Azurah -- including the no-focus fallback at `:8515` | Indirect | `0.7^n` soft | `:8623` |
| 702 `THRESHOLD_RITE` | `+1.5` | **No Khajiit ingress.** Dunmer Reclamation only | unreachable | n/a | -- |
| 703 `DESECRATION` | `-2.5` | **Activator only** (route 110) | Authored content | none | `:8640` |

The `Observe the Moons` power sits outside this table entirely -- it pays raw
piety to the presiding god (section 1.2), hard-capped once per devotional day.

### Baan Dar

| ID | Delta | Trigger | Control | Real cap | Handler |
|---|---:|---|---|---|---|
| 505 `ROAD_TRICK` | `+0.4` | Outnumbered win: 3+ kills **or** level delta >= 5, **and** the low-health flag set | Encounter | **hard 1 / day** | `:8477` |
| 501 `BANDIT_ROAD` | `+3.0` | Near-fatal reversal: near-fatal flag plus at least one session kill | Encounter | **hard 1 / week** | `:8569` |
| 504 `BETRAYAL` | `-2.0` | **Activator only** (route 114) | Authored content | none | `:8893` |

502 and 503 are Bosmer-path only and never fire for a Khajiit.

### Rajhin

| ID | Delta | Trigger | Control | Real cap | Handler |
|---|---:|---|---|---|---|
| 801 `ELEGANT_THEFT` | `+0.4` | Pickpocket of >= 200 gold, or any target on `PDV_FLST_RajhinNotableTargets` | **Player-owned** (thief build) | `0.7^n` soft, plus 7-day per-target cooldown | `:8485` |
| 802 `LEGEND_MADE` | `+1.5` | Single take >= 500 gold, or a steal of an item valued >= 500 | **Player-owned** | `0.7^n` soft | `:8707` |
| 803 `BOTCHED_THEFT` | `-2.0` | **Activator only** (route 112) | Authored content | none | `:8800` |

### Alkosh

| ID | Delta | Trigger | Control | Real cap | Handler |
|---|---:|---|---|---|---|
| 901 `DRAGON_ORDER` | `+0.4` | MQ104 stage 160 (one-shot) or activator route 92 | Not repeatable | `0.7^n` soft, but nothing renews it | `:8497` |
| 902 `NAMED_DRAGON` | `+2.0` | Kill an ActorBase on `PDV_FLST_AlkoshNamedDragons` | Finite (6 bases) | **one-shot per base** | `:8536` |
| 903 `CHAOS_AID` | `-3.0` | Killing Paarthurnax; also activator route 113 | One-shot in practice | upstream one-shot | `:8808` |
| -- | none | Generic dragon kill | Encounter | **focus weight only, 1 / week, no piety** | `:8551` |

### Layer A summary

| Deity | Repeatable positive faucets | Player-owned among them |
|---|---:|---:|
| Khenarthi | 2 | 1 (road home) |
| Rajhin | 2 | 2 |
| Baan Dar | 2 | 0 (both encounter-gated) |
| Azurah | 1 | 0 (indirect only) |
| Alkosh | **0** | 0 |

All four anti-creed signals (604, 703, 803, 504) are activator-only. They have
dispatch sites but no ambient trigger reaches them, so no Khajiit player can
currently lose piety through them.

---

## 3. Layer B -- the likes/dislikes action table

Pipeline: `references/authoring/PDV_DeityLikesDislikes.csv` ->
`tools/pdv_likesdislikes_gen.mjs` -> `LoadRowsForDeity`
(`PDV__ManagerQuest.psc:12664`) -> StorageUtil -> `PDV_DeityBase.ScoreFromTable`.
`LIKES_DISLIKES_VERSION = 20` (`:629`) is current and matches the CSV row for
row; there is no inert-CSV drift. Blocks: Baan Dar `:12910`, Khenarthi `:12921`,
Rajhin `:12933`, Alkosh `:12945`, Azura `:12957`.

Row counts are near-parity:

| Deity | Rows | Likes | Dislikes | Khajiit overlays |
|---|---:|---:|---:|---:|
| Azura | 12 | 8 | 4 | 0 |
| Khenarthi | 11 | 8 | 3 | 2 (313, 350) |
| Rajhin | 11 | 7 | 4 | 2 (360, 304) |
| Alkosh | 11 | 6 | 5 | 0 |
| Baan Dar | 10 | 7 | 3 | 0 |

**Row count is the wrong measure.** Each row carries a per-day cap, so what
matters is the daily ceiling, and how much of it an ordinary session can
actually reach. Excluding acts that need a dragon, a Word of Power, a Daedric
artifact, or a Daedra kill:

| Deity | Full daily ceiling | Everyday-reachable ceiling | Gated-out rows |
|---|---:|---:|---|
| Khenarthi | 11.25 | **8.25** | 302 dragon, 343 word |
| Azura | 11.25 | **8.25** | 343 word, 368 artifact |
| Baan Dar | 7.75 | **7.75** | none |
| Rajhin | 6.30 | **6.30** | none |
| Alkosh | 7.50 | **3.00** | 302 dragon, 343 word, 301 daedra |

### Why that number decides the audit

Piety is clamped at dawn: `scaledToday = pietyToday * GAIN_RATE_SCALE` then
clamped to `PIETY_DAILY_MAX_DELTA` (`PDV__ManagerQuest.psc:13594-13599`).
With `GAIN_RATE_SCALE = 1.32` (`:622`) and `PIETY_DAILY_MAX_DELTA = 4.3`
(`:618`), **a deity needs `4.3 / 1.32` = `3.26` raw points in a day to reach its
cap.**

| Deity | Everyday-reachable Layer B | vs the 3.26 raw cap threshold |
|---|---:|---|
| Khenarthi | 8.25 | 2.5x -- clears it easily |
| Azura | 8.25 | 2.5x -- clears it easily |
| Baan Dar | 7.75 | 2.4x -- clears it easily |
| Rajhin | 6.30 | 1.9x -- clears it |
| Alkosh | **3.00** | **0.92x -- cannot reach the cap** |

Alkosh is the only one of the five who, on an ordinary dragonless day, cannot
fill his daily piety allowance from the action table -- and he has no curated
faucet to top up with. Every other god clears the cap on Layer B alone and uses
its curated faucet as flavour rather than as fuel.

---

## 4. Repeatable-signal parity verdict

**They are not equal.** Reading both layers together:

| Deity | Layer A faucets | Layer B everyday reach | Can hit the 4.3 daily cap in ordinary play? |
|---|---:|---:|---|
| Khenarthi | 2 | 8.25 | Yes, comfortably |
| Azurah | 1 | 8.25 | Yes on the table; her *own* practice pays elsewhere |
| Baan Dar | 2 | 7.75 | Yes |
| Rajhin | 2 | 6.30 | Yes |
| Alkosh | **0** | **3.00** | **No** |

Two real deficits, and they are different in kind:

- **Alkosh is a genuine shortfall in both layers.** Zero repeatable curated
  faucet, and an action table gated behind dragons, Words, and Daedra. He is the
  only one of the five who is structurally short of his own daily cap.
- **Azurah is a routing problem, not a volume problem.** Her table is joint-best.
  What she lacks is ownership: her one signature practice, the moon rite, pays
  whichever god the sky names, and her declared 1.5 threshold beat is unwired.

Baan Dar reads thin in revision 1 only because both his faucets are encounter-
gated. His table clears the cap without them, so the encounter gating is texture
rather than starvation. Revision 1's "Thin" verdict for Baan Dar is withdrawn.

### The structural moon-slot inequality

`GetKhajiitMoonPhaseFromGameDay` (`:27071`) splits 24 days into eight equal
3-day windows, and `GetLunarPresidingFocus` (`:3019`) assigns them. Per 24-day
cycle:

| God | Slots | Days per cycle | Moon-rite piety per cycle |
|---|---:|---:|---:|
| Khenarthi | 3, 7 | 6 | 2.4 |
| Azurah | 2, 8 | 6 | 2.4 |
| Rajhin | 4, 5 | 6 | 2.4 |
| Baan Dar | 6 | 3 | 1.2 |
| Alkosh | 1 | 3 | 1.2 |

A player cannot influence this. Note also that the race sheet's "Alkosh only the
full moon (rare by design)" reads as rarer than the implementation: the
full-moon window is 3 of 24 days, exactly as long as Baan Dar's.

---

## 5. Quest-signal state

The compiled artifact is clean. `node tools/pdv_quest_matrix_compile.mjs --check
--json` returns `PASS`, `questCells 1982`, `questKeys 173`, `watchedQuests 134`.
All five deities compile through at full source fidelity; the "0 quest entries"
key-drift failure mode is **not** present. The problem is authoring density.

| Deity | Rows | Rows minus the uniform 25-row MainQuest floor | Net payout | Positive milestones |
|---|---:|---:|---:|---:|
| Baan Dar | 47 | 22 | +136 | 2 |
| Rajhin | 44 | 19 | +254 | 9 |
| Khenarthi | 41 | 16 | +78 | **0** |
| Azura | 39 | 14 | +64 | 2 |
| Alkosh | 38 | 13 | +50 | **0** |

Pantheon context: these rank #14, #22, #28, #33 and #34 of 45 deities. The
leader is Stendarr at 75. None of the five is rich; the apparent parity in the
totals column is an artifact of the Tranche 11 MainQuest pass giving all five
exactly 25 rows.

Alkosh's only milestone is a **penalty** (`DB11|200 sow_chaos_madness -C`, -18).
The Dragon King of Cats cannot currently reach an 18-point positive event.
Khenarthi has no milestone of either sign -- all 41 of her rows are `small`.

### Coverage gaps by family

- **All five have zero Dragonborn / Solstheim rows** across 23 quests and 52
  cells. This is the single largest hole and it is uniform.
- **Khenarthi**: 1 row across 10 Dawnguard quests; 1 across 12 Civil War quests.
  Her `protect_the_weak` and `honor_the_dead` creed maps onto both and is unmined.
- **Alkosh**: zero in College, Dawnguard, Dragonborn, Companions, Misc Side. His
  `serve_empire_order` and `uphold_law_justice` rows pay 2 points each, so a full
  Imperial Civil War playthrough yields him roughly 10 points.
- **Azura**: zero Dark Brotherhood rows despite `desecrate_the_dead` being an
  obvious anti-creed fit that Khenarthi, Baan Dar and Rajhin all carry there.
  20 of her 39 rows are a single tag at 2 points, so her distribution is very flat.
- **Baan Dar**: 4 Thieves Guild rows against Rajhin's 8, in a guild that is his
  own domain. Zero College, Dawnguard, Companions, Misc Side.
- **Rajhin**: a pure Dark Brotherhood + Thieves Guild + MainQuest deity. Outside
  those three families he earns almost nothing.
- **Mod-patch channels are effectively empty**: one row total for the five
  (Azura, Glenmoril) across the 24-row ARR matrix and the 7-row Authoria core.

### Non-row lanes, for completeness

Two of the five hold quest-meta faucet lanes at `value.meta.*` = 1.0 per hit:
`value.meta.khenarthi` on `MetaOutdoors` quests and `value.meta.azura` on
`MetaMageAid || MetaTwilight` (`PDV__ManagerQuest.psc:1862-1892`). Baan Dar,
Rajhin and Alkosh have none. Among Part D faucets, only `Azura.fate_threshold`
belongs to the five. This asymmetry compounds the row asymmetry rather than
offsetting it.

---

## 6. Locked spec -- repeatable-signal parity

Three items. All are specified, none are built. Each must remain non-generic,
hard-capped, and **separate from the shared `+4` lunar substrate budget**
(`PDV_SubstrateBase.psc:75-121`) -- the substrate stays deity-agnostic and equal
by construction, and none of this may draw on it.

### 6.1 Moon rite becomes a split -- presiding plus focused

**Decision: split.** The presiding god keeps its `+0.4`. Once a focused emphasis
exists, the focused deity **also** receives a pulse from the same rite. Before
emergence, behaviour is unchanged (presiding only).

Site: `CompleteKhajiitMoonObservation`, `PDV__ManagerQuest.psc:8166-8172`. Reuse
the existing `PDV.Khajiit.MoonRite.PietyDay` stamp so the whole split remains one
hard grant per devotional day; do not add a second day key. When the focused
deity *is* the presiding deity, the rite pays once, not twice.

Rationale: this preserves the cosmological reading -- the sky still names a god
and that god is still fed -- while guaranteeing every focus one player-owned
daily piety act. It also blunts the 3-of-24 slot inequality for Baan Dar and
Alkosh without touching the schedule.

The rite continues to grant zero focus weight. Emergence must stay behavioural.

### 6.2 Alkosh gets a repeatable order-keeping lane, and the dead dragon path is wired

**Decision: both.**

- **New lane, "Order Restored":** the first fully cleared hostile location per
  devotional day emits `SIGNAL_DRAGON_ORDER` (901). Hard once per devotional day
  via a new day stamp. This is Alkosh's `uphold_law_justice` creed expressed as
  practice -- order imposed on chaos -- it is naturally paced by dungeon cadence,
  it collides with no other Khajiit lane, and it is reachable without a dragon.
- **Wire the generic-dragon piety pulse.** `HandleKhajiitAlkoshGenericDragon`
  (`:8551`) keeps its once-per-game-week focus-weight nudge, but must also emit
  `SIGNAL_DRAGON_ORDER` at that same weekly cadence. A dragon kill paying the
  Dragon King of Time exactly nothing is not a balance choice; it reads as an
  omission.

Together these lift Alkosh's everyday-reachable ceiling above the 3.26 raw cap
threshold, which is the specific defect in section 3.

### 6.3 Azurah's threshold rite gets a Khajiit ingress

**Decision: wire it, do not retire it.**

`SIGNAL_THRESHOLD_RITE` (702, `+1.5`) fires on the **first location discovery
made outdoors during a twilight window** -- dawn `05:00-07:00` or dusk
`19:00-21:00` -- hard once per devotional day.

The detector already exists: event `345` discover-location is hooked and is
already in Azurah's likes table. The addition is the time-and-exterior gate.
The double gate keeps it non-generic; the hard daily stamp keeps it non-farmable;
and crossing into unknown ground at the hinge of the day is precisely Azurah's
domain of thresholds and passage.

This gives Azurah a player-owned beat she currently lacks, without disturbing the
moon rite.

### 6.4 Out of scope for this spec

The four activator-only anti-creed signals (604, 703, 803, 504) stay
activator-only. Giving them ambient triggers is a separate decision about
punishment surface and is not part of a parity pass.

---

## 7. Locked spec -- quest-signal wealth

Target: **approximately 100 quest-matrix rows per deity.**

| Deity | Now | Target | New rows |
|---|---:|---:|---:|
| Khenarthi | 41 | 100 | +59 |
| Azura | 39 | 100 | +61 |
| Baan Dar | 47 | 100 | +53 |
| Rajhin | 44 | 100 | +56 |
| Alkosh | 38 | 100 | +62 |
| | | | **+291** |

At 100 each, all five sit clearly above the current pantheon leader (Stendarr,
75). That is deliberate: the requirement is a wealth of quest signals, not parity
with an existing mid-table deity.

### Blocking precondition -- RESOLVED 2026-08-06

Reconciled in commit `9591d7dd` ("fix(matrix): reconcile Full.csv drift and gate
the tranche merge"), which kept the `Full.csv` values, restored the missing
`DB01|198` cluster through a new
`PDV_QuestReactionMatrix_Reconciliation_2026-08-06.csv`, and added a `--check`
mode to `tools/pdv_quest_tranche_merge.mjs`. That commit sits on a separate
worktree and is **not yet merged into this branch**; re-run its `--check` after
the branches meet. The original finding is kept below because it explains why
the gate exists.

**`PDV_QuestReactionMatrix_Full.csv` could not be regenerated from its
tranches, and publishing Tranche 12 runs the merge that would have overwritten it.**
Re-deriving the merge from the 11 tranche files yields 1978 cells; `Full.csv`
holds 1982. Both sides are committed and stable since 2026-07-16.

- **4 rows exist in `Full.csv` that no tranche produces** -- the whole
  `DB01|198` cluster (Stendarr, Mara, Stuhn, Molag Bal).
- **17 shared keys carry different payloads**, including **5 milestone
  downgrades** on regeneration: `C06|200` Arkay, `DA16|190` Mara, `MS14|200`
  Arkay, `MS14|200` Stendarr, and `MQ201|250` Nocturnal (`Full.csv` has
  `theft_burglary,deceit +C milestone` = 18 points; the tranche says
  `keep_secret +S small` = 4).

Nothing catches this today. `tools/pdv_quest_matrix_compile.mjs --check` only
proves `Full.csv` and the compiled JSON agree; it never re-derives `Full.csv`
from the tranches, so the first pipeline stage is unverified.

None of the five Khajiit deities appeared in the drift, so the row counts in
section 5 are unaffected.

### Delivered -- Tranche 12 (2026-08-06)

`references/authoring/PDV_QuestReactionMatrix_Tranche12_KhajiitFiveWealth.csv`,
**149 rows** (92 completion-stage + 57 intermediate-stage), authored and
validated but **not merged** (the merge tool's hardcoded file list does not yet
include it -- see Pipeline constraints).

| Deity | Was | +T12 | Now | Target | Positive milestones (was -> now) |
|---|---:|---:|---:|---:|---|
| Baan Dar | 47 | +36 | 83 | 100 | 2 -> 8 |
| Azura | 39 | +37 | 76 | 100 | 1 -> 7 |
| Alkosh | 38 | +32 | 70 | 100 | **0 -> 11** |
| Khenarthi | 41 | +27 | 68 | 100 | **0 -> 8** |
| Rajhin | 44 | +17 | 61 | 100 | 9 -> 12 |

**The milestone requirement is met for all five**, including the two that
previously could not reach a positive milestone at all. 11 of the 149 rows are
anti-creed negatives. The ~100-row target is **not** met, and the reason is
structural rather than effort-bound -- see below.

### Why ~100 per deity is not reachable from the vanilla quest graph

Two hard filters bind, and both are correctness requirements rather than
conservatism:

1. **A matrix row must fire on a completed act, not on an objective.** Most
   intermediate journal stages record what the player has been *told to do*
   ("Brynjolf has given me a new assignment", "I must kill Gaius Maro"), not
   what they *did*. Tagging those fires the deity reaction on the wrong beat --
   a player would see Rajhin approve of a theft at the moment someone offered
   them a job. Of 107 candidate intermediate rows, **54 were dropped** on this
   rule.
2. **The Part B creed bindings are narrow, and deliberately so.** Rajhin has
   exactly two approving tags (`theft_burglary` C, `deceit` S) and Khenarthi
   three. Reaching 100 rows each would require tagging beats that are not
   actually theft, deception, or protection -- which is the homogenisation the
   spec forbids.

Rajhin is the extreme case: 61 of a target 100, because the vanilla graph simply
does not contain 100 completed, non-radiant, in-creed theft-or-deception beats
outside the Thieves Guild and Dark Brotherhood, and he already held 9 of the
best ones.

**Recommendation:** treat 61-83 as the honest ceiling for creed-faithful vanilla
coverage. The remainder cannot come from the mod-patch channels on the same
evidence standard -- see below.

### The ARR/Authoria channel was investigated and is blocked, 2026-08-06

Two findings, both verified live on the ARR instance:

1. **ARR rows are conditional content.** The ARR matrix compiles to a separate
   `PDV_QuestReactionMatrix_ARR.json` that ships only inside
   `dist/PDV_AuthoriaARR_Compatibility`, `dist/PDV_Patch_Authoria_AllInOne`, and
   the FOMOD's `plugins/authoria`. It is **not** in the base Devotion release, so
   rows there raise coverage only for players running Vigilant/Glenmoril/Unslaad
   *and* the patch. Base-player coverage stays at 61-83 regardless.
2. **ARR quests carry no journal text.** Read live on
   `D:\Wabbajack\modlists\ARR 2.5` (profile `KoK R11`; Vigilant.esm,
   Unslaad.esm and Glenmoril.esm all confirmed ACTIVE): every
   `Stages[i].LogEntries[0].Entry` on `zzzCrbMq02` is `(absent)`. These quests
   are **objective-driven** -- the content lives in `Objectives[i].DisplayText`
   ("Defeat Austella", "Decide Ulliss' fate"), which are *directives, not
   outcomes*. Authoring outcomes from them is exactly the failure this pass
   dropped 54 vanilla rows to avoid, and branch-heavy quests make valence
   unresolvable statically.

This is why all 24 existing ARR rows carry `RUNTIME-VERIFY` in their citations:
the previous author hit the same wall.

### ARR delivered -- 27 objective-derived RUNTIME-VERIFY rows (2026-08-06)

The owner elected the objective-derived route. `PDV_QuestReactionMatrix_ARR.csv`
goes 24 -> **51 rows**; the Khajiit five now hold **28** there against 1 before:

| Deity | ARR rows |
|---|---:|
| Alkosh | 9 |
| Azura | 8 |
| Baan Dar | 7 |
| Khenarthi | 4 |
| Rajhin | **0** |

Compile verified: `node tools/pdv_quest_matrix_compile.mjs --check --json
--matrix references/authoring/PDV_QuestReactionMatrix_ARR.csv` -> `PASS`,
51 cells, 36 keys.

Vigilant turns out to be an unusually good fit for **Azura**, because its whole
spine is Molag Bal and she is the only one of the five whose creed names him
(`destroy_reject_daedra:molagbal`, S). Her milestones here:
`The Blood Matron` s100 (freeing Lamae Bal, his first victim, from his curse),
`Old Regrets` s75 (surrendering the Mace of Molag Bal to the Vigil rather than
keeping it), and `Remnants` s80 (`cure_undeath` -- giving Stendarr's Mercy to
the last remnant instead of the sword).

**Rajhin gained nothing and the channel cannot give him anything.** Vigilant,
Unslaad and Glenmoril are Daedric/dragon/horror content with essentially no
artful-theft or deception beats, which is his entire creed
(`theft_burglary` C, `deceit` S).

**The authoring rule used, and why:** an objective's `Index` is when the task is
*given*, not when it is done. Each row therefore fires on the **next stage after
the act's objective** -- e.g. Unslaad `The Final Journey` objective s135
"Defeat <Boss>" is scored at stage **s140**. Stage indices were confirmed to
exist on the record before authoring, so no row can be a stage that never fires.
Every citation names the source objective, the offset rule, and carries
`RUNTIME-VERIFY`.

Rows: Vigilant `Thus Spoke Khajiit` s80 (granting the dying Khajiit Jo'vanni his
last request -- Khenarthi `honor_the_dead` milestone, Azura `honor_the_dead`);
Unslaad `The Final Journey` s140 and `Hoarfrost` s50 (Alkosh
`kill_honorable_combat`, Baan Dar `prove_by_struggle`).

**Vigilant's 120 quests are mostly not authorable, and this is the finding that
caps the channel.** Surveyed by editorid family:

| Family | Count | Authorable? |
|---|---:|---|
| `zzzCHSubQuest*` | 16 | **No** -- zero objectives (checked 4 of 4 sampled) |
| `zzzCHMemoryQuest*` | 13 | **No** -- zero objectives (sampled) |
| `zzzAoMBounty*`, `zzzCHrq*` | many | **No** -- radiant bounties |
| `VS *` boss quests | many | **No** -- `<Alias=Boss>` parameterised |
| `Send the Vigil to <hold>` | 9 | **No** -- one per hold, repeatable pattern |
| `zzzAoMMq*` / `zzzBMMq*` / `zzzCHMQ*` main line | ~20 | **Yes**, where objectives exist |

The narrative sub-quests and memory quests -- the bulk of Vigilant, and the parts
with the richest theology -- carry **neither journal text nor objectives**. There
is nothing in the record to derive a stage-to-act mapping from; they are
scene/trigger quests driven entirely by Papyrus. `Exsultate Jubilate`,
`Kyne's Dragon` and `Dragon Souls` are all zero-objective too.

So the ARR ceiling is set by the main quest lines, not by survey effort. Those
are now largely worked: Vigilant `zzzAoMMq01/02/04/06/07`, `zzzBMMq01/02/03`,
`zzzCOMq01` and Unslaad `zzzCrbMq02/Mq08` all carry rows.

**Still authorable** on the same method: Vigilant `zzzAoMMq03` (Lazy Afternoon),
`zzzAoMMq05` (Dine and Dash), `zzzAoMMq09` (The Endless Fall), `zzzAoMMq10`
(The Landing); the rest of the Unslaad main line (`Mq01/03/04/05/06/07/10`);
and Glenmoril's story quests (`zzzRevMq*`, `zzzGHMq*`, `zzzLrhMq*`). Check each
for a non-empty `Objectives` list first -- roughly half of what has been sampled
across these mods has none.

**The offset rule, for whoever continues.** An objective's `Index` is when the
task is given. Score on the next stage at which it has resolved. Where the
stage list was read, that is the literal next stage index; otherwise use the
next *objective* index, which is also a stage index -- confirmed on 7 of 7
quests checked. Each row's citation records which of the two was used.

**Rajhin gained nothing here and is unlikely to.** Vigilant, Unslaad and
Glenmoril are Daedric/dragon/horror content; they contain almost no artful theft
or deception beats, which is his entire creed.

houseCARL was re-pointed to `D:\Wabbajack\modlists\Anvil` (profile
`Devotion Dev`) after this work.

Constraints discovered while authoring:

- `vanilla-quest-stage-readback.csv` carries journal prose for **126 of 778**
  quests and **none** for Dragonborn.esm or Dawnguard.esm. DLC stage text was
  read live from the QUST records through houseCARL
  (`Stages[i].LogEntries[0].Entry`). Quest names and stage indices came from the
  same read.
- **18 Dawnguard `DLC1RH*`/`DLC1RV*` quests are radiant** (CK folder
  `DLC1\Radiant\`) and were excluded. They repeat indefinitely, so a matrix row
  on one is an uncapped faucet. Existing precedent excludes them.
- **13 vanilla quests were dropped** rather than stretched, because their
  completion beat matches no creed among the five -- e.g. `MS01` completes on
  being framed and imprisoned, `MS05` on joining the Bards College, `TG09` on
  *returning* the Skeleton Key rather than taking it.
- **Rajhin is the hard case.** His Part B profile is only `theft_burglary`(C)
  and `deceit`(S). The intermediate pass found his real content -- Goldenglow,
  Dampened Spirits, Calcelmo's stone, Riftweald Manor, the Gourmet's Writ --
  and 9 further candidate cells were rejected because `Full.csv` already held
  them (his existing Thieves Guild milestones).
- **Outcome text is derived, never invented.** Each intermediate row's outcome
  is condensed from that stage's own journal entry; alias placeholders
  (`<Alias=Dungeon>`) are stripped, and rows whose entry is an objective are
  dropped rather than reworded into an act.

Validation run against both the current and the reconciled `Full.csv`: header
parity, 10 columns on every row, **zero key collisions**, no internal
duplicates, every `editor_id`+`stage` resolving in the readback, no radiant
quests, all act tags already in the live vocabulary, and all enum domains
valid.

### Pipeline constraints

These come from `tools/pdv_quest_tranche_merge.mjs` and shape what can be
authored. Read them before writing rows, not after the merge fails.

- **The dedup key is `editor_id|outcome_stage|deity`** (`:41`). A deity can hold
  **at most one row per quest stage**; a second is silently dropped and the
  higher-ranked one kept (`rank` = milestone 100, then C 30 / S 20 / m 10, `:37`).
  Cross-deity overlap on the same stage is a *different* key and is unaffected.
- **Capacity follows from that key.** 100 rows per deity means 100 *distinct
  stages* per deity, against 173 stage keys in the matrix today. Reaching the
  target therefore requires **new stage coverage**, not denser authoring on the
  existing pool. This is why the Solstheim/Dawnguard/College fill is structural
  rather than cosmetic.
- **Conflicting valence is a hard failure.** If any two tranches give the same
  deity `+` and `-` on one stage, the merge prints `CONFLICTING VALENCE` and
  exits 1 (`:54`). There are exactly two grandfathered exceptions
  (`T03|100|Kynareth`, `T03|100|Y'ffre`); do not add a third. Check each target
  stage against `Full.csv` for an existing row for that deity before authoring.
- **The tranche file list is hardcoded** in the merge tool (`:4-14`), so adding
  Tranche 12 requires appending one line to that array. `CLAUDE.md` forbids
  editing toolchain scripts unless asked -- this one-line addition is a sanctioned
  exception for this task and should be called out in the handoff.

### Authoring rules

- Author into a **new tranche**,
  `references/authoring/PDV_QuestReactionMatrix_Tranche12_KhajiitFiveWealth.csv`,
  in the same schema as the existing tranches. Merge with
  `tools/pdv_quest_tranche_merge.mjs`, compile with
  `tools/pdv_quest_matrix_compile.mjs`. **Never hand-edit
  `PDV_QuestReactionMatrix_Full.csv`** -- it is generated.
- **Coverage priority order:** Dragonborn / Solstheim first (the total blackout,
  23 quests, all five at zero), then Dawnguard, College, Companions, Civil War,
  Bards College, and side content.
- **The Solstheim blackout is an authoring gap, not a tooling gap.** The compiler
  resolves `editor_id` to FormID through
  `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv`, which
  already carries **244 Dragonborn.esm quests and 184 Dawnguard.esm quests** (of
  778 total). No new extract is needed before authoring DLC2 or DLC1 rows.
- Draw per-deity act tags from Part B of
  `references/authoring/PDV_QuestReactionMatrix.md` (lines 275-303) so new rows
  **extend each creed rather than homogenise the five**. The five must stay
  distinguishable after the pass:

  | Deity | Creed tags to extend |
  |---|---|
  | Khenarthi | `protect_the_weak`, `honor_the_dead`, `honor_the_wild`, `mercy_spare` |
  | Azurah | `disciplined_study`, `slay_undead`, `cure_undeath`, `honor_the_dead`, and the `desecrate_the_dead` anti-creed |
  | Baan Dar | `prove_by_struggle`, `deceit`, `theft_burglary` |
  | Rajhin | `deceit`, `theft_burglary`, `aesthetic_devotion` |
  | Alkosh | `serve_empire_order`, `uphold_law_justice`, `keep_oath`, `kill_honorable_combat`, and the `sow_chaos_madness` anti-creed |

- **Every deity must finish with at least 4 positive milestones.** Khenarthi and
  Alkosh currently have none; Alkosh's sole milestone is a penalty. Rajhin's 9 is
  the level to raise the others toward, not an outlier to trim.
- **Overlap is explicitly permitted, across deities only.** One quest stage may
  carry rows for several of the five, with different tags and even opposing
  valences -- each deity is its own dedup key. What is *not* available is two rows
  for the **same** deity on one stage: the merge keeps one and drops the other
  silently, and opposing valences for one deity abort the merge. Divergent
  preferences across the five are equally acceptable; the requirement is wealth
  per deity, not identical coverage.
- Close the two specific domain inversions while passing: Baan Dar's 4 Thieves
  Guild rows against Rajhin's 8, and Azurah's zero Dark Brotherhood rows.
- Mod-patch channels (ARR, Authoria core) are **out of scope** for this tranche.
  They are a separate compatibility surface with its own matrix.

---

## 8. Proof status

Unchanged by this document. `references/authoring/PDV_PreBetaRaceGateLedger.md`
lines 127-128 hold Khajiit at **Conditional / Readback-Ready**: prior route
evidence remains useful, but the 2026-08-06 substrate, focus-emergence,
observation, resonance, Portent and Champion changes require a new in-game
matrix before a runtime or manual Pass can be restored.

Nothing in sections 6 and 7 is built. This document specifies parity; it does not
claim it. When the specified work lands, it needs its own runtime proof -- the
spec is not evidence.
