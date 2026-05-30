# PDV Content Destination Matrix (writer-facing)

**Purpose.** A single editable picture of *where every kind of written string
lives* in the project, so the author can answer "if I write this line, which
file does it go in, and which file is its source of truth?" without paging
through the architecture or the 2000-line content manifest.

**Editing.** This file is meant to be redlined and fed back. Mark any cell
that looks wrong with `[CHECK: ...]` inline; do not feel obliged to keep the
markdown table syntax tidy while editing -- the next pass will reflow.

**Not authoritative.** The locked specs are still:
- `PDV_Architecture_v3.md` (system behavior)
- `race-sheets/PDV_RaceContent_Manifest.md` (every race-facing string)
- `race-sheets/PDV_DaedricContent_Manifest.md` (every Daedric-path string)
- `PDV_STANDARDS.md` (voice / budget / ASCII rules)

This file is a navigation aid over those.

---

## 1. The four destinations (read this first)

Every string in the mod passes through up to four documents, in order:

| # | Destination | What lives here | Who reads it |
|---|---|---|---|
| 1 | **Design source** | The *intent* of a string -- which deity, which tier, which mechanic it announces. No prose. | Designer / architect |
| 2 | **Manifest draft** | The actual ASCII English prose, in a row keyed by `Slot ID`. One row per shippable string. | Writer (you) |
| 3 | **Shipped CK record** | The Creation Kit record (SPEL desc, MESG body+title, NOTI text, DLOG topic) that the game actually reads. | Phase 19 implementer |
| 4 | **Player handbook** | Promoted, ratified prose folded back into the public `Race_*.md` reading material. | Player / lore reader |

The pipeline is **Design -> Draft -> Ship -> Promote**, and a string's "home"
depends on which stage you are working in.

### 1.1 Files per destination

| Destination | Files |
|---|---|
| Design source | `PDV_Architecture_v3.md`, `PDV_RaceDesign_<Race>.md` (10 files), `references/phase4/PDV_DaedricRacePrinceMatrix.csv`, `references/phase4/PDV_RaceSignalMatrix.csv`, `references/phase4/PDV_StanceMatrix.csv`, `PDV_TargetEndStates_1.0.md` |
| Manifest draft | `race-sheets/PDV_RaceContent_Manifest.md`, `race-sheets/PDV_DaedricContent_Manifest.md` |
| Shipped CK record | ESP records (not in repo yet; authored in Phase 19) -- record types: SPEL `DESC`, MESG `FULL`+`DESC`, MESG title, dialogue `TOPIC` |
| Player handbook | `race-sheets/Race_<Race>.md` (10 files) |

---

## 2. Surface -> Destination map

Every Surface (the kind of string the writer is drafting) maps to a single
slot-id pattern, a single CK record type, and a known voice + budget. This is
the canonical lookup when the writer is staring at a draft and asking "what
is this thing, mechanically?"

