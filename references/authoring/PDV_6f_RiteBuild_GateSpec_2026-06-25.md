# 6f Variety Rites -- Build Gate-Spec + Turnkey Record Manifest (2026-06-25)

**Status: Papyrus rite trios BUILT + committed + compiling 0/0 (inert until records bind).
ESP records PENDING (turnkey below -- a supervised `--dry-run` -> `--esp` authoring pass).**

Commits this session:
- `14d9ac3` Orc Trial of Iron Papyrus trio
- `9b73bf2` Redguard Remembering of Names Papyrus trio
- `2c3e26e` Altmer Disciplines of Return Papyrus trio

All three mirror the proven **Bosmer Naming** template (`TryBosmerNaming` ~3862 /
`ApplyBosmerNaming` / `SyncBosmerNaming` / `GetBosmerNamingSpell` /
`RemoveBosmerNamingSpells` / `IsBosmerNamingCoherent`): sleep-triggered, 7-day cooldown,
> Superseded 2026-07-13 for the Altmer decline edge only: `Not yet` still does not
> spend the seven-day accepted-rite cooldown, but now records a separate
> three-devotional-day prompt cooldown. The implementation and current player guide
> are authoritative; the historical R4 wording below is retained as evidence.

"Not yet" doesn't spend cooldown, one-active clear-before-add, dawn fade/restore on
coherence break. Each is `None`-guarded so it compiles and stays inert until its records
are authored + VMAD-wired.

---

## Ratified decisions (the Pending-row open items, resolved this session)

**Cross-cutting:**
- **Rite GRANTS record no `PDV.Driver.*`** (Ledger carve-out). Rites grant *spells*
  (favor/buff channel), not piety -- there is no piety pulse to attribute, so the
  ledger-coverage audit must NOT demand a driver on a rite grant. (Bosmer Naming sets the
  precedent: its grant records no driver.) Only a tranche *piety* pulse (e.g. a pilgrimage
  arrival routed through a path signal) records a driver.
- **Anti-farm:** the rite is capped by the 7-day cooldown + one-active; no piety pulse on
  the grant, so no per-pulse cap needed on the rite itself.
- **Regen axes = PeakValueModifier**, never ValueModifier (durable convention).

**Orc -- Trial of Iron (magnitudes ACCEPTED as shipped):**
- Tusk = Unarmed +5, Shield = DamageResist +5 (armor points), Hammer = Smithing +5,
  Yoke = CarryWeight +15. (SPEL+MGEF already exist + readback-clean.)
- Trigger: at the declared community rest cell (`IsPlayerAtDeclaredRestCell`,
  `PDV.Orc.HearthRest.DeclaredFormID`) -- built infra, no new FLST/LCTN.
- Coherence: life-mode standing unchanged since rite (`PDV_OrcLifeModeTrack.GetCurrentState`).

**Redguard -- Remembering of Names:**
- Blade = OneHanded +5; Road = StaminaRateMult **PeakValueModifier** +8%; Rest = HealRate
  **PeakValueModifier** +5%; **Harvest = Speech +5%** (vanilla has no barter AV -- reconciled
  to Speech, the Bosmer Keeper->CarryWeight precedent; no other Redguard told-self uses
  Speech). Each a constant ability MGEF (one-active, not timed).
- Trigger: declared rest cell (`PDV.Redguard.AncestralRest`). Coherence: sect unchanged
  (`PDV_RedguardSectTrack`). Private-context gate: **dropped for 1.0** (sleep-at-rest-cell
  is the anchor; private-ownership condition deferred to post-1.0). Vampire earn-halt on
  tranche pulses: **deferred** (the rite grant awards no piety, so the leak doesn't apply
  to it; signatures are a separate beat).

**Altmer -- Disciplines of Return:**
- Four schools, each **-5% spell cost**: Alteration / Destruction / Illusion / Restoration
  (`PDV_SPEL_AltmerDiscipline_<School>` + paired `PDV_MGEF_*`, Fortify-school cost archetype).
- Trigger: at sleep (`HandleAltmerSleepEvents`, already curse-guarded) -- no Chamber-of-Study
  declared cell required for 1.0 (L2 not built; the rite anchors on rest).
- Coherence: `ALTMER_CRISIS_NONE` or `ALTMER_CRISIS_SCARRED_RESOLVED` AND not
  `IsAltmerFavorSuppressedByCurse()`.
- **L3 "Syrabane's Hand" reskin:** owner ruling = reskin to a cleanly-detectable Syrabane
  beat (enchant/recharge, or cast-a-Ward) -- a separate SIGNATURE beat, NOT the rite; specced
  as a follow-on (needs a cast/enchant hook). The L5 rite ships this session.
- **Chantry pilgrimage = 7 verified stations** (station-2 "authored Auri-El surface" dropped
  -> 2.0 backlog). The Chantry/L4 is a separate pilgrimage beat (FLST), not the L5 rite.

---

## Turnkey record manifest (the supervised authoring pass)

