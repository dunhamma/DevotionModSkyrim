# B3 Deity Politics Charter

**Status:** Design dossier, 2026-06-10. Subsumes `04_future_buckets_backlog.md` Bucket 3.
**Scope:** Surfaces PDV's existing, silent rivalry ledger as living pantheon politics,
adds inter-deity jealousy, lore-grounded alliances with fused boons, and SPID-distributed
NPC faction auras. No Papyrus/CK/ESP changes in this document.

---

## 1. The Politics Model

PDV already has a rivalry ledger: `RivalDeities[]` + `RivalMultipliers[]` on `PDV_DeityBase`,
consumed by `ApplyRivalryPenalties` in `PDV__ManagerQuest`. The player never sees it.
B3 surfaces that ledger as *living* pantheon behavior: a rival's piety gains make jealous
gods slightly restless, the rivalry toast that already fires (`SendPrismaEventToast("rivalry"...)`)
graduates to a narrated omen, paired allies share a fused boon only when both are Pleased+,
and SPID-distributed NPC faction auras give social weight to the player's standing without
per-NPC scripts.

The politics system is a **backdrop layer**, not a second devotion game. Player action always
dominates pacing. Politics provides ambient color, one memorable jealousy moment, and the
optional satisfaction of discovering an ally pairing -- not a second meter to manage.

---

## 2. Novelty Claim

Across every Skyrim faith mod studied in M1 (Wintersun, Pilgrim, Gods & Worship, Pantheon),
the god is a passive ledger: favor moves only because the player acted. B3 is the first
faith-mod implementation where **gods notice each other** -- where devotion to one deity
actively shifts the social weather for others. The `ApplyRivalryPenalties` seam already fires;
the novelty is making it **visible and felt** through toasts, omens, NPC reactions, and a
fused boon that exists only at the intersection of two relationships.

---

## 3. Authored Opinion Table

A small authored CSV (`PDV_DeityPolitics.csv`) replaces the current per-deity VMAD
`RivalDeities[]` property array as the single source of truth for all directed pair opinions.
Rows are consulted only at three call sites: `ApplyRivalryPenalties` (rivalry fires, already
live), the new jealousy hook at dawn mood recompute (band-cross), and the alliance fused-boon
check (band-cross or daily audit). No N^2 scan -- the opinion table is indexed by
(source_deity_name, target_deity_name) at compile time into a flat JSON lookup.

### 3.1 Sample opinion table (5-8 lore-grounded pairs)

| source | target | relation | multiplier | lore_basis | notes |
|--------|--------|----------|------------|------------|-------|
| Talos | AuriEl | RIVAL | 0.40 | Talos-ban; Altmer divine erasure vs apotheosis | LIVE: authored in Talos.psc design notes; RivalDeities[] not yet ESP-wired |
| Boethiah | Mephala | ALLY | -- | Dunmer Good Daedra Reclamation triad; shared Tribunal overthrow | Fused boon pilot candidate |
| Mara | Dibella | ALLY | -- | Divine love + divine beauty; complementary domains | [INVENTED: no direct lore source; plausible synthesis] |
| Stendarr | Boethiah | RIVAL | 0.30 | Vigilants vs Good Daedra; mercy vs proving-through-violence | Low multiplier -- friction, not cancellation |
| Malacath | Trinimac | RIVAL | 0.50 | Malacath IS Trinimac after Boethiah's act; divine identity rupture | Highest justified multiplier in roster |
| Arkay | Sithis | RIVAL | 0.35 | Life-death cycle vs primordial void/dissolution | Lore-grounded; Sithis acknowledges no Aedric claim |
| Kyne | Shor | ALLY | -- | Nordic paired cosmology: storm-mother + warrior-king | [ALLY only; no fused boon designed yet for this pair] |
| Azura | Boethiah | ALLY | -- | Good Daedra Reclamation triad; Azura most civic, Boethiah most martial | Second Dunmer fused-boon candidate |

**Lore basis rating key:** entries without `[INVENTED]` tag trace to UESP / verified lore
sources. Invented entries are flagged; owner must ratify before ESP authoring.

---

## 4. Jealousy Mechanic

When the active patron's piety rises (positive `clampedToday` at dawn), each of that deity's
rivals receives a **jealousy dip** to mood (not piety). This is additive to the existing
`ApplyRivalryPenalties` piety hit.

Framing: a rival deity notices you giving devotion elsewhere and grows slightly colder.
Bound so politics never outweigh player action:

- Jealousy dip magnitude: `jealousy = rivalMult * clampedToday * 0.15`
  where the 0.15 coefficient = alpha/(1-alpha) of a two-day EWMA cycle at maximum daily
  signal (4.3). At a full ideal day this is ~0.65 mood points per rival. A sustained
  week of max devotion could accumulate ~4 mood points on a rival -- roughly one-tenth
  of a band width, insufficient to flip a band alone.
- Jealousy fires only when: source deity is the active patron AND `clampedToday > 0` AND
  rival is in the active patron pool (the standard pool filter from LD-P1).
- No jealousy from background-deity rivalry; player must be courting a rival to trigger it.

---

## 5. Alliance Fused Boon

