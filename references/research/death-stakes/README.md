# Bucket 11 -- Death & Afterlife Stakes: Charter

**Status:** DESIGN DOSSIER, 2026-06-11. Research only. No Papyrus/CK/ESP
changes made. Names are the contract; no in-game proof exists for any
mechanism described here.

**Precondition for build:** LD-P1 runtime-proven (mood-band StorageUtil
namespace, `GetDeityMoodBand`, `PDV_GLO_PatronMoodBand`, `SendPrismaEventToast`
all live and compiled). Death-stakes can be authored against LD-P1 seams but
cannot be compiled or wired until those seams exist in the manager.

---

## 1. The Death-Stakes Model

At the moment of death (or near-death -- see 01_feasibility.md), PDV reads the
active patron's current mood band and sets a one-shot **soul-fate flag** in
StorageUtil. The flag records which afterlife destination the deity claims for
the player's soul. A Marked-tier toast fires at that moment ("Shor calls the
worthy") and the flag persists for the rest of the playthrough, surfacing in
journal text, survey text, and optionally in later bond-stage arc content (B4).

This is text-and-flag only in V1. There is no engine death-hijack, no
fast-travel override, no UI screen. The mechanical weight is entirely
narrative: the player knows what happened, and the system remembers it.

The soul-fate flag is a **one-shot Marked beat** per the A3 intervention
taxonomy in `06_interventions_architecture.md`. It fires once per playthrough
(or once per "first-death" -- see open decision D3 below). It cannot be
anti-farmed because death is not a farmable event.

---

## 2. The Existing Sovngarde Substrate

PDV already has the conceptual substrate for this bucket. In live source
(`PDV__ManagerQuest.psc`):

- `ApplyNordCurseHandlers` (live ~:7236) sets `PDV.Nord.VampireActive = 1` on
  vampirism onset and surfaces the message: "Sovngarde is closed while the
  thirst remains." This is exactly the soul-fate channel -- the message tells
  the player their afterlife status has changed. The cursor text at line ~:6997
  returns the same string under `GetCurseTransitionDiegeticText()`.
- `IsNordVampireSuppressed()` (live ~:8916) reads `PDV.Nord.VampireActive` to
  gate favor-lane eligibility. The suppression pattern is the correct V1 shape
  for death-stakes: set a flag, gate downstream systems on it.
- `GetNordSurveyBaseText()` (live ~:9089) surfaces "Sovngarde is closed while
  the thirst remains. Current standing: ..." -- showing the flag is already
  surfaced in the survey panel.
- `PDV_Msg_Nord_CurseState_VampireOnset` is the live message record for the
  vampire onset Sovngarde message. Death-stakes reuses the `ShowNordMessage`
  (or equivalent `ShowRaceMessage`) + `SendPrismaEventToast` pattern.
- The werewolf curse text (line ~:7257): "The hunt pulls against Sovngarde.
  Master the beast, or it will name the road for you." -- shows that Hircine
  already competes with Shor for the Nord soul. The death-stakes model makes
  this explicit at the moment of death rather than only at curse onset.

The death-stakes build is therefore an **extension of the Sovngarde substrate**,
not a new system. The flag pattern, suppression pattern, survey text pattern,
and message pattern all have live analogues.

---

## 3. Per-Deity Afterlife Destination Table

Mood at death determines which destination flag is set. "Patron" means the
active patron deity via `PDV_GLO_PatronDeity` / `_activeDeity`.

| Patron deity | Race affinity | Pleased/Exalted (mood >= 0, band 2+) | Cool/Wroth (mood < 0, band 0-1) | Notes |
|---|---|---|---|---|
| Shor | Nord (Old Ways) | Sovngarde -- the hall of valor | Denied by Shor; road is unmarked | Core P1 pilot |
| Kyne | Nord (Old Ways) | Sky-road -- carried on the wind | Storm turns away; soul wanders | P1 pilot |
| Arkay | Nord/Imperial | The wheel turns; rebirth favored | Arkay's mercy conditional | Post-P1 |
| Akatosh | Imperial/Altmer | Soul enters the eternal flow | Soul cast adrift from the stream | Post-P1 |
| Auri-El | Altmer | The crystal tower; Aetherius ascent | Denied ascent; Aetherial exile | Post-P1 |
| Mara | Any | Embraced; swift passage | No claim; wandering dead | Post-P1 |
| Tu'whacca | Redguard | The Far Shores -- Redguard paradise | Tu'whacca turns away; soul lost | Post-P1; Far Shores token already exists in source (`PDV.Redguard.FarShoresToken`) |
| Hircine | Werewolf-gated | The Hunting Grounds -- eternal hunt | Cast out of the Hunting Grounds | P1 pilot (curse-gated deity face) |
| Hist | Argonian | Soul returns to the Hist roots | Hist weakened; soul delayed | Post-P1; Hist substrate already in source |
| Y'ffre | Bosmer | Shaped by the Green; story continues | Unraveled; no shape to keep | Post-P1 |
| Malacath | Orc | The Ashpit -- Malacath's domain | Abandoned; soul to the void | Post-P1 |
| Molag Bal | Any (coercive) | Coldharbour -- soul trapped | Rejected even by Coldharbour | Post-P1; Dread axis (B4) is the natural complement |
| Hermaeus Mora | Any | Apocrypha -- soul indexed forever | Knowledge insufficient; soul purged | Post-P1 |
| Azura | Dunmer/Any | Soul goes to Moonshadow at dusk | Azura withholds passage | Post-P1 |
| Meridia | Any | Colored Rooms -- in her light | Soul denied light; darkness | Post-P1 |
| Boethiah | Any | Named in the Great Game | Forgotten; unworthy of the game | Post-P1 |

