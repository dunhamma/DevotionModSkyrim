# PDV Daedric Section 11 Contract Cells -- Batch A (8 Princes)

**Status:** DRAFT (no-deploy prep). Nothing here deploys or changes the live build.
**Created:** 2026-06-19
**Provenance:** Compiled by reading `references/phase4/PDV_DaedricRacePrinceMatrix.csv` (canonical per-race + hook/boon/price cells), `references/authoring/PDV_Daedric_DecisionPacket_CAT4.md` (D-15..D-18 rationale), `PDV_Architecture_v3.md` Sections 11 / 11.6 / 25.9 and the Section 11 contract-field list at line ~2561, `references/PDV_RaceArchitecture_DesignReference.md` (surface-type vocabulary, Dunmer Daedric deviation map), `references/authoring/PDV_RaceContractTemplate.md` (contract scaffold), `references/authoring/PDV_DaedricBoonPriceReviewSheet.md` (V2 boon/price magnitudes), `references/authoring/PDV_DaedricPactRedesign.md` (one-active-pact hard switch), and `race-sheets/PDV_DaedricContent_Manifest.md` Sections 6 / 7.1-7.15 (authored per-Prince content). All eight Princes here are already content-drafted in the manifest; this artifact re-projects them into the eleven Section 11 contract fields for build planning.

---

## How to read this document

This prep artifact takes the eleven requested contract fields and fills each from
the locked Daedric design only. Where a field is set by an architecture lock it
cites the lock; where a field is set by the canonical matrix it cites the matrix
cell; where the matrix/manifest does not yet pin a value it reads `UNSPEC -- needs
ruling` and is carried to the open-questions list rather than invented.

**The eleven fields, mapped to their locked source of record:**

| Field | Source of record |
|---|---|
| Surface type | `PDV_Architecture_v3.md` Section 11 contract list (StandaloneDaedricQuest default; FactionOathSurface for Nocturnal only; curse-state entry for Hircine/Molag Bal) |
| Response state | `PDV_DaedricRacePrinceMatrix.csv` per-race cells + the `<state>` token (Native/Legible/Tolerated/Foreign/Taboo/Hostile/Curse) |
| Boon | `PDV_DaedricBoonPriceReviewSheet.md` V2 table (AV + magnitudes) + matrix `Boon` theme |
| Price | `PDV_DaedricBoonPriceReviewSheet.md` V2 table (AV + magnitudes) + matrix `PrimaryPrice` theme |
| Stigma | D-15 weight class (Tolerated ~0.5x / Standard 1.0x / High-rupture ~1.5x); four-band WitchcraftExposure shape; native-integration forces zero |
| Faith friction | matrix per-race `<friction>` clause + native-integration override (Section 11.4); the load-bearing-hostility notes |
| Vanilla hook priority | matrix `VanillaHookPriority` cell |
| Buildability | matrix `BuildabilityTag` (all eight are `Vanilla Hook`) + D-17 batch placement |
| Exit route | matrix per-race `<exit>` clause + D-13 mixed recovery (curse-access = cure path, D-16) |
| Residue | D-15.3 (stigma decays to Latent at 1/day; one-way `WasChampion` flag) + curse residue for Molag Bal |
| Required feedback | D-18 content-ready slot set (tone, boon/price x3, tier-up + lapse, Champion entry, commitment or curse-onset, stigma or curse-driven crossings, neglect + exit, per-race response) |

**Locked invariants that constrain every block (do not re-litigate here):**

- Stigma model, curse-access template, authoring order, and the content-ready
  bar are LOCKED as D-15..D-18 in `PDV_Architecture_v3.md` Section 11.6.
- One active Daedric pact at a time -- HARD SWITCH (`PDV_DaedricPactRedesign.md`):
  committing/advancing a Prince makes it the single live pact (one boon + one
  price); the prior pact's effects switch off while its piety/tier are preserved.
  The werewolf/vampire curse is NOT a pact spell and persists across switches.
- Curse-access Princes (Hircine, Molag Bal) coordinate with -- and must not
  double-fire -- the race manifest `*_CurseState_*` rows.
- Boon/price magnitudes are the V2 replacement model: only the current tier's
  boon+price are active (no lower-tier stacking).
