# PDV Phase 21 - DoD / Authoria Reuse Audit

Status: readback comparison complete; no direct ARR ESP reuse approved.
Date: 2026-06-15.

This audit compares the Diaries of Dibella package against the earlier
Authoria / ARR compatibility work. It is a tool/result reuse check, not runtime
proof and not a public support claim.

## Reused Method

The Authoria pass supplied the reusable method:

- remove the list's religion overhaul first;
- prove the shared shrine spell surface by readback;
- keep the standalone compatibility ESP name reserved until a stable adapter
  source is proven;
- treat list-owned balancing or generated outputs as local rebuild work, not as
  PDV assets to redistribute;
- use `pdv_patch.mjs` for approved classification/distribution rules, not for
  speculative quest or adult-framework hooks.

The same method was applied to DoD. `pdv_patch.mjs validate --json` and
`pdv_patch.mjs plan --json` still resolve against the Anvil Devotion profile:
11 rules loaded, 9 ready, 6 build-ready, and 2 blocked tooling examples with
symbolic payloads. No DoD-specific build rule is approved yet.

## Shared Active Surfaces

The ARR main profile and DoD main profile share 1002 active plugins and 694
active MO2 mods. The relevant shared surfaces are:

| Surface | Shared evidence | Reuse decision |
|---|---|---|
| `The Heart Of Dibella - Quest Expansion.esp` | Active in both lists; DoD and ARR both touch vanilla `T01` plus `T01_GiveLetter`. | Reuse as a candidate source list only. Do not emit a PDV route until exact stage/outcome semantics are approved. |
| `Caught Red Handed - Quest Expansion.esp` | Active in both lists; both touch `FreeformRiften11`, `DialogueRiftenHaelgasBunkhouseScene03`, and `FreeformRiften11b`. | Candidate for future Dibella/social route review; not safe as generic adult/social piety. |
| `TheOnlyCureQuestExpansion.esp` | Active in both lists; both touch vanilla `DA13`. | Already belongs to the Daedric Peryite quest-stage lane, not a DoD-specific patch. |
| `The Whispering Door - Quest Expansion.esp` | Active in both lists; both touch vanilla `DA08` and `DA08RumorPointer`. | Already belongs to the Daedric Mephala quest-stage lane, not a DoD-specific patch. |
| `Talos' Tease.esp` | Active in both lists; both expose `JOJ_ThaeylinDialogueQuest`; DoD also includes many JOJ shop/outfit patches. | Candidate for curated Talos location/story review; no direct ARR patch copy. |
| Half-Khajiit / Ohmes-Raht | Active in both lists through `HalfKhajiit.esp` and Ohmes-Raht tweak patches. | Needs PDV custom-race normalization support before claiming native Khajiit routing. |
| M'rissi | Active in both lists; ARR has a Requiem patch and DoD has several M'rissi gameplay/dialogue patches. | Candidate for future Khajiit/follower-context review only; no direct route adapter. |

## Authoria Patch Results That Do Not Port Directly

ARR has active list patches such as:

- `Authoria - Reqtificated - Half Khajiit.esp`
- `Authoria - Reqtificated - The Heart of Dibella QE.esp`
- `Authoria - Reqtificated - Talos Tease.esp`
- `Authoria - Reqtificated - Dibella's Grace.esp`
- `Authoria - Reqtificated - Caught Red Handed QE.esp`
- `Authoria - Reqtificated - Mrissi.esp`

houseCARL readback shows these are mostly Requiem/list-balancing overrides:
Half-Khajiit gains Requiem keywords; Talos Tease and M'rissi touch containers,
armor, weapons, race records, and dialogue responses; Heart of Dibella touches
Requiem's `REQ_Boon_AgentOfDibella_Perk`. DoD is not using the ARR Requiem
stack, so these records should not be copied into the DoD package.

## DoD-Specific Readback Findings

### Half-Khajiit / Ohmes-Raht

DoD active readback:

- `HalfKhajiitRace` (`03322B:HalfKhajiit.esp`) wins from
  `DOD - Ohmes-Raht Fix.esp`.
- `HalfKhajiitRaceVampire` (`05693A:HalfKhajiit.esp`) wins from
  `DOD - Ohmes-Raht Fix.esp`.
- The normal race carries `ActorTypeNPC` and `IsBeastRace`.
- The vampire race carries `ActorTypeNPC`, `ActorTypeUndead`, `Vampire`, and
  `IsBeastRace`.

The DoD package now ships the explicit data-only policy for this race: both
records are listed in `PDV_RaceMap.json` and resolve to Khajiit origin index
`6`. This keeps `Devotion.esp` free of a `HalfKhajiit.esp` master and does not
copy any ARR Requiem/list-balancing patch. Runtime smoke still needs to prove
normal and vampire Ohmes-Raht save behavior before a public support claim.

### Dibellan Baths

DoD active readback:

- `akdDibellanBathsLocation` (`005A99:Dibellan Baths.esp`) already has
  `LocTypeDwelling` and `LocTypeTemple`.
- `akdDibellaMarker` uses `TempleBlessingScript` and points its
  `TempleBlessing` property at vanilla `AltarDibellaSpell`
  (`0FB995:Skyrim.esm`). The current Devotion shrine spell override already
  covers this marker after Wintersun removal.
- `akdSybilMarker` uses `TempleBlessingScript` but points its
  `TempleBlessing` property at `akdAltarSybilSpell`
  (`042BF6:Dibellan Baths.esp`).
- `akdAltarSybilSpell` applies three vanilla effects, including two 28800
  duration effects and one instant effect. It is not part of the existing 14
  vanilla shrine spell override set.

`akdAltarSybilSpell` is the strongest DoD-specific patch candidate found in
this audit. It should not be changed in the current package without a specific
design decision, because it is a list-authored Sybil blessing rather than a
Wintersun leftover.

### Mara's Embrace And Talos' Tease Locations

DoD active readback:

- `XXTURiftenBrothel` (`000A4E:Mara's Embrace.esp`) has `LocTypeInn`.
- `JOJ_TalosTeaseLocation` (`1335BD:Talos' Tease.esp`) has
  `LocTypeDwelling` and `LocTypeInn`.

These are social/venue classifications, not temple classifications. They should
remain context-only until PDV has curated receivers for Mara or Talos social
content. Do not add `LocTypeTemple` to them as a shortcut.

## Candidate Reuse Backlog

| Candidate | Tool to reuse | Status | Gate before shipping |
|---|---|---|---|
| DoD Sybil blessing neutralization or adapter | `pdv-shrine-blessing-author` pattern plus houseCARL readback | Candidate | Decide whether to remove its stat boon, convert it to cure-only, or route a Dibella/Sybil signal. Then verify spell effect readback and runtime activation. |
| Ohmes-Raht custom-race mapping | Race readback + `PDV_RaceMap.json` data map | Shipped data map | Prove normal/vampire Ohmes-Raht origin behavior in runtime smoke before public support. |
| Heart of Dibella QE exact-stage route | `pdv_extract_quest_stage_readback.mjs`, `pdv_phase20_p2_receiver` pattern | Candidate | Approve exact quest/stage/outcome rows; prove no duplicate with vanilla `T01`/Agent of Dibella handling. |
| Caught Red Handed QE Dibella/social route | Same quest-stage readback workflow | Candidate | Approve exact non-repeatable branch semantics; reject generic adult/social counters. |
| Talos' Tease curated Talos route | houseCARL quest/location readback + future receiver | Candidate | Identify a stable quest/stage or activator event; avoid generic inn/shop presence scoring. |
| The Only Cure / Whispering Door QE | Existing Daedric quest-stage tools | Covered by shared Daedric lane | Keep in Daedric source-proof flow; no DoD-specific adapter needed. |

## Current Package Decision

Do not add a `PDV_DoD_Compatibility.esp` yet. The reusable Authoria result is
the proof boundary and scan workflow, not a portable ESP. The current DoD zip
remains correct for Wintersun replacement, shrine-spell ownership, and the
data-only Ohmes-Raht origin map. The next safe expansion would be a separate
candidate patch for either the Sybil blessing
or custom-race mapping after the design gate is explicit.
