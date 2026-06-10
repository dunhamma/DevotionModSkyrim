# B3 Deity Politics Feasibility

**Status:** Design dossier, 2026-06-10. Honesty bar = `03_feasibility.md`: every seam
cited is verified against live source; every item ends with the specific proof still required.
No CK access and no Skyrim runtime in this session.

**Live source base:** `PDV__ManagerQuest.psc` (10,197 lines), `PDV_DeityBase.psc` (395 lines),
`PDV_Deity_*.psc` (32 deities). Verified 2026-06-10.

---

## Grounding facts (verified against live source)

| Fact | Live location | Verified |
|------|---------------|---------|
| `ApplyRivalryPenalties(sourceDeity, sourceAmount)` exists and fires | `PDV__ManagerQuest.psc:9858` | YES |
| It iterates `sourceDeity.RivalDeities[]` / `RivalMultipliers[]` | `:9859-9860` | YES |
| `SendPrismaEventToast("rivalry", ...)` is called inside it | `:9878` | YES |
| `RivalDeities[]` / `RivalMultipliers[]` on `PDV_DeityBase` | `PDV_DeityBase.psc:59-60` | YES |
| **No deity .psc script has `RivalDeities` VMAD values authored yet** | all 32 `PDV_Deity_*.psc` grep clean | YES -- ESP-only gap |
| Talos/AuriEl rivalry is noted in comments but not ESP-wired | `PDV_Deity_Talos.psc:7`, `PDV_Deity_AuriEl.psc:13` | YES |
| `SyncPatronBoonsToTier` / `ClearAllBoons` in DeityBase | `PDV_DeityBase.psc:332-356` | YES |
| `SurfaceTransition` with StorageUtil one-shot guard | `PDV__ManagerQuest.psc:1119-1134` | YES |
| `PDV_DiegeticDirectorService.Dispatch(...)` scaffold exists (D1Enabled-gated) | `:1131-1132` | YES |
| `RunDawnUpdateMood` does NOT yet exist in live source | grep returns nothing | YES -- LD-P1 adds it |
| Mood-engine (`OnMoodBandCross`, `ApplyMoodDelta`) not in live source | grep returns nothing | YES -- LD-P1 work |
| Panel already surfaces rivalry (first rival name) | `:1444-1450` | YES (silent; no toast text) |

---

## Mechanism 1: Rivalry Surfacing (toast enrichment)

**Live seam:** `ApplyRivalryPenalties` at `PDV__ManagerQuest.psc:9858`; toast call at `:9878`
uses `rival` parameter = `rivalDeity.DeityName`. The `context` string arg is always `""` today.

**Confidence: HIGH**

**Recomposition vs greenfield:** pure data authoring. No Papyrus changes. The `"rivalry"`
toast event type already exists and fires; it already carries the rival name. Enriching it
requires only:
1. Add `toast_context` column to the new `PDV_DeityPolitics.csv` opinion table.
2. At compile time, bake the authored context string into a StorageUtil key keyed by
   `(source, rival)` pair names.
3. In `ApplyRivalryPenalties`, read the StorageUtil key and pass it as the `context` arg.

The one gap: `RivalDeities[]` VMAD values are not ESP-wired on any deity yet
(`PDV_Deity_*.psc` files reference the property but no `.psc` sets it; it is a pure
ESP property). The function fires but no rival arrays are populated, so the toast never
actually triggers in the current live build.

**Proof still required:**
- Wire `RivalDeities[]` on Talos ESP (Talos -> AuriEl, multiplier 0.40).
- Verify toast fires when an Altmer player earns Talos piety.
- Verify `context` string appears in the toast overlay.

---

## Mechanism 2: Jealousy Hook at Dawn

**Live seam:** `RunDawnUpdateMood` does not yet exist -- it is the LD-P1 insertion described
in `04_living_deities_architecture.md section 3.2`. B3 jealousy is a call added inside that function
after EWMA recompute. The `ApplyRivalryPenalties` Papyrus pattern (loop over `RivalDeities[]`,
apply fractional delta to each) is the direct template.

**Confidence: MEDIUM-HIGH** (contingent on LD-P1 `RunDawnUpdateMood` landing first)

**Recomposition vs greenfield:** the loop pattern is a direct clone of `ApplyRivalryPenalties`.
The delta formula (`rivalMult * clampedToday * 0.15`) writes to `PDV.Mood.<rival>` via the
new LD-P1 StorageUtil namespace. No new Papyrus API needed; StorageUtil float writes are proven.

**Gap:** requires LD-P1 mood namespaces (`PDV.Mood.<deity>`, `PDV.Mood.<deity>.Band`) to
exist and be writable. Those are LD-P1 Block B authoring work.

**Proof still required:**
- LD-P1 `RunDawnUpdateMood` must be landed first.
- Smoke test: Talos patron at max signal for two days -- verify AuriEl `PDV.Mood.AuriEl`
  dips ~1.3 points cumulative.
- Confirm jealousy alone cannot flip a mood band (requires ~40-50 mood-point delta for
  a band boundary; at 0.65/day that takes 60+ consecutive days of max Talos signal -- safe).

---

## Mechanism 3: Alliances and Fused Boons

**Live seam:** `SyncPatronBoonsToTier` at `PDV_DeityBase.psc:332`; `ClearAllBoons` at `:346`;
`AddSpell` pattern. The fused boon grant bypasses `ClearAllBoons` and calls `AddSpell` directly
on a separately-authored `Spell` record.