- The Section 11 contract names thirteen fields (it adds `commitment signal` and
  `temptation pressure`). This Batch A artifact fills the eleven requested fields;
  commitment signal and temptation pressure are quoted inline under Vanilla hook
  priority / Faith friction for context but are not separate cells here.

---

## 7.A.1 Boethiah

Matrix row: `Boethiah / Boethra`. PrincePathType `Struggle-overthrow-trial`.
Native-integrated for Dunmer (Reclamation, routes to race manifest); Khajiit is
Legible (Boethra is a known name, not a lunar lane -- takes the global response).
Manifest pilot (Section 6).

- **Vanilla quest hook (route from):** Boethiah's Calling (DA12) -- the
  Sacellum / "kill the strongest follower" proving chain; `Boethiah's Calling >
  betrayal outcome > proving acts` (matrix `VanillaHookPriority`).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; commitment by N=3
  Boethiah-coded signals per Section 11.3).
- **Response state:** mixed by race (matrix) -- Dunmer Native; Khajiit Legible;
  Nord/Imperial/Breton/Bosmer Taboo; Redguard/Argonian Foreign; Altmer/Orc
  Hostile.
- **Boon:** One-Handed +10 / +15 / +20 (review sheet). Theme: conflict-winning
  edge and trial momentum (matrix `Boon`).
- **Price:** Speech -8 / -12 / -15 (review sheet). Theme: conflict escalation and
  trust damage (matrix `PrimaryPrice`); manifest also frames follower/loyalty
  strain.
- **Stigma:** Standard weight class, ~1.0x base accrual (D-15.2). Four-band
  WitchcraftExposure shape; full three-crossing authoring (Suspected / Known /
  Notorious). Native-integration forces zero for Dunmer.
- **Faith friction:** Altmer and Orc hostility is load-bearing (matrix Notes;
  Boethiah as betrayer of Trinimac for Altmer, and the Malacath-betrayal rivalry
  for Orc). Native-integration override (Section 11.4) removes friction for
  Dunmer only.
- **Vanilla hook priority:** `Boethiah's Calling > betrayal outcome > proving
  acts` (matrix). Commitment signal: `Boethiah quest resolution,
  sacrifice/betrayal threshold, repeated trial-of-strength choices`.
- **Buildability:** `Vanilla Hook` (matrix `BuildabilityTag`). D-17 placement:
  the manifest pilot; proven first; not in Batch 0.
- **Exit route:** renounce verb (chosen-pact). Per-race exit clauses (matrix):
  Nord rededicate through accepted gods; Imperial public penance or abandonment;
  Altmer/Orc severe-rupture, no gentle road. D-13 mixed recovery default.
- **Residue:** stigma decays to `Latent` at 1/day (D-15.3); permanent residue is
  the one-way `PDV.Daedric.Boethiah.WasChampion` dialogue flag set on first
  Champion entry. Exit prose: "the stigma fades only on its own slow time."
- **Required feedback (D-18 slots):** tone profile; boon x3 + price x3 passive
  SPEL descriptions; SeekerEntry / DevotedEntry / Lapse notifications;
  `PDV_Msg_Daedric_Boethiah_ChampionEntry`; `_Commitment`; stigma Suspected /
  Known / Notorious; NeglectTexture; `_Exit`; per-race `Response_<Race>` for the
  nine non-native races (Dunmer routes to race manifest). Firing-density sanity
  paragraph present.

---

## 7.A.2 Azura

Matrix row: `Azura / Azurah`. PrincePathType `Fate-dawn-dusk-prophecy`.
Native-integrated for Dunmer AND Khajiit (both route to race manifest); the
global path covers the other eight races. D-17 Batch 0 (proves native-override
routing at scale). Manifest Section 7.1.

- **Vanilla quest hook (route from):** The Black Star (DA01) -- Aranea / Azura's
  Star; `The Black Star > Azura shrine > artifact outcome` (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment) with
  native-integration override for two races.
- **Response state:** Dunmer Native; Khajiit Native (Azurah, core lunar
  theology); Nord/Imperial/Altmer/Orc Taboo; Breton Legible;
  Bosmer/Redguard/Argonian Foreign (matrix cells).
- **Boon:** Magic Resistance +10% / +15% / +20% (review sheet). Theme: threshold
  foresight and liminal protection (matrix `Boon`).
