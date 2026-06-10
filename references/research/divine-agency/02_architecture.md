# Divine Agency -- Architecture (Buildable Spec)

**Status:** Design dossier, 2026-06-11. Research only -- no Papyrus/CK/ESP changes.
**Dependencies:** LD-P1 engine (RunDawnUpdateMood, OnMoodBandCross, RunDawnProcessDemands,
PDV_GLO_PatronMoodBand, active patron pool, StorageUtil PDV.Mood.* namespace) must be live
before any emissary or champion mechanism builds. Congregation aura can be authored in CK
independently, but the condition-read on PDV_GLO_PatronMoodBand requires the global to exist.

---

## 1. StorageUtil Namespaces

All keys follow existing PDV.* discipline: floats via GetFloatValue/SetFloatValue, ints via
GetIntValue/SetIntValue. Emissary and congregation state is form-keyed (per deity); a global
spawn-guard is None-keyed (one active emissary at a time).

```
; Emissary anti-spam (per deity form, mirrors PDV.Intervention.Smite.Day pattern)
PDV.Agency.Emissary.<deity>.Day       (int)   ; devotion-day index of last emissary spawn
PDV.Agency.Emissary.<deity>.LastFire  (float) ; gametime of last spawn (cooldown check)

; Global spawn guard (None-keyed -- only one emissary active at a time)
PDV.Agency.Emissary.Active            (int)   ; 1 = emissary currently alive in world
PDV.Agency.Emissary.DeityIndex        (int)   ; DeityIndex of the sponsoring deity
PDV.Agency.Emissary.SpawnedAt         (float) ; gametime of spawn (for lifetime check)

; Champion anti-spam (per deity form)
PDV.Agency.Champion.<deity>.Day       (int)   ; devotion-day index of last champion spawn
PDV.Agency.Champion.<deity>.LastFire  (float) ; gametime

; Congregation aura: no runtime StorageUtil needed (pure CK MGEF condition on global)
```

---

## 2. New PDV_DeityBase Authored Properties

These are ESP-only VMAD properties (no Papyrus source change on PDV_DeityBase.psc needed
until implementation):

```
; Emissary authoring
ActorBase Property EmissaryActorBase Auto      ; the NPC actor form for this deity's emissary
Float Property EmissaryLifetimeDays = 0.014 Auto ; ~20 real minutes at normal timescale
String Property EmissaryToastKey = "" Auto     ; SendPrismaEventToast context string

; Champion authoring (parallel arrays by band, index 0=Wroth/1=Cool/2=Pleased/3=Exalted)
ActorBase[] Property ChampionActorBases Auto   ; sponsored champion per band
ActorBase[] Property RivalAgentActorBases Auto ; rival-sent agent per band

; Congregation aura: no new PDV_DeityBase properties needed -- SPID INI + CK keyword only
```

If EmissaryActorBase is None for a given deity, TrySpawnEmissary returns immediately --
deities without authored emissaries are silent (same failsafe as Smite_Effect on A3d).

---

## 3. Congregation Aura -- SPID INI + MGEF Pattern

**Reuses the B3 politics pattern canonically (`08_deity_politics_architecture.md` section 4).
Do not redesign. Reference that spec; this section records divine-agency-specific parameters.**

### 3.1 Global condition

`PDV_GLO_PatronMoodBand` mirrors the active patron's band (0=Wroth, 1=Cool, 2=Pleased,
3=Exalted). Updated by `RunDawnUpdateMood` whenever the active patron's band changes (LD-P1
seam). The congregation MGEF reads this global in a CK condition.

### 3.2 SPID INI (P1 pilot: Stendarr)

File: `PlayerDevotion_Stendarr_CongregAura_DISTR.ini`

```ini
; Distribute PDV_KW_StendarrCongregAura to Vigilants of Stendarr faction NPCs.
; The keyword carries an Ability MGEF whose condition reads PDV_GLO_PatronMoodBand.
; When Stendarr is the active patron at Pleased+ (band >= 2), Vigilants gain a
; disposition bonus toward the player. When Wroth (band = 0), they gain a penalty.
Keyword = PDV_KW_StendarrCongregAura|ActorTypeNPC|NONE|NONE|NPC|VigilantsOfStendarr
```

### 3.3 MGEF: PDV_MG_StendarrCongregAura (CK authoring)

