# PDV Phase 21 — Authoria / ARR Conflict Dossier

Status: local package evidence (two-sided shrine readback pass; runtime pending).
Date: 2026-06-14.
Target: **ARR — Authoria - Requiem Reforged** (P0; 1.0 gate = accepted Authoria
integration/test package). Companion to `phase20-targets.csv` (ARR row) and
`PDV_Phase20_CompatibilityNotes.md`. This is technical evidence, not a public
support claim or maintainer endorsement.

## Method & authority basis

- houseCARL pointed at the ARR MO2 instance (`D:\Wabbajack\modlists\ARR`,
  profile *Authoria - Requiem Reforged - Main Profile*).
- Per `requiem-patching/references/scope-and-authority.md`, winners must resolve
  to Requiem **inputs**, not the Reqtificated overlay (PDV's patch is itself
  re-run through the Reqtificator). The list shipped with the overlay **active**,
  so it was temporarily disabled for the scan (see §8) — 5 output plugins:
  `Requiem for the Indifferent.esp` + `Authoria - Output - {NPC Appearances,
  High Poly Head Patcher, Synthesis Gameplay, Synthesis Worldspace}.esp`.
- **Freshness probe PASSED:** Iron Sword `012EB7:Skyrim.esm` → winner
  `Requiem.esp`, override_depth 3 (`Skyrim.esm → USSEP → Requiem.esp`). Reads
  below reflect Requiem inputs.
- PDV is **not installed** in ARR, so this is a one-sided study of ARR winners
  against PDV's in-repo record contracts. No two-sided diff yet.

## 1. Readiness verdict

**Yes — we are at the point.** Phase 20 content lock is closed; ARR is the
designated P0 lane; houseCARL's Requiem tooling reads the ARR stack cleanly.
This pass produces the missing **ARR-specific** conflict map (the 2026-06-08
investigation only deep-scanned race-compat/survival/Wintersun-for-DoD). Actual
patch authoring remains gated on (a) an author current-list refresh and (b) PDV
installed into the ARR instance for two-sided diffs.

## 2. Archon removal set (replacement-first)

`Archon - Faiths of Tamriel` is a **full deity-worship overhaul occupying PDV's
exact niche** — `Archon.esp` touches **922 records**: per-deity
Altar/Acolyte/Champion tiered MGEFs for all Divines (+ Magnus) AND all 16 Daedric
Princes (+ Sithis), priest-vendor factions (`APO_PriestServices*`), amulet
effects, benevolent/malevolent shrine keywords, a dispel-blessings utility. PDV
is its functional successor, so removal is conceptually clean.

**Active plugins to remove (15):**

| Line | Plugin | Role |
|---|---|---|
| 1425 | `Archon.esp` | core (922 records) |
| 1426 | `Archon - Vigilant.esp` | quest-mod bridge |
| 1427 | `Archon - BDS.esp` | (Beyond Skyrim/Bruma-style) bridge |
| 1428 | `Archon - Mandra Shrines.esp` | Daedric shrine content bridge |
| 1429 | `Archon - Wyrmstooth.esp` | quest-mod bridge |
| 1430 | `Archon - HOHQE.esp` | House of Horrors QE bridge |
| 1431 | `Archon - TG Alt Endings.esp` | Thieves Guild bridge |
| 1432 | `Archon - TOCQE.esp` | The Only Cure QE bridge |
| 1433 | `Archon - TWDQE.esp` | The Whispering Door QE bridge |
| 1951 | `Archon - Markarth Entrance and Farm Overhaul.esp` | worldspace bridge |
| 2360 | `Archon - Lux Via.esp` | Lux Via lighting bridge |
| 2658 | `Lux - Archon.esp` | Lux lighting bridge |
| 2659 | `Lux - Archon - Mandra Shrines.esp` | Lux lighting bridge |
| 3221 | `Authoria - Master Patch - Archon.esp` | list consolidation (wins some Archon records, e.g. `0FB98E` AltarJulianosEffect @ depth 5) |
| 3276 | `Authoria - Papyrus - Missing Properties - Archon Fix.esp` | Archon script-property fix |

Notes:
- The `*QE` / Vigilant / Wyrmstooth / BDS / Markarth bridges only *integrate*
  base quest/worldspace mods with Archon; the base mods (HouseOfHorrorsQuestExpansion,
  TheOnlyCureQuestExpansion, etc.) **stay** — removing the bridge reverts them to
  non-Archon behavior. PDV must re-provide theology hooks for the high-signal ones
  (House of Horrors→Molag Bal, The Only Cure→Peryite, Cursed Tribe→Malacath,
  Whispering Door→Mephala).