- **Price:** Stamina Regeneration -5% / -10% / -15% (review sheet). Theme: fate
  obligation and prophetic burden (matrix `PrimaryPrice`).
- **Stigma:** Standard weight class, ~1.0x (D-15.2; Azura is a Good Daedra but
  on the global path reads as a foreign cult). Native-integration forces zero for
  Dunmer and Khajiit.
- **Faith friction:** lowest-friction of the good Daedra externally; native for
  two races (no outsider stigma there). Altmer cell is the sharpest external read
  (apostasy from Auri-El order; difficult absolution only).
- **Vanilla hook priority:** `The Black Star > Azura shrine > artifact outcome`.
  Commitment signal: `Azura quest outcome, artifact alignment, repeated
  twilight-threshold acts`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 0 -- proves the
  native-override pattern (Mephala and Malacath reuse it).
- **Exit route:** renounce / quiet abandonment (matrix per-race clauses: Nord
  cleanse or rededicate; Dunmer normal switch or ancestor-led rededication;
  Khajiit normal switch within lunar substrate). D-13 mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Azura.WasChampion` flag on first Champion (D-15.3).
- **Required feedback (D-18 slots):** full standard set (tone; boon/price x3;
  SeekerEntry/DevotedEntry/Lapse; ChampionEntry; `_Commitment`; stigma Suspected/
  Known/Notorious; NeglectTexture; `_Exit`; eight `Response_<Race>` rows; Dunmer
  and Khajiit route to race manifest, no Daedric response row). Firing-density
  sanity paragraph present.

---

## 7.A.3 Vaermina

Matrix row: `Vaermina`. PrincePathType `Dream-nightmare-memory`. No
native-integration exception. D-17 Batch 0 (the pure-standard proof). Manifest
Section 7.10.

- **Vanilla quest hook (route from):** Waking Nightmare (DA16) -- Nightcaller
  Temple / Skull of Corruption; `Waking Nightmare > Skull of Corruption >
  nightmare/sleep corruption` (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment).
- **Response state:** Nord/Imperial/Altmer Taboo; Breton Foreign-but-legible at
  the margins; Dunmer/Khajiit/Bosmer/Redguard/Orc/Argonian Foreign (matrix cells;
  manifest Section 7.10 summary).
- **Boon:** Illusion +10 / +15 / +20 (review sheet). Theme: dream insight, fear
  leverage, sleep-path advantage (matrix `Boon`).
- **Price:** Health Regeneration -5% / -10% / -15% (review sheet). Theme: sleep
  corruption and memory/fear instability (matrix `PrimaryPrice`). Review note:
  Vaermina (bodily unrest) and Molag Bal (loss of Restoration) deliberately split
  to avoid feeling too close.
- **Stigma:** Standard weight class, ~1.0x (D-15.2). Full three-crossing
  authoring.
- **Faith friction:** no race treats Vaermina as native; the heaviest external
  friction is Nord (hearth-safety / kin-trust), Imperial (civic memory), Altmer
  (self-cultivation corruption). No load-bearing-hostility note.
- **Vanilla hook priority:** `Waking Nightmare > Skull of Corruption >
  nightmare/sleep corruption`. Commitment signal: `Waking Nightmare, Skull of
  Corruption, nightmare manipulation threshold`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 0 -- the clean standard
  external pact with no native override (proves the pure template). Matrix
  authoring note: should stay tightly quest-anchored for first release.
- **Exit route:** renounce / cleanse / abandonment (matrix per-race clauses).
  D-13 mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Vaermina.WasChampion` flag (D-15.3). Manifest exit prose adds the
  in-fiction note that "Vaermina keeps what she learned about yours" -- this is
  flavor, not a mechanical residue beyond `WasChampion`.
- **Required feedback (D-18 slots):** full standard set; ten races carry per-race
  responses (no native exception). EditorID note (manifest): extended slot IDs
  exceed 32 chars -- flagged for Phase 19 abbreviation review. Firing-density
  sanity paragraph present.

---

## 7.A.4 Meridia

Matrix row: `Meridia`. PrincePathType `Cleansing-light-anti-undead overlay`. No
native-integration exception; matrix note "best treated as tolerated-access in
several cultures without becoming native." D-17 Batch 0 (proves the `Tolerated`
weight class). Manifest Section 7.4.

