# Signal-Density Audit — can each god generate ~2.5 piety/day in normal play?

**Question.** The pace model (`PDV_PietyPaceBalancingTable.md`) assumes a steady player nets
**~2.5 piety/day** per god, giving the default 10/20/34-day calendar to Observant/Faithful/Devoted.
That only holds if each god actually *affords* ~2.5/day of qualifying behavior in normal play.
This audit checks that, using the per-race trigger families and the manifest's own cadence notes.

**Method / the bar.** Daily piety ≈ a **devotion floor** (prayer/shrine/substrate, ~+1.0/day,
Class A) **+ favors** (Class B/C). Because a single standard favor is +1.5, **prayer floor + one
standard favor = 2.5/day** — so a god clears the bar as long as it reliably affords *one*
qualifying favor per day on top of its floor. The manifest's repeated "~1–2 favors/day in steady
play" notes are therefore right at or above the bar for any god that *has* a floor.

**Two exceptions to the floor** (important): **Malacath/Orc** has no prayer floor by design —
*"you cannot pray harder… cannot visit a shrine"* (`PDV_RaceDesign_Orc.md:174`) — and **Argonian
Hist** has a passive drag instead of a floor. These two are structurally slower, on purpose.

## Headline

The uniform calendar **holds as the default**, and most gods clear ~2.5/day comfortably. The real
finding is not accidental gaps — it's that **the architecture deliberately runs three things
off-calendar**, and those need to be recorded as sanctioned exceptions (with real calendars) so
they aren't mistaken for density bugs. Only a few genuinely thin paths need a trigger top-up, and
the fix is always **richer triggers, never a higher per-act value** (raising per-act values would
desync every *other* god).

## Verdict table

`On-calendar` = clears ~2.5/day via floor + ~1 favor · `Sanctioned-slow` = intentionally below
default, documented in design · `Gap (fix)` = accidentally thin, enrich triggers.