- `Archon - Mandra Shrines.esp` integrates a **Daedric shrine content mod**
  ("Mandra Shrines") — candidate hook surface for PDV's Daedric system (§5).
  Confirm with author whether Mandra Shrines stays as standalone content.
- Removal needs an author-refresh confirmation pass (record-count drift since the
  list was last reviewed).

## 3. Shrine blessings — REPLACE target (decided: PDV owns shrines)

The 14 core shrine-blessing SPELs are currently a 3-layer chain
`vanilla → Requiem.esp → Archon.esp (winner)`. Archon fully replaces them
(`APO_Altar*`, 3 effects each via Archon MGEFs). **Requiem.esp also overrides all
14** in the middle layer with its Requiem-balanced versions (cure-disease +
Requiem effects).

**Consequence:** with Archon removed, the winner reverts to **`Requiem.esp`'s**
versions — same FormIDs PDV's neutralization manifest already targets. So PDV's
existing cure-only override mechanism
(`PDV_ShrineBlessingNeutralization.manifest.json`,
`tools/pdv-shrine-blessing-author`) works **unchanged** — it must simply (a) load
after `Requiem.esp` and (b) have Archon gone. No FormID re-pointing needed.

14 target SPELs (all overridden by Requiem in ARR; FormIDs unchanged):
`0FB988/0FB994/0FB995/0FB996/0FB997/0FB998/0FB999/0FB99A/0FB99B/10E8AE:Skyrim.esm`,
`011360:Dawnguard.esm`, `03BCFB/03BCFC/03BCFD:Dragonborn.esm`.

Activator policy holds: do **not** replace global vanilla shrine activator
scripts (`TempleBlessingScript`); strip the SPEL effects only. Watch the Lux Via
shrine activators (`000E43`,`0EA98C:Lux Via.esp`) already in PDV's manifest.

## 4. Reward retune — RETUNE target (decided: retune to Requiem)

PDV's T1/T2/T3 rewards (`PDV_Phase20_RewardRecordContracts.json`) are vanilla-
scaled ActorValue rate-mults (MagickaRateMult/HealRateMult/StaminaRateMult 4–15%,
ResistDisease/ResistMagic/DamageResist). Requiem's economy is materially
different (e.g. no in-combat health regen; resistances on a different curve), so
vanilla-scaled rate-mults will read wrong.

**Approach (via `requiem-magic-patching` live-analogy):** re-derive each packet's
magnitude from Requiem's comparable **constant-effect ability spells** in
`Requiem - Magic Redone.esp` / `Requiem.esp` (Standing-Stone / racial / blessing-
tier abilities). Carry inputs; let the Reqtificator process the patch.
**Step 1 (Requiem analog ceiling table) — DONE 2026-06-14** (houseCARL read pass
on ARR inputs; standing-stone winners resolve to `Requiem - Birthsigns Redone.esp`,
racial winners to `Requiem - Races Redone.esp` — both active in ARR, so analogs
are list-accurate). **Verdict: PDV's pre-calibration holds — T1 values are safe
and conservative across all 6 ActorValues; none approach a Requiem cap or analog.**

| ActorValue | PDV T1 | Requiem analogs (winner) | Requiem cap | Verdict | Ceiling T1/T2/T3 |
|---|---|---|---|---|---|
| MagickaRateMult | +4% | Altmer racial +50%, Imperial +10% | none (combat regen at FULL rate, `fCombatMagickaRegenRateMult`=1 vs vanilla 0.33) | safe | 5 / 10 / 20 % |
| StaminaRateMult | +4–5% | Lady Stone +25%, Lurker's Vigor +10% | none (combat regen FULL, `fCombatStaminaRegenRateMult`=1 vs 0.35) | safe | 5 / 10 / 20 % |
| HealRateMult | +4–5% | Lady Stone +25%, Argonian racial +50% | none (no combat heal-regen mult — near-worthless mid-fight) | safe (weak) | 5 / 15 / 30 % |
| ResistMagic | +3–5% | Breton racial +20%, Lord Stone +10% | `fPlayerMaxResistance`=90% (Requiem raised from 85) | safe | 5 / 10 / 20 % |
| DamageResist | +4 AR | Lord Stone +150 AR, Orc racial +100 AR | `fMaxArmorRating`=80% DR | **negligible** (≈0.3% DR — arguably too low to feel) | 10 / 25 / 50 AR |
| ResistDisease | +15% (night) | Argonian +75%, Altmer/Bosmer/Redguard +50% | 90% (shared resist cap) | safe (Argonian stacking nears cap, but cap clamps) | 15 / 30 / 50 % |

**Two Requiem-specific takeaways for the retune, not safety failures:**
1. **Regen mults bite harder in Requiem than vanilla** — Requiem restores Magicka/
   Stamina regen to full rate *in combat* (vanilla cuts to ~⅓). So %-regen rewards
   are more valuable than vanilla intuition suggests; keep the cumulative T2/T3
   ladder under the ceilings above. HealRateMult is the inverse (no combat heal-
   regen mult → mostly a between-fights bonus).
2. **DamageResist +4 is effectively nothing** in Requiem's AR curve (Orc's
   `Malacath's Regard` reward). If it should be *felt*, bump toward the ceiling
   (≤50 AR at T3); if it's intentional flavor for the easier-default audience,
   leave it — a power-fantasy-vs-Requiem design choice, not a balance bug.

**Step 2 (T1/T2/T3 ladder review) — DONE 2026-06-14.** Full ladder extracted and
audited across all 10 race specs. Outcome: (a) **DamageResist rescaled to an armor
ladder 15/30/50** on every tiered reward (it was the systemic "armor points capped
like %" weakness — see [[damageresist-armor-points-ceiling-exemption]]); (b)
regen/resist **%-mult crossings clamped to Requiem ceilings** (Magicka/Stamina/
ResistMagic T2 10/T3 20; Heal T2 15/T3 30); (c) Orc broad **T1=15 pushed live** to
the framework ESP (`--check` PASS). Validator confirms 0 violations; timed
near-death procs (e.g. Argonian Void-Held Surge) intentionally exempt. Remaining:
T2/T3 + focused-family values land per-race only when each author helper runs;
sync the flat-12 note in `PDV_RaceRewardBudgetLedger.md`. Caveats from the gather:
DamageResist DR% depends on Requiem's non-standard armor formula (`fArmorBaseFactor`=0)
— confirm in-game; Savior's Hide resist values are script-dynamic.

## 5. Daedric shrine hooks — HOOK target (decided: hook existing shrines)

Archon's footprint proves the list models **all 16 Princes (+ Sithis)** with
Altar surfaces, so in-world Daedric shrine activators exist to hook. Three of the
princes (Azura/Boethiah/Mephala) are already in the §3 shrine-SPEL set
(Solstheim/Dawnguard altars). Daedric shrine content present in ARR includes the
`man_*.esp` series (`man_sithis.esp`, `man_JyggalagShrine.esp`,
`man_kynarethStatue.esp`, `man_maraStatue.esp`) and the **Mandra Shrines** mod
(currently Archon-integrated).

**Deferred to the patch-authoring pass:** a per-Prince → shrine-ACTI override map
(read each Daedric shrine activator's live winner — vanilla / Requiem / `man_*` /
Mandra — and target it for PDV's boon/curse path), flagging Princes with no
in-world shrine in ARR (PDV's portable/signal surface stays the fallback there).
Cross-reference `PDV_DaedricPrinceRecordContracts.json`.

## 6. System-family context (classify only)

- **Survival (context-only):** primary = `SunHelmSurvival.esp` (GREEN — readable
  globals per 2026-06-08: `_SHCurrentHungerLevel` etc.) with many SunHelm
  patches; plus `Frostfall.esp` + `Campfire.esm` (AMBER — effect/keyword reads).
  PDV reads these for eligibility/caps, never raw piety gain/loss.
- **Curse theology = Requiem-native.** No Growl/Sacrosanct/Moonlight Tales stack;
  vampirism/lycanthropy run through `Requiem_VampireCollection.esp` (+
  `VampireFeedingTweaks.esp`, `SunAffectsNPCVampires.esp`). Artifact curses:
  `EbonyBladeCurse.esp` (+ Requiem patch; Mephala) and
  `The Cursed Tribe - Quest Expansion.esp` (Malacath). PDV's curated
  Hircine/Molag Bal/Azura transitions must key off **Requiem's** vamp/werewolf
  records/keywords here, not Growl/Sacrosanct.

## 7. Recommended compatibility-patch shape (ESL-first; one ARR patch)

1. **Removal set** (§2): the 16 Archon plugins, applied as a list-author removal
   step (not an ESP edit).
2. **Shrine replace** (§3): PDV's cure-only override of the 14 Requiem shrine
   SPELs, loaded after `Requiem.esp`. Mechanism already exists.
3. **Reward retune** (§4): Requiem-scaled magnitudes for the T1/T2/T3 packets.
4. **Daedric hooks** (§5): per-Prince shrine-ACTI overrides routing to PDV.
5. Masters minimal (base game + PDV + only touched ARR plugins); ESL-flag;
   reference-only RFTI output optional — author regenerates final RFTI.
6. End with: run the patch through the Reqtificator.

## 8. Open questions for the author current-list refresh

- Confirm the exact Archon removal set against the author's live list (record
  drift; whether `Mandra Shrines` base content stays standalone for §5 hooks).
- Which of the `Archon - *QE` bridge reversions need a PDV theology hook vs.
  classify-only.
- Per-AV Requiem analog magnitudes for §4 (needs a Magic Redone enumeration pass).
- Per-Prince Daedric shrine-ACTI winners for §5 (needs an ACTI enumeration pass).
- Install PDV into ARR to enable two-sided conflict diffs before packaging.

## 9. Profile-state note (cleanup performed)

The scan temporarily disabled 5 overlay/output plugins in
`profiles/Authoria - Requiem Reforged - Main Profile/plugins.txt` (backup:
`plugins.txt.pdvbak`). These are **restored** at session end; the profile's play
state is unchanged. The list's `ModOrganizer.ini` `[General]` keys used
`key = value` spacing that houseCARL's parser rejects; canonicalized by opening
MO2 once.

## 10. Local package readback update (2026-06-14)

Follow-up local package work installed PDV into ARR as a local test mod:

- MO2 root: `D:\Wabbajack\modlists\ARR`
- Profile: `Authoria - Requiem Reforged - Main Profile`
- Local test mod: `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test`
- Junction target: `D:\Wabbajack\modlists\Anvil\mods\Devotion`
- Profile backup directory:
  `D:\Wabbajack\modlists\ARR\profiles\Authoria - Requiem Reforged - Main Profile\pdv-authoria-backups`
- Backup stamp: `20260614-224145`

The live profile table resolves the Archon removal set to 15 plugin lines, not
16. All 15 are inactive in the local test profile. `PlayerDevotion_Framework.esp`
is active before `Requiem for the Indifferent.esp`.

Two-sided houseCARL shrine readback passes for the current package slice:

- All 14 shrine blessing `SPEL` targets resolve to
  `PlayerDevotion_Framework.esp` after Archon is disabled.
- `Requiem.esp` remains the middle-layer input for the core shrine spells.
- The three Dragonborn Good Daedra altar spells resolve to one remaining PDV
  cure effect, `071554:PlayerDevotion_Framework.esp`
  (`PDV_MGEF_DunmerShrineCure`), carrying `PDV_DunmerShrinePrayerEffect`.
- No global shrine activator script replacement is introduced.

No standalone `PDV_AuthoriaARR_Compatibility.esp` is emitted for this proven
slice, because the required record winners already come from
`PlayerDevotion_Framework.esp`. The plugin name remains reserved for future
approved ARR-specific route adapters.

Reward consistency follow-up also passes: the Phase 20 reward contract and all
ten `*RewardRecords.spec.json` files match the Requiem retune expectations for
T1 values, DamageResist `15/30/50`, regen/resist ceilings, and Orc T1 = 15.
Timed near-death procs remain intentionally outside the broad retune.

Daedric shrine route adapters remain deferred. houseCARL ACTI scans of
`man_DaedricShrines.esp`, `man_MehrunesDagonShrine.esp`,
`man_JyggalagShrine.esp`, and `man_sithis.esp` only produced stable Nocturnal
shrine ACTI records by shrine EditorID; they do not provide a safe all-Prince
ACTI map.

Papyrus optimization review found no broken script contract in the reviewed
sources, but it flagged pre-existing suboptimal hot-path patterns in
`PDV__ManagerQuest.psc`, `PDV_PlayerEvents.psc`, and `PDV_DaedricPathBase.psc`.
Treat those as release-hardening follow-ups before any ready/public support
claim; they do not invalidate this local ARR shrine readback package.
