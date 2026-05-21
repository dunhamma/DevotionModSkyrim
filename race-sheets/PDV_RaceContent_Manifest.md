# PDV Race Content Manifest (1.0)

**Status:** Authoring manifest. Inventory across all 10 races. Full draft prose for Nord, Orc, and Dunmer; slot-only rows for the other 7.
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
   - `PDV_Dlog_<Race>_<NPC|Archetype>_<Slot>` for dialogue topics (placeholder NPC archetype until Section 16.3 dialogue casting fixes the actual NPC alias).
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
| Shrine / privilege dialogue topic (`PDV_Dlog_*`) | Player second-person | NPC voice (within branch, not in topic name) | Topic name reads from the player's seat; the branch itself is NPC dialogue authored separately in CK. |
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
4. Altmer (slot rows only; Altmer is the only Partial implementation-spec; affected slots are flagged)
5. Khajiit (slot rows only; no formal commitment offer per Section 12.4a)
6. Imperial (slot rows only)
7. Redguard (slot rows only)
8. Bosmer (slot rows only; four-path divergence)
9. Breton (slot rows only; three-tradition divergence)
10. Argonian (slot rows only)

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
| PDV_Bless_Nord_Kyne_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Kyne has noticed your steps. Cold resistance +10%. |
| PDV_Bless_Nord_Kyne_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Kyne shelters the hunter who sleeps under her sky. Outdoor rest restores stamina fully. Wild animals stay calm until provoked. |
| PDV_Bless_Nord_Kyne_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Kyne Champion" | Passive SPEL | The storm-mother answers your weather. In wind and rain, shouts and arrows carry farther; power attack stamina cost -10% in the open. |
| PDV_Bless_Nord_Talos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Talos has caught the breath of your Voice. Shout recharge +5%. |
| PDV_Bless_Nord_Talos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The old breath gathers behind your Thu'um. Shout recharge +10%. Defying the Talos ban is counted as worship. |
| PDV_Bless_Nord_Talos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Talos/Ysmir Champion" | Passive SPEL | Talos marks the open defier. Shout recharge +15%. Stormcloak ground and Thalmor defiance return a short surge of stamina and health. |
| PDV_Bless_Nord_Shor_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Shor's hall has noted your sword. When outnumbered in melee, stamina returns a little faster. |
| PDV_Bless_Nord_Shor_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Honor in the fight earns Shor's small mercy. A fair kill restores a small share of health. Companions work weighs double. |
| PDV_Bless_Nord_Shor_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates Section "Shor Champion" | Passive SPEL | Shor watches your bridge approach. Honorable kills restore health by the foe's strength; near death, a brief steadiness holds you up. |
| PDV_Bless_Nord_Tsun_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Tsun marks the bearer of weight. Power attack stamina cost -5%. |
| PDV_Bless_Nord_Tsun_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The shield-thane sees the fight you should have lost. Surviving against severe odds returns a short stamina burst. |
| PDV_Bless_Nord_Tsun_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Tsun's weighing holds. After a trial against three or more foes, stamina holds at twenty percent for one day. Trial-and-challenge work counts double. |
| PDV_Bless_Nord_Stuhn_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Stuhn turns his eye to those who fight for allies. Bonus damage against foes who struck your allies first. |
| PDV_Bless_Nord_Stuhn_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | A ransom kept, a prisoner freed: Stuhn answers in the next fight with a steadier guard. |
| PDV_Bless_Nord_Stuhn_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Stuhn names the merciful sword. Sparing a beaten foe raises your armor sharply for the next fight. Hostage-takers take heavier hits. |
| PDV_Bless_Nord_Mara_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Mara has counted your kindness. Healing magic is five percent more effective. Vendors offer slightly better prices. |
| PDV_Bless_Nord_Mara_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The hearth-mother holds your household. Marriage and home work earn extra devotion. Restoring a community is felt as worship. |
| PDV_Bless_Nord_Mara_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Mara warms your door. Helping a family restores full health on next rest. Temples of Mara grant you healing at reduced cost. |
| PDV_Bless_Nord_Akatosh_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Akatosh holds your hour a little longer. Time-pressure skill checks are slightly more forgiving. |
| PDV_Bless_Nord_Akatosh_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Long devotion does not go unmeasured. Streaks of seven steady days return bonus piety at dawn. |
| PDV_Bless_Nord_Akatosh_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Akatosh keeps your continuance. Unbroken devotion of fourteen days returns cumulative skill experience. Amulet of Akatosh doubles its vanilla effect. |
| PDV_Bless_Nord_Kynareth_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL; Nine Divines lane | Kynareth's road shelters your traveling. Cold resistance +10%. |
| PDV_Bless_Nord_Kynareth_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL; Nine Divines lane | Kynareth steadies the open way. Outdoor rest fully restores stamina; hawks circle before ambushes as a warning. |
| PDV_Bless_Nord_Kynareth_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3", TargetEndStates lines 182-183 | Passive SPEL; Nine Divines lane | Kynareth's grace answers your steps. In wind and rain, shouts and arrows carry farther; outdoor sleep restores more. |
| PDV_Bless_Nord_Arkay_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Arkay marks the keeper of rites. Disease resistance +10%. Undead deal five percent less harm. |
| PDV_Bless_Nord_Arkay_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | A burial done well is owed. Completing a death-rite restores full health on next rest. |
| PDV_Bless_Nord_Arkay_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Arkay's covenant holds. Undead deal twenty percent less harm. Hall of the Dead priests speak to you with priest-recognition. |
| PDV_Bless_Nord_Stendarr_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Stendarr counts the spared hand. Brawl damage +5%. Vigilants of Stendarr stay neutral by default. |
| PDV_Bless_Nord_Stendarr_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Mercy chosen is mercy kept. After sparing a foe in dialogue, the next fight grants a small armor boost. |
| PDV_Bless_Nord_Stendarr_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Stendarr's restraint becomes your armor. Sparing a surrendering foe grants fifteen percent damage resistance for the rest of the fight. |
| PDV_Bless_Nord_Zenithar_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Zenithar weighs honest work. Crafting experience +5%. |
| PDV_Bless_Nord_Zenithar_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The honest hand makes a finer thing. Smithing improvement quality climbs a little. Honest commerce returns small devotion. |
| PDV_Bless_Nord_Zenithar_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Zenithar names the master's work. A crafted item may rise one quality step beyond your perk rank. After an honest sale, your next persuasion has a boost. |
| PDV_Bless_Nord_Julianos_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Julianos reads your study. Novice and Apprentice spells cost three percent less. |
| PDV_Bless_Nord_Julianos_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | Pages turned are devotion paid. Skill books return piety; College work earns extra. |
| PDV_Bless_Nord_Julianos_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Julianos sharpens your study. All spell costs -8%. Reaching a new magic skill rank grants one free cast of that school. |
| PDV_Bless_Nord_Dibella_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 1" | Passive SPEL | Dibella notes the well-said word. Speech +5%. First impressions are warmer. |
| PDV_Bless_Nord_Dibella_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 2" | Passive SPEL | The right word at the right moment carries. After a strong persuasion, the next social check is steadier. |
| PDV_Bless_Nord_Dibella_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Nord Section "Tier 3" | Passive SPEL | Dibella crowns the well-made hour. After a major persuasion or performance, the next equivalent check nearly succeeds on its own. Bards' College work earns strong devotion. |

