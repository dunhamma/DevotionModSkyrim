# The Imperial journey - what a player actually experiences

**Status:** LIVING working document for the Imperial UX session.
**What this is:** the player's experience in the order they live it, with the exact text the
game shows today at each beat. Not an architecture map (that is the Atlas) and not a copy
database (that is the workbook). This is the join: what happens, when, and what it says.
**Evidence:** direct houseCARL readback of `Devotion.esp` (MO2 `Anvil` / profile
`Devotion Dev` / `Devotion-V3Dev`) plus `live-source` Papyrus. **No runtime observation** --
nothing here is proof of in-game behaviour.

---

## How to read this

Each beat gives its **trigger**, its **channel**, and the **exact current text**.

- **PUSH** - the game speaks: MessageBox, Prisma toast, Book of Days entry.
- **PULL** - the player looks: Active Effects, the Survey power, the MCM, the Prisma panel.

**Two corrections that reframe the whole picture, both found while building this:**

1. **PDV is not silent.** It says a great deal through Active Effects and the Survey, and
   the writing there is good. "Nothing fires" was the wrong diagnosis; the right question is
   which moments deserve a **push** as well as the pull that already exists.
2. **Tier crossings do push** -- via a Book of Days journal line. An earlier draft of this
   document said they were pull-only. That was wrong.

---

## Act 1 - Becoming an Imperial

### 1.1 First load
**Trigger:** origin capture on game start. **Channel:** PUSH, one-time info box.
Imperial has no setup choice by design -- only Breton, Bosmer, Redguard, Orc and Nord get
an explicit choice (`PDV__ManagerQuest.psc:3487-3492`), so `GetStartupChoiceMessage` returns
`None` and Imperial falls to `Debug.MessageBox(GetStartupInfoOnlyText(...))` at `:3586`.

**Exact text, assembled at `:3750`:**
> "You begin in the broad embrace of the Nine Divines, even as the White-Gold Concordat
> presses down on the open worship of Talos."
>
> "Live under the Divines. Your choices will decide how Talos, law, and public duty weigh
> on you."

**Status:** built, and this is strong framing -- it names the Concordat tension in the first
thing an Imperial ever reads. Worth noting that no Imperial startup MESG exists in the ESP;
this is Papyrus-emitted.

### 1.2 Civic acts
**Trigger:** public service, mercy, lawful order, honest work, death duty.
**Channel:** PUSH toast + Book of Days, plus PULL effects.

**Finding:** there are **five civic families** (`GetImperialCivicFamilyLabel` `:292-306`) and
their labels -- `public_service`, `mercy`, `lawful_order`, `honest_work`, `death_duty` -- are
**internal tokens the player never sees**. All five funnel to one shared string:

> "Your public service steadies your devotion." (`:367`)

with a single craft variant, "Completed craft strengthened civic practice." (`:785`).
So sparing a life, keeping the law, and honest labour all report identically -- and a mercy
act literally reports as *public service*.

Book of Days assembles as `stateLabel + ": " + context` -- e.g.
> "Civic Steadiness: Your public service steadies your devotion."

Repeat or capped acts are silent (suppressed when `grantedMetric <= 0.0`,
`PDV_PrismaPresenter.psc:1884`), which is the anti-spam rule working correctly.

**PULL text:** `Imperial Civic Duty` / "Civic duty lends order to your worship, even where
public and private loyalties diverge." and `Civic Faith - Seeker` / "The Nine note your civic
faith. Health Regeneration +4%."

### 1.3 The civic substrate
Tier names the player sees (`:567-580`): **Civic practice quiet -> Civic Steadiness ->
Civic Discipline -> Civic Exemplar**, each a real blessing:
- `Civic Steadiness` / "Civic practice steadies body and road. Maximum Health +5, Maximum Stamina +5."
- `Civic Discipline` / "The Empire's practiced disciplines hold under pressure. +10 / +10."
- `Civic Exemplar` / "Civic duty has become settled practice. +15 / +15."

**Finding:** `PDV_Substrate_ImperialAncestor.psc` emits **no player string at all** -- every
string in it is a trace or a storage key, and `PDV_SubstrateBase.psc:267-274` only traces and
swaps boons on a tier change. A substrate tier crossing reaches the player *only* as the
`"deepen"` phase of the next favor toast. The internal posture labels (`quiet` / `steady` /
`disciplined`) never appear in the Survey.

---

## Act 2 - Being noticed

### 2.1 Broad tier crossings
**Channel:** PUSH -- Book of Days only, no toast (`PDV_OriginRuntimeBase.psc:7218`).
**Exact text:** `GetBroadLaneDisplayName + " has reached " + label`, and for Imperial the lane
is **"The Divines' Regard"** with labels Distant / Observant / Faithful:
> "The Divines' Regard has reached Observant."

**PULL:** `The Divines' Regard - Observant` / "The Divines regard your shared worship. Poison
Resistance +10%." then `- Faithful` / "The Divines deepen their regard... Poison Resistance
+10%, Disease Resistance +10%." Broad caps at Tier 2.

