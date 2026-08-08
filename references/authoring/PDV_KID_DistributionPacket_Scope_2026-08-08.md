# PDV KID Distribution Packet - Scope

Status: LIVING (scope doc, pre-implementation)
Opened: 2026-08-08
Owner decision on this page: scope is **greenfield and mod-agnostic** - cover as many
mods as possible regardless of modlist. JoJ is a beneficiary, not the target.

Sibling packet: `PDV_SPID_RecognitionPacket_Scope_2026-08-08.md`. The two are
deliberately separate: KID targets **items**, SPID targets **NPCs**. They share no
records and should not share a file.

---

## 1. What KID is for, in Devotion's terms

Devotion needs to know things about items the player interacts with - is this food a
plant or a meat, is this a trade good, is this a hunting trophy. The static answer is a
FormList inside `Devotion.esp`. That answer does not scale past vanilla, for a reason
that is already written into the shipped ini and is worth restating because it is the
whole argument for this packet:

> A FormList entry pointing at another plugin's record makes that plugin a MASTER of
> `Devotion.esp`, so anyone without it gets a missing-master failure and the plugin will
> not load.

KID re-applies at every startup, carries no master dependency, has no save footprint,
and **matches nothing when the target mod is absent**. That last property is what makes
a single mod-agnostic KID layer safe to ship to every user regardless of load order.

The routing code already accepts either path (`FormMatchesListOrKeyword`), so this
packet adds reach, not new plumbing.

---

## 2. Verified current state (2026-08-08, live source + tracked ini)

| Fact | Value |
|---|---|
| KID files shipped | 1 - `mod-data/SKSE/Plugins/KeywordItemDistributor/PDV_GreenPact_KID.ini` |
| Rules in it | 1 (`PDV_KW_GreenPact_Meat`, 9 name matches, Requiem/F&BR) |
| PDV keywords referenced anywhere in live source | 6 total |
| ... of which Green Pact | 5 (`Plant`, `Meat`, `Fungi`, `Egg`, `Insect`) |
| ... other | 1 (`PDV_KW_LocTypeInn`) |
| Green Pact lanes declared but EMPTY | Plant, Fungi, Egg, Insect |

So four of the five Green Pact keyword lanes are declared in the ini header and
distribute nothing. That is the baseline: **a keyword vocabulary of five, one of which
is live.**

---

## 3. Architecture rulings this packet needs

### R-KID-1: KID files ship in CORE Devotion, not in the per-mod FOMOD

Proposed. The per-mod FOMOD exists because a quest-reaction channel is ~90KB of JSON per
mod and the user should not install 44 of them to get 3. A KID rule is one line, and it
is inert when its target is absent. Per-mod gating buys nothing and costs install
complexity and a coverage-drift surface.

Ruling: KID files live in `mod-data/SKSE/Plugins/KeywordItemDistributor/`, ship with
core Devotion, and are organised by **subject lane**, not by target mod.

### R-KID-2: One file per subject lane

`PDV_GreenPact_KID.ini`, `PDV_Trade_KID.ini`, `PDV_Hunt_KID.ini`, etc. Not one file per
mod, and not one monolith. A lane file can be read end to end by a person deciding
whether a classification is right, which is the actual review unit.

### R-KID-3: Name matching is the default, and its self-correction is a feature

Already established and already documented in the shipped file: for the `Potion` type,
KID resolves a Form filter against the item's **magic effects**, not its own FormID, so
FormID filters are wrong for food. Name matching also self-corrects - if another mod
adds its own "Bear Meat", tagging it as meat is still right.

Corollary that must be respected: name matching is **substring** matching. A rule for
`Ale` matches `Alessia's Journal` if the type filter is wrong. Every rule must carry a
type filter, and broad short names need review before shipping.

### R-KID-4: Carry the reasoning block forward on every regeneration

Non-negotiable, and the reason is on the file: the 2026-08-06 packaging archive shipped
a rule superset with the entire comment block stripped, and an external reviewer caught
it rather than us. Any generator that writes these files preserves comments or is not
used.

---

## 4. Scope

### Lane A - Green Pact completion (P0, bounded, closes a known gap)

Close the four empty keyword lanes and widen meat coverage. Target food sources are
chosen for **prevalence across curated lists**, not for one modlist:

| Source | Present in | Lanes it feeds |
|---|---|---|
| Requiem - Food and Beverages Redone | ARR, Anvil | Meat (live), Plant, Fungi |
| Apothecary - An Alchemy Overhaul | JoJ | Plant, Fungi, Insect |
| Gourmet - A Cooking Overhaul | JoJ | Meat, Plant, Egg |
| Saints and Seducers (CC) | JoJ, DoD | Plant, Fungi |
| Rare Curios (CC) | JoJ | Plant, Insect |
| Fishing (CC) | JoJ | Meat, Egg |
| Hunterborn | list-dependent | Meat |
| SunHelm / Last Seed / Frostfall | ARR, DoD | Meat, Plant |
| Ghosts of the Tribunal (CC) | JoJ | Plant |

Owner rulings already on record and NOT reopened here: fungi and egg stay **neutral**
for the Green Pact unless the owner changes that; insect was deferred because vanilla
has ~no edible insects. Lane A therefore has a design question inside it - see 6.1.

### Lane B - New item-class lanes (P1, needs design review before authoring)

Candidate lanes, each of which would let an existing deity react to an item class it
theologically cares about. **None of these are approved; this is the menu to rule on.**

| Lane | Keyword | Deity / race hook | Notes |
|---|---|---|---|
| Raw and taboo meat | `PDV_KW_Namira_Taboo` | Namira cannibalism faucet | Faucet already exists and is fed by quest channels; an item hook makes it day-to-day |
| Alcohol | `PDV_KW_Sanguine_Drink` | Sanguine revel faucet | Same shape; faucet exists |
| Trade goods / gems / ingots | `PDV_KW_Zenithar_Trade` | Zenithar | Zenithar is a thin shell today |
| Hunting trophies / pelts | `PDV_KW_Hircine_Trophy` | Hircine, Kyne | Kyne already has a kill lane; risk of double-credit |
| Burial / funerary items | `PDV_KW_Arkay_Rite` | Arkay, Tu'whacca | Redguard death-duty already has a kill lane |
| Orcish smithing output | `PDV_KW_Malacath_Forge` | Malacath, Orc | Ties to the stronghold lane |
| Amulets of the Divines | `PDV_KW_Divine_Amulet` | all Nine | Cheap, high legibility, low risk |

Every Lane B entry needs a **PULSE-level anti-farm cap** before it ships. Item-class
signals are the easiest thing in the game to farm; the existing rule is that the cap
lives on the pulse, not on the caller.

### Lane C - Integration with the existing per-mod patches (P1)

For each per-mod patch that currently ships or would ship an **ESP**, ask whether a KID
rule could do the same job masterlessly. Deliverable is a short verdict table, not a
rewrite. The value is preventing new master dependencies, not removing old ones.

---

## 5. Verification - and its honest limits

KID has no exit code. A malformed line is skipped **silently**. So the gate stack is:

1. **Keyword-existence lint (new, buildable).** Every `PDV_KW_*` named in any shipped
   KID file must resolve to a real KYWD record in `Devotion.esp`. This is a real gate
   with a real exit code and it catches the most common failure (a keyword renamed in
   the ESP, or never created). **This does not exist yet and is in scope.**
2. **Grammar lint (new, buildable).** Each line parses to the KID 7-section shape, has a
   type filter, and does not use a Form filter on a `Potion` type.
3. **In-game spot check per lane (manual, unavoidable).** Name-matched rules against an
   absent mod cannot be statically proven, by construction. Each lane ships with a named
   spot check: acquire item X, `player.hasKeyword` or the lane's own surfacing.

**Stated plainly: gates 1 and 2 prove the file is well-formed and self-consistent. They
prove nothing about whether a rule matches the item you meant.** Only the spot check
does. Do not let a green lint be reported as lane coverage.

---

## 6. Open questions for the owner

**6.1** Green Pact fungi and egg were ruled **neutral**. Lane A cannot close the "four
empty lanes" without reopening that. Options: (a) keep neutral and delete the two
keywords, (b) keep neutral and keep the keywords dormant for future use, (c) reopen.

**6.2** Lane B: which of the seven candidate lanes are approved? Recommend starting with
Namira, Sanguine, and Divine Amulet - all three attach to machinery that already exists,
so they are rows and rules rather than new systems.

**6.3** R-KID-1 (core, not FOMOD) - confirm. It changes where the files ship and
therefore what the release packager picks up.

---

## 7. Proof boundary

Nothing on this page is runtime-proven. Section 2 is a live read of the tracked ini and
a grep of `live-source/Scripts` on 2026-08-08. Sections 3-6 are proposals.