| Race / path | ~Favors/day (manifest) | Floor? | Verdict | Action |
|---|---|---|---|---|
| Nord (broad) | ~2/day (`Manifest:345`) | shrine | **On-calendar** | none |
| Altmer (coherence) | ~1–2/day (`:870`); dawn rite +2 | dawn rite | **On-calendar** | none |
| Dunmer (ancestor + Good Daedra) | ~1–2/day (`:661`) | ash-prayer (always-on) | **On-calendar** | none |
| Khajiit (lunar substrate) | ~2/day (`:1029`) | substrate (always-on) | **On-calendar** | substrate model, not piety-pace |
| Imperial (broad Nine) | ~1–2/day (`:1202`) | shrine | **On-calendar** | none |
| Imperial → **Talos path** | rare costly-defiance (`:344`) | — | **Sanctioned-slow** | politically expensive *by design*; not a gap |
| Bosmer — Old Contract | meal-choice dense | shrine | **On-calendar** | none |
| Bosmer — Living Story | ~1–2/day (`:1545`) | shrine | **On-calendar** | none |
| Bosmer — Bandit Road | road-life + survival | shrine | **On-calendar** | none |
| Bosmer — **Exchange (Z'en)** | proportionate vengeance, quest-gated | shrine | **Gap (fix)** | add everyday fair-dealing / debt-settlement / honest-trade triggers |
| Breton — Hidden Art | Daedric work, dense | shrine | **On-calendar** | none |
| Breton — Green Way | stones + outdoor + hunt | shrine | **On-calendar** | none |
| Breton — **Knight's Road** | mercy/justice, intentional moments | shrine | **Gap (fix)** | add ambient just-conduct triggers (protect a victim, refuse a dishonest job, escort/aid) |
| Redguard — Crown | martial + tomb respect | shrine/Far-Shores token | **On-calendar** | none |
| Redguard — Forebear | road passage + contract | token | **On-calendar** | none |
| Redguard — **Ash'abah** | death-adjacent only | token | **Monitor** | dense for dungeon-delvers, thin for city/social play; widen only if playtest shows social Ash'abah stalling |
| Orc — Stronghold | ~1–2/day (`:489`), **no floor** | none | **Sanctioned-slow** (100% base) | see calendar below |
| Orc — City | ~1–2/day, no floor | none | **Sanctioned-slow** (75%) | see calendar below |
| Orc — Legion/Exile | ~1–2/day, no floor | none | **Sanctioned-slow** (60%) | see calendar below |
| Argonian (Hist/People/Void) | ~1–2/day (`:1904`) | passive Hist drag | **Sanctioned-slow** | leaky-floor, below |
| Daedric paths (all) | multi-day rites (Hircine: 1 rite × 3 days = Seeker) | — | **Sanctioned-slow** | separate rite-cadence model, below |

## Sanctioned exceptions — the real calendars

These are *intended* to run off the 10/20/34 default. Recording them so they read as design, not bugs.

### Orc life-mode multipliers (now pinned down)

`PDV_RaceDesign_Orc.md:219` set the multipliers as "TBD" — applying them to the locked 2.5/day
default (and 3.5 ceiling) gives concrete calendars. The Champion threshold (85) is **the same**
across modes; only the rate differs.

| Mode | Rate ×base | Default day to Obs / Faith / Devoted | Ceiling day to Devoted |
|---|---|---|---|
| Stronghold | 1.00 → 2.5/day | **10 / 20 / 34** | ~24 |
| City | 0.75 → 1.9/day | **13 / 27 / 45** | ~32 |
| Legion/Exile | 0.60 → 1.5/day | **17 / 33 / 57** | ~40 |

This makes "the burden is highest, the ceiling lowest" (`Orc:63`) a real ~57-day Legion climb to
Devoted — deliberately the hardest devotional life in the mod. **Recommend locking the 1.00 / 0.75 /
0.60 multipliers** (they were the design's own rough targets and they produce a coherent spread).

### Argonian — leaky Hist floor (not a multiplier)

Hist decays −1/dawn after 3 maintenance-free days, floor 20 (`Argonian:47`). With diligent
water/rest maintenance the decay is fully offset and Argonian climbs near-default; neglect it and a
chunk of the daily budget is spent standing still. Net: a careful Argonian is roughly on-calendar
for Hist; a careless one stalls. This is "begin inside absence, not abundance" by design — **no fix
needed**, but expect Argonian Faithful to land a few days later than default in typical play.

### Daedric paths — rite cadence, not daily accrual

Daedric devotion is gated to multi-day authored rites (Hircine proof: one rite on each of three
separate in-game days = Seeker; same-day repeats are anti-farm-scaled, `Architecture` Phase 13).
These deliberately do **not** sit on the 2.5/day calendar and should not be balanced against it.

## Genuine gaps to fix (trigger enrichment only)

> **Resolved:** both gaps are now specced in `PDV_TriggerTopups_Exchange_KnightsRoad.md` (Z'en = Reciprocity family: production + exchange; Knight's Road = Justice family: predator-kill without stealth opener). Detail below retained for rationale.


Two paths can't reliably produce even one favor/day on top of the floor:

1. **Bosmer Exchange (Z'en).** Proportionate vengeance is quest-gated, so ordinary days are empty.
   Add ambient Z'en triggers: honest trade, settling a debt, fair-dealing dialogue, refusing a
   swindle. Goal: ~1 qualifying everyday act/day so Exchange tracks Living Story's pace.
2. **Breton Knight's Road.** Mercy/justice beats are intentional, low-frequency choices. Add ambient
   just-conduct triggers (protect a victim, escort/aid, refuse a dishonest contract) so a knightly
   player generates ~1/day without waiting for a curated mercy moment.

**Monitor (no change yet):** Redguard Ash'abah is death-adjacent only — fine for a dungeon-heavy
player (draugr everywhere), thin for a city/social character. Widen only if playtest shows a social
Ash'abah stalling below Observant.

**Do not** address any gap by raising a per-act value — that would pull the whole roster off the
shared calendar. Density gaps are fixed at the *trigger* layer, pace is set at the *value* layer.

## Net answer

Yes — ~2.5/day is achievable for every god that's supposed to hit it. The shared calendar is sound.
Three exception classes (Orc modes, Argonian Hist, Daedric rites) are slower **on purpose** and now
have explicit calendars; two paths (Bosmer Exchange, Breton Knight's Road) need a small trigger
top-up to reach the default. With the Orc multipliers locked at 1.00/0.75/0.60 and those two
triggers enriched, the cross-god pace is coherent and intentional end-to-end.
