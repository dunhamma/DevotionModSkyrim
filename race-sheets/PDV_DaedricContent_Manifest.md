# PDV Daedric Path Content Manifest (1.0)

**Status:** Authoring manifest. Companion to `race-sheets/PDV_RaceContent_Manifest.md`. Full draft prose for the Boethiah pilot; the remaining 1.0 Daedric Princes are stub-listed.
**Created:** 2026-05-21
**Owner docs:** `PDV_Architecture_v3.md` Section 11 (Daedric path architecture) and Section 21.1 (1.0 scope); `references/PDV_RaceArchitecture_DesignReference.md` Section 11; `references/phase4/PDV_DaedricRacePrinceMatrix.csv` (the canonical Prince-by-race matrix); `PDV_STANDARDS.md` Section 3.
**Purpose:** Extend manifest-style content authoring to the Daedric paths, which the race content manifest deliberately deferred. Author one Prince (Boethiah) end to end to prove the Daedric row template, then stub the rest.

---

## 1. Relationship to the race content manifest

This file is the Daedric sibling of `PDV_RaceContent_Manifest.md`. The race
manifest owns Aedric and native devotion for all 10 races; this file owns the
Prince-first Daedric paths.

It **reuses, by reference**, the race manifest's shared conventions: ASCII
rules (Section 2), the voice-by-Surface matrix (Section 3), the per-Surface
length budgets (Section 4), firing-density targets (Section 5), the
localization-readiness rules (Section 7), and the token tables (Section 24).
It does not restate them. The Daedric-specific additions are in Sections 2-5
below.

Both files are validated by the same tool: `node tools/pdv_content_verify.mjs`.

## 2. Daedric contract grammar

Per `PDV_Architecture_v3.md` Section 11, a Daedric path runs on the same tier
spine as an Aedric deity but uses a different contract grammar:

- **Boon / price / stigma triple.** Every tier grants a **boon** (a benefit)
  and a paired **price** (a thematic drawback active while the boon is held).
  Every Daedric devotional act also accrues **stigma**, a cumulative
  social-readability metric that manifests as NPC wariness and dialogue gates.
- **Commitment gate.** Unlike an Aedric deity, a Daedric path awards no piety
  until the player has performed N distinct Prince-coded commitment signals
  (default 3). Before the gate clears, the path is dormant.
- **Tiers are `Seeker` / `Devoted` / `Champion`** (not the Aedric
  `Observant` / `Faithful` / `Devoted` ladder). See race manifest Section 24.2.
- **Per-race response.** The same path presents differently to each race --
  `Native`, `Legible`, `Tolerated`, `Foreign`, `Taboo`, `Hostile`, or
  `Curse-access` -- with race-specific stigma weight and exit difficulty. The
  canonical per-race cells are in `PDV_DaedricRacePrinceMatrix.csv`.
- **Native-integration override** (Section 11.4). For the races where a Prince
  is native -- Azura/Boethiah/Mephala for Dunmer, Boethra/Mafala for Khajiit,
  Malacath for Orc -- the Daedric contract does not apply: stigma is near-zero
  and the path behaves as an Aedric-style deity. Those treatments are authored
  in the race manifest, not here. This file covers the Prince-first global
  path for the non-native races.

## 3. Daedric-specific slot conventions

Extends race manifest Section 1. Slot IDs:

- `PDV_Bless_Daedric_<Prince>_<Seeker|Devoted|Champion>` -- boon descriptions.
- `PDV_Price_Daedric_<Prince>_<Seeker|Devoted|Champion>` -- **new slot type**:
  the thematic-drawback copy paired with each boon.
- `PDV_Notif_Daedric_<Prince>_<Seeker|Devoted>Entry`, `_Lapse` -- tier-up.
- `PDV_Msg_Daedric_<Prince>_ChampionEntry` -- the top-tier recognition.
- `PDV_Msg_Daedric_<Prince>_Commitment` -- the pact, fired when the
  commitment gate clears.
- `PDV_Notif_Daedric_<Prince>_Stigma_<band>` -- stigma band-crossing feedback.
- `PDV_Notif_Daedric_<Prince>_NeglectTexture` -- neglect.
- `PDV_Msg_Daedric_<Prince>_Exit` -- renunciation copy, including residue.
- `PDV_Msg_Daedric_<Prince>_Response_<Race>` -- per-race response framing.

## 4. Daedric row template