- **Vanilla quest hook (route from):** The Break of Dawn (DA10) -- Mount Kilkreath
  / Dawnbreaker; `The Break of Dawn > Dawnbreaker > undead/necromancer cleansing`
  (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment), but
  with the `Tolerated` stigma treatment.
- **Response state:** Nord/Imperial/Breton/Redguard Tolerated; Dunmer/Altmer/
  Khajiit/Bosmer/Orc/Argonian Foreign (matrix cells). No Taboo/Hostile/Native.
- **Boon:** Restoration +10 / +15 / +20 (review sheet -- V2 replaced narrow
  disease resist with a broader anti-corruption Restoration lane). Theme:
  undead-cleansing edge and radiant corruption resistance (matrix `Boon`).
- **Price:** Illusion -8 / -12 / -15 (review sheet). Theme: authoritarian purity
  and anti-undead intolerance (matrix `PrimaryPrice`).
- **Stigma:** `Tolerated` weight class, ~0.5x base accrual (D-15.2). Author
  Suspected/Known crossings; Notorious is rare-edge only for tolerant races. This
  is the Batch 0 proof of the Tolerated class.
- **Faith friction:** lowest-friction Prince across cultures (anti-undead utility
  reads as outsider devotion, not cult); Redguard reads as subordinate to
  Tu'whacca's duties. No native race, but no severe-rupture race either.
- **Vanilla hook priority:** `The Break of Dawn > Dawnbreaker > undead/necromancer
  cleansing`. Commitment signal: `Meridia quest outcome, Dawnbreaker service,
  repeated undead-cleansing milestones`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 0 -- proves the
  `Tolerated` class and the "Notorious is rare-edge" rule (Peryite reuses it).
  Source-curation caution: must prevent generic undead-kill farming (manifest
  firing-density note).