### 2.2 Patron tier crossings
**Channel:** PUSH -- `SurfaceTransition("tier", ...)` (`PDV_DevotionLedger.psc:1163`).
**Journal line** (`PDV_PrismaPresenter.psc:292`):
> "Your devotion to <Deity> has reached <Seeker | Devoted | Champion>."

**Toast band** uses the other vocabulary: Distant / Observant / Faithful / Devoted.

> **Design question surfaced by this:** two parallel tier vocabularies are live at once --
> Seeker/Devoted/Champion in the journal, Observant/Faithful/Devoted in the toast band. The
> word "Devoted" means different positions in each. Worth deciding whether that is intended.

### 2.3 THE BIG ONE - Talos tier reaches are silenced by the Concordat
`PDV_DevotionLedger.psc:1155-1157` with `PDV_OriginRuntime_Imperial.psc:238-248`: **Imperial
Talos tier crossings are suppressed entirely while Concordat standing is above 50.**

So a compliant Imperial who is quietly building devotion to Talos climbs Seeker, Devoted,
Champion and **is told nothing at any of them**. The Concordat does not merely gate the
offer -- it makes the entire Talos relationship invisible. This is the most consequential
silence in the Imperial journey and it is nowhere in the audit queue.

---

## Act 3 - The Concordat, running underneath everything

A parallel track, moving whenever the player acts politically.

**Record layer: entirely empty.** QUST `PDV_RepTrack_ConcordatStanding` (0499C0) has no Name,
0 stages, 0 objectives. GLOB `PDV_GLO_ConcordatStanding` (0499CC) is a bare float.

**Every Concordat word in the game:**
- Survey (`:551-557`): "Under the Concordat, you are <label>."
- Book of Days (`:37-43`): "Under the White-Gold Concordat, you are <label>." -- fired by
  `BuildModeChangeLine` at dawn **when the mode snapshot changes**, pinned, tone
  `reorientation` (`PDV_PrismaPresenter.psc:1083`)
- MCM (`:676`): "Imperial | <label> | <standing>"
- Book summary (`:668`): "Civic faith, Divines, and Concordat pressure leave their marks here."

Labels: Openly Defiant / Privately Defiant / Uncommitted / Publicly Compliant / Concordat Enforcer.

**Correction to an earlier claim of mine:** a transition *is* surfaced -- the dawn mode-change
Book line fires. What is missing is not the beat but its **content**: every line restates the
label and none names the cost.

**What the cost actually is, stated nowhere:** high compliance closes Talos, blunts Stendarr
and Arkay, and -- per 2.3 -- silences Talos tier crossings. The track is Talos's
`GainModifyingTrack` AND `DecayModifyingTrack` (`PDV__ManagerQuest.psc:1164-1168`), so Talos
piety gains slower and decays faster while you comply.

**Locked 2026-08-25:** Talos offers fail gracefully, no offer-time rejection. State copy is
therefore the only channel carrying this. Owner copy in progress on the workbook's
`Concordat Writing` sheet.

---

## Act 4 - The offer

**Trigger:** dawn-only, 50 piety plus qualifying signals on 2 separate days within 7.
**Channel:** PUSH MessageBox, buttons `Accept` / `Not yet` / `Refuse`.
**Note:** a vanilla MessageBox never displays the MESG Name -- only the Description is read.

| Deity | Name (never shown) | Description the player reads |
|---|---|---|
| Akatosh | Akatosh's Order | "Your devotion has not wavered through upheaval. Carry the god of time as your own, and the long order becomes your faith. Will you?" |
| Talos | Talos Calls the Defier | "You kept faith with me where the law forbade it. Carry the old breath openly, and the Empire's own god answers a treason of conscience. Will you?" |
| Kynareth | Kynareth's Road | "The open way has been kind to you. Carry Kynareth as your own, and the road and the sky answer. Will you?" |
| Mara | Mara's House | "You have built and mended where you could. Carry the mother of the people as your own, and the civic heart is yours to keep. Will you?" |
| Zenithar | Zenithar's Trade | "Your work is honest and your weight is true. Carry the trade-god as your own, and the day's labor becomes worship. Will you?" |
| Arkay | Arkay's Covenant | "You have kept the rites the war neglected. Carry Arkay as your own, and the death-cycle is your charge. Will you?" |
| Stendarr | Stendarr's Mercy | "You have stayed the killing hand where the province wanted it loosed. Carry Stendarr as your own. Will you?" |
| Julianos | Julianos' Code | "You study, you weigh, you judge with care. Carry Julianos as your own, and the written truth is your devotion. Will you?" |
| Dibella | Dibella's Grace | "You make beauty and speak well where it matters most. Carry Dibella as your own. Will you?" |