The shared 8-column row template from race manifest Section 8 is unchanged:
`Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose`.

Two additions:
- **New Surface:** `Price description` -- a passive SPEL description, narrator
  voice, budget 200/140, identical handling to `Blessing description` /
  `Boon description`.
- **Tier vocabulary:** Daedric rows use `Seeker` / `Devoted` / `Champion`.

## 5. Stigma band model (provisional)

`PDV_Architecture_v3.md` Section 11.6 leaves the stigma decay model open
("Defer to content-author phase"). This manifest authors stigma feedback
against a provisional three-band crossing model -- `Suspected`, `Known`,
`Notorious` -- mirroring the Breton `WitchcraftExposure` shape minus its
`Hidden` floor (an unmarked path needs no notification). If the architecture
later locks a different band count, the stigma rows are the only ones that
need a revisit.

**Proposed lock (D-15):**
`references/authoring/PDV_Daedric_DecisionPacket_CAT4.md` resolves this against
the full four-band `WitchcraftExposure` shape (`Latent` `0..25` with no
notification, then `Suspected` / `Known` / `Notorious`), per-Prince storage, a
derived `PDV_GLO_DaedricExposure = max(active path stigma)` social read, three
weight classes (`Tolerated` / `Standard` / `High-rupture`), slow 1/day decay,
and a `WasChampion` residue flag. The three crossing notifications above are
unchanged by that lock; the `Latent` floor simply has no notification, which
this section already assumes. Pending ratification.

---

## 6. Boethiah (full pilot)

Boethiah is the architecture's piloted Daedric Prince. Source: the `Boethiah / Boethra`
row of `PDV_DaedricRacePrinceMatrix.csv` -- PrincePathType `Struggle-overthrow-trial`,
CommitmentSignal `Boethiah quest resolution, sacrifice/betrayal threshold,
repeated trial-of-strength choices`, Boon `Conflict-winning edge and trial
momentum`, PrimaryPrice `Conflict escalation and trust damage`,
VanillaHookPriority `Boethiah's Calling > betrayal outcome > proving acts`.

**Native-integration note.** Boethiah is *also* a native Dunmer Reclamation
and Khajiit-legible as Boethra. Those treatments are authored in the race
manifest (`PDV_Bless_Dunmer_Boethiah_T3`, `PDV_Msg_Dunmer_Boethiah_Offer`,
`PDV_Msg_Dunmer_Boethiah_ChampionEntry`, the Dunmer Boethiah favor rows; the
Khajiit Azurah/Boethra-legible framing). Per Section 2, the Daedric contract
does not apply to Dunmer or Khajiit. This pilot covers the Prince-first global
path for the eight non-native races, and Section 6.8 routes Dunmer and Khajiit
back to the race manifest rather than re-authoring them.

### 6.1 Tone profile

| Voice | Tone profile |
|---|---|
| Boethiah (Daedric path) | Trial-voiced, sharp, contemptuous of weakness; speaks of strength proven and the unworthy overthrown. The same Prince as the Dunmer-native Reclamation, but on the global path the pact is taken against one's own people: the voice is identical, the social ground is not. |

### 6.2 Boon descriptions (`PDV_Bless_Daedric_Boethiah_*`)

Narrator voice. Budget 200 hard / 140 target. Passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Boethiah_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" Boon; Architecture v3 Section 11.2 | Passive SPEL; pact engaged | Boethiah marks the seeker of trials. A kill against a worthy foe sharpens your hand: a brief weapon-damage edge after a hard-won fight. |
| PDV_Bless_Daedric_Boethiah_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" Boon; Architecture v3 Section 11.2 | Passive SPEL | Boethiah's trial momentum is yours. Felling a significant enemy grants a day of heavier carry weight and stronger power attacks. |
| PDV_Bless_Daedric_Boethiah_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" Boon; Architecture v3 Section 11.2 | Passive SPEL | Boethiah names you proven. In sustained combat a winning edge builds and holds; overthrowing the strong returns the Prince's full favor. |

### 6.3 Price descriptions (`PDV_Price_Daedric_Boethiah_*`)

