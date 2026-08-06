# §16.7 Transition Surfacing — Coverage Map

**Purpose:** Bind each of the five §16.7 transition classes to the **already-drafted** slot
IDs in `race-sheets/PDV_RaceContent_Manifest.md`, mark the N/A cells, and specify the
one-shot guard keys. This is a wiring artifact: it lets an implementer wire §16.7 by pointing
at existing copy.

**Headline:** the transition copy is essentially **already authored**. A full inventory plus
spot-verification found **no new copy required** — every transition a race can hit maps to an
existing slot, and the empty cells are intentional N/A (a race without a focused-patron path
or a life-mode simply has no emergence/reorientation event). The three "critical gaps" an
earlier inventory flagged were all false alarms: Dunmer neglect exists
(`PDV_RaceContent_Manifest.md:580-582`), Khajiit "Devoted entry" is by design the per-deity
Champion entry (`:926`), and Altmer curse-cure is intentionally absent — the Altmer position
is terminal (`PDV_RaceDesign_Altmer.md:367`).

## Guard-key convention

§16.7 routes everything through `SurfaceTransition(eventClass, key, direction)` with
save-persistent one-shot guards under `PDV.Surfaced.<eventClass>.<key>.<direction>`. Keys and
directions per class are given in each table below. Opposite-direction transitions clear the
guard they re-enable (recovering a tier re-arms that deity's `neglect`; curing a curse clears
the onset guard and arms the cure beat).

## Master matrix (race × class)

`Y` = bound to existing slot · `N/A` = no such transition by design · `→Champion` = surfaced
by the per-deity Champion entry (see Devoted/emergence reconciliation below).

| Race | tier | emergence | curse | reorientation | neglect |
|------|:----:|:---------:|:-----:|:-------------:|:-------:|
| Altmer | Y | →Champion | Y (terminal) | N/A | Y |
| Argonian | Y | N/A | Y | N/A (posture) | Y |
| Bosmer | Y | N/A | Y | Y (path) | Y |
| Breton | Y | Y | Y | Y (druidic) | Y |
| Dunmer | Y | →Champion | Y | N/A | Y |
| Imperial | Y | →Champion | Y | Y (Concordat) | Y |
| Khajiit | Y | Y (first focus) | Y | Y (automatic focus replacement) | Y |
| Nord | Y | →Champion | Y | N/A | Y |
| Orc | Y | Y (life-mode) | Y | Y (life-mode) | Y |
| Redguard | Y | →Champion | Y | Y (sect) | Y |

### Devoted / emergence reconciliation (read before wiring)

§16.7's `tier` class names "Faithful, then Devoted." For most races the **Devoted** crossing
*is* a focused patron dominating — i.e. the same event the `emergence` class describes. To
avoid a double-fire at Devoted:

- `tier` fires only at **Observant** and **Faithful** (broad-worship milestones).
- The **Devoted** crossing is surfaced once by the **emergence** class, using the per-deity
  Champion entry (`→Champion`) where the race has no dedicated emergence row.

This is the only behavioural clarification the map adds; §16.7 carries a pointer to it.

---

## 1. `tier` — Observant / Faithful (Medium notification; toast `tier`)

Key = `broad`; direction = `Observant` | `Faithful`. One-shot per direction per save.

| Race | Observant | Faithful |
|------|-----------|----------|
| Altmer | `PDV_Notif_Altmer_Pantheon_ObservantEntry` | `PDV_Notif_Altmer_Pantheon_FaithfulEntry` |
| Argonian | `PDV_Notif_Argonian_Observant_Entry` | `PDV_Notif_Argonian_Faithful_Entry` |
| Bosmer | `PDV_Notif_Bosmer_Observant_Entry` | `PDV_Notif_Bosmer_Faithful_Entry` |
| Breton | `PDV_Notif_Breton_Observant_Entry` | `PDV_Notif_Breton_Faithful_Entry` |
| Dunmer | `PDV_Notif_Dunmer_GoodDaedra_ObservantEntry` | `PDV_Notif_Dunmer_GoodDaedra_FaithfulEntry` |
| Imperial | `PDV_Notif_Imperial_Observant_Entry` | `PDV_Notif_Imperial_Faithful_Entry` |
| Khajiit | `PDV_Notif_Khajiit_Lunar_ObservantEntry` | `PDV_Notif_Khajiit_Lunar_FaithfulEntry` |
| Nord | `PDV_Notif_Nord_Observant_Entry` | `PDV_Notif_Nord_Faithful_Entry` |
| Orc | `PDV_Notif_Orc_Malacath_ObservantEntry` | `PDV_Notif_Orc_Malacath_FaithfulEntry` |
| Redguard | `PDV_Notif_Redguard_Observant_Entry` | `PDV_Notif_Redguard_Faithful_Entry` |