- **Exit route:** normal abandonment / shrine cleansing / normal re-entry (matrix
  per-race clauses; lighter than most Princes). D-13 mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Meridia.WasChampion` flag (D-15.3). Manifest Argonian exit prose
  notes "no residue" socially -- consistent with the Tolerated class clearing
  cleanly; the `WasChampion` flag still applies as the only permanent mark.
- **Required feedback (D-18 slots):** full standard set; all ten races carry
  per-race responses (no native exception). Firing-density sanity paragraph
  present.

---

## 7.A.5 Molag Bal

Matrix row: `Molag Bal`. PrincePathType `Domination-vampirism-enslavement`.
**Curse-access Prince (D-16).** D-17 Batch 0 (the curse-access end-to-end proof;
the genuinely new curse-access build, authored against the Hircine pattern).
Manifest Section 7.15.

- **Vanilla quest hook (route from):** The House of Horrors (DA07) -- Markarth
  Abandoned House / Mace of Molag Bal; plus the vampirism (Volkihar) state; `The
  House of Horrors > vampirism > Mace of Molag Bal` (matrix).
- **Surface type:** curse-state entry (D-16). The `_Commitment` slot is reframed
  as a vampiric embrace -- Molag Bal speaks when the player commits while carrying
  vampirism; the gate is three domination/Molag-aligned signals with the thirst
  in play, not general piety accumulation. Coordinates with (does not duplicate)
  the race `*_CurseState_*` rows.
- **Response state:** Redguard Hostile; Dunmer/Orc Taboo; all others Curse (Nord,
  Imperial, Breton, Altmer, Khajiit, Bosmer, Argonian) (matrix cells; manifest
  Section 7.15 summary).
- **Boon:** Illusion +10 / +15 / +20 (review sheet -- keeps domination as control
  magic). Theme: domination edge, coercive pressure, vampiric leverage (matrix
  `Boon`).
- **Price:** Restoration -8 / -12 / -15 (review sheet -- skill-for-skill loss
  framing loss of mercy). Theme: domination corruption and spiritual violation
  (matrix `PrimaryPrice`).
- **Stigma:** `High-rupture` weight class, ~1.5x (D-15.2) -- BUT in curse-access
  mode (D-16) stigma is driven by the Phase 15 curse-state overlay (known-vampire
  visibility), not an independent per-act Daedric counter. No standalone Molag Bal
  stigma notifications fire in V1; the three drafted independent-stigma band lines
  are parked in `PDV_V2_Backlog.md` for the planned witnessed-kill notoriety
  enhancement. The per-tier price descriptions carry the social-register texture.
- **Faith friction:** the loudest social rupture of the eight (High-rupture +
  vampiric-violation memory). Redguard friction is hostile (breaks the Far Shores
  / mortality order). Per-race responses are uniformly cure-first across all ten
  races.
- **Vanilla hook priority:** `The House of Horrors > vampirism > Mace of Molag
  Bal`. Commitment signal: `House of Horrors, active vampirism, Volkihar /
  domination threshold`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 0 -- the curse-access
  reduced row set end to end; authored second, against the Hircine pattern.
- **Exit route:** cure path (D-16; the renounce verb does not apply). Cure starts
  recovery; rites / authored beats complete it (D-13 mixed recovery). Per-race
  exits are "cure first, then rededicate," with a lowered floor for Imperial and
  no full restoration for Altmer (matrix cells).
- **Residue:** the curse persists across pact switches (curse is not a pact
  spell; `PDV_DaedricPactRedesign.md`). On exit the favor boon/price withdraw but
  the vampiric curse remains until cured. Daedric stigma residue: `WasChampion`
  one-way flag still applies (D-15.3); the deeper scar is the curse-state scar
  owned by the race `*_CurseState_*` rows, not a Daedric stigma counter.
- **Required feedback (D-18 slots, curse-access variant):** tone; boon/price x3;
  SeekerEntry/DevotedEntry/Lapse; ChampionEntry; `_Commitment` reframed as
  vampiric-embrace curse-onset; NO independent stigma crossings in V1
  (curse-state-driven, Model B); NeglectTexture; `_Exit` (cure/residue);
  ten per-race `Response_<Race>` rows. Must not collide with race `*_CurseState_*`
  slots (D-16.2 verifier check). EditorID note (manifest): `Molag` token; extended
  IDs exceed 32 chars -- Phase 19 review. Firing-density sanity paragraph present.

---

## 7.A.6 Mephala

Matrix row: `Mephala / Mafala`. PrincePathType `Web-secret-murder-clan`.
Native-integrated for Dunmer (Reclamation/hidden-community lane, routes to race
manifest); Khajiit is Legible (Mafala is a known name, not a lunar lane -- takes
the global response). D-17 Batch 1 (native-integration variant; reuses the Azura
pattern). Manifest Section 7.2.

- **Vanilla quest hook (route from):** The Whispering Door (DA14) -- Dragonsreach /
  Ebony Blade; `The Whispering Door > Ebony Blade > hidden-network choices`
  (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment) with
  native-integration override for Dunmer.
- **Response state:** Dunmer Native; Khajiit Legible; Nord/Imperial/Altmer/Orc
  Taboo; Breton Legible; Bosmer/Redguard/Argonian Foreign (matrix cells).
- **Boon:** Sneak +10 / +15 / +20 (review sheet). Theme: secret-network leverage
  and hidden-path advantage (matrix `Boon`). Matrix note (load-bearing): do NOT
  flatten Mephala into generic stealth behavior -- the web is social, the violence
  personal.
- **Price:** Speech -8 / -12 / -15 (review sheet). Theme: social corruption and
  hidden violence (matrix `PrimaryPrice`).
- **Stigma:** Standard weight class, ~1.0x (D-15.2). Full three-crossing
  authoring. Native-integration forces zero for Dunmer.
- **Faith friction:** Taboo for the open-honor / civic-virtue races
  (Nord/Imperial/Orc) and Altmer orthodoxy; Legible-but-risky for Breton; native
  for Dunmer. No hostility cell. Matrix Notes: "Do not flatten Mephala into
  generic stealth behavior."
- **Vanilla hook priority:** `The Whispering Door > Ebony Blade > hidden-network
  choices`. Commitment signal: `Whispering Door / Ebony Blade threshold,
  hidden-loyalty bargains, deliberate web-building`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 1 -- native-integration
  variant (after Azura proves the override pattern).
- **Exit route:** renounce / shrine cleansing / quiet abandonment (matrix per-race
  clauses: Nord shrine cleansing or renunciation; Imperial confession/cleansing).
  D-13 mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Mephala.WasChampion` flag (D-15.3). Exit prose: corruption "leaves
  its mark slowly," distrust does not relearn trust on the player's schedule.