Narrator voice. Budget 200 hard / 140 target. Passive SPEL, paired with each
boon. Source: the matrix PrimaryPrice `Conflict escalation and trust damage`,
and the Architecture v3 Section 11.2 example (Boethiah price = oath-bond
difficulty with companions).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Boethiah_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" PrimaryPrice; Architecture v3 Section 11.2 | Passive SPEL; paired with the Seeker boon | The price of the pact: conflict gathers around you. Hostile encounters escalate more readily while Boethiah's edge is held. |
| PDV_Price_Daedric_Boethiah_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" PrimaryPrice; Architecture v3 Section 11.2 | Passive SPEL; paired with the Devoted boon | The price deepens: trust frays. Followers and allies are harder to keep, and the world meets your strength with sharper resistance. |
| PDV_Price_Daedric_Boethiah_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Boethiah" PrimaryPrice; Architecture v3 Section 11.2 | Passive SPEL; paired with the Champion boon | The full price: you are a standing trial. Bonds of loyalty strain hardest now, and few alliances outlast the proving Boethiah demands of all who stand near you. |

### 6.4 Tier-up notifications and Champion entry

Tier-up notifications are narrator voice, budget 80 hard / 60 target. The
Champion entry is the top-tier recognition MessageBox, god-voice, 500/280.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Boethiah_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Boethiah counts you a Seeker of trials. |
| PDV_Notif_Daedric_Boethiah_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Boethiah counts you proven. Devoted. |
| PDV_Notif_Daedric_Boethiah_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Boethiah's regard is thinning. The pact weakens. |
| PDV_Msg_Daedric_Boethiah_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Boethiah"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Boethiah's Champion" Body: "You did not survive the trials. You won them, and went looking for more. That is the whole of my creed. You are proven, Champion -- and proven things are never left in peace. Good." |

### 6.5 Commitment / pact (`PDV_Msg_Daedric_Boethiah_Commitment`)

God-voice. MessageBox. Body budget 500 hard / 280 target. Fires when the
commitment gate clears -- three distinct Boethiah-coded signals per
`PDV_Architecture_v3.md` Section 11.3.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Boethiah_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Boethiah" CommitmentSignal | Fires once when the commitment gate clears | Title: "Boethiah's Pact" Body: "Three times you have proven you understand me -- the trial taken, the unworthy pulled down, strength shown without apology. The pact is open. Take my edge, and pay its cost: the world will test you as hard as you test it." |

### 6.6 Stigma band crossings (`PDV_Notif_Daedric_Boethiah_Stigma_*`)

Narrator voice. Notifications. Budget 80 hard / 60 target. Provisional
three-band model per Section 5. Fires on band entry.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Boethiah_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 (provisional bands) | On entering Suspected | Your Daedric leaning is suspected. Some watch you warily now. |
| PDV_Notif_Daedric_Boethiah_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your pact with Boethiah is known. Doors and trust begin to close. |
| PDV_Notif_Daedric_Boethiah_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are a known Boethiah cultist. The wary have turned hostile. |

### 6.7 Neglect texture and exit

Neglect is player-second-person, budget 80/60. The exit message is god-voice,
MessageBox, 500/280, and carries the residue note (stigma decays slowly;
history remains) per `PDV_Architecture_v3.md` Section 11.4 and 11.6.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Boethiah_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You have stopped proving yourself. Boethiah's edge dulls; only the stigma stays. |
| PDV_Msg_Daedric_Boethiah_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4 (exit route); Section 11.6 (stigma decay) | Fires once on renunciation; residue persists | Title: "Boethiah's Contempt" Body: "You set the pact down. Boethiah expected no better -- the weak always do. The edge is gone. The stigma fades only on its own slow time, and the memory of what you reached for does not fully leave you, or the people who saw it." |

### 6.8 Per-race response framing (`PDV_Msg_Daedric_Boethiah_Response_*`)