**Confidence: MEDIUM** (recomposition of known pattern; new SPEL/MGEF authoring required)

**Recomposition vs greenfield:** the `AddSpell` / `RemoveSpell` calls are proven pattern.
The new element is the dawn alliance check: a small function
`CheckAndSyncAllianceBoons(PDV_DeityBase deityA, PDV_DeityBase deityB, Spell fusedBoon)`
that reads both `PDV.Mood.<X>.Band` values and conditionally adds/removes the fused boon.
StorageUtil reads at dawn are proven safe.

**Gap:** the `PDV.Mood.<X>.Band` namespace is LD-P1. The fused boon SPEL/MGEF must be
authored in CK (domain-fused effect for the specific alliance). The one-active-boost-cap
interaction requires a presence check before granting (`Game.GetPlayer().HasSpell(fusedBoon)`).

**Proof still required:**
- LD-P1 mood bands must be live.
- Author Boethiah+Mephala fused boon SPEL in CK; wire the two deity VMAD AlliancePartner
  properties (new authored properties on `PDV_DeityBase`, ESP-only).
- Smoke: Dunmer player, Boethiah patron at Pleased, Mephala background at Pleased --
  fused boon granted on dawn. Drop Mephala via neglect to Cool -- fused boon removed next dawn.
- Confirm no double-grant if alliance check fires twice.

---

## Mechanism 4: Opinion Table (CSV + compiler)

**Live seam:** the `tools/pdv_quest_matrix_compile.mjs` + `tools/pdv_living_deities_compile.mjs`
pattern (both ship and pass self-tests as of 2026-06-10). A new `PDV_DeityPolitics.csv`
compiler is a direct clone of the living-deities compile workflow.

**Confidence: HIGH**

**Recomposition vs greenfield:** pure tooling clone. The compile target is a StorageUtil JSON
blob or keyed flat storage (same pattern as the quest-matrix compile). No in-game script changes
needed beyond reading the keyed context strings.

**Proof still required:**
- Author `PDV_DeityPolitics.csv` with the 8 sample rows.
- Write self-test gates (no empty source/target, multiplier in [0, 1], INVENTED flag check).
- Confirm compiled output is read correctly by the toast enrichment path.

---

## Mechanism 5: SPID Faction Auras

**Live seam:** SPID distribution infrastructure exists in the modlist (Anvil). `PDV_GLO_PatronMoodBand`
is designed in LD-P1 as a CK-readable global mirror of the active patron's band. A SPID INI
distributes a keyword to faction-affiliated NPCs; that keyword carries an MGEF whose CK condition
reads the global.

**Confidence: MEDIUM** (design is sound; no CK proof; SPID behavior depends on faction-keyword
NPC coverage)

**Recomposition vs greenfield:** the SPID INI pattern is documented in `01_mechanism_bank.md section G`.
No Papyrus scripting on NPCs. The MGEF condition reading a GlobalVariable is vanilla CK
functionality. The challenge is identifying which NPC factions reliably correspond to each deity
in the vanilla game -- priest factions exist for the Nine Divines (TemplePriests* etc.) but
coverage for Good Daedra or Daedric Prince worshippers is sparse.

**Gap:** `PDV_GLO_PatronMoodBand` must be authored and live (LD-P1 dependency). Faction coverage
for Boethiah/Mephala NPC priests in vanilla is thin -- may require a keyword distributed to
quest-gated NPCs rather than faction membership.

**Proof still required:**
- `PDV_GLO_PatronMoodBand` must be live and updating.
- Author one pilot SPID INI distributing a keyword to a small NPC set (Divines temple priests
  of a deity with authored rivalry, e.g., Kynareth shrine priests for a Talos-vs-AuriEl test).
- Author the MGEF with a `GetGlobalValue(PDV_GLO_PatronMoodBand) < 2` (below Pleased) condition.
- In-game smoke: patron at Wroth band -- does the priest have a disposition shift?
- The MGEF approach cannot update live mid-scene (MGEF reads global at application time);
  an NPCscript poll is explicitly NOT the design. Accept that aura updates propagate on next
  cell entry / MGEF reapplication.

---

## Summary Verdicts

| Mechanism | Live seam | Confidence | Shape | Primary dependency |
|-----------|-----------|------------|-------|--------------------|
| Rivalry surfacing | `ApplyRivalryPenalties` (`:9858`) | HIGH | recomposition | ESP VMAD wiring of `RivalDeities[]` |
| Jealousy hook | `RunDawnUpdateMood` insertion point (LD-P1) | MEDIUM-HIGH | recomposition | LD-P1 mood namespaces live |
| Alliance fused boon | `AddSpell` / `RemoveSpell` pattern | MEDIUM | recomposition + new SPEL | LD-P1 mood bands + CK authoring |
| Opinion table CSV | compile toolchain clone | HIGH | greenfield tooling | none (standalone) |
| SPID auras | SPID INI + CK MGEF + global | MEDIUM | greenfield INI/record | `PDV_GLO_PatronMoodBand` live; faction NPC coverage |

All five mechanisms are buildable. No invented Papyrus APIs used anywhere in this design.
The primary blocker for jealousy and alliances is LD-P1 Block B (mood namespaces).
Rivalry surfacing and the opinion table are independent and could be piloted before LD-P1 lands.