- **Required feedback (D-18 slots):** full standard set; nine `Response_<Race>`
  rows (Dunmer routes to race manifest). Firing-density sanity paragraph present.

---

## 7.A.7 Malacath

Matrix row: `Malacath / Mauloch`. PrincePathType `Oath-exile-code-vengeance`.
Native-integrated for Orc (core Orc code, routes to race manifest); Redguard
hostility (Malooc) explicitly preserved. D-17 Batch 1 (native-integration
variant). Manifest Section 7.3.

- **Vanilla quest hook (route from):** The Cursed Tribe (DA09) -- Largashbur /
  Volendrung; `The Cursed Tribe > Volendrung > stronghold/Blood-Kin context`
  (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment) with
  native-integration override for Orc.
- **Response state:** Orc Native; Redguard Hostile (Malooc); Imperial/Dunmer/
  Altmer Taboo; Nord/Breton/Khajiit/Bosmer/Argonian Foreign (matrix cells).
- **Boon:** Armor Rating +10 / +15 / +20 (review sheet -- outcast-endurance
  fantasy). Theme: endurance, oath retaliation, outsider resilience (matrix
  `Boon`).
- **Price:** Movement Speed -3% / -5% / -8% (review sheet -- capped low so play
  does not feel broken). Theme: harsh judgment and code burden (matrix
  `PrimaryPrice`).
- **Stigma:** Standard weight class, ~1.0x (D-15.2). Full three-crossing
  authoring. Native-integration forces zero for Orc.
- **Faith friction:** Redguard hostility is load-bearing and explicitly preserved
  (Malooc, enemy-god of the old crossing -- severe rupture only). Altmer Taboo
  (degraded ancestor / Trinimac unmade). Native for Orc (no friction). Matrix
  Notes: "Orc-native exception; Redguard hostility is explicitly preserved."
- **Vanilla hook priority:** `The Cursed Tribe > Volendrung > stronghold/Blood-Kin
  context`. Commitment signal: `The Cursed Tribe / Volendrung / Blood-Kin /
  exile-defense threshold`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 1 -- native-integration
  variant.
- **Exit route:** renounce / abandon / cleanse, with hard rededication for the
  Taboo races and no gentle road for Redguard (matrix per-race clauses). D-13
  mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Malacath.WasChampion` flag (D-15.3). Exit prose: "the mark of the
  pariah fades on its own slow time."
- **Required feedback (D-18 slots):** full standard set; nine `Response_<Race>`
  rows (Orc routes to race manifest). Firing-density sanity paragraph present.

---

## 7.A.8 Mehrunes Dagon

Matrix row: `Mehrunes Dagon`. PrincePathType `Destruction-revolution-ruin`. No
native-integration exception. D-17 Batch 2 (standard external pact); high-rupture.
Manifest Section 7.7. Slot IDs use the `Dagon` token.

- **Vanilla quest hook (route from):** Pieces of the Past (DA06) -- Mehrunes'
  Razor reassembly; `Pieces of the Past > Mehrunes' Razor > destructive outcomes`
  (matrix).
- **Surface type:** StandaloneDaedricQuest (chosen-pact; N=3 commitment).
- **Response state:** Imperial Hostile (Oblivion-Crisis memory) and Redguard
  Hostile (destroyer of the way-making civilization); Argonian Foreign; all other
  seven races Taboo (matrix cells; manifest Section 7.7 summary).
- **Boon:** Attack Damage +5% / +8% / +12% (review sheet -- record-proven raw
  attack damage for the Prince of Destruction; uses the lower combat ceiling).
  Theme: burst destructive advantage against entrenched targets (matrix `Boon`).
- **Price:** Armor Rating -5 / -10 / -15 (review sheet -- paid for with lower
  defenses). Theme: ruin escalation and civic-spiritual rupture (matrix
  `PrimaryPrice`).
- **Stigma:** `High-rupture` weight class, ~1.5x base accrual (D-15.2) -- reaches
  Notorious fastest; Oblivion-Crisis memory makes this one of the loudest social
  ruptures. Full three-crossing authoring.