| Surface | Slot-id prefix | CK record | Voice | Budget (hard / target) | Design source field | Drafted in | Handbook impact |
|---|---|---|---|---|---|---|---|
| Blessing description | `PDV_Bless_<Race>_<Deity>_T<1-3>` | SPEL `DESC` | Narrator | 200 / 140 | `RaceDesign Tier Rewards` | Race manifest section 10-19 `.2` | Race_*.md "Paths of Devotion" lines |
| Boon description (Daedric) | `PDV_Bless_Daedric_<Prince>_<Tier>` | SPEL `DESC` | Narrator | 200 / 140 | `DaedricMatrix Boon` | Daedric manifest 6.2 (Boethiah) | none (no Daedric handbook yet) |
| Price description (Daedric) | `PDV_Price_Daedric_<Prince>_<Tier>` | SPEL `DESC` | Narrator | 200 / 140 | `DaedricMatrix PrimaryPrice` | Daedric manifest 6.3 | none |
| Tier-up notification | `PDV_Notif_<Race>_<Deity>_Tier<n>Entry` | MESG (HUD NOTI) | Narrator | 80 / 60 | Architecture v3 Sec 10 tier model | Race manifest `.3` | none (transient) |
| Champion entry | `PDV_Msg_<Race>_<Deity>_ChampionEntry` | MESG box (FULL+DESC) | God-voice (or Narrator if Texture-only) | 500 / 280 + 40 title | RaceDesign / EndStates Champion lines | Race manifest `.4` / `.5` | Race_*.md "Champion moment" if folded |
| Champion ambient | `PDV_Notif_<Race>_<Deity>_ChampionAmbient_<context>` | MESG (HUD NOTI) | Player-2nd | 80 / 60 | RaceDesign Champion ambient list | Race manifest `.4` / `.5` | none |
| Neglect texture | `PDV_Notif_<Race>_<Deity>_NeglectTexture` | MESG (HUD NOTI) | Player-2nd | 80 / 60 | RaceDesign Neglect Texture | Race manifest `.5` / `.7` / `.8` | none |
| Commitment offer (body) | `PDV_Msg_<Race>_<Deity>_Offer` | MESG box | God-voice | 500 / 280 + 40 title | Architecture v3 Sec 10.5 offer model | Race manifest `.6` / `.7` | Race_*.md "How Devotion Works" framing |
| Commitment offer (response) | `PDV_Msg_<Race>_OfferResponse_<Accept|Decline>` | MESG button text | Player-2nd | 40 / 30 | Architecture v3 Sec 10.5 | Race manifest `.6` / `.7` | none |
| Commitment pact (Daedric) | `PDV_Msg_Daedric_<Prince>_Commitment` | MESG box | God-voice | 500 / 280 + 40 title | Architecture v3 Sec 11.3 | Daedric manifest 6.5 | none |
| Survey Devotion readout | `PDV_Msg_<Race>_Survey_<variant>` | SPEL `DESC` (status spell) | Narrator | 240 / 180 | Architecture v3 Sec 16 Survey model | Race manifest `.7` / `.8` / `.9` | none (player UI) |
| Contextual favor (Noted) | `PDV_Notif_<Race>_FavorNoted_<lane>` | MESG (HUD NOTI) | Player-2nd | 80 / 60 | RaceDesign Contextual Favor Pilot Table | Race manifest `.8` / `.9` / `.10` | none |
| Contextual favor (Marked) | `PDV_Msg_<Race>_FavorMarked_<lane>` | MESG box | God-voice | 500 / 280 + 40 title | RaceDesign Contextual Favor Pilot Table | Race manifest `.8` / `.9` / `.10` | rare; can fold to Race_*.md if iconic |
| Curse-state transition | `PDV_Msg_<Race>_CurseState_<state>` | MESG box | God-voice | 500 / 280 + 40 title | RaceDesign Curse State Summary | Race manifest `.9` / `.11` / `.13` | Race_*.md "Curse States" |
| Shrine / privilege dialogue topic | `PDV_Dlog_<Race>_<topic>` | dialogue TOPIC text | Player-2nd | 120 / 80 | RaceDesign Signal Examples / shrine list | Race manifest `.10` / `.12` / `.14` | none (player chooses in-game) |
| Stigma band crossing (Daedric) | `PDV_Notif_Daedric_<Prince>_Stigma_<band>` | MESG (HUD NOTI) | Narrator | 80 / 60 | Architecture v3 Sec 11.2 + Daedric manifest Sec 5 | Daedric manifest 6.6 | none |
| Per-race Daedric response | `PDV_Msg_Daedric_<Prince>_Response_<Race>` | MESG box | Narrator | 500 / 280 + 40 title | DaedricMatrix per-race cells | Daedric manifest 6.8 | Race_*.md "The Daedric Question" |
| Daedric exit | `PDV_Msg_Daedric_<Prince>_Exit` | MESG box | God-voice | 500 / 280 + 40 title | Architecture v3 Sec 11.4 / 11.6 | Daedric manifest 6.7 | none |
| Race-specific posture readout | `PDV_Msg_<Race>_<Track>Posture_*` (Dunmer Ancestor, Argonian Hist, etc.) | MESG box / SPEL DESC | Narrator | 240 / 180 | RaceDesign track model | Race manifest `.2` (Dunmer/Argonian/Khajiit) | Race_*.md "How Devotion Works" framing |
| Race-specific band/track crossing | `PDV_Notif_<Race>_<Track>_<band>` (Altmer Thalmor, Imperial Concordat, Bosmer GreenPact, Breton Witchcraft etc.) | MESG (HUD NOTI) | Narrator | 80 / 60 | RaceDesign track | Race manifest race-specific subsections | none |
| Prisma overlay toast | `PDV_PrismaToast_<event>` | UI toast | Symbol-led, minimal | 60 / 40 | Architecture v3 Sec 16.5 | (not yet in manifests -- gated) | none |