### 10.3 Tier-up notifications (`PDV_Notif_Nord_*_Tier*Entry`)

Narrator voice. HUD notifications. Budget 80 hard / 60 target. Per `PDV_Architecture_v3.md` Section 16.2: tier change is a Medium event. All Faithful rows carry the `suppress-if-offer-same-dawn` flag.

Tier-up notifications use one shared template per tier (the deity name is the variable position) to avoid sixty bespoke rows. Anti-farm: one per deity per direction per save.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Nord_Observant_Entry | Notification | Noted | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per deity per save; deity inserted by caller | %s has begun to notice your deeds. Observant. |
| PDV_Notif_Nord_Faithful_Entry | Notification | Noted | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per deity per save; suppress-if-offer-same-dawn | Your standing with %s is steady now. Faithful. |
| PDV_Notif_Nord_Devoted_Entry | Notification | Marked | Narrator | 80/60 | TargetEndStates Section "Nord", Architecture v3 Section 16.2 | One per save; the patron's name | %s claims you. Devoted. |
| PDV_Notif_Nord_Observant_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per deity per direction per save | Your standing with %s has slipped to Wavering. |
| PDV_Notif_Nord_Faithful_Lapse | Notification | Noted | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per deity per direction per save | The favor of %s is thinning. Observant. |
| PDV_Notif_Nord_Devoted_Lapse | Notification | Marked | Narrator | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per save per patron loss | The bond with %s loosens. The Devoted bond is not held. |

Note on the `%s` token: this is a single-token substitution slot bound to the deity name, not free-form interpolation. Localization-readiness rule 1 still holds (no string concatenation, no player name); the deity name table is the only externalized variable.

### 10.4 Champion moment recognition

`PDV_TargetEndStates_1.0.md` "Nord Champion moment" section (lines 176-184) names four Champion paths. The pilot deliberately uses three different shapes across them:

- **Kyne Champion**: `Entry + ambient` -- the source explicitly calls out "the texture of being outside" as ongoing recognition.
- **Talos / Ysmir Champion**: `Entry-only` -- the source emphasizes the moment of being marked; the ongoing dialogue privileges live in the Section 10.10 dialogue topics, not in this manifest as ambient lines.
- **Shor Champion**: `Texture-only` -- the source's "honorable kills have a different weight" and "Sovngarde-adjacent content gives more resonance" are gameplay mechanics, not authored strings. No row beyond the Devoted tier-up notification.
- **Kynareth-as-Nord Champion**: `Entry + ambient` -- the source instructs "Same beat as Old Ways Kyne" so the shape matches.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_Kyne_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 179-180 | One-time on first Kyne Devoted | Body: "You sleep where the storm sleeps. You walk where the wind walks. Kyne names her hunter." Title: "Kyne's Recognition" |
| PDV_Notif_Nord_Kyne_ChampionAmbient_Storm | Notification | Noted | Player-2nd | 80/60 | TargetEndStates lines 179-180 | Kyne Devoted + outdoor + storm weather; one per in-game day | The wind is going your way. |
| PDV_Notif_Nord_Kyne_ChampionAmbient_OutdoorRest | Notification | Quiet | Player-2nd | 80/60 | TargetEndStates lines 179-180 | Kyne Devoted + outdoor sleep complete; one per rest | You wake settled. |
| PDV_Msg_Nord_Talos_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 180-181 | One-time on first Talos Devoted | Body: "You did not let me die. The old breath is yours to carry. Speak, and Tamriel hears Talos." Title: "Talos Names You" |
| PDV_Msg_Nord_Shor_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates line 181 | Texture-only Champion: no entry MessageBox at present. Row reserved; prose left for review if Texture-only is overruled. | -- |
| PDV_Msg_Nord_Kynareth_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | TargetEndStates lines 182-183 | One-time on first Kynareth Devoted | Body: "You walked the long road in my sky. Kynareth's grace stays with you in wind and rain." Title: "Kynareth's Grace" |
| PDV_Notif_Nord_Kynareth_ChampionAmbient_Storm | Notification | Noted | Player-2nd | 80/60 | TargetEndStates lines 182-183 | Kynareth Devoted + outdoor + storm; one per in-game day | The road feels held. |

### 10.5 Neglect texture (`PDV_Notif_Nord_*_NeglectTexture`)