## 2. `emergence` — focused patron / emphasis first dominates (Loud MessageBox; toast `tier`)

Key = focus deity (or life-mode); direction = `dominant`. One-shot per subject.

| Race | Emergence surface |
|------|-------------------|
| Breton | `PDV_Notif_Breton_FocusEmergence` (focus within tradition) |
| Khajiit | five deity-specific `PDV_MSG_KhajiitFocus_*` MessageBoxes on first automatic focus only, paired with the existing Prisma toast and pinned Book entry |
| Orc | life-mode entries `PDV_Notif_Orc_LifeMode_{Stronghold,City,LegionExile}_Entry` (also the reorientation surface) |
| Altmer | `PDV_Notif_Altmer_Focus_DevotedEntry` (Devoted = focus) |
| Dunmer | `PDV_Notif_Dunmer_Focus_DevotedEntry` (Devoted = focus) |
| Nord / Imperial / Redguard | per-deity **Champion entry** (`PDV_Msg_<Race>_<Deity>_ChampionEntry`) — Devoted-of-a-patron is the emergence beat |
| Argonian | **N/A** — three always-on layers (Hist/People/Void), no single patron to emerge |

## 3. `curse` — onset and cure, per curse type (Loud MessageBox)

Key = `vampire` | `werewolf`; direction = `onset` | `cure`. Curing clears the onset guard and
arms the cure beat (and vice-versa). Must coordinate with the D-16 cure-path exit and not
double-fire against race `CurseState` rows.