```
MGEF: PDV_MG_StendarrCongregAura
  Type: Ability (always-on while keyword present)
  Magnitude: 15 (disposition bonus)
  Condition A: GetGlobalValue(PDV_GLO_PatronMoodBand) >= 2
               Subject: Target (NPC)
               ; This effect is active when the active patron is Pleased or Exalted.

; Separate MGEF for the penalty variant (or use a negative magnitude under a <= 0 condition):
MGEF: PDV_MG_StendarrCongregWrath
  Type: Ability
  Magnitude: -20 (disposition penalty)
  Condition A: GetGlobalValue(PDV_GLO_PatronMoodBand) == 0
               ; Fires only when active patron is at Wroth
```

**Note:** GetGlobalValue in a CK condition is a vanilla function -- no scripts. The MGEF
re-evaluates on NPC package change or cell reentry, not per-frame. This is intentional:
the aura is ambient texture. If a faster response is needed, the vanilla `SetRelationshipRank`
could be called from a Papyrus hook, but that requires per-NPC scripts and defeats the
purpose of SPID distribution.

**Vanilla faction coverage for Stendarr:** `VigilantsOfStendarr` is a vanilla-defined
faction. SPID can distribute to it directly. For other deities (Boethiah, Mephala, Nocturnal),
vanilla priest factions are thinner -- distribute to quest-participant NPCs or use a formlist
of specific actor records instead of a faction name.

### 3.4 Expanding to Other Deities

Per deity: one INI, one (or two) MGEF records, one keyword. No per-deity Papyrus. Author
them as the pilot proves the pattern. Priority order: Stendarr (P1) -> Dibella/Mara (clear
temple factions) -> Daedric deities (thin vanilla factions, use quest NPCs).

---

## 4. Emissary Spawn -- Function Spec

### 4.1 TrySpawnEmissary (new function in PDV__ManagerQuest)

**Insertion point:** inside `OnMoodBandCross(PDV_DeityBase deity, Int oldBand, Int newBand)`
(LD-P1 seam, not yet live), after `SyncPatronBoonsToBand`. Fire on any band-cross (up or
down) -- the deity can send an emissary for good news or bad.

```
Function TrySpawnEmissary(PDV_DeityBase deity, Int newBand)
    ; failsafe: only if deity has an authored emissary
    if !deity.EmissaryActorBase
        return
    endIf
    ; only for active patron (pool filter)
    if deity != _activeDeity
        return
    endIf
    ; do not spawn in interior cells
    if Game.GetPlayer().IsInInterior()
        return
    endIf
    ; global guard: only one active emissary at a time
    if StorageUtil.GetIntValue(None, "PDV.Agency.Emissary.Active") == 1
        return
    endIf
    ; anti-spam: once per week per deity
    Form deityForm = GetDeityFormOrNone(deity)
    Int currentDay = deity.GetDevotionDayIndex()
    Float lastFire = StorageUtil.GetFloatValue(deityForm, "PDV.Agency.Emissary.LastFire")
    if lastFire > 0.0 && (Utility.GetCurrentGameTime() - lastFire) < 7.0
        return
    endIf
    ; MCM density gate (reuse existing PassesDensityGate() -- LD-P1/A2)
    if !PassesDensityGate()
        return
    endIf
    ; spawn
    ObjectReference spawnedRef = Game.GetPlayer().PlaceAtMe(deity.EmissaryActorBase, 1, false, false)
    if !spawnedRef
        return
    endIf
    ; record state
    StorageUtil.SetIntValue(None, "PDV.Agency.Emissary.Active", 1)
    StorageUtil.SetIntValue(None, "PDV.Agency.Emissary.DeityIndex", deity.DeityIndex)
    StorageUtil.SetFloatValue(None, "PDV.Agency.Emissary.SpawnedAt", Utility.GetCurrentGameTime())
    StorageUtil.SetFloatValue(deityForm, "PDV.Agency.Emissary.LastFire", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(deityForm, "PDV.Agency.Emissary.Day", currentDay)
    ; toast
    if deity.EmissaryToastKey != ""
        SendPrismaEventToast("emissary", deity, deity.EmissaryToastKey, "", "")
    endIf
    ; schedule cleanup
    ; PROOF ITEM: RegisterForSingleUpdateGameTime must be called on a script with OnUpdateGameTime.
    ; PDV__ManagerQuest already uses RegisterForSingleUpdateGameTime in the demand scheduler --
    ; confirm the call is valid from that script before wiring. If not, author a helper
    ; ActiveMagicEffect or Quest fragment that holds the cleanup timer.
    RegisterForSingleUpdateGameTime(deity.EmissaryLifetimeDays)
EndFunction
```

### 4.2 Emissary cleanup (OnUpdateGameTime slot-in)

```
; In PDV__ManagerQuest OnUpdateGameTime (or a dedicated cleanup helper):
if StorageUtil.GetIntValue(None, "PDV.Agency.Emissary.Active") == 1
    ; PROOF ITEM: we do not hold a reference to spawnedRef across save/load.
    ; The safest approach is to tag the spawned actor with a keyword at spawn time
    ; (e.g. PDV_KW_EmissaryTag) and use Game.FindAllRefsWithKeyword() to locate
    ; and delete it. Or: store the ref's FormID in StorageUtil if PapyrusUtil
    ; Form storage is available.
    ; For P1: accept that on a save/reload mid-lifetime the ref may be lost;
    ; clear the Active flag after 1 + lifetime to self-heal.
    Float spawnedAt = StorageUtil.GetFloatValue(None, "PDV.Agency.Emissary.SpawnedAt")
    Int activeDeityIdx = StorageUtil.GetIntValue(None, "PDV.Agency.Emissary.DeityIndex")
    PDV_DeityBase activeDeity = GetDeityByIndex(activeDeityIdx)
    Float lifetime = 0.014
    if activeDeity
        lifetime = activeDeity.EmissaryLifetimeDays
    endIf
    if Utility.GetCurrentGameTime() > spawnedAt + lifetime
        ; ref likely gone or strayed; clear guard
        StorageUtil.SetIntValue(None, "PDV.Agency.Emissary.Active", 0)
    endIf
endIf
```

**Open proof item:** `RegisterForSingleUpdateGameTime` on PDV__ManagerQuest -- confirm this
is already used in the demand scheduler (LD-P1) and the same registration can fire the
emissary cleanup. If not, author a dedicated helper object.

---

## 5. Champion Sponsorship -- Function Spec

**Insertion point:** same as emissary -- `OnMoodBandCross`. Champion fires on up-cross to
Pleased or Exalted (patron-sponsored champion) or on down-cross to Wroth (rival-sent agent).
The rival-agent variant slots into `ApplyRivalryPenalties` (live :10094) as an optional
`TrySpawnRivalAgent(rivalDeity, sourceAmount)` call after the piety penalty, gated on the
same Wroth-band check as A3f sacrifice.

```
Function TrySpawnChampion(PDV_DeityBase deity, Int newBand)
    ; Only spawn for patron at Pleased+ (not rival agents -- see TrySpawnRivalAgent)
    if newBand < 2
        return
    endIf
    if !deity.ChampionActorBases || deity.ChampionActorBases.Length <= newBand
        return
    endIf
    ActorBase championBase = deity.ChampionActorBases[newBand]
    if !championBase
        return
    endIf
    if Game.GetPlayer().IsInInterior()
        return
    endIf
    ; anti-spam: once per 14 days per deity
    Form deityForm = GetDeityFormOrNone(deity)
    Float lastFire = StorageUtil.GetFloatValue(deityForm, "PDV.Agency.Champion.LastFire")
    if lastFire > 0.0 && (Utility.GetCurrentGameTime() - lastFire) < 14.0
        return
    endIf
    if !PassesDensityGate()
        return
    endIf
    ObjectReference spawnedRef = Game.GetPlayer().PlaceAtMe(championBase, 1, false, false)
    if spawnedRef
        ; Set allegiance: Friend (3) for patron champion
        ; PROOF ITEM: Actor.SetRelationshipRank signature -- confirm parameter order
        ; (Game.GetPlayer(), rank). Vanilla: Actor.SetRelationshipRank(akOtherActor, aiRank)
        ; where rank 3 = Friend, 4 = Ally, -4 = Enemy.
        Actor championActor = spawnedRef as Actor
        if championActor
            championActor.SetRelationshipRank(Game.GetPlayer(), 3)
        endIf
        StorageUtil.SetFloatValue(deityForm, "PDV.Agency.Champion.LastFire", Utility.GetCurrentGameTime())
        StorageUtil.SetIntValue(deityForm, "PDV.Agency.Champion.Day", deity.GetDevotionDayIndex())
        SendPrismaEventToast("champion", deity, "", "", "")
    endIf
EndFunction
```

**Level-scaling approach:** author three ChampionActorBases variants per deity (one per
positive band) as separate ActorBase records or a leveled actor form. Read
PDV_GLO_PatronMoodBand via script-poll at spawn time -- the band is already written to
StorageUtil as `PDV.Mood.<deity>.Band` by RunDawnUpdateMood; read it directly, pick the
appropriate ActorBase. No per-frame polling required; the choice is baked at spawn.

---

## 6. Pacing Calibration

All tunables anchored to the pacing model: PIETY_DAILY_MAX_DELTA = 4.3 (live :313 in
PDV__ManagerQuest.psc), band thresholds -40/0/10/55 (Wroth/Cool/Pleased/Exalted per
`04_living_deities_architecture.md` section 2.2).

| Tunable | Value | Rationale |
|---|---|---|
| Emissary cooldown | 7 game-days | Band changes at most once per ~6 days at max signal (Kyne alpha 0.12); one emissary per band cycle |
| Champion cooldown | 14 game-days | Champion scenes are higher-intensity; two-week floor |
| Emissary lifetime | 0.014 game-days (~20 min realtime) | Long enough to find; short enough not to clutter the world |
| Congregation MGEF disposition | +15 (Pleased) / -20 (Wroth) | Felt but not game-breaking; scaled to vanilla relationship rank deltas |
| Global spawn guard | 1 active emissary at a time | Prevent stacking; deities queue, not simultaneous |

These are first-pass defaults. The authoring CSVs and VMAD properties are the tuning surface;
no magnitude is hardcoded in Papyrus (always read from authored ActorBase or EmissaryLifetimeDays
property).

---

## 7. Verifier Expectations

Extend `tools/pdv_verify.mjs` or `tools/pdv_content_verify.mjs` with:

1. **Congregation aura:** PDV_KW_StendarrCongregAura keyword present on at least one
   Vigilant NPC after SPID loads; MGEF condition correctly reads PDV_GLO_PatronMoodBand
   (confirm condition target and global ID in CK data).
2. **Emissary anti-spam:** PDV.Agency.Emissary.<deity>.Day and .LastFire populated after a
   spawn fires; second TrySpawnEmissary call within 7 days returns without spawning.
3. **Emissary active guard:** PDV.Agency.Emissary.Active = 1 while emissary alive;
   returns to 0 after lifetime expires (smoke: advance game time by EmissaryLifetimeDays,
   verify Active = 0).
4. **Emissary no-interior:** TrySpawnEmissary does not fire when player is in an interior
   cell (test: enter Breezehome, force band-cross via console, verify no spawn).
5. **Champion allegiance:** spawned champion actor has RelationshipRank(player) = 3 (Friend)
   immediately after spawn; rival agent has rank = -4 (Enemy).
6. **No double-spawn:** band-cross fires TrySpawnEmissary once; a second cross within 7
   days is blocked by anti-spam key.

---

## 8. Open Owner Decisions

| # | Decision | Options | Blocking |
|---|---------|---------|---------|
| 1 | Congregation P1 pilot deity: confirm Stendarr, or start with a Daedric deity | Stendarr (recommended, clear faction) vs Boethiah/Mephala (quest NPCs) | Before CK authoring |
| 2 | Emissary P1 pilot deity: confirm Hircine hunt-emissary (curse-gated actor provides mood substrate), or choose another | Hircine (hunt raven or wolf; curse-gated) vs Stendarr Vigilant | After LD-P1 in-game proof |
| 3 | Emissary cleanup approach: keyword-tag + FindAllRefsWithKeyword, or PapyrusUtil Form storage, or accept save/reload loss | Robustness vs complexity tradeoff | Before implementing TrySpawnEmissary |
| 4 | Champion actor design: separate authored ActorBase records per band vs leveled actor form | Authoring complexity vs save-bloat | Before CK authoring |
| 5 | Congregation MGEF magnitude: +15/-20 disposition tuning | Felt-but-not-breaking vs too subtle | After in-game proof |
| 6 | Sequencing: congregation aura (CK-only) vs emissary P1 -- can congregation author in parallel with LD-P1 Papyrus wiring? | Parallel workstream vs sequential | No technical blocker; congregation does not depend on LD-P1 Papyrus, only on the global existing |