**Four never name their god in the description:** Akatosh ("the god of time"), Talos ("the
Empire's own god"), Mara ("the mother of the people"), Zenithar ("the trade-god"). Since the
Name is not displayed, an Imperial offered Akatosh is never told it is Akatosh. This
independently reproduces the wording backlog's Imperial count of four.

**The three answers:**
- Accept: "You take this patron. The broad faith narrows to one, and the order keeps you as its own."
- Not yet: "Not yet. Broad worship holds, and the patron waits on your word."
- Refuse: "You keep to broad worship. The patronage is declined, and will not be offered again soon."

---

## Act 5 - The patron road

Nine three-rung ladders, all PULL, all written. Two examples:

**Arkay:** "The keeper of the cycle wards your flesh. Disease Resistance +5%." -> "You keep
the vigil between life and death. +15%, Max Health +20." -> `Arkay's Ward - Champion`
"Arkay's ward stands between you and the grave. +27%, Max Health +30."

**Talos:** "Defiance held in secret hardens you. Armor +15." -> "Open faith in the Ninth
steels your arm. Armor +30, One-Handed +8." -> `Talos's Triumph - Champion` "The Hero-God of
Man stands with the faithful. Armor +50, One-Handed +20."

The Talos ladder tracks secrecy -> openness. That is the political arc, and blessing text is
the only place it is currently written.

### 5.1 Champion
**PUSH:** the generic journal line only -- "Your devotion to Arkay has reached Champion."
**No Imperial champion-entry record exists** in any type; "Champion" appears solely as a
blessing tier suffix. The apotheosis moment gets the same sentence as every other tier.

---

## Branches

### Neglect
**Trigger:** civic metric above 0 AND more than 3 days since a civic source (`:107-122`).
**PULL text, and it is good:** `The Divines Grow Distant` / "You have let civic faith lapse.
The Divines' ward against sickness thins -- Disease Resistance -5% until you return to public
service. The real bite comes only at rupture or curse."
**PUSH:** nothing Imperial-specific. `SyncImperialNeglectSpell` (`:124-142`) emits no toast,
no Book entry, no message. The generic "Devotion quiet" dawn toast is **gated to Nord only**
(`PDV_DevotionLedger.psc:2212`). With an active patron an Imperial gets the shared generic
lines -- "A rite has grown quiet and needs attention." / "You return to a rite you had let
fall silent." Broad-worship Imperials get neither.

### Curse
**Mechanics:** VampireHalt, history scar, substrate wipe plus 20.0 cure seed, reward resync
(`:250-273`). `ApplyImperialCurseHandlers` emits no string.
**PUSH:** `GetCurseContextForRace` (`PDV_OriginRuntimeBase.psc:7504-7538`) has branches for
Nord, Altmer, Bosmer, Argonian and Orc -- **no Imperial branch** -- so it returns empty and
an Imperial gets only the bare generic lines: "A curse changes the shape of devotion." / "A
curse gives way to a new shape." / "The curse lifts, and devotion may answer again."
**PULL, and this is Imperial-specific and well written** (`:518-523`):
- "Curse posture: the civic faith is halted while the undeath holds."
- "Curse posture: the civic faith runs strained while the beast is in you."
- "Curse posture: the civic faith is whole again, but the community religion remembers the absence."

**Correction:** an earlier draft said the game never tells an Imperial their devotion is
halted. The Survey does. What is missing is the push at the moment it happens, and any
Imperial voice in the generic curse line.

### The Daedric track
Universal, race-flavoured: silent accrual -> pre-pact notice at piety 20 -> three commitment
signals -> formal offer -> global consent -> Seeker/Devoted/Champion with paired Boon and
Price spells.
**Imperial-specific:** 16 `PDV_Msg_Daedric_*_Response_Imperial` records exist -- one per
Prince, the Imperial cultural reaction. **Debug-only, no organic call site** (owner ruling
2026-08-07). Written, race-specific content no player has ever seen.

---

## The full Survey readout

`GetImperialSurveyText()` (`:489-527`) assembles, in this order:

Base -- with patron: "<Deity> holds your focus among the Nine. Standing: <band>. <Concordat sentence>"
Base -- broad: "You worship the Nine Divines broadly, and your standing is <band>. <Concordat sentence>"

Then, conditionally:
- "The commitment remains, but its boon is suspended until 50 piety."
- "You have kept Talos at hidden shrines, away from watching eyes."
- "You have honored Talos in the open, where the Concordat forbids it."
- "Your patron has taken note of the civic good you have done in their name."
- "Civic practice: <tier name>."
- "You have drifted far enough on the Talos question that a deliberate change of course could now bring you back."
- the curse-posture sentence

This is the richest Imperial surface by a wide margin, and it is entirely pull.

---

## What the walkthrough shows

1. **Pull is strong, push is thin.** Blessings, neglect, curse posture and the Survey are
   well written. The push layer is the startup box, favor toasts, tier journal lines, the
   offer and its answers.
2. **Talos tier silence under the Concordat (2.3) is the sharpest finding** -- a whole
   relationship can progress to Champion invisibly. Not previously in the queue.
3. **Five civic families report as one string**, and mercy reports as "public service".
4. **Two tier vocabularies run in parallel** and disagree on what "Devoted" means.
5. **Concordat has zero record-layer text**; its transition beat exists but only restates the
   label.
6. **Champion gets the generic tier sentence** -- no Imperial recognition of any kind.
7. **Broad-worship Imperials get no neglect push at all** (the dawn toast is Nord-gated).
8. **16 written Imperial Daedric responses are unreachable.**
