# PDV Race Content Manifest (1.0)

**Status:** Authoring manifest. Inventory across all 10 races, all with full draft prose. The former Altmer and Breton gated slots (Sections 13.13, 18.14) are now authored for the Phase 20 content lock; everything else is content-author-ready for Phase 19.
**Created:** 2026-05-20
**Owner doc family:** `PDV_TargetEndStates_1.0.md` (launch feel, per-race acceptance), `race-sheets/PDV_RaceDesign_*.md` (locked design specs and contextual-favor tables), `race-sheets/Race_*.md` (player-facing companion guides), `PDV_Architecture_v3.md` (subsystem contracts, especially Sections 10, 12, 16, 17), `PDV_STANDARDS.md` Section 3 (description-engineering rules).
**Purpose:** Enumerate every player-facing string slot the 1.0 content-authoring phase has to fill, anchor each to its locked source, and prove the row template by drafting all Nord prose.

This manifest is the inventory; it is not the eventual content-authoring source of truth inside the ESP. Phase 19 (`PDV_Architecture_v3.md` Section 17) is the build pipeline.

---

## 1. Locked decisions

These were ratified in the planning pass for this manifest.

1. **Voice is mixed by Surface.** See the matrix in Section 3.
2. **Single source of truth.** All draft prose for the 1.0 content lift lives in this file until promoted into shipped ESP records or `Race_*.md` handbooks. Race sheets are not edited in this pass.
3. **Champion shape decided per race.** Each Champion row carries one of `Entry-only`, `Entry + ambient`, or `Texture-only` in its notes. The Nord pilot deliberately uses different shapes across its four Champions to prove the row template carries the distinction.
4. **Slot IDs are the eventual CK record names.** Naming follows `PDV_Architecture_v3.md` Section 17 conventions and stays EditorID-safe (ASCII letters, digits, underscore; no length over 32 characters where the CK editor truncates):
   - `PDV_Msg_<Race>_<Deity>_<Slot>` for `Message` (MESG) records.
   - `PDV_Notif_<Race>_<Deity>_<Slot>` for HUD notifications routed through `Debug.Notification`.
   - `PDV_Dlog_<Race>_<NPC|Archetype>_<Slot>` for planned V2 dialogue topics (placeholder NPC archetype until Section 16.3 dialogue casting fixes the actual NPC alias). These rows are recognition intent only for V1; do not promote them into new NPC conversation lines for V1.
   - `PDV_Bless_<Race>_<Deity>_T<1|2|3>` for blessing descriptions (the string lives on the existing tier SPEL).
   - `PDV_PrismaToast_<Race>_<Deity>_<Slot>` for Prisma overlay toasts (Section 16.5).

## 2. ASCII rules

Per `PDV_Architecture_v3.md` Section 2 invariant 6 and `PDV_STANDARDS.md` Section 3.2 rule 6:

- Allowed substitutes: straight quotes `"` and `'`, ASCII ellipsis `...`, double-dash `--`, single hyphen `-`, asterisk `*`.
- Disallowed: curly quotes, em dashes, en dashes, the unicode ellipsis character, bullets, emoji, any multibyte punctuation.
- Verification: `LC_ALL=C grep -nP '[^\x00-\x7F]' race-sheets/PDV_RaceContent_Manifest.md` returns no matches.

## 3. Voice-by-Surface matrix

| Surface | Primary voice | Secondary voice (when used) | Rationale |
|---|---|---|---|
| Blessing description (`PDV_Bless_*`) | Third-person narrator | -- | Matches `PDV_STANDARDS.md` Section 3.3 conformance example. |
| Tier-up notification (`PDV_Notif_*_Tier*Entry`) | Third-person narrator | -- | Status change announced by the narrator, not the god. |
| Neglect texture line (`PDV_Notif_*_NeglectTexture`) | Player second-person | -- | The player is the one experiencing absence; second-person carries the loss. |
| Commitment offer body (`PDV_Msg_*_Offer`) | God-voice | -- | The god is the speaker. Only Marked surface that gets god-voice as default. |
| Commitment response (`PDV_Msg_*_OfferResponse_*`) | Player second-person | -- | The player's reply. Reads naturally from the player's seat. |
| Champion Entry MessageBox (`PDV_Msg_*_ChampionEntry`) | God-voice | Narrator (Texture-only races) | Champion entry is the god's recognition. Texture-only races skip the message. |
| Champion ambient (`PDV_Notif_*_ChampionAmbient_*`) | Player second-person | -- | Fires in fitting context after entry; reads as the player noticing. |
| Survey Devotion readout (`PDV_Msg_*_Survey_*`) | Third-person narrator | -- | A scannable status block, not a vision. |
| Shrine / privilege dialogue topic (`PDV_Dlog_*`) | Player second-person | NPC voice (within branch, not in topic name) | Planned V2 only. Topic name reads from the player's seat; branch dialogue would be authored separately in CK after V2 scope opens. |
| Contextual favor surfacing (`PDV_Notif_*_FavorNoted_*`, `PDV_Msg_*_FavorMarked_*`) | Player second-person (Noted), god-voice (Marked) | -- | Smaller favors feel like a felt response; large favors are the god speaking. |
| Curse-state transition (`PDV_Msg_*_CurseState_*`) | God-voice | -- | A theological rupture: the god is naming what has changed. |
| Prisma overlay toast (`PDV_PrismaToast_*`) | Symbol-led, minimal text | -- | Section 16.5: symbol-led, quiet enough for normal play. |

Rows that deviate from the matrix must justify the deviation in the notes column.

## 4. Length budgets per Surface

| Surface | Hard cap | Target | Source |
|---|---|---|---|
| HUD `Notification` | 80 chars | 60 chars | Skyrim notification corner truncation convention. |
| `MessageBox` title | 40 chars | 30 chars | CK MESG title field convention. |
| `MessageBox` body | 500 chars | 280 chars | Two scannable sentences fits ~280; 500 is the practical CK limit before line breaks become awkward. |
| Blessing description (SPEL) | 200 chars | 140 chars | `PDV_STANDARDS.md` Section 3.2 rule 4 (`~200 chars for tooltips`). The Standards Section 3.3 conformance example is 105 chars. |
| Survey Devotion readout body | 240 chars | 180 chars | Status spell block (patron + tier + direction + one flavor line). |
| Dialogue topic line | 120 chars | 80 chars | `PDV_STANDARDS.md` Section 3.2 rule 7 (`under 80 characters where possible`). |
| Prisma overlay toast text | 60 chars | 40 chars | Symbol-led: text is supportive, not primary. |

## 5. Firing-density targets

Per `PDV_Architecture_v3.md` Section 16.2 ("normal play should understand major changes without being narrated through every event fire") and Section 10.7 family caps:

- `Marked`: less than 1 per 2 hours of steady play. Hard cap 1 per hour.
- `Noted`: less than 2 per hour. Hard cap 4 per hour.
- `Quiet`: no count target; icon-only.

Per-row `Anti-farm / dep notes` column records expected firings per in-game day and any per-row cooldown that keeps the row inside its cap.

## 6. Special firing rules

- **Tier-up versus commitment-offer collision.** When a commitment offer fires on the same dawn as a Faithful (Tier 2) tier-up notification, the tier-up is suppressed and only the offer MessageBox fires. The offer carries the tier change implicitly. Rows that gate by this rule carry the flag `suppress-if-offer-same-dawn` in their notes column.
- **Champion shape per row.** Champion rows record one of `Entry-only`, `Entry + ambient`, or `Texture-only` so the manifest does not over-author texture passages from the end-state doc that are already gameplay mechanics, not strings.
- **Cure cycle gating.** Curse-state strings (`PDV_Msg_*_CurseState_*`) fire at most once per cure cycle: once on entering the cursed state, once on the cure rite, no spam.

## 7. Localization-readiness rules

Per `PDV_Architecture_v3.md` Section 23 (post-1.0 localization deferred, externalization assumed minor):

1. No string interpolation. Do not write `"Kyne knows " + playerName`. Use generic forms.
2. No string concatenation across slots. Each slot is one string.
3. No embedded numerals in prose where the tier vocabulary will do. `"Faithful"` is fine because that is the localized tier word; `"50 piety"` is not.
4. Each row is self-contained. If a longer readout swaps clauses by condition, that is multiple rows with a shared parent slot id, not one row with embedded conditionals.

The complete externalized vocabulary -- every `%s` token and its closed value
set -- is enumerated in Section 24 (Token tables).

## 8. Shared row template

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|

- **Slot ID** -- the canonical CK record name per Section 1.
- **Surface** -- one of `Notification`, `MessageBox`, `Dialogue topic`, `Blessing description`, `Status spell readout`, `Book`, `Prisma toast`.
- **Surfacing** -- `Quiet` / `Noted` / `Marked` per `PDV_Architecture_v3.md` Section 10.6.
- **Voice** -- `Narrator` / `Player-2nd` / `God-voice` per Section 3 matrix.
- **Budget** -- character target/hard from Section 4.
- **Source** -- file plus section/line range the slot is locked in.
- **Anti-farm / dep notes** -- expected firings per day, cooldowns, suppression flags, gating state.
- **Draft prose** -- the ASCII English string. Empty for non-pilot races.

## 9. Per-race priority order

Manifest sections follow the build order from `PDV_TargetEndStates_1.0.md` "Priority order for building" (lines 525-534):

1. Nord (full draft prose)
2. Orc (full draft prose)
3. Dunmer (full draft prose)
4. Altmer (full draft; the former gated slots are authored in Section 13.13 for the Phase 20 content lock)
5. Khajiit (full draft prose; no formal commitment offer per Section 12.4a)
6. Imperial (full draft prose)
7. Redguard (full draft prose)
8. Bosmer (full draft prose; four-path divergence)
9. Breton (full draft prose; three-tradition divergence; Vigilant pressure authored)
10. Argonian (full draft prose)

---

## 10. Nord (full pilot)

### 10.1 Per-deity tone profiles

Mandatory before any Nord row drafting. One sentence per deity. Drafts that drift from the descriptor are rejected at review.

| Deity | Tone profile |
|---|---|
| Shor | Martial, blunt, Sovngarde-coded; speaks of seats earned and feasts kept; never sentimental. |
| Kyne | Cold, clear, weather-imagery; spare lines; the storm in the sentence; addresses the hunter, not the citizen. |
| Talos / Ysmir | Defiant, terse, archaic; cadence short; mead-hall plainness with a king's weight; never apologetic. |
| Tsun | Shield-thane formality; measured, witness-toned; speaks of trial and crossing. |
| Stuhn | Even-handed, mercy-without-softness; speaks of ransom kept, prisoners freed, fair fights. |
| Mara (Hearth) | Warm, household, intimate; speaks of doors, fires, returns; the kindest of the Nord voices. |
| Akatosh | Slow, even, time-measured; speaks of streak and continuance; austere rather than warm. |
| Kynareth (Nine Divines) | Same weather imagery as Kyne but framed by temple grace; slightly steadier and less wild. |
| Arkay | Quiet, ceremonial, death-respecting; speaks of rest, the cycle, what the dead are owed. |
| Stendarr | Restraint, mercy under pressure; speaks of staying the hand, of the surrendering enemy. |
| Zenithar | Plainspoken, honest-trade voice; speaks of the day's work, fair weight, quality. |
| Julianos | Studied, careful, library-toned; speaks of pages read, schools learned, patience. |
| Dibella | Warm, refined, performance-knowing; speaks of beauty made, the right word at the right moment. |

### 10.2 Blessing descriptions (`PDV_Bless_Nord_*`)

Narrator voice. Theological lead + concrete numeric effect, per `PDV_STANDARDS.md` Section 3.3 conformance example. Budget 200 hard / 140 target. Anti-farm: passive (carried by the tier SPEL); no firing cost.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Nord_Kyne_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Kyne has noticed your steps. The warrior-mother toughens her own, and the cold bites you 10% less. |
| PDV_Bless_Nord_Kyne_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Kyne shelters the hunter who sleeps beneath her sky. Your endurance has grown so your maximum stamina rises by 35, and wild animals stay calm until provoked. |
| PDV_Bless_Nord_Kyne_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Kyne Champion" | Passive SPEL | The storm-mother answers her favored's call. In wind and rain your shouts and arrows fly further, and in the open your power attacks cost 10% less stamina. |
| PDV_Bless_Nord_Talos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Talos has seen your arm raised in defiance. Your melee attacks strike 5% harder. |
| PDV_Bless_Nord_Talos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The old breath gathers behind your Thu'um. Your shouts recharge 10% faster, and defying the Talos ban is counted as worship. |
| PDV_Bless_Nord_Talos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Talos/Ysmir Champion" | Passive SPEL | Talos marks the open defier. Your maximum health rises by 50. Stormcloak ground and Thalmor defiance return a cumulative surge to base health and stamina, capped at +50 each. |
| PDV_Bless_Nord_Shor_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Shor's Hall hears the ring of your sword. Your stamina regenerates 5% faster. |
| PDV_Bless_Nord_Shor_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Honor in battle earns Shor's small mercy. A fair kill restores 10 health. Companions work weighs double. |
| PDV_Bless_Nord_Shor_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Shor Champion" | Passive SPEL | Shor has kept your seat in the Hall. Honorable kills restore health by the foe's strength; at 20% health in fair combat, stamina holds steady. |
| PDV_Bless_Nord_Tsun_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Tsun bears some of your weight. Your power attacks cost 5% less stamina. |
| PDV_Bless_Nord_Tsun_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL. Logic: set bSevereFight when 3+ hostiles target the player or a single hostile is significantly overleveled; track lowest player health % via OnHit; on OnCombatStateChanged to 0 while alive, if bSevereFight AND player dropped below ~25% HP during the fight, apply a short stamina burst, then clear flags. | The shield-thane sees the fight you should have lost. Surviving against severe odds returns a short stamina burst. |
| PDV_Bless_Nord_Tsun_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Tsun's weighing holds. After a trial against three or more foes, stamina holds at 20% for one day. Trial-and-challenge work counts double. |
| PDV_Bless_Nord_Stuhn_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Stuhn turns his eye to those who defend the blow. Foes who strike first -- against you or an ally -- take 5 more damage. |
| PDV_Bless_Nord_Stuhn_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Stuhn answers the shield raised for another. Freeing a prisoner, honoring a ransom, or pulling enemies from an ally raises your armor rating by 15 for the next fight. |
| PDV_Bless_Nord_Stuhn_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Stuhn honors the merciful sword. As long as you honorably kill enemies and spare the innocent, your armor is raised by 50 and enemies take 15 more damage. |
| PDV_Bless_Nord_Mara_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Mara has counted your kindness. Healing magic is 5% more effective, and your followers recover health faster at your side. |
| PDV_Bless_Nord_Mara_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The hearth-mother nurtures your household. Your maximum health rises by 30, and marriage and home work earn extra devotion. |
| PDV_Bless_Nord_Mara_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Mara warms your door. Restoration spells are 15% more effective and your maximum health rises by 50. Helping a family restores you fully at once. |
| PDV_Bless_Nord_Akatosh_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Akatosh holds your hour a little longer. Your magicka regenerates 10% faster, and your shout cooldowns recover 5% sooner. |
| PDV_Bless_Nord_Akatosh_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Long devotion does not go unmeasured. Your maximum magicka rises by 30, and steady seven-day streaks return bonus piety at dawn. |
| PDV_Bless_Nord_Akatosh_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Akatosh keeps your continuance. Unbroken devotion of fourteen days returns a growing dawn blessing of magicka and stamina regeneration. The Amulet of Akatosh doubles its vanilla effect. |
| PDV_Bless_Nord_Kynareth_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL; Nine Divines lane | Kynareth shelters the traveler on the open road. Her sky tempers the weather, and your resistance to cold rises by 10%. |
| PDV_Bless_Nord_Kynareth_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL; Nine Divines lane | Kynareth steadies the open way. Outdoor rest fully restores stamina; hawks circle before ambushes as a warning. |
| PDV_Bless_Nord_Kynareth_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates lines 182-183 | Passive SPEL; Nine Divines lane | Kynareth's grace answers your steps. Her winds carry arrow and Voice alike, and a night slept beneath the sky restores more than any roof. |
| PDV_Bless_Nord_Arkay_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Arkay marks the keeper of rites. Your resistance to disease rises by 10%, and undead deal 5% less harm. |
| PDV_Bless_Nord_Arkay_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | A burial done well is owed. Completing a death-rite restores full health on next rest. |
| PDV_Bless_Nord_Arkay_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Arkay's covenant holds. Undead deal 20% less harm, and Hall of the Dead priests speak to you as a peer. |
| PDV_Bless_Nord_Stendarr_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Stendarr counts the spared hand. Your blocking absorbs 5% more damage, and Vigilants of Stendarr stay neutral by default. |
| PDV_Bless_Nord_Stendarr_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Mercy chosen is mercy kept. After sparing a foe in dialogue, the next fight grants 5% damage resistance. |
| PDV_Bless_Nord_Stendarr_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Stendarr's restraint becomes your armor. Sparing a surrendering foe grants 15% damage resistance for the rest of the fight. |
| PDV_Bless_Nord_Zenithar_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Zenithar weighs honest work. Your honest trades fetch slightly better prices. |
| PDV_Bless_Nord_Zenithar_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The honest hand makes a finer thing. Your Smithing rises by 10, and honest commerce returns small devotion. |
| PDV_Bless_Nord_Zenithar_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Zenithar names the master's work. A crafted item may rise one quality step beyond your perk rank. After an honest sale, your next persuasion has a boost. |
| PDV_Bless_Nord_Julianos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Julianos reads your study. Novice and Apprentice spells cost 3% less. |
| PDV_Bless_Nord_Julianos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Pages turned are devotion paid. Novice, Apprentice, and Adept spells cost 5% less. Skill books return piety; College work earns extra. |
| PDV_Bless_Nord_Julianos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Julianos sharpens your study. All spells cost 8% less. Reaching a new magic skill rank grants one free cast of that school. |
| PDV_Bless_Nord_Dibella_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Dibella notes the well-said word. Your Speech improves by 5%, and first impressions are warmer. |
| PDV_Bless_Nord_Dibella_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The right word at the right moment carries. Your Speech improves by 10%, and a strong persuasion steadies the next social check. |
| PDV_Bless_Nord_Dibella_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Dibella crowns the well-made hour. After a major persuasion or performance, the next equivalent check nearly succeeds on its own. Bards' College work earns strong devotion. |

### 10.3 Tier-up notifications (`PDV_Notif_Nord_*_Tier*Entry`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. Per `PDV_Architecture_v3.md` Section 16.2: tier change is a Medium event. All Faithful rows carry the `suppress-if-offer-same-dawn` flag.

Tier-up notifications use one shared template per tier (the deity name is the variable position) to avoid sixty bespoke rows. Anti-farm: one per deity per direction per save.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Nord_Observant_Entry | Notification | Noted | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per deity per save; deity inserted by caller | %s has begun to notice your deeds. |
| PDV_Notif_Nord_Faithful_Entry | Notification | Noted | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per deity per save; suppress-if-offer-same-dawn | Your standing with %s is steady now. |
| PDV_Notif_Nord_Devoted_Entry | Notification | Marked | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per save; the patron's name | %s claims you. |
| PDV_Notif_Nord_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per deity per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Nord_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per deity per direction per save | The favor of %s is thinning. |
| PDV_Notif_Nord_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per save per patron loss | The bond with %s loosens. The Devoted bond is not held. |

Note on the `%s` token: this is a single-token substitution slot bound to the deity name, not free-form interpolation. Localization-readiness rule 1 still holds (no string concatenation, no player name); the deity name table is the only externalized variable.

### 10.4 Champion moment recognition

`PDV_RaceDesign_Nord.md` "Tier 3 -- Devoted" gives every worshippable Nord deity a Champion Moment. Reaching Devoted is a marked, one-time event for any deity at the right level, so each of the thirteen carries a god-voice `ChampionEntry` MessageBox. Ambient notifications are layered on top only where the source calls for ongoing texture:

- **Entry + ambient**: Kyne and Kynareth -- the source explicitly calls out "the texture of being outside" as ongoing recognition.
- **Entry-only**: the remaining eleven -- the moment of being marked carries the recognition; ongoing privileges, where they exist, live in the Section 10.10 dialogue topics rather than as ambient lines.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_Kyne_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 179-180 | One-time on first Kyne Devoted | Body: "You sleep where the storm sleeps. You walk where the wind walks. Kyne has named her hunter." Title: "Kyne's Recognition" |
| PDV_Notif_Nord_Kyne_ChampionAmbient_Storm | Notification | Noted | Player-2nd | 80/60 | TargetEndStates lines 179-180 | Kyne Devoted + outdoor + storm weather; one per in-game day | The wind is blowing your way. |
| PDV_Notif_Nord_Kyne_ChampionAmbient_OutdoorRest | Notification | Quiet | Player-2nd | 80/60 | TargetEndStates lines 179-180 | Kyne Devoted + outdoor sleep complete; one per rest | You awake settled within. |
| PDV_Msg_Nord_Talos_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 180-181 | One-time on first Talos Devoted | Body: "You did not let me die. The old breath is yours to carry. Speak, and Tamriel hears Talos." Title: "Talos Names You" |
| PDV_Msg_Nord_Shor_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates line 181; RaceDesign_Nord Section "Tier 3" | One-time on first Shor Devoted | Body: "Your sword stayed honest to the last blow, and Shor has counted every fall. The seat I kept is yours now. When the bridge comes, you will not cross it as a stranger." Title: "Shor Keeps Your Seat" |
| PDV_Msg_Nord_Kynareth_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 182-183 | One-time on first Kynareth Devoted | Body: "You walked the long road in my sky. Kynareth's grace stays with you in wind and rain." Title: "Kynareth's Grace" |
| PDV_Notif_Nord_Kynareth_ChampionAmbient_Storm | Notification | Noted | Player-2nd | 80/60 | TargetEndStates lines 182-183 | Kynareth Devoted + outdoor + storm; one per in-game day | The road feels held. |
| PDV_Msg_Nord_Tsun_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Tsun Devoted | Body: "I have watched you stand where lesser men would have run, against odds that should have ended you. The weighing is done. You have the right to cross, and I will not bar your way." Title: "Tsun Has Weighed You" |
| PDV_Msg_Nord_Stuhn_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Stuhn Devoted | Body: "You have spared the beaten and freed the bound when cruelty would have been easier. The open hand is your banner now. Stuhn knows the merciful sword by name, and yours is known." Title: "Stuhn Names You" |
| PDV_Msg_Nord_Mara_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Mara Devoted | Body: "You have made hearths where there were none and held families that were breaking. The warmth you gave is given back. Come home to any door of mine, and find it open and warm." Title: "Mara Holds Your Door" |
| PDV_Msg_Nord_Akatosh_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Akatosh Devoted | Body: "Day upon day, unbroken, you have kept faith while empires forgot theirs. The line does not fray in your hands. The dragon-god marks your continuance, and time keeps what you keep." Title: "Akatosh Keeps the Hour" |
| PDV_Msg_Nord_Arkay_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Arkay Devoted | Body: "You have given the dead their rites when the living would not, and turned back what should not walk. The cycle holds because you hold it. Arkay names you keeper, and the Hall of the Dead knows your hand." Title: "Arkay's Covenant Sealed" |
| PDV_Msg_Nord_Stendarr_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Stendarr Devoted | Body: "You have stayed the killing blow again and again, where wrath was the easy road. Mercy chosen so many times becomes a wall no blade easily passes. Stendarr names you, and your restraint is your armor now." Title: "Stendarr's Mercy Made Armor" |
| PDV_Msg_Nord_Zenithar_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Zenithar Devoted | Body: "Every weight you kept true, every trade you made fair, has been counted. The honest hand makes holy work. Zenithar sets his mark on yours, and what you craft now carries more than its making." Title: "Zenithar Names the Honest Hand" |
| PDV_Msg_Nord_Julianos_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Julianos Devoted | Body: "You have studied with a patience few keep, until the arts answered as a friend answers. Wisdom is not stored in you; it is used. Julianos names you, and every school you touch is lighter for it." Title: "Julianos Reads You" |
| PDV_Msg_Nord_Dibella_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Tier 3" | One-time on first Dibella Devoted | Body: "You have made beauty where you walked and spoken the word that lands. What you gave to the world, the world gives back to you. Dibella names you, and the well-made hour answers when you call." Title: "Dibella's Recognition" |

### 10.5 Neglect texture (`PDV_Notif_Nord_*_NeglectTexture`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `PDV_Architecture_v3.md` Section 14: neglect is absence, not punishment. Each row fires on the first day of a meaningful lapse band crossing for that deity, not continuously.

**ASCII stress-test row:** `PDV_Notif_Nord_General_AncestorsQuiet` deliberately tests whether "the ancestors are quiet" reads under ASCII without leaning on em dashes or ellipses. If this row fails review, raise the cost back against `PDV_Architecture_v3.md` Section 2 invariant 6.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Nord_Kyne_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture", TargetEndStates lines 192-194 | One per lapse-band crossing per deity | The wind passes you by today. |
| PDV_Notif_Nord_Talos_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your Voice feels quieter. |
| PDV_Notif_Nord_Shor_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The hard fight is lacking. |
| PDV_Notif_Nord_Mara_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The hearth feels colder when you come home. |
| PDV_Notif_Nord_Tsun_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your trials go unweighed. |
| PDV_Notif_Nord_Stuhn_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The open hand goes unseen. |
| PDV_Notif_Nord_Akatosh_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your days run on, unmeasured. |
| PDV_Notif_Nord_Kynareth_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The road gives nothing back. |
| PDV_Notif_Nord_Arkay_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The cycle turns without you. |
| PDV_Notif_Nord_Stendarr_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your mercy feels like nothing now. |
| PDV_Notif_Nord_Zenithar_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The honest day earns only its wage. |
| PDV_Notif_Nord_Julianos_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your study goes unread. |
| PDV_Notif_Nord_Dibella_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The well-said word goes unnoticed. |
| PDV_Notif_Nord_General_AncestorsQuiet | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" line 184; TargetEndStates line 194 | One per lapse into the general broad-worship neglect band per save | The ancestors are quiet. |

### 10.6 Commitment offers (`PDV_Msg_Nord_*_Offer` and `PDV_Msg_Nord_OfferResponse_*`)

God-voice on the offer body. Player-second-person on the response options. MessageBox. Body budget 500 hard / 280 target. Title budget 40 hard / 30 target. Per `PDV_Architecture_v3.md` Section 12.3: presented at dawn. Per the Nord design-sheet `Acceptance / no-switching rule`: accepting clears pending Nord offers and sets shared patron state to active primary.

Per-deity offer bodies are authored. Response options (Accept / Not Yet / Refuse) are shared across all Nord commitment offers (and reused as templates for the other races' god-voice patrons in later passes).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_Kyne_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate"; TargetEndStates Section "Nord" | Dawn-fire; one Kyne offer per cooldown window | Title: "Kyne Reaches Back" Body: "You sleep where I am. You hunt where I watch. Will you carry my name now, or will you stay among the many?" |
| PDV_Msg_Nord_Shor_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Shor Calls You" Body: "Your sword has stayed honest to the last blow, and Tsun has counted every fall. I am keeping a seat at my table for you. Take the name of Shor now and walk to my hall as one who is awaited, or hold to the broad road and prove it further." |
| PDV_Msg_Nord_Talos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Talos Marks the Defier" Body: "You would not let them silence me. Carry the old breath openly now, and Tamriel will hear Talos through you. Or hold the secret close and walk the broad road yet, until you are ready to be marked." |
| PDV_Msg_Nord_Tsun_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Tsun Weighs You" Body: "I have watched you stand where lesser men would have run, against odds that should have ended you. The weighing is nearly done. Take the shield-thane's mark now and be known at the crossing, or come to Shor's bridge unweighed and let the trials decide." |
| PDV_Msg_Nord_Stuhn_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Stuhn Sees the Open Hand" Body: "You have spared the beaten and freed the bound when cruelty would have been the easier road. The open hand can be your banner. Carry the ransom-keeper's name now, or wait, and let me test the mercy in you further." |
| PDV_Msg_Nord_Mara_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Mara Opens the Door" Body: "You have made a hearth where there was none and held families that were breaking. The warmth you gave can be a door that is always open to you. Let me hold that hearth with you now, or stay welcome among the many a while longer." |
| PDV_Msg_Nord_Akatosh_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Akatosh Marks the Hour" Body: "Day upon day, unbroken, you have kept faith while others let theirs fray. The line does not slip in your hands. Take the dragon's keeping now and let time hold what you hold, or measure your hours further before you choose." |
| PDV_Msg_Nord_Kynareth_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Kynareth Calls the Traveler" Body: "The road has been good to you because I am good to the road. The open sky already steadies your step. Carry my name now, traveler, and let the wind go with you, or hold to the broad reverence a while longer." |
| PDV_Msg_Nord_Arkay_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Arkay's Covenant" Body: "You have given the dead their rites when the living would not, and turned back what should not walk. The cycle holds because you hold it. Walk now as keeper of the covenant, or come to the door again when you are ready." |
| PDV_Msg_Nord_Stendarr_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Stendarr Stays the Hand" Body: "You have stayed the killing blow again and again, where wrath was the easy road. Mercy chosen so often becomes a wall no blade passes lightly. Take my mercy as your armor now, or hold the question open and be tested further." |
| PDV_Msg_Nord_Zenithar_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Zenithar Names the Honest Hand" Body: "Every weight you kept true, every trade you made fair, has been counted. The honest hand makes holy work. Carry the trade-god's name now and let your craft mean more than its making, or stay among the broad a while." |
| PDV_Msg_Nord_Julianos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Julianos Reads You" Body: "You have studied with a patience few keep, until the arts answered as a friend answers. Wisdom in you is used, not stored. Carry the name of the schools now, or read further before you bind yourself to them." |
| PDV_Msg_Nord_Dibella_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Dibella's Recognition" Body: "You have made beauty where you walked and spoken the word that lands. What you give to the world, the world gives back. Carry my craft openly now, or stay among the loved a while longer." |
| PDV_Msg_Nord_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Reused across Nord offers and as template for other races | Accept the bond. |
| PDV_Msg_Nord_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3; RaceDesign_Nord Section "Offer-decline rule" | Not Yet sets per-deity cooldown only; no piety loss | Not yet. |
| PDV_Msg_Nord_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3; RaceDesign_Nord Section "Offer-decline rule" | Repeated decline doubles cooldown to fourteen days | Refuse the offer. |

### 10.7 Survey Devotion readouts (`PDV_Msg_Nord_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. Per `PDV_Architecture_v3.md` Section 16.2: thematic by default; numeric values only in MCM. Variant per lane. The two `%s` tokens are bound to deity-name and tier-name external tables; localization rule 1 still holds.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_Survey_BroadOldWays | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; TargetEndStates Section "Nord Broad worship lane" | Cast Survey Devotion; no firing cost | You honor the Old Ways broadly. The pantheon has noted you. Standing: %s. The road is steady. |
| PDV_Msg_Nord_Survey_BroadNineDivines | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; TargetEndStates Section "Nord Broad worship lane" | Cast Survey Devotion; no firing cost | You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath. Standing: %s. |
| PDV_Msg_Nord_Survey_Focused | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Nord Section "Acceptance / no-switching rule" | Cast Survey Devotion; %s1 deity name, %s2 tier | %s1 names you. Standing: %s2. The bond holds. |
| PDV_Msg_Nord_Survey_FocusedSlipping | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Nord Section "Neglect Texture" | Tier dropping in last seven days | %s1 still names you, but the bond is thinning. Standing: %s2. |

### 10.8 Contextual favor surfacings

Five trigger families in Broad Old Ways and five in Broad Nine Divines per `RaceDesign_Nord Section "Contextual Favor Pilot Table"`. The manifest only authors strings for `Noted` and `Marked` rows; `Quiet` rows are icon-only and need no prose.

Player-second-person voice on Noted. God-voice on Marked. Per `PDV_Architecture_v3.md` Section 10.6 and Section 10.7 family caps.

**ASCII stress-test row:** `PDV_Msg_Nord_FavorMarked_TalosDefiance` deliberately drafts the Marked Talos line under ASCII without em dashes or ellipses.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Nord_FavorNoted_OldWays_SkyRoad | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Old Ways" line 124 | Environmental favor bucket; one per outdoor sleep day | The cold sits lighter on you. Kyne and Shor are near. |
| PDV_Notif_Nord_FavorNoted_OldWays_HearthDefense | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Old Ways" line 126 | After-act bucket; one per defended hold/family event | The hearth remembers. |
| PDV_Notif_Nord_FavorNoted_OldWays_DeathRite | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Old Ways" line 127 | After-act; one per Hall-of-the-Dead or burial quest | The dead are owed and the dead are paid. |
| PDV_Notif_Nord_FavorNoted_OldWays_TalosDefiance | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Old Ways" line 128 | After-act; costly-faithful only | A small thing kept hidden. Talos answers. |
| PDV_Msg_Nord_FavorMarked_TalosDefiance | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Broad Old Ways" line 128; Architecture v3 Section 10.6 | High-cost defiance only: hiding a worshipper, protecting a shrine, defying Thalmor face-to-face; one per such event; per-event cooldown | Title: "Talos Notes the Risk" Body: "You stood between them and me. Carry the old breath a little longer." |
| PDV_Notif_Nord_FavorNoted_NineDivines_RoadGrace | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Nine Divines" line 134 | Environmental; one per outdoor sleep day | Kynareth's road is good to you today. |
| PDV_Notif_Nord_FavorNoted_NineDivines_HouseholdMercy | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Nine Divines" line 135 | After-act; one per qualifying event | Mara and Stendarr have noted what you spared. |
| PDV_Notif_Nord_FavorNoted_NineDivines_ProperDeath | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Nine Divines" line 136 | After-act; one per Hall-of-the-Dead or anti-necromancy beat | The order of the dead is kept. |
| PDV_Notif_Nord_FavorNoted_NineDivines_TalosPressure | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Broad Nine Divines" line 138 | After-act; costly-faithful only | The contradiction holds. Talos hears even here. |
| PDV_Msg_Nord_FavorMarked_NineTalosOpenDefiance | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Broad Nine Divines" line 138 | High-cost only; per-event cooldown | Title: "Talos Inside the Nine" Body: "You carried both my name and theirs, and would not put me down. Walk on." |

### 10.9 Curse-state transitions (`PDV_Msg_Nord_CurseState_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Per `PDV_Architecture_v3.md` Section 13 and `RaceDesign_Nord Section "Curse State Summary"`: fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary"; Race_Nord Section "Curse States" | Once on first transformation as Nord | Title: "Hircine's Pull" Body: "The beast is in the Companions' gift, but it stands against Shor's hall. Your seat on the bridge weakens while the hunt holds." |
| PDV_Msg_Nord_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary" | Once on werewolf cure completion | Title: "The Bridge Holds Again" Body: "The hunt is set down. Hircine's hold is broken, and your seat on the bridge holds firm once more. Shor's hall will name you when the day comes. Tsun marks that you ran with the beast, and does not forget." |
| PDV_Msg_Nord_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary"; Race_Nord Section "Curse States" | Once on becoming vampire | Title: "Sovngarde Closes" Body: "Molag Bal's shadow has fallen across you. Sovngarde will not name you while you carry his thirst. Cure the curse, and even then the scar remains." |
| PDV_Msg_Nord_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary" | Once on cure completion | Title: "The Door Stands Ajar" Body: "The thirst is gone. The bridge is open again. But Tsun has seen what walked into the dark, and that is not forgotten." |

### 10.10 Shrine and privilege dialogue topics (`PDV_Dlog_Nord_*`)

Player-second-person on topic name. Branch dialogue itself would be NPC voice,
authored separately in CK after V2 scope opens. Topic-line budget 120 hard / 80
target. Per `PDV_Architecture_v3.md` Section 16.3, new NPC conversation lines
are out of V1 scope; the Nord rows below are retained as recognition-intent
drafts and technical proof only.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Nord_KynePriest_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; TargetEndStates Section "Kyne Champion" | Kyne Devoted; one priest archetype | "I sleep where Kyne sleeps. I hunt where she hunts." |
| PDV_Dlog_Nord_TalosShrine_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; TargetEndStates lines 180-181 | Talos Devoted, hidden shrine context | "The old breath is mine to carry. Tell me what is needed." |
| PDV_Dlog_Nord_ArkayHall_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; TargetEndStates Section "Arkay Champion" | Arkay Devoted at any Hall of the Dead | "I keep the rites. What is owed the dead here?" |

### 10.11 Nord pilot firing-density sanity

Sum of expected per-day fires for a Faithful-Old-Ways Nord in steady outdoor play (storm season, Companions mid-arc, occasional Talos pressure beat):

- Marked: 0 most days; ~1 every 3-5 in-game days when a Talos costly-defiance beat lands. Inside the `<1 per 2h` target.
- Noted: ~2 per day (one outdoor-sleep favor, one after-act favor on quest beats), occasional 3 on death-rite days. Inside the `<2 per h` target if the day is more than one hour of play.
- Quiet: uncounted; icon-only.

Tier-up notifications: at most one per save per deity per direction. The Faithful-tier-up suppression rule covers the day a commitment offer fires. No additional anti-spam is required.

The Champion `Entry + ambient` cadence for Kyne is one storm-acknowledgment per in-game day plus one outdoor-rest acknowledgment per rest. Both are `Quiet` or `Noted`. The Marked Champion entry itself is once per save.

---

## 11. Orc (full draft)

Implementation-locked. Single Malacath devotion, life-mode-divergent. `PDV_State_OrcLifeMode` with `City = 0`, `Stronghold = 1`, `LegionExile = 2`. No separate focused-primary deity layer per `PDV_TargetEndStates_1.0.md` line 463.

**Slot-frame correction:** the planning-pass slot frame assumed one blessing set with mode as a state interpretation. The locked `RaceDesign_Orc` "Tier Rewards" section in fact mode-differentiates Tier 2 and Tier 3 blessings (Stronghold / City / Legion-Exile each get distinct blessing text). Tier 1 is shared across modes. The blessing slot list below reflects the corrected seven-record set.

**No commitment offer.** Orc has no separate focused-primary offer per `TargetEndStates` line 463. Deepening comes through mode-specific Malacath excellence; Tier 3 entry uses the Devoted tier-up notification plus the per-mode Champion entry MessageBox. No god-voice offer beat is authored.

### 11.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Malacath | Blunt, verdict-toned, exile-coded; never petitioned, never warm; speaks of the code, the forge, the oath, and what he has witnessed; a judgment rendered, not a comfort offered. |
| Stronghold shaman (ambient) | Old, ritual, mountain-stronghold-coded; interprets Malacath's will aloud; the only Orc voice that speaks for the god rather than as him. Used only in Stronghold Champion ambient lines. |

### 11.2 Blessing descriptions (`PDV_Bless_Orc_Malacath_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1 shared; Tier 2 and Tier 3 mode-differentiated per the corrected set above. Anti-farm: passive SPEL, no firing cost.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Orc_Malacath_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 1" | Passive SPEL; all modes | Malacath has noted your conduct. The weapons and armor you temper improve a little further; Orcish armor you wear adds 5 armor; your resistance to disease rises by 10%; your brawls hit 5% harder. |
| PDV_Bless_Orc_Malacath_T2_Stronghold | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 2 -- Stronghold Orc" | Passive SPEL; Stronghold mode | Malacath sees the oath carried in full. Your forge work tempers higher. Proving strength against a hard foe restores health after the fight. |
| PDV_Bless_Orc_Malacath_T2_City | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 2 -- City Orc" | Passive SPEL; City mode | Malacath sees the code held with no stronghold to hold it for you. Quality work earns his eye. Standing firm against scorn steadies your next words. |
| PDV_Bless_Orc_Malacath_T2_LegionExile | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 2 -- Legion/Exile Orc" | Passive SPEL; LegionExile mode | Malacath weighs the code carried under foreign command. A contract honored under pressure is counted. Endurance through the long march is counted. |
| PDV_Bless_Orc_Malacath_T3_Stronghold | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Stronghold Orc Champion" | Passive SPEL; Stronghold mode | Malacath's witness is complete. Weapons you forged strike 5% harder in your hands alone. Near death, once a day, his fury restores stamina and lightens your blows. |
| PDV_Bless_Orc_Malacath_T3_City | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "City Orc Champion" | Passive SPEL; City mode | Malacath saw you hold the code where nothing rewarded it. Your craft always reaches its ceiling. Met with scorn and unbroken, your next fight steadies you. |
| PDV_Bless_Orc_Malacath_T3_LegionExile | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Legion/Exile Orc Champion" | Passive SPEL; LegionExile mode | Malacath acknowledged the endurance. A hard service completed steadies the next fight. You carry 15 more weight; the exile's back is broad. |

### 11.3 Tier-up notifications (`PDV_Notif_Orc_Malacath_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. No `suppress-if-offer-same-dawn` flag: Orc has no commitment offer. Anti-farm: one per direction per save.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Orc_Malacath_ObservantEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Tier 1" | One per save | Malacath has begun to watch your conduct. Observant. |
| PDV_Notif_Orc_Malacath_FaithfulEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Tier 2" | One per save | Malacath sees the pattern. The code is carried. Faithful. |
| PDV_Notif_Orc_Malacath_DevotedEntry | Notification | Marked | Narrator | 80/60 | RaceDesign_Orc "Tier 3" | One per save; precedes the per-mode Champion entry | Malacath's witness is complete. Devoted. |
| PDV_Notif_Orc_Malacath_ObservantLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Neglect Texture" | One per direction per save | Malacath's eye has drifted from you. Wavering. |
| PDV_Notif_Orc_Malacath_FaithfulLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Neglect Texture" | One per direction per save | The code shows thin to Malacath now. Observant. |
| PDV_Notif_Orc_Malacath_DevotedLapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Orc "Neglect Texture" | One per save per Devoted loss | Malacath no longer holds the Devoted witness. |

### 11.4 Champion entry and ambient

Champion shapes: **Stronghold** is `Entry + ambient` (forge and shaman texture is ongoing recognition per `RaceDesign_Orc` "Stronghold Orc Champion"). **City** is `Entry + ambient` (one dignity-under-scorn ambient line; the source's "brief resolve bonus when insulted" is a recurring beat). **Legion/Exile** is `Entry-only` (the source frames it as a completed statement, not a recurring texture).

God-voice on entry MessageBoxes; player-second-person on ambient notifications.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Orc_Malacath_ChampionEntry_Stronghold | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Stronghold Orc Champion"; TargetEndStates "Orc Champion moment" | One-time on first Stronghold Devoted | Title: "The Forge Sings" Body: "I do not bless. I witness. The forge, the oath, the strength, the kin -- you carried all four. The stronghold is yours, and the work you make knows your hand." |
| PDV_Msg_Orc_Malacath_ChampionEntry_City | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "City Orc Champion"; TargetEndStates lines 478-479 | One-time on first City Devoted | Title: "Witnessed Alone" Body: "No chief confirmed you. No shaman named you. No stronghold held the code for you. I did. You held it where nothing made you, and that is the harder thing." |
| PDV_Msg_Orc_Malacath_ChampionEntry_LegionExile | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Legion/Exile Orc Champion"; TargetEndStates line 480 | One-time on first LegionExile Devoted; Entry-only Champion | Title: "The Burden Carried" Body: "You carried my code through a foreign army, a foreign province, years that wanted you smaller. You did not get smaller. The exile who endures is my truest word." |
| PDV_Notif_Orc_Malacath_ChampionAmbient_ForgeWork | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Stronghold Orc Champion" | Stronghold Devoted + forge use; one per in-game day | The forge work feels like prayer answered. |
| PDV_Notif_Orc_Malacath_ChampionAmbient_StrongholdAccept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Stronghold Orc Champion" ("the shaman's voice feels present") | Stronghold Devoted + at a stronghold; one per stronghold visit | At the stronghold, the shaman's words seem meant for you. |
| PDV_Notif_Orc_Malacath_ChampionAmbient_PrivateOath | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "City Orc Champion" | City Devoted + dignity-under-scorn beat; per qualifying event | Scorned, and unbroken. Malacath's witness holds. |

### 11.5 Neglect texture (`PDV_Notif_Orc_Malacath_NeglectTexture_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Orc` "Neglect Texture": emptiness at the forge, mode-specific drift, and the explicit oath-breaking signal. Each fires on the first day of a meaningful lapse, not continuously.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Orc_Malacath_NeglectTexture_Forge | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Neglect Texture" line 184; "Stronghold neglect" | One per lapse-band crossing | The forge is only iron and heat now. The work has stopped being prayer. |
| PDV_Notif_Orc_Malacath_NeglectTexture_CityQuality | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "City Orc neglect" line 187 | One per lapse-band crossing; City mode | The work is just work now. There is nothing of the code left in it. |
| PDV_Notif_Orc_Malacath_NeglectTexture_LegionErasure | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Legion/Exile neglect" line 188 | One per lapse-band crossing; LegionExile mode | Folded away to fit in, you have left Malacath nothing to watch. |
| PDV_Notif_Orc_Malacath_NeglectTexture_OathBroken | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Oath-breaking" line 189 | One per oath-break event; sustained breaking accrues separately | An oath set down is an oath Malacath saw you set down. |

### 11.6 Survey Devotion readouts (`PDV_Msg_Orc_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One variant per life-mode. The `%s` token is bound to the tier-name external table.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Orc_Survey_Stronghold | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Orc "Mode Philosophies" | Cast Survey Devotion | You carry Malacath's code inside the stronghold, where forge, kin, and oath hold it with you. Standing: %s. The witness continues. |
| PDV_Msg_Orc_Survey_City | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Orc "Mode Philosophies" | Cast Survey Devotion | You carry Malacath's code in the city, alone, with no stronghold to confirm it. Standing: %s. Malacath watches what no one else does. |
| PDV_Msg_Orc_Survey_LegionExile | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Orc "Mode Philosophies" | Cast Survey Devotion | You carry Malacath's code under foreign discipline. The contract is the oath; the endurance is the strength. Standing: %s. |

### 11.7 Contextual favor surfacings

Four trigger families per life-mode per `RaceDesign_Orc` "Contextual Favor Table". Only `Noted` and `Marked` rows are authored; `Quiet` rows are icon-only. Player-second-person on Noted; god-voice on Marked. Per the table review locks, the two Marked moments are Stronghold Blood-Kin crisis and Legion/Exile exile-burden return.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Orc_FavorNoted_Stronghold_ForgeExcellence | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 128 | After-act; quality/value/context required; daily cap | The work serves the hold. Malacath marks the maker. |
| PDV_Notif_Orc_FavorNoted_Stronghold_BloodKinCrisis | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 129 | After-act; ordinary stronghold aid | The stronghold stands a little surer for what you did. |
| PDV_Msg_Orc_FavorMarked_Stronghold_BloodKinCrisis | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Contextual Favor Table" line 129; "Table review locks" line 161 | Major crisis resolution or stronghold re-entry only; per-event | Title: "Blood-Kin" Body: "You answered the stronghold's worst hour. The kin will not forget it, and neither will I." |
| PDV_Notif_Orc_FavorNoted_Stronghold_CommunalProvision | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 130 | After-act; curated provision/oath stages | Provision given, oath kept. The kin are held. |
| PDV_Notif_Orc_FavorNoted_Stronghold_WorthyChallenge | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 131 | Noted only for stronghold crisis, boss, trial, or Malacath-significant fight; else Quiet | A true test met. Malacath was watching that one. |
| PDV_Notif_Orc_FavorNoted_City_QualityLabor | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 132 | After-act; named commission or quality threshold | The city does not know the work was a rite. Malacath does. |
| PDV_Notif_Orc_FavorNoted_City_Dignity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 133 | After-act; curated hostile/dismissive outcome only | Met with scorn, you did not bend. The code held. |
| PDV_Notif_Orc_FavorNoted_City_OrcSolidarity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 134 | After-act; named Orc aid; cooldown | You stood by your own where no stronghold would. Counted. |
| PDV_Notif_Orc_FavorNoted_City_SelfMadeCommunity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 135 | Environmental/after-act; `PDV_SacredPlace` investment required | The place you built has witnesses now. |
| PDV_Notif_Orc_FavorNoted_LegionExile_ContractPressure | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 136 | After-act; completed pressure-bearing service only | The contract held under weight. Malacath counts the hard ones. |
| PDV_Notif_Orc_FavorNoted_LegionExile_Endurance | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 137 | Environmental/after-act; caps; endurance is context | The long road did not break you. Endurance is the strength. |
| PDV_Notif_Orc_FavorNoted_LegionExile_Discipline | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 138 | After-act; authored milestone proving the code was carried | You served without erasing yourself. The code crossed the border with you. |
| PDV_Notif_Orc_FavorNoted_LegionExile_ExileBurden | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Orc "Contextual Favor Table" line 139 | After-act; ordinary return to invested place | Returned from service to the place you made. The burden set down a while. |
| PDV_Msg_Orc_FavorMarked_LegionExile_ExileBurden | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Contextual Favor Table" line 139; "Table review locks" line 165 | Major return, restoration, or community-established moment only; per-event | Title: "The Burden Returned" Body: "You went out under another's banner and came back to the place you made. The exile who returns carrying the code is the word I am proudest to speak." |

### 11.8 Life-mode shift notifications (`PDV_Notif_Orc_LifeMode_*`)

**Slot-frame correction:** the planning-pass slot frame used `PDV_Msg_Orc_LifeMode_*` (MessageBox). A life-mode shift is a band-crossing-class state change, not a god speaking; it is downgraded to a `Notification` with `Narrator` voice. Per `RaceDesign_Orc` "Life-mode selection rule": shifts resolve at major gates or dawn consolidation.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Orc_LifeMode_Stronghold_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Life-mode selection rule"; TargetEndStates line 469 | Fires on confirmed switch into Stronghold | You live inside the code now. Stronghold Orc. |
| PDV_Notif_Orc_LifeMode_City_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Life-mode selection rule" | Fires on confirmed switch into City | You carry the code in the city now. City Orc. |
| PDV_Notif_Orc_LifeMode_LegionExile_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Orc "Life-mode selection rule" | Fires on confirmed switch into LegionExile | You carry the code in service now. Legion and exile. |

### 11.9 Curse-state transitions (`PDV_Msg_Orc_CurseState_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Orc` "Curse State Summary": werewolf is conditionally defensible, vampirism is near-total collapse. Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Orc_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Werewolf"; Race_Orc "Curse States" | Once on first transformation as Orc | Title: "The Beast Tested" Body: "The wolf is in you. I do not turn away from it. But the beast is judged by my code as the smith is: is it strong, does it endure, does it serve the kin or break them? Prove the wolf." |
| PDV_Msg_Orc_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Werewolf" | Once on werewolf cure completion | Title: "The Wolf Set Aside" Body: "You have put the beast down. It was never outside my code; it was a thing to master, and you mastered it by ending it. You are an Orc still, and still tested. The kin will weigh the wolf longer than I will." |
| PDV_Msg_Orc_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Vampire"; Race_Orc "Curse States" | Once on becoming vampire | Title: "Outside the Test" Body: "You feed on the living now. That is dependency, and dependency is the thing my code exists to refuse. You stand outside the test. Cure this, or I have nothing to witness." |
| PDV_Msg_Orc_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Orc "Vampire" | Once on cure completion | Title: "Back Within Reach" Body: "The thirst is gone. You are a living Orc again, and a living Orc can be tested. Begin. The kin will remember the lapse longer than the code does." |

### 11.10 Shrine and privilege dialogue topics (`PDV_Dlog_Orc_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three representative archetypes, one per life-mode's spiritual-authority figure per `Race_Orc` "Spiritual Authority".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Orc_Chief_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Orc "Stronghold NPC recognition" | Stronghold Devoted or Blood-Kin | "I carry the code. Tell me what the stronghold needs." |
| PDV_Dlog_Orc_Shaman_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; Race_Orc "Spiritual Authority" | Stronghold mode, any tier | "Speak Malacath's will. I will hear it." |
| PDV_Dlog_Orc_LegionOfficer_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Orc "Legion/Exile" | LegionExile Devoted | "I serve under your command, and I serve the code. Both hold." |

### 11.11 Orc pilot firing-density sanity

A Faithful City Orc in steady mixed-society play (crafting commissions, occasional Orc-aid beat):

- Marked: 0 most days; Stronghold Blood-Kin crisis and Legion/Exile burden-return are rare quest-anchored events. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (one quality-labor favor, occasional dignity or solidarity beat). Inside the `<2 per h` target.
- Quiet: uncounted; icon-only (worthy-challenge favor is Quiet outside stronghold crisis context).

Tier-up notifications: at most one per save per direction. Life-mode shift notifications are gated to confirmed switches at major gates or dawn, with a three-day soft-switch lock-out, so they cannot fire repeatedly.

## 12. Dunmer (full draft)

Implementation-locked. Layered, not path-based: Layer 1 ancestor substrate is always active; Layer 2 is shared Good Daedra acknowledgment (Tier 2 cap); Layer 3 is a single focused Reclamation (Azura, Boethiah, or Mephala). `PDV_Substrate_DunmerAncestor` owns the substrate; `PDV_State_DunmerAncestorPosture` has `Normal = 0`, `Strained = 1`, `Silent = 2`, `RestoredScarred = 3`.

**Slot-frame corrections:**
- **Blessings are not per-deity for Tier 1 and 2.** `RaceDesign_Dunmer` "Tier Rewards" locks Tier 1 and Tier 2 as the shared Layer 1 + Layer 2 experience; only Tier 3 is per-focused-Reclamation. The corrected set is five blessing records: `PDV_Bless_Dunmer_GoodDaedra_T1`, `_GoodDaedra_T2`, and `_Azura_T3` / `_Boethiah_T3` / `_Mephala_T3`.
- **Shrine dialogue archetypes revised.** The planning-pass frame named `TempleNewLifeReclamations`, `AncestralTomb`, and `HouseDunmer`, none of which exist as Skyrim surfaces (the infrastructure ceiling means no Dunmer tombs or House shrines). Corrected to Grey Quarter elder, a Reclamations devotee, and general Dunmer kin.
- **Tribunal Memory added.** `RaceDesign_Dunmer` "Tribunal Memory (LOCKED)" is a named flavor content category (occasional notification text referencing Vivec, Sotha Sil, Almalexia). The planning-pass frame omitted it; it is authored below as a curated pool.

### 12.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Ancestors | Quiet, old, witnessing; the ash and the dead; never punish, only answer or fall silent; speak of being seen and held across distance. |
| Azura | Twilight-voiced, prophetic, tender about painful truth; speaks of thresholds and of becoming truer, not merely stronger; warns rather than commands. |
| Boethiah | Trial-voiced, sharp, strength-testing; speaks of the unworthy cut away and the self authored through struggle; combative, never cruel. |
| Mephala | Soft, conspiratorial, web-voiced; speaks of the hidden people, the secret kept, the web drawn close; intimate rather than loud. |

### 12.2 Ancestor substrate posture readouts (`PDV_Msg_Dunmer_AncestorPosture_*`)

Narrator voice. Status readout surface (shown by Survey Devotion and on posture transitions). Budget 240 hard / 180 target. One per posture enum value.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Dunmer_AncestorPosture_Normal | Status spell readout | Quiet | Narrator | 240/180 | RaceDesign_Dunmer "Ancestor posture enum"; TargetEndStates lines 292-293 | Default for living Dunmer | The ash-prayer carries. The ancestors are present, and they answer the life you are living. |
| PDV_Msg_Dunmer_AncestorPosture_Strained | Status spell readout | Noted | Narrator | 240/180 | RaceDesign_Dunmer "Ancestor posture enum" | Werewolf or ritual-unclean state; fires on transition | The ash-prayer carries, but thinly. Something in you sits uneasy with the ancestors -- the beast, or an unclean rite. |
| PDV_Msg_Dunmer_AncestorPosture_Silent | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Dunmer "Ancestor posture enum"; "Curse State Summary" | Active vampirism; fires on transition | The ash-prayer meets no answer. The ancestors do not speak to the undead. The silence is not punishment; it is what you have become. |
| PDV_Msg_Dunmer_AncestorPosture_RestoredScarred | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Dunmer "Ancestor posture enum" | Post-cure return; fires on transition | The ash-prayer carries again. The ancestors answer -- but they remember the silence, and so do you. |

### 12.3 Blessing descriptions (`PDV_Bless_Dunmer_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1 and Tier 2 are the shared Layer 1 + Layer 2 experience; Tier 3 is per focused Reclamation. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Dunmer_GoodDaedra_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Tier 1" | Passive SPEL; shared Layer 1+2 | The ash-prayer is kept and the Good Daedra are acknowledged. Your resistance to fire rises by 5% and your resistance to magic rises by 5%. |
| PDV_Bless_Dunmer_GoodDaedra_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Tier 2" | Passive SPEL; shared Layer 1+2 | The Reclamations hold steady around your exile. From dawn to midday, your resistance to fire rises by 10% and your resistance to magic rises by 5%. A power-attack kill on a strong foe returns stamina. |
| PDV_Bless_Dunmer_Azura_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Azura focus" | Passive SPEL; Azura focus | Azura watches your thresholds. From dawn to noon, fire and magic resistance climb together; by night, magic costs 10% less. |
| PDV_Bless_Dunmer_Boethiah_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Boethiah focus" | Passive SPEL; Boethiah focus | Boethiah marks proven strength. After felling a significant foe, you carry 25 more weight and your power attacks grow lighter for a day. The ancestors record the victory. |
| PDV_Bless_Dunmer_Mephala_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Mephala focus" | Passive SPEL; Mephala focus | Mephala draws the web close. Your resistance to poison rises by 20%, and the hidden network brings you secrets before others hear them. Discretion opens doors others never see. |

### 12.4 Tier-up notifications (`PDV_Notif_Dunmer_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. Observant and Faithful are shared-layer; Devoted is per focused Reclamation (the `%s` token binds the focus deity name). Faithful entry carries `suppress-if-offer-same-dawn` because Dunmer focus uses the formal-offer gate.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Dunmer_GoodDaedra_ObservantEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Tier 1" | One per save | The ash-prayer holds and the Good Daedra answer. Observant. |
| PDV_Notif_Dunmer_GoodDaedra_FaithfulEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Tier 2" | One per save; suppress-if-offer-same-dawn | The Reclamations are steady in your exile. Faithful. |
| PDV_Notif_Dunmer_Focus_DevotedEntry | Notification | Marked | Narrator | 80/60 | RaceDesign_Dunmer "Tier 3" | One per save; %s is the focus deity | %s knows your name now. Devoted. |
| PDV_Notif_Dunmer_GoodDaedra_ObservantLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Neglect Texture" | One per direction per save | The Good Daedra answer more faintly now. Wavering. |
| PDV_Notif_Dunmer_GoodDaedra_FaithfulLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Neglect Texture" | One per direction per save | The Reclamations are thinning toward silence. Observant. |
| PDV_Notif_Dunmer_Focus_DevotedLapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Dunmer "Neglect Texture" | One per save per focus loss | The bond with %s loosens. The Devoted bond is not held. |

### 12.5 Champion entry and ambient

All three Reclamation Champions are `Entry + ambient`: each end-state passage describes ongoing in-fiction recognition (Azura's threshold flavor, Boethiah's "they have seen" on rival kills, Mephala's web texture). God-voice on entry MessageBoxes; player-second-person on ambient notifications.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Dunmer_Azura_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Azura focus"; TargetEndStates "Azura Champion" | One-time on first Azura Devoted | Title: "Azura at the Threshold" Body: "I marked your people once, at the worst crossing they ever made. I mark you now. Stand at the thresholds, and you will not stand at them blind." |
| PDV_Notif_Dunmer_Azura_ChampionAmbient_Threshold | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Azura focus" | Azura Devoted + threshold beat; one per in-game day | At the threshold, Azura's voice goes ahead of you. |
| PDV_Msg_Dunmer_Boethiah_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Boethiah focus"; TargetEndStates "Boethiah Champion" | One-time on first Boethiah Devoted | Title: "Boethiah's Mark" Body: "You did not survive. You overcame. The unworthy fell, and you stood where they stood. Author yourself further -- I am watching, and so are the dead." |
| PDV_Notif_Dunmer_Boethiah_ChampionAmbient_Trial | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Boethiah focus" | Boethiah Devoted + rival-strength kill; cooldown | A worthy foe down. The ancestors have seen. |
| PDV_Msg_Dunmer_Mephala_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Mephala focus"; TargetEndStates "Mephala Champion" | One-time on first Mephala Devoted | Title: "Mephala's Web" Body: "The hidden people survive because someone holds the threads. You hold them now. The web knows your hand, and it will not let you fall through it." |
| PDV_Notif_Dunmer_Mephala_ChampionAmbient_HiddenObligation | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Mephala focus" | Mephala Devoted + hidden-community beat; per qualifying event | The web tightens, quietly, in your favor. |

### 12.6 Commitment offers (`PDV_Msg_Dunmer_*_Offer` and `PDV_Msg_Dunmer_OfferResponse_*`)

God-voice on offer bodies; player-second-person on responses. MessageBox. Body budget 500 hard / 280 target; title 40/30. Per `RaceDesign_Dunmer` "Focus gate (LOCKED)": the offer must present as a Reclamation deepening through the life already lived, never as abandoning the ancestors.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Dunmer_Azura_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Focus gate" | Dawn-fire; per-deity cooldown | Title: "Azura's Twilight" Body: "You have lived toward me without naming it -- the thresholds kept, the hard truths faced. This is not leaving the ancestors. It is the ash-prayer deepening toward dawn. Will you name me your focus?" |
| PDV_Msg_Dunmer_Boethiah_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Focus gate" | Dawn-fire; per-deity cooldown | Title: "Boethiah's Trial" Body: "You have proven yourself against the unworthy again and again. The ancestors witnessed it; now I ask for it by name. This deepens the Reclamation; it does not replace the ash. Will you name me your focus?" |
| PDV_Msg_Dunmer_Mephala_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Focus gate" | Dawn-fire; per-deity cooldown | Title: "Mephala's Whisper" Body: "You have kept the web whole without being asked. The hidden people are safer for you. Name me your focus, and the ash-prayer deepens into the web -- nothing of the ancestors is set down. Will you?" |
| PDV_Msg_Dunmer_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Shared across Dunmer offers | Deepen toward this Reclamation. |
| PDV_Msg_Dunmer_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Sets per-deity cooldown only | Not yet. |
| PDV_Msg_Dunmer_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Broad shared worship continues | Stay with the shared Reclamations. |

### 12.7 Neglect texture (`PDV_Notif_Dunmer_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Dunmer` "Neglect Texture": silence, not punishment, across all three layers. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Dunmer_Layer1_AshPrayerQuiet | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Layer 1 neglect"; TargetEndStates lines 318-320 | One per lapse-band crossing | The ash-prayer goes out, and nothing comes back. The ancestors have gone quiet. |
| PDV_Notif_Dunmer_Layer2_GoodDaedraThin | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Layer 2 neglect" | One per lapse-band crossing | The Good Daedra feel far off. The dawn no longer warms the way it did. |
| PDV_Notif_Dunmer_Layer3_FocusFading | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Layer 3 neglect" | One per lapse-band crossing; %s is the focus deity | %s no longer waits at your thresholds. The bond is thinning. |

### 12.8 Survey Devotion readouts (`PDV_Msg_Dunmer_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One variant for no-focus shared worship and one per focused Reclamation. The `%s` token binds the tier-name external table.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Dunmer_Survey_NoFocus | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | The ash-prayer holds and the three Good Daedra answer together. Standing: %s. No single Reclamation has your name yet. |
| PDV_Msg_Dunmer_Survey_Azura | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | Azura holds your focus; the ash-prayer carries beneath her. Standing: %s. The thresholds are watched. |
| PDV_Msg_Dunmer_Survey_Boethiah | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | Boethiah holds your focus; the ash-prayer carries beneath. Standing: %s. The dead record your victories. |
| PDV_Msg_Dunmer_Survey_Mephala | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | Mephala holds your focus; the ash-prayer carries beneath. Standing: %s. The web holds you, and you hold it. |

### 12.9 Contextual favor surfacings

Five trigger families in the shared lane and five each for Azura, Boethiah, and Mephala per `RaceDesign_Dunmer` "Contextual Favor Table". Only `Noted` and `Marked` rows are authored; `Quiet` rows are icon-only. Player-second-person on Noted; god-voice on Marked. The locked anti-generic boundaries (Azura threshold, Boethiah cruelty, Mephala crime) carry into the dep-notes column.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Dunmer_FavorNoted_Shared_AshPrayer | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 152 | Environmental/after-act; home improves but is not required | The ash-prayer carries, even here. The ancestors are near. |
| PDV_Notif_Dunmer_FavorNoted_Shared_DiasporaSolidarity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 154 | After-act; curated Dunmer-aid hooks | You stood by your own in exile. The ancestors count it. |
| PDV_Notif_Dunmer_FavorNoted_Shared_ReclamationAck | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 155 | After-act; stays blended pre-focus | The Reclamations stir. All three are with you yet. |
| PDV_Notif_Dunmer_FavorNoted_Shared_DeadObligations | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 156 | After-act; buildable proxies only, no penalty for impossible rites | The dead are tended as the ash allows. It is enough. |
| PDV_Notif_Dunmer_FavorNoted_Azura_ThresholdKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 157 | Environmental/after-act; real threshold required, not decorative twilight | You crossed knowing it was a crossing. Azura goes with you. |
| PDV_Notif_Dunmer_FavorNoted_Azura_PainfulTruth | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 158 | After-act; truth without cost stays Noted | You chose the hard truth over the useful lie. Azura marks it. |
| PDV_Msg_Dunmer_FavorMarked_Azura_PainfulTruth | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer favor table line 158 | Marked only when the truth costs safety, power, or belonging | Title: "Azura's Star" Body: "The truth cost you safety, and you took it anyway. That is the becoming I watch for. Walk on, clearer than you were." |
| PDV_Notif_Dunmer_FavorNoted_Azura_ExileEndured | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 159 | After-act/environmental; continuity across distance | Far from home, the practice held. Exile did not dissolve you. |
| PDV_Msg_Dunmer_FavorMarked_Azura_ChangedBody | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer favor table line 160 | Rare major; curse-state confrontation or major cleansing only | Title: "Azura Knows" Body: "Your body has changed, and I did not look away. What you are now is not simple, and I will not pretend it is. But you are still becoming, and I am still here." |
| PDV_Notif_Dunmer_FavorNoted_Azura_StarRite | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 161 | Environmental/after-act; shrine and artifact signals | The Star and the twilight answer you personally now. |
| PDV_Notif_Dunmer_FavorNoted_Boethiah_TrialSurvived | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 162 | Momentary/after-act; real pressure required, not every kill | Pressed hard, you proved strong. Boethiah counts it. |
| PDV_Notif_Dunmer_FavorNoted_Boethiah_FalseAuthority | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 163 | After-act; ordinary overthrow stays Noted | An unworthy power pulled down. Boethiah is pleased. |
| PDV_Msg_Dunmer_FavorMarked_Boethiah_FalseAuthority | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer favor table line 163 | Marked for major quest outcomes only | Title: "Boethiah's Calling" Body: "You cut away an order that did not deserve to stand. This is the trial: not destruction, but the worthier thing put in its place. Stand there." |
| PDV_Notif_Dunmer_FavorNoted_Boethiah_BetrayalTest | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 164 | After-act; for surviving the test, never casual cruelty | Betrayed, and you answered with strength. The test is passed. |
| PDV_Notif_Dunmer_FavorNoted_Boethiah_ChimericSelf | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 165 | After-act; generic Altmer kills do not qualify | You chose a Dunmer destiny over an order imposed. Counted. |
| PDV_Notif_Dunmer_FavorNoted_Boethiah_Conspiracy | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 166 | Quiet/Noted; recognizes decisive covert action | The strike landed clean and unseen. Boethiah favors the plot. |
| PDV_Notif_Dunmer_FavorNoted_Mephala_HiddenCommunity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 167 | After-act; keeping the hidden people intact, not generic charity | The hidden people are whole because you kept them so. |
| PDV_Notif_Dunmer_FavorNoted_Mephala_SecretKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 168 | Quiet/Noted; only when the secret preserves an obligation | A secret held, and an obligation with it. The web holds. |
| PDV_Msg_Dunmer_FavorMarked_Mephala_LethalSecret | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer favor table line 169 | Marked only for major Mephala quest/artifact moments | Title: "The Whispering Door" Body: "A blade in the dark, drawn for the web and not for yourself. The hidden people will never know it was you. I will." |
| PDV_Notif_Dunmer_FavorNoted_Mephala_ObligationWeb | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 170 | Quiet/Noted; the web tightening helpfully | A favor passed along an unseen thread. The web tightens kindly. |
| PDV_Notif_Dunmer_FavorNoted_Mephala_NecessaryLie | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer favor table line 171 | After-act; the survival lie, curated hooks, not broad fraud | The lie protected the web. Mephala knows the difference. |

### 12.10 Portable shrine and Tribunal Memory

Portable shrine activation is the core low-friction Dunmer rhythm (the ash-prayer ceremony). Player-second-person, Notification, Noted. Tribunal Memory is a curated cosmetic flavor pool, narrator voice, Noted, with no scoring impact per `RaceDesign_Dunmer` "Tribunal Memory (LOCKED)".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Dunmer_PortableShrine_Activate | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Infrastructure ceiling"; Architecture v3 Section 21.2 | Per ash-prayer use; daily cap on the favor it feeds | You set the ash and pray. The portable shrine answers. |
| PDV_Notif_Dunmer_PortableShrine_PrivateContext | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Dunmer "Infrastructure ceiling"; Race_Dunmer "Portable shrine practice" | Player-owned home bonus context | Prayed within your own walls, the ash-prayer carries further. |
| PDV_Notif_Dunmer_TribunalMemory_Vivec | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Tribunal Memory" | Curated trigger pool; cosmetic, no scoring; rare cadence | For a breath, you think of Vivec, and the city that is gone. |
| PDV_Notif_Dunmer_TribunalMemory_SothaSil | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Tribunal Memory" | Curated trigger pool; cosmetic, no scoring; rare cadence | Sotha Sil's clockwork silence crosses your mind, then passes. |
| PDV_Notif_Dunmer_TribunalMemory_Almalexia | Notification | Noted | Narrator | 80/60 | RaceDesign_Dunmer "Tribunal Memory" | Curated trigger pool; cosmetic, no scoring; rare cadence | Almalexia's name surfaces, bright and bitter, and sinks again. |

### 12.11 Curse-state transitions (`PDV_Msg_Dunmer_CurseState_*`)

MessageBox. Body budget 500 hard / 280 target. Fires once per cure cycle. **Voice deviation:** the vampire-onset row uses Narrator voice, not god-voice, because its theological content is precisely the absence of the god-voice -- the ancestors have gone silent and cannot speak the message. The cure and werewolf rows use god-voice (the ancestors).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Dunmer_CurseState_VampireOnset_AshSilenced | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Dunmer "Curse States"; TargetEndStates line 322 | Once on becoming vampire; sets posture Silent; voice deviation justified above | Title: "The Ash-Prayer Silenced" Body: "You set the ash and speak the prayer, and for the first time in your life nothing answers. The ancestors do not speak to the undead. The silence is total, and it is yours now." |
| PDV_Msg_Dunmer_CurseState_VampireCured_Scarred | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Curse States"; TargetEndStates line 322 | Once on cure; sets posture RestoredScarred | Title: "The Ancestors Answer" Body: "The ash-prayer carries again. We hear you. But we heard the silence too, and it does not leave us, or you. Return -- scarred, and still ours." |
| PDV_Msg_Dunmer_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Werewolf"; Race_Dunmer "Curse States" | Once on first transformation; sets posture Strained | Title: "Ritually Unclean" Body: "The beast in you has no place in the ash or the Reclamations. The ancestors do not turn away, but they answer thinly now. Hircine offers nothing to fill the gap." |
| PDV_Msg_Dunmer_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Dunmer "Curse States" | Once on werewolf cure; clears posture Strained | Title: "The Ash Runs Clean" Body: "The beast is set down. The ritual taint lifts, and the ancestors answer at full voice once more. The ash takes your prayer without strain. What was unclean is washed; carry the Reclamations on." |

### 12.12 Shrine and privilege dialogue topics (`PDV_Dlog_Dunmer_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three archetypes grounded in Skyrim Dunmer surfaces.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Dunmer_GreyQuarterElder_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Dunmer "diaspora solidarity" | Faithful or above | "I carry the ash-prayer in exile, as you do. Tell me what the quarter needs." |
| PDV_Dlog_Dunmer_ReclamationsDevotee_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Dunmer "Layer 2" | Focused on any Reclamation | "The Good Daedra answer me. Speak of the Reclamations." |
| PDV_Dlog_Dunmer_DunmerKin_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Dunmer "Religious Identity" | Any tier | "We are far from Morrowind, kin. The ancestors still watch us both." |

### 12.13 Dunmer firing-density sanity

A Faithful no-focus Dunmer in steady play (occasional Grey Quarter beat, portable ash-prayer most mornings, Good Daedra shrine when found):

- Marked: 0 most days; the Marked Azura/Boethiah/Mephala favors are quest-anchored and rare. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (ash-prayer rhythm plus an occasional shared-layer favor or Tribunal Memory line). The Tribunal Memory pool is rare-cadence so it does not compound. Inside the `<2 per h` target.
- Quiet: uncounted; icon-only (witnessed-victory, several Boethiah and Mephala families are Quiet outside their stronger contexts).

Tier-up notifications: at most one per save per direction; Faithful entry is suppressed on a same-dawn focus offer. Posture readouts fire only on posture transitions, which are rare (curse onset/cure).

## 13. Altmer (full draft)

Altmer was the last Partial implementation-spec per `PDV_TargetEndStates_1.0.md` lines 76-87. For the Phase 20 content lock the spec is closed and every slot is authored: the previously gated contextual-favor surfacings, the Lorkhan crisis-of-faith copy, and the post-vampire Exiled Altmer micro-path flavor are now drafted in Section 13.13.

`ThalmorAlignment` is the orthodoxy/coherence track (`0-30 Heterodox`, `31-69 Orthodox Moderate`, `70-100 Thalmor Devout`). Layer 1 Auri-El is always active. Focused commitment uses the shared patron state.

**Slot-frame corrections:**
- **Blessings are not per-deity for Tier 1 and 2.** `RaceDesign_Altmer` "Tier Rewards" locks Tier 1 and Tier 2 as the shared Auri-El-foundation-plus-pantheon experience; only Tier 3 is per focused deity. Corrected to `PDV_Bless_Altmer_Pantheon_T1`, `_Pantheon_T2`, and `_AuriEl_T3` / `_Magnus_T3` / `_Trinimac_T3` / `_Xarxes_T3` / `_Syrabane_T3`. "Psijic" is a faction, not a deity; the Psijic-aligned focuses are Magnus and Syrabane.
- **Five focused deities, not three.** The planning-pass Champion-entry frame named only Trinimac/Magnus/Psijic. The locked Tier 3 set is Auri-El, Magnus, Trinimac, Xarxes, Syrabane.

### 13.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Auri-El | Vast, serene, time-and-sun; speaks of the return, the path back, the dawn; patient on a scale that dwarfs a mortal life. |
| Magnus | Precise, scholarly, escape-coded; the architect who got out; speaks of the Elder Way and of the arts as the road. |
| Trinimac | Stern, militant, civilizational; speaks of the project defended by force and orthodoxy held; the martial ancestor. |
| Xarxes | Dry, archival, lineage-keeping; speaks of what is written, the genealogy, the quiet truth that outlasts enforcement. |
| Syrabane | Gentle, guardian-toned, warding; the apprentices' protector; speaks of the magic that shields the one still on the path. |

### 13.2 Blessing descriptions (`PDV_Bless_Altmer_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1 and Tier 2 are the shared Auri-El-plus-pantheon experience; Tier 3 is per focused deity. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Altmer_Pantheon_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Tier 1" | Passive SPEL; shared | Auri-El is acknowledged at dawn. Spells in all schools cost 3% less and your resistance to magic rises by 5%. |
| PDV_Bless_Altmer_Pantheon_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Tier 2" | Passive SPEL; shared | The pantheon relationship is stable and coherent. At dawn, a spell-cost reduction holds until noon. Advancing a magic skill makes the next cast of that school free. |
| PDV_Bless_Altmer_AuriEl_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Auri-El focus" | Passive SPEL; Auri-El focus | Auri-El watches your return. Magic regenerates 25% faster out of combat; from dawn to midday, spells cost 15% less. |
| PDV_Bless_Altmer_Magnus_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Magnus focus" | Passive SPEL; Magnus focus | Magnus marks the scholar's discipline. Alteration and Illusion cost 10% less; magic regenerates 20% faster out of combat. |
| PDV_Bless_Altmer_Trinimac_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Trinimac focus" | Passive SPEL; Trinimac focus; ThalmorAlignment 70+ | Trinimac blesses the project defended by force. Your one-handed attacks strike 5% harder, and an enforcement act under high orthodoxy raises your armor by 15 for a day. |
| PDV_Bless_Altmer_Xarxes_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Xarxes focus" | Passive SPEL; Xarxes focus | Xarxes keeps your lineage. Your Enchanting and Alteration improve by 5%, and a quest of real ancestry returns a day of cheaper magic. |
| PDV_Bless_Altmer_Syrabane_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Altmer "Syrabane focus" | Passive SPEL; Syrabane focus | Syrabane shields the apprentice. Magic-using foes deal 15% less damage; your wards absorb 15% more. |

### 13.3 Tier-up notifications (`PDV_Notif_Altmer_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. Observant and Faithful are shared; Devoted is per focused deity (`%s` binds the focus deity name). Faithful entry carries `suppress-if-offer-same-dawn` (Altmer uses the formal-offer gate).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_Pantheon_ObservantEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "Tier 1" | One per save | The dawn is acknowledged and the path is begun. Observant. |
| PDV_Notif_Altmer_Pantheon_FaithfulEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "Tier 2" | One per save; suppress-if-offer-same-dawn | Your theology holds its coherence. Faithful. |
| PDV_Notif_Altmer_Focus_DevotedEntry | Notification | Marked | Narrator | 80/60 | RaceDesign_Altmer "Tier 3" | One per save; %s is the focus deity | %s recognizes your coherence. Devoted. |
| PDV_Notif_Altmer_Pantheon_ObservantLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "Neglect Texture" | One per direction per save | The path is acknowledged less surely now. Wavering. |
| PDV_Notif_Altmer_Pantheon_FaithfulLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "Neglect Texture" | One per direction per save | Your coherence is slipping. Observant. |
| PDV_Notif_Altmer_Focus_DevotedLapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Altmer "Neglect Texture" | One per save per focus loss | The bond with %s loosens. The Devoted bond is not held. |

### 13.4 Champion entry and ambient

Champion shapes: **Auri-El** and **Magnus** are `Entry + ambient` (dawn return and skill-milestone are recurring in-fiction beats). **Trinimac**, **Xarxes**, and **Syrabane** are `Entry-only` (their ongoing recognition is dialogue privilege, authored in Section 13.12, not ambient lines). God-voice on entries; player-second-person on ambients.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_AuriEl_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Auri-El focus"; TargetEndStates "Altmer Champion" | One-time on first Auri-El Devoted | Title: "Auri-El's Dawn" Body: "You held the path through a world built to make you forget it. The return is not a doctrine to you; it is a daily practice. Keep walking toward the dawn. I am the dawn." |
| PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Auri-El focus" | Auri-El Devoted + dawn observance; one per in-game day | The dawn answers you, and the return feels near. |
| PDV_Msg_Altmer_Magnus_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Magnus focus"; TargetEndStates "Divine Body Champion" | One-time on first Magnus Devoted | Title: "The Elder Way" Body: "I did not break the trap with force. I studied until the wall became a door. You have studied as I studied. The arts are the road, and you are far along it." |
| PDV_Notif_Altmer_Magnus_ChampionAmbient_Milestone | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Magnus focus" | Magnus Devoted + magic skill milestone; per milestone | A school mastered further. Magnus marks the discipline. |
| PDV_Msg_Altmer_Trinimac_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Trinimac focus"; TargetEndStates "Thalmor Orthodox Champion" | One-time on first Trinimac Devoted; Entry-only | Title: "Trinimac's Sword" Body: "The project does not defend itself. You have defended it -- by force, by orthodoxy held without flinching. The Lorkhan world strikes hardest at those who strike hardest for me. You did not yield." |
| PDV_Msg_Altmer_Xarxes_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Xarxes focus" | One-time on first Xarxes Devoted; Entry-only | Title: "Xarxes' Record" Body: "Enforcement forgets. The record does not. You have kept faith with the lineage and the written truth. Your name is set down where it cannot be unwritten." |
| PDV_Msg_Altmer_Syrabane_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Syrabane focus" | One-time on first Syrabane Devoted; Entry-only | Title: "Syrabane's Ward" Body: "The path is long and the one who walks it can fall. I have shielded apprentices since the first of them. I shield you now. Walk on, and walk warded." |

### 13.5 Neglect texture (`PDV_Notif_Altmer_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Altmer` "Neglect Texture": Altmer neglect is inconsistency, not absence. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_NeglectTexture_OrthodoxyDrift | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Orthodoxy drift" | One per lapse-band crossing | Your acts no longer match your stated theology. You feel undefined. |
| PDV_Notif_Altmer_NeglectTexture_CultivationFading | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Psijic drift" | One per lapse-band crossing | You have stopped cultivating yourself. The discipline that set you apart fades. |
| PDV_Notif_Altmer_NeglectTexture_AuriElDistant | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Neglect Texture" | One per lapse-band crossing | The dawn is only the dawn now. The return feels far away. |

### 13.6 Lorkhan Adjacency pressure (`PDV_Notif_Altmer_LorkhanPressure_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Altmer` "Lorkhan Adjacency Penalty System": the tags `PDV_ALT_LORKHAN_T1/T2/T3` are locked. Per the "Obviousness rule", the interpretation must be surfaced so the player understands the theological meaning. The example presentation in the design ("You feel the old dissonance: this rite honors the mortal world Lorkhan made.") informs the Tier 3 line.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_LorkhanPressure_T1 | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Lorkhan ... Tier 1"; tag `PDV_ALT_LORKHAN_T1_DIRECT` | One-time per major source; long cooldown on repeatable worship sources | You have touched the thing that broke your people. The dissonance is deep. |
| PDV_Notif_Altmer_LorkhanPressure_T2 | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Lorkhan ... Tier 2"; tag `PDV_ALT_LORKHAN_T2_SHOR_ADJ` | One-time per source or milestone; no repeat spam | This act belongs to Shor's framework, not yours. It stings to be here. |
| PDV_Notif_Altmer_LorkhanPressure_T3 | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Lorkhan ... Tier 3"; "Obviousness rule"; tag `PDV_ALT_LORKHAN_T3_MORTAL_VALIDATION` | At most once per in-game day; surfaces the interpretation on first instance | You feel the old dissonance: this honors the mortal world Lorkhan made. |

Tier 4 (`PDV_ALT_LORKHAN_T4_CONTEXT`) adjusts `ThalmorAlignment` only and carries no piety penalty; it produces no dedicated notification beyond the band-crossing rows in Section 13.7.

### 13.7 ThalmorAlignment band crossings (`PDV_Notif_Altmer_ThalmorAlignment_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Bands locked at `0-30 Heterodox`, `31-69 Orthodox Moderate`, `70-100 Thalmor Devout`. Fires on band entry.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_ThalmorAlignment_Heterodox | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "ThalmorAlignment Track" | One per band entry | Alignment: Heterodox. Self-cultivation is favored; enforcement rings hollow. |
| PDV_Notif_Altmer_ThalmorAlignment_OrthodoxModerate | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "ThalmorAlignment Track" | One per band entry | Alignment: Orthodox Moderate. The whole pantheon stands equally open. |
| PDV_Notif_Altmer_ThalmorAlignment_ThalmorDevout | Notification | Noted | Narrator | 80/60 | RaceDesign_Altmer "ThalmorAlignment Track" | One per band entry; unlocks Trinimac focus eligibility | Alignment: Thalmor Devout. Enforcement is worship; Trinimac's path opens. |

### 13.8 Commitment offers (`PDV_Msg_Altmer_*_Offer` and `PDV_Msg_Altmer_OfferResponse_*`)

God-voice on offer bodies; player-second-person on responses. MessageBox. Body budget 500 hard / 280 target; title 40/30. Trinimac's offer is gated on `ThalmorAlignment` 70+ per `RaceDesign_Altmer` "Trinimac gating".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_AuriEl_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Worship Structure" | Dawn-fire; per-deity cooldown | Title: "Auri-El's Path" Body: "You have kept the dawn through every temptation to forget it. Make the return your focus, and the foundation becomes the whole of your faith. Will you name me?" |
| PDV_Msg_Altmer_Magnus_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Worship Structure" | Dawn-fire; per-deity cooldown | Title: "Magnus and the Elder Way" Body: "You study as escape, not as utility. That is my path. Name me your focus, and the arts become the road back. Will you?" |
| PDV_Msg_Altmer_Trinimac_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Trinimac gating" | Dawn-fire; per-deity cooldown; requires ThalmorAlignment 70+ | Title: "Trinimac's Call" Body: "You have defended the project with the sword, not only the prayer. The orthodox path is the hardest, and the Lorkhan world will strike you hardest for it. Name me, and carry that weight." |
| PDV_Msg_Altmer_Xarxes_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Xarxes focus" | Dawn-fire; per-deity cooldown | Title: "Xarxes and the Record" Body: "You trust what is written over what is enforced. Name me your focus, and the lineage and the quiet truth become your devotion. Will you?" |
| PDV_Msg_Altmer_Syrabane_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Syrabane focus" | Dawn-fire; per-deity cooldown | Title: "Syrabane's Guard" Body: "You cast to shield, not only to strike. Name me your focus, and the warding arts become your path. Will you walk it guarded?" |
| PDV_Msg_Altmer_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Shared across Altmer offers | Name this focus. |
| PDV_Msg_Altmer_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Sets per-deity cooldown only | Not yet. |
| PDV_Msg_Altmer_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Broad coherent worship continues | Keep to the foundation. |

### 13.9 Survey Devotion readouts (`PDV_Msg_Altmer_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One variant per faction alignment. `%s` binds the tier-name external table.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_Survey_ThalmorOrthodox | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Altmer "Worship Structure" | Cast Survey Devotion | You hold the orthodox path: enforcement as faith, the project defended by force. Standing: %s. The Lorkhan world costs you most, and you pay it. |
| PDV_Msg_Altmer_Survey_DivineBody | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Altmer "Worship Structure" | Cast Survey Devotion | You hold the Divine Body path: balanced cultural practice, the return pursued without rigid enforcement. Standing: %s. |
| PDV_Msg_Altmer_Survey_Psijic | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Altmer "Worship Structure" | Cast Survey Devotion | You hold the Psijic path: the Old Ways, private meditation, heterodox scholarship. Standing: %s. The Lorkhan world costs you least. |

### 13.10 Curse-state transitions (`PDV_Msg_Altmer_CurseState_*`)

God-voice (Auri-El). MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Altmer` "Curse State Summary": both states are terminal -- vampirism has no clean restoration, werewolf halts devotion entirely. Fires once on onset. The post-vampire Exiled Altmer micro-path flavor is drafted in Section 13.13 as enhancement custom content.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Vampire"; Race_Altmer "Curse States" | Once on becoming vampire; terminal -- no restoration arc | Title: "Auri-El Closes" Body: "You flee the sun now, and the sun is the god of return. There is no path back from where you stand. The records will not hold your name. This is not a punishment. It is what shrinking from the dawn has always meant." |
| PDV_Msg_Altmer_CurseState_WerewolfHardHalt | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Werewolf"; TargetEndStates "Altmer werewolf note" line 351 | Once on first transformation; devotion halts entirely | Title: "The Project Inverted" Body: "The whole of Altmer faith is to become spirit again. You have become a beast. There is no doctrine for this, no heresy small enough to hold it, no path in any direction. Devotion stops here." |

### 13.11 Lorkhan first-interpretation notice (`PDV_Msg_Altmer_LorkhanInterp_FirstTime`)

God-voice deviation: this is a one-time teaching MessageBox, narrator voice, that fires the first time any Lorkhan pressure tag triggers, so the player learns what the dissonance means before the Section 13.6 short notifications carry it alone. Per `RaceDesign_Altmer` "Obviousness rule".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_LorkhanInterp_FirstTime | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Altmer "Obviousness rule" | One-time, first Lorkhan pressure of any tier | Title: "The Old Dissonance" Body: "Lorkhan made the mortal world, the trap your ancestors fell into. Acts that honor, strengthen, or celebrate his creation press against your faith -- not because a god disapproves, but because you have touched the thing that broke your people. You will feel this again." |

### 13.12 Shrine and privilege dialogue topics (`PDV_Dlog_Altmer_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three archetypes per the recognition-privilege payoffs in `RaceDesign_Altmer` "Tier Rewards".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Altmer_AuriElDevotee_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Altmer "Auri-El focus" | Auri-El Devoted | "I keep the dawn and the path back. Speak of the return." |
| PDV_Dlog_Altmer_CollegeMage_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Altmer "Magnus focus" | Magnus or Syrabane focus; College context | "The arts are my devotion. Show me what the College keeps closed." |
| PDV_Dlog_Altmer_ThalmorOfficer_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Altmer "Trinimac focus" | Trinimac Devoted; ThalmorAlignment 70+ | "I defend the project by the sword. The orthodoxy knows my name." |

### 13.13 Contextual favor, Lorkhan crisis, and Exiled path (drafted)

Spec closed for Phase 20 content lock. The contextual-favor lanes are keyed to the three locked alignment paths (Altmer carries no generic broad lane per `RaceDesign_Altmer`): ThalmorOrthodox, DivineBody, Psijic. Noted favor is player-second-person (Notification, 80/60); Marked favor is god-voice Auri-El, the always-active foundation (MessageBox, 500/280). The four Lorkhan crisis beats are the locked trigger list (`PDV_ALT_CRISIS_FAITH`): the Dragonborn declaration, the Sovngarde beat, a marriage beat, and the Companions beast-blood fork; narrator voice, matching the Section 13.11 dissonance teaching. The post-vampire Exiled micro-path is authored as optional enhancement flavor after the terminal onset in Section 13.10.

Ratification note (2026-05-31 AEST): `MarriageBeat` is the current third
crisis beat, presented in player-facing terms as Marriage / Mortal Continuity,
not Talos/Thalmor contradiction. Lore cross-review treats the beat as
household, lineage, embodied attachment, and continuity inside Lorkhan's mortal
world; it is not anti-Mara and not a claim that Altmer marriage is invalid.
Talos/Thalmor can only return as a later additional crisis row through an
explicit decision. The two wired proof reward rows use
`PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance` for dawn steadiness and
`PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended` for orthodox cost.

Contextual favor -- ThalmorOrthodox lane:

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_FavorNoted_ThalmorOrthodox_Enforcement | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | After-act; one per enforcement act, daily cap | Heresy named and answered. The orthodoxy marks the hand that enforces. |
| PDV_Notif_Altmer_FavorNoted_ThalmorOrthodox_OrthodoxRite | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Environmental; dawn rite at an orthodox shrine, daily cap | The dawn kept by the strict rite. Doctrine is served as written. |
| PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Rare major; a costly act defending orthodoxy by the sword | Title: "Auri-El Marks the Sword" Body: "You did not only pray for the project; you bled for it. The hardest path is the one that answers Lorkhan's world with steel, and you walked into the cost with open eyes. The dawn knows what it took from you." |

Contextual favor -- DivineBody lane:

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_FavorNoted_DivineBody_Cultivation | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | After-act; mastery milestone, daily cap | Mastery earned and refined. You raise yourself as the project asks. |
| PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Environmental; unforced dawn observance, daily cap | You greet the dawn unforced. The return is honored, not compelled. |
| PDV_Msg_Altmer_FavorMarked_DivineBody_ReturnAffirmed | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Rare major; affirming the return without enforcement | Title: "Auri-El Marks the Return" Body: "You turned toward the dawn when the mortal world offered every reason to forget it, and you did it without a whip at anyone's back. This is the return as it was meant: chosen, not enforced. I keep it." |

Contextual favor -- Psijic lane:

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Altmer_FavorNoted_Psijic_OldWaysMeditation | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Environmental; private meditation, daily cap | The Old Ways kept in private. The quiet path costs you least. |
| PDV_Notif_Altmer_FavorNoted_Psijic_ForbiddenLore | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | After-act; heterodox lore recovered, daily cap | Hidden knowledge recovered. What is written outlasts what is enforced. |
| PDV_Msg_Altmer_FavorMarked_Psijic_UnseenStep | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Altmer "Worship Structure"; TargetEndStates line 146 favor-lane closeout | Rare major; a lonely, unrewarded Old Ways moment | Title: "Auri-El Marks the Quiet Path" Body: "You kept the Old Ways where no one could see and no one could reward you. The heterodox road is lonely and easy to abandon, and you did not abandon it. The foundation holds you still." |

Lorkhan crisis-of-faith (`PDV_Msg_Altmer_LorkhanCrisis_*`):

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_LorkhanCrisis_DragonbornDeclaration | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Altmer "Obviousness rule"; TargetEndStates line 146 crisis-trigger closeout | One-time on being named Dragonborn | Title: "Named for the Mortal World" Body: "They call you Dragonborn -- a mortal soul carrying the dragon's, blessed by the world Lorkhan made and the people who live in it. The gift is real. So is the dissonance: the thing that honors you is the thing your ancestors died trying to escape. You will carry both." |
| PDV_Msg_Altmer_LorkhanCrisis_SovngardeBeat | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Altmer "Obviousness rule"; TargetEndStates line 146 crisis-trigger closeout | One-time on the Sovngarde beat | Title: "The Hall That Should Not Be" Body: "Sovngarde is real -- a hall of mortal dead who feast and do not dissolve, who chose to stay in the world rather than return beyond it. To an Altmer this is the trap made beautiful. You have seen it now, and you cannot unsee that the mortal world keeps its own." |
| PDV_Msg_Altmer_LorkhanCrisis_MarriageBeat | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Altmer "Obviousness rule"; TargetEndStates line 146 crisis-trigger closeout | One-time on taking a spouse | Title: "Bound to the World" Body: "You have taken a spouse, a door, a hearth -- ties to the mortal world Lorkhan built. The Psijics would call it attachment; the orthodox would call it descent. It may be the truest thing you have done, or the deepest forgetting. Only you can say which." |
| PDV_Msg_Altmer_LorkhanCrisis_CompanionsFork | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Altmer "Obviousness rule"; TargetEndStates line 146 crisis-trigger closeout | One-time at the Companions beast-blood fork | Title: "The Beast at the Threshold" Body: "The Companions offer you the blood of the beast -- to become, by choice, the furthest thing from spirit an Altmer can be. The whole of your faith is to rise out of flesh, not deeper into it. Refuse, and you keep the project. Accept, and there is no doctrine left to hold you." |

Post-vampire Exiled Altmer path (`PDV_Msg_Altmer_VampireExiledPath_*`, optional enhancement flavor after the Section 13.10 terminal onset):

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Altmer_VampireExiledPath_Entry | MessageBox | Marked | Narrator | 500/280 | TargetEndStates Section 21.2 line 1536 enhancement content | One-time after vampire onset, if the Exiled path is enabled | Title: "The Exile's Road" Body: "Auri-El has closed, and the records will not hold your name. What remains is not devotion but exile -- a long walk outside the return, among others the dawn has let go. There is no path back. There is only how you carry the dark you have become." |
| PDV_Msg_Altmer_VampireExiledPath_Recognition | MessageBox | Marked | Narrator | 500/280 | TargetEndStates Section 21.2 line 1536 enhancement content | On reaching the Exiled-path recognition beat | Title: "Known Among the Exiled" Body: "The others outside the dawn know you now -- the cast-out Altmer, the ones the return forgot. It is not a congregation and it is not grace. It is recognition, of a kind, among those who share the same closed door. You are not alone in the exile, even if you stand alone before the god." |

### 13.14 Altmer firing-density sanity

A Faithful Divine Body Altmer in steady play (dawn observance, College progression, occasional Lorkhan-adjacent beat from the main quest):

- Marked: 0 most days; Champion entry, curse onsets, crisis MessageBoxes, and the Lorkhan first-interpretation notice are one-time or rare quest-paced events. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day in steady play (dawn ambient/favor after pressure, occasional study milestone, rare contextual favor). Lorkhan pressure notifications are one-time-per-source and main-quest-paced, so they do not compound. Inside the `<2 per h` target.
- Quiet: uncounted; icon-only.

Tier-up notifications: one per save per direction; Faithful entry suppressed on a same-dawn focus offer. ThalmorAlignment band crossings are infrequent (the track moves on authored enforcement/defiance acts). The Section 13.13 contextual-favor rows are now drafted; each lane is capped at one Noted favor per family per day with a single rare Marked, keeping the lane inside the `<2 per h` Noted target.

## 14. Khajiit (full draft)

Implementation-locked. No formal commitment offer per `PDV_Architecture_v3.md` Section 12.4a; focused emphasis emerges silently. `PDV_Substrate_KhajiitLunar` owns the always-active lunar substrate. `PDV_State_KhajiitFocusedEmphasis` with `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, `Alkosh = 5`. `PDV_State_KhajiitLunarPosture` with `Normal = 0`, `Strained = 1`, `Corrupted = 2`, `ShadowDrift = 3`.

**Slot-frame corrections:**
- **Blessings include a substrate baseline and shared Tier 1/2.** The locked `RaceDesign_Khajiit` "Tier Rewards" gives the always-active lunar substrate its own passive expression, then shared Tier 1 and Tier 2, then per-focus Tier 3. The corrected set is eight blessing records: `PDV_Bless_Khajiit_Lunar_Substrate`, `_Lunar_T1`, `_Lunar_T2`, and `_Khenarthi_T3` / `_Azurah_T3` / `_BaanDar_T3` / `_Rajhin_T3` / `_Alkosh_T3`.
- **No commitment offer; silent focus emergence instead.** Khajiit is the only no-offer race. The commitment slot is replaced by a single gentle focus-emergence notification (Section 14.5), templated by the `%s` deity token, surfaced as a Noted notification rather than a MessageBox so it never reads as a popup the player accepts.
- **Survey readout simplified.** One Broad row plus one Focused row templated by `%s` deity and `%s` tier, rather than one row per deity.

### 14.1 Tone profiles

| Voice | Tone profile |
|---|---|
| The Lunar Lattice | Vast, impersonal, cosmological; not a voice that addresses you so much as a structure you live inside; spoken of by the narrator, never speaking itself. |
| Khenarthi | Wind-voiced, road-knowing, merciful; speaks of passage, of arriving when needed, of the open sky; always moving. |
| Azurah | Twilight-voiced, threshold-knowing; the mother who shaped the Khajiit; speaks of fate and the hinges of the world; tender and certain. |
| Baan Dar | Sly, warm to the outcast, reversal-voiced; a pariah's god speaking to a pariah; speaks of the improbable escape and the clever turn. |
| Rajhin | A performer's voice, delighted, legend-making; speaks of theft as art and of the story worth telling; never petty. |
| Alkosh | Rare, immense, order-keeping; the dragon-lord; speaks of cosmic chaos held back and the line that must not break. |

### 14.2 Lunar substrate readouts and phase flavor

Lunar posture readouts are narrator voice, status readout surface, budget 240 hard / 180 target. Lunar phase shift flavor is a curated cosmetic pool, narrator voice, Notification, budget 80 hard / 60 target, with no scoring impact.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Khajiit_LunarPosture_Normal | Status spell readout | Quiet | Narrator | 240/180 | RaceDesign_Khajiit "Lunar posture enum" | Default | The Lunar Lattice holds you cleanly. The moons know your form, and the road knows your step. |
| PDV_Msg_Khajiit_LunarPosture_Strained | Status spell readout | Noted | Narrator | 240/180 | RaceDesign_Khajiit "Werewolf posture" | Lycanthropy; fires on transition | The Lattice holds you, but strained. The beast-shape is a competing form, and the caravans keep their distance. |
| PDV_Msg_Khajiit_LunarPosture_Corrupted | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Khajiit "Vampire posture" | Vampirism; fires on transition | The Lattice still holds you, corrupted and thinned. The moons do not disown the undead, but the community does. |
| PDV_Msg_Khajiit_LunarPosture_ShadowDrift | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Khajiit "ShadowDrift boundary" | Dominant shadow behavior; fires on transition | You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars. |
| PDV_Notif_Khajiit_LunarPhase_FullMoons | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Moon-cycle model"; Race_Khajiit "The Lunar Cycle" | Curated pool; cosmetic; per phase shift | Masser and Secunda are both full. The night's devotion runs strong. |
| PDV_Notif_Khajiit_LunarPhase_Crossed | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Moon-cycle model" | Curated pool; cosmetic; per phase shift | The moons cross overhead. You feel the Lattice tighten in the bone. |
| PDV_Notif_Khajiit_LunarPhase_Waning | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Moon-cycle model" | Curated pool; cosmetic; per phase shift | The moons wane. The road asks for a quieter, steadier faith now. |

### 14.3 Blessing descriptions (`PDV_Bless_Khajiit_*`)

Narrator voice. Budget 200 hard / 140 target. The substrate baseline is always active; Tier 1 and Tier 2 are shared; Tier 3 is per focused deity. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Khajiit_Lunar_Substrate | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Lunar Substrate" | Passive SPEL; always active | The Lunar Lattice holds you. Night vision is keener after dark; outdoor night life and caravan kinship are felt as devotion. |
| PDV_Bless_Khajiit_Lunar_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Tier 1" | Passive SPEL; shared | The moons have noticed how you move. Stamina Regeneration +5% (at night), Disease Resistance +15% (at night). |
| PDV_Bless_Khajiit_Lunar_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Tier 2" | Passive SPEL; shared | The Lattice holds you steady. Outdoor night travel carries more; cold and storms press lighter; full moons strengthen the day's devotion. |
| PDV_Bless_Khajiit_Khenarthi_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Khenarthi Champion" | Passive SPEL; Khenarthi focus | Khenarthi names you to the road. Sprinting outdoors drains 15% less stamina; storms no longer chill you; outdoor sleep restores health and stamina both. |
| PDV_Bless_Khajiit_Azurah_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Azurah Champion" | Passive SPEL; Azurah focus | Azurah watches your thresholds. Spells cost 10% less at night and 15% less at dawn and dusk. The hinges of the world turn where you stand. |
| PDV_Bless_Khajiit_BaanDar_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Baan Dar Champion" | Passive SPEL; Baan Dar focus | Baan Dar walks with the pariah. Once a week, a near-fatal escape returns a day-long pulse of fortune. Acts beyond the city walls weigh heavier. |
| PDV_Bless_Khajiit_Rajhin_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Rajhin Champion" | Passive SPEL; Rajhin focus | Rajhin marks the artful thief. A theft from a notable target opens a brief unseen window; the first strike of a fight cuts deeper. |
| PDV_Bless_Khajiit_Alkosh_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Khajiit "Alkosh Champion" | Passive SPEL; Alkosh focus | Alkosh keeps the cosmic line. Your resistance to fire rises by 15%, and felling a named dragon grants a two-day blessing of order. |

### 14.4 Tier-up notifications (`PDV_Notif_Khajiit_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. Observant and Faithful are shared lunar worship; no `suppress-if-offer-same-dawn` flag because Khajiit has no offer. The Devoted entry is the per-deity Champion entry (Section 14.6); only the Devoted lapse lives here.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Khajiit_Lunar_ObservantEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Tier 1" | One per save | The moons have noticed how you move. Observant. |
| PDV_Notif_Khajiit_Lunar_FaithfulEntry | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Tier 2" | One per save | The Lattice holds you steady now. Faithful. |
| PDV_Notif_Khajiit_Lunar_ObservantLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Neglect Texture" | One per direction per save | The moons mark you less surely now. Wavering. |
| PDV_Notif_Khajiit_Lunar_FaithfulLapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Neglect Texture" | One per direction per save | The Lattice holds you more thinly. Observant. |
| PDV_Notif_Khajiit_Focus_DevotedLapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Khajiit "Focused patron neglect" | One per save per focus loss; %s is the focus deity | The lean toward %s fades. The Devoted bond is not held. |

### 14.5 Silent focus emergence (`PDV_Notif_Khajiit_FocusEmergence`)

Narrator voice. HUD notification, not a MessageBox, so it never reads as a popup the player accepts. Budget 80 hard / 60 target. This is the Khajiit-specific replacement for a commitment offer: per `RaceDesign_Khajiit` "Silent patron emergence", focus shifts silently at dawn when one deity has 50+ piety and a 15-piety lead. One templated row; the `%s` token binds the emerging deity name (Khenarthi, Azurah, Baan Dar, Rajhin, or Alkosh).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Khajiit_FocusEmergence | Notification | Noted | Narrator | 80/60 | RaceDesign_Khajiit "Silent patron emergence"; Architecture v3 Section 12.4a | Fires once at dawn when emphasis shifts None to a deity; %s is the emerging deity | Your devotion has been leaning toward %s. The moons already knew. |

### 14.6 Champion entry and ambient

Champion entries are the Tier 3 / Devoted recognition. They are MessageBoxes with no choice -- a recognition delivered, not an offer accepted -- so they honor the silent-system rule (the moon noticed you; you did not apply). God-voice on entries; player-second-person on ambients. Champion shapes: Khenarthi, Azurah, and Baan Dar are `Entry + ambient`; Rajhin and Alkosh are `Entry-only` (Rajhin's theft texture and Alkosh's rare dragon work surface as gameplay, not authored ambient lines).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Khajiit_Khenarthi_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Khenarthi Champion" | One-time on first Khenarthi Devoted | Title: "Khenarthi's Road" Body: "The wind has carried you so long it has learned your name. Walk, and the road walks with you. The open sky was always your temple roof." |
| PDV_Notif_Khajiit_Khenarthi_ChampionAmbient_Road | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Khenarthi Champion" | Khenarthi Devoted + open-road travel; one per in-game day | The road runs easy under you. Khenarthi's wind is at your back. |
| PDV_Msg_Khajiit_Azurah_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Azurah Champion" | One-time on first Azurah Devoted | Title: "Azurah's Twilight" Body: "I shaped the Khajiit at the first dusk. I have watched you stand at every threshold since. You feel the world's hinges now. Cross well." |
| PDV_Notif_Khajiit_Azurah_ChampionAmbient_Threshold | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Azurah Champion" | Azurah Devoted + threshold beat; one per in-game day | A threshold ahead. Azurah's twilight goes before you. |
| PDV_Msg_Khajiit_BaanDar_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Baan Dar Champion" | One-time on first Baan Dar Devoted | Title: "Baan Dar's Favor" Body: "The world offered you nothing, exile, and you made a life of it anyway. That is my whole gospel. When the reversal should have killed you, look for my hand." |
| PDV_Notif_Khajiit_BaanDar_ChampionAmbient_Reversal | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Baan Dar Champion" | Baan Dar Devoted + improbable survival; weekly cap | You should not have walked away from that. Baan Dar's hand. |
| PDV_Msg_Khajiit_Rajhin_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Rajhin Champion" | One-time on first Rajhin Devoted; Entry-only | Title: "Rajhin's Touch" Body: "The Footpad himself stole from an Emperor and wore Mephala's ring. You steal as though a story is being told. It is. I am telling it." |
| PDV_Msg_Khajiit_Alkosh_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Alkosh Champion" | One-time on first Alkosh Devoted; Entry-only | Title: "Alkosh's Line" Body: "Lorkhaj's chaos gnaws at the seams of the world. Few are asked to hold the line against it. You were. You held. The dragon-lord knows your face." |

### 14.7 Neglect texture (`PDV_Notif_Khajiit_NeglectTexture_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Khajiit` "Neglect Texture": cumulative thinning from being indoors, urban, and cut off from road and community. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Khajiit_NeglectTexture_SubstrateThinning | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Substrate neglect" | One per lapse-band crossing | Too long indoors and walled in. The Lattice holds you more thinly. |
| PDV_Notif_Khajiit_NeglectTexture_PatronFading | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Focused patron neglect" | One per lapse-band crossing; %s is the focus deity | %s sends less than you had grown used to. The lean is fading. |
| PDV_Notif_Khajiit_NeglectTexture_CaravanForgotten | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "The caravan dimension" | One per lapse-band crossing | The caravans do not know your face. You have not been where they go. |

### 14.8 Survey Devotion readouts (`PDV_Msg_Khajiit_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One Broad row and one Focused row. The Focused row uses two tokens: `%s` deity name and `%s` tier name.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Khajiit_Survey_Broad | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2; RaceDesign_Khajiit "Broad fallback" | Cast Survey Devotion | You walk inside the Lunar Lattice, broad and unfocused, held by the moons and the road. Standing: %s. No god leads yet, and that is whole. |
| PDV_Msg_Khajiit_Survey_Focused | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 deity, %s2 tier | The Lattice holds you, and %s1 leads your devotion now. Standing: %s2. You did not choose it; you were walking it. |

### 14.9 Contextual favor surfacings

Six trigger families, formalized from `RaceDesign_Khajiit` "In-game hook cross-check", Tier 2 path-specific notes, and Champion specifics. **Substrate/Road** (daily environmental and caravan-kinship); **Khenarthi** (open-road wind grace); **Azurah** (threshold-crossings); **Baan Dar** (adversity and near-fatal reversal); **Rajhin** (elegant theft); **Alkosh** (dragon and order). Player-second-person on Noted; god-voice on Marked. The Baan Dar reversal is a `Rare major favor` per `PDV_TargetEndStates_1.0.md` line 112.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Khajiit_FavorNoted_Substrate_RoadLife | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "In-game hook cross-check" (open road) | Environmental; daily cap; no fast-travel | The road carries you kindly tonight. The moons are near. |
| PDV_Notif_Khajiit_FavorNoted_Substrate_CaravanKinship | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "In-game hook cross-check" (caravan belonging) | After-act; cooldown per caravan encounter | The caravan knows you and is glad of it. Kinship counts. |
| PDV_Notif_Khajiit_FavorNoted_Khenarthi_RoadGrace | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Khenarthi Champion" | Environmental; Khenarthi emphasis | Khenarthi's wind finds your back on the open road. |
| PDV_Notif_Khajiit_FavorNoted_Azurah_Threshold | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Azurah thresholds" | After-act; real threshold required | A crossing made well. Azurah's twilight marks it. |
| PDV_Notif_Khajiit_FavorNoted_BaanDar_Outnumbered | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Baan Dar reversals" | Momentary combat; adversity filter; cooldown | Outnumbered and still standing. Baan Dar favors the long odds. |
| PDV_Msg_Khajiit_FavorMarked_BaanDar_Reversal | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Baan Dar Champion"; TargetEndStates line 112 (rare major favor) | Weekly cap; near-fatal escape only | Title: "Pariah's Fortune" Body: "That was not survivable, and you survived it. The god of pariahs wrote you a way out, because once, someone should have done the same for him." |
| PDV_Notif_Khajiit_FavorNoted_Rajhin_ElegantTheft | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Rajhin elegant theft" | After-act; notable target; no petty-theft spam | A theft worth a story. Rajhin is delighted. |
| PDV_Notif_Khajiit_FavorNoted_Alkosh_DragonOrder | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Alkosh dragon/order" | After-act; named dragon or order-keeping beat | A dragon down, the line held. Alkosh marks the order kept. |

### 14.10 Road home acknowledgment (`PDV_Notif_Khajiit_RoadHome_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Khajiit` "Road homes": 2-3 designated anchors; piety requires cycling the circuit, not repeating one anchor.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Khajiit_RoadHome_Designate | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Road homes"; Architecture v3 Section 21.2 | On designating an anchor (max 2-3) | You have made this a road home. The circuit has an anchor here. |
| PDV_Notif_Khajiit_RoadHome_Return | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Road-home cadence" | On returning to an anchor after cycling; not repeat-camping | Back at a road home, the circuit holding. The Lattice steadies. |
| PDV_Notif_Khajiit_RoadHome_MissedCadence | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Khajiit "Road-home cadence" | On cadence lapse | You have not walked the circuit in too long. The anchors grow cold. |

### 14.11 Curse-state transitions (`PDV_Msg_Khajiit_CurseState_*`)

MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Khajiit` "Curse State Summary": curses damage belonging rather than erasing Khajiit identity; both are recoverable. God-voice is Azurah (the mother who shaped the Khajiit and guards their passage, the protective reading for the undead). **Voice deviation:** the ShadowDrift row uses narrator voice, because ShadowDrift is the Lattice loosening its hold -- there is no god present to speak it.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Khajiit_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Vampire"; sets posture Corrupted | Once on becoming vampire | Title: "The Lattice Corrupted" Body: "The thirst has taken you, little moon. The Lattice does not cast you out -- the moons do not disown their own -- but the caravans will fear you, and rightly. I will not look away. Few of the others can say the same." |
| PDV_Msg_Khajiit_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Vampire" | Once on cure; clears posture toward Normal | Title: "The Lattice Clears" Body: "The thirst is gone. The corruption lifts from the Lattice, and the caravans may learn your face again. Walk back into the moonlight. It was always waiting." |
| PDV_Msg_Khajiit_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Werewolf"; sets posture Strained | Once on first transformation | Title: "A Competing Shape" Body: "Hircine has given you another shape. The moons are about form, and you carry one too many now. You are still Khajiit -- strained, watched, but not erased. The community will fear the wolf. Hold to the road." |
| PDV_Msg_Khajiit_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Khajiit "Werewolf" | Once on werewolf cure; clears posture toward Normal | Title: "One Shape Again" Body: "The wolf is set down, little moon. The Lattice holds a single shape once more, and the extra form no longer pulls against the moons. The caravans will lose their fear in time. The road is yours again." |
| PDV_Msg_Khajiit_CurseState_ShadowDriftEntry | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Khajiit "ShadowDrift boundary"; sets posture ShadowDrift | Once on entering ShadowDrift; voice deviation justified above | Title: "The Shadow Between Stars" Body: "You have lived too long in the shadow -- night-only, predatory, drawn to the dark between the moons. The Lattice loosens its hold. Khenarthi's road and Azurah's twilight both feel far away now." |
| PDV_Msg_Khajiit_CurseState_ShadowDriftRecovery | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Khajiit "ShadowDrift boundary"; clears ShadowDrift posture | Once on leaving ShadowDrift; pairs with ShadowDriftEntry | Title: "Back Under the Moons" Body: "You have turned from the dark between the stars and walked back into the moonlight. The Lattice tightens its hold again, and Khenarthi's road and Azurah's twilight return to you. The drift is ended." |

### 14.12 Shrine and privilege dialogue topics (`PDV_Dlog_Khajiit_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Two archetypes grounded in Khajiit road life.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Khajiit_Caravaneer_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Khajiit "caravan belonging" | Faithful or above | "I walk the road and the moons walk with me. What does the caravan need?" |
| PDV_Dlog_Khajiit_MoonPriest_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; Race_Khajiit "Who They Worship" | Any tier | "The Lattice holds me. Speak of the moons, and of Riddle'Thar." |

### 14.13 Khajiit firing-density sanity

A Faithful broad-worship Khajiit in steady road play (outdoor sleep, caravan encounters, foot travel between holds):

- Marked: 0 most days; Champion entries and curse onsets are one-time, and the Baan Dar reversal favor is weekly-capped. Inside the `<1 per 2h` target.
- Noted: ~2 per day (a road-life favor, a caravan-kinship favor, occasional lunar-phase flavor on a shift). Phase flavor is per-shift so it cannot compound. Inside the `<2 per h` target.
- Quiet: uncounted; icon-only.

The silent focus emergence fires once per save when emphasis first activates. Tier-up notifications are one per save per direction. There is no offer, so no Faithful suppression rule applies. Road-home acknowledgments are gated to the cadence rule, so repeat-camping cannot farm them.

## 15. Imperial (full draft)

Implementation-locked. Broad Nine Divines worship plus the formal-offer focus pattern, with `PDV_RepTrack_ConcordatStanding` running underneath (`Open Defiant`, `Private Defiant`, `Uncommitted`, `Public Compliant`, `Concordat Enforcer`). Nine focused deities: Akatosh, Talos, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella.

**Slot-frame correction:** the planning-pass frame listed separate `PDV_Msg_Imperial_Talos_PrivateDefiance_Surface` / `_OpenDefiance_Surface` rows. Private versus open delivery is a presentation variant of the single Talos commitment offer (the offer surfaces privately at Private Defiant), not separate strings; it is folded into the Talos offer's dep-notes rather than authored as its own slot.

### 15.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Akatosh | Imperial, institutional, time-and-law; the Empire's own god; speaks of continuity and the unbroken line; formal. |
| Talos | The forbidden god; speaks low and urgent of conscience against law, of the man who made the Empire; defiant, costly, never safe. |
| Kynareth | Temple-framed weather grace; speaks of road and open sky in a civic Divine register; steadier than the Nord's Kyne. |
| Mara | Civic warmth, the mother of the people; speaks of marriage, household, the bonds that hold a community; kind and public. |
| Zenithar | The merchant's god; plainspoken, honest-trade; speaks of fair weight, the honored contract, the day's work. |
| Arkay | Ceremonial, death-keeping; speaks of the Hall of the Dead, proper burial, the cycle the law must protect; grave and steady. |
| Stendarr | Mercy under civic pressure; speaks of restraint where persecution would be easier; the conscience of the Empire. |
| Julianos | Law, logic, applied wisdom; speaks of the written code, the studied truth, the just judgment; precise. |
| Dibella | Civic grace, beauty, the well-made word; speaks of art and persuasion as public virtue; refined and warm. |

### 15.2 Blessing descriptions (`PDV_Bless_Imperial_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1/2/3 per deity. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Imperial_Akatosh_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Akatosh steadies your civic hours. Your stamina regenerates 5% faster, and your resistance to dragon breath rises by 5%. |
| PDV_Bless_Imperial_Akatosh_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Akatosh rewards the unwavering. Long devotion streaks return bonus piety; dragon-order service scores strongly. |
| PDV_Bless_Imperial_Akatosh_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Akatosh keeps the long order. Unbroken devotion of fourteen days returns a growing dawn blessing of magicka and stamina regeneration; the Amulet of Akatosh doubles its effect. |
| PDV_Bless_Imperial_Talos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Talos answers even the quiet faith. Your shouts recharge 5% faster, and civil war service is felt as worship. |
| PDV_Bless_Imperial_Talos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Talos answers defiance. At Private Defiant, hidden shrines bless deeper; at Open Defiant, devotion gains a further measure. |
| PDV_Bless_Imperial_Talos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Talos marks faith held against the law. Your shouts recharge 15% faster, and Stormcloak ground and defiance return a surge of stamina and health. |
| PDV_Bless_Imperial_Kynareth_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Kynareth shelters the traveler. Your resistance to cold and storms rises by 10%, and your stamina regenerates 5% faster outdoors. |
| PDV_Bless_Imperial_Kynareth_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Kynareth steadies the open way. Outdoor rest fully restores stamina; her shrine cleansing fully restores health. |
| PDV_Bless_Imperial_Kynareth_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Kynareth grants passage. In storm and rain, power attacks cost 10% less stamina; outdoor sleep removes all exposure penalty. |
| PDV_Bless_Imperial_Mara_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Mara counts your kindness. Healing magic is 5% more effective, and your followers recover health faster at your side. |
| PDV_Bless_Imperial_Mara_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Mara holds your household. Marriage and community-restoration work earn extra devotion; her temple grants healing at reduced cost. |
| PDV_Bless_Imperial_Mara_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Mara warms the people's house. Helping a family restores full health on next rest; her temple heals you freely once a week. |
| PDV_Bless_Imperial_Zenithar_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Zenithar weighs honest work. Your honest trades fetch slightly better prices; honest commerce is felt as worship. |
| PDV_Bless_Imperial_Zenithar_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Zenithar honors the finished work. After a major crafting project, your next trade goes favorably. |
| PDV_Bless_Imperial_Zenithar_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Zenithar sanctifies honest work. A crafted item may rise one quality step beyond your perk rank; honest trade steadies your next persuasion. |
| PDV_Bless_Imperial_Arkay_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Arkay marks the keeper of rites. Your resistance to disease rises by 10% and undead deal 5% less harm. |
| PDV_Bless_Imperial_Arkay_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Arkay keeps the death-rites. Completing one restores full health on next rest; undead deal 10% less harm. |
| PDV_Bless_Imperial_Arkay_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Arkay's covenant holds. Undead deal 20% less harm; a completed death-rite restores full health on next rest. |
| PDV_Bless_Imperial_Stendarr_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Stendarr counts the spared hand. Your blocking absorbs 5% more damage; Vigilants of Stendarr stay neutral. |
| PDV_Bless_Imperial_Stendarr_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Stendarr arms the merciful. After mercy chosen in dialogue, the next fight grants an armor boost; Vigilants treat you as a peer. |
| PDV_Bless_Imperial_Stendarr_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Stendarr makes mercy your armor. Sparing a surrendering foe grants 15% damage resistance for the rest of the fight. |
| PDV_Bless_Imperial_Julianos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Julianos weighs your reasoning. Your Novice and Apprentice spells cost 3% less to cast. |
| PDV_Bless_Imperial_Julianos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Julianos rewards study. Skill books return piety; College and law-adjacent work scores. |
| PDV_Bless_Imperial_Julianos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Julianos sharpens applied wisdom. All spells cost 8% less, and a new magic skill rank grants one free cast of that school. |
| PDV_Bless_Imperial_Dibella_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 1" | Passive SPEL | Dibella favors the gracious tongue. Your Speech improves by 5%, and first impressions are warmer. |
| PDV_Bless_Imperial_Dibella_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 2" | Passive SPEL | Dibella carries the right word. After a strong persuasion, the next social check is steadier. |
| PDV_Bless_Imperial_Dibella_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Imperial "Tier 3" | Passive SPEL | Dibella crowns civic grace. After a major persuasion or performance, the next equivalent check succeeds on its own, once a day. |

### 15.3 Tier-up notifications (`PDV_Notif_Imperial_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. The `%s` token binds the deity name. Faithful entry carries `suppress-if-offer-same-dawn`.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Imperial_Observant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "Tier 1" | One per deity per save; %s deity | %s has noticed your civic faith. Observant. |
| PDV_Notif_Imperial_Faithful_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "Tier 2" | One per deity per save; suppress-if-offer-same-dawn | Your standing with %s is steady now. Faithful. |
| PDV_Notif_Imperial_Devoted_Entry | Notification | Marked | Narrator | 80/60 | RaceDesign_Imperial "Tier 3" | One per save; the patron's name | %s knows your name. Devoted. |
| PDV_Notif_Imperial_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "Neglect Texture" | One per deity per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Imperial_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "Neglect Texture" | One per deity per direction per save | The favor of %s is thinning. Observant. |
| PDV_Notif_Imperial_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Imperial "Neglect Texture" | One per save per patron loss | The bond with %s loosens. The Devoted bond is not held. |

### 15.4 ConcordatStanding band crossings (`PDV_Notif_Imperial_Concordat_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Five bands per `RaceDesign_Imperial` "ConcordatStanding Track". Fires on band entry.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Imperial_Concordat_OpenDefiant | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "ConcordatStanding Track" | One per band entry | Open Defiant now. The Thalmor hunt you; Talos answers all the louder. |
| PDV_Notif_Imperial_Concordat_PrivateDefiant | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "ConcordatStanding Track" | One per band entry | Private Defiant now. The Thalmor grow suspicious; Talos hears you. |
| PDV_Notif_Imperial_Concordat_Uncommitted | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "ConcordatStanding Track" | One per band entry | Uncommitted on the Talos question. The Thalmor pass you by. |
| PDV_Notif_Imperial_Concordat_PublicCompliant | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "ConcordatStanding Track" | One per band entry | Public Compliant now. The Thalmor are friendly; Talos grows distant. |
| PDV_Notif_Imperial_Concordat_ConcordatEnforcer | Notification | Noted | Narrator | 80/60 | RaceDesign_Imperial "ConcordatStanding Track" | One per band entry | Concordat Enforcer. Thalmor allied; mercy and the death-rites suffer for it. |

### 15.5 Champion entries (`PDV_Msg_Imperial_*_ChampionEntry`)

God-voice. MessageBox. Body budget 500 hard / 280 target. `Entry-only` for all four: the Imperial Champions are recognition of a held political and civic position, not recurring ambient texture. The four politically-loaded Champions are authored per `PDV_TargetEndStates_1.0.md` lines 230-234.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Imperial_Talos_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 234, 166 | One-time on first Talos Devoted | Title: "Faith Against the Law" Body: "You kept me when keeping me was a crime -- not in a free province, but in the Empire that signed me away. That is the faith I remember. Speak, and the old breath answers." |
| PDV_Msg_Imperial_Stendarr_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 231-232 | One-time on first Stendarr Devoted | Title: "Mercy in Defiance" Body: "A merciful hand is easy in peace. You held it merciful in a province built for persecution. That is the Empire I would have. Wear my restraint as armor." |
| PDV_Msg_Imperial_Akatosh_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates line 232 | One-time on first Akatosh Devoted | Title: "The Unbroken Line" Body: "Empires fall when the line breaks. You did not break. Through war and upheaval your devotion held its hour, day on day. The god of time keeps what keeps faith." |
| PDV_Msg_Imperial_Arkay_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates line 233 | One-time on first Arkay Devoted | Title: "The Death-Covenant" Body: "This province is full of the wrongly dead. You gave them their rites when the war would not. The cycle is honored in you. The Hall of the Dead knows your name." |
| PDV_Msg_Imperial_Kynareth_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Tier 3"; focused-deity champion | One-time on first Kynareth Devoted | Title: "Kynareth's Open Way" Body: "The Empire is bound together by its roads, and you kept faith on them through every storm the province could raise. The sky knows your step now. Walk on, and the weather is on your side." |
| PDV_Msg_Imperial_Mara_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Tier 3"; focused-deity champion | One-time on first Mara Devoted | Title: "The People's Mother" Body: "You mended what the war tore -- households, hearths, the small bonds that hold a province together. Mara is the love that makes a people more than a map. The civic heart is yours to keep, and I keep you within it." |
| PDV_Msg_Imperial_Zenithar_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Tier 3"; focused-deity champion | One-time on first Zenithar Devoted | Title: "The Honest Ledger" Body: "Coin by coin, deal by deal, you kept your weight true while the Empire's own grew crooked. Zenithar asks no miracle, only the honest day done honestly. You have given it, and the work itself blesses you now." |
| PDV_Msg_Imperial_Julianos_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Tier 3"; focused-deity champion | One-time on first Julianos Devoted | Title: "The Measured Mind" Body: "You weighed before you struck and studied before you judged, in a province that rewards neither. Julianos is the order beneath the law, the reason the codes are written at all. The written truth is open to you now. Read deep." |
| PDV_Msg_Imperial_Dibella_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Tier 3"; focused-deity champion | One-time on first Dibella Devoted | Title: "The Gracious Word" Body: "Where others reached for the blade, you found the word that turned the room. Dibella is the grace that makes the Empire worth defending -- beauty, art, the right thing said well. What you give the world, the world gives back to you." |

### 15.6 Neglect texture (`PDV_Notif_Imperial_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Imperial` "Neglect Texture": civic hollowness -- the institutional religion becomes mere performance.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Imperial_Arkay_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial "Arkay neglect" | One per lapse-band crossing | The unburied dead around you feel like a duty you let fall. |
| PDV_Notif_Imperial_Stendarr_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial "Stendarr neglect" | One per lapse-band crossing | Mercy has not been asked of you in a while, nor offered. |
| PDV_Notif_Imperial_Talos_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial "Talos neglect" | One per lapse-band crossing | The hidden shrines are cold stone now. The risk meant something once. |
| PDV_Notif_Imperial_CivicScaffoldingHollow_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial "General neglect" | One per general lapse band per save | The Divines feel like institutions now, not presences. |

### 15.7 Commitment offers (`PDV_Msg_Imperial_*_Offer` and `PDV_Msg_Imperial_OfferResponse_*`)

God-voice on offer bodies; player-second-person on responses. MessageBox. Body budget 500 hard / 280 target; title 40/30. The Talos offer is gated on `ConcordatStanding` per `RaceDesign_Imperial` "Talos commitment gate": normally available only at Uncommitted, Private Defiant, or Open Defiant, and surfaces privately at Private Defiant.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Imperial_Akatosh_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Akatosh's Order" Body: "Your devotion has not wavered through upheaval. Carry the god of time as your own, and the long order becomes your faith. Will you?" |
| PDV_Msg_Imperial_Talos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Talos commitment gate" | Dawn-fire; requires non-compliant ConcordatStanding; surfaces privately at Private Defiant | Title: "Talos Calls the Defier" Body: "You kept faith with me where the law forbade it. Carry the old breath openly, and the Empire's own god answers a treason of conscience. Will you?" |
| PDV_Msg_Imperial_Kynareth_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Kynareth's Road" Body: "The open way has been kind to you. Carry Kynareth as your own, and the road and the sky answer. Will you?" |
| PDV_Msg_Imperial_Mara_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Mara's House" Body: "You have built and mended where you could. Carry the mother of the people as your own, and the civic heart is yours to keep. Will you?" |
| PDV_Msg_Imperial_Zenithar_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Zenithar's Trade" Body: "Your work is honest and your weight is true. Carry the trade-god as your own, and the day's labor becomes worship. Will you?" |
| PDV_Msg_Imperial_Arkay_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Arkay's Covenant" Body: "You have kept the rites the war neglected. Carry Arkay as your own, and the death-cycle is your charge. Will you?" |
| PDV_Msg_Imperial_Stendarr_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Stendarr's Mercy" Body: "You have stayed the killing hand where the province wanted it loosed. Carry Stendarr as your own. Will you?" |
| PDV_Msg_Imperial_Julianos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Julianos' Code" Body: "You study, you weigh, you judge with care. Carry Julianos as your own, and the written truth is your devotion. Will you?" |
| PDV_Msg_Imperial_Dibella_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial "Offer-gate rule" | Dawn-fire; per-deity cooldown | Title: "Dibella's Grace" Body: "You make beauty and speak well where it matters most. Carry Dibella as your own. Will you?" |
| PDV_Msg_Imperial_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Shared across Imperial offers | Accept the patron. |
| PDV_Msg_Imperial_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Sets per-deity cooldown only | Not yet. |
| PDV_Msg_Imperial_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Broad worship continues | Keep to broad worship. |

### 15.8 Survey Devotion readouts (`PDV_Msg_Imperial_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. `%s` tokens bind deity, tier, and ConcordatStanding band as noted per row.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Imperial_Survey_BroadDivines | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 Concordat band | You worship the Nine Divines broadly, civic and public. Standing: %s1. On the Talos question you stand %s2. |
| PDV_Msg_Imperial_Survey_Focused | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 deity, %s2 tier, %s3 Concordat band | %s1 holds your focus among the Nine. Standing: %s2. On the Talos question you stand %s3. |

### 15.9 Contextual favor surfacings

Five trigger families in the Broad Nine Divines lane per `RaceDesign_Imperial` "Contextual Favor Pilot Table". Only `Noted` and `Marked` rows are authored; the honest-work family is `Quiet` and icon-only. Player-second-person on Noted; god-voice on Marked.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Imperial_FavorNoted_MercyRestraint | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial favor table line 81 | Momentary/after-act; meaningful pressure; pay-bounty menu does not count | Mercy chosen under pressure. Stendarr steadies you. |
| PDV_Notif_Imperial_FavorNoted_BurialDuty | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial favor table line 82 | After-act; per Hall-of-the-Dead or anti-necromancy beat | The dead are given their rites. Arkay marks it. |
| PDV_Notif_Imperial_FavorNoted_LawfulOrder | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial favor table line 83 | After-act; concrete order-preserving act, not faction membership | Order kept, the public served. Akatosh is steady with you. |
| PDV_Notif_Imperial_FavorNoted_TalosPressure | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Imperial favor table line 85 | After-act; authored faithful defiance only | A faith kept hidden, at real cost. Talos hears it. |
| PDV_Msg_Imperial_FavorMarked_TalosDefiance | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Imperial favor table line 85 | High-cost defiance only; per-event cooldown | Title: "Talos Notes the Risk" Body: "You stood between the Thalmor and one of mine, in the Empire that outlawed me. That is worship. Carry the old breath a little longer." |

### 15.10 Curse-state transitions (`PDV_Msg_Imperial_CurseState_*`)

MessageBox. Body budget 500 hard / 280 target. **Voice deviation:** all three rows use Narrator voice rather than god-voice. Imperial religion is civic infrastructure, not a single personal patron; the curse messages are institutional statements that no one god speaks. Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Imperial_CurseState_VampireOnset | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Imperial "Vampire"; Race_Imperial "Curse States" | Once on becoming vampire; Divine devotion halts | Title: "The Civic Faith Halts" Body: "You are undead now, and the Nine Divines are a religion of the living community. The civic faith does not bend to accommodate this. It stops. The Concordat no longer touches your soul, only your safety." |
| PDV_Msg_Imperial_CurseState_VampireCured | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Imperial "Vampire" | Once on cure; resumes from lowered floor | Title: "Re-Entry From a Lower Floor" Body: "The undeath is lifted. The Nine Divines are open to you again -- but the civic faith resumes from a lowered floor, not your old standing. The community religion remembers the absence." |
| PDV_Msg_Imperial_CurseState_WerewolfOnset | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Imperial "Werewolf"; Race_Imperial "Curse States" | Once on first transformation | Title: "Homeless Within the Faith" Body: "The beast is in you, and the Nine Divines have no place for it. Your devotion continues, weaker, its civic-facing parts thinned. Hircine offers an Imperial nothing. You are isolated within your own faith." |
| PDV_Msg_Imperial_CurseState_WerewolfCured | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Imperial "Werewolf" | Once on werewolf cure; resumes from lowered floor | Title: "Homecoming Within the Faith" Body: "The beast is set aside. The Nine Divines make room again, and the civic-facing devotion thickens back toward what it was. The community religion notes the absence, as it always does, and resumes from a lowered floor." |

### 15.11 Shrine and privilege dialogue topics (`PDV_Dlog_Imperial_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Four archetypes per the recognition payoffs in `RaceDesign_Imperial`.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Imperial_NineDivinesPriest_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3 | Faithful or above | "I keep the Nine as the Empire keeps them. Speak of the temple's needs." |
| PDV_Dlog_Imperial_HallOfTheDead_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Imperial "Arkay" | Arkay Devoted | "I tend the rites the war forgot. What do the dead here need?" |
| PDV_Dlog_Imperial_VigilantOfStendarr_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Imperial "Stendarr" | Stendarr Devoted | "Stendarr's mercy is mine to carry. Count me among the Vigil." |
| PDV_Dlog_Imperial_LegionOfficer_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Imperial "Akatosh" | Akatosh Devoted; Legion context | "I serve the Empire and its gods both. Where am I needed?" |

### 15.12 Imperial firing-density sanity

A Faithful broad-worship Imperial in steady civic play (Hall of the Dead quests, occasional Thalmor or Talos beat, civil-war decisions):

- Marked: 0 most days; Champion entries and curse onsets are one-time. The Marked Talos defiance favor is high-cost and quest-paced. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (a burial-duty or lawful-order favor, occasional mercy favor). ConcordatStanding band crossings are rare (the band moves on sustained political behavior, and the Uncommitted band is intentionally wide). Inside the `<2 per h` target.
- Quiet: uncounted; icon-only (the honest-work favor family is Quiet).

Tier-up notifications: one per save per deity per direction; Faithful entry suppressed on a same-dawn focus offer.

## 16. Redguard (full draft)

Implementation-locked. Sect-divergent (Crown, Forebear, Ash'abah) within one Yokudan religious universe; ancestor reverence always active. `PDV_State_RedguardSect` with `Crown = 0`, `Forebear = 1`, `AshAbah = 2`.

**Slot-frame corrections:**
- **Blessings: Tier 1 shared, Tier 2 sect-shaped, Tier 3 per focused deity.** The locked `RaceDesign_Redguard` "Tier Rewards" gives Tier 1 a single all-sect record, Tier 2 three sect-shaped records, and Tier 3 per focused deity. The corrected set is ten blessing records: `PDV_Bless_Redguard_Yokudan_T1`, `_Crown_T2` / `_Forebear_T2` / `_AshAbah_T2`, and `_Satakal_T3` / `_Tuwhacca_T3` / `_Ruptga_T3` / `_Leki_T3` / `_Tava_T3` / `_HoonDing_T3`. Onsi and Zeht are minor and have no focused Tier 3 per the locked Tier 3 list.
- **HoonDing make-way folded into contextual favor.** The planning-pass frame listed separate `PDV_Msg_Redguard_HoonDingMakeWay_*` rows. Make-way is authored as the Marked make-way favor rows in Section 16.9 (Crown, Forebear, Ash'abah); the curated milestone hooks (dragon, named boss, final boss, weekly cap) live in those rows' dep-notes.

### 16.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Ancestors (Redguard) | The watching dead; a gravity rather than a voice; present at tombs and death; speak rarely, of how you lived and whether the Far Shores will have you. |
| Satakal | The Worldskin; vast, cyclical; speaks of the shedding, of creation and destruction as one motion, of death as correct when its time has come. |
| Tu'whacca | The guide of souls to the Far Shores; quiet, grave, grateful to those who tend the dead; the gentlest Yokudan voice. |
| Ruptga | Tall Papa, the pathfinder; the first to find the Far Shores; speaks of the way charted and of survival as a sacred achievement. |
| Leki | Saint of the Spirit Sword; disciplined, exact; speaks of the blade as devotion, the honorable cut, the art learned with patience. |
| Tava | The bird-god of wind and passage; speaks of safe arrival, the road carried, the storm steered through. |
| HoonDing | The Make-Way God; surges and does not linger; speaks only in the moment a way is forced where there was none. |

### 16.2 Blessing descriptions (`PDV_Bless_Redguard_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1 shared; Tier 2 sect-shaped; Tier 3 per focused deity. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Redguard_Yokudan_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tier 1" | Passive SPEL; all sects | Satakal's cycle is acknowledged and Tu'whacca's guidance sought. Your resistance to disease rises by 10%; your one-handed attacks strike 3% harder; felling undead returns minor health. |
| PDV_Bless_Redguard_Crown_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tier 2 -- Crown" | Passive SPEL; Crown sect | The Yokudan gods recognize a kept orthodoxy. Honorable combat sharpens your blade for a time; tomb sites draw the ancestors near. |
| PDV_Bless_Redguard_Forebear_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tier 2 -- Forebear" | Passive SPEL; Forebear sect | The Yokudan gods recognize the way made in exile. Surviving hard odds or a long road returns stamina; honored contracts earn Tava's favor. |
| PDV_Bless_Redguard_AshAbah_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tier 2 -- Ash'abah" | Passive SPEL; Ash'abah sect | The Yokudan gods recognize the unclean duty borne. Cleansing a tomb restores full health on next rest; undead deal 15% less harm. |
| PDV_Bless_Redguard_Satakal_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Satakal Champion" | Passive SPEL; Satakal focus | Satakal sheds the Worldskin around you. A quest of cosmic or generational stakes returns a day of fear resistance and health regeneration. |
| PDV_Bless_Redguard_Tuwhacca_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tu'whacca Champion" | Passive SPEL; Tu'whacca focus | Tu'whacca draws the Far Shores nearer. Undead deal up to 25% less harm; a completed death-rite restores full health, and the dead feel present at the tombs. |
| PDV_Bless_Redguard_Ruptga_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Ruptga Champion" | Passive SPEL; Ruptga focus | Ruptga charts your way. Making a path through the impossible returns a day of steady bonus across your disciplines. |
| PDV_Bless_Redguard_Leki_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Leki Champion" | Passive SPEL; Leki focus | Leki makes the blade discipline holy. Your one-handed attacks strike 8% harder, and honorable sword-work returns power-attack stamina. |
| PDV_Bless_Redguard_Tava_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "Tava Champion" | Passive SPEL; Tava focus | Tava rides the wind with you. Storms no longer penalize the open road; sprinting drains 15% less stamina; a long journey's end restores health and stamina. |
| PDV_Bless_Redguard_HoonDing_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Redguard "HoonDing Champion" | Passive SPEL; HoonDing focus | HoonDing makes the way. Once a week, an impossible-odds victory returns a day-long surge of combat strength. |

### 16.3 Tier-up notifications (`PDV_Notif_Redguard_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. The `%s` token binds the deity name. Faithful entry carries `suppress-if-offer-same-dawn`.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Redguard_Observant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Tier 1" | One per deity per save | %s has marked your conduct. Observant. |
| PDV_Notif_Redguard_Faithful_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Tier 2" | One per deity per save; suppress-if-offer-same-dawn | Your standing with %s is steady now. Faithful. |
| PDV_Notif_Redguard_Devoted_Entry | Notification | Marked | Narrator | 80/60 | RaceDesign_Redguard "Tier 3" | One per save; the patron's name | %s knows your name, and your ancestors speak of you. Devoted. |
| PDV_Notif_Redguard_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Neglect Texture" | One per deity per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Redguard_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Neglect Texture" | One per deity per direction per save | The favor of %s is thinning. Observant. |
| PDV_Notif_Redguard_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Redguard "Neglect Texture" | One per save per patron loss | The bond with %s loosens. The Devoted bond is not held. |

### 16.4 Sect entry notifications (`PDV_Notif_Redguard_Sect_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Fires on first-run sect choice or a confirmed sect switch per `RaceDesign_Redguard` "Sect switching locks".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Redguard_Sect_Crown_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Implementation locks" | On confirmed switch into Crown | You hold the Crown way: orthodoxy kept, the old inheritance intact. |
| PDV_Notif_Redguard_Sect_Forebear_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Implementation locks" | On confirmed switch into Forebear | You hold the Forebear way: Redguard identity carried among outsiders. |
| PDV_Notif_Redguard_Sect_AshAbah_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Redguard "Sect switching locks" | On taking up the Ash'abah burden | You take up the Ash'abah duty: the unclean work others will not touch. |

### 16.5 Champion entry and ambient

One sect-level Champion per sect, `Entry + ambient`. God-voice on entries (ancestors for Crown, HoonDing for Forebear, Tu'whacca for Ash'abah); player-second-person on ambients.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Redguard_ChampionEntry_Crown | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Crown Champion" lines 433-435 | One-time on first Crown Devoted | Title: "The Inheritance Kept" Body: "You carried the old way into exile and did not let it thin -- the blade, the bearing, the rites, all intact. The ancestors who died holding Hammerfell see their orthodoxy alive in you." |
| PDV_Notif_Redguard_Crown_ChampionAmbient_Tomb | Notification | Noted | Player-2nd | 80/60 | TargetEndStates "Crown Champion" | Crown Devoted + tomb site; one per in-game day | At the tomb, the ancestors feel close and approving. |
| PDV_Msg_Redguard_ChampionEntry_Forebear | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Forebear Champion" line 436 | One-time on first Forebear Devoted | Title: "The Way Made" Body: "You made a life in a province that was never yours, and stayed Redguard doing it. That is the way-making. The god who held the Alik'r line knows the same quality in you." |
| PDV_Notif_Redguard_Forebear_ChampionAmbient_Road | Notification | Noted | Player-2nd | 80/60 | TargetEndStates "Forebear Champion" | Forebear Devoted + hard passage; per qualifying event | The road yields. HoonDing's way-making is in your step. |
| PDV_Msg_Redguard_ChampionEntry_AshAbah | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Ash'abah Champion" line 437 | One-time on first Ash'abah Devoted | Title: "Burden-Bearer's Grace" Body: "You did the work your own people will not thank you for. You cleansed the unclean dead and bore the stigma. The god of the Far Shores is grateful, even where the living are not." |
| PDV_Notif_Redguard_AshAbah_ChampionAmbient_DeathSite | Notification | Noted | Player-2nd | 80/60 | TargetEndStates "Ash'abah Champion" | Ash'abah Devoted + major tomb or death site; one per in-game day | At the death-site, Tu'whacca's presence is close. |

### 16.6 Neglect texture (`PDV_Notif_Redguard_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Redguard` "Neglect Texture": the ancestor layer and sect frame quieting, not punishment. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Redguard_AncestorLayer_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard "Ancestor layer neglect" | One per lapse-band crossing | You have handled the dead carelessly. The Far Shores seem further away. |
| PDV_Notif_Redguard_Crown_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard "Crown neglect" | One per lapse-band crossing; Crown sect | Yokudan practice has slid into Divines convenience. The orthodoxy thins. |
| PDV_Notif_Redguard_Forebear_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard "Forebear neglect" | One per lapse-band crossing; Forebear sect | You have taken only the easy road. HoonDing does not notice the safe. |
| PDV_Notif_Redguard_AshAbah_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard "Ash'abah neglect" | One per lapse-band crossing; Ash'abah sect | The undead duty goes unmet. The burden is just weight now, unhonored. |

### 16.7 Commitment offers (`PDV_Msg_Redguard_*_Offer` and `PDV_Msg_Redguard_OfferResponse_*`)

God-voice on offer bodies; player-second-person on responses. MessageBox. Body budget 500 hard / 280 target; title 40/30. Sect filters which deities offer and how, per `RaceDesign_Redguard` "Focused deity gate".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Redguard_Satakal_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "Satakal's Cycle" Body: "You have lived as one who knows the Worldskin sheds. Carry Satakal as your own, and the great cycle becomes your devotion. Will you?" |
| PDV_Msg_Redguard_Tuwhacca_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "Tu'whacca's Charge" Body: "You tend the dead and turn back the undead. Carry Tu'whacca as your own, and the guidance of souls to the Far Shores is your charge. Will you?" |
| PDV_Msg_Redguard_Ruptga_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "Ruptga's Path" Body: "You have made ways and charted survival. Carry Ruptga, Tall Papa, as your own, and the path itself becomes your faith. Will you?" |
| PDV_Msg_Redguard_Leki_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "Leki's Blade" Body: "Your sword-work is disciplined and honest. Carry Leki as your own, and the blade becomes devotion made exact. Will you?" |
| PDV_Msg_Redguard_Tava_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "Tava's Wind" Body: "The road has carried you far, and you have carried it well. Carry Tava as your own, and the wind of good passage is yours. Will you?" |
| PDV_Msg_Redguard_HoonDing_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Focused deity gate" | Dawn-fire; per-deity cooldown | Title: "HoonDing's Call" Body: "Again and again you have made a way where there was none. Carry the Make-Way God as your own, and the impossible passage becomes your devotion. Will you?" |
| PDV_Msg_Redguard_OfferResponse_Accept | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Shared across Redguard offers | Walk under this god. |
| PDV_Msg_Redguard_OfferResponse_NotYet | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Sets per-deity cooldown only | Not yet. |
| PDV_Msg_Redguard_OfferResponse_Refuse | MessageBox | Marked | Player-2nd | 40/30 | Architecture v3 Section 12.3 | Broad sect worship continues | Keep to the sect's broad worship. |

### 16.8 Survey Devotion readouts (`PDV_Msg_Redguard_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One row per sect; `%s` binds the tier name.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Redguard_Survey_Crown | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You keep the Crown way: orthodox Yokudan practice carried intact in exile. Standing: %s. The ancestors are strong at your back. |
| PDV_Msg_Redguard_Survey_Forebear | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You keep the Forebear way: Redguard identity lived among outsiders. Standing: %s. The road and the contract are your proving ground. |
| PDV_Msg_Redguard_Survey_AshAbah | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You keep the Ash'abah duty: the unclean dead are your charge. Standing: %s. Tu'whacca honors the burden few will. |

### 16.9 Contextual favor surfacings

Four trigger families per sect per `RaceDesign_Redguard` "Contextual Favor Pilot Table". Only `Noted` and `Marked` rows are authored; the Crown sacred-martial-bearing family is `Quiet` and icon-only. Player-second-person on Noted; god-voice on Marked. The three Marked make-way favors carry the curated HoonDing milestone hooks (dragon, named boss, final boss; weekly cap) in their dep-notes.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Redguard_FavorNoted_Crown_TombRespect | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Crown favor table line 93 | Environmental/after-act; per site, not repeat visits | The ancestors are close at this tomb. Orthodoxy carried in exile. |
| PDV_Notif_Redguard_FavorNoted_Crown_YokudanForm | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Crown favor table line 94 | After-act; curated Yokudan-form hooks | You kept Yokudan form where Divines convenience beckoned. Counted. |
| PDV_Msg_Redguard_FavorMarked_Crown_MakeWay | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard Crown favor table line 95; "Crown make-way rule" | Rare major; honorable adversity only; curated milestone, weekly cap | Title: "Sacred Survival" Body: "You came through honorable adversity that should have ended you. Ruptga charted such ways first, and HoonDing forces them still. The Far Shores draw a little nearer." |
| PDV_Notif_Redguard_FavorNoted_Forebear_RoadPassage | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Forebear favor table line 101 | Environmental; reject fast travel | The road carried you well. Tava's wind was with the journey. |
| PDV_Notif_Redguard_FavorNoted_Forebear_HonoredContract | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Forebear favor table line 102 | After-act; honored contract, not gold-making | A contract honored under pressure. Pragmatic honor, and it counts. |
| PDV_Notif_Redguard_FavorNoted_Forebear_RespectfulBridge | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Forebear favor table line 104 | After-act; identity kept while cooperating | You cooperated with outsiders and stayed Redguard doing it. |
| PDV_Msg_Redguard_FavorMarked_Forebear_MakeWay | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard Forebear favor table line 103 | Rare major; impossible-odds only; curated milestone, weekly cap | Title: "The Way Forced" Body: "Severely outmatched, and still you made a way through. That is my whole nature. The god who held the Dominion back is in your step." |
| PDV_Notif_Redguard_FavorNoted_AshAbah_UndeadCleansing | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Ash'abah favor table line 110 | After-act; per site/boss, not repeat farm | The unclean dead are put to rest. Tu'whacca marks the work. |
| PDV_Notif_Redguard_FavorNoted_AshAbah_HallBurialDuty | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Ash'abah favor table line 111 | After-act; per hold/quest | The burial duty is kept. The burden is bearable when honored. |
| PDV_Notif_Redguard_FavorNoted_AshAbah_ImpurityBorne | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard Ash'abah favor table line 112 | After-act; ordinary impurity-bearing | You bore the duty no one else would touch. It is seen. |
| PDV_Msg_Redguard_FavorMarked_AshAbah_ImpurityBorne | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard Ash'abah favor table line 112; "Ash'abah marking rule" | Marked only for costly burden moments | Title: "The Burden Honored" Body: "You did the work your own people recoil from, and you paid its cost in their eyes. I do not recoil. The Far Shores keep a place for the burden-bearer." |
| PDV_Msg_Redguard_FavorMarked_AshAbah_HardPassage | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard Ash'abah favor table line 113 | Rare major; major tomb or named undead boss; weekly cap | Title: "A Way Through the Unclean" Body: "You cut a path through ritual uncleanness that would have turned anyone else back. The way is made. The dead behind you can rest." |

### 16.10 Tu'whacca portable token (`PDV_Notif_Redguard_FarShoresToken_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Redguard` "Tu'whacca devotional surface": a permanent portable Far Shores token. V1 ships without the previously drafted private/home bonus context; player-facing copy addresses Tu'whacca, never Arkay.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Redguard_FarShoresToken_Activate | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Redguard "Tu'whacca devotional surface" | Per token use; daily cap on the favor it feeds | You tend the Far Shores token and speak to Tu'whacca. |

### 16.11 Curse-state transitions (`PDV_Msg_Redguard_CurseState_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Redguard` "Curse State Summary": vampirism is near-total collapse with a Tu'whacca-first cure re-entry; werewolf is strained, not severed. Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Redguard_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Vampire" | Once on becoming vampire; devotion collapses across all sects | Title: "Outside the Cycle" Body: "You are undead now, and undeath is a soul that has left the cycle I guide. The Far Shores cannot receive you while the curse holds. Devotion across all three sects falls quiet. Cure this, and return to me first." |
| PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Vampire recovery note" line 211 | Once on cure; Tu'whacca re-entry precedes other devotion | Title: "Right Re-Entry" Body: "The curse is lifted. Come back through me before any other god -- proper mortality, ancestor order, the right return to the cycle. When that is done, the Far Shores are open, and your sect may have you again." |
| PDV_Msg_Redguard_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Werewolf"; Race_Redguard "Curse States" | Once on first transformation; strained, not severed | Title: "Strained, Not Severed" Body: "The beast is in you. The Yokudan gods and your sect remain within reach, but strained -- Hircine is an intrusion, not a home. The ancestors do not turn away. They only watch more closely." |
| PDV_Msg_Redguard_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Redguard "Werewolf" | Once on werewolf cure; strain lifts | Title: "The Strain Lifts" Body: "The beast is set down. The strain eases, and the Yokudan gods and your sect come back into full reach. Hircine's intrusion is ended. The ancestors, who only watched more closely, ease their gaze. Wholly theirs again." |

### 16.12 Shrine and privilege dialogue topics (`PDV_Dlog_Redguard_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three archetypes grounded in Redguard death-duty and diaspora.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Redguard_AlikR_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Redguard "Alik'r ... diaspora" | Faithful or above | "I keep the Yokudan way as the Alik'r kept Hammerfell. What is needed?" |
| PDV_Dlog_Redguard_HallOfTheDead_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Redguard "Hall of the Dead duty" | Tu'whacca Devoted or Ash'abah sect | "I tend the dead for Tu'whacca. What restless ones are here?" |
| PDV_Dlog_Redguard_TombKeeper_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Redguard "Ash'abah" | Ash'abah Devoted | "The unclean dead are my charge. Tell me what walks here." |

### 16.13 Redguard firing-density sanity

A Faithful Ash'abah Redguard in steady death-duty play (draugr crypts, Hall of the Dead quests, occasional necromancer operation):

- Marked: 0 most days; Champion entries and curse onsets are one-time, and the Marked make-way and impurity favors are weekly-capped or costly-burden-gated. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (an undead-cleansing favor, occasional burial-duty favor, Far Shores token use). Inside the `<2 per h` target.
- Quiet: uncounted; icon-only (the Crown sacred-martial-bearing favor family is Quiet).

Tier-up notifications: one per save per deity per direction; Faithful entry suppressed on a same-dawn focus offer. Sect entry notifications are gated to confirmed switches with a two-day destination proof, so they cannot fire repeatedly.

## 17. Bosmer (full draft)

Implementation-locked. Four-path divergence: Old Contract (Y'ffre orthodox), Living Story (Y'ffre moderate), Exchange (Z'en), Bandit Road (Baan Dar). `PDV_State_BosmerPath` with `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`.

**Slot-frame corrections:**
- **Blessings are per-path, not per-deity.** The locked `RaceDesign_Bosmer` "Tier Rewards" gives each of the four paths its own Tier 1/2/3. Old Contract and Living Story are both Y'ffre but materially different. The corrected set is twelve blessing records: `PDV_Bless_Bosmer_<OldContract|LivingStory|Exchange|BanditRoad>_T<1|2|3>`. Arkay/Xarxes/Mara/Stendarr are a background secondary layer with no separate blessing records.
- **No commitment offer.** The path setup choice is the commitment; Tier 3 is reached through continued focused devotion within the path. No god-voice offer beat is authored, so Faithful tier-up carries no `suppress-if-offer-same-dawn` flag.
- **Erroneous "Green Way Druidic Trial" slot removed.** Green Way is a Breton tradition, not a Bosmer path. The Bosmer werewolf treatment is per-path and is authored in the curse-state section.

### 17.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Y'ffre | The Earth-Bones, the Storyteller; speaks of the covenant, of form held by the Now, of the Green Pact's terms; ancient, exact, and -- on the Old Contract -- unbending. |
| Z'en | The god of payment in kind; speaks of debt, balance, the account settled; precise rather than vengeful; nothing is free. |
| Baan Dar (Bosmer) | The Bandit God, the exile's trickster; desperate cleverness, not polished crime; speaks warm to pariahs of the improbable survival. |

### 17.2 Blessing descriptions (`PDV_Bless_Bosmer_*`)

Narrator voice. Budget 200 hard / 140 target. Per path, Tier 1/2/3. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Bosmer_OldContract_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- Old Contract" | Passive SPEL; Old Contract path | The Green Pact is kept. Your archery strikes 3% harder; your resistance to poison rises by 15%; your daggers cut 2% deeper. |
| PDV_Bless_Bosmer_OldContract_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- Old Contract" | Passive SPEL; Old Contract path | Y'ffre answers the kept covenant. Hunting kills restore stamina; animals never flee unprovoked. At Strict compliance, devotion gains a fifth again. |
| PDV_Bless_Bosmer_OldContract_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- Old Contract" | Passive SPEL; Old Contract path | Y'ffre's Mark is on you. In forest and wild, your archery strikes 8% harder; animals never flee; the first arrow of a hunt strikes true and deep. |
| PDV_Bless_Bosmer_LivingStory_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Living Story" | Passive SPEL; Living Story path | The Story is carried. Your Speech improves by 5%; your stamina regenerates 5% faster outdoors; your resistance to poison rises by 10%. |
| PDV_Bless_Bosmer_LivingStory_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Living Story" | Passive SPEL; Living Story path | Y'ffre and the secondary gods answer the diaspora faith. Community acts return piety; nature sites and outdoor combat steady you. |
| PDV_Bless_Bosmer_LivingStory_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Living Story" | Passive SPEL; Living Story path | You carry the Story itself. Your Speech improves by 10%, and preserving a community or tradition returns a day of broadened skill. The dialogue of memory opens to you. |
| PDV_Bless_Bosmer_Exchange_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Exchange" | Passive SPEL; Exchange path | Z'en weighs your dealings. Your Barter improves by 5%; merchant prices improve; defending against a first-striker returns minor health. |
| PDV_Bless_Bosmer_Exchange_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Exchange" | Passive SPEL; Exchange path | Z'en answers the settled account. Proportionate vengeance grants a day of stronger weapons; honored debts and fair trade return piety. |
| PDV_Bless_Bosmer_Exchange_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Exchange" | Passive SPEL; Exchange path | Balance is restored through you. A debt settled or a wrong redressed returns a day of stronger skill growth; proportionate kills return stamina. |
| PDV_Bless_Bosmer_BanditRoad_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Bandit Road" | Passive SPEL; Bandit Road path | The road teaches you. Your Pickpocket improves by 5%; your Sneak improves by 3%; a night slept outdoors sharpens the next day's first stealth. |
| PDV_Bless_Bosmer_BanditRoad_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Bandit Road" | Passive SPEL; Bandit Road path | Baan Dar answers the exile. Surviving severe odds returns a burst of stamina; road-life scores; outcasts deal with you kindly. |
| PDV_Bless_Bosmer_BanditRoad_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Bosmer "Tier Rewards -- The Bandit Road" | Passive SPEL; Bandit Road path | Baan Dar's luck is yours. Once a week, a survival you should not have had returns a day-long pulse of fortune; the wild road weighs heavier than the city. |

### 17.3 Tier-up notifications (`PDV_Notif_Bosmer_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. The `%s` token binds the path's deity (Y'ffre, Z'en, or Baan Dar). No `suppress-if-offer-same-dawn` flag: Bosmer has no commitment offer.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Bosmer_Observant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Tier Rewards" | One per path per save; %s deity | %s has noticed your path. Observant. |
| PDV_Notif_Bosmer_Faithful_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Tier Rewards" | One per path per save | Your standing with %s is steady now. Faithful. |
| PDV_Notif_Bosmer_Devoted_Entry | Notification | Marked | Narrator | 80/60 | RaceDesign_Bosmer "Tier Rewards" | One per save | %s knows your name. Devoted. |
| PDV_Notif_Bosmer_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Neglect Texture" | One per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Bosmer_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Neglect Texture" | One per direction per save | The favor of %s is thinning. Observant. |
| PDV_Notif_Bosmer_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Bosmer "Neglect Texture" | One per save per Devoted loss | The bond with %s loosens. The Devoted bond is not held. |

### 17.4 Champion entries (`PDV_Msg_Bosmer_ChampionEntry_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. `Entry-only` for all four paths; the path's ongoing texture is gameplay (the hunt, the Story dialogue, the settled account, the weekly luck) rather than authored ambient lines.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Bosmer_ChampionEntry_OldContract | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Old Contract Champion" line 398 | One-time on first Old Contract Devoted | Title: "Y'ffre's Mark" Body: "You kept the Pact in exile, where no warden watched and no forest enforced it. You kept it because it is true, not because it is law. The covenant is fully yours, and the wild knows you for its own." |
| PDV_Msg_Bosmer_ChampionEntry_LivingStory | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Living Story Champion" line 399 | One-time on first Living Story Devoted | Title: "The Story Carried" Body: "The forest could not follow you here, so you carried the Story instead -- in memory, in community, in the telling. Y'ffre is the Now held by narrative. You hold a piece of it." |
| PDV_Msg_Bosmer_ChampionEntry_Exchange | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Exchange Champion" line 400 | One-time on first Exchange Devoted | Title: "The Account Clean" Body: "Debt by debt, wrong by wrong, you have kept the world even. Nothing free, nothing owed, nothing left unpaid. Z'en's balance runs through you now." |
| PDV_Msg_Bosmer_ChampionEntry_BanditRoad | MessageBox | Marked | God-voice | 500/280 | TargetEndStates "Bandit Road Champion" line 401 | One-time on first Bandit Road Devoted | Title: "The Story by the Fire" Body: "You are the one who should not have made it -- and did, and again, and again. That is the story exiles tell in the dark. Baan Dar writes those stories, and you are in his book." |

### 17.5 Path setup and entry (`PDV_Msg_Bosmer_PathChoice_Setup`, `PDV_Notif_Bosmer_Path_*`)

The setup prompt is narrator voice (a MessageBox presenting the four-path choice). Path entry notifications are narrator voice. Per `RaceDesign_Bosmer` "Path switching locks": first-run choice is free; later switching is destination-gated.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Bosmer_PathChoice_Setup | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Bosmer "Worship Structure"; TargetEndStates line 393 | First-run setup; one-time | Title: "The Covenant in Exile" Body: "Y'ffre made a covenant with the Bosmer. In Skyrim, far from Valenwood's enforcement, you must decide what you still carry of it. Choose your path: the Old Contract, the Living Story, the Exchange, or the Bandit Road." |
| PDV_Notif_Bosmer_Path_OldContract_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Path implementation locks" | On confirmed entry into Old Contract | You walk the Old Contract. The Green Pact is yours to keep, in full. |
| PDV_Notif_Bosmer_Path_LivingStory_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Path implementation locks" | On confirmed entry into Living Story | You walk the Living Story. The covenant lives in memory and community. |
| PDV_Notif_Bosmer_Path_Exchange_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Path implementation locks" | On confirmed entry into Exchange | You walk the Exchange. The world should be even, and you keep it so. |
| PDV_Notif_Bosmer_Path_BanditRoad_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "Path implementation locks" | On confirmed entry into Bandit Road | You walk the Bandit Road. The exile's road is your theology now. |

### 17.6 Old Contract forced reckoning (`PDV_Msg_Bosmer_OldContract_*`)

The forced-reckoning confrontation is god-voice (Y'ffre), a MessageBox with the recommit/renounce choice. The responses are player-second-person. The terminal message is god-voice. Per `RaceDesign_Bosmer` "Forced reckoning" and "One cycle, then the door closes".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Bosmer_OldContract_ForcedReckoning_Confront | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Forced reckoning"; TargetEndStates line 408 | Fires after three consecutive in-game days at Apostate | Title: "Y'ffre Confronts You" Body: "Three days you have stood Apostate to the Pact we made. I will not let it fade in silence. Recommit, and the covenant holds. Renounce, and it is set down. Choose. There is no third answer." |
| PDV_Msg_Bosmer_OldContract_ForcedReckoning_Recommit | MessageBox | Marked | Player-2nd | 40/30 | RaceDesign_Bosmer "Forced reckoning" | Recommit; GreenPactCompliance snaps to 30 | Recommit to the Pact. |
| PDV_Msg_Bosmer_OldContract_ForcedReckoning_Renounce | MessageBox | Marked | Player-2nd | 40/30 | RaceDesign_Bosmer "Forced reckoning" | Renounce; first renunciation allows one re-entry | Renounce the Pact. |
| PDV_Msg_Bosmer_OldContract_Terminal | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "One cycle, then the door closes"; TargetEndStates line 411 | Fires on second renunciation; Y'ffre ledger frozen permanently | Title: "The Door Closes" Body: "You have set the Pact down a second time. There is no third taking-up. Y'ffre's ledger is closed to you now, and stays closed. The other Bosmer gods remain -- but the covenant is over." |

### 17.7 Green Pact compliance band feedback (`PDV_Notif_Bosmer_GreenPact_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Old Contract path only. Bands per `RaceDesign_Bosmer` "GreenPactCompliance State Model". Fires on band entry. (Per-item plant-consumption feedback stays gated per Architecture v3 Section 21.2 until the Green Pact tag layer ships -- see Section 21.)

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Bosmer_GreenPact_Apostate | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model" | One per band entry | Compliance fallen to Apostate. Y'ffre's favor is locked; the reckoning begins. |
| PDV_Notif_Bosmer_GreenPact_Lapsed | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model" | One per band entry | Compliance has slipped to Lapsed. Y'ffre's favor comes at half. |
| PDV_Notif_Bosmer_GreenPact_Observant | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model" | One per band entry | Compliance restored to Observant. Y'ffre's favor flows full again. |
| PDV_Notif_Bosmer_GreenPact_Strict | Notification | Noted | Narrator | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model" | One per band entry | Compliance risen to Strict. Y'ffre's favor flows a fifth again stronger. |

### 17.7a Green Pact per-item violation feedback (prose drafted; MECHANICS-BLOCKED)

**Mechanics dependency:** requires the PDV-owned Green Pact tag layer (Architecture v3 Section 21.2 essential custom content) that intercepts plant-item consumption events and decrements `GreenPactCompliance`. The tag layer must ship before these rows can fire. Prose is authored here so Phase 20 content-lock is not blocked on implementation.

Narrator / God-voice per row. Budget per column. Old Contract path only. Anti-spam gating: cooldown window (exact window set by implementation) prevents rapid-fire from looting a chest. The Marked row fires only on deliberate curated violations.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Bosmer_GreenPact_PlantConsumed | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model"; Architecture v3 Section 21.2 | MECHANICS-BLOCKED: tag layer required. Per tagged plant item consumed; cooldown window set by implementation | Plant flesh consumed. The Pact holds the count. |
| PDV_Notif_Bosmer_GreenPact_PlantConsumed_NearBand | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "GreenPactCompliance State Model"; Architecture v3 Section 21.2 | MECHANICS-BLOCKED: tag layer required. Fires when within implementation-defined threshold of the next downward band crossing | Another plant consumed. Compliance approaches the next fall. |
| PDV_Msg_Bosmer_GreenPact_PlantConsumed_Marked | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "GreenPactCompliance State Model"; Architecture v3 Section 21.2 | MECHANICS-BLOCKED: tag layer required. Fires on deliberate curated high-value plant consumption (ingredient hooks, not incidental food); per-event cooldown | Title: "The Pact Remembers" Body: "You ate from the living world. The Pact does not argue with the hunger; it holds the record. Each plant consumed is a mark against the covenant. The count is yours to weigh; Y'ffre weighs it already." |

### 17.8 Neglect texture (`PDV_Notif_Bosmer_*_NeglectTexture`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Bosmer` "Neglect Texture", one per path. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Bosmer_OldContract_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Old Contract neglect" | One per lapse-band crossing | The Pact is slipping, and you can feel the reckoning coming. |
| PDV_Notif_Bosmer_LivingStory_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Living Story neglect" | One per lapse-band crossing | The oral tradition dries up. You have stopped carrying the Story. |
| PDV_Notif_Bosmer_Exchange_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Exchange neglect" | One per lapse-band crossing | Debts go unpaid and unnoticed. The world's balance ignores you. |
| PDV_Notif_Bosmer_BanditRoad_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Bandit Road neglect" | One per lapse-band crossing | Baan Dar's luck has gone dormant. The road is just hardship now. |

### 17.9 Survey Devotion readouts (`PDV_Msg_Bosmer_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One row per path; `%s` binds the tier name (and the compliance band for Old Contract).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Bosmer_Survey_OldContract | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 compliance band | You walk the Old Contract, the Green Pact kept in full. Standing: %s1. Compliance: %s2. Y'ffre holds you to the terms. |
| PDV_Msg_Bosmer_Survey_LivingStory | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You walk the Living Story, the covenant carried in memory and community. Standing: %s. The Story passes through you. |
| PDV_Msg_Bosmer_Survey_Exchange | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You walk the Exchange, the world kept even debt by debt. Standing: %s. Z'en weighs your account. |
| PDV_Msg_Bosmer_Survey_BanditRoad | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion | You walk the Bandit Road, the exile's theology of the open road. Standing: %s. Baan Dar favors the improbable. |

### 17.10 Contextual favor surfacings

Four trigger families, formalized from `RaceDesign_Bosmer` per-path Tier Rewards and Signal Examples. **Old Contract** (proper hunt, forest kept against desecration); **Living Story** (community preserved, nature-site presence); **Exchange** (debt honored, proportionate redress); **Bandit Road** (road-life, pariah solidarity, near-fatal reversal). Player-second-person on Noted; god-voice on Marked. The Bandit Road reversal is a `Rare major favor` per `PDV_TargetEndStates_1.0.md` line 112.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Bosmer_FavorNoted_OldContract_ProperHunt | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- Old Contract"; Signal Examples | After-act; daily cap; proper hunting conduct | A clean hunt, the Pact honored. Y'ffre's wild answers. |
| PDV_Notif_Bosmer_FavorNoted_OldContract_ForestKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Old Contract"; Race_Bosmer "Old Contract" | After-act; anti-desecration beat | You turned back desecration of the living world. Counted. |
| PDV_Notif_Bosmer_FavorNoted_LivingStory_CommunityKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- The Living Story" | After-act; non-trivial preservation | Something preserved, something remembered. The Story holds. |
| PDV_Notif_Bosmer_FavorNoted_LivingStory_NatureSite | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- The Living Story" | Environmental; per site, daily cap | At the grove, Y'ffre's presence is quiet and near. |
| PDV_Notif_Bosmer_FavorNoted_Exchange_DebtSettled | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- The Exchange" | After-act; honored debt or contract | A debt paid, an account made even. Z'en is satisfied. |
| PDV_Notif_Bosmer_FavorNoted_Exchange_ProportionateVengeance | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- The Exchange" | After-act; redress quest, proportionate only | The wrong is redressed, no more and no less. Balance. |
| PDV_Notif_Bosmer_FavorNoted_BanditRoad_RoadLife | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier Rewards -- The Bandit Road" | Environmental; road-life acts; daily cap | The road keeps you. Baan Dar favors the wandering exile. |
| PDV_Notif_Bosmer_FavorNoted_BanditRoad_PariahSolidarity | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Bosmer "Tier 3 -- The Bandit Road" | After-act; aiding other outcasts | You stood by another outcast. Baan Dar marks his own. |
| PDV_Msg_Bosmer_FavorMarked_BanditRoad_Reversal | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Bandit Road Champion"; TargetEndStates line 112 (rare major favor) | Weekly cap; near-death survival or impossible escape only | Title: "Baan Dar's Luck" Body: "You should not have walked away from that. You did. That is the story they will tell about you in the dark, around the fire. I gave you the ending." |

### 17.11 Curse-state transitions (`PDV_Msg_Bosmer_CurseState_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Bosmer` "Curse State Summary": vampirism breaks the Old Contract's PactBound immediately and strains the other paths; werewolfism is a serious Old Contract violation but contested strain elsewhere. The per-path difference is carried in one body each rather than separate path rows. Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Bosmer_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Vampire" | Once on becoming vampire | Title: "The Covenant and the Undead" Body: "You are undead now. The living covenant does not reach the unliving. On the Old Contract the Pact breaks at once; on the other paths the bond strains hard but holds by a thread. Y'ffre is the Now, and you have stepped outside it." |
| PDV_Msg_Bosmer_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Vampire" | Once on cure | Title: "Back Within the Now" Body: "The undeath is lifted. You stand within the living world again, and your path is open -- though the Old Contract, broken this way, must be retaken like any lapse." |
| PDV_Msg_Bosmer_CurseState_WerewolfOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Werewolf by path" | Once on first transformation | Title: "The Hunt Without Sanction" Body: "The beast is in you. It echoes the Wild Hunt, so Bosmer theology can read it -- but it is not Y'ffre's sanction. On the Old Contract this is a serious violation; on the other paths, contested strain. The shape is intelligible. It is not approved." |
| PDV_Msg_Bosmer_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Bosmer "Werewolf by path" | Once on werewolf cure; Old Contract retaken like a lapse | Title: "The Hunt Set Down" Body: "The beast is set down. The unsanctioned shape leaves you, and you stand within Y'ffre's Now again. On the Old Contract the violation must be retaken like any lapse; on the other paths the strain simply eases. The Now holds." |

### 17.12 Shrine and privilege dialogue topics (`PDV_Dlog_Bosmer_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Two archetypes; Y'ffre has no Skyrim shrine, so the Kynareth shrine serves as the proxy per `RaceDesign_Bosmer` Implementation Notes.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Bosmer_YffreShrine_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Bosmer Implementation Notes | Old Contract or Living Story path | "Y'ffre's covenant is mine to carry. I keep it where Kynareth's shrine stands." |
| PDV_Dlog_Bosmer_BosmerElder_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Bosmer "The Living Story" | Faithful or above | "I carry the Story for our people in exile. What must be remembered here?" |

### 17.13 Bosmer firing-density sanity

A Faithful Living Story Bosmer in steady community play (preservation quests, nature-site visits, secondary-god acts):

- Marked: 0 most days; Champion entries, the path-setup choice, the forced-reckoning confrontation, and curse onsets are all one-time, and the Bandit Road reversal favor is weekly-capped. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (a community-kept favor, an occasional nature-site favor). Green Pact band crossings (Old Contract only) are infrequent because the meter is act-driven with no passive decay. Inside the `<2 per h` target.
- Quiet: uncounted; icon-only.

Tier-up notifications: one per save per direction. There is no commitment offer, so no Faithful suppression rule applies. Path-entry notifications are gated to confirmed switches with the seven-day switch lock-out, so they cannot fire repeatedly.

## 18. Breton (full draft)

Implementation-locked. The most mechanically complex race: three-tradition divergence (Knight's Road, Hidden Art, Green Way) plus three parallel tracks. `PDV_State_BretonTradition` with `KnightsRoad = 0`, `HiddenArt = 1`, `GreenWay = 2`. Tracks: `KnightlyVowIntegrity`, `WitchcraftExposure`, `DruidicStanding` (paired with `PDV_State_BretonDruidicFork`).

**Slot-frame corrections:**
- **Blessings: per-tradition Tier 1/2, per-deity Tier 3.** The locked `RaceDesign_Breton` "Tier Rewards" gives each tradition its own Tier 1 and Tier 2, then per-focused-deity Tier 3. The corrected set is sixteen blessing records: `_KnightsRoad_T1` / `_T2`, `_HiddenArt_T1` / `_T2`, `_GreenWay_T1` / `_T2`, and ten Tier 3 records (Stendarr, Akatosh, Mara; Hermaeus Mora, Hircine, Nocturnal, Namira; Y'ffre, Magnus, Phynaster).
- **Focused deity uses emergence, not a bespoke offer suite.** `RaceDesign_Breton` line 33 references "patron offers" within the tradition, while `PDV_TargetEndStates_1.0.md` line 252 says "focused deity emphasis emerges". With ten possible focused deities across three traditions, the manifest reconciles these by treating the tradition setup as the headline commitment and the focused deity as an emergence within the tradition, surfaced by one templated notification (Section 18.5). This matches the `n/a (tradition setup)` coverage marking. Authoring ten bespoke per-deity offer MessageBoxes is a possible later refinement, noted but not in this pass.
- **Champion entries are tradition-level (3), not per-deity.** `RaceDesign_Breton` writes one "Champion moment for [tradition]" per tradition.
- **Vigilant pressure encounter is authored** (Section 18.14) for the Phase 20 content lock.

### 18.1 Tone profiles

| Voice | Tone profile |
|---|---|
| Knight's Road | Chivalric, civic, oath-bound; speaks of the vow kept, of mercy and justice, of protection given without reward; earnest. |
| Hidden Art | Occult, double-lived, conspiratorial; speaks low of the practice concealed or the rupture declared; the patron's voice is hungry and precise. |
| Green Way | Druidic, covenantal, outdoor; speaks of the standing stones, the living world, the old knowledge Bretons still half-hear; quiet. |
| Stendarr | Mercy and the protective shield; speaks of the vow, the spared, the defended; stern but warm. |
| Akatosh | Time, order, the unbroken streak; speaks of continuance and the long-kept faith; formal. |
| Mara | Hearth and community; speaks of the family held and the home restored; warm. |
| Y'ffre (Breton Green Way) | The Earth-Bones as the druids half-remember; speaks of the covenant, the stone circle, the forest taught to know you; gentle, old. |
| Magnus | The Elder Way, magic as discipline; speaks of the arts mastered and the architecture of the spell; precise. |
| Phynaster | Longevity and the elven inheritance; speaks of the long life and the magic in half-elven blood; measured. |
| Hidden Art patrons | Hermaeus Mora, Hircine, Nocturnal, and Namira each speak in the Hidden Art register, sharpened to their domain: knowledge priced, the hunt, the shadow, the corruption named. |

### 18.2 Blessing descriptions (`PDV_Bless_Breton_*`)

Narrator voice. Budget 200 hard / 140 target. Per tradition Tier 1/2; per focused deity Tier 3. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Breton_KnightsRoad_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Knight's Road" | Passive SPEL; Knight's Road | The vow is kept. Your magic resistance rises by 5%, and defending an NPC in combat grants 20 more maximum health for a time. |
| PDV_Bless_Breton_KnightsRoad_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Knight's Road" | Passive SPEL; Knight's Road | Stendarr and the Divines answer the knight. Mercy and unrewarded aid arm the next fight; high Integrity steadies your block. |
| PDV_Bless_Breton_HiddenArt_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Hidden Art" | Passive SPEL; Hidden Art | The hidden practice answers. Novice and Apprentice spells cost 5% less; magic regenerates faster at night. |
| PDV_Bless_Breton_HiddenArt_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Hidden Art" | Passive SPEL; Hidden Art | Your patron rewards the occult work. Daedric shrines and rituals sharpen your magic; at Notorious, devotion gains a quarter again. |
| PDV_Bless_Breton_GreenWay_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Green Way" | Passive SPEL; Green Way | The old covenant stirs. Your resistance to poison rises by 10%, and foraging yields an extra harvest. |
| PDV_Bless_Breton_GreenWay_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Tier Rewards -- Green Way" | Passive SPEL; Green Way | Y'ffre answers the druid. Outdoor sleep restores stamina and half your missing health; animals rarely turn on you; standing stones answer. |
| PDV_Bless_Breton_Stendarr_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Stendarr Champion" | Passive SPEL; Stendarr focus | Stendarr's Aegis is yours. Protecting an ally grants 15% damage resistance; Vigilants treat you as a peer; Daedra and undead take heavier hits. |
| PDV_Bless_Breton_Akatosh_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Akatosh Champion" | Passive SPEL; Akatosh focus | Akatosh keeps the order. Unbroken devotion of fourteen days at high Integrity returns a growing dawn blessing of magicka and stamina regeneration; the Amulet of Akatosh doubles its effect. |
| PDV_Bless_Breton_Mara_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Mara Champion" | Passive SPEL; Mara focus | Mara holds the community. Helping a family restores full health on next rest; her temple grants full recognition; companions heal better near you. |
| PDV_Bless_Breton_HermaeusMora_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Hermaeus Mora Champion" | Passive SPEL; Hermaeus Mora focus | Hermaeus Mora prices your scholarship. Alteration, Conjuration, and Illusion spells cost 10% less to cast; the deeper you are seen, the more he gives. |
| PDV_Bless_Breton_Hircine_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Hircine Champion" | Passive SPEL; Hircine focus | Hircine bonds the beast. Beast form lasts longer; the hunt scores stronger; the change comes smoother. |
| PDV_Bless_Breton_Nocturnal_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Nocturnal Champion" | Passive SPEL; Nocturnal focus | Nocturnal marks the shadow. Sneak attacks deal 15% more; a theft from a notable target opens a brief unseen window. |
| PDV_Bless_Breton_Namira_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Namira Champion" | Passive SPEL; Namira focus | Namira's corruption is yours. Squalor and hunger press lighter; she notices the things others will not name. |
| PDV_Bless_Breton_Yffre_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Y'ffre Champion" | Passive SPEL; Y'ffre focus | Y'ffre's Living Story runs through you. In forest, your armor rises by 10; hunting shots strike deep; nature-site quests count double. |
| PDV_Bless_Breton_Magnus_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Magnus Champion" | Passive SPEL; Magnus focus | Magnus opens the Elder Way. All spells cost 10% less and Alteration costs 15% less; Psijic-adjacent study scores strongly. |
| PDV_Bless_Breton_Phynaster_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Breton "Phynaster Champion" | Passive SPEL; Phynaster focus | Phynaster's long life is in your blood. Your resistance to magic rises by 15% over your Breton birthright, and elven-heritage acts return piety. |

### 18.3 Tier-up notifications (`PDV_Notif_Breton_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. The `%s` token binds the deity name. No `suppress-if-offer-same-dawn` flag: Breton uses tradition setup and focus emergence rather than a dawn offer.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Breton_Observant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Tier Rewards" | One per deity per save | %s has noticed your tradition. Observant. |
| PDV_Notif_Breton_Faithful_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Tier Rewards" | One per deity per save | Your standing with %s is steady now. Faithful. |
| PDV_Notif_Breton_Devoted_Entry | Notification | Marked | Narrator | 80/60 | RaceDesign_Breton "Tier Rewards" | One per save | %s knows your name. Devoted. |
| PDV_Notif_Breton_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Neglect Texture" | One per deity per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Breton_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Neglect Texture" | One per deity per direction per save | The favor of %s is thinning. Observant. |
| PDV_Notif_Breton_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Breton "Neglect Texture" | One per save per Devoted loss | The bond with %s loosens. The Devoted bond is not held. |

### 18.4 Tradition setup and entry (`PDV_Msg_Breton_TraditionChoice_Setup`, `PDV_Notif_Breton_Tradition_*`)

The setup prompt is narrator voice, a MessageBox presenting the three-tradition choice. Tradition entries are narrator voice. Per `RaceDesign_Breton` "Worship Structure": the setup choice is explicit and, in 1.0, stable.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_TraditionChoice_Setup | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Breton "Worship Structure"; TargetEndStates line 254 | First-run setup; one-time | Title: "Which Tradition" Body: "Breton faith is the tradition you walk; the gods give it shape after. Choose: the Knight's Road of vow and mercy, the Hidden Art of occult practice, or the Green Way of the old druidic covenant." |
| PDV_Notif_Breton_Tradition_KnightsRoad_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Worship Structure" | On tradition set to Knight's Road | You walk the Knight's Road. The vow is yours to keep. |
| PDV_Notif_Breton_Tradition_HiddenArt_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Worship Structure" | On tradition set to Hidden Art | You walk the Hidden Art. The occult practice is yours, and its risks. |
| PDV_Notif_Breton_Tradition_GreenWay_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "Worship Structure" | On tradition set to Green Way | You walk the Green Way. The old druidic covenant is yours. |

### 18.5 Focus emergence (`PDV_Notif_Breton_FocusEmergence`)

Narrator voice. HUD notification. Budget 80 hard / 60 target. One templated row; the `%s` token binds the emerging focused deity within the chosen tradition. See the slot-frame correction above for why emergence rather than a bespoke offer suite.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Breton_FocusEmergence | Notification | Noted | Narrator | 80/60 | TargetEndStates line 252; RaceDesign_Breton line 33 | Fires when focused emphasis settles within the tradition; %s deity | Within your tradition, your devotion has settled on %s. The focus has emerged. |

### 18.6 Champion entries (`PDV_Msg_Breton_ChampionEntry_*`)

God-voice in the tradition register. MessageBox. Body budget 500 hard / 280 target. `Entry-only`, one per tradition.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_ChampionEntry_KnightsRoad | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Champion moment for Knight's Road"; TargetEndStates lines 272-273 | One-time on first Knight's Road Devoted | Title: "The Vow Unbroken" Body: "Skyrim offered you the Guild, the Brotherhood, every expedient shortcut -- and you kept the vow through all of it. That is the hardest road in this province. The shield you carry for others is real now." |
| PDV_Msg_Breton_ChampionEntry_HiddenArt | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Champion moment for Hidden Art"; TargetEndStates line 274 | One-time on first Hidden Art Devoted | Title: "The Double Life Resolved" Body: "You chose -- the practice hidden completely, or declared and Notorious. You did not linger in the safe middle. Your patron rewards the one who commits, whichever way. The art is fully yours." |
| PDV_Msg_Breton_ChampionEntry_GreenWay | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Champion moment for Green Way"; TargetEndStates line 275 | One-time on first Green Way Devoted | Title: "The Forest Knows You" Body: "Skyrim's woods are cold and they do not welcome easily. They welcome you. The animals settle, the hunt is guided, the standing stones answer. The old covenant is kept, quietly and completely." |

### 18.7 Track band crossings (`PDV_Notif_Breton_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Three tracks per `RaceDesign_Breton`: KnightlyVowIntegrity, WitchcraftExposure, DruidicStanding. Fires on band entry.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Breton_KnightlyVowIntegrity_Intact | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "KnightlyVowIntegrity Track" | One per band entry | Your knightly vow stands intact. Stendarr reads it clearly. |
| PDV_Notif_Breton_KnightlyVowIntegrity_Strained | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "KnightlyVowIntegrity Track" | One per band entry | Your knightly vow is strained. Knight's Road favor comes harder now. |
| PDV_Notif_Breton_KnightlyVowIntegrity_Broken | Notification | Marked | Narrator | 80/60 | RaceDesign_Breton "KnightlyVowIntegrity Track" | One per band entry | Your knightly vow is broken. The Knight's Road halts until you restore it. |
| PDV_Notif_Breton_WitchcraftExposure_Hidden | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "WitchcraftExposure Track" | One per band entry | Your occult practice is Hidden. It is invisible to those who would object. |
| PDV_Notif_Breton_WitchcraftExposure_Suspected | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "WitchcraftExposure Track" | One per band entry | Your practice is Suspected. The Vigilants may begin to notice. |
| PDV_Notif_Breton_WitchcraftExposure_Known | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "WitchcraftExposure Track" | One per band entry | Your practice is Known. The Vigilants are a real danger now. |
| PDV_Notif_Breton_WitchcraftExposure_Notorious | Notification | Marked | Narrator | 80/60 | RaceDesign_Breton "WitchcraftExposure Track" | One per band entry | Practice now Notorious. Society ruptures; the patron rewards full commitment. |
| PDV_Notif_Breton_DruidicStanding_Open | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "DruidicStanding" | One per band entry | The druidic covenant is open but unproven. Y'ffre waits. |
| PDV_Notif_Breton_DruidicStanding_Acknowledged | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "DruidicStanding" | One per band entry | The druidic covenant is acknowledged. Y'ffre answers you steadily. |
| PDV_Notif_Breton_DruidicStanding_Frayed | Notification | Noted | Narrator | 80/60 | RaceDesign_Breton "DruidicStanding" | One per band entry | The druidic covenant frays. The forest is forgetting you. |

### 18.8 Druidic Trial fork (`PDV_Msg_Breton_GreenWay_DruidicTrial_*`)

The Druidic Trial fires once, on a Green Way Breton's first werewolf transformation. The confrontation is god-voice (Y'ffre), a MessageBox with the two-way choice; the responses are player-second-person. Per `RaceDesign_Breton` "Druidic Trial details".

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_GreenWay_DruidicTrial_Confront | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Druidic Trial details"; TargetEndStates line 280 | One-time, on first werewolf transformation as Green Way | Title: "The Druidic Trial" Body: "The beast is in you now. The druid circles have always been split on this. Decide: the beast serves the Green, and the covenant deepens around the new shape -- or Hircine's gift becomes your own, and the Green closes to you. Choose." |
| PDV_Msg_Breton_GreenWay_DruidicTrial_BeastServesGreen | MessageBox | Marked | Player-2nd | 60/40 | RaceDesign_Breton "Druidic Trial details" | Y'ffre devotion resumes full; Hircine path locked out | The beast serves the Green. |
| PDV_Msg_Breton_GreenWay_DruidicTrial_HircineClaimed | MessageBox | Marked | Player-2nd | 60/40 | RaceDesign_Breton "Druidic Trial details" | Druidic fork betrayal pressure begins; Hircine drift begins | Hircine's gift is mine. |

### 18.9 Neglect texture (`PDV_Notif_Breton_*_NeglectTexture`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Breton` "Neglect Texture", one per tradition. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Breton_KnightsRoad_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Knight's Road neglect" | One per lapse-band crossing | The vow feels hollow. Your patron is disappointed, not distant. |
| PDV_Notif_Breton_HiddenArt_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Hidden Art neglect" | One per lapse-band crossing | You went Notorious, then stopped. The cost remains; the reward is gone. |
| PDV_Notif_Breton_GreenWay_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Green Way neglect" | One per lapse-band crossing | The forest stopped noticing you. Nature is only background now. |

### 18.10 Survey Devotion readouts (`PDV_Msg_Breton_Survey_*`)

Narrator voice. Body budget 240 hard / 180 target. One row per tradition; `%s` tokens bind the tier name and the tradition's signature track.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_Survey_KnightsRoad | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 Integrity band | You walk the Knight's Road: vow, mercy, protective justice. Standing: %s1. Knightly Vow Integrity: %s2. |
| PDV_Msg_Breton_Survey_HiddenArt | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 Exposure band | You walk the Hidden Art: occult practice and the double life. Standing: %s1. Witchcraft Exposure: %s2. |
| PDV_Msg_Breton_Survey_GreenWay | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 Druidic Standing | You walk the Green Way: the old druidic covenant. Standing: %s1. Druidic Standing: %s2. |

### 18.11 Contextual favor surfacings

Three to five trigger families per tradition lane per `RaceDesign_Breton` "Approved 1.0 lock additions" line 290. The race sheet does not enumerate a formal favor table; the rows below are derived from the per-tradition Tier Rewards and the 1.0 hook evidence. Player-second-person on Noted; god-voice on Marked. The Notorious rupture is a Marked Hidden Art moment.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Breton_FavorNoted_KnightsRoad_MercyJustice | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Tier Rewards -- Knight's Road" | After-act; curated mercy/justice outcomes | Mercy chosen, justice kept. The vow holds, and Stendarr sees it. |
| PDV_Notif_Breton_FavorNoted_KnightsRoad_ProtectedOther | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Tier Rewards -- Knight's Road" | Momentary/after-act; curated defense situations | You stood between the weak and the blade. The shield is real. |
| PDV_Notif_Breton_FavorNoted_KnightsRoad_UnrewardedAid | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Tier Rewards -- Knight's Road" | After-act; curated zero-reward quest variants | Help given with no reward asked. The Knight's Road counts it. |
| PDV_Notif_Breton_FavorNoted_HiddenArt_OccultWork | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Tier Rewards -- Hidden Art" | After-act; major occult acts only | The hidden practice deepens. Your patron is pleased, and quiet. |
| PDV_Notif_Breton_FavorNoted_HiddenArt_DaedricRite | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Hidden Art: strong 1.0 hooks" | After-act; Daedric quest outcomes | A Daedric rite completed. The patron's reward flows strong. |
| PDV_Msg_Breton_FavorMarked_HiddenArt_NotoriousRupture | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Champion moment for Hidden Art"; "WitchcraftExposure Track" | One-time on first reaching Notorious | Title: "Notorious" Body: "You have stopped hiding. Society recoils, and there is no taking it back -- but I no longer have to whisper to you. The art is loud now, and it is fully yours." |
| PDV_Notif_Breton_FavorNoted_GreenWay_StandingStone | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Green Way: strong 1.0 hooks" | Environmental; per stone, first visit | At the standing stone, the old covenant answers. |
| PDV_Notif_Breton_FavorNoted_GreenWay_OutdoorLife | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Tier Rewards -- Green Way" | Environmental; cadence-based, daily cap | The wild keeps you. Y'ffre's covenant is steady. |
| PDV_Notif_Breton_FavorNoted_GreenWay_NatureRestraint | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Breton "Cross-lane pressure rule" | After-act; nature-aligned restraint | You spared the living world where you could. Counted. |

### 18.12 Curse-state transitions (`PDV_Msg_Breton_CurseState_*`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Per `RaceDesign_Breton` "Curse State Summary": the curse outcome is a three-tradition matrix. The vampire onset carries the per-tradition split in one body; werewolf has a per-tradition split (Green Way werewolf is the Druidic Trial in Section 18.8). Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Curse State Summary" | Once on becoming vampire | Title: "The Curse and the Tradition" Body: "You are undead now, and each tradition answers differently. The Knight's Road breaks -- oaths and Divines lost. The Green Way excommunicates -- Y'ffre closes. Only the Hidden Art finds you a partial home, in the Volkihar court and the witch-mother's acceptance." |
| PDV_Msg_Breton_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Curse State Summary"; "Approved 1.0 lock additions" line 287 | Once on cure | Title: "Re-Entry" Body: "The undeath is lifted. The Knight's Road may be rebuilt through restored Integrity. The Green Way remains under betrayal pressure until an authored re-entry exists; richer restoration is deferred." |
| PDV_Msg_Breton_CurseState_WerewolfOnset_KnightsRoad | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Curse State Summary" | Once on first transformation; Knight's Road | Title: "Homeless in the Vow" Body: "The beast is in you, and the Knight's Road has no frame for it. There is no theological home for the wolf here. Your Integrity degrades on each transformation, and the knightly orders will not understand." |
| PDV_Msg_Breton_CurseState_WerewolfOnset_HiddenArt | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Curse State Summary" | Once on first transformation; Hidden Art | Title: "The Beast Belongs" Body: "The beast is in you, and the Hidden Art already holds Hircine. Glenmoril is family here. There is no rupture -- the wolf fits the occult frame as though it were always meant to." |
| PDV_Msg_Breton_CurseState_WerewolfCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Breton "Curse State Summary" | Once on werewolf cure; per-tradition resolution | Title: "The Beast Set Down" Body: "The wolf is set down. On the Knight's Road, Integrity may now be rebuilt, the transformations ended, though the orders remember. In the Hidden Art the beast that belonged is given up by choice; Glenmoril marks the loss, and the occult frame holds an empty place." |

### 18.13 Shrine and privilege dialogue topics (`PDV_Dlog_Breton_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three archetypes, one per tradition.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Breton_StendarrShrine_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Breton "Knight's Road" | Knight's Road, Faithful or above | "I keep the knightly vow for Stendarr. Where is mercy needed?" |
| PDV_Dlog_Breton_HiddenArtContact_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Breton "The Hidden Art" | Hidden Art tradition | "I practice the hidden art. Speak plainly -- no one is listening." |
| PDV_Dlog_Breton_DruidicKeeper_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Breton "The Green Way" | Green Way tradition | "The Green Way is mine. Tell me of the standing stones here." |

### 18.14 Vigilant pressure encounter (drafted)

Authored for Phase 20 content lock. Narrator voice, MessageBox 500/280, matching the Section 18.7 WitchcraftExposure band voice. The three beats escalate with exposure: the Letter fires on entering the Known band, the road encounter on continued Known-band visibility, and the confrontation on the Notorious band. Each is one-time per exposure climb; the WitchcraftExposure band crossings carry the ongoing exposure feel between them.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Breton_VigilantPressure_Letter | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Breton "WitchcraftExposure Track"; TargetEndStates lines 260-262 | One-time on entering the Known exposure band | Title: "A Letter from the Vigil" Body: "A sealed letter finds you, unsigned but unmistakable. The Vigilants of Stendarr have heard what you keep, and they are watching the roads you take. It is a warning, this time. They do not send a second." |
| PDV_Msg_Breton_VigilantPressure_RoadEncounter | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Breton "WitchcraftExposure Track"; TargetEndStates lines 260-262 | One-time on continued Known-band visibility after the Letter | Title: "The Vigil on the Road" Body: "Two Vigilants block the road ahead, hands near their maces, reading you for the mark of the thing you serve. They ask their questions knowing the answers. How this ends depends on what they decide they saw -- and on whether your cover holds one more time." |
| PDV_Msg_Breton_VigilantPressure_Confrontation | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Breton "WitchcraftExposure Track"; TargetEndStates lines 260-262 | One-time on entering the Notorious exposure band | Title: "The Vigil Comes for You" Body: "The watching is over. The Vigilants have named you a servant of the Daedra, and they have come in number to end it. There is no letter now, no question, no road to slip down. What you practiced in the dark has found you in the light, and only one of you walks away." |

### 18.15 Breton firing-density sanity

A Faithful Hidden Art Breton in steady occult play (Daedric quests, careful cover, occasional exposure shift):

- Marked: 0 most days; Champion entries, the tradition-setup choice, the Druidic Trial, the one-time Notorious rupture, and curse onsets are all one-time. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (an occult-work favor, an occasional Daedric-rite favor). Track band crossings are infrequent because all three tracks move on major authored acts, not ambient behavior. Inside the `<2 per h` target.
- Quiet: uncounted; icon-only.

Tier-up notifications: one per save per deity per direction. There is no dawn offer, so no Faithful suppression rule applies. The Section 18.14 Vigilant pressure encounter fires its three beats one-time each across an exposure climb, so it does not compound the daily Noted count.

## 19. Argonian (full draft)

Implementation-locked. One layered Hist substrate carrying three visible layers (Hist, People, Void); no deity choice and no commitment offer. `PDV_Substrate_ArgonianHist` owns the substrate. `PDV_State_ArgonianHistPosture` with `Normal = 0`, `Distant = 1`, `Strained = 2`, `Silenced = 3`, `Corrupted = 4`.

**Slot-frame correction:** the planning-pass frame implied per-layer Tier 1/2/3 blessings (`PDV_Bless_Argonian_<Hist|People|Void>_T<1|2|3>`). The locked `RaceDesign_Argonian` "Tier Rewards" gives Tier 1 and Tier 2 as the single layered experience (all three layers at once), and Tier 3 splits into the three Champion sub-rewards. The corrected set is five blessing records: `PDV_Bless_Argonian_Layered_T1`, `_Layered_T2`, and `_Hist_T3` / `_Community_T3` / `_Sithis_T3`.

### 19.1 Tone profiles

| Voice | Tone profile |
|---|---|
| The Hist | Not a god; the ancient sentient trees that give and receive Saxhleel souls; constitutive, distant in Skyrim; it reaches, or fails to reach, rather than speaks. |
| The People | The Saxhleel held together by each other in exile; warm, practical, mutual; the family chosen when the trees cannot be reached. |
| Sithis | The primordial void -- change, death, the dark before and around all things; acknowledged, never worshipped; speaks rarely, and never to comfort. |

### 19.2 Substrate posture readouts (`PDV_Msg_Argonian_HistPosture_*`)

Narrator voice. Status readout surface (shown by Survey Devotion and on posture transitions). Budget 240 hard / 180 target. One per `PDV_State_ArgonianHistPosture` value.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Argonian_HistPosture_Normal | Status spell readout | Quiet | Narrator | 240/180 | RaceDesign_Argonian "Curse posture enum" | Default | The Hist is distant, as it always is in Skyrim, but it still reaches you. You are held. |
| PDV_Msg_Argonian_HistPosture_Distant | Status spell readout | Noted | Narrator | 240/180 | RaceDesign_Argonian "Curse posture enum" | Low uncursed Hist relation; fires on transition | The Hist has thinned to almost nothing. You feel like a stranger in your own skin. |
| PDV_Msg_Argonian_HistPosture_Strained | Status spell readout | Noted | Narrator | 240/180 | RaceDesign_Argonian "Curse posture enum" | Lycanthropy; fires on transition | The Hist relation is strained. The beast-shape sits between you and the trees, but they have not let go. |
| PDV_Msg_Argonian_HistPosture_Silenced | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Argonian "Curse posture enum" | Active vampirism; fires on transition | The Hist has gone silent. It does not speak to its own undead. The cycle is interrupted. |
| PDV_Msg_Argonian_HistPosture_Corrupted | Status spell readout | Marked | Narrator | 240/180 | RaceDesign_Argonian "Curse posture enum" | Vampirism plus domination pressure; fires on transition | The Hist relation is corrupted. Undeath and domination have fouled the connection at its root. |

### 19.3 Blessing descriptions (`PDV_Bless_Argonian_*`)

Narrator voice. Budget 200 hard / 140 target. Tier 1 and Tier 2 are the layered experience; Tier 3 splits into the three Champion sub-rewards. Anti-farm: passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Argonian_Layered_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Argonian "Tier 1" | Passive SPEL; layered | The Hist is distant but present; the People know you. Water breathing deepens; you swim 10% faster; near water you heal 2 health a second; your resistance to disease rises by 15%. |
| PDV_Bless_Argonian_Layered_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Argonian "Tier 2" | Passive SPEL; layered | All three layers are maintained under exile. Near water you heal 5 health a second; rest near water restores health and stamina fully; helping a Saxhleel returns stamina. |
| PDV_Bless_Argonian_Hist_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Argonian "Hist Champion" | Passive SPEL; Hist layer | The Hist reaches you where water reaches. In wetland and water, your damage resistance rises by 10%, your health regenerates steadily, and your Sneak by 15. The swamp gives what dry stone cannot. |
| PDV_Bless_Argonian_Community_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Argonian "Community Champion" | Passive SPEL; Community layer | The People are your armor. Helping Saxhleel returns strong piety; a friendly Argonian nearby raises your armor by 8; the exile network knows you. |
| PDV_Bless_Argonian_Sithis_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Argonian "Sithis Champion" | Passive SPEL; Void layer | Sithis holds those who faced the void unflinching. Near death, a burst of stamina regeneration; a Dark Brotherhood contract sharpens speed and stealth after. |

### 19.4 Tier-up notifications (`PDV_Notif_Argonian_*`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. No `%s` deity token (there is no deity); no `suppress-if-offer-same-dawn` flag (no commitment offer).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_Observant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Tier 1" | One per save | The Hist reaches you, and the People know you. Observant. |
| PDV_Notif_Argonian_Faithful_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Tier 2" | One per save | All three layers hold under exile. Faithful. |
| PDV_Notif_Argonian_Devoted_Entry | Notification | Marked | Narrator | 80/60 | RaceDesign_Argonian "Tier 3" | One per save | The Hist knows you still, across all that distance. Devoted. |
| PDV_Notif_Argonian_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Neglect Texture" | One per direction per save | The layers are thinning. Your standing has slipped to Wavering. |
| PDV_Notif_Argonian_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Neglect Texture" | One per direction per save | The exile identity is fraying. Observant. |
| PDV_Notif_Argonian_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Argonian "Neglect Texture" | One per save per Devoted loss | The deepest connection loosens. The Devoted bond is not held. |

### 19.5 Champion entry and ambient

Champion shapes: **Hist** and **Community** are `Entry + ambient`; **Sithis** is `Entry-only`. **Voice deviation:** the Hist Champion entry uses Narrator voice, because the Hist reaches rather than speaks (there is no Hist voice to deliver a god-voice message). The Community entry is the People's collective voice; the Sithis entry is Sithis-voice.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Argonian_ChampionEntry_Hist | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Argonian "Hist Champion"; voice deviation justified above | One-time on first Hist-layer Devoted | Title: "Hist-Touched" Body: "Across all the miles from Black Marsh, in the wetlands and waters of this cold province, the Hist has found a way to reach you. It does not speak. It does not need to. You are Saxhleel, wholly, even here." |
| PDV_Notif_Argonian_Hist_ChampionAmbient_Water | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist Champion" | Hist-layer Devoted + near water; one per in-game day | Near the water, the Hist is almost here. You can feel it. |
| PDV_Msg_Argonian_ChampionEntry_Community | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Argonian "Community Champion" | One-time on first Community-layer Devoted; the People's voice | Title: "The Saxhleel Bond" Body: "You kept the exile community alive when the Hist could not hold us. The Assemblage, the docks, every Saxhleel you stood beside -- we know you. You are the family we chose, as we are yours." |
| PDV_Notif_Argonian_Community_ChampionAmbient_KinPresent | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Community Champion" | Community-layer Devoted + Argonian ally present; per qualifying event | A Saxhleel beside you. The exile community holds. |
| PDV_Msg_Argonian_ChampionEntry_Sithis | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Argonian "Sithis Champion" | One-time on first Sithis-layer Devoted; Entry-only | Title: "Void-Held" Body: "You looked into the dark that precedes and surrounds all things, and you did not flinch. Sithis does not comfort. But Sithis catches what has truly accepted the void. You have. Walk on, unafraid of the ending." |

### 19.6 Hist sap meditation (`PDV_Notif_Argonian_HistSapMeditation_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Argonian` "Hist distance rule" and `PDV_Architecture_v3.md` Section 21.2 essential custom content: the Hist sap meditation tool is a Hist-maintenance signal.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_HistSapMeditation_Activate | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist recovery signals"; Architecture v3 Section 21.2 | Per meditation use; daily cap on the Hist gain | You take the Hist sap and go still. The trees feel a little nearer. |
| PDV_Notif_Argonian_HistSapMeditation_Effect | Notification | Quiet | Player-2nd | 80/60 | RaceDesign_Argonian "Hist recovery signals" | Felt effect; quiet | The meditation steadies you. The Hist relation holds against the distance. |

### 19.7 Bed of choice (`PDV_Notif_Argonian_BedOfChoice_*`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Argonian` "Bed of choice": one `PDV_SacredPlace` anchor, "the family I chose"; cadence is three qualifying sleeps within a rolling 30 in-game days.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_BedOfChoice_Designate | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Bed of choice" | On designating the single anchor | You have chosen this bed: the family you chose. The exile has an anchor. |
| PDV_Notif_Argonian_BedOfChoice_Return | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Bed of choice" | On a qualifying sleep at the chosen bed | Back at the bed you chose. The People hold you a little closer. |
| PDV_Notif_Argonian_BedOfChoice_MissedCadence | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Bed of choice" | On cadence lapse; light People decay, place bonus removed | You have not returned to your chosen bed in too long. The anchor weakens. |

### 19.8 Sithis activation (`PDV_Notif_Argonian_SithisActivation_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Argonian` "Sithis activation": baseline awareness is always present; full Void scoring needs at least three significant Sithis signals.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_SithisActivation_FirstSignal | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Sithis activation" | On the first significant Sithis signal | Sithis stirs at the edge of you -- change, death, the void acknowledged. |
| PDV_Notif_Argonian_SithisActivation_FullActivation | Notification | Marked | Narrator | 80/60 | RaceDesign_Argonian "Sithis activation" | On reaching the three-signal activation threshold | Sithis is fully awake in you now, a third way to make meaning in exile. |

### 19.9 Neglect texture (`PDV_Notif_Argonian_*_NeglectTexture`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `RaceDesign_Argonian` "Neglect Texture", one per layer. Each fires on the first day of a meaningful lapse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_HistThinning_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist relation neglect" | One per lapse-band crossing | The Hist is thinning. You feel less Saxhleel than you did. |
| PDV_Notif_Argonian_PeopleIsolation_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Community neglect" | One per lapse-band crossing | Alone too long, no Saxhleel near. Isolation deepens the distance. |
| PDV_Notif_Argonian_VoidDormancy_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Sithis neglect" | One per lapse-band crossing | Sithis lies dormant. The void is there, but you have not faced it. |

### 19.10 Posture transition notifications (`PDV_Notif_Argonian_HistPosture_*_Entry`)

Narrator voice. Notifications. Budget 80 hard / 60 target. The `Distant` and `Strained` transitions fire here; the `Silenced` and `Corrupted` transitions are vampirism-linked and surface through the curse-state messages in Section 19.13 instead, to avoid double-notifying the same event.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_HistPosture_Distant_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Curse posture enum" | On transition to Distant | The Hist has grown distant. You are becoming a stranger in your own skin. |
| PDV_Notif_Argonian_HistPosture_Strained_Entry | Notification | Noted | Narrator | 80/60 | RaceDesign_Argonian "Curse split" | On transition to Strained (lycanthropy) | The Hist relation is strained. The beast-shape sits between you and the trees. |

### 19.11 Survey Devotion readout (`PDV_Msg_Argonian_Survey_Layered`)

Narrator voice. Body budget 240 hard / 180 target. One layered readout; `%s` tokens bind the tier name and the three layer states.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Argonian_Survey_Layered | Status spell readout | Quiet | Narrator | 240/180 | Architecture v3 Section 16.2 | Cast Survey Devotion; %s1 tier, %s2 Hist, %s3 People, %s4 Void | You carry the Saxhleel exile, far from Black Marsh. Standing: %s1. The Hist is %s2, the People %s3, the void %s4. |

### 19.12 Contextual favor surfacings

Three trigger families, formalized from `RaceDesign_Argonian` per-layer Tier Rewards and Signal Examples. **Hist** (near-water steadying, solitary reflection, Hist-sap meditation); **Community/People** (Saxhleel aid, Assemblage held, settlement protection); **Void** (death-facing, Dark Brotherhood contract). All are `Noted` -- consistent with the design's quiet, maintenance-against-the-current texture; the Argonian race carries no Marked favor row by design. Player-second-person voice.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Argonian_FavorNoted_Hist_NearWater | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist recovery signals" | Environmental; daily cap | Near the water, the Hist relation steadies. The distance shrinks a little. |
| PDV_Notif_Argonian_FavorNoted_Hist_Reflection | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist recovery signals" | After-act; solitary reflection in a wild place | A still moment in a wild place. The Hist reaches toward it. |
| PDV_Notif_Argonian_FavorNoted_Community_SaxhleelAid | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Layer 2 ... Primary signals" | After-act; cooldown per Argonian NPC | You helped one of your own. The exile community holds. |
| PDV_Notif_Argonian_FavorNoted_Community_AssemblageKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Layer 2 ... Primary signals" | After-act; Windhelm Assemblage extra weight | The Windhelm Assemblage is surer for what you did. Kinship. |
| PDV_Notif_Argonian_FavorNoted_Void_DeathFaced | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Layer 3 ... Sithis rises through" | After-act; curated death-facing choice | You faced a death without flinching. Sithis acknowledges it. |
| PDV_Notif_Argonian_FavorNoted_Void_BrotherhoodContract | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Layer 3 ... Sithis rises through" | After-act; per Dark Brotherhood contract | A contract completed for the Brotherhood. The void answers. |
| PDV_Notif_Argonian_FavorNoted_Hist_SapMeditation | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Hist recovery signals"; mechanics-dep: Hist-sap vessel custom feature | After-act; designated Hist contemplation site; daily cap; MECHANICS-BLOCKED: requires Hist-sap vessel feature from Phase 21 custom content | Sap taken. The distance closes a little; the Hist hears across the marsh. |
| PDV_Notif_Argonian_FavorNoted_Community_SettlementKept | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Argonian "Layer 2 ... Primary signals" | After-act; defending Argonian settlement or Assemblage from direct threat; cooldown per event | You kept the People from harm. The exile community is safer for it. |

### 19.13 Curse-state transitions (`PDV_Msg_Argonian_CurseState_*`)

MessageBox. Body budget 500 hard / 280 target. **Voice deviation:** all three rows use Narrator voice. The Hist reaches rather than speaks, and the deepest curse content is precisely the Hist's silence; no god-voice can carry it. Per `RaceDesign_Argonian` "Curse State Summary": vampirism is the deep grief state, werewolf is recoverable strain. Fires once per cure cycle.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Argonian_CurseState_VampireOnset | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Argonian "Vampire"; sets posture Silenced or Corrupted | Once on becoming vampire | Title: "The Hist Falls Silent" Body: "You are undead now. The Hist gives Saxhleel souls and receives them at death -- and yours is no longer going where it was meant to go. The Hist falls silent. The People cannot safely hold you. Only the void stays near. This is the deepest grief." |
| PDV_Msg_Argonian_CurseState_VampireCured | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Argonian "Vampire" | Once on cure | Title: "The Hist Reaches Again" Body: "The undeath is lifted. The Hist's silence breaks slowly -- it must learn to reach you again across both the distance and the memory of what you were. The People can hold you once more. It will take time. It can be done." |
| PDV_Msg_Argonian_CurseState_WerewolfOnset | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Argonian "Werewolf"; sets posture Strained | Once on first transformation | Title: "A Changed Shape" Body: "The beast is in you. The Hist is accustomed to Saxhleel who change -- the shape strains the relation but does not sever it. The People can still recognize you. This is serious, but it is not the silence. It can be carried." |
| PDV_Msg_Argonian_CurseState_WerewolfCured | MessageBox | Marked | Narrator | 500/280 | RaceDesign_Argonian "Werewolf" | Once on werewolf cure; clears posture Strained | Title: "The Shape Settles" Body: "The beast is set down. The strain on the Hist relation eases, and the People recognize you without reservation again. The shape that pulled at the bond is gone. What was carried is set aside; the Hist reaches you clean." |

### 19.14 Shrine and privilege dialogue topics (`PDV_Dlog_Argonian_*`)

Player-second-person on topic name. Branch dialogue authored separately in CK. Topic-line budget 120 hard / 80 target. Three archetypes grounded in the Skyrim Argonian exile community.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Dlog_Argonian_WindhelmAssemblage_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Argonian "Layer 2" | Faithful or above | "I keep faith with our people in exile. What does the Assemblage need?" |
| PDV_Dlog_Argonian_RiftenDocks_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Argonian "Layer 2" | Faithful or above | "We hold each other where the Hist cannot reach. Tell me what is needed." |
| PDV_Dlog_Argonian_HistKeeper_Recognition | Dialogue topic | Noted | Player-2nd | 120/80 | Architecture v3 Section 16.3; RaceDesign_Argonian "Layer 1" | Hist-layer Devoted | "The Hist still reaches me, faintly. Speak of the old connection." |

### 19.15 Argonian firing-density sanity

A Faithful community-leaning Argonian in steady exile play (Windhelm Assemblage support, water-proximity maintenance, occasional Sithis beat):

- Marked: 0 most days; Champion entries, Sithis full activation, and curse onsets are all one-time. Inside the `<1 per 2h` target.
- Noted: ~1-2 per day (a near-water Hist favor, an occasional Saxhleel-aid or settlement-protection favor). Argonian carries no Marked favor row by design, so steady play is quiet. Inside the `<2 per h` target. The Hist-sap meditation favor row is MECHANICS-BLOCKED and does not contribute until the vessel feature ships.
- Quiet: uncounted; icon-only (the Hist sap meditation effect line is Quiet).

Tier-up notifications: one per save per direction. There is no commitment offer, so no Faithful suppression rule applies. Bed-of-choice acknowledgments are gated to the cadence rule, and posture transitions are rare (curse-linked or sustained Hist decay).

Argonian has no commitment-offer slot: there is no deity choice. The bed-of-choice and Sithis-activation beats above are the closest the layered system comes to a commitment moment, and both are authored as gentle notifications rather than offer MessageBoxes.

---

## 20. Coverage check (Section 9 priority order)

| Race | Tone profiles | Blessings | Tier-up | Champion | Neglect | Offer | Survey | Favors | Curse | Dialogue topics | Pilot prose |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Nord | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Orc | drafted | drafted | drafted | drafted | drafted | n/a | drafted | drafted | drafted | drafted | YES |
| Dunmer | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Altmer | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Khajiit | drafted | drafted | drafted | drafted | drafted | n/a | drafted | drafted | drafted | drafted | YES |
| Imperial | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Redguard | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Bosmer | drafted | drafted | drafted | drafted | drafted | n/a (path setup) | drafted | drafted | drafted | drafted | YES |
| Breton | drafted | drafted | drafted | drafted | drafted | n/a (tradition setup) | drafted | drafted | drafted | drafted | YES |
| Argonian | drafted | drafted | drafted | drafted | drafted | n/a | drafted | drafted | drafted | drafted | YES |

`n/a` rows mean the race does not use the standard commitment-offer pattern (Khajiit silent emergent, Orc mode-deepening, Bosmer setup choice, Breton tradition setup, Argonian no deity choice). The setup-choice MessageBoxes for Bosmer and Breton are slot-only rows in their sections, not in the commitment-offer pattern.

`Dialogue topics = drafted` means recognition intent exists for every race, but
new NPC conversation lines, voiced responses, lip files, scene content, and
broad recognition topics are out of V1 scope. For V1, translate any needed
recognition into non-voiced fallback surfaces: Survey/status, MCM Player text,
MessageBox, notification, spell/effect description, book/note, safe service or
shrine gate, or Prisma toast.

---

## 21. Gated and deferred appendix

These slots are deliberately not authored in this pass. (The Altmer crisis-of-faith copy, Altmer contextual-favor lanes, Altmer post-vampire Exiled flavor, and the Breton Vigilant pressure encounter were gated here in earlier passes and are now authored for the Phase 20 content lock -- see Sections 13.13 and 18.14.)

| Item | Gate | Reason |
|---|---|---|
| Daedric path content | Now authored in the companion file `race-sheets/PDV_DaedricContent_Manifest.md`: Boethiah is drafted end to end as the pilot, and the remaining 15 Skyrim-facing Princes are in scope for the Phase 20 content lock. No longer deferred here. | Boethiah pilot complete; see the Daedric manifest. |
| NPC conversation / recognition dialogue | Planned V2 enhancement. Existing `PDV_Dlog_*` rows remain recognition-intent drafts only. | V1 explicitly avoids adding new NPC conversation lines, voiced responses, lip files, scene content, or broad recognition topics. |
| Bosmer Green Pact per-item violation feedback | `PDV_Architecture_v3.md` Section 21.2 essential custom content: PDV-owned Green Pact tag layer must ship first. Prose is now authored in Section 17.7a with a MECHANICS-BLOCKED flag; implementation can wire up the tag layer without further content authoring. | Item-level surfacing depends on the tag layer existing. |
| MCM player tab copy | `PDV_Architecture_v3.md` Section 16.1, Section 16.4: MCM should not be a daily management surface. | Authored alongside the player tab itself, not as flavor content. |
| Localization / non-ASCII variants | `PDV_Architecture_v3.md` Section 23: deferred post-1.0; minor refactor via string-table externalization. | Out of 1.0 scope by architecture. |
| Daedric race-by-Prince matrix expansion strings | In scope for Phase 20 content lock. `references/phase4/PDV_DaedricRacePrinceMatrix.csv` is the implementation matrix; each cell must be expanded into the Section 11 contract before strings are authored. No longer deferred past content lock. | Expansion authoring follows Phase 13 pilot and `PDV_DaedricContent_Manifest.md` pattern. |

---

## 22. Verification checklist

This manifest's own verification, per the plan:

1. **Coverage:** every race in Section 9 has a section. Path/sect-divergent races have rows per path. -- See Section 20 table.
2. **Source-citation:** every drafted Nord row has a Source column entry pointing at a real file/line range. Spot-check 10 at random.
3. **ASCII:** `LC_ALL=C grep -nP '[^\x00-\x7F]' race-sheets/PDV_RaceContent_Manifest.md` returns no matches.
4. **Nord pilot completeness:** every Nord row has non-empty `Draft prose`. All thirteen worshippable deities carry a `ChampionEntry` MessageBox per the universal-champion decision in Section 10.4; no row is left reserved.
5. **Blessing discipline:** Nord blessing rows lead with theological tone and follow with a concrete numeric effect, matching the `PDV_STANDARDS.md` Section 3.3 conformance example. No formids, no `PDV_*` record names in prose, no `bucket` / `hook` jargon.
6. **Surfacing-vs-source:** every `Marked` row is one the source explicitly named as Marked or as a high-cost / costly-but-faithful moment. The two Marked Talos rows in Section 10.8 are flagged by `RaceDesign_Nord` lines 128 and 138 respectively.
7. **Deferred appendix:** Green Pact per-item feedback, MCM player tab, and localization appear in Section 21 with the gate cited. The former Altmer crisis copy, Altmer contextual-favor lanes, Altmer Exiled flavor, and Breton Vigilant pressure are now authored (Sections 13.13, 18.14) for the Phase 20 content lock. Daedric path content has moved to its own companion manifest (`PDV_DaedricContent_Manifest.md`), no longer deferred. Daedric race-by-Prince matrix expansion strings are now in scope for Phase 20 content lock, not deferred past it.
8. **Slot-ID convention:** every Nord slot id matches the `PDV_Msg_*` / `PDV_Notif_*` / `PDV_Bless_*` / `PDV_Dlog_*` / `PDV_PrismaToast_*` scheme. None exceed 32 EditorID characters where the CK editor truncates. (Longest Nord id: `PDV_Notif_Nord_Kynareth_ChampionAmbient_Storm` is 45 chars; flagged for review -- some CK fields tolerate longer EditorIDs but MESG/SPEL EditorIDs are safer under 32. Recommend `PDV_Notif_Nord_Kyn_ChampAmb_Storm` style abbreviations at Phase 19 hand-off if the truncation rule bites. Slot id stability vs. the manifest is the contract; CK shorthand is acceptable so long as the Slot ID column carries both.)
9. **Length-budget:** every Nord `Draft prose` cell is at or under the row's `Budget` cap. The longest drafted body is `PDV_Msg_Nord_CurseState_VampireOnset` at 252 chars (under the 500 hard / 280 target). Notifications stay at or under 60 chars in nearly all cases; the few that touch 70-80 carry the body inside the 80 hard cap.
10. **Voice-matrix compliance:** every Nord row's `Voice` matches the Section 3 matrix. No drift.
11. **Localization-readiness:** the only externalized tokens are the `%s` deity-name and tier-name substitutions in Section 10.3 tier-up notifications and Section 10.7 status readouts. No player-name interpolation, no string concatenation, no embedded numerals in prose (numbers in blessing descriptions are mechanical effects per Section 4 budget exception and match `PDV_STANDARDS.md` Section 3.3).
12. **Firing-density:** Section 10.11 sanity table confirms Nord steady play stays inside the `Marked < 1 per 2h` and `Noted < 2 per h` targets.
13. **Tone-profile coverage:** every Nord deity referenced by a Section 10.2-10.10 row has a Section 10.1 tone-profile entry.
14. **ASCII stress-test:** the two named stress-test rows -- `PDV_Notif_Nord_General_AncestorsQuiet` ("The ancestors are quiet.") and `PDV_Msg_Nord_FavorMarked_TalosDefiance` ("You stood between them and me. Carry the old breath a little longer.") -- read naturally under ASCII without em dashes or ellipses. The rule is not raising cost back to the user.
15. **Tone-continuity review (Phase 20 WS-4):** every deity and every Daedric Prince's rows were read against its tone profile, and shared deities worshipped by more than one race were laid side by side to confirm the cultural framing genuinely differs (not just the slot ID). Resolved this pass: Kyne vs. Kynareth differentiated on Nord (different gods, same race); Mara / Stendarr / Zenithar / Kynareth same-god overlap accepted across races with consistent full-sentence format; all 16 Daedric Princes audited and fact-checked against their Skyrim portrayal, with Mehrunes Dagon realigned to his in-game wrathful-command delivery; three cross-Prince MessageBox title collisions resolved. The companion Daedric manifest carries the matching Section 8 coverage. Drafts that drift from the descriptor are rejected at review.

---

## 23. Next slice

All ten races carry full draft prose. The manifest is content-author-ready for Phase 19 (`PDV_Architecture_v3.md` Section 17).

The remaining open work is no longer race-by-race prose drafting but the following:

1. **Gated slots closed.** The three Altmer slot groups (Section 13.13) and the Breton Vigilant pressure encounter (Section 18.14) were authored for the Phase 20 content lock. The Altmer implementation-spec questions (`PDV_TargetEndStates_1.0.md` line 146) are resolved in those sections: the favor lanes are keyed to the three alignment paths, and the crisis trigger list is the four locked beats.
2. **Promote ratified prose.** Once reviewed, migrate the draft prose into the shipped ESP records (Phase 19) and into the `Race_*.md` player handbooks where it serves as player-facing copy.
3. **Fill formal contextual-favor tables.** Khajiit, Bosmer, and Argonian favor rows here are derived from hook cross-checks and Tier Rewards because those race sheets carry no formal favor table yet. When those tables are added to the race sheets, re-check the lane families and row counts.
4. **Per-deity offer prose for Breton** (optional refinement): the single templated focus-emergence notification could be expanded into bespoke per-deity offers if the design later confirms full patron offers within traditions.
5. **Update `PDV_TargetEndStates_1.0.md`** "Content authored" column from Pending toward Drafted for each race as this manifest's prose is ratified.

---

## 24. Token tables

This section makes the localization-readiness rule (Section 7) concrete: every
`%s` substitution token used in the manifest, and its full value set, is
enumerated here. Section 7's "externalized vocabulary" is exactly the tables
below. The companion `race-sheets/PDV_DaedricContent_Manifest.md` reuses these
tables.

### 24.1 Token syntax convention

- A row with **one** substitution slot uses bare `%s`.
- A row with **two or more** slots uses numbered `%s1`, `%s2`, `%s3`, `%s4`.
- Numbered indices are **row-local and positional**, not global: `%s1` binds
  to the deity name in `PDV_Msg_Nord_Survey_Focused` but to the tier name in
  `PDV_Msg_Imperial_Survey_BroadDivines`. Each row's `Anti-farm / dep notes`
  column states what each token binds. This satisfies Section 7 rule 1 (no
  free interpolation): the only substituted values are the closed vocabularies
  below.
- Tokens are filled by the caller from these tables; prose is never
  concatenated.

### 24.2 Tier-name vocabulary

| Ladder | Values (low to high) | Used by |
|---|---|---|
| Aedric / native devotion ladder | `Distant`, `Wavering`, `Observant`, `Faithful`, `Devoted` | Every race's tier-up notifications and `Standing: %s` survey readouts |
| Daedric path ladder | `Seeker`, `Devoted`, `Champion` | `PDV_DaedricContent_Manifest.md` boon/price tiers (`PDV_Architecture_v3.md` Section 11.1) |

`Devoted` appears in both ladders; `Champion` is a Daedric tier name, while in
the Aedric ladder "Champion" is only the experience term for the Devoted tier,
never a substituted value.

### 24.3 Deity-name rosters

The deity name that fills `%s` in a race's tier-up, focus, and survey rows is
drawn from that race's roster:

| Race | Deity-name values |
|---|---|
| Nord | Shor, Kyne, Talos / Ysmir, Tsun, Stuhn, Mara, Akatosh, Kynareth, Arkay, Stendarr, Zenithar, Julianos, Dibella |
| Imperial | Akatosh, Talos, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella |
| Dunmer | Azura, Boethiah, Mephala (focused Reclamation) |
| Altmer | Auri-El, Magnus, Trinimac, Xarxes, Syrabane |
| Khajiit | Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh |
| Redguard | Satakal, Tu'whacca, Ruptga, Leki, Tava, HoonDing |
| Bosmer | Y'ffre, Z'en, Baan Dar (the active path's deity) |
| Breton | Stendarr, Akatosh, Mara, Hermaeus Mora, Hircine, Nocturnal, Namira, Y'ffre, Magnus, Phynaster |
| Orc | Malacath only -- named literally in prose, never via `%s` |
| Argonian | none -- no deity-name token (no deity choice) |

### 24.4 Track and state vocabularies

Band, posture, and mode names that fill `%s` tokens in survey readouts and
band-crossing notifications:

| Track / state | Values | Source |
|---|---|---|
| ConcordatStanding (Imperial) | Open Defiant, Private Defiant, Uncommitted, Public Compliant, Concordat Enforcer | RaceDesign_Imperial "ConcordatStanding Track" |
| ThalmorAlignment (Altmer) | Heterodox, Orthodox Moderate, Thalmor Devout | RaceDesign_Altmer "ThalmorAlignment Track" |
| GreenPactCompliance (Bosmer Old Contract) | Apostate, Lapsed, Observant, Strict | RaceDesign_Bosmer "GreenPactCompliance State Model" |
| KnightlyVowIntegrity (Breton) | Intact, Strained, Broken | RaceDesign_Breton "KnightlyVowIntegrity Track" |
| WitchcraftExposure (Breton) | Hidden, Suspected, Known, Notorious | RaceDesign_Breton "WitchcraftExposure Track" |
| DruidicStanding (Breton) | Open, Acknowledged, Frayed | RaceDesign_Breton "DruidicStanding" |
| Orc life-mode | City, Stronghold, Legion/Exile | RaceDesign_Orc "Life-mode implementation rule" |
| Khajiit focused emphasis | None (broad), Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh | RaceDesign_Khajiit "Focused-emphasis enum" |
| Dunmer ancestor posture | Normal, Strained, Silent, RestoredScarred | RaceDesign_Dunmer "Ancestor posture enum" |
| Khajiit lunar posture | Normal, Strained, Corrupted, ShadowDrift | RaceDesign_Khajiit "Lunar posture enum" |
| Argonian Hist posture | Normal, Distant, Strained, Silenced, Corrupted | RaceDesign_Argonian "Curse posture enum" |

**Argonian layered survey states.** `PDV_Msg_Argonian_Survey_Layered` uses
`%s2` / `%s3` / `%s4` for the three layer readouts. The planning-pass row left
these undefined; the consistency audit (Section 25) flagged the gap. Defined
values:

| Layer | `%s` values (low to high) |
|---|---|
| Hist (`%s2`) | silent, distant, thinning, reaching |
| People (`%s3`) | isolated, strained, holding |
| Void (`%s4`) | dormant, stirring, awake |

---

## 25. Consistency audit log

### 25.1 Audit -- 2026-05-21 (all 606 race rows)

**Scope.** All 606 authored rows across the ten race sections, plus the
manifest's shared conventions. Run after the verification tool
(`tools/pdv_content_verify.mjs`) landed.

**Checked and clean:**
- **ASCII and budgets.** `node tools/pdv_content_verify.mjs` reports
  `FAIL=0, WARN=0, PASS=606`. Every row is ASCII-only and within its
  per-Surface hard cap.
- **Slot-ID uniqueness and convention.** No collisions; all slot IDs match
  the `PDV_(Msg|Notif|Bless|Dlog|PrismaToast|Price)_*` scheme. The longest
  IDs (the Khajiit/Nord favor and champion-ambient slots, ~45-52 chars) sit
  over the 32-char comfort note but under the tool's 64-char warn line; CK
  shorthand at Phase 19 remains acceptable per Section 22 item 8.
- **Voice-by-Surface matrix.** Tool `WARN=0` on the mechanically-checkable
  families (blessing, price, dialogue, survey, posture all narrator/player as
  expected). The documented narrator-voice deviations -- Dunmer vampire
  ash-silenced, the three Imperial curse-states, Khajiit ShadowDrift, the
  Argonian Hist Champion and three Argonian curse-states, the Altmer Lorkhan
  first-interpretation message -- each carry an inline justification in their
  section text. Confirmed intentional.
- **Tier-up register.** Observant / Faithful / Devoted entries were compared
  across all ten races. They share one register (narrator-voice recognition
  ending in the tier name) while carrying race-distinct flavor -- this is the
  intended per-race content variation, not drift.
- **Blessing tone.** Every `PDV_Bless_*` row leads with theology and follows
  with a concrete effect; effects worded qualitatively ("a little faster",
  "full health", "reduced cost") are valid per `PDV_STANDARDS.md` Section 3.3,
  whose own conformance example carries no numerals.
- **Marked surfacing.** The higher Marked counts (Nord 27, Imperial 22) are
  driven by commitment-offer suites and curse-state messages, all legitimately
  Marked MessageBoxes; per-race firing-density sanity sections already show
  Marked *firing* stays inside the `<1 per 2h` target because offers and
  curse onsets are rare events. No `Noted` source event was found promoted to
  `Marked`.

**Gap found and resolved:**
- The `%s` token conventions were never written down, and
  `PDV_Msg_Argonian_Survey_Layered` referenced `%s2`/`%s3`/`%s4` with no
  defined value set. Resolved by adding Section 24 (Token tables), which
  documents the `%s` / `%sN` convention and defines the Argonian layer-state
  vocabulary.

**Result.** No row-level prose rewrites were required; the manifest is
internally consistent. The only change this audit produced is the new
Section 24.