Narrator voice. MessageBox. Body budget 500 hard / 280 target. One-time, on a
race-X character committing to the Boethiah path. Each row is drawn from the
matching per-race cell of `PDV_DaedricRacePrinceMatrix.csv` (`<state>; <friction>;
<exit>`). Eight non-native races are authored; Dunmer and Khajiit are
native-integrated and route to the race manifest instead.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Boethiah_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Nord cell | One-time on a Nord committing | Title: "A Taboo Among Nords" Body: "To a Nord, Boethiah's proving-by-betrayal is taboo -- it corrodes the communal honor the hearth is built on. The path can be walked, but a Nord who walks it carries shame, and the way back runs through rededication to accepted gods." |
| PDV_Msg_Daedric_Boethiah_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Imperial cell | One-time on an Imperial committing | Title: "A Taboo Among Imperials" Body: "To an Imperial, Boethiah is an anti-civic cult -- a strain on the legal and Divine frame that holds society together. The path is a kind of treason. Return runs through public penance or quiet abandonment." |
| PDV_Msg_Daedric_Boethiah_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Breton cell | One-time on a Breton committing | Title: "A Taboo Among Bretons" Body: "A Breton can make Boethiah intelligible -- the occult margins of the Hidden Art already bend this way -- but the path stays socially corrosive. Keep it covered, or renounce it; the uncommitted middle costs the most." |
| PDV_Msg_Daedric_Boethiah_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Altmer cell; Notes "Hostility for Altmer and Orc is load-bearing" | One-time on an Altmer committing | Title: "Hostile to the Altmer" Body: "For an Altmer this is not mere taboo. Boethiah is the betrayer of Trinimac, the load-bearing enemy of Altmer orthodoxy. To take this pact is severe rupture, and there is no gentle road back from it." |
| PDV_Msg_Daedric_Boethiah_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Bosmer cell | One-time on a Bosmer committing | Title: "A Taboo Among Bosmer" Body: "A Bosmer can feel Boethiah as pressure -- the trial, the overthrow -- but it is not a normal Bosmer lane. The path is taboo, and renouncing it later is costly." |
| PDV_Msg_Daedric_Boethiah_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Redguard cell | One-time on a Redguard committing | Title: "Foreign to the Redguard" Body: "To a Redguard, Boethiah's proving ethos is foreign -- an outsider creed that challenges the Yokudan honor frame rather than fitting inside it. Leaving the path again means hard rededication." |
| PDV_Msg_Daedric_Boethiah_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Orc cell; Notes "Hostility for Altmer and Orc is load-bearing" | One-time on an Orc committing | Title: "Hostile to the Orsimer" Body: "For an Orc this is the deepest rivalry there is. Boethiah's hand in the betrayal that made Malacath sits against the whole Orc code. To take this pact is hard rupture, and Malacath does not forget it." |
| PDV_Msg_Daedric_Boethiah_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Boethiah" Argonian cell | One-time on an Argonian committing | Title: "Foreign to the Saxhleel" Body: "Boethiah has no place in the Hist or the exile community; to an Argonian the path is simply foreign, outside the layered substrate. It can be walked, but it is set down through abandonment or cleansing, not woven in." |

**Dunmer and Khajiit (native-integrated, not authored here).** Boethiah is a
native Dunmer Reclamation and Khajiit-legible as Boethra; per Section 2 and
`PDV_Architecture_v3.md` Section 11.4 the Daedric contract is overridden for
them. A Dunmer or Khajiit relating to Boethiah uses the race manifest's
Dunmer Boethiah section and the Khajiit Azurah/Boethra framing -- there is no
`PDV_Msg_Daedric_Boethiah_Response_Dunmer` or `_Khajiit` row.

### 6.9 Boethiah firing-density sanity

A character on the Boethiah path in steady play (trial-of-strength combat,
the occasional overthrow quest beat):

- Marked: 0 most days. The commitment pact, the Champion entry, the per-race
  response, the Notorious stigma crossing, and the exit are all one-time.
  Inside the `<1 per 2h` target.
- Noted: rare -- a Seeker tier-up, an early stigma crossing. Daedric paths are
  event-driven, not ambient-accumulating (Section 11), so steady play is
  quiet. Inside the `<2 per h` target.
- Quiet: the boon and price descriptions are passive SPEL text, no firing.

---

## 7. Remaining Phase 20 Daedric Prince Surfaces (stubs)

After Boethiah proves the template, the remaining Princes are authored in
follow-up passes. `PDV_Architecture_v3.md` now sets the 1.0 target at
**all sixteen Skyrim-present Daedric Prince surfaces content-ready for every
race**. Buildability and vanilla hook strength still guide authoring order, but
they no longer decide whether a Skyrim-present Prince is in scope. Jyggalag is
out of 1.0 scope per `PDV_TargetEndStates_1.0.md` unless future adopted content
explicitly adds him. Each stub will reuse the Section 6 row shape: tone
profile, boon and price descriptions, tier-ups, commitment, stigma, neglect,
exit, and per-race response.