- **Faith friction:** Imperial hostility is stronger than generic taboo because of
  Oblivion-Crisis memory (matrix Notes -- load-bearing); Redguard hostility is also
  load-bearing (enemy of the way-makers). No native race; no Legible/Tolerated
  cell.
- **Vanilla hook priority:** `Pieces of the Past > Mehrunes' Razor > destructive
  outcomes`. Commitment signal: `Pieces of the Past, Razor commitment,
  catastrophic overthrow alignment`.
- **Buildability:** `Vanilla Hook` (matrix). D-17 Batch 2 -- standard external
  pact (mass-authored after Batch 0 proves the templates).
- **Exit route:** renounce / cleanse for the Taboo races; for the Hostile races
  (Imperial, Redguard) there is no gentle exit -- the rupture is total and return
  is hard and public (matrix cells). D-13 mixed recovery.
- **Residue:** stigma decays to `Latent` at 1/day; one-way
  `PDV.Daedric.Dagon.WasChampion` flag (D-15.3). Exit prose: "What you fractured
  does not heal, but it no longer grows."
- **Required feedback (D-18 slots):** full standard set; all ten races carry
  per-race responses (no native exception; Imperial and Redguard use the maximum
  rupture framing). Firing-density sanity paragraph present.

---

## Cross-Prince summary table (quick reference)

| Prince | Surface type | Stigma class | Boon (S/D/C) | Price (S/D/C) | Hook (DA-code) |
|---|---|---|---|---|---|
| Boethiah | StandaloneDaedricQuest | Standard ~1.0x | One-Handed +10/15/20 | Speech -8/12/15 | Boethiah's Calling (DA12) |
| Azura | StandaloneDaedricQuest + native override (Dunmer, Khajiit) | Standard ~1.0x | Magic Resist +10/15/20% | Stamina Regen -5/10/15% | The Black Star (DA01) |
| Vaermina | StandaloneDaedricQuest | Standard ~1.0x | Illusion +10/15/20 | Health Regen -5/10/15% | Waking Nightmare (DA16) |
| Meridia | StandaloneDaedricQuest (Tolerated) | Tolerated ~0.5x | Restoration +10/15/20 | Illusion -8/12/15 | The Break of Dawn (DA10) |
| Molag Bal | Curse-state entry (D-16) | High-rupture ~1.5x (curse-state-driven, Model B) | Illusion +10/15/20 | Restoration -8/12/15 | The House of Horrors (DA07) + vampirism |
| Mephala | StandaloneDaedricQuest + native override (Dunmer) | Standard ~1.0x | Sneak +10/15/20 | Speech -8/12/15 | The Whispering Door (DA14) |
| Malacath | StandaloneDaedricQuest + native override (Orc) | Standard ~1.0x | Armor Rating +10/15/20 | Movement Speed -3/5/8% | The Cursed Tribe (DA09) |
| Mehrunes Dagon | StandaloneDaedricQuest | High-rupture ~1.5x | Attack Damage +5/8/12% | Armor Rating -5/10/15 | Pieces of the Past (DA06) |

---

## Provenance notes and caveats

- Boon/price magnitudes are the V2 replacement-model values from
  `PDV_DaedricBoonPriceReviewSheet.md`; that sheet labels itself a balance-review
  artifact, not runtime proof. Active-Effects, save/load, stack-legibility, and
  manual-feel evidence are still pending (separate proof boundary).
- The vanilla DA-quest codes (DA01, DA06, DA07, DA09, DA10, DA12, DA14, DA16) are
  the standard Skyrim Daedric quest editor codes corresponding to the named quests
  in each matrix `VanillaHookPriority` cell. The matrix names the quests, not the
  codes; the codes are added here as a build convenience and should be confirmed
  against the live record before any CK wiring. Flagged in open questions.
- Stigma weight classes are read directly from D-15.2 (Meridia = Tolerated;
  Boethiah/Azura/Mephala/Malacath/Vaermina = Standard; Mehrunes Dagon/Molag Bal =
  High-rupture).
- This artifact intentionally does not assign per-race numeric `StigmaModByRace`
  values -- the matrix carries the qualitative per-race `<state>` but not numeric
  multipliers, so those remain UNSPEC (see open questions).