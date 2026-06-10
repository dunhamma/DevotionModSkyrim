# B3 Deity Politics Architecture

**Status:** Design dossier, 2026-06-10. Buildable spec. No Papyrus/CK/ESP changes in this document.
**Dependencies:** LD-P1 mood namespaces (`PDV.Mood.<deity>`, `PDV.Mood.<deity>.Band`) and
`PDV_GLO_PatronMoodBand` global must be live before jealousy and alliance mechanisms build.
Rivalry surfacing and opinion table are fully independent.

---

## 1. Opinion Table CSV Shape

File: `references/authoring/PDV_DeityPolitics.csv`

```
source,target,relation,multiplier,fused_boon_key,toast_context,jealousy_context,lore_basis,invented,notes
Talos,AuriEl,RIVAL,0.40,,AuriEl watches your devotion with cold eyes.,AuriEl grows distant as Talos claims you.,Talos-ban / Altmer divine erasure,,
Boethiah,Mephala,ALLY,0.00,pdv_boethiah_mephala_fused,,Mephala notes Boethiah has your ear.,Dunmer Good Daedra Reclamation triad,,pilot alliance
Mephala,Boethiah,ALLY,0.00,pdv_boethiah_mephala_fused,,Boethiah watches while Mephala weaves.,Dunmer Good Daedra Reclamation triad,,symmetric pair
Mara,Dibella,ALLY,0.00,pdv_mara_dibella_fused,,,Divine love and beauty; complementary domains,YES,owner must ratify
Dibella,Mara,ALLY,0.00,pdv_mara_dibella_fused,,,Divine love and beauty; complementary domains,YES,symmetric pair; owner must ratify
Stendarr,Boethiah,RIVAL,0.30,,Boethiah's faithful earn Stendarr's suspicion.,Stendarr grows wary as you prove yourself to Boethiah.,Vigilants vs Good Daedra,,
Malacath,Trinimac,RIVAL,0.50,,Malacath stirs with the memory of what was lost.,Malacath's contempt sharpens.,Malacath IS Trinimac; divine identity rupture,,
Arkay,Sithis,RIVAL,0.35,,Arkay's order resists the void you acknowledge.,Arkay's blessing grows thin in the shadow of Sithis.,Life-death cycle vs primordial void,,
Kyne,Shor,ALLY,0.00,,,,Nordic paired cosmology; storm-mother and warrior-king,,no fused boon designed yet
```

### Column definitions

| Column | Type | Meaning |
|--------|------|---------|
| `source` | string | DeityName of the reacting deity (the one whose piety triggered the check) |
| `target` | string | DeityName of the affected deity |
| `relation` | RIVAL / ALLY | RIVAL: target loses piety/mood on source gain; ALLY: fused boon check |
| `multiplier` | float [0,1] | RIVAL only: fraction of sourceAmount applied negative to target piety |
| `fused_boon_key` | string | ALLY only: StorageUtil key prefix for the fused boon SPEL formID |
| `toast_context` | string | Context string for the `"rivalry"` toast (enriches existing toast) |
| `jealousy_context` | string | Text for `"jealousy"` band-cross omen toast |
| `lore_basis` | string | Lore citation; blank = see notes |
| `invented` | YES / blank | Flag: owner must ratify before ESP authoring |
| `notes` | string | Free text |

**Compile output:** a flat JSON keyed by `"<source>|<target>"` loaded into StorageUtil at
startup (same pattern as `PDV_QuestReactionMatrix_Full`). Self-test gates: no empty source/target;
RIVAL multiplier in (0, 1]; ALLY pairs must be symmetric (both directions present); `invented`
rows flagged in compiler output.

---

## 2. Jealousy Hook

### Insertion point

Inside `RunDawnUpdateMood` (LD-P1 `PDV__ManagerQuest.psc`, after per-deity EWMA recompute),
add one call per deity that has RIVAL rows and is NOT the active patron:

```
; After mood recompute for active patron _activeDeity:
ApplyJealousyDips(_activeDeity, clampedToday)
```

### New function: `ApplyJealousyDips(PDV_DeityBase sourceDeity, Float clampedToday)`

Mirrors the shape of `ApplyRivalryPenalties` (`PDV__ManagerQuest.psc:9858`):

```
Function ApplyJealousyDips(PDV_DeityBase sourceDeity, Float clampedToday)
    ; Only fires if source is the active patron and had a net positive day.
    if sourceDeity != _activeDeity
        return
    endIf
    if clampedToday <= 0.0
        return
    endIf

    Quest[] rivalForms = sourceDeity.RivalDeities
    Float[] rivalMultipliers = sourceDeity.RivalMultipliers
    if !rivalForms || !rivalMultipliers
        return
    endIf

    Int i = 0
    while i < rivalForms.Length
        if i < rivalMultipliers.Length
            PDV_DeityBase rivalDeity = rivalForms[i] as PDV_DeityBase
            if rivalDeity && IsDeityInActivePool(rivalDeity)
                Float dip = rivalMultipliers[i] * clampedToday * 0.15 * -1.0
                ; Write directly to PDV.Mood.<rival> -- LD-P1 namespace
                Form rivalForm = GetDeityFormOrNone(rivalDeity)
                Float currentMood = StorageUtil.GetFloatValue(rivalForm, "PDV.Mood")
                Float newMood = Clamp(currentMood + dip, -100.0, 100.0)
                StorageUtil.SetFloatValue(rivalForm, "PDV.Mood", newMood)
                ; Band recompute and jealousy toast if band crossed
                Int oldBand = StorageUtil.GetIntValue(rivalForm, "PDV.Mood.Band")
                Int newBand = ComputeBandFromMood(rivalDeity, newMood)
                if newBand < oldBand
                    StorageUtil.SetIntValue(rivalForm, "PDV.Mood.Band", newBand)
                    SendPrismaEventToast("jealousy", rivalDeity, GetJealousyContext(sourceDeity, rivalDeity), "", "")
                endIf
            endIf
        endIf
        i += 1
    endWhile
EndFunction
```

Notes:
- `IsDeityInActivePool` is LD-P1 (live source does not yet have it; see `04_living_deities_architecture.md section 3.3`).
- `ComputeBandFromMood` is LD-P1 (the band threshold reader inside `RunDawnUpdateMood`).
- `GetDeityFormOrNone` is live at `PDV__ManagerQuest.psc:9892`.
- `GetJealousyContext` reads the compiled StorageUtil opinion table entry for `(source|rival)`.
- The 0.15 coefficient is the jealousy fraction constant. Named constant `JEALOUSY_FRACTION = 0.15`
  to allow future tuning without touching the loop.

---

## 3. Fused Boon Mechanics

### New authored properties on `PDV_DeityBase` (ESP-only, new columns)

```
Quest[] Property AlliancePartners Auto     ; parallel array with AllianceBoons
Spell[] Property AllianceBoons Auto        ; fused boon spell for each partner pair
```

These are pure VMAD properties; no Papyrus source change on `PDV_DeityBase.psc` needed.
They are populated in CK for the two pilot deities (Boethiah and Mephala) only.

### New function: `CheckAndSyncAllianceBoons(PDV_DeityBase deity)`

Called once per deity in `RunDawnUpdateMood`, after mood bands are updated:

```
Function CheckAndSyncAllianceBoons(PDV_DeityBase deity)
    Quest[] partners = deity.AlliancePartners
    Spell[] fusedBoons = deity.AllianceBoons
    if !partners || !fusedBoons
        return
    endIf
    Int i = 0
    while i < partners.Length && i < fusedBoons.Length
        PDV_DeityBase partner = partners[i] as PDV_DeityBase
        Spell fused = fusedBoons[i]
        if partner && fused
            Form partnerForm = GetDeityFormOrNone(partner)
            Int myBand = StorageUtil.GetIntValue(GetDeityFormOrNone(deity), "PDV.Mood.Band")
            Int partnerBand = StorageUtil.GetIntValue(partnerForm, "PDV.Mood.Band")
            Bool shouldHave = (myBand >= 2) && (partnerBand >= 2)  ; >= Pleased
            Bool hasIt = Game.GetPlayer().HasSpell(fused)
            if shouldHave && !hasIt
                Game.GetPlayer().AddSpell(fused, False)
                ; One-shot Marked toast (SurfaceTransition guard prevents repeat)
                SurfaceTransition("alliance", deity.DeityName + "_" + partner.DeityName, "granted", -1, "positive")
            elseIf !shouldHave && hasIt
                Game.GetPlayer().RemoveSpell(fused)
                SurfaceTransition("alliance", deity.DeityName + "_" + partner.DeityName, "lost", -1, "neutral")
            endIf
        endIf
        i += 1
    endWhile
EndFunction
```

Notes:
- Call from `RunDawnUpdateMood` AFTER all EWMA and jealousy passes complete.
- Only call on deities in the active patron pool (pool filter).
- `SurfaceTransition` at `PDV__ManagerQuest.psc:1119` is live and uses a StorageUtil one-shot
  guard, so the alliance-granted toast fires once per direction change.
- The family-cap rule: the fused boon MGEF must be authored with a non-stacking flag and should
  be weaker than either deity's T3 boon individually.

### Alliance check insertion order in `RunDawnUpdateMood`

```
; Per-deity loop:
RunDawnEWMAUpdate(deity)          ; compute new mood, update band
ApplyJealousyDips(deity, ...)     ; jealousy hits on rivals (only for active patron)
CheckAndSyncAllianceBoons(deity)  ; grant/revoke fused boons
```

---

## 4. SPID INI and Global Condition Pattern

### Global: `PDV_GLO_PatronMoodBand`

Already specified in LD-P1 (`04_living_deities_architecture.md section 2.3`). Mirrors the active
patron's mood band (0=Wroth, 1=Cool, 2=Pleased, 3=Exalted). Updated in `RunDawnUpdateMood`
whenever the active patron's band changes.

### SPID INI structure (one INI per deity with authored rival)

File: `PlayerDevotion_Talos_RivalAura_DISTR.ini`

```ini
; Distribute PDV_KW_TalosPatronRivalAura to Kynareth/Akatosh temple priests.
; The keyword carries a MGEF whose condition reads PDV_GLO_PatronMoodBand.
; When the active patron (Talos) is at Wroth (band=0), priests of Auri-El-adjacent
; factions experience a disposition offset.
Keyword = PDV_KW_TalosPatronRivalAura|ActorTypeNPC|NONE|NONE|NPC|TemplePriestKynareth,TemplePriestAkatosh
```

### MGEF condition pattern (CK authoring, no Papyrus)

```
MGEF: PDV_MG_RivalDispositionAura
  Type: Ability (always-on while present)
  Condition: GetGlobalValue(PDV_GLO_PatronMoodBand) < 2
    ; Fires when active patron is below Pleased
  Effect: FrenzyMagnitude -15 (disposition penalty toward player)
           OR: a ForceGreet / unique dialogue condition flag keyword
```

Notes:
- The MGEF applies when the keyword is distributed; the condition gates its active state.
- `GetGlobalValue` in CK conditions is a vanilla function -- no scripts involved.
- The MGEF cannot update live mid-scene; it re-evaluates on NPC-package change or cell reentry.
  This is intentional and acceptable: the aura is ambient texture, not real-time tracking.
- Faction coverage gap: for Boethiah/Mephala (Dunmer Good Daedra), vanilla priest factions
  are thin. Author the INI keyword distribution against quest-stage NPCs (Boethiah's Calling
  participants, Mephala Ebony Blade quest) rather than generic faction membership.
- The SPID INI reads `NPC` type from the vanilla faction list. Name it in the `_DISTR.ini`
  convention so it loads last and conflicts nothing.

### One INI per rivalry pair (P1 pilot scope: one INI)

P1 pilot: distribute only for Talos-patron vs Kynareth/Akatosh-adjacent priests.
Expand to Boethiah+Mephala and Malacath+Trinimac in later passes.

---

## 5. Verifier Expectations

Extend `tools/pdv_verify.mjs` or `tools/pdv_content_verify.mjs` with:

1. **Opinion table integrity:** `PDV_DeityPolitics.csv` self-test -- no empty source/target;
   RIVAL multiplier in (0,1]; ALLY pairs symmetric; `invented` rows reported as warnings, not errors.
2. **RivalDeities[] wiring:** for each RIVAL row in the opinion table, verify that the source
   deity's ESP VMAD `RivalDeities` and `RivalMultipliers` arrays are populated (post-CK authoring).
3. **AlliancePartners[] wiring:** for each ALLY pair, verify symmetric VMAD on both deities.
4. **Fused boon presence:** for each ALLY pair with a `fused_boon_key`, verify the SPEL record
   exists in the ESP.
5. **Jealousy magnitude check:** in smoke log, verify `PDV.Mood.<rival>` decrements on the day
   a patron earns positive piety. Quantitative: at max daily signal (4.3), expect AuriEl dip
   of `0.40 * 4.3 * 0.15 = 0.258` mood points.
6. **Alliance grant/revoke:** fused boon present when both allies at Pleased+; absent when
   either drops to Cool. No double-grant (presence check before AddSpell).
7. **SPID aura (smoke only):** `PDV_KW_TalosPatronRivalAura` keyword present on at least one
   temple priest NPC in the pilot run; condition correctly gated on band value.

---

## 6. Open Owner Decisions

| # | Decision | Options | Blocking |
|---|---------|---------|---------|
| 1 | Ratify INVENTED opinion table entries (Mara+Dibella, Kyne+Shor ALLY) | Accept / revise / drop | Before ESP wiring |
| 2 | Fused boon SPEL designs: what do Boethiah+Mephala and Mara+Dibella fused boons actually DO | Domain-fused MGEF designs (owner lore call) | Before CK authoring |
| 3 | SPID aura strength: disposition penalty magnitude and scope (which NPCs) | Tuning decision | Before CK authoring |
| 4 | Sequencing vs LD-P1: build politics alongside LD-P1 Block B, or as a separate LD-P2+ workstream | Project scheduling | No technical blocker |
| 5 | Whether the `"jealousy"` toast is a new `eventName` type in the Prisma bridge or reuses `"rivalry"` with a different context | Prisma bridge design (may have UI implications) | Before wiring jealousy toast |