Player-second-person voice. Notifications. Budget 80 hard / 60 target. Per `PDV_Architecture_v3.md` Section 14: neglect is absence, not punishment. Each row fires on the first day of a meaningful lapse band crossing for that deity, not continuously.

**ASCII stress-test row:** `PDV_Notif_Nord_General_AncestorsQuiet` deliberately tests whether "the ancestors are quiet" reads under ASCII without leaning on em dashes or ellipses. If this row fails review, raise the cost back against `PDV_Architecture_v3.md` Section 2 invariant 6.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Nord_Kyne_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture", TargetEndStates lines 192-194 | One per lapse-band crossing per deity | The wind passes you by today. |
| PDV_Notif_Nord_Talos_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | Your Voice feels like skill again, not faith. |
| PDV_Notif_Nord_Shor_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The hard fight is only a hard fight. |
| PDV_Notif_Nord_Mara_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" | One per lapse-band crossing per deity | The hearth feels colder when you come home. |
| PDV_Notif_Nord_General_AncestorsQuiet | Notification | Noted | Player-2nd | 80/60 | RaceDesign_Nord Section "Neglect Texture" line 184; TargetEndStates line 194 | One per lapse into the general broad-worship neglect band per save | The ancestors are quiet. |

### 10.6 Commitment offers (`PDV_Msg_Nord_*_Offer` and `PDV_Msg_Nord_OfferResponse_*`)

God-voice on the offer body. Player-second-person on the response options. MessageBox. Body budget 500 hard / 280 target. Title budget 40 hard / 30 target. Per `PDV_Architecture_v3.md` Section 12.3: presented at dawn. Per the Nord design-sheet `Acceptance / no-switching rule`: accepting clears pending Nord offers and sets shared patron state to active primary.