**Method:** clone `tools/pdv-bosmer-variety-author/Program.cs` per race (keep the fail-closed
FLST + `EnsureMessage`/`EnsureSpell`+MGEF + VMAD-forward-wire shape). Route SPEL/MGEF through
it or `pdv-phase20-reward-author`. **`--dry-run` FIRST** to catch Mutagen `ActorValue` enum
drift (regen = PeakValueModifier; confirm `StaminaRateMult`, `HealRate`, `Speech`, and the
Fortify-school cost archetype member names), then `--esp` (backup first). `--check` slot dump
must be clean; then `pdv_verify` FAIL=0, `pdv_compile` 0/0 (properties now bind), houseCARL
readback.

### Orc (smallest -- 1 record)
| Record | Type | Detail |
|---|---|---|
| `PDV_MESG_Orc_TrialOfIron` | MESG | MessageBox; buttons `[Tusk, Shield, Hammer, Yoke, Not yet]` (index 0-3 = discipline, 4 = Not yet). Body lists the four disciplines + effects (effects in BODY, not buttons). VMAD-wire `PDV_MESG_Orc_TrialOfIron` on `PDV__ManagerQuest`. |
| (SPEL+MGEF x4) | -- | ALREADY EXIST (`PDV_SPEL_Orc_TrialOfIron_*`) -- do NOT re-author. |

### Redguard (5 records)
| Record | Type | Magnitude / AV |
|---|---|---|
| `PDV_SPEL_RedguardRemember_Blade` (+MGEF) | SPEL+MGEF ability | OneHanded +5 |
| `PDV_SPEL_RedguardRemember_Road` (+MGEF) | SPEL+MGEF ability | StaminaRateMult +8% **PeakValueModifier** |
| `PDV_SPEL_RedguardRemember_Rest` (+MGEF) | SPEL+MGEF ability | HealRate +5% **PeakValueModifier** |
| `PDV_SPEL_RedguardRemember_Harvest` (+MGEF) | SPEL+MGEF ability | Speech +5% |
| `PDV_MSG_RedguardRemembering` | MESG | buttons `[Blade, Road, Rest, Harvest, Not yet]` |
VMAD-wire all 5 props on `PDV__ManagerQuest`.

### Altmer (5 records)
| Record | Type | Magnitude / AV |
|---|---|---|
| `PDV_SPEL_AltmerDiscipline_Alteration` (+MGEF) | SPEL+MGEF ability | Alteration spell cost -5% |
| `PDV_SPEL_AltmerDiscipline_Destruction` (+MGEF) | SPEL+MGEF ability | Destruction spell cost -5% |
| `PDV_SPEL_AltmerDiscipline_Illusion` (+MGEF) | SPEL+MGEF ability | Illusion spell cost -5% |
| `PDV_SPEL_AltmerDiscipline_Restoration` (+MGEF) | SPEL+MGEF ability | Restoration spell cost -5% |
| `PDV_MESG_AltmerDisciplines` | MESG | buttons `[Alteration, Destruction, Illusion, Restoration, Not yet]` |
VMAD-wire all 5 props on `PDV__ManagerQuest`.

**Button-order rule (load-bearing):** button index MUST equal the `Get<Race>...Spell(index)`
order above (startup-choice index==value lesson) -- a mismatch silently grants the wrong
discipline. The Papyrus maps 0-3 to the spells in exactly the table order; the MESG buttons
must match.

---

## Per-rite acceptance refuters (mirror PDV_DaedricSurfacing_AdversarialAcceptance)
Accept iff all PASS + gates GREEN:
- **R1 boon fires** -- `Apply<Race>...` adds the selected ability; `Get<Race>...Spell` maps 0-3.
- **R2 one-active** -- only one ability held; `...Active` single-valued 0/1-4.
- **R3 clear-before-add** -- `Apply` calls `Remove<Race>...Spells` before AddSpell.
- **R4 cooldown + "Not yet" free** -- 7-day reject; pressed>3 returns without writing LastRiteTime.
- **R5 coherence fade/restore** -- `Sync` removes on incoherence, re-adds on recovery; Active stays set while quiet. Predicate: Orc=life-mode unchanged; Redguard=sect unchanged; Altmer=no-crisis + not-cursed.
- **R6 records exist + wired** -- `--check` slot dump; VMAD props resolve non-None.
- **R7 no regression** -- compile 0/0, verify FAIL=0, e2e 0 RED, no spurious `PDV.Driver.*` on the grant.

Machine gates: `pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> `pdv_signal_e2e_gate` 0 RED ->
`pdv_specced_minus_audit` 0 -> `pdv_ledger_coverage_audit` CLEAN -> `pdv_antifarm_sweep_audit`
no UNCAPPED-GAIN -> `pdv_integrity_harness` PASS -> `<race>-variety-author --check` clean.
Manual in-game (one-active swap, dawn fade/restore; `coc` skips OnStoryChangeLocation -- not
relevant here, these are sleep-triggered) = owner-held.