Note: section numbers like `.2 / .3 / .4` are *positional within each race
section*. Nord is section 10, Orc 11, Dunmer 12, Altmer 13, Khajiit 14,
Imperial 15, Redguard 16, Bosmer 17, Breton 18, Argonian 19. So Nord
blessings live at 10.2; Argonian dialogue topics live at 19.14.

---

## 3. Race x Surface coverage grid

The cell shows the manifest subsection that holds the drafted prose, or one
of:

- `n/a` -- race does not use this surface (architecturally)
- `gated` -- surface exists in design but is intentionally not drafted yet
- `deferred` -- surface is post-1.0
- empty -- the surface has not yet been considered for this race

Sources: race manifest section 20 (Coverage check) plus per-race subsection
headers.

| Surface \ Race           | Nord  | Orc   | Dunmer | Altmer | Khajiit | Imperial | Redguard | Bosmer | Breton | Argonian |
|---|---|---|---|---|---|---|---|---|---|---|
| Tone profiles            | 10.1  | 11.1  | 12.1   | 13.1   | 14.1    | 15.1     | 16.1     | 17.1   | 18.1   | 19.1     |
| Blessings                | 10.2  | 11.2  | 12.3   | 13.2   | 14.3    | 15.2     | 16.2     | 17.2   | 18.2   | 19.3     |
| Tier-up notifications    | 10.3  | 11.3  | 12.4   | 13.3   | 14.4    | 15.3     | 16.3     | 17.3   | 18.3   | 19.4     |
| Champion entry / ambient | 10.4  | 11.4  | 12.5   | 13.4   | 14.6    | 15.5     | 16.5     | 17.4   | 18.6   | 19.5     |
| Neglect texture          | 10.5  | 11.5  | 12.7   | 13.5   | 14.7    | 15.6     | 16.6     | 17.8   | 18.9   | 19.9     |
| Commitment offer         | 10.6  | n/a   | 12.6   | 13.8   | n/a (silent) | 15.7 | 16.7     | n/a (path setup 17.5) | n/a (tradition setup 18.4) | n/a |
| Survey readout           | 10.7  | 11.6  | 12.8   | 13.9   | 14.8    | 15.8     | 16.8     | 17.9   | 18.10  | 19.11    |
| Contextual favors        | 10.8  | 11.7  | 12.9   | 13.13 | 14.9 | 15.9 | 16.9   | 17.10  | 18.11  | 19.12    |
| Curse-state transitions  | 10.9  | 11.9  | 12.11  | 13.10  | 14.11   | 15.10    | 16.11    | 17.11  | 18.12  | 19.13    |
| Shrine / dialogue topics | 10.10 | 11.10 | 12.12  | 13.12  | 14.12   | 15.11    | 16.12    | 17.12  | 18.13  | 19.14    |
| Race-specific extras     | --    | LifeMode 11.8 | AncestorPosture 12.2 / Tribunal 12.10 | LorkhanPressure 13.6 / ThalmorAlignment 13.7 / LorkhanInterp 13.11 | LunarPhase 14.2 / FocusEmergence 14.5 / RoadHome 14.10 | ConcordatStanding 15.4 | SectEntry 16.4 / FarShoresToken 16.10 | PathChoice 17.5 / OldContract 17.6 / GreenPact 17.7 | TraditionChoice 18.4 / FocusEmergence 18.5 / Track bands 18.7 / DruidicTrial 18.8 | HistPosture 19.2 / HistSap 19.6 / BedOfChoice 19.7 / SithisActivation 19.8 / PostureTransitions 19.10 |