| Prince | PrincePathType | Authoring notes |
|---|---|---|
| Boethiah / Boethra | Struggle-overthrow-trial | **Drafted** (Section 6). Native-integrated for Dunmer and Khajiit. |
| Azura / Azurah | Fate-dawn-dusk-prophecy | Native-integrated for Dunmer and Khajiit -- Daedric path covers the other eight races. |
| Mephala / Mafala | Web-secret-murder-clan | Native-integrated for Dunmer and Khajiit. |
| Malacath / Mauloch | Oath-exile-code-vengeance | Native-integrated for Orc -- Daedric path covers the other nine races. |
| Meridia | Cleansing-light-anti-undead overlay | Tolerated-access in several cultures; lighter stigma than most. |
| Hircine | Hunt-lycanthropy-predator | **Curse-access** Prince -- framing differs: entry runs through lycanthropy, not a normal pact. |
| Molag Bal | Domination-vampirism-enslavement | **Curse-access** Prince -- entry runs through vampirism; pairs with the race manifest curse-state rows. |
| Nocturnal | Shadow-oath-luck-debt | Entry via the Thieves Guild / Nightingale chain; does not count toward vanilla Oblivion Walker. |
| Hermaeus Mora | Forbidden-knowledge-artifact | Black Book / Apocrypha hooks; strong on Solstheim. |
| Mehrunes Dagon | Destruction-revolution-ruin | High-rupture path; Oblivion Crisis memory makes him enemy pressure for Imperials. |
| Sheogorath | Madness-disruption-instability | Wabbajack / Mind of Madness hooks. |
| Namira / Namiira | Revulsion-decay-outcast-hunger | Strong social and ancestor friction across races. |
| Sanguine / Sangiin | Excess-temptation-indulgence | Appealing but intentionally unreliable; light-touch path. |
| Clavicus Vile | Bargain-wish-contract | Bargain price must stay visible in the price descriptions. |
| Peryite | Plague-order-lowest-task | Narrow, quest-anchored; defensive fantasy. |
| Vaermina | Dream-nightmare-memory | Skull of Corruption / Waking Nightmare hooks. |

**Curse-access framing note.** Hircine and Molag Bal are the curse-access
Princes. Their commitment gate is not a chosen pact but a curse acquisition
(lycanthropy, vampirism), so their `_Commitment` slot is reframed as a
curse-onset message and they coordinate with the race manifest's per-race
`CurseState` rows rather than standing fully apart from them. This is a
template variation to resolve when the first curse-access Prince is authored.

**Proposed lock (D-16) and authoring order (D-17).**
`references/authoring/PDV_Daedric_DecisionPacket_CAT4.md` locks the curse-access
reduced row set (curse-onset replaces the pact; stigma is curse-state-driven;
exit is the cure path; boon/price/tier/response author normally), the no-double-
fire coordination rule with the race manifest `CurseState` rows, and the
batched authoring order. That order fronts a template-variation proof batch
(Azura, Vaermina, Meridia, Molag Bal) before mass-authoring, and notes Hircine
is a content-surface-only pass since its Phase 13/15 mechanics are already
proven. D-18 in the same packet defines the per-Prince content-ready checklist
for the 20C gate. Pending ratification.

---

## 8. Coverage

| Prince | Tone | Boon | Price | Tier-up | Commitment | Stigma | Neglect/Exit | Per-race response | Status |
|---|---|---|---|---|---|---|---|---|---|
| Boethiah | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (8 non-native) | PILOT COMPLETE |
| 15 others | -- | -- | -- | -- | -- | -- | -- | -- | stub (Section 7) |

## 9. Verification

1. **Tool.** `node tools/pdv_content_verify.mjs` validates this file alongside
   the race manifest -- ASCII, per-Surface budgets, slot-ID uniqueness and
   convention, voice matrix, source citations, non-empty prose. A clean run is
   the gate.
2. **No slot collision.** The Daedric Boethiah boon slots
   (`PDV_Bless_Daedric_Boethiah_*`) are distinct from the native Dunmer
   Boethiah blessing (`PDV_Bless_Dunmer_Boethiah_T3`); the verifier's
   cross-file uniqueness check confirms it.
2a. **Matrix fidelity.** The Section 6.8 per-race response states match the
   `Boethiah` row of `PDV_DaedricRacePrinceMatrix.csv`: Nord/Imperial/Breton/
   Bosmer Taboo, Altmer/Orc Hostile, Redguard/Argonian Foreign, Dunmer/Khajiit
   native (routed to the race manifest).
3. **Budget.** Every drafted row is at or under its Surface hard cap; the
   MessageBox rows split into title (40) and body (500) for the check.