**Flag invented for V1 (no direct lore reference, inferred):**
- Kyne "sky-road" destination: Kyne as storm-mother carrying the worthy dead is
  lore-adjacent (Old Ways Nords knew her as death-bringer) but the specific
  "sky-road" framing is invented for PDV.
- "Denied even by Coldharbour" for Wroth Molag: invented; humiliation rather
  than horror.
- "Soul purged" for Wroth Hermaeus Mora: invented; the Dreamsleeve is the
  canonical neutral afterlife for unclaimed souls.

**Neutral/unclaimed fallback:** if no active patron at death, flag =
`PDV.SoulFate.Destination = "dreamsleeve"` with text "No god claims you. The
Dreamsleeve takes the unnamed." This covers Argonians without the Hist
substrate and no-patron players.

---

## 4. Novelty Claim

No Skyrim faith mod surfaces a deity-mood-at-death soul-fate flag. Wintersun
ignores death entirely. Pilgrim has no death hook. Gods & Worship has no
death event. The closest precedent is in Sacrosanct (vampire feeding resets a
counter on kill) -- which is an anti-farm pattern, not an afterlife narrative.

The bond-ladder capstone (B4, `09_authored_arcs_charter.md`) is the natural
downstream consumer: a stage-4 deity that knew you in life may reference the
soul-fate flag in its terminal arc text, or the death-stakes outcome may
function as a bond-advance gate ("only the Beloved reach Sovngarde"). The
death-stakes flag is designed as a B4 input but does not require B4 to ship.

---

## 5. P1 Pilot Scope (Recommended)

**In scope for P1:**

1. **Nord / Shor / Sovngarde** -- the existing Sovngarde substrate already
   expresses this channel (vampire severs the claim; werewolf threatens it).
   Death-stakes P1 makes the claim explicit at the actual moment of near-death
   and writes a persistent flag instead of just a modal message.

2. **Hircine / Hunting Grounds** -- the curse-gated `PDV_Deity_Hircine` face
   (LD-P1 authored) already makes Hircine a mood-tracked deity. Death for a
   werewolf with Hircine pleased should fire "The Hunt claims you" -- a
   competing afterlife claim against Shor that the werewolf curse messages
   already foreshadow ("The hunt pulls against Sovngarde").

**Rationale for Nord + Hircine as P1:**
- Both already have lore-grounded afterlife destinations that PDV source already
  names.
- The Nord/Hircine tension is explicitly present in the live source text --
  death-stakes resolves that narrative tension in-game.
- No new theology invention is required for P1; only the detection hook and
  flag write are new.

**What stays backlog:**
- All other deities and races in the destination table above.
- Any engine-facing effect from the soul-fate flag (journal unlocks, arc gating,
  B4 bond-capstone content).
- Multi-death behavior (D3 below).

---

## 6. Open Owner Decisions

| ID | Decision | Options | Current default assumption |
|---|---|---|---|
| D1 | Death detection hook | OnDying on player alias (recommended) vs. low-health threshold vs. no detection (flag at dawn if health reached zero) | OnDying recommended; see 01_feasibility.md |
| D2 | Mood threshold for "pleased" claim | Band >= Pleased (2) or any positive mood (> 0) | Band >= Pleased (mood-band 2+ per LD-P1 bands) |
| D3 | One-shot vs. per-death | Set once, never overwrite vs. overwrite on each death | One-shot (write only if `PDV.SoulFate.Written == 0`); owner may prefer last-death-wins |
| D4 | Wroth behavior | Rival claims soul vs. patron denies (no rival claim) vs. neutral Dreamsleeve fallback | Patron-denied + Dreamsleeve fallback; rival-claim (e.g. Molag Bal) is authoring-optional per deity |
| D5 | Death Alternative compat | If Death Alternative / Sands of Time catches the death before the player truly dies, does the hook fire? | Treat near-death (health <= 5%) as the trigger; DA modifies respawn, not the health drop -- safe |