Per-deity offer bodies are authored. Response options (Accept / Not Yet / Refuse) are shared across all Nord commitment offers (and reused as templates for the other races' god-voice patrons in later passes).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Nord_Kyne_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate"; TargetEndStates Section "Nord" | Dawn-fire; one Kyne offer per cooldown window | Title: "Kyne Reaches Back" Body: "You sleep where I am. You hunt where I watch. Will you carry my name now, or will you stay among the many?" |
| PDV_Msg_Nord_Shor_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Shor Calls You" Body: "Your sword is honest. Your dead are counted by Tsun. Take a seat I am keeping for you, or wait and prove the road further." |
| PDV_Msg_Nord_Talos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Talos Marks the Defier" Body: "You would not let them silence me. Carry the old breath openly, and Tamriel will hear Talos through you. Or hold the secret and walk the broad road yet." |
| PDV_Msg_Nord_Tsun_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Tsun Weighs You" Body: "You have stood the bad odds. Will you take the shield-thane's mark, or come at the bridge again unweighed?" |
| PDV_Msg_Nord_Stuhn_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Stuhn Sees the Open Hand" Body: "You have spared what you might have struck. Will you carry the ransom-keeper's name, or wait to be tested further?" |
| PDV_Msg_Nord_Mara_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Mara Opens the Door" Body: "You have made a hearth where there was none. Will you let me hold it with you, or stay welcome among many?" |
| PDV_Msg_Nord_Akatosh_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Akatosh Marks the Hour" Body: "Your days have stayed steady. Take the dragon's keeping, or measure your hours further before you choose." |
| PDV_Msg_Nord_Kynareth_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Kynareth Calls the Traveler" Body: "The road has been good to you because I am good to the road. Carry my name, or hold to the broad reverence." |
| PDV_Msg_Nord_Arkay_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Arkay's Covenant" Body: "You have kept the rites. Will you walk as keeper of the cycle, or come to the door again later?" |
| PDV_Msg_Nord_Stendarr_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Stendarr Stays the Hand" Body: "You have stayed the killing blow. Will you take my mercy as your armor, or hold the question open?" |
| PDV_Msg_Nord_Zenithar_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Zenithar Names the Honest Hand" Body: "Your work is steady, your weight true. Will you carry the trade-god's name, or stay among the broad?" |
| PDV_Msg_Nord_Julianos_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Julianos Reads You" Body: "You have studied with patience. Will you carry the schools' name, or read further before you bind?" |
| PDV_Msg_Nord_Dibella_Offer | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Primary-offer gate" | Dawn-fire; per-deity cooldown | Title: "Dibella's Recognition" Body: "You make beauty where you go. Will you carry my craft openly, or stay among the loved?" |
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
| PDV_Msg_Nord_CurseState_VampireOnset | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary"; Race_Nord Section "Curse States" | Once on becoming vampire | Title: "Sovngarde Closes" Body: "Molag Bal's shadow has fallen across you. Sovngarde will not name you while you carry his thirst. Cure the curse, and even then the scar remains." |
| PDV_Msg_Nord_CurseState_VampireCured | MessageBox | Marked | God-voice | 500/280 | RaceDesign_Nord Section "Curse State Summary" | Once on cure completion | Title: "The Door Stands Ajar" Body: "The thirst is gone. The bridge is open again. But Tsun has seen what walked into the dark, and that is not forgotten." |

### 10.10 Shrine and privilege dialogue topics (`PDV_Dlog_Nord_*`)

Player-second-person on topic name. Branch dialogue itself is NPC voice, authored separately in CK. Topic-line budget 120 hard / 80 target. Per `PDV_Architecture_v3.md` Section 16.3: target ~30-50 race-coded topics for 1.0 across all races; Nord pilot scopes three representative archetypes.

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
| PDV_Bless_Orc_Malacath_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 1" | Passive SPEL; all modes | Malacath has noted your conduct. Smithing experience +5%; Orcish armor you wear adds 5 armor; disease resistance +10%; brawl damage +5%. |
| PDV_Bless_Orc_Malacath_T2_Stronghold | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Orc "Tier 2 -- Stronghold Orc" | Passive SPEL; Stronghold mode | Malacath watches the code carried in full. Your forge work tempers higher. Proving strength against a hard foe restores health after the fight. |
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
| PDV_Bless_Dunmer_GoodDaedra_T1 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Tier 1" | Passive SPEL; shared Layer 1+2 | The ash-prayer is kept and the Good Daedra are acknowledged. Fire resistance +5%; magic resistance +5%. |
| PDV_Bless_Dunmer_GoodDaedra_T2 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Tier 2" | Passive SPEL; shared Layer 1+2 | The Reclamations hold steady around your exile. From dawn to midday, fire resistance +10% and magic resistance +5%. A power-attack kill on a strong foe returns stamina. |
| PDV_Bless_Dunmer_Azura_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Azura focus" | Passive SPEL; Azura focus | Azura watches your thresholds. From dawn to noon, fire and magic resistance climb together; by night, magic costs 10% less. |
| PDV_Bless_Dunmer_Boethiah_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Boethiah focus" | Passive SPEL; Boethiah focus | Boethiah marks proven strength. After felling a significant foe, carry weight +25 and lighter power attacks for a day. The ancestors record the victory. |
| PDV_Bless_Dunmer_Mephala_T3 | Blessing description | Quiet | Narrator | 200/140 | RaceDesign_Dunmer "Mephala focus" | Passive SPEL; Mephala focus | Mephala draws the web close. Poison resistance +20%; the hidden network returns 5% more gold. Discretion opens doors others never see. |

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

## 13. Altmer (slot frame, partial-locked)

Altmer is the only Partial implementation-spec per `PDV_TargetEndStates_1.0.md` lines 76-87. Affected slots are flagged with `(gated)` and listed in the deferred appendix (Section 21) rather than authored.

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Altmer_<AuriEl|Trinimac|Magnus|Xarxes|Psijic>_T<1|2|3>` | RaceDesign_Altmer Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Altmer_<Deity>_<Tier>Entry`, `PDV_Notif_Altmer_<Deity>_<Tier>Lapse` | RaceDesign_Altmer Section "Tier Rewards" |
| Champion entry | `PDV_Msg_Altmer_<Trinimac|Magnus|Psijic>_ChampionEntry` (per faction alignment) | TargetEndStates Section "Altmer Champion moment" |
| Neglect texture | `PDV_Notif_Altmer_<Deity>_NeglectTexture`, plus `PDV_Notif_Altmer_ThalmorAlignment_Drift` (incoherence band crossings) | TargetEndStates lines 348-351 |
| Commitment offer | `PDV_Msg_Altmer_<Deity>_Offer`; reuse response triplet | RaceDesign_Altmer Section "Primary-offer gate" |
| Survey readout | `PDV_Msg_Altmer_Survey_<ThalmorOrthodox|DivineBody|Psijic>` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Altmer_FavorNoted_<Faction>_<TriggerFamily>` | **gated**: contextual-favor lanes Partial per TargetEndStates line 146 |
| Lorkhan crisis-of-faith | `PDV_Msg_Altmer_LorkhanCrisis_<DragonbornDeclaration|SovngardeBeat|MarriageBeat|CompanionsFork>` | **gated**: final crisis trigger list Partial per TargetEndStates line 146 |
| Lorkhan pressure (per tier) | `PDV_Notif_Altmer_LorkhanPressure_T<1|2|3>` | TargetEndStates Section "Lorkhan pressure posture" line 332 |
| Werewolf hard-halt notice | `PDV_Msg_Altmer_CurseState_WerewolfHardHalt` | TargetEndStates Section "Altmer werewolf note" line 351 |
| Vampire flavor | `PDV_Msg_Altmer_CurseState_VampireOnset`, `PDV_Msg_Altmer_CurseState_VampireCured_Exiled` | **gated**: Enhancement custom content per TargetEndStates Section "Custom content priority" line 1536 |

## 14. Khajiit (slot frame)

Implementation-locked. No formal commitment offer per `PDV_Architecture_v3.md` Section 12.4a; focused emphasis emerges silently. `PDV_State_KhajiitFocusedEmphasis` with `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, `Alkosh = 5`.

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Khajiit_<Khenarthi|Azurah|BaanDar|Rajhin|Alkosh>_T<1|2|3>` | RaceDesign_Khajiit Section "Tier Rewards" |
| Lunar substrate readout | `PDV_Msg_Khajiit_LunarPhase_<Masser|Secunda|Crossed>`, `PDV_Msg_Khajiit_LunarPosture_<Normal|Strained|Corrupted|ShadowDrift>` | TargetEndStates Section "Khajiit implementation state" line 359 |
| Tier-up notification | `PDV_Notif_Khajiit_<Deity>_<Tier>Entry`, `PDV_Notif_Khajiit_<Deity>_<Tier>Lapse` | RaceDesign_Khajiit Section "Tier Rewards" |
| Champion entry (silent emergent) | `PDV_Msg_Khajiit_<Deity>_ChampionEntry` -- Champion shape `Entry-only` or `Texture-only`; no god-voice offer | TargetEndStates Section "Khajiit Champion moment", Section "emergent patron exception" |
| Champion ambient | `PDV_Notif_Khajiit_<Deity>_ChampionAmbient_<TwilightThreshold|RoadGrace|ReversalEscape|ElegantTheft|DragonBattle>` | TargetEndStates Section "Khajiit Champion moment" lines 365-369 |
| Neglect texture | `PDV_Notif_Khajiit_LunarThinning_NeglectTexture`, `PDV_Notif_Khajiit_CommunityFading_NeglectTexture` | TargetEndStates lines 378-381 |
| Survey readout | `PDV_Msg_Khajiit_Survey_<Broad|<Deity>>` | Architecture v3 Section 16.2 |
| Road-home acknowledgment | `PDV_Msg_Khajiit_RoadHome_<Designate|Return|MissedCadence>` | TargetEndStates line 359; Architecture v3 Section 21.2 essential content |
| Contextual favor (Noted/Marked) | `PDV_Notif_Khajiit_FavorNoted_<Lane>_<TriggerFamily>`, `PDV_Msg_Khajiit_FavorMarked_<Lane>_<TriggerFamily>` | RaceDesign_Khajiit |
| Curse-state transition | `PDV_Msg_Khajiit_CurseState_<VampireOnset_Corrupted|WerewolfOnset_Strained|ShadowDrift_Entry|ShadowDrift_Exit>` | TargetEndStates line 359 (KhajiitLunarPosture enum) |
| Shrine / privilege dialogue | `PDV_Dlog_Khajiit_<Caravaneer|MoonSinger>_Recognition` | Architecture v3 Section 16.3 |

## 15. Imperial (slot frame)

Implementation-locked. Broad Nine Divines + `PDV_RepTrack_ConcordatStanding` (`Open Defiant`, `Private Defiant`, `Uncommitted`, `Public Compliant`, `Concordat Enforcer`).

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Imperial_<Akatosh|Kynareth|Mara|Zenithar|Arkay|Stendarr|Julianos|Dibella|Talos>_T<1|2|3>` | RaceDesign_Imperial Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Imperial_<Deity>_<Tier>Entry`, `PDV_Notif_Imperial_<Deity>_<Tier>Lapse` | RaceDesign_Imperial |
| Champion entry | `PDV_Msg_Imperial_<Stendarr|Akatosh|Arkay|Talos>_ChampionEntry` | TargetEndStates Section "Imperial Champion moment" lines 230-234 |
| ConcordatStanding band crossing | `PDV_Notif_Imperial_ConcordatStanding_<OpenDefiant|PrivateDefiant|Uncommitted|PublicCompliant|ConcordatEnforcer>_Entry` | TargetEndStates lines 217-220 |
| Neglect texture | `PDV_Notif_Imperial_<Deity>_NeglectTexture`, `PDV_Notif_Imperial_CivicScaffoldingHollow_NeglectTexture` | TargetEndStates lines 242-245 |
| Commitment offer | `PDV_Msg_Imperial_<Deity>_Offer`; reuse response triplet | RaceDesign_Imperial Section "Primary-offer gate" |
| Survey readout | `PDV_Msg_Imperial_Survey_<BroadDivines|Focused>_<ConcordatBand>` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Imperial_FavorNoted_<Lane>_<TriggerFamily>`, `PDV_Msg_Imperial_FavorMarked_<Lane>_<TriggerFamily>` | TargetEndStates lines 207-218 |
| Talos defiance after rupture | `PDV_Msg_Imperial_Talos_PrivateDefiance_Surface`, `PDV_Msg_Imperial_Talos_OpenDefiance_Surface` | TargetEndStates lines 218-220 |
| Curse-state transition | `PDV_Msg_Imperial_CurseState_VampireOnset_CompleteCollapse`, `PDV_Msg_Imperial_CurseState_VampireCured_ReEntry`, `PDV_Msg_Imperial_CurseState_WerewolfOnset` | TargetEndStates Section "Imperial Vampire note" line 246 |
| Shrine / privilege dialogue | `PDV_Dlog_Imperial_<NineDivinesPriest|HallOfTheDead|VigilantOfStendarr|LegionOfficer>_Recognition` | Architecture v3 Section 16.3 |

## 16. Redguard (slot frame)

Implementation-locked. `PDV_State_RedguardSect` with `Crown = 0`, `Forebear = 1`, `AshAbah = 2`. Ancestor reverence always active.

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Redguard_<Satakal|Tuwhacca|Ruptga|Leki|Tava|HoonDing|Onsi|Zeht>_T<1|2|3>` | RaceDesign_Redguard Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Redguard_<Deity>_<Tier>Entry`, `PDV_Notif_Redguard_<Deity>_<Tier>Lapse` | RaceDesign_Redguard |
| Champion entry | `PDV_Msg_Redguard_ChampionEntry_<Crown|Forebear|AshAbah>` | TargetEndStates Section "Redguard Champion moment" lines 433-437 |
| Champion ambient | `PDV_Notif_Redguard_ChampionAmbient_<Tomb|RoadGuided|HoonDingMakeWay|AshAbahDeathDuty>` | TargetEndStates lines 433-441 |
| Sect entry | `PDV_Msg_Redguard_Sect_<Crown|Forebear|AshAbah>_Entry` | RaceDesign_Redguard Section "Implementation state" |
| Neglect texture | `PDV_Notif_Redguard_AncestorsDistant_NeglectTexture`, `PDV_Notif_Redguard_AshAbah_BurdenUnmet_NeglectTexture` | TargetEndStates lines 452-455 |
| Commitment offer | `PDV_Msg_Redguard_<Deity>_Offer`; reuse response triplet | RaceDesign_Redguard |
| Survey readout | `PDV_Msg_Redguard_Survey_<Crown|Forebear|AshAbah>_<Broad|Focused>` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Redguard_FavorNoted_<Sect>_<TriggerFamily>`, `PDV_Msg_Redguard_FavorMarked_<Sect>_<TriggerFamily>` | TargetEndStates lines 422-423 |
| Tu'whacca portable shrine | `PDV_Msg_Redguard_FarShoresToken_<Activate|PrivateContext>` | TargetEndStates Section "Tu'whacca surface" line 428 |
| HoonDing make-way | `PDV_Msg_Redguard_HoonDingMakeWay_<DragonClear|NamedBossClear|FinalBoss>` | TargetEndStates Section "Hook feasibility" line 426; line 441 |
| Curse-state transition | `PDV_Msg_Redguard_CurseState_VampireOnset`, `PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry`, `PDV_Msg_Redguard_CurseState_WerewolfOnset` | TargetEndStates Section "Redguard Vampire cure recovery note" line 457 |
| Shrine / privilege dialogue | `PDV_Dlog_Redguard_<AlikR|HallOfTheDead|TombKeeper>_Recognition` | Architecture v3 Section 16.3 |

## 17. Bosmer (slot frame)

Implementation-locked. Four-path divergence. `PDV_State_BosmerPath` with `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`.

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Bosmer_<Yffre|Arkay|Xarxes|Mara|Stendarr|Zen|BaanDar>_T<1|2|3>` | RaceDesign_Bosmer Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Bosmer_<Deity>_<Tier>Entry`, `PDV_Notif_Bosmer_<Deity>_<Tier>Lapse` | RaceDesign_Bosmer |
| Champion entry per path | `PDV_Msg_Bosmer_ChampionEntry_<OldContract|LivingStory|Exchange|BanditRoad>` | TargetEndStates Section "Bosmer Champion moment" lines 396-401 |
| Path setup choice | `PDV_Msg_Bosmer_PathChoice_Setup`, `PDV_Msg_Bosmer_Path_<OldContract|LivingStory|Exchange|BanditRoad>_Entry` | RaceDesign_Bosmer Section "Implementation state"; TargetEndStates Section "Path switching" line 393 |
| Old Contract forced reckoning | `PDV_Msg_Bosmer_OldContract_ForcedReckoning_<Recommit|Renounce>`, `PDV_Msg_Bosmer_OldContract_Terminal` | TargetEndStates Section "Forced reckoning moment" line 408; Section "Bosmer Neglect texture" line 411 |
| Green Pact compliance feedback | `PDV_Notif_Bosmer_GreenPact_<Strict|Lapsed|Apostate>_BandEntry` | RaceDesign_Bosmer Section "Shared Pact memory"; deferred per-item feedback per Architecture v3 Section 21.2 |
| Neglect texture | `PDV_Notif_Bosmer_<Path>_NeglectTexture` | TargetEndStates Section "Bosmer Neglect texture" lines 410-414 |
| Survey readout | `PDV_Msg_Bosmer_Survey_<Path>_<Broad|Focused>` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Bosmer_FavorNoted_<Path>_<TriggerFamily>`, `PDV_Msg_Bosmer_FavorMarked_<Path>_<TriggerFamily>` | RaceDesign_Bosmer |
| Werewolf Druidic Trial fork (Green Way) | `PDV_Msg_Bosmer_GreenWay_DruidicTrial_<TheBeastServesGreen|TheBeastTakesOver>` | TargetEndStates Section "Druidic Standing + Werewolf fork" line 280; Breton/Bosmer overlap referenced |
| Curse-state transition | `PDV_Msg_Bosmer_CurseState_<VampireOnset|VampireCured|WerewolfOnset>` | RaceDesign_Bosmer Section "Curse States" |
| Shrine / privilege dialogue | `PDV_Dlog_Bosmer_<YffreShrine|GraahliTradition>_Recognition` | Architecture v3 Section 16.3 |

## 18. Breton (slot frame)

Implementation-locked. Three-tradition divergence. `PDV_State_BretonTradition` with `KnightsRoad`, `HiddenArt`, `GreenWay`. Tracks: `WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding`.

| Category | Slot pattern | Source |
|---|---|---|
| Blessing description | `PDV_Bless_Breton_<Stendarr|Akatosh|Yffre|<DaedricPrince>>_T<1|2|3>` | RaceDesign_Breton Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Breton_<Deity>_<Tier>Entry`, `PDV_Notif_Breton_<Deity>_<Tier>Lapse` | RaceDesign_Breton |
| Tradition setup | `PDV_Msg_Breton_TraditionChoice_Setup`, `PDV_Msg_Breton_Tradition_<KnightsRoad|HiddenArt|GreenWay>_Entry` | TargetEndStates Section "Breton Implementation-lock note" line 254 |
| Champion entry per tradition | `PDV_Msg_Breton_ChampionEntry_<KnightsRoad|HiddenArt|GreenWay>` | TargetEndStates Section "Breton Champion moment" lines 270-275 |
| Knightly Vow Integrity band | `PDV_Notif_Breton_KnightlyVowIntegrity_<Strong|Strained|Broken>_BandEntry` | TargetEndStates Section "Track math posture" line 264 |
| Witchcraft Exposure band | `PDV_Notif_Breton_WitchcraftExposure_<Hidden|Visible|Notorious>_BandEntry` | TargetEndStates Section "Recovery cadence posture" line 266 |
| Druidic Standing band | `PDV_Notif_Breton_DruidicStanding_<Open|Acknowledged|Embraced>_BandEntry` | TargetEndStates line 264 |
| Vigilant pressure encounter | `PDV_Msg_Breton_VigilantPressure_<Letter|RoadEncounter|Confrontation>` | TargetEndStates Section "Vigilant pressure note", Section "Extension candidate" lines 260-262; **gated**: may slip post-1.0 per "should not block Breton 1.0 unless the encounter pattern proves cheap" |
| Druidic Trial fork (Green Way werewolf) | `PDV_Msg_Breton_GreenWay_DruidicTrial_<TheBeastServesGreen|TheBeastTakesOver>` | TargetEndStates Section "Druidic Standing + Werewolf fork" line 280 |
| Neglect texture | `PDV_Notif_Breton_<Tradition>_NeglectTexture` | TargetEndStates Section "Breton Neglect texture" lines 282-285 |
| Survey readout | `PDV_Msg_Breton_Survey_<Tradition>` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Breton_FavorNoted_<Tradition>_<TriggerFamily>`, `PDV_Msg_Breton_FavorMarked_<Tradition>_<TriggerFamily>` | TargetEndStates Section "Contextual favor posture" line 268 |
| Curse-state transition | `PDV_Msg_Breton_CurseState_<VampireOnset|VampireCured|WerewolfOnset_GreenWayFork|WerewolfOnset_NonGreenWay>` | RaceDesign_Breton Section "Curse States" |
| Shrine / privilege dialogue | `PDV_Dlog_Breton_<StendarrShrine|NightingaleSentinel|DruidicCirclekeeper>_Recognition` | Architecture v3 Section 16.3 |

## 19. Argonian (slot frame)

Implementation-locked. Single layered Hist substrate (Hist, People, Void). `PDV_State_ArgonianHistPosture` with `Normal = 0`, `Distant = 1`, `Strained = 2`, `Silenced = 3`, `Corrupted = 4`. No deity choice.

| Category | Slot pattern | Source |
|---|---|---|
| Substrate readout (Hist/People/Void) | `PDV_Msg_Argonian_Hist_<Distance>`, `PDV_Msg_Argonian_People_<Belonging>`, `PDV_Msg_Argonian_Void_<Dormancy|Active>` | TargetEndStates Section "Argonian Implementation state" lines 498-499 |
| Blessing description | `PDV_Bless_Argonian_<Hist|People|Void>_T<1|2|3>` | RaceDesign_Argonian Section "Tier Rewards" |
| Tier-up notification | `PDV_Notif_Argonian_<Layer>_<Tier>Entry`, `PDV_Notif_Argonian_<Layer>_<Tier>Lapse` | RaceDesign_Argonian |
| Champion entry per layer | `PDV_Msg_Argonian_ChampionEntry_<Hist|People|Void>` | TargetEndStates Section "Argonian Champion moment" lines 507-511 |
| Hist sap meditation prompt | `PDV_Msg_Argonian_HistSapMeditation_<Activate|Effect>` | TargetEndStates Section "Hist distance" line 500; Section "Custom content priority" line 1529; Architecture v3 Section 21.2 |
| Bed of choice anchor | `PDV_Msg_Argonian_BedOfChoice_<Designate|Return|MissedCadence>` | TargetEndStates Section "Bed of choice" line 502 |
| Sithis activation threshold | `PDV_Msg_Argonian_SithisActivation_<FirstSignal|FullActivation>` | TargetEndStates Section "Sithis activation" line 504 |
| Neglect texture | `PDV_Notif_Argonian_HistThinning_NeglectTexture`, `PDV_Notif_Argonian_PeopleIsolation_NeglectTexture`, `PDV_Notif_Argonian_VoidDormancy_NeglectTexture` | TargetEndStates Section "Argonian Neglect texture" line 517 |
| Posture transition | `PDV_Msg_Argonian_HistPosture_<Distant|Strained|Silenced|Corrupted>_Entry` | TargetEndStates Section "Curse posture" line 519 |
| Survey readout | `PDV_Msg_Argonian_Survey_Layered` | Architecture v3 Section 16.2 |
| Contextual favor (Noted/Marked) | `PDV_Notif_Argonian_FavorNoted_<Lane>_<TriggerFamily>`, `PDV_Msg_Argonian_FavorMarked_<Lane>_<TriggerFamily>` | RaceDesign_Argonian |
| Curse-state transition | `PDV_Msg_Argonian_CurseState_VampireOnset_HistSilenced`, `PDV_Msg_Argonian_CurseState_VampireCured`, `PDV_Msg_Argonian_CurseState_WerewolfOnset_Strain` | TargetEndStates Section "Curse posture" line 519 |
| Shrine / privilege dialogue | `PDV_Dlog_Argonian_<WindhelmAssemblage|RiftenDocks|HistKeeper>_Recognition` | Architecture v3 Section 16.3 |

Note: Argonian has no standard commitment-offer slot because there is no deity choice. The People layer's belonging milestones use `PDV_Msg_Argonian_People_*` flavor rather than offer copy.

---

## 20. Coverage check (Section 9 priority order)

| Race | Tone profiles | Blessings | Tier-up | Champion | Neglect | Offer | Survey | Favors | Curse | Dialogue topics | Pilot prose |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Nord | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Orc | drafted | drafted | drafted | drafted | drafted | n/a | drafted | drafted | drafted | drafted | YES |
| Dunmer | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted | YES |
| Altmer | slot only | slot only | slot only | slot only | slot only | slot only | slot only | gated | gated | gated | -- |
| Khajiit | slot only | slot only | slot only | slot only | slot only | n/a | slot only | slot only | slot only | slot only | -- |
| Imperial | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | -- |
| Redguard | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | slot only | -- |
| Bosmer | slot only | slot only | slot only | slot only | slot only | n/a (path setup) | slot only | slot only | slot only | slot only | -- |
| Breton | slot only | slot only | slot only | slot only | slot only | n/a (tradition setup) | slot only | gated (Vigilant) | slot only | slot only | -- |
| Argonian | slot only | slot only | slot only | slot only | slot only | n/a | slot only | slot only | slot only | slot only | -- |

`n/a` rows mean the race does not use the standard commitment-offer pattern (Khajiit silent emergent, Orc mode-deepening, Bosmer setup choice, Breton tradition setup, Argonian no deity choice). The setup-choice MessageBoxes for Bosmer and Breton are slot-only rows in their sections, not in the commitment-offer pattern.

---

## 21. Gated and deferred appendix

These slots are deliberately not authored in this pass.

| Item | Gate | Reason |
|---|---|---|
| Altmer crisis-of-faith trigger copy | Close out Altmer Partial implementation-spec: crisis resolution hooks, final crisis trigger list, contextual-favor lanes, focused-deity hook posture (`PDV_TargetEndStates_1.0.md` line 146). | Spec is Partial; authoring now risks rework. |
| Altmer contextual-favor Marked rows | Same gate. | Lanes are Partial. |
| Altmer post-vampire Exiled flavor | Enhancement custom content category (`PDV_Architecture_v3.md` Section 21.2). | Not required for core function. |
| Daedric path price/stigma/boon copy beyond Boethiah | Daedric path architecture (`PDV_Architecture_v3.md` Section 11) pilots only Boethiah; 8-12 paths total target for 1.0 (Section 21.1). Each requires the Section 11 contract field expansion before string authoring. | One Prince pilot proven; remaining are scaffolded only. |
| Bosmer Green Pact per-item violation feedback | `PDV_Architecture_v3.md` Section 21.2 essential custom content: PDV-owned Green Pact tag layer must ship first. | Item-level surfacing depends on the tag layer existing. |
| MCM player tab copy | `PDV_Architecture_v3.md` Section 16.1, Section 16.4: MCM should not be a daily management surface. | Authored alongside the player tab itself, not as flavor content. |
| Localization / non-ASCII variants | `PDV_Architecture_v3.md` Section 23: deferred post-1.0; minor refactor via string-table externalization. | Out of 1.0 scope by architecture. |
| Breton Vigilant pressure encounter copy | `PDV_TargetEndStates_1.0.md` Section "Extension candidate" lines 260-262: should not block Breton 1.0 unless the encounter pattern proves cheap. | Slip-able to post-1.0. |
| Daedric race-by-Prince matrix expansion strings | `references/phase4/PDV_DaedricRacePrinceMatrix.csv` is the implementation matrix; race sheets are acceptance context only. | Each cell must be expanded into the Section 11 contract before strings are authored. |

---

## 22. Verification checklist

This manifest's own verification, per the plan:

1. **Coverage:** every race in Section 9 has a section. Path/sect-divergent races have rows per path. -- See Section 20 table.
2. **Source-citation:** every drafted Nord row has a Source column entry pointing at a real file/line range. Spot-check 10 at random.
3. **ASCII:** `LC_ALL=C grep -nP '[^\x00-\x7F]' race-sheets/PDV_RaceContent_Manifest.md` returns no matches.
4. **Nord pilot completeness:** every Nord row has non-empty `Draft prose` except `PDV_Msg_Nord_Shor_ChampionEntry`, which is intentionally `Texture-only` per Section 10.4 and reserved with a notes-column comment.
5. **Blessing discipline:** Nord blessing rows lead with theological tone and follow with a concrete numeric effect, matching the `PDV_STANDARDS.md` Section 3.3 conformance example. No formids, no `PDV_*` record names in prose, no `bucket` / `hook` jargon.
6. **Surfacing-vs-source:** every `Marked` row is one the source explicitly named as Marked or as a high-cost / costly-but-faithful moment. The two Marked Talos rows in Section 10.8 are flagged by `RaceDesign_Nord` lines 128 and 138 respectively.
7. **Deferred appendix:** Altmer crisis copy, Daedric paths beyond Boethiah, Green Pact per-item feedback, MCM player tab, localization, Vigilant pressure, and Daedric matrix expansion all appear in Section 21 with the gate cited.
8. **Slot-ID convention:** every Nord slot id matches the `PDV_Msg_*` / `PDV_Notif_*` / `PDV_Bless_*` / `PDV_Dlog_*` / `PDV_PrismaToast_*` scheme. None exceed 32 EditorID characters where the CK editor truncates. (Longest Nord id: `PDV_Notif_Nord_Kynareth_ChampionAmbient_Storm` is 45 chars; flagged for review -- some CK fields tolerate longer EditorIDs but MESG/SPEL EditorIDs are safer under 32. Recommend `PDV_Notif_Nord_Kyn_ChampAmb_Storm` style abbreviations at Phase 19 hand-off if the truncation rule bites. Slot id stability vs. the manifest is the contract; CK shorthand is acceptable so long as the Slot ID column carries both.)
9. **Length-budget:** every Nord `Draft prose` cell is at or under the row's `Budget` cap. The longest drafted body is `PDV_Msg_Nord_CurseState_VampireOnset` at 252 chars (under the 500 hard / 280 target). Notifications stay at or under 60 chars in nearly all cases; the few that touch 70-80 carry the body inside the 80 hard cap.
10. **Voice-matrix compliance:** every Nord row's `Voice` matches the Section 3 matrix. No drift.
11. **Localization-readiness:** the only externalized tokens are the `%s` deity-name and tier-name substitutions in Section 10.3 tier-up notifications and Section 10.7 status readouts. No player-name interpolation, no string concatenation, no embedded numerals in prose (numbers in blessing descriptions are mechanical effects per Section 4 budget exception and match `PDV_STANDARDS.md` Section 3.3).
12. **Firing-density:** Section 10.11 sanity table confirms Nord steady play stays inside the `Marked < 1 per 2h` and `Noted < 2 per h` targets.
13. **Tone-profile coverage:** every Nord deity referenced by a Section 10.2-10.10 row has a Section 10.1 tone-profile entry.
14. **ASCII stress-test:** the two named stress-test rows -- `PDV_Notif_Nord_General_AncestorsQuiet` ("The ancestors are quiet.") and `PDV_Msg_Nord_FavorMarked_TalosDefiance` ("You stood between them and me. Carry the old breath a little longer.") -- read naturally under ASCII without em dashes or ellipses. The rule is not raising cost back to the user.

---

## 23. Next slice

Nord, Orc, and Dunmer carry full draft prose. The natural next pass extends draft prose to the next race in Section 9 priority order (Altmer). Altmer is the only Partial implementation-spec: its blessing, tier-up, neglect, offer, survey, and Lorkhan-pressure slots are authorable now, but the contextual-favor Marked rows, the Lorkhan crisis-of-faith copy, and the post-vampire flavor stay gated per Section 21 until the spec closes. The next pass authors the non-gated Altmer slots and leaves the gated ones explicitly marked.
