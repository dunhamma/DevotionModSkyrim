# PDV SPID Recognition Packet - Scope

Status: LIVING (scope doc, pre-implementation)
Opened: 2026-08-08
Owner decision on this page: scope is **greenfield and mod-agnostic** - cover as many
mods as possible regardless of modlist. Architecture chosen: **SPID scaffolds, Papyrus
drives.**

Sibling packet: `PDV_KID_DistributionPacket_Scope_2026-08-08.md`. KID targets **items**,
SPID targets **NPCs**. Separate files, separate keywords, separate gates.

Closes/refiles: `BC-0748` (SPID runtime distribution) in `PDV_CompletenessGapLedger.md`.

---

## 1. The finding that reshapes this packet

`PDV_DiegeticUX_ArchitectureSpec.md` section 4.8 currently says:

> `PDV_DiegeticStance_DISTR.ini` distributes a faction/relationship rank keyed to
> existing `PDV_GLO_ActiveDeityIndex` / `PDV_GLO_ActiveTier`.

**This is not buildable.** Checked against the bundled SPID 7.3.0 grammar reference
(`housecarl:spid-authoring`), two hard constraints:

1. SPID has exactly **four** filter sections - String, Form, Level, Trait. There is
   **no GlobalVariable filter**. A `_DISTR.ini` cannot read `PDV_GLO_ActiveTier`.
2. SPID "redistributes everything from scratch on each launch." Distribution is
   evaluated at load and is **never re-evaluated when game state changes**.

Taken together: a tier-keyed distribution would bake in whatever tier the player held at
the moment the save loaded and would never move. The player would rise to Champion and
the world would keep treating them as it did at the loading screen until they alt-tabbed
out and back in.

The globals themselves are healthy - `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`,
`PDV_GLO_OriginRace`, `PDV_GLO_PatronState`, `PDV_GLO_CurseState` all exist and are
maintained in live source. The spec drifted; the data did not.

**Action: section 4.8 of the DiegeticUX spec must be rewritten to section 3 below.** It
is currently a live document making a present-tense design claim that cannot be built.

---

## 2. Verified greenfield cost (2026-08-08, grep of `live-source/Scripts`)

| Fact | Value |
|---|---|
| `PDV_FACT*` / faction records referenced in live source | **0** |
| `SetFactionRank` / `ModFactionRank` / `SetRelationshipRank` / `GetFactionRank` calls | **0** |
| PDV keywords in existence | 6 (5 Green Pact, 1 inn locator) |

Devotion has never touched NPC disposition. This packet is not "wire up an existing
system" - it is a new system with new records, new Papyrus, and a new config lane.
Estimate accordingly.

---

## 3. Architecture: SPID scaffolds, Papyrus drives

The insight that makes this cheap: **do not move state on the NPCs. Move it on the
player.**

```
  SPID (once, at load)          Devotion ESP (static)         Papyrus (on tier change)
  --------------------          ---------------------         ------------------------
  Put NPC populations           Faction-vs-faction            Move THE PLAYER between
  into PDV recognition   --->   reaction records define  <---  PDV_FACT_Tier_* factions
  factions by who they are      how each recognition           when the tier global moves
  (priests, Thalmor,            faction feels about each
  Forsworn, caravans...)        player tier faction
```

Consequences:

- **Zero per-NPC runtime cost.** SPID does the population targeting it is genuinely good
  at, once, at load. Devotion never iterates NPCs.
- **The dynamic part runs on one actor.** Tier changes are rare and already eventful;
  a single player faction move on a tier-change event is nothing. No cloak, no
  `RegisterForUpdate`, no scan.
- **The engine does the disposition math**, from static records, with no script in the
  loop.
- **It degrades correctly.** No SPID installed, or the ini fails to parse: the player
  still moves between tier factions, no NPC is in a recognition faction, and nothing
  happens. No error, no half-state.

### 3.1 The mechanism claim that still needs verification

The design above assumes NPC-to-player disposition can be driven by a faction's
**reaction to a faction the player is in**, rather than requiring a per-NPC relationship
rank. That is the standard engine behaviour, but I have **not** verified the FACT record
schema for it in this project. Before authoring: check the FACT record's reaction
structure via `housecarl:mutagen-reference`, and confirm on a live record how vanilla
does it (`ThalmorFaction` toward `PlayerFaction` is the obvious donor to read).

**If that check fails**, the fallback is per-NPC `SetRelationshipRank` driven off the
SPID-distributed keyword, which is materially more expensive and would want re-scoping.
Do not author rows before this check passes.

---

## 4. Scope

### V1 - disposition only, non-voiced (P0)

This is section 21.3-legal by construction: disposition and stance, no new voiced lines.

**Records to create in `Devotion.esp`:**

- `PDV_FACT_Tier_Seeker` / `_Devoted` / `_Champion` (player-side; Papyrus moves the
  player between them). Exact tier names must match the shipped ladder - there are two
  ladders (patron vs broad) and this must not invent a third.
- `PDV_FACT_Recog_Pious` - populations that warm to visible devotion.
- `PDV_FACT_Recog_Hostile` - populations that cool to it (Thalmor toward Talos being the
  archetype).
- Reaction records wiring each Recog faction to each Tier faction.
- `PDV_KW_Recognition` - a marker keyword so a future lane can query "is this NPC
  SPID-tagged" without a faction check.

**Papyrus to add:** a single tier-change handler that moves the player. Hook the
existing tier-change site; do **not** add a new update loop.

**`_DISTR.ini` targets - vanilla forms only, so it works in every modlist:**

| Population | Filter basis | Recognition |
|---|---|---|
| Temple priests (all Nine) | class / temple factions | Pious |
| Vigilants of Stendarr | faction | Pious, hostile to Daedric patrons |
| Thalmor | `ThalmorFaction` | Hostile to Talos |
| Forsworn | faction | Pious to Hircine/Daedric, hostile otherwise |
| Orc strongholds | faction | Pious to Malacath |
| Khajiit caravans | faction | Pious to Khajiit lunar lane |
| Greybeards | faction | Pious to Kyne/Nord lane |
| Dark Brotherhood / Nightingales | faction | Pious to Sithis / Nocturnal |
| Dawnguard | faction | interacts with the vampire earn-halt lanes |

Because every one of these is a vanilla form, the base ini is modlist-agnostic. It also
covers a large share of JoJ, DoD, and ARR NPCs for free, since overhauls almost always
keep NPCs in their vanilla factions.

### V2 - per-modlist population top-ups (P1)

Optional supplementary `_DISTR.ini` files naming mod-added factions and NPCs. These
**are** per-mod and belong in the FOMOD, unlike the base ini. Candidates from JoJ:
Interesting NPCs, LOTD museum staff, Vigilant, Glenmoril, Project AHO Telvanni,
Mannaz-added race populations.

### V3 - voiced recognition (OUT OF SCOPE, stays V2 in the architecture docs)

---

## 5. Integration with the existing patch lanes

Three lanes now exist and must not blur:

| Lane | Ships | Targets | Inert when target absent because |
|---|---|---|---|
| Quest-reaction channel | StorageUtil JSON, per-mod, FOMOD | quest stages | the quest FormID resolves to nothing |
| KID | ini, core Devotion | items | the name matches nothing |
| SPID | ini, core (V1) + FOMOD (V2) | NPCs | the faction/NPC form resolves to nothing |

A patch should use exactly one of these. The routing question is only ever **what
receives the change** - a quest outcome, an item, or an NPC.

---

## 6. Verification

Same shape as KID, same honest limit - SPID fails silently.

1. **Form-existence lint (new, buildable).** Every `PDV_FACT_*` / `PDV_KW_*` named in a
   shipped `_DISTR.ini` resolves to a real record in `Devotion.esp`. Real exit code.
2. **Grammar lint (new, buildable).** Pipe-section count is correct on every line; no
   SkyPatcher-style `Plugin.esp|0x123` IDs (SPID uses suffix-tilde `0x123~Plugin.esp`);
   no two modifiers mixed in one String or Form expression.
3. **Reaction-record readback (houseCARL).** After authoring, read back each FACT and
   confirm the reaction entries landed. This is the one part of the packet that has a
   genuine record-level proof.
4. **In-game spot check (manual, unavoidable).** Rise a tier in front of a tagged NPC
   population and confirm the disposition moved. Nothing static proves this.

**Stated plainly: a green lint means the ini is well-formed. It does not mean a single
NPC was tagged.** SPID logs its own distribution counts - that log, not the lint, is the
first real evidence.

---

## 7. Open questions for the owner

**7.1** Tier granularity: three player factions (Seeker/Devoted/Champion) or two
(known/Champion)? Three is more legible; two is fewer records and fewer reaction rows.
Recommend three, matching the shipped ladder.

**7.2** Should a **cursed** or **neglecting** player get a hostile recognition band? The
curse state global exists. This is the most flavourful use of the system and also the
most likely to annoy - a player who lapsed for a week suddenly finding temples cold.

**7.3** Does the hostile band apply to **crime and combat**, or disposition only?
Disposition-only is safe. Hostile-on-sight has a dossier already
(`notoriety-hostile-on-sight`) and is a much bigger decision.

---

## 8. Proof boundary

Section 1's SPID constraints are read from the bundled SPID 7.3.0 grammar reference.
Section 2 is a grep of `live-source/Scripts` on 2026-08-08. Section 3.1 is explicitly
**unverified** and gates the rest. Everything else is proposal.