### 3.1 Author state (race manifest Section 20, condensed)

| Race | State | Open items |
|---|---|---|
| Nord | drafted (full pilot) | -- |
| Orc | drafted | -- |
| Dunmer | drafted | -- |
| Altmer | drafted | Altmer crisis/contextual/Exiled rows closed in RaceContent Manifest Section 13.13 after the 2026-05-30 implementation-spec closeout |
| Khajiit | drafted | -- |
| Imperial | drafted | -- |
| Redguard | drafted | -- |
| Bosmer | drafted | Green Pact per-item violation feedback (needs PDV-owned tag layer first) |
| Breton | drafted | Vigilant pressure encounter copy (Section 18.14; slip-able post-1.0) |
| Argonian | drafted | -- |

---

## 4. Daedric Prince x Status grid

Source: `PDV_DaedricContent_Manifest.md` Sections 6-8 and
`references/phase4/PDV_DaedricRacePrinceMatrix.csv`.

Surfaces per Prince (rows): Tone, Boon, Price, Tier-up, Commitment, Stigma,
Neglect / Exit, Per-race response (8 non-native cells per Prince).

| Prince | PrincePathType | Manifest section | State | Notes |
|---|---|---|---|---|
| Boethiah / Boethra | Struggle-overthrow-trial | 6 (full) | **drafted (pilot)** | Native-integrated for Dunmer + Khajiit (those treatments live in race manifest) |
| Azura / Azurah | Fate-dawn-dusk-prophecy | 7 (stub) | not drafted | Native for Dunmer + Khajiit -- Daedric path covers other 8 races |
| Mephala / Mafala | Web-secret-murder-clan | 7 (stub) | not drafted | Native for Dunmer + Khajiit |
| Malacath / Mauloch | Oath-exile-code-vengeance | 7 (stub) | not drafted | Native for Orc -- Daedric path covers other 9 races |
| Meridia | Cleansing-light overlay | 7 (stub) | not drafted | Lighter stigma; Tolerated by several races |
| Hircine | Hunt-lycanthropy-predator | 7 (stub) | not drafted | **Curse-access** -- entry via lycanthropy; reframed commitment slot |
| Molag Bal | Domination-vampirism-enslavement | 7 (stub) | not drafted | **Curse-access** -- entry via vampirism |
| Nocturnal | Shadow-oath-luck-debt | 7 (stub) | not drafted | Entry via Thieves Guild / Nightingale |
| Hermaeus Mora | Forbidden-knowledge-artifact | 7 (stub) | not drafted | Black Book hooks; strong on Solstheim |
| Mehrunes Dagon | Destruction-revolution-ruin | 7 (stub) | not drafted | High-rupture; enemy pressure for Imperials |
| Sheogorath | Madness-disruption-instability | 7 (stub) | not drafted | Wabbajack / Mind of Madness |
| Namira / Namiira | Revulsion-decay-outcast-hunger | 7 (stub) | not drafted | Strong social + ancestor friction |
| Sanguine / Sangiin | Excess-temptation-indulgence | 7 (stub) | not drafted | Light-touch path |
| Clavicus Vile | Bargain-wish-contract | 7 (stub) | not drafted | Bargain price must stay visible in copy |
| Peryite | Plague-order-lowest-task | 7 (stub) | not drafted | Narrow, quest-anchored |
| Vaermina | Dream-nightmare-memory | 7 (stub) | not drafted | Skull of Corruption hooks |
| Jyggalag | -- | -- | **out of 1.0 scope** | Per `PDV_TargetEndStates_1.0.md` |