| Race | Vampire onset | Vampire cure | Werewolf onset | Werewolf cure |
|------|---------------|--------------|----------------|---------------|
| Altmer | `PDV_Msg_Altmer_CurseState_VampireOnset` (terminal) + optional `PDV_Msg_Altmer_VampireExiledPath_Entry`/`_Recognition` | **N/A by design** (terminal) | `PDV_Msg_Altmer_CurseState_WerewolfHardHalt` | **N/A by design** (halt) |
| Argonian | `..Argonian_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Bosmer | `..Bosmer_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Breton | `..Breton_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset_KnightsRoad` / `..WerewolfOnset_HiddenArt` | `..WerewolfCured` |
| Dunmer | `..Dunmer_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Imperial | `..Imperial_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Khajiit | `..Khajiit_CurseState_VampireOnset` (+ `..ShadowDriftEntry`) | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Nord | `..Nord_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Orc | `..Orc_CurseState_VampireOnset` | `..VampireCured` | `..WerewolfOnset` | `..WerewolfCured` |
| Redguard | `..Redguard_CurseState_VampireOnset` | `..VampireCured_TuwhaccaReEntry` | `..WerewolfOnset` | `..WerewolfCured` |

## 4. `reorientation` — confirmed sect / mode / path / standing switch (Medium; Loud if major)

Key = destination state; direction = `enter`. Fire on the **confirmed** switch only.

| Race | Reorientation surfaces |
|------|------------------------|
| Bosmer | `PDV_Notif_Bosmer_Path_{OldContract,LivingStory,Exchange,BanditRoad}_Entry` |
| Redguard | `PDV_Notif_Redguard_Sect_{Crown,Forebear,AshAbah}_Entry` |
| Orc | `PDV_Notif_Orc_LifeMode_{Stronghold,City,LegionExile}_Entry` |
| Imperial | `PDV_Notif_Imperial_Concordat_{Uncommitted,PrivateDefiant,OpenDefiant,PublicCompliant,ConcordatEnforcer}` — see the Talos-gate "state-legible not interrupt" rule in §16.7 and `PDV_DecisionMemo_ImperialComplianceLane.md` |
| Breton | `PDV_Notif_Breton_DruidicStanding_{Open,Acknowledged,Frayed}` (tradition is start-locked; druidic standing is the only switch) |
| Altmer / Dunmer / Nord | **N/A** — pantheon/path chosen at start and locked; no mid-game switch (`PDV_Architecture_v3.md:1474` patron-swap deferred) |
| Khajiit | automatic replacement after the new deity satisfies Seeker piety plus the `25 / 15` dominance test; Prisma toast and unpinned Book entry, no repeat popup |
| Argonian | **N/A** — Hist posture (`PDV_Notif_Argonian_HistPosture_*`) is driven by curse/neglect, already surfaced by those classes; no player-chosen switch |

## 5. `neglect` — god first crosses a neglect threshold / tier drop (Medium; toast `neglect`)

Key = deity (or layer/mode); direction = the lapsed band. **Cadence:** fire once per tier-drop;
re-arm only after the player recovers a tier (§16.7 cadence rule). Two complementary surfaces
exist per race: **tier-drop lapse** rows and **thematic neglect-texture** rows.

| Race | Tier-drop lapse rows | Thematic neglect-texture rows |
|------|----------------------|-------------------------------|
| Altmer | `..Pantheon_ObservantLapse` / `..Pantheon_FaithfulLapse` / `..Focus_DevotedLapse` | `..NeglectTexture_{OrthodoxyDrift,CultivationFading,AuriElDistant}` |
| Argonian | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` | `..HistThinning_NeglectTexture` / `..PeopleIsolation_NeglectTexture` / `..VoidDormancy_NeglectTexture` |
| Bosmer | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` / `..GreenPact_Lapse` | `..{OldContract,LivingStory,Exchange,BanditRoad}_NeglectTexture` |
| Breton | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` | `..{KnightsRoad,HiddenArt,GreenWay}_NeglectTexture` |
| Dunmer | `..GoodDaedra_ObservantLapse` / `..GoodDaedra_FaithfulLapse` / `..Focus_DevotedLapse` | `..Layer1_AshPrayerQuiet` / `..Layer2_GoodDaedraThin` / `..Layer3_FocusFading` (`:580-582`) |
| Imperial | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` | `..{Arkay,Stendarr,Talos}_NeglectTexture` / `..CivicScaffoldingHollow_NeglectTexture` |
| Khajiit | `..Lunar_ObservantLapse` / `..Lunar_FaithfulLapse` / `..Focus_DevotedLapse` | `..NeglectTexture_{SubstrateThinning,PatronFading,CaravanForgotten}` |
| Nord | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` | per-deity `..<Deity>_NeglectTexture` (Kyne, Talos, Shor, …) + `..General_AncestorsQuiet` |
| Orc | `..Malacath_ObservantLapse` / `..Malacath_FaithfulLapse` / `..Malacath_DevotedLapse` | `..Malacath_NeglectTexture_{Forge,CityQuality,LegionErasure,OathBroken}` |
| Redguard | `..Observant_Lapse` / `..Faithful_Lapse` / `..Devoted_Lapse` | `..{AncestorLayer,Crown,Forebear,AshAbah}_NeglectTexture` |

---

## What still needs doing (not copy authoring)

The copy is done. The remaining work is **wiring**, on the local CK/tooling machine:

1. Implement the `SurfaceTransition()` helper + `PDV.Surfaced.*` guards (§16.7).
2. For each non-N/A cell above, fire the class with the listed slot at its detected transition,
   honoring the Devoted/emergence reconciliation and the neglect re-arm cadence.
3. Confirm the per-race manifest rows are promoted to ESP records (Phase 19 / CAT-6) — many are
   still draft-in-manifest, not yet wired into `Devotion.esp`.
4. Daedric per-race curse-access response rows (e.g. Orc Molag Bal) close under the D-18 content
   checklist, separately from this map.

No cell in this map requires new player-facing copy.