Two allied deities whose moods are both Pleased+ (band >= 2) jointly grant a **third boon**
the player would not receive from either alone. The fused boon is a separate `Spell` record,
not a combination of the two deities' existing boons.

Mechanics:
- Checked once per dawn (in the mood recompute pass, after both moods are updated).
- Grant condition: ally A at Pleased+, ally B at Pleased+, player has patron relationship
  with at least one of them (pool filter).
- Grant via the `SyncPatronBoonsToBand` path: `ClearAllBoons()` is NOT called (the fused
  boon is additive, not a swap). Use `AddSpell` directly guarded by a presence check.
- Revoke: on the next dawn where either ally drops below Pleased, the fused boon is removed.
- Family-cap: the fused boon counts against the one-active-boost cap (section 9.1). It should be
  the weakest of the three active boons -- a synergy effect, not a doubling of power.
- The fused boon is always domain-fused: Mara+Dibella fused = a brief restoration + appeal
  aura (community texture, not combat power); Boethiah+Mephala fused = a prove-yourself
  edge (combat observation moment, thematically appropriate for the Reclamation triad).

---

## 6. Narrated Surfacing

B3 rides existing channels -- no new plumbing required:

1. **Rivalry toast (already live):** `SendPrismaEventToast("rivalry", sourceDeity, "", "", rivalDeity.DeityName)`
   fires today but carries empty `context`. B3 enriches the context string: e.g.,
   `"AuriEl watches your devotion with cold eyes."` -- authored per pair in the opinion
   table (`toast_context` column).
2. **Jealousy omen (B3-new):** when a rival's mood drops into a lower band due to
   jealousy accumulation, a `SendPrismaEventToast("jealousy", rivalDeity, ...)` fires
   using the band-cross omen toast path already designed in LD-P1. Text: `"<RivalName>
   grows distant as you draw closer to <PatronName>."` -- authored per pair.
3. **Alliance recognition (B3-new):** when the fused boon is first granted, a `Marked`-
   tier toast: `"<AllyA> and <AllyB> acknowledge your unified devotion."` Fires once per
   alliance cycle (per-dawn StorageUtil one-shot guard, matching `SurfaceTransition`).
4. **Diegetic Director (LD-P2 routing, not B3 scope):** B3 notes which events SHOULD
   be routed to `PDV_DiegeticDirectorService.Dispatch(...)` once LD-P2 is wired.
   The scaffold exists today (`D1Enabled`-gated); B3 does not build into it.

---

## 7. SPID Faction Auras

NPC priests and faction members of a deity the player has angered (rival at Wroth band)
gain a keyword distributed by SPID. The keyword triggers a distributed MGEF on those NPCs
whose condition reads a PDV global (the active patron's mood band mirror, `PDV_GLO_PatronMoodBand`).
When the patron's rival is at Wroth, the NPC MGEF fires a subtle social cue (disposition
penalty or contextual dialogue flag). The player never sees a script; it is all CK-condition-
gated on the distributed keyword.

Full design is in `08_deity_politics_architecture.md` section 4.

---

## 8. P1 Pilot Scope (Recommended)

**Minimal viable B3 in LD-P2 or a standalone Politics-P1:**

1. **Surface existing rivalry:** enrich the existing `"rivalry"` toast with authored
   `context` strings from the opinion table. Zero new Papyrus -- only data authoring.
   Talos/AuriEl is the proven rivalry (Talos.psc design notes explicitly name it).

2. **Jealousy hook at band-cross:** insert the jealousy-dip call into `RunDawnUpdateMood`
   (LD-P1 insertion point), gated on active patron pool membership. One new sub-function
   `ApplyJealousyDips(PDV_DeityBase sourceDeity, Float clampedToday)` in
   `PDV__ManagerQuest`. Proof: Talos patron -- AuriEl mood should dip ~0.65/day at max
   Talos signal.

3. **ONE alliance pair (Boethiah+Mephala):** Dunmer-scoped, Good Daedra Reclamation
   context. Author the fused boon SPEL/MGEF in CK, wire the dawn alliance check, and
   prove the grant/revoke cycle in-game. This establishes the full alliance machinery
   with zero risk of over-powering non-Dunmer runs.

4. **Opinion table CSV:** compile the 8-row sample above (minus INVENTED entries pending
   ratification), drive the toast context strings and multipliers from it. This is the
   data-authoring foundation for future pair additions.

**Deferred from pilot:** SPID auras (requires INI + keyword + global authoring in CK,
standalone scope), cross-realm alliances like Kyne+Shor (no fused boon designed), and
any voiced/diegetic surfacing (LD-P2 dependency).

---

## 9. Bucket 3 Subsumed

`04_future_buckets_backlog.md` Bucket 3 ("Inter-deity alliances") described:
- Paired gods whose joint approval unlocks a fused boon (Mara+Dibella, Boethiah+Mephala) -- COVERED, section 5 above.
- Joint displeasure compounds -- COVERED by jealousy, section 4 above.
- Seed: Hades Duo boons; rivalry ledger (symmetric) -- COVERED, B3 operates the existing ledger.

Bucket 3 is fully subsumed by this dossier. The backlog row may be deleted or marked SUPERSEDED
after owner review.