1.0 target per Architecture v3: **all sixteen Skyrim-present Daedric Prince
surfaces content-ready for every race**. Buildability and vanilla hook strength
(matrix `BuildabilityTag` and `VanillaHookPriority` columns) still guide
authoring order, but no Skyrim-present Prince is optional for 1.0. Jyggalag
remains out of scope unless future adopted content explicitly adds him.

---

## 5. Voice / budget cheat sheet (paste over your monitor)

| If the surface is... | ...the voice is... | ...the budget is (hard / target) |
|---|---|---|
| HUD notification (NOTI) | Narrator OR Player-2nd (see surface map) | 80 / 60 chars |
| MessageBox title | -- | 40 / 30 chars |
| MessageBox body | God-voice for offers/commitments/curse/Champion entries; Narrator for surveys + per-race responses + stigma; Player-2nd for offer-responses | 500 / 280 chars |
| Blessing / Boon / Price (SPEL DESC) | Narrator | 200 / 140 chars |
| Survey Devotion readout (status SPEL) | Narrator | 240 / 180 chars |
| Dialogue topic (player line) | Player-2nd | 120 / 80 chars |
| Prisma overlay toast | symbol-led, minimal | 60 / 40 chars |

Rules that bite regardless of surface (race manifest Section 7):

1. No string interpolation (no `"Kyne knows " + playerName`).
2. No concatenation across slots -- each row is one string.
3. No embedded numerals where the tier vocabulary will do (`"Faithful"` ok;
   `"50 piety"` not).
4. ASCII only -- no em dashes, no smart quotes, no ellipsis character. Use
   `--` and `...` literally.

---

## 6. Promotion path (Manifest -> Handbook)

Most manifest rows do **not** appear in the player handbooks. Promote a row
to `Race_<Race>.md` when:

- It is a Blessing description and the handbook needs to describe what the
  player gets at that tier.
- It is a Curse-state transition and the handbook documents the curse arc.
- It is a per-race Daedric response and the handbook's "The Daedric
  Question" section needs a representative tone sample.
- It is a Champion entry that is iconic enough to be the lore beat the
  handbook closes on.

Transient text (notifications, tier-ups, survey readouts, dialogue topics,
favors) is **never** promoted: it is consumed in play.

Pipeline check before promotion:
1. Manifest row is drafted.
2. Verification tool (`node tools/pdv_content_verify.mjs`) is clean for
   that row.
3. Row's `Source` column points at a still-canonical design line.
4. Handbook prose paraphrases or quotes the manifest row; it does not
   restate mechanics not in the manifest.

---

## 7. How to use this matrix

- **Starting a new race section?** Use Section 3's row of cells as the
  checklist. If a cell is empty, that surface has not been drafted; if it
  shows a section number, the prose already exists there.
- **Starting a new Daedric path?** Mirror Boethiah's structure: Sections
  6.1-6.8 of the Daedric manifest. Section 4 above shows which Prince to
  pick next based on vanilla hook strength.
- **Picking a voice / budget?** Section 5 is the cheat sheet; Section 2 has
  the full per-surface breakdown.
- **Asking "where does this string live in the game?"** Section 2 column
  `CK record`.
- **Asking "where does this string come from, conceptually?"** Section 2
  column `Design source field`.

---

## 8. Things to confirm / push back on

Mark these inline as you read; they are the cells the author (me) was least
certain about while assembling this matrix:

- [ ] Section 2 row "Race-specific posture readout": is `Dunmer Ancestor /
      Argonian Hist / Khajiit Lunar` the right grouping, or should each be
      its own row?
- [ ] Section 3 "Race-specific extras" cell: is one cell per race enough,
      or do you want one row per track?
- [ ] Section 4 "all sixteen Skyrim-present Princes": confirm authoring order
      now that every Skyrim-present Prince surface is required for 1.0.
- [ ] Section 6 "Promotion path": is this the criterion you want, or
      should *all* curse + champion + Daedric-response rows promote
      automatically?
- [ ] Anywhere a cell reads `gated` or `deferred`, sanity-check that the
      gate is still real.
