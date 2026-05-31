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

## 7. Daedric Princes (full authoring)

For the Phase 20 content lock, all 16 Skyrim-facing Princes are authored to the
Section 6 Boethiah template (tone profile, boon and price descriptions,
tier-ups, commitment, stigma, neglect, exit, and bespoke per-race responses).
Jyggalag stays out of 1.0 scope per `PDV_TargetEndStates_1.0.md`. Authoring runs
in buildability-ranked batches; each authored Prince is a subsection below, and
the ledger tracks progress. Per-race responses are written individually from
each Prince's `PDV_DaedricRacePrinceMatrix.csv` cell; native-integrated race
cells route to the race manifest and carry no Daedric response row.

**Progress ledger.**

| Prince | Status |
|---|---|
| Boethiah / Boethra | drafted (Section 6 pilot) |
| Azura / Azurah | drafted (Section 7.1) |
| Mephala / Mafala | drafted (Section 7.2) |
| Malacath / Mauloch | drafted (Section 7.3) |
| Meridia | drafted (Section 7.4) |
| Nocturnal | drafted (Section 7.5) |
| Hermaeus Mora | drafted (Section 7.6) |
| Mehrunes Dagon | drafted (Section 7.7) |
| Sheogorath | drafted (Section 7.8) |
| Clavicus Vile | drafted (Section 7.9) |
| Vaermina | drafted (Section 7.10) |
| Sanguine / Sangiin | drafted (Section 7.11) |
| Namira / Namiira | drafted (Section 7.12) |
| Peryite | drafted (Section 7.13) |
| Hircine | drafted (Section 7.14) |
| Molag Bal | drafted (Section 7.15) |

The stub table below keeps each pending Prince's PrincePathType and authoring
notes for reference until it is authored into a subsection.

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

---

### 7.1 Azura

Source: the `Azura / Azurah` row of `PDV_DaedricRacePrinceMatrix.csv` -- PathType `Fate-dawn-dusk-prophecy`, CommitmentSignal `Azura quest outcome, artifact alignment, repeated twilight-threshold acts`, Boon `Threshold foresight and liminal protection`, Price `Fate obligation and prophetic burden`, Hook `The Black Star > Azura shrine > artifact outcome`. Native-integrated for Dunmer and Khajiit (routed to the race manifest); the global path covers the other eight races.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Azura (Daedric path) | Prophetic, twilight-voiced, poised between dawn and dusk; speaks of fate, thresholds, and what is foreseen; the gentlest of the Princes, but her foresight binds. On the global path she is a foreign star, not the Dunmer mother. |

**Boon descriptions** (`PDV_Bless_Daedric_Azura_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Azura_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" Boon; Architecture v3 Section 11.2 | Passive SPEL; pact engaged | Azura opens the threshold a little. At dawn and dusk your sight sharpens -- a brief foresight that reads danger before it strikes. |
| PDV_Bless_Daedric_Azura_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" Boon; Architecture v3 Section 11.2 | Passive SPEL | Azura's twilight is yours. Crossing thresholds -- doorways, dawns, deaths narrowly escaped -- grants a span of clearer sight and warded steps. |
| PDV_Bless_Daedric_Azura_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" Boon; Architecture v3 Section 11.2 | Passive SPEL | Azura names you her seer. Foresight holds through the dim hours; what is fated to harm you announces itself, and her star shelters your passage. |

**Price descriptions** (`PDV_Price_Daedric_Azura_*`). Narrator, 200/140, paired with each boon.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Azura_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" PrimaryPrice | Passive SPEL; paired with the Seeker boon | The price of foresight: the burden of knowing. Visions intrude unbidden, and what you have seen cannot be unseen. |
| PDV_Price_Daedric_Azura_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" PrimaryPrice | Passive SPEL; paired with the Devoted boon | The price deepens: fate obligates. Azura's sight comes with her demands, and the path she shows is not always the one you would choose. |
| PDV_Price_Daedric_Azura_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Azura" PrimaryPrice | Passive SPEL; paired with the Champion boon | The full price: you are bound to the prophecy. The sight that protects you also commits you; you serve the pattern Azura reveals, whether or not it serves you. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Azura_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Azura counts you a Seeker at the threshold. |
| PDV_Notif_Daedric_Azura_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Azura holds you in her twilight. Devoted. |
| PDV_Notif_Daedric_Azura_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Azura's star dims for you. The foresight fades. |
| PDV_Msg_Daedric_Azura_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Azura"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Azura's Seer" Body: "You watched the thresholds and trusted what you saw there. Few outside my children do. I name you seer, Champion -- and a seer belongs to the fate they witness. Walk the pattern. It was always going to be you." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Azura_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Azura" CommitmentSignal | Fires once when the commitment gate clears | Title: "Azura's Star" Body: "Three times you turned toward the dawn-and-dusk and read the omen true. You are not of my Dunmer, and still you came. Take the threshold-sight, and accept its weight: to see what is coming is to be bound to meet it." |

**Stigma band crossings.** Azura is a good Daedra -- lower stigma, but a foreign cult on the global path.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Azura_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Your turn toward Azura is noticed. A foreign star, some murmur. |
| PDV_Notif_Daedric_Azura_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your devotion to Azura is known. To most here she is an outsider's Daedra. |
| PDV_Notif_Daedric_Azura_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Azura's. The wary keep their distance from her seer. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Azura_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You turn from the thresholds. Azura's foresight clouds; only unease remains. |
| PDV_Msg_Daedric_Azura_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Azura's Patience" Body: "You set the star down. Azura does not rage; she has seen this too. The foresight closes, and the world dims to its ordinary dark. What you glimpsed of the pattern lingers, and so does the wariness of those who knew you walked by twilight." |

**Per-race responses** (`PDV_Msg_Daedric_Azura_Response_*`). Narrator, 500/280, one-time on commitment. Eight non-native races; Dunmer and Khajiit route to the race manifest.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Azura_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Nord cell | One-time on a Nord committing | Title: "A Foreign Star Among Nords" Body: "To a Nord, Azura is a foreign cult -- twilight prophecy sits poorly against a hearth-and-war faith built on what a hand can do. The path can be walked, but it strains the Nord frame, and the way back is to cleanse the star and rededicate to the old gods." |
| PDV_Msg_Daedric_Azura_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Imperial cell | One-time on an Imperial committing | Title: "A Cult Outside the Order" Body: "To an Imperial, devotion to Azura reads as a non-civic cult -- a private prophecy outside the Divine public order the Empire keeps. The path strains that order, and return runs through shrine cleansing or rededication to the Nine." |
| PDV_Msg_Daedric_Azura_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Breton cell | One-time on a Breton committing | Title: "Legible, but Watched" Body: "A Breton can read Azura plainly -- threshold witchcraft and star-prophecy are within the Hidden Art's reach. It is intelligible, but socially risky; keep it covered, or rededicate. The danger here is exposure, not incomprehension." |
| PDV_Msg_Daedric_Azura_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Altmer cell | One-time on an Altmer committing | Title: "Apostasy from the Dawn" Body: "For an Altmer, turning to Azura is apostasy -- the Auri-El order does not share its dawn with a Daedric star. The path is taboo, and the road back is difficult absolution, not a simple change of heart." |
| PDV_Msg_Daedric_Azura_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Bosmer cell | One-time on a Bosmer committing | Title: "Foreign to the Green" Body: "To a Bosmer, Azura is intelligible but foreign -- not a Green Pact lane, only an outsider's star. The path can be walked and as easily set down: cleansing, or quiet abandonment, and the Green closes over the gap." |
| PDV_Msg_Daedric_Azura_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Redguard cell | One-time on a Redguard committing | Title: "Outside the Yokudan Way" Body: "To a Redguard, Azura is a foreign star -- not part of the Yokudan pantheon or the way of the sword-singers. The path is outside the lane; leaving it means shrine or ancestor re-entry to the Redguard dead." |
| PDV_Msg_Daedric_Azura_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Orc cell | One-time on an Orc committing | Title: "Beside the Code, Not In It" Body: "For an Orc, Azura sits outside the Malacath code -- an outsider's prophecy with no place in stronghold or oath. The path is taboo beside the code, and renouncing it is hard: the stronghold does not easily forget a star-walker." |
| PDV_Msg_Daedric_Azura_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Azura" Argonian cell | One-time on an Argonian committing | Title: "Outside the Hist" Body: "To an Argonian, Azura has no root in the Hist or the exile community -- she is simply foreign, a star outside the substrate. The path can be walked and then drifted from, or set down by ritual cleansing, and the Hist neither holds nor mourns it." |

---

### 7.2 Mephala

Source: the `Mephala / Mafala` row of the matrix -- PathType `Web-secret-murder-clan`, CommitmentSignal `Whispering Door / Ebony Blade threshold, hidden-loyalty bargains, deliberate web-building`, Boon `Secret-network leverage and hidden-path advantage`, Price `Social corruption and hidden violence`, Hook `The Whispering Door > Ebony Blade > hidden-network choices`. Matrix note: do not flatten Mephala into generic stealth. Native-integrated for Dunmer and Khajiit; the global path covers the other eight races.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Mephala (Daedric path) | Whispering, sidelong, web-voiced; speaks of secrets kept and bonds spun and cut; never raises her voice because she does not need to; offers corruption as intimacy. The web is social and the violence is personal -- not a thief's skill, a spider's patience. |

**Boon descriptions** (`PDV_Bless_Daedric_Mephala_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Mephala_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" Boon | Passive SPEL; pact engaged | Mephala spins you a first thread. Secrets find their way to you, and a hidden path opens where others see only wall. |
| PDV_Bless_Daedric_Mephala_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" Boon | Passive SPEL | Mephala's web is yours to read. Hidden loyalties and unseen routes reveal themselves; what is whispered in one room reaches you in another. |
| PDV_Bless_Daedric_Mephala_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" Boon | Passive SPEL | Mephala names you of the web. The network is yours -- leverage over the connected, passage through the closed, and the quiet knowledge of who owes whom. |

**Price descriptions** (`PDV_Price_Daedric_Mephala_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Mephala_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" PrimaryPrice | Passive SPEL; paired with the Seeker boon | The price of the web: corruption seeps in. The secrets you gather stain the gathering; trust given to you frays a little for the knowing. |
| PDV_Price_Daedric_Mephala_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" PrimaryPrice | Passive SPEL; paired with the Devoted boon | The price deepens: the web demands feeding. Hidden violence and quiet betrayal are its currency, and Mephala's advantage dims if the threads go slack. |
| PDV_Price_Daedric_Mephala_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mephala" PrimaryPrice | Passive SPEL; paired with the Champion boon | The full price: you are a knot in the web, not its master. Every bond you hold holds you; the corruption you spread runs back along the threads to you. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mephala_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Mephala counts you a Seeker of the web. |
| PDV_Notif_Daedric_Mephala_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Mephala draws you into the web. Devoted. |
| PDV_Notif_Daedric_Mephala_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Mephala's threads loosen. The web's advantage thins. |
| PDV_Msg_Daedric_Mephala_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Mephala"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Mephala's Web" Body: "You learned that everything is connected, and that the one who holds the threads holds the room. I do not shout; neither should you. You are of the web now, Champion -- and the web is never set down cleanly. Pull, and see who moves." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Mephala_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Mephala" CommitmentSignal | Fires once when the commitment gate clears | Title: "Mephala's Whisper" Body: "Three times you chose the hidden way -- the bargain struck in the dark, the loyalty spun and cut, the web built with intent. You hear me, then. Take the threads. Their price is that you will never again see a room and not count its secrets." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mephala_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Something about you invites suspicion. People guard their words near you now. |
| PDV_Notif_Daedric_Mephala_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your hand in the hidden web is known. Trust closes quietly wherever you go. |
| PDV_Notif_Daedric_Mephala_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are known for the web you spin. The honest have turned against you. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mephala_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You let the threads go slack. Mephala's web dims; the distrust you spun remains. |
| PDV_Msg_Daedric_Mephala_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Mephala's Indifference" Body: "You cut yourself free of the web. Mephala does not mind -- a single thread is nothing to her. The leverage is gone, the hidden ways close. But the corruption you carried leaves its mark slowly, and those who learned to distrust you do not relearn trust on your schedule." |

**Per-race responses** (`PDV_Msg_Daedric_Mephala_Response_*`). Narrator, 500/280. Eight non-native races; Dunmer and Khajiit route to the race manifest.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Mephala_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Nord cell | One-time on a Nord committing | Title: "Against Open Honor" Body: "To a Nord, Mephala's hidden murder-web is taboo -- it rots the open honor and kin-trust a Nord life is built on. The path can be walked in shadow, but a Nord who walks it works against his own, and the way back is shrine cleansing or outright renunciation." |
| PDV_Msg_Daedric_Mephala_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Imperial cell | One-time on an Imperial committing | Title: "Against Public Virtue" Body: "To an Imperial, Mephala's secrecy is anti-civic -- a corrosion of the public virtue that holds the Empire together. The path is a quiet treason, and return runs through confession and cleansing, or simple abandonment of the threads." |
| PDV_Msg_Daedric_Mephala_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Breton cell | One-time on a Breton committing | Title: "Legible in the Margins" Body: "A Breton can read Mephala plainly -- witchcraft has always kept secrets. It is intelligible but risky; keep the web covered, or rededicate. What undoes a Breton here is exposure, not the strangeness of the thing." |
| PDV_Msg_Daedric_Mephala_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Altmer cell | One-time on an Altmer committing | Title: "Covert Corruption" Body: "For an Altmer, Mephala's covert corruption violates orthodoxy outright -- the project is purity, and the web is rot dressed as intimacy. The path is taboo, and only difficult absolution leads back." |
| PDV_Msg_Daedric_Mephala_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Bosmer cell | One-time on a Bosmer committing | Title: "Trickster, but Not the Green" Body: "A Bosmer feels the trickster overlap -- there is a sidelong kinship -- but Mephala is not Green Pact theology. The path is foreign at root; it is walked lightly and set down by quiet abandonment, not reckoning." |
| PDV_Msg_Daedric_Mephala_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Redguard cell | One-time on a Redguard committing | Title: "Alien to Open Honor" Body: "To a Redguard, the secret-web is alien -- the Yokudan way is open honor and the clean stroke, not the whispered knot. The path is foreign and corrosive to that frame; returning means hard re-entry into the civic trust you spent." |
| PDV_Msg_Daedric_Mephala_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Orc cell | One-time on an Orc committing | Title: "Rot in the Code" Body: "For an Orc, Mephala's hidden corruption strains the Malacath code -- the stronghold runs on plain oath, not secret leverage. The path is taboo, and renunciation comes only through proof and real cost paid back to the kin." |
| PDV_Msg_Daedric_Mephala_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mephala" Argonian cell | One-time on an Argonian committing | Title: "Not a Hist Lane" Body: "To an Argonian, Mephala is foreign -- the Hist does not whisper, and a knack for shadows is not devotion to the web. The path has no root in the substrate; it is simply drifted from, and the Hist neither held it nor misses it." |

---

### 7.3 Malacath

Source: the `Malacath / Mauloch` row of the matrix -- PathType `Oath-exile-code-vengeance`, CommitmentSignal `The Cursed Tribe / Volendrung / Blood-Kin / exile-defense threshold`, Boon `Endurance, oath retaliation, and outsider resilience`, Price `Harsh judgment and code burden`, Hook `The Cursed Tribe > Volendrung > stronghold/Blood-Kin context`. Matrix note: Orc-native exception, Redguard hostility (Malooc) explicitly preserved. Native-integrated for Orc (routed to the race manifest); the global path covers the other nine races.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Malacath (Daedric path) | Blunt, bitter, oath-bound; the god of the spurned and exiled; speaks of the code kept, the oath answered, the strong enduring what breaks the weak; no comfort, only respect earned. On the global path he is the outsider's god, pariah-strength offered to the cast-out of any race. |

**Boon descriptions** (`PDV_Bless_Daedric_Malacath_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Malacath_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" Boon | Passive SPEL; pact engaged | Malacath hardens the outcast. You endure a little more before you break, and a blow struck against you is answered the harder. |
| PDV_Bless_Daedric_Malacath_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" Boon | Passive SPEL | Malacath's endurance is yours. Pain moves you less, and those who break their oath to you, or strike you first, take the cost back doubled. |
| PDV_Bless_Daedric_Malacath_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" Boon | Passive SPEL | Malacath names you of the spurned-and-strong. You stand where others fall, your oath is iron, and vengeance for a broken word comes due through your hand. |

**Price descriptions** (`PDV_Price_Daedric_Malacath_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Malacath_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" PrimaryPrice | Passive SPEL; paired with the Seeker boon | The price of the code: harsh judgment. Malacath holds you to the oath as hard as your enemies, and weakness in yourself is not forgiven. |
| PDV_Price_Daedric_Malacath_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" PrimaryPrice | Passive SPEL; paired with the Devoted boon | The price deepens: the code burdens. You cannot bend a sworn word without loss, and the world treats the pariah-god's follower as the outsider he is. |
| PDV_Price_Daedric_Malacath_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Malacath" PrimaryPrice | Passive SPEL; paired with the Champion boon | The full price: you are the code, and it is merciless. Every oath binds you absolutely; every mercy you would give, Malacath counts as weakness, and the exile he grants is permanent. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Malacath_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Malacath counts you a Seeker of the code. |
| PDV_Notif_Daedric_Malacath_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Malacath counts your oath iron. Devoted. |
| PDV_Notif_Daedric_Malacath_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Malacath's regard hardens away. The code's strength leaves you. |
| PDV_Msg_Daedric_Malacath_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Malacath"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Malacath's Sworn" Body: "You are not mine by blood, and still you kept the oath when keeping it cost you everything. That is the code. The spurned do not get comfort, Champion -- they get strength, and the right to endure. Stand. That is all I have ever asked of anyone." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Malacath_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Malacath" CommitmentSignal | Fires once when the commitment gate clears | Title: "Malacath's Oath" Body: "Three times you stood by the sworn word when the easy road was to break it, and three times you took the outsider's part. You understand me, though you are not Orc. Take the code. Its price is that you will be held to it without mercy, by me and by everyone who learns whose god you keep." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Malacath_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Your turn to the pariah-god is suspected. Some eye the outsider's strength. |
| PDV_Notif_Daedric_Malacath_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your oath to Malacath is known. He is the spurned Daedra here; you are suspect. |
| PDV_Notif_Daedric_Malacath_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Malacath's. The wary treat his sworn as one of the cast-out. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Malacath_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You let the oath go soft. Malacath's strength withdraws; only the mark stays. |
| PDV_Msg_Daedric_Malacath_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Malacath's Contempt" Body: "You set the code down. Malacath has no surprise in him -- the weak always find the oath too heavy in the end. The endurance leaves you. The mark of the pariah fades on its own slow time, and the people who saw you swear by the spurned god remember it longer than you would like." |

**Per-race responses** (`PDV_Msg_Daedric_Malacath_Response_*`). Narrator, 500/280. Nine non-native races; Orc routes to the race manifest.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Malacath_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Nord cell | One-time on a Nord committing | Title: "An Outsider's God" Body: "To a Nord, Malacath is an understandable outsider god -- strength and grudge are not strange -- but he is not a normal Nord lane. The path is foreign; it can be walked and then abandoned, or cleansed away at a shrine of the old gods." |
| PDV_Msg_Daedric_Malacath_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Imperial cell | One-time on an Imperial committing | Title: "Civically Suspect" Body: "To an Imperial, Malacath is a legally and civically suspect path -- an outsider's god whose code answers oath with vengeance, not law. The path strains the civic order; return runs through cleansing or public renunciation." |
| PDV_Msg_Daedric_Malacath_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Breton cell | One-time on a Breton committing | Title: "A Harsh Outsider Code" Body: "A Breton can read Malacath as a harsh outsider code -- intelligible, even respectable in its way -- but it is not the Breton baseline. The path is foreign; keep it covered, or renounce it, as the occult margins allow." |
| PDV_Msg_Daedric_Malacath_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Dunmer cell | One-time on a Dunmer committing | Title: "House of Troubles" Body: "To a Dunmer, Malacath sits near the House of Troubles -- a pressure to be warded against, not a devotion to keep. The path is taboo against the Reclamations and ancestors; the way back is hard rededication to the proper dead." |
| PDV_Msg_Daedric_Malacath_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Altmer cell | One-time on an Altmer committing | Title: "The Degraded Ancestor" Body: "For an Altmer, Malacath is the degraded ancestor -- Trinimac unmade, the orthodoxy's worst cautionary tale worn as a crown. To follow him is taboo against everything the project means, and only difficult absolution leads back." |
| PDV_Msg_Daedric_Malacath_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Khajiit cell | One-time on a Khajiit committing | Title: "Outside the Lattice" Body: "To a Khajiit, Malacath is foreign -- not a lunar lane, no thread in the Lattice. The path is an outsider's, walked and then abandoned, or cleansed; the moons neither lit it nor lose it." |
| PDV_Msg_Daedric_Malacath_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Bosmer cell | One-time on a Bosmer committing | Title: "Exile, but Not the Green" Body: "A Bosmer can read Malacath's exile -- the Wild-Hunt world knows the cast-out -- but it is not a core Bosmer path. The way is foreign at root; it is drifted from, not renounced, and the Green closes over it." |
| PDV_Msg_Daedric_Malacath_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Redguard cell; Notes "Redguard hostility (Malooc) explicitly preserved" | One-time on a Redguard committing | Title: "Malooc the Enemy" Body: "For a Redguard this is not mere foreignness. Malacath is Malooc, the enemy-god of the old crossing, a cautionary name spoken against. To take this oath is severe rupture against the Yokudan dead, and there is no gentle road back from it." |
| PDV_Msg_Daedric_Malacath_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Malacath" Argonian cell | One-time on an Argonian committing | Title: "Outside the Hist" Body: "To an Argonian, Malacath is foreign -- no root in the Hist, no place in the exile community despite his exile theme. The path is an outsider's; it is set down by quiet abandonment, and the substrate neither held it nor marks its leaving." |

---

### 7.4 Meridia

Source: the `Meridia` row of the matrix -- PathType `Cleansing-light-anti-undead overlay`, CommitmentSignal `Meridia quest outcome, Dawnbreaker service, repeated undead-cleansing milestones`, Boon `Anti-undead zeal, purity drive, cleansing instinct`, Price `Authoritarian purity and anti-undead intolerance`, Hook `The Break of Dawn > Dawnbreaker > undead/necromancer cleansing`. Matrix note: best treated as tolerated-access in several cultures without becoming native. No native-integration exception -- all ten races carry per-race responses.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Meridia (Daedric path) | Radiant, imperious, absolute; the god of cleansing light who views the undead as affront and corruption as enemy; speaks in declarations, not invitations -- she names the work and expects it done. The path is a covenant to fight on her behalf, not a warmth extended; her register is command, not comfort. |

**Boon descriptions** (`PDV_Bless_Daedric_Meridia_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Meridia_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" Boon | Passive SPEL; pact engaged | Meridia's light stirs in you. Undead recoil a little more sharply, and corruption finds you harder to take. |
| PDV_Bless_Daedric_Meridia_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" Boon | Passive SPEL | Meridia's radiance is yours in full. The undead burn before you, and the creeping rot of enchanted corruption struggles against your skin. |
| PDV_Bless_Daedric_Meridia_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" Boon | Passive SPEL | Meridia names you her cleansing blade. You scourge the undead, and the radiance turns corruption aside before it can take hold. |

**Price descriptions** (`PDV_Price_Daedric_Meridia_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Meridia_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the radiance: purity demanded. Meridia will not tolerate compromise, and her follower acts before rot spreads. |
| PDV_Price_Daedric_Meridia_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: intolerance is yours. Meridia presses the war outward; hesitation against the risen finds her regard cooling. |
| PDV_Price_Daedric_Meridia_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Meridia" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: the mandate is absolute. The undead are enemy, corruption is enemy. Meridia does not negotiate with what must be burned. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Meridia_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Meridia marks you a Seeker of the light. |
| PDV_Notif_Daedric_Meridia_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Meridia's radiance holds you. Devoted. |
| PDV_Notif_Daedric_Meridia_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Meridia's light dims in you. The cleansing edge withdraws. |
| PDV_Msg_Daedric_Meridia_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Meridia"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Meridia's Cleansing Agent" Body: "You have proven you understand the work. The undead are an affront to the living world, and corruption is the rot they spread. You are my instrument. Not a weapon I hold -- you act of your own will, in my name. Carry the light forward." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Meridia_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Meridia" CommitmentSignal | Fires once when the commitment gate clears | Title: "Meridia's Covenant" Body: "You answered my call. You stood against the risen dead without being forced, and then again, and again -- because that is what you are. The covenant is simple: the undead are enemy. I ask nothing else of you, and nothing less." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Meridia_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Meridia's mark on you is suspected. Some note the zeal and watch. |
| PDV_Notif_Daedric_Meridia_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Meridia devotion is known. She is Daedric; the light does not change it. |
| PDV_Notif_Daedric_Meridia_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Meridia's. The cleansing mission reads as Daedric zealotry. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Meridia_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You leave the undead unchallenged. Meridia's radiance dims in you. |
| PDV_Msg_Daedric_Meridia_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Meridia's Dismissal" Body: "You set down the covenant. Meridia does not argue; she does not plead. The cleansing edge leaves you, and the undead are no longer your charge. The corruption you did not finish has a long memory." |

**Per-race responses** (`PDV_Msg_Daedric_Meridia_Response_*`). Narrator, 500/280. All ten races; no native-integration exceptions.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Meridia_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Nord cell | One-time on a Nord committing | Title: "Useful Light, Outside Creed" Body: "A Nord reads the anti-undead work plainly -- Meridia scours what dishonors the dead, and that fits. But she is Daedric, and Nord creed runs to the Nine, not to princes whose light happens to run the right direction. Setting it down is sincere redirection, not rupture." |
| PDV_Msg_Daedric_Meridia_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Imperial cell | One-time on an Imperial committing | Title: "Civic Use, Not Civic Faith" Body: "An Imperial can respect Meridia's anti-undead work -- the Divines approve the service in principle. But Meridia is not Divine, and Imperial devotion has proper channels. This is borrowed from a Daedric frame; the way back is shrine cleansing and recommitment." |
| PDV_Msg_Daedric_Meridia_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Breton cell | One-time on a Breton committing | Title: "Not the Witchcraft Lane" Body: "A Breton reads Meridia's radiance as adjacent to healing arts -- the light fighting corruption has a familiar shape. The path sits outside the witchcraft risk band, which makes it relatively comfortable for a Breton. Rededication is normal if it runs its course." |
| PDV_Msg_Daedric_Meridia_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Dunmer cell | One-time on a Dunmer committing | Title: "Useful Against the Risen" Body: "A Dunmer can see the use -- Meridia fights the undead, and that matter is never far from Morrowind's frame. But she is not Tribunal or Reclamation; she sits outside the Dunmer center entirely. The path is foreign, and setting it down asks only quiet abandonment." |
| PDV_Msg_Daedric_Meridia_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Altmer cell | One-time on an Altmer committing | Title: "Outside Orthodoxy, Not Ruin" Body: "An Altmer sees Meridia as foreign -- Daedric, outside Aldmeri orthodoxy, and not the return theology of Auri-El. But she is not a catastrophic choice in the way some Princes are. Renunciation is difficult but available through sincere absolution." |
| PDV_Msg_Daedric_Meridia_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Khajiit cell | One-time on a Khajiit committing | Title: "Light Without a Moon Lane" Body: "A Khajiit may respect Meridia's anti-undead work -- the moons have enemies, and she fights them. But she holds no position in the lunar lattice; she is not a moon-lane. The path sits outside the substrate and is set down by straightforward abandonment." |
| PDV_Msg_Daedric_Meridia_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Bosmer cell | One-time on a Bosmer committing | Title: "Useful, Not Green" Body: "A Bosmer has no deep conflict with fighting the undead -- the Green Pact does not defend the risen. But Meridia is not Green Pact theology; the cleansing light has no root in the covenant. The path is not hostile to Bosmer conscience; it simply runs its course and is set down." |
| PDV_Msg_Daedric_Meridia_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Redguard cell | One-time on a Redguard committing | Title: "Tu'whacca's Margin" Body: "For a Redguard, Meridia's work aligns with Tu'whacca's own -- both concern the proper rest of the dead. The path is tolerated when it serves that interest and stays subordinate to it. Setting it down is normal civic re-entry; Tu'whacca holds no grudge at work done on his behalf." |
| PDV_Msg_Daedric_Meridia_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Orc cell | One-time on an Orc committing | Title: "Useful to the Stronghold" Body: "An Orc sees the value in cleansing -- undead are enemies, and Meridia fights them. But she is not Malacath; she speaks nothing of the code or the exile. The path is foreign utility, and it is renounced the Orc way: prove the oath to the code, and set the light down." |
| PDV_Msg_Daedric_Meridia_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Meridia" Argonian cell | One-time on an Argonian committing | Title: "Not a Hist Channel" Body: "An Argonian can find use in Meridia's corruption-fighting -- the Hist is not indifferent to rot. But Meridia is not the Hist; her light carries no bond to the community or the memory. The path is foreign, set down when its work is done, with no residue." |

---

### 7.5 Nocturnal

Source: the `Nocturnal` row of the matrix -- PathType `Shadow-oath-luck-debt`, CommitmentSignal `Thieves Guild / Nightingale oath / Skeleton Key threshold`, Boon `Secrecy, opportunism, luck-seeking, criminal glamour`, Price `Debt, oath-binding, and luck withdrawal`, Hook `Thieves Guild > Nightingale oath > Skeleton Key`. Matrix note: keep Rajhin and Baan Dar distinct from Nocturnal. No native-integration exception; Rajhin (Khajiit) and Baan Dar (Bosmer) are separate native lanes -- Nocturnal is external pressure in both.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Nocturnal (Daedric path) | Detached, cryptic, contractual; the god of shadow, luck, and debt who speaks in inevitability, not command -- the oath was always yours, the debt was always coming, and she merely records it; cool and distant, neither warm nor punishing; her register is the certainty of the ledger kept in the dark. |

**Boon descriptions** (`PDV_Bless_Daedric_Nocturnal_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Nocturnal_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" Boon | Passive SPEL; pact engaged | Shadow luck covers you. Small fortunate turns come more often; the unseen paths open a little wider. |
| PDV_Bless_Daedric_Nocturnal_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" Boon | Passive SPEL | Nocturnal's shade deepens. Luck favors you more reliably, and in shadows you move as though they expect you. |
| PDV_Bless_Daedric_Nocturnal_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" Boon | Passive SPEL | Nocturnal's debt runs in your favor. Fortune tilts for you in the dark; shadows are allies, and your concealment in them is absolute. |

**Price descriptions** (`PDV_Price_Daedric_Nocturnal_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Nocturnal_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the shadow: the oath binds. What you owe Nocturnal has no stated invoice, only the certainty that it comes due eventually. |
| PDV_Price_Daedric_Nocturnal_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: the debt has weight. Luck does not withdraw, but the oath tightens; Nocturnal does not forget, and the shadow does not either. |
| PDV_Price_Daedric_Nocturnal_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Nocturnal" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: the oath is you now. Nocturnal is patient. She takes her due when the circumstances are right, and the sworn servant always finds it was implied in the terms they accepted. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Nocturnal_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Nocturnal acknowledges you. Seeker of the shadow. |
| PDV_Notif_Daedric_Nocturnal_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Nocturnal's shadow runs deeper in you. Devoted. |
| PDV_Notif_Daedric_Nocturnal_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Nocturnal's luck turns away. The shadow grows indifferent. |
| PDV_Msg_Daedric_Nocturnal_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Nocturnal"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Nocturnal's Nightingale" Body: "Every oath to me echoes through the Evergloam eventually. You found yours through choice, which is unusual. The luck stays, the shadow stays, and the debt is recorded as it always was. You are mine -- which means the dark is yours, and the terms were always clear." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Nocturnal_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Nocturnal" CommitmentSignal | Fires once when the commitment gate clears | Title: "Nocturnal's Claim" Body: "Three times you chose the shadow when the open path was easier. You understand the terms now -- not fully, because no one does, but enough. The luck is real, the concealment is real, and the price is real. This is what you agreed to." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Nocturnal_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Nocturnal's oath on you is suspected. The shadow leaves a residue some can read. |
| PDV_Notif_Daedric_Nocturnal_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your oath to Nocturnal is known. The shadow-debt is not civil; people note it. |
| PDV_Notif_Daedric_Nocturnal_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Nocturnal's. The oath marks you as outside the civic order. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Nocturnal_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You leave the shadow unused. Nocturnal's luck withdraws; only the debt stays. |
| PDV_Msg_Daedric_Nocturnal_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Nocturnal's Release" Body: "You release the oath. Nocturnal does not argue; she is patient with all things. The shadow luck withdraws and the concealment with it. The Evergloam keeps the record, and the debt is listed as settled -- which is the nearest thing to forgiveness she extends." |

**Per-race responses** (`PDV_Msg_Daedric_Nocturnal_Response_*`). Narrator, 500/280. All ten races; Rajhin (Khajiit native trickster) and Baan Dar (Bosmer native trickster) are kept explicitly distinct from Nocturnal.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Nocturnal_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Nord cell | One-time on a Nord committing | Title: "Against Open Honor" Body: "For a Nord, Nocturnal's oath-cult corrupts the open honor that Nord life rests on. Shadow-bargaining is not the way of the mead-hall or the honest fight. Leaving asks real effort: renounce the oath directly, or carry the residue." |
| PDV_Msg_Daedric_Nocturnal_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Imperial cell | One-time on an Imperial committing | Title: "Outside the Legal Order" Body: "For an Imperial, a shadow-cult oath strains the legal and divine order both -- the Divines are the proper frame, and criminal devotion is anti-civic by definition. The path is private apostasy, and leaving it is hardest through formal oath release. Without that, the residue lingers." |
| PDV_Msg_Daedric_Nocturnal_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Breton cell | One-time on a Breton committing | Title: "Margins of the Craft" Body: "A Breton reads Nocturnal's shadow bargains clearly -- they sit at the margins of the craft and the secret society tradition that has always run through Breton culture. The path is legible but publicly staining; cover it, or release the oath and rededicate." |
| PDV_Msg_Daedric_Nocturnal_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Dunmer cell | One-time on a Dunmer committing | Title: "Outside the Hidden Web" Body: "A Dunmer can see Nocturnal's hidden-network shape -- it resembles Mephala's web. But Nocturnal is not the Reclamations; she is an outsider wearing familiar clothes. Hard rededication runs through the Reclamation proper, not simple abandonment." |
| PDV_Msg_Daedric_Nocturnal_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Altmer cell | One-time on an Altmer committing | Title: "Apostasy by Oath" Body: "For an Altmer, a shadow-cult oath is apostasy against Aldmeri order outright. The trickster and the web have no sanctioned place, and Nocturnal's secrecy-devotion compounds it. Absolution is difficult and requires sincere effort." |
| PDV_Msg_Daedric_Nocturnal_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Khajiit cell; Notes "Rajhin remains native trickster lane" | One-time on a Khajiit committing | Title: "Not Rajhin's Lane" Body: "A Khajiit knows the trickster trade -- Rajhin walked it first and holds that lane. Nocturnal wears the same cut but is not native; her oath is Daedric, outside the lattice. It sits poorly beside Rajhin's memory. Exit is oath release or clean withdrawal." |
| PDV_Msg_Daedric_Nocturnal_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Bosmer cell; Notes "Baan Dar remains native trickster core" | One-time on a Bosmer committing | Title: "Baan Dar's Margin" Body: "A Bosmer finds Nocturnal familiar at the surface -- Baan Dar is native cunning, and shadow margins are not foreign to the Green Pact world. But Nocturnal is not Baan Dar. Leaving is oath release or a costly switch back to the native trickster lane." |
| PDV_Msg_Daedric_Nocturnal_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Redguard cell | One-time on a Redguard committing | Title: "Against Honor's Record" Body: "For a Redguard, a shadow oath is anti-honor -- the Yokudan way is the open name and the kept word. Nocturnal's debt is the inverse: the hidden name, the debt you cannot see. Leaving requires sincere renunciation and the slow restoration of trust spent." |
| PDV_Msg_Daedric_Nocturnal_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Orc cell | One-time on an Orc committing | Title: "Not the Code's Cunning" Body: "An Orc can see the use in Nocturnal's shadow -- exiles live in the margins. But cunning for its own sake is not Malacath's code; that is plain oath, not hidden debt. Exit is oath release or direct renunciation, then prove the code in some visible form." |
| PDV_Msg_Daedric_Nocturnal_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Nocturnal" Argonian cell | One-time on an Argonian committing | Title: "Not a Shadow of the Hist" Body: "To an Argonian, Nocturnal is foreign -- stealth and outsider life do not constitute devotion to the shadow. The Hist does not whisper through Nocturnal, and her oath carries no bond to the community. The path simply drifts away, or is cleansed directly." |

---

### 7.6 Hermaeus Mora

Source: the `Hermaeus Mora` row of the matrix -- PathType `Forbidden-knowledge-artifact`, CommitmentSignal `Discerning the Transmundane, Oghma Infinium, Black Book acceptance, dangerous secret bargains`, Boon `Curiosity, private scholarship, forbidden archives, truth-at-cost appetite`, Price `Knowledge corruption and agency erosion`, Hook `Discerning the Transmundane > Oghma Infinium > Black Books`. Matrix notes: Khajiit legibility (Hermorah) does not mean lunar-lane replacement; Bosmer Herma-Mora is kept explicitly separate. No native-integration exception. **EditorID note:** Slot IDs use the token `Mora` for this Prince; IDs with extended suffixes (e.g. `_Stigma_Suspected`, `_ChampionEntry`, `_Response_*`) exceed 32 chars and are flagged for Phase 19 abbreviation review -- not renamed now.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Hermaeus Mora (Daedric path) | Vast, patient, archival; the god of what is known and what should not be known; speaks as though the answer is already recorded and you are the last to arrive at it; impersonal, encyclopedic, faintly horrifying in completeness -- he takes your secrets as tribute and your agency as a ledger entry; no warmth, no malice, only the accumulation. |

**Boon descriptions** (`PDV_Bless_Daedric_Mora_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Mora_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" Boon | Passive SPEL; pact engaged | Mora's archive opens a corner. You retain more of what you study; knowledge surfaces from texts that should give less. |
| PDV_Bless_Daedric_Mora_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" Boon | Passive SPEL | Mora's collection deepens in you. Spell insight comes faster, and dangerous texts open their secrets to your study without the usual cost. |
| PDV_Bless_Daedric_Mora_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" Boon | Passive SPEL | Mora names you archivist. Secrets yield; forbidden knowledge is yours; what drives lesser scholars to ruin is a tool in your hands. |

**Price descriptions** (`PDV_Price_Daedric_Mora_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Mora_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the archive: knowledge corrupts. What you learn through Mora changes how you think, and some cannot be unlearned. |
| PDV_Price_Daedric_Mora_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: agency erodes. Mora's archive pulls; curiosity becomes compulsion, and the questions grow larger than the questioner. |
| PDV_Price_Daedric_Mora_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hermaeus Mora" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: the archive owns you. Mora holds what you have learned, and you are catalogued alongside the things you studied. Agency is a recorded entry, not a living condition. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mora_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Mora opens a section for you. Seeker. |
| PDV_Notif_Daedric_Mora_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Mora's archive deepens its claim. Devoted. |
| PDV_Notif_Daedric_Mora_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Mora's archive closes. The forbidden knowledge dims. |
| PDV_Msg_Daedric_Mora_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Hermaeus Mora"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Mora's Archivist" Body: "You have given me three things: your curiosity, your willingness to pay for it, and your silence on what you found. The archive is open. The Black Books, the dark corners, what other scholars refused -- yours to handle. You are catalogued now, beside all of it." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Mora_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Hermaeus Mora" CommitmentSignal | Fires once when the commitment gate clears | Title: "Mora's Contract" Body: "Three times you paid the cost for knowledge and took it anyway. That is not wisdom; it is devotion. The contract is registered: access for tribute. What you know belongs to the archive, and the archive belongs to you as much as it belongs to anyone." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mora_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Mora's mark on you is suspected. Some sense the forbidden in the study. |
| PDV_Notif_Daedric_Mora_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your debt to Mora is known. Forbidden knowledge marks its keeper. |
| PDV_Notif_Daedric_Mora_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Mora's archivist. The forbidden archive marks you as other. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Mora_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You stop seeking. Mora's archive dims; the knowledge fades. |
| PDV_Msg_Daedric_Mora_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Mora's Release" Body: "You withdraw from the archive. Mora records it -- anticipated; you were always going to leave eventually. The knowledge dims, the spell insight closes. What you learned remains yours, but Mora's direct access withdraws. The record stands." |

**Per-race responses** (`PDV_Msg_Daedric_Mora_Response_*`). Narrator, 500/280. All ten races; Hermorah (Khajiit) is legible but not a native lane; Herma-Mora (Bosmer lore) is kept explicitly separate from this devotion path.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Mora_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Nord cell | One-time on a Nord committing | Title: "Outside the Mythic Frame" Body: "For a Nord, Mora's forbidden archive has no place in the mythic frame -- Sovngarde has no wing for Apocrypha. Dangerous knowledge for its own sake runs counter to Nord honor and straightforward spiritual life. Leaving asks real cleansing and recommitment." |
| PDV_Msg_Daedric_Mora_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Imperial cell | One-time on an Imperial committing | Title: "Anti-Civic Knowledge" Body: "For an Imperial, forbidden scholarship is anti-civic -- it erodes the public trust and divine order that Imperial life rests on. Mora is the private enemy of the institutional. Abandonment requires more than withdrawal: cleansing, and re-entry into the civic devotional frame." |
| PDV_Msg_Daedric_Mora_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Breton cell | One-time on a Breton committing | Title: "Dangerous Scholarship" Body: "A Breton reads Hermaeus Mora plainly -- forbidden archives fit the Breton intellectual inheritance, from Mages Guild private libraries to the old conjuration lines. The path is legible but costly; keep it covered, or renounce and rededicate." |
| PDV_Msg_Daedric_Mora_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Dunmer cell | One-time on a Dunmer committing | Title: "Not the Inner Circle" Body: "A Dunmer scholar may engage Mora at the margins -- Great House politics have always touched dangerous knowledge. But Mora is not Tribunal revelation or Reclamation anchor; he is an outsider's archive. The path closes by abandonment and careful rededication." |
| PDV_Msg_Daedric_Mora_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Altmer cell | One-time on an Altmer committing | Title: "Study Is Not Worship" Body: "For an Altmer, the temptation is to read Mora as a superior scholar. That reading is apostasy -- study is not worship, and Mora is not an emanation of the light. Aldmeri orthodoxy treats his archive as corruption of the purity project. Absolution is difficult." |
| PDV_Msg_Daedric_Mora_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Khajiit cell; Notes "Hermorah legible but not a native lane" | One-time on a Khajiit committing | Title: "Hermorah Is Legible" Body: "A Khajiit finds Hermaeus Mora legible through Hermorah, the Khajiiti shape of the same entity. But legibility is not a native lane; Hermorah does not feed the Lunar Mandate. Quiet withdrawal or native reframing keeps the lunar substrate intact." |
| PDV_Msg_Daedric_Mora_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Bosmer cell; Notes "explicit correction keeps Bosmer Herma-Mora separate" | One-time on a Bosmer committing | Title: "Herma-Mora, Kept Separate" Body: "A Bosmer knows Herma-Mora in their own stories -- the old test, the temptation at the boundary. But the Green Pact keeps that distance explicit. Walking into the archive is different from knowing the story. The path is foreign to Bosmer backbone and set down by abandonment." |
| PDV_Msg_Daedric_Mora_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Redguard cell | One-time on a Redguard committing | Title: "Dangerous Scholarship, No Home" Body: "For a Redguard, dangerous scholarship exists -- the Ra Gada have records of what to avoid -- but Mora is not a Redguard frame. The archive is foreign, without Yokudan grounding. The path is set down by abandonment; it leaves no deep mark if sincerely relinquished." |
| PDV_Msg_Daedric_Mora_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Orc cell | One-time on an Orc committing | Title: "Knowledge at Oath Cost" Body: "An Orc can be drawn to Mora through the exile's pragmatism -- dangerous knowledge is power. But Malacath's code requires the oath spoken plainly, not the silent debt. The archive is taboo here, and leaving requires renouncing through real cost paid against the code." |
| PDV_Msg_Daedric_Mora_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hermaeus Mora" Argonian cell | One-time on an Argonian committing | Title: "Not What the Hist Keeps" Body: "To an Argonian, Mora's archive is foreign -- the Hist keeps its own knowledge, and Apocrypha is not that. What matters in exile is not what the Hist holds. The path is set down by abandonment; the Hist does not hold the loss against the one who returns." |

---

### 7.7 Mehrunes Dagon

Source: the `Mehrunes Dagon` row of the matrix -- PathType `Destruction-revolution-ruin`, CommitmentSignal `Pieces of the Past, Razor commitment, catastrophic overthrow alignment`, Boon `Attraction to ruin, anti-order violence, revolutionary destruction`, Price `Ruin escalation and civic-spiritual rupture`, Hook `Pieces of the Past > Mehrunes' Razor > destructive outcomes`. Matrix note: Imperial hostility is stronger than generic taboo because of Oblivion Crisis memory; Redguard cell is also Hostile (destroyer of the way-making civilization). No native-integration exception; slot IDs use `Dagon` token.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Mehrunes Dagon (Daedric path) | Wrathful, totalizing, grandiose; the Prince of Destruction does not argue his case -- the end is a command he expects you to execute, not a cause he persuades you toward; his register is contemptuous of mortal hesitation and absolutely certain of the result; he is cold toward mortal concerns but his conviction about destruction is furious and absolute; he commands, tests, and dismisses -- you are either the instrument of the ruin or you are in the way of it. |

**Boon descriptions** (`PDV_Bless_Daedric_Dagon_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Dagon_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" Boon | Passive SPEL; pact engaged | Dagon's edge settles in you. Your blow against what is entrenched carries extra weight; the wall that should hold breaks first. |
| PDV_Bless_Daedric_Dagon_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" Boon | Passive SPEL | Dagon's ruin deepens in you. Barriers fall faster, fortifications yield, and the things built to last crack first. |
| PDV_Bless_Daedric_Dagon_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" Boon | Passive SPEL | Dagon names you his ruin made walking. What stands is enemy; what is entrenched is target. You are the end that cannot be stopped. |

**Price descriptions** (`PDV_Price_Daedric_Dagon_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Dagon_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the ruin path: escalation. Dagon does not distinguish your order from the enemy's; the destruction begins to include you. |
| PDV_Price_Daedric_Dagon_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: civic rupture. The communities that held you are part of the order Dagon destroys; the world around you empties. |
| PDV_Price_Daedric_Dagon_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Mehrunes Dagon" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: you are the principle. Dagon's ruin does not stop when you stop pointing it; you have become the revolution, no off state. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Dagon_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Dagon marks you a Seeker of the ruin path. |
| PDV_Notif_Daedric_Dagon_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Dagon's ruin runs in you. Devoted. |
| PDV_Notif_Daedric_Dagon_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Dagon's favor withdraws. The destructive edge dims. |
| PDV_Msg_Daedric_Dagon_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Mehrunes Dagon"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Dagon's Ruin-Walker" Body: "Three times you brought the walls down without flinching. I do not congratulate instruments -- I deploy them. You are my Walker. The Razor is yours in spirit if not in hand, and the order standing before you is already ending. Do not stop. I do not tolerate hesitation in what I name mine." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Dagon_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Mehrunes Dagon" CommitmentSignal | Fires once when the commitment gate clears | Title: "Dagon's Call" Body: "Three times you chose the ruin when you could have preserved it. You understand what I demand. Take the Walker's edge: the works of order are the target, the destruction does not ask permission, and neither will you. You are mine. Begin." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Dagon_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Dagon's path is suspected on you. Some read the ruins you leave. |
| PDV_Notif_Daedric_Dagon_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your devotion to Dagon is known. A ruin-walker leaves more than enemies behind. |
| PDV_Notif_Daedric_Dagon_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Dagon's. The ruin-walker is not trusted by any settled order. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Dagon_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You step back from the ruin. Dagon's edge dims; the destructive drive fades. |
| PDV_Msg_Daedric_Dagon_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Dagon's Severance" Body: "You leave the ruin path. Dagon dismisses it -- destruction needs no particular instrument, and you were always replaceable. The edge leaves you. What you fractured does not heal, but it no longer grows. That is the full accounting of what you chose to stop being." |

**Per-race responses** (`PDV_Msg_Daedric_Dagon_Response_*`). Narrator, 500/280. All ten races. Imperial and Redguard cells are Hostile (hardest rupture framing); all others are Taboo except Argonian (Foreign).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Dagon_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Nord cell | One-time on a Nord committing | Title: "Against Hearth and Continuity" Body: "For a Nord, Dagon's ruin cult attacks hearth, continuity, and the kin-bonds that Nord life rests on. The apocalypse opposes Shor's hall and the honoring of the dead. Leaving asks sincere cleansing and rededication; the rupture leaves a mark." |
| PDV_Msg_Daedric_Dagon_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Imperial cell; Notes "Imperial hostility stronger than generic taboo, Oblivion memory" | One-time on an Imperial committing; Hostile cell -- maximum rupture framing | Title: "Enemy of the Empire" Body: "For an Imperial, Dagon is not taboo -- he is enemy. The Oblivion Crisis is recent: cities burned, gates opened, the Emperor died. This oath is active betrayal of everything Imperial. There is no gentle exit; the rupture is total, and return is hard and public." |
| PDV_Msg_Daedric_Dagon_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Breton cell | One-time on a Breton committing | Title: "Occult Rebellion, Social Ruin" Body: "A Breton can read Dagon's revolutionary energy -- the occult rebellion has a shape Breton culture knows. But the apocalypse is not manageable; the catastrophe is social ruin even for the practitioner. Cover is possible early; direct renunciation is the cleaner path." |
| PDV_Msg_Daedric_Dagon_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Dunmer cell | One-time on a Dunmer committing | Title: "Outsider Ruin Path" Body: "For a Dunmer, Dagon's ruin has no home in layered duty or community. The Reclamations are about reclaiming, not ending. Destruction for its own sake cuts against House loyalty, kin-debt, and the ancestor-substrate. It is set down by abandonment and redirection." |
| PDV_Msg_Daedric_Dagon_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Altmer cell | One-time on an Altmer committing | Title: "Against the Ordained Order" Body: "For an Altmer, Dagon is the opposite of the Aldmeri project -- Apotheosis, purity, return to Auri-El are upward trajectories, and Dagon is their negation. The cult is not merely heretical; it is structurally incompatible. Absolution is difficult and requires genuine re-anchoring." |
| PDV_Msg_Daedric_Dagon_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Khajiit cell | One-time on a Khajiit committing | Title: "Chaos, Not Dark Pressure" Body: "A Khajiit can read Dagon as dark pressure -- chaos is not unknown to the lattice. But his ruin cult is not a moon lane; it conflicts with the lunar order rather than supplements it. The path is dark indulgence, not substrate fit, and is set down by abandonment." |
| PDV_Msg_Daedric_Dagon_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Bosmer cell | One-time on a Bosmer committing | Title: "Against Continuity and Covenant" Body: "For a Bosmer, Dagon's ruin cult is anti-covenant -- the Green Pact is continuity, and ruin is its opposite. The end of things is not Bosmer theology even in its darkest corners. The path is not legible here; renunciation is the only clean exit." |
| PDV_Msg_Daedric_Dagon_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Redguard cell; Hostile cell -- severe rupture framing | One-time on a Redguard committing | Title: "Enemy of the Way-Makers" Body: "For a Redguard, Dagon is an enemy in the deep Yokudan sense -- the destroyer of roads, cities, and the civilization the Ra Gada crossed the sea to build. This is not foreign devotion; it is betrayal of the crossing itself. Rupture is severe and total; return is hard and public." |
| PDV_Msg_Daedric_Dagon_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Orc cell | One-time on an Orc committing | Title: "Ruin Against Provision" Body: "An Orc can see the use in destruction -- Malacath's code includes the right to fight back. But destruction for its own sake is not provision; the stronghold that only tears down cannot feed or defend. Dagon's ruin offers no return, and Orc life requires one. Renounce directly." |
| PDV_Msg_Daedric_Dagon_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Mehrunes Dagon" Argonian cell | One-time on an Argonian committing | Title: "Ruin Is Not Sithis" Body: "To an Argonian, Dagon is foreign -- collapse does not make him Sithis-adjacent; the Hist distinguishes between void that renews and ruin that simply ends. His destruction has no Hist root and no community purpose. The path is abandoned, not renounced with ceremony." |

---

### 7.8 Sheogorath

Source: the `Sheogorath` row of the matrix -- PathType `Madness-disruption-instability`, CommitmentSignal `Mind of Madness, Wabbajack commitment, repeated unstable-bargain choices`, Boon `Fascination with absurdity, instability, and warped outcomes`, Price `Unpredictability and loss of stable control`, Hook `The Mind of Madness > Wabbajack > instability choices`. Matrix note: keep distinct from Sanguine (indulgence) and Rajhin-style trickster energy; Khajiit cell acknowledges Sheggorath's place in the lunar lattice as dark-pressure, not devotion. No native-integration exception; slot IDs use `Sheo` token. **EditorID note:** Extended suffixes (e.g. `_Stigma_Suspected`, `_Response_*`) will exceed 32 chars; flagged for Phase 19 abbreviation review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Sheogorath (Daedric path) | Theatrical, manic, brilliantly unstable; the Madgod lurches between the genuinely insightful and the completely unhinged; his voice is the disruption that arrives smiling, distinct from Sanguine's temptation and Rajhin's cunning -- Sheogorath is not pleasure or cleverness, he is unmooring, and his register reflects that the ground is always about to shift. |

**Boon descriptions** (`PDV_Bless_Daedric_Sheo_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Sheo_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" Boon | Passive SPEL; pact engaged | Sheogorath's absurdity opens a crack. Where the direct approach fails, something sideways succeeds; solutions arrive from the wrong angle. |
| PDV_Bless_Daedric_Sheo_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" Boon | Passive SPEL | Sheogorath's disruption deepens. Chaotic outcomes bend your way; the problem that should not break breaks, the wall that should hold falls. |
| PDV_Bless_Daedric_Sheo_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" Boon | Passive SPEL | Sheogorath names you the Madgod's own. Unpredictability is your ally; the stable is always about to become otherwise. |

**Price descriptions** (`PDV_Price_Daedric_Sheo_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Sheo_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the madness path: unpredictability cuts both ways. The disruption does not promise to hit only the targets you choose. |
| PDV_Price_Daedric_Sheo_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: control erodes. The Madgod's touch does not stop at useful chaos; the devotee's own certainties grow unreliable. |
| PDV_Price_Daedric_Sheo_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sheogorath" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: you cannot put it down. Sheogorath does not give back stability; the one who carries his full mark has become the disruption they chose, and it moves with them now. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sheo_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Sheogorath marks you a Seeker. How delightful. |
| PDV_Notif_Daedric_Sheo_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Sheogorath's madness deepens in you. Devoted. |
| PDV_Notif_Daedric_Sheo_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Sheogorath grows bored. The chaotic edge fades. |
| PDV_Msg_Daedric_Sheo_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Sheogorath"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "The Madgod's Own" Body: "Champion! Oh, how I love that word. You have broken three things that were perfectly good and intact, and you did it in the most interesting ways possible. Do you know what that tells me? Nothing at all! Which is exactly right. The disruption is yours. Do not drop it; it bites." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Sheo_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Sheogorath" CommitmentSignal | Fires once when the commitment gate clears | Title: "Sheogorath's Touch" Body: "Three times you let the chaos choose instead of your plan, and three times it chose better than you would have. I love it when mortals discover that. The commitment is recorded in the Book of Instability, which I made up just now. It is quite real. Welcome." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sheo_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Sheogorath's touch on you is suspected. The odd outcomes draw notice. |
| PDV_Notif_Daedric_Sheo_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Sheogorath devotion is known. The Madgod's follower is thought unstable. |
| PDV_Notif_Daedric_Sheo_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Sheogorath's. Settled people step away from the Madgod's marked. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sheo_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You choose the predictable. Sheogorath grows bored; the disruption edge fades. |
| PDV_Msg_Daedric_Sheo_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Sheogorath's Indifference" Body: "You are leaving? That is fine. I have other toys. The chaos drains out of you -- slowly, in the way that cheese drains. The disruption that was yours goes looking for someone more interesting. You will find stability eventually. Good luck with that." |

**Per-race responses** (`PDV_Msg_Daedric_Sheo_Response_*`). Narrator, 500/280. All ten races; Sheggorath's dark-pressure position in the Khajiit lunar lattice is acknowledged but explicitly distinguished from devotion.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Sheo_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Nord cell | One-time on a Nord committing | Title: "Against Oath Stability" Body: "For a Nord, Sheogorath strains the kin-bonds and oath-stability that Nord life rests on. A mead-hall where the patron is unpredictable does not hold together. The path is corrosive; leaving means direct abandonment or enduring the residue." |
| PDV_Msg_Daedric_Sheo_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Imperial cell | One-time on an Imperial committing | Title: "Anti-Civic Instability" Body: "For an Imperial, Sheogorath is anti-civic by definition -- public order is the foundation of Imperial civilization, and the Madgod is its enemy. The chaos runs against the rule of law as readily as against any enemy. Setting it down is straightforward abandonment." |
| PDV_Msg_Daedric_Sheo_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Breton cell | One-time on a Breton committing | Title: "Corrosive in the Margins" Body: "A Breton can read Sheogorath at the surface -- the occult margins have room for the strange. But the madness is socially corrosive even when kept private. Cover works at low commitment; renunciation is the cleaner path once it escalates." |
| PDV_Msg_Daedric_Sheo_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Dunmer cell | One-time on a Dunmer committing | Title: "House of Troubles Pressure" Body: "For a Dunmer, Sheogorath sits in the House of Troubles context -- the Dunmer know his pressure. But that context is about resistance, not devotion; embracing him is failing the test. Hard rededication runs through the Reclamation proper." |
| PDV_Msg_Daedric_Sheo_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Altmer cell | One-time on an Altmer committing | Title: "Opposed to Disciplined Apotheosis" Body: "For an Altmer, Sheogorath's unstable reality-play violates Apotheosis -- disciplined refinement and Aldmeri purity require stability. Madness is not a detour on the upward path; it is the opposite terminus. Absolution is difficult and requires active re-anchoring." |
| PDV_Msg_Daedric_Sheo_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Khajiit cell; Notes "Sheggorath is dark-pressure, not normal lunar lane" | One-time on a Khajiit committing | Title: "Sheggorath's Dark Lane" Body: "A Khajiit knows Sheogorath as Sheggorath in the lattice -- a dark-pressure the lunar calendar acknowledges. But acknowledgment is not devotion; he is the dark lane, held at the edge. Taking him as patron destabilizes the substrate; abandonment is the way back." |
| PDV_Msg_Daedric_Sheo_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Bosmer cell | One-time on a Bosmer committing | Title: "Not the Trickster Lane" Body: "A Bosmer can feel the surface trickster energy, but Sheogorath is not Baan Dar -- the madness is not cunning, and the disruption is not the Green Pact's wild note. The path is corrosive and not Bosmer backbone; abandonment is the clean exit." |
| PDV_Msg_Daedric_Sheo_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Redguard cell | One-time on a Redguard committing | Title: "Against Honor and Duty" Body: "For a Redguard, Sheogorath strains honor and duty -- the Yokudan frame values the disciplined warrior and the kept oath. Madness corrodes both. The path eats what Redguard civic life rests on; renunciation is direct." |
| PDV_Msg_Daedric_Sheo_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Orc cell | One-time on an Orc committing | Title: "Mockery of the Code" Body: "For an Orc, Sheogorath's chaotic mockery strains the code directly -- the code is plain, spoken, and kept, and the Madgod's disruption is none of those things. An exile who laughs at the code is not keeping it. Renunciation is direct; demonstrate the code in some visible form." |
| PDV_Msg_Daedric_Sheo_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sheogorath" Argonian cell | One-time on an Argonian committing | Title: "Change Is Not Madness" Body: "To an Argonian, Sheogorath is foreign -- the Hist knows change and void, but renewing void is not madness that unmoors. His instability has no Hist root and no community purpose. The path is abandoned, not renounced with ceremony." |

---

### 7.9 Clavicus Vile

Source: the `Clavicus Vile` row of the matrix -- PathType `Bargain-wish-contract`, CommitmentSignal `Daedra's Best Friend, Masque/Rueful Axe choice, explicit wish-at-cost bargain`, Boon `Deal-seeking, shortcut desire, contract hunger, loophole curiosity`, Price `Bargain backlash and exploitative terms`, Hook `A Daedra's Best Friend > Masque/Rueful Axe > deal logic`. Matrix note: different from Sanguine (indulgence) and Nocturnal (shadow oath) despite overlap in temptation. No native-integration exception; slot IDs use `Vile` token. **EditorID note:** Extended suffixes will exceed 32 chars; flagged for Phase 19 abbreviation review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Clavicus Vile (Daedric path) | Cheerful, contractual, deliberately vague on the terms; the god of deals and wishes who speaks with the satisfied pleasantness of someone who has already gotten the better end; his register is friendly and almost helpful -- the trap is always in the fine print, and he never points it out; distinct from Nocturnal's oath-debt and Sanguine's indulgence: Vile offers what you want, and the cost is the thing you forgot to read. |

**Boon descriptions** (`PDV_Bless_Daedric_Vile_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Vile_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" Boon | Passive SPEL; pact engaged | Vile's transactional edge is yours. Favorable terms come a little more often; the deal that should fall through somehow does not. |
| PDV_Bless_Daedric_Vile_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" Boon | Passive SPEL | Vile's contract deepens. Favorable turns come more reliably; the bargain you should not win goes your way. |
| PDV_Bless_Daedric_Vile_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" Boon | Passive SPEL | Vile names you his preferred client. Favorable terms become your default; loopholes open before you, and the deals bend your direction. |

**Price descriptions** (`PDV_Price_Daedric_Vile_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Vile_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the bargain: Vile's terms have fine print. What you get is real; what it costs is also real, and the invoice arrives later. |
| PDV_Price_Daedric_Vile_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: exploitative terms. Vile's contracts tighten; the backlash when a deal turns arrives harder than it should. |
| PDV_Price_Daedric_Vile_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Clavicus Vile" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: you are the preferred client, which means Vile takes interest in what you do with the terms. The favors are real. The dependencies they create are also real. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vile_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Vile acknowledges you as a Seeker. The terms look good. |
| PDV_Notif_Daedric_Vile_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Vile's contract deepens its hold. Devoted. |
| PDV_Notif_Daedric_Vile_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Vile's interest cools. The favorable terms withdraw. |
| PDV_Msg_Daedric_Vile_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Clavicus Vile"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Vile's Preferred Client" Body: "You have done this three times -- asked for something, accepted the terms, and not complained about the fine print afterward. That is rare. Most patrons I prefer have the good sense not to re-read what they agreed to. You are my preferred client. Enjoy the terms. They are very good." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Vile_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Clavicus Vile" CommitmentSignal | Fires once when the commitment gate clears | Title: "Vile's Contract" Body: "Three times you made the deal and paid the price without disputing the terms. Most mortals try to renegotiate at least once. The commitment is registered: preferred client access, and the most interesting obligations that come with it. Read them carefully." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vile_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Vile's dealings in you are suspected. Favorable outcomes draw notice. |
| PDV_Notif_Daedric_Vile_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your deal with Vile is known. His clients share the contract's reputation. |
| PDV_Notif_Daedric_Vile_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Vile's client. People know what his preferred terms cost. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vile_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You stop making deals. Vile's favor cools; the obligations remain. |
| PDV_Msg_Daedric_Vile_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Vile's Discard" Body: "You are ending the contract? That is your right -- the terms allowed for it. The favorable edge withdraws, and the outstanding obligations resolve themselves, usually in ways that feel slightly worse than you would prefer. Vile finds the whole thing amusing. He always does." |

**Per-race responses** (`PDV_Msg_Daedric_Vile_Response_*`). Narrator, 500/280. All ten races. Breton is Legible; Dunmer/Khajiit/Bosmer/Redguard/Orc/Argonian are Foreign; Nord/Imperial/Altmer are Taboo.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Vile_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Nord cell | One-time on a Nord committing | Title: "Shortcuts Dishonor the Deed" Body: "For a Nord, Vile's shortcuts dishonor the deed -- the thing earned through honest struggle is the thing that counts. A deal that delivers the outcome without the work is a lie about who did it. The path corrodes Nord honor; leaving asks sincere cleansing and recommitment." |
| PDV_Msg_Daedric_Vile_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Imperial cell | One-time on an Imperial committing | Title: "Against Civic Virtue" Body: "For an Imperial, Vile's exploitative contracts strain the civic virtue that holds the Empire together -- a deal that deceives the other party is anti-law by design. The Divines favor the honest contract; Vile profits on the dishonest one. Setting it down is abandonment." |
| PDV_Msg_Daedric_Vile_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Breton cell | One-time on a Breton committing | Title: "Contract Magic, Careful Terms" Body: "A Breton reads Vile immediately -- contract-magic and the hedge bargain are part of the Breton inheritance. The risk is exposure: a Breton can keep the contract covered, but renunciation is the cleaner option once it grows." |
| PDV_Msg_Daedric_Vile_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Dunmer cell | One-time on a Dunmer committing | Title: "Exile Temptation, Not Core" Body: "A Dunmer in exile may be tempted by Vile's deals -- the power of a contract when you have nothing is real. But Vile is not the Reclamations, and bargain-logic does not replace House duty or ancestor-debt. The path is foreign; abandonment is direct." |
| PDV_Msg_Daedric_Vile_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Altmer cell | One-time on an Altmer committing | Title: "Deal-With-Power Is Apostasy" Body: "For an Altmer, Vile's deal-with-power violates Aldmeri orthodoxy -- the Altmer project is Apotheosis through disciplined refinement, not a contract with an opportunistic Daedra. Absolution is difficult and requires dismantling the contract's remaining terms." |
| PDV_Msg_Daedric_Vile_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Khajiit cell | One-time on a Khajiit committing | Title: "Not Rajhin's Cunning" Body: "A Khajiit may see the trickster shape in Vile -- the loophole found, the deal well made. But Vile is not Rajhin; the contract is not road-wisdom, and following Vile does not honor the clever ancestor. The overlap is surface-level; the path is foreign. Abandonment is direct." |
| PDV_Msg_Daedric_Vile_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Bosmer cell | One-time on a Bosmer committing | Title: "Bargain Cunning, No Root" Body: "A Bosmer has no deep conflict with deal-making -- Baan Dar respects cunning. But Vile is not Baan Dar, and deal-cunning for Vile's sake is not the native trickster lane. The path has no root; it is set down when it runs its course." |
| PDV_Msg_Daedric_Vile_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Redguard cell | One-time on a Redguard committing | Title: "Contracts Without Honor" Body: "For a Redguard, contracts matter -- the Yokudan world was built on agreements that held. But Vile corrupts the contract; his terms exploit, and a deal-maker who profits on ignorance is a covenant-breaker. Renunciation requires restoring the terms of any deal Vile arranged." |
| PDV_Msg_Daedric_Vile_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Orc cell | One-time on an Orc committing | Title: "Against the Plain Oath" Body: "An Orc in exile may be drawn to Vile's bargains -- the favorable deal is tempting. But Malacath's code is the plain oath, not the fine-print contract. Vile's terms strain the code because they produce uneven results; renounce through consequence." |
| PDV_Msg_Daedric_Vile_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Clavicus Vile" Argonian cell | One-time on an Argonian committing | Title: "Tempting in Exile, Not Hist" Body: "To an Argonian, Vile is foreign -- tempting in exile, but the Hist does not bargain with power; it breathes together. Vile's contract is no substitute for the substrate. The path is abandoned; the Hist does not hold the absence against the one who returns." |

---

### 7.10 Vaermina

Source: the `Vaermina` row of the matrix -- PathType `Dream-nightmare-memory`, CommitmentSignal `Waking Nightmare, Skull of Corruption, nightmare manipulation threshold`, Boon `Nightmare fascination, memory violation curiosity, fear-use temptation`, Price `Sleep corruption and memory/fear instability`, Hook `Waking Nightmare > Skull of Corruption > nightmare/sleep corruption`. Matrix note: should stay tightly quest-anchored for first release. No native-integration exception. **EditorID note:** Slot IDs use `Vaermina` token; boon/price/msg IDs exceed 32 chars; flagged for Phase 19 abbreviation review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Vaermina (Daedric path) | Quiet, invasive, certain; the god of the dream that knows you better than you do; she does not threaten, she reveals what is already there; her register is the nightmare's particular certainty -- slow, low, unhurried, already inside; she does not need to be loud because she is already in the sleep. |

**Boon descriptions** (`PDV_Bless_Daedric_Vaermina_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Vaermina_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" Boon | Passive SPEL; pact engaged | Vaermina's touch opens the dream-path. Sleep reveals more than it hides; you read fear in others before they know you are reading it. |
| PDV_Bless_Daedric_Vaermina_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" Boon | Passive SPEL | Vaermina's nightmare deepens. Dream insight comes readily; the fear of others is legible, and you press it where it matters. |
| PDV_Bless_Daedric_Vaermina_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" Boon | Passive SPEL | Vaermina names you her nightmare-walker. Sleep is your domain; you read fear with precision, and what haunts others gives you advantage. |

**Price descriptions** (`PDV_Price_Daedric_Vaermina_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Vaermina_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the dream-path: sleep corrupts. Vaermina does not only give you the dream; she leaves herself in it when you sleep. |
| PDV_Price_Daedric_Vaermina_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: memory instability. Time in Vaermina's nightmare blurs the boundary between what happened and what was shown. |
| PDV_Price_Daedric_Vaermina_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Vaermina" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: fear and memory are hers. You wield fear outward, but Vaermina's access to yours is absolute; nothing you dream is private. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vaermina_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Vaermina marks you a Seeker of the dream-path. |
| PDV_Notif_Daedric_Vaermina_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Vaermina's nightmare takes a deeper hold. Devoted. |
| PDV_Notif_Daedric_Vaermina_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Vaermina's presence recedes. The dream-path grows dark. |
| PDV_Msg_Daedric_Vaermina_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Vaermina"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Vaermina's Nightmare-Walker" Body: "You walked into the nightmare and did not wake from it. That is what Champion means in my keeping. I know your fears -- all of them, named and unnamed. Use that knowledge. It cuts better than anything you carry. I have made certain it also cuts both ways." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Vaermina_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Vaermina" CommitmentSignal | Fires once when the commitment gate clears | Title: "Vaermina's Opening" Body: "Three times you used the nightmare as a tool rather than fleeing from it. That is the gate. Vaermina does not offer comfort; she offers access. The dream-path is open -- the fear-leverage, the memory of things not meant to be legible. The price is that she reads the same in you." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vaermina_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Vaermina's mark is suspected. You know too much about others' fears. |
| PDV_Notif_Daedric_Vaermina_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Vaermina devotion is known. People fear the nightmare-walker. |
| PDV_Notif_Daedric_Vaermina_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Vaermina's nightmare-walker. No settled place trusts you. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Vaermina_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You leave the dream-path. Vaermina fades; the fear-leverage withdraws. |
| PDV_Msg_Daedric_Vaermina_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Vaermina's Withdrawal" Body: "You step back from the nightmare. Vaermina does not argue; she simply closes the path. The dream-insight goes dark, the fear-leverage withdraws, and what you knew about others' nightmares fades with the access that gave it to you. Vaermina keeps what she learned about yours." |

**Per-race responses** (`PDV_Msg_Daedric_Vaermina_Response_*`). Narrator, 500/280. All ten races; three Taboo (Nord, Imperial, Altmer), one Breton Foreign-but-legible at margins, six purely Foreign.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Vaermina_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Nord cell | One-time on a Nord committing | Title: "Against Hearth Safety" Body: "For a Nord, Vaermina's nightmare cult strains hearth safety and kin-trust. The one who sleeps beside you should not be a nightmarer. The dream that reveals what you most fear has no place in the honest hall. Leaving asks cleansing and sincere recommitment." |
| PDV_Msg_Daedric_Vaermina_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Imperial cell | One-time on an Imperial committing | Title: "Against Civic Memory" Body: "For an Imperial, memory violation opposes civic order and mercy -- a society of records trusts them unaltered. Vaermina corrodes that trust; her path undoes the archival virtue the Empire rests on. Leaving is abandonment and recommitment to the civic devotional frame." |
| PDV_Msg_Daedric_Vaermina_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Breton cell | One-time on a Breton committing | Title: "Not Core, Despite the Shape" Body: "A Breton can read Vaermina's dream-path at the margins -- the nightmare has a shape in Breton tradition. But this is not a core Breton lane; the sleep corruption and memory violation sit outside the craft's actual lines. Cover is possible; renunciation is cleaner." |
| PDV_Msg_Daedric_Vaermina_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Dunmer cell | One-time on a Dunmer committing | Title: "Outside the Fear-Lanes" Body: "For a Dunmer, Vaermina's nightmare is an outsider pressure -- the fear-path and the memory violation do not connect to ancestor-duty, Good Daedra theology, or the Reclamations. The path is foreign; it is set down by abandonment with no particular ceremony required." |
| PDV_Msg_Daedric_Vaermina_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Altmer cell | One-time on an Altmer committing | Title: "Corruption of Self-Cultivation" Body: "For an Altmer, Vaermina's nightmare corruption violates disciplined self-cultivation -- the upward path requires a clear mind, and the nightmare that rewrites memory is its enemy. Absolution is difficult and requires active doctrinal re-anchoring." |
| PDV_Msg_Daedric_Vaermina_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Khajiit cell | One-time on a Khajiit committing | Title: "Dream Pressure, Not a Lane" Body: "A Khajiit may encounter Vaermina through dream pressure -- the lattice acknowledges dream-paths. But dream pressure is not devotion, and Vaermina is not a lunar lane. The path is foreign and is set down by abandonment." |
| PDV_Msg_Daedric_Vaermina_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Bosmer cell | One-time on a Bosmer committing | Title: "Sleep Fear, No Green Root" Body: "For a Bosmer, Vaermina's sleep-fear corruption has no root in the Green Pact. The nightmare is not the forest; it is an outsider thing beside the path. The path is set down by abandonment when its course is done." |
| PDV_Msg_Daedric_Vaermina_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Redguard cell | One-time on a Redguard committing | Title: "Against Communal Duty" Body: "For a Redguard, Vaermina strains communal duty -- the Yokudan frame values the clear head and the kept record. The nightmare that corrupts memory is the enemy of the trusted deed. The path is foreign; abandonment and recommitment to the clean record is the exit." |
| PDV_Msg_Daedric_Vaermina_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Orc cell | One-time on an Orc committing | Title: "Against Endurance" Body: "For an Orc, Vaermina's nightmare corruption strains the endurance ethic -- endurance requires knowing what you endure, and the nightmare that rewrites what you know is its opposite. The path is foreign; it is abandoned when its course is done." |
| PDV_Msg_Daedric_Vaermina_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Vaermina" Argonian cell | One-time on an Argonian committing | Title: "Exile Dreams, Outsider Rot" Body: "To an Argonian, Vaermina is foreign -- dreams matter in exile, but Vaermina is not the Hist's dream-channel; she is outsider corruption moving through sleep. The path is set down by abandonment; the Hist does not hold the absence against the one who returns." |

---

### 7.11 Sanguine

Source: the `Sanguine / Sangiin` row of the matrix -- PathType `Excess-temptation-indulgence`, CommitmentSignal `A Night to Remember, Sanguine Rose, explicit excess/temptation threshold`, Boon `Pleasure-seeking, revelry, lax restraint, deliberate indulgence`, Price `Overindulgence, unreliability, and restraint loss`, Hook `A Night to Remember > Sanguine Rose > excess contexts`. Matrix notes: must not become generic 'go to tavern, gain devotion' -- commitment requires genuine excess threshold; Sangiin is a dark-pressure reading inside Khajiit mythic field, not core path; distinct from Nocturnal (shadow-oath) and Clavicus Vile (contract). **EditorID note:** Slot IDs use `Sanguine` token; extended IDs exceed 32 chars; flagged for Phase 19 review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Sanguine (Daedric path) | Warm, charming, genuinely pleased; the god of indulgence and excess who never mentions the cost; his register is the invitation that sounds reasonable right up until three days in when you cannot remember your name -- not malicious, simply indulgent, and content to watch the evening keep going; distinct from Nocturnal's oath-debt and Vile's contract: Sanguine's path is a mood, not a deal. |

**Boon descriptions** (`PDV_Bless_Daedric_Sanguine_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Sanguine_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" Boon | Passive SPEL; pact engaged | Sanguine's ease settles in you. Revelry lands lighter; you navigate excess with more grace than before. |
| PDV_Bless_Daedric_Sanguine_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" Boon | Passive SPEL | Sanguine's indulgence deepens. You endure revelry where others wilt; temptation has a familiar, comfortable face. |
| PDV_Bless_Daedric_Sanguine_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" Boon | Passive SPEL | Sanguine names you his own. Excess is your element; the revelry that should end simply continues. |

**Price descriptions** (`PDV_Price_Daedric_Sanguine_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Sanguine_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the indulgence path: overindulgence. Sanguine does not enforce the limit, and without the limit the morning arrives harder. |
| PDV_Price_Daedric_Sanguine_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: unreliability. The devotee's word runs alongside the evening's plans; sober commitments dissolve. |
| PDV_Price_Daedric_Sanguine_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Sanguine" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: restraint is gone. Sanguine does not ask for it back; indulgence is always the more pressing call now. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sanguine_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Sanguine marks you a Seeker. The first round is on him. |
| PDV_Notif_Daedric_Sanguine_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Sanguine's indulgence takes a deeper hold. Devoted. |
| PDV_Notif_Daedric_Sanguine_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Sanguine's ease withdraws. The revelry grows ordinary. |
| PDV_Msg_Daedric_Sanguine_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Sanguine"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Sanguine's Own" Body: "Well done. You have arrived at the end of the road that begins with one more. I am delighted. The ease is yours permanently -- the revelry, the comfort, the wonderful inability to stop when the evening is still young. That is the gift. You already know what it costs. Welcome." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Sanguine_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Sanguine" CommitmentSignal | Fires once when the commitment gate clears | Title: "Sanguine's Invitation" Body: "Three times the evening ran past what it should have, and three times you let it. That is the signal I read. This is not an oath -- I do not do those -- and it is not a bargain. It is simply a recognition that you are the sort of person the night finds. Enjoy that." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sanguine_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Sanguine's ease on you is suspected. Some note the morning arrivals. |
| PDV_Notif_Daedric_Sanguine_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Sanguine devotion is known. The indulgence path has a visible residue. |
| PDV_Notif_Daedric_Sanguine_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Sanguine's. The restrained give you a wide berth. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Sanguine_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You return to restraint. Sanguine's ease lifts; the indulgence edge fades. |
| PDV_Msg_Daedric_Sanguine_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Sanguine's Shrug" Body: "You are walking away from it. Sanguine does not mind; he finds that charming in its own way. The ease lifts, the revelry loses its warmth, and the temptation that felt comfortable goes back to feeling like what it is. That is fine. The door is not locked." |

**Per-race responses** (`PDV_Msg_Daedric_Sanguine_Response_*`). Narrator, 500/280. All ten races; Khajiit Legible via Sangiin dark-pressure; Breton Foreign-but-intelligible; Nord/Imperial/Altmer Taboo; others Foreign.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Sanguine_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Nord cell | One-time on a Nord committing | Title: "Against Discipline and Honor" Body: "For a Nord, Sanguine's indulgence strains the discipline and honor that underpin Nord life -- the warrior who cannot refuse excess is not the warrior who holds the line. The path is a quiet erosion; leaving means accepting whatever residue the indulgence left." |
| PDV_Msg_Daedric_Sanguine_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Imperial cell | One-time on an Imperial committing | Title: "Anti-Civic Devotion" Body: "For an Imperial, indulgence is tolerated in pieces -- the tavern exists and the law acknowledges it. But as devotion, Sanguine's path is anti-civic; it erodes the self-discipline that public service and honest commerce require. Renunciation is recommitment to the civic frame." |
| PDV_Msg_Daedric_Sanguine_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Breton cell | One-time on a Breton committing | Title: "Intelligible, Not Core" Body: "A Breton can read Sanguine -- revelry and mixed-company ease are part of the Breton social world. But Sanguine is not a core Breton tradition; the intelligibility is social, not theological. Cover works at low commitment; renunciation is cleaner once the path takes hold." |
| PDV_Msg_Daedric_Sanguine_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Dunmer cell | One-time on a Dunmer committing | Title: "Outsider Indulgence" Body: "For a Dunmer, Sanguine's indulgence is an outsider temptation -- it does not connect to ancestor-duty or the Reclamations. The ease is real, but it has no root in the Dunmer spiritual center. The path is set down by abandonment; no special ceremony is needed." |
| PDV_Msg_Daedric_Sanguine_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Altmer cell | One-time on an Altmer committing | Title: "Against Disciplined Apotheosis" Body: "For an Altmer, Sanguine's indulgence is the opposite of Apotheosis -- the upward path requires discipline, and permanent restraint-loss is not a detour, it is a retreat. Absolution is difficult and requires re-anchoring to the Aldmeri project." |
| PDV_Msg_Daedric_Sanguine_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Khajiit cell; Notes "Sangiin is dark-pressure, not core path" | One-time on a Khajiit committing | Title: "Sangiin's Dark Lane" Body: "A Khajiit finds Sanguine legible through Sangiin, a dark-pressure in the Khajiiti lattice. But Sangiin is acknowledged, not honored. Taking Sanguine as patron crosses from familiarity into an outside pull. Withdrawal or cleansing keeps the substrate intact." |
| PDV_Msg_Daedric_Sanguine_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Bosmer cell | One-time on a Bosmer committing | Title: "Revelry Without a Root" Body: "A Bosmer lives in a world that has Baan Dar's cunning and Y'ffre's continuity -- there is room for revelry, but the patron is not Sanguine. The indulgence path has no root in the covenant or the trickster tradition. The path is set down by abandonment when it runs its course." |
| PDV_Msg_Daedric_Sanguine_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Redguard cell | One-time on a Redguard committing | Title: "Indulgence Without Honor" Body: "For a Redguard, indulgence as devotion is foreign -- the Yokudan frame values the disciplined warrior and the kept oath, neither of which is served by Sanguine's ease. The path does not belong to Redguard backbone theology; abandonment is direct." |
| PDV_Msg_Daedric_Sanguine_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Orc cell | One-time on an Orc committing | Title: "Not Malacath's Revelry" Body: "For an Orc, Sanguine's revelry has no place in Malacath's code -- the code is endurance, not ease. Revelry under humiliation is not the code's way; devotion to indulgence is foreign to the stronghold ethic. The path is abandoned when it runs its course." |
| PDV_Msg_Daedric_Sanguine_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Sanguine" Argonian cell | One-time on an Argonian committing | Title: "Not a Hist Lane" Body: "To an Argonian, Sanguine is foreign -- indulgence is not the Hist's frame, and the community does not breathe that way. The ease the path offers is real but rootless. The path drifts away; the Hist does not hold the drift against the one who returns." |

---

### 7.12 Namira

Source: the `Namira / Namiira` row of the matrix -- PathType `Revulsion-decay-outcast-hunger`, CommitmentSignal `Taste of Death, Ring of Namira, corpse-taboo acceptance, chosen outcast solidarity`, Boon `Attraction to darkness, taboo, outcast fellowship, hunger`, Price `Social revulsion and consumption taboo`, Hook `The Taste of Death > Ring of Namira > corpse-taboo acts`. Matrix note: Khajiit legibility (Namiira dark-pressure) should remain dark-pressure framing, not baseline devotion. Breton and Khajiit are Legible; Bosmer and Redguard are Taboo. No native-integration exception.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Namira (Daedric path) | Quiet, low, strangely welcoming; the god who calls from the darkest outcast corners -- she is the hunger the respectable pretend does not exist, the fellowship of the cast-out; her register is not threatening, it is recognizing; she speaks to the ones who have nothing left to lose, not against the ones who turned them away. |

**Boon descriptions** (`PDV_Bless_Daedric_Namira_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Namira_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" Boon | Passive SPEL; pact engaged | Namira's darkness settles around you. Revulsion that breaks others steels you; you endure the forgotten places without flinching. |
| PDV_Bless_Daedric_Namira_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" Boon | Passive SPEL | Namira's outcast fellowship deepens. The resilience of one who has nothing to lose is yours; the places that repel others are your domain. |
| PDV_Bless_Daedric_Namira_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" Boon | Passive SPEL | Namira names you of the outcast faithful. You are the hunger the respectable pretend does not exist; what they revile sustains you. |

**Price descriptions** (`PDV_Price_Daedric_Namira_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Namira_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the outcast path: social revulsion. Those who accept Namira's follower are few, and they are not the respectable. |
| PDV_Price_Daedric_Namira_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: consumption taboo. The hunger Namira feeds takes a shape others find unacceptable, and hiding it grows harder. |
| PDV_Price_Daedric_Namira_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Namira" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: revulsion is your medium. The respectable do not welcome Namira's Champion, and she does not ask them to. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Namira_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Namira marks you a Seeker of the outcast path. |
| PDV_Notif_Daedric_Namira_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Namira's darkness takes a deeper hold. Devoted. |
| PDV_Notif_Daedric_Namira_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Namira's fellowship withdraws. The outcast resilience fades. |
| PDV_Msg_Daedric_Namira_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Namira"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Namira's Outcast Faithful" Body: "The respectable have their clean altars. You found your way here instead, and three times you chose the path that brought you lower in their eyes and deeper in mine. That is enough. The hunger is real. The fellowship is real. The revulsion is their problem." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Namira_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Namira" CommitmentSignal | Fires once when the commitment gate clears | Title: "Namira's Welcome" Body: "Three times you sat with the taboo and did not flinch from it. That is the gate. Namira does not call the clean; she calls those the clean have turned away. If you are here, you already understand the welcome that waits in the dark places." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Namira_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Namira's mark is suspected. People read the filth-path in your traces. |
| PDV_Notif_Daedric_Namira_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Namira devotion is known. The outcast-path marks its follower openly. |
| PDV_Notif_Daedric_Namira_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Namira's. The respectable give the outcast-faithful a wide berth. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Namira_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You step away from the outcast path. Namira's fellowship dims; the hunger fades. |
| PDV_Msg_Daedric_Namira_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Namira's Release" Body: "You leave the outcast path. Namira does not argue; she has more than enough of the cast-out. The hunger fades, the outcast resilience lifts, and the revulsion you carried becomes ordinary repulsion again -- manageable, human, the kind that does not sustain you." |

**Per-race responses** (`PDV_Msg_Daedric_Namira_Response_*`). Narrator, 500/280. All ten races; Breton Legible (outcast witchcraft heritage); Khajiit Legible via Namiira dark-pressure; Bosmer and Redguard Taboo; others Taboo (Nord, Imperial, Altmer) or Foreign (Dunmer, Orc, Argonian).

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Namira_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Nord cell | One-time on a Nord committing | Title: "Against Hearth and Honor" Body: "For a Nord, Namira's corpse-and-filth cult is a direct attack on the hearth -- the home is where you honor the dead and protect the living, and the outcast-hungry path corrupts both. Leaving asks sincere cleansing and direct renunciation; the rupture leaves a mark." |
| PDV_Msg_Daedric_Namira_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Imperial cell | One-time on an Imperial committing | Title: "Civic and Religious Rupture" Body: "For an Imperial, Namira's revulsion cult is both civic and religious rupture -- the Divines ask for piety toward the living community, and the decay-path is its enemy in both registers. Cleansing or abandonment are the exits, with formal recommitment to the civic divine frame." |
| PDV_Msg_Daedric_Namira_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Breton cell | One-time on a Breton committing | Title: "Outcast Witchcraft Heritage" Body: "A Breton can read Namira -- the witchcraft and outcast heritage has always had dark corners, and Namira's fellowship is intelligible in that frame. But the danger is real, not merely social; cover or renounce as the commitment deepens." |
| PDV_Msg_Daedric_Namira_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Dunmer cell | One-time on a Dunmer committing | Title: "Outsider Corruption" Body: "For a Dunmer, Namira's decay and outcast path is outsider corruption -- it does not connect to ancestor-duty, the Reclamations, or the Good Daedra. The filth-cult has no root in the Dunmer spiritual center; the path is set down by abandonment with no particular ceremony." |
| PDV_Msg_Daedric_Namira_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Altmer cell | One-time on an Altmer committing | Title: "Impurity Against the Project" Body: "For an Altmer, Namira's impurity and degradation are the direct opposite of Apotheosis -- the upward trajectory of purity and self-refinement cannot coexist with the chosen descent into filth. Absolution is difficult and requires deliberate re-anchoring to the Aldmeri project." |
| PDV_Msg_Daedric_Namira_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Khajiit cell; Notes "Namiira is dark-pressure, not baseline devotion" | One-time on a Khajiit committing | Title: "Namiira's Dark Pressure" Body: "A Khajiit knows Namiira as dark-pressure in the Khajiiti lattice -- the hungry void kept at the edge. But dark-pressure is not devotion; Namiira is acknowledged, not honored. Taking her as patron crosses from familiarity into an outside pull. Withdrawal or cleansing returns." |
| PDV_Msg_Daedric_Namira_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Bosmer cell | One-time on a Bosmer committing | Title: "Against Continuity and Covenant" Body: "For a Bosmer, Namira's decay path opposes continuity and covenant -- the Green Pact is the contract of what lives and what the living owe each other. Decay as a devotional frame cuts against that covenant at the root. Renunciation is the only clean exit." |
| PDV_Msg_Daedric_Namira_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Redguard cell | One-time on a Redguard committing | Title: "Against Ancestor and Social Law" Body: "For a Redguard, Namira's corpse-taboo breaks ancestor law and social law both. The dead are honored, not consumed; the outcast is pitied, not made a cult. Cleansing and hard renunciation are the exits, both requiring visible recommitment to the ancestor-honoring frame." |
| PDV_Msg_Daedric_Namira_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Orc cell | One-time on an Orc committing | Title: "Filth-Cult, Not Exile Code" Body: "For an Orc, Namira's filth-cult is an outsider thing -- Malacath's code is endurance and provision, not the chosen descent into decay. The exiles Namira calls are a different kind of cast-out than the ones Malacath honors. The path is foreign; abandonment is direct." |
| PDV_Msg_Daedric_Namira_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Namira" Argonian cell | One-time on an Argonian committing | Title: "Grief Temptation, Not Hist" Body: "To an Argonian, Namira tempts the grief-states -- the outcast in exile finds recognition in her call. But the Hist is not the decay-path; community does not breathe that way. The path is set down by abandonment; the Hist does not hold the absence against the one who returns." |

---

### 7.13 Peryite

Source: the `Peryite` row of the matrix -- PathType `Plague-order-lowest-task`, CommitmentSignal `The Only Cure, Spellbreaker, disease/affliction threshold, unpleasant-duty acceptance`, Boon `Tolerance for drudgery, disease themes, low-order submission`, Price `Affliction and submission to task/order`, Hook `The Only Cure > Spellbreaker > disease/affliction contexts`. Matrix note: good example of a Prince likely kept narrow and quest-anchored. Only Altmer cell is Taboo; all others are Foreign. **EditorID note:** Slot IDs use `Peryite` token; extended IDs exceed 32 chars; flagged for Phase 19 review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Peryite (Daedric path) | Dry, dutiful, faintly officious; the god of the lowest task and the disease it comes with; speaks in assignment, not invitation -- the work must be done, and he assigns it without apology or explanation; his register is completely indifferent to whether you find the task noble, because he is not asking. |

**Boon descriptions** (`PDV_Bless_Daedric_Peryite_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Peryite_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" Boon | Passive SPEL; pact engaged | Peryite's resilience settles in you. Affliction finds you harder to bring down, and the unpleasant tasks others refuse are simply tasks. |
| PDV_Bless_Daedric_Peryite_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" Boon | Passive SPEL | Peryite's imposed order deepens. Disease weakens you less; the tasks you are assigned, however low, run efficiently. |
| PDV_Bless_Daedric_Peryite_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" Boon | Passive SPEL | Peryite names you keeper of the lowest order. Affliction barely touches you; the unwanted tasks run efficiently through your hands. |

**Price descriptions** (`PDV_Price_Daedric_Peryite_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Peryite_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the affliction path: you carry what Peryite assigns, and some assignments are diseases. |
| PDV_Price_Daedric_Peryite_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: task-order submission. Peryite assigns; the devotee's judgment yields to it, not ahead of it. |
| PDV_Price_Daedric_Peryite_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Peryite" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: you are the lowest-order mechanism. Peryite assigns; you execute; the nature of the assignment is not yours to question. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Peryite_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Peryite marks you a Seeker of the affliction order. |
| PDV_Notif_Daedric_Peryite_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Peryite's task-order deepens its hold. Devoted. |
| PDV_Notif_Daedric_Peryite_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Peryite reassigns. The affliction resilience withdraws. |
| PDV_Msg_Daedric_Peryite_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Peryite"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Peryite's Task-Keeper" Body: "You have completed three tasks no one else would take. That is the gate. I do not offer meaning; I offer efficiency. The lowest order must run, and it runs best through those who accept it without complaint. You are that now. The assignment list continues." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Peryite_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Peryite" CommitmentSignal | Fires once when the commitment gate clears | Title: "Peryite's Assignment" Body: "Three times the task was unpleasant and you did it anyway. That is not virtue; that is efficiency. The lowest order must run, and you are suited to it. The commitment is registered. The next assignment is already listed." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Peryite_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Peryite's affliction-path is suspected. The disease-keeper draws wary eyes. |
| PDV_Notif_Daedric_Peryite_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Peryite devotion is known. Disease-cult marks its follower with suspicion. |
| PDV_Notif_Daedric_Peryite_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Peryite's. The disease-keeper is not welcome in the healthy. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Peryite_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You leave the task undone. Peryite reassigns. The affliction edge fades. |
| PDV_Msg_Daedric_Peryite_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Peryite's Reassignment" Body: "You are released from the assignment. Peryite does not argue; the work will be done by someone else. The affliction resilience goes, the task-efficiency withdraws, and the diseases you carried under his order no longer stay with you on his schedule. The work continues without you." |

**Per-race responses** (`PDV_Msg_Daedric_Peryite_Response_*`). Narrator, 500/280. All ten races; Altmer is Taboo; all nine others are Foreign.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Peryite_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Nord cell | One-time on a Nord committing | Title: "Task-Order, No Hearth Fit" Body: "For a Nord, Peryite's task-order is alien -- the Nord world has duty, but it runs through kin and oath, not through submission to a disease-cult. The path can be read at the surface but has no true root. Setting it down is direct abandonment." |
| PDV_Msg_Daedric_Peryite_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Imperial cell | One-time on an Imperial committing | Title: "Low-Order Duty, Not Civic" Body: "For an Imperial, Peryite's low-order duty has a legible shape -- the Empire runs on people doing their tasks. But Peryite is not civic devotion; he is submission to affliction, and the Divines are the proper frame for Imperial duty. Abandonment is direct." |
| PDV_Msg_Daedric_Peryite_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Breton cell | One-time on a Breton committing | Title: "Unpleasant Duty, No Core" Body: "A Breton can see the unpleasant-duty reading at the margins -- there is a strand of the craftworker tradition that honors the worst tasks done well. But Peryite is not a Breton core tradition; the intelligibility is peripheral and does not root. The path is set down by abandonment." |
| PDV_Msg_Daedric_Peryite_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Dunmer cell | One-time on a Dunmer committing | Title: "Outsider Affliction Order" Body: "For a Dunmer, Peryite's affliction-order is an outsider path -- it does not connect to ancestor-duty, the Reclamations, or the House structure. Submission to disease-task is not a Dunmer devotional lane; the path is set down by abandonment with no ceremony required." |
| PDV_Msg_Daedric_Peryite_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Altmer cell | One-time on an Altmer committing | Title: "Diseased Submission Against Apotheosis" Body: "For an Altmer, Peryite's diseased submission violates Aldmeri order -- purity is the project, and voluntary affliction-association is its opposite. The path is not merely foreign; it is actively incompatible with Apotheosis. Absolution is difficult." |
| PDV_Msg_Daedric_Peryite_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Khajiit cell | One-time on a Khajiit committing | Title: "Burdens Without a Moon" Body: "A Khajiit knows burdens -- the road is long and the tasks are often thankless. But Peryite's disease-order is not a lunar lane; the lattice does not run through affliction-submission. The path is foreign, and it is set down by abandonment; the substrate does not hold the gap." |
| PDV_Msg_Daedric_Peryite_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Bosmer cell | One-time on a Bosmer committing | Title: "Disease-Order, No Green Root" Body: "For a Bosmer, Peryite's disease-order has no root in the Green Pact or the spirit world. The covenant concerns the living in relation to the living; submission to affliction-task is not Bosmer theology. The path is set down by abandonment when its course is done." |
| PDV_Msg_Daedric_Peryite_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Redguard cell | One-time on a Redguard committing | Title: "Drudgery Without Honor" Body: "For a Redguard, Peryite's drudgery and disease do not map to Yokudan devotion -- the Yokudan frame values the disciplined warrior and the meaningful task, not the low-order submission to affliction. The path is foreign and is set down by direct abandonment." |
| PDV_Msg_Daedric_Peryite_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Orc cell | One-time on an Orc committing | Title: "Harsh Duty, Wrong Master" Body: "An Orc can see the shape of harsh duty in Peryite's order -- Malacath's code has its own harsh assignments. But Peryite is not Malacath; his affliction-order is outsider submission, not the code. The path is foreign, and it is abandoned by direct renunciation." |
| PDV_Msg_Daedric_Peryite_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Peryite" Argonian cell | One-time on an Argonian committing | Title: "Affliction, No Hist Root" Body: "To an Argonian, Peryite's affliction-order is foreign -- the Hist does not route devotion through disease-task submission. The community breathes together. The path is abandoned; the Hist does not hold the absence against the one who returns." |

---

### 7.14 Hircine

Source: the `Hircine` row of the matrix -- PathType `Hunt-lycanthropy-predator`, CommitmentSignal `Ill Met by Moonlight, active lycanthropy, Companions/wild-hunt threshold`, Boon `Tracking, hunt momentum, and predator clarity`, Price `Predatory instinct and social/afterlife tension`, Hook `Ill Met by Moonlight > werewolf state > Companions`. **Curse-access Prince:** the `_Commitment` slot is reframed as a curse-onset embrace -- Hircine speaks directly when the player commits to his path while carrying lycanthropy; the gate is three Hircine-aligned signals with the wolf in play, not a general piety accumulation. Existing race CurseState rows (e.g., `PDV_Msg_Nord_CurseState_WerewolfOnset` voiced by Shor) fire at transformation onset and are additive -- different trigger, different voice. **EditorID note:** Slot IDs use `Hircine` token; all extended IDs exceed 32 chars; flagged for Phase 19 review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Hircine (Daedric path) | Primal, joyful, predatory; speaks from the hunt, not from doctrine; does not argue theology or negotiate -- he names what is already true and invites you to recognize it; warm in the way the predator is warm toward the one who hunts alongside it; no contempt for the beasts he makes. |

**Boon descriptions** (`PDV_Bless_Daedric_Hircine_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Hircine_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" Boon | Passive SPEL; pact engaged | Hircine's hunt-sense is in you. Prey announces itself; the predator reads the terrain with new clarity. |
| PDV_Bless_Daedric_Hircine_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" Boon | Passive SPEL | The hunt runs deeper now. Hircine's predator-edge extends into stamina, and the prey does not slip away. |
| PDV_Bless_Daedric_Hircine_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" Boon | Passive SPEL | You see the whole arc of the hunt -- target, approach, kill, clean territory. Hircine's Champion reads it without effort. |

**Price descriptions** (`PDV_Price_Daedric_Hircine_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Hircine_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the hunt-path: the predator register. The civilized world reads the beast in you and keeps its distance. |
| PDV_Price_Daedric_Hircine_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: the beast shapes the social register. Others read Hircine's claim and do not find it comfortable. |
| PDV_Price_Daedric_Hircine_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Hircine" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: the Huntsman's isolation. The civilian world is an afterthought to the hunt, and the hunt does not make friends. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Hircine_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Hircine marks you a Seeker of the hunt-path. |
| PDV_Notif_Daedric_Hircine_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Hircine's hunt-claim deepens. Devoted. |
| PDV_Notif_Daedric_Hircine_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Hircine's hunt withdraws. The predator-edge fades; the beast-claim loosens. |
| PDV_Msg_Daedric_Hircine_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Hircine"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Hircine's Huntsman" Body: "You have run with the wolf when you could have cured it, hunted when the prey was inconvenient, and taken three kills that satisfied no one but the beast and you. That is the standard. You are my Huntsman now. The forest is yours, and the forest asks only one thing: that you run." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Hircine_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Hircine" CommitmentSignal | Fires once when commitment gate clears; curse-access reframe: player carries lycanthropy and has signaled three times | Title: "Hircine's Claim" Body: "The wolf is in you, and you know what that means now -- not the fear that comes first, but the thing after the fear: the hunting-ground opened, the prey was visible, and the body knew before the mind. That moment is mine. Welcome, Hunter." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Hircine_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Your Hircine devotion is suspected. The beast-path draws wary eyes. |
| PDV_Notif_Daedric_Hircine_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Hircine devotion is known. The hunt-path marks its follower plainly. |
| PDV_Notif_Daedric_Hircine_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Hircine's. The beast-walker is not welcome in the settled hold. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Hircine_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | The hunt goes quiet. Hircine's predator-edge fades; the beast-claim withdraws. |
| PDV_Msg_Daedric_Hircine_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Hircine's Release" Body: "You leave the hunt-path. Hircine does not argue; the forest closes to others as easily. The predator-edge withdraws, the hunt-sense dims, and the wolf's claim over you returns to where it was before the path began -- the curse remains if you carry it, but Hircine's favor is withdrawn." |

**Per-race responses** (`PDV_Msg_Daedric_Hircine_Response_*`). Narrator, 500/280. All ten races; Altmer Hostile; Breton and Bosmer Legible; all others Curse or Foreign.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Hircine_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Nord cell | One-time on a Nord committing | Title: "Hunt Against the Bridge" Body: "For a Nord, Hircine's claim sits against Sovngarde -- the hunt-soul and the hall-soul cannot both be honored fully, and Hircine does not yield. The beast is intelligible here, through the Companions and the wild, but it strains the bridge. The path requires cure or hard renunciation to close; the scar on the bridge remains." |
| PDV_Msg_Daedric_Hircine_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Imperial cell | One-time on an Imperial committing | Title: "The Civic Override" Body: "For an Imperial, Hircine's lane opens through the werewolf state -- the normal civic rejection is overridden by the curse access, but the Divines do not recognize it as legitimate devotion. The path is a crisis for the civic-faith frame. Cure and slow rededication to the Nine rebuild what the curse disrupted." |
| PDV_Msg_Daedric_Hircine_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Breton cell | One-time on a Breton committing | Title: "Wild Hunt at the Margin" Body: "A Breton can read Hircine -- the druidic and witchcraft frames both hold wild-hunt strands, and Glenmoril is close enough to make the beast-path intelligible at the margin. The cost varies by path: the Knight's Road severs; the Hidden Art holds. The exit is a fork, a cure, or a deliberate rededication." |
| PDV_Msg_Daedric_Hircine_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Dunmer cell | One-time on a Dunmer committing | Title: "No Ash Fit" Body: "For a Dunmer, Hircine's hunt-claim is an outsider pressure -- the Reclamations do not reach it, and the ancestors do not hold a lane for the beast-god. The wolf is ritually unclean in any case; Hircine's added claim only deepens the disconnection. The path is set down by cure or direct abandonment." |
| PDV_Msg_Daedric_Hircine_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Altmer cell | One-time on an Altmer committing | Title: "Beast Regression Against Apotheosis" Body: "For an Altmer, Hircine's beast-path is the literal reversal of Apotheosis -- the whole project is upward into spirit, and becoming the beast is the descent the project was built to prevent. There is almost no positive lane available. The only clean exit is cure; the damage to the Aldmeri project is not easily repaired even after." |
| PDV_Msg_Daedric_Hircine_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Khajiit cell | One-time on a Khajiit committing | Title: "Form Against the Lattice" Body: "A Khajiit's moon-identity remains under the curse, but the beast-shape strains the Lattice -- Khajiit form is moon-given and precise, and Hircine's wolf is a competing form that the moons did not provide. The caravans will keep their distance from the beast-walker. Cure or controlled distancing are the exits; the Lattice does not disown you." |
| PDV_Msg_Daedric_Hircine_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Bosmer cell | One-time on a Bosmer committing | Title: "Wild Hunt Adjacent" Body: "For a Bosmer, Hircine reads through Wild-Hunt adjacency -- the theology can hold the beast-hunt frame at its edges, but it is not orthodox devotion and carries cost. On the Old Contract the breach is serious; on the other paths the reading is merely contested. The exit requires cure or costly re-entry into covenant standing." |
| PDV_Msg_Daedric_Hircine_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Redguard cell | One-time on a Redguard committing | Title: "Homelessness Under the Beast" Body: "For a Redguard, the wolf-curse carries no Yokudan home -- the Yokudan gods do not answer it, and no sect gives the beast-walker a frame. Hircine's claim produces only spiritual homelessness; there is no honor in it and no path from it. Cure first, then Tu'whacca's restoration rites rebuild the broken connection." |
| PDV_Msg_Daedric_Hircine_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Orc cell | One-time on an Orc committing | Title: "The Beast Tested Against the Code" Body: "For an Orc, the wolf-curse has a conditional Malacath reading -- the beast may be defensible if it is disciplined and does not break the kin. But Hircine is not Malacath, and the claim competes with the code. Proving discipline is the path that keeps the connection; the failure state is abandonment or cure." |
| PDV_Msg_Daedric_Hircine_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Hircine" Argonian cell | One-time on an Argonian committing | Title: "The Beast and the Hist" Body: "For an Argonian, Hircine's wolf-curse strains the Hist relation without breaking it entirely -- the beast-shape is a competing form the Hist did not provide, and the community feels the strain. But the Hist does not disown you; the relation is thin, not severed. Cure or careful stabilization can restore what the beast-shape pulls against." |

---

### 7.15 Molag Bal

Source: the `Molag Bal` row of the matrix -- PathType `Domination-vampirism-enslavement`, CommitmentSignal `House of Horrors, active vampirism, Volkihar / domination threshold`, Boon `Domination edge, coercive pressure, vampiric leverage`, Price `Domination corruption and spiritual violation`, Hook `The House of Horrors > vampirism > Mace of Molag Bal`. **Curse-access Prince:** the `_Commitment` slot is reframed as a vampiric embrace -- Molag Bal speaks directly when the player commits to his path while carrying vampirism; the gate is three domination/Molag-aligned signals with the thirst in play, not a general piety accumulation. Existing race CurseState rows (e.g., `PDV_Msg_Nord_CurseState_VampireOnset` voiced by Shor) fire at vampire onset and are additive -- different trigger, different voice. Matrix note: Molag Bal is mostly a curse-access lane even where not literally marked Curse. **EditorID note:** Slot IDs use `Molag` token; all extended IDs exceed 32 chars; flagged for Phase 19 review.

**Tone profile.**

| Voice | Tone profile |
|---|---|
| Molag Bal (Daedric path) | Crushing, domination-absolute; cold contempt that occasionally warms when you are useful; does not persuade -- he states; the hierarchy is its own argument; speaks to those who understand that power over others is its own purpose; no warmth toward the player themselves, only toward their utility. |

**Boon descriptions** (`PDV_Bless_Daedric_Molag_*`). Narrator, 200/140, passive SPEL.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Bless_Daedric_Molag_Seeker | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" Boon | Passive SPEL; pact engaged | Molag Bal's domination-edge settles in you. Coercive leverage comes more easily; hierarchy bends in your direction. |
| PDV_Bless_Daedric_Molag_Devoted | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" Boon | Passive SPEL | The grip deepens. Molag Bal's vampiric authority extends your reach -- the dominated stay dominated. |
| PDV_Bless_Daedric_Molag_Champion | Boon description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" Boon | Passive SPEL | You carry the full weight of Molag Bal's domination. The hierarchy bends; resistance buckles; the leverage is yours. |

**Price descriptions** (`PDV_Price_Daedric_Molag_*`). Narrator, 200/140.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Price_Daedric_Molag_Seeker | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" PrimaryPrice | Passive SPEL; paired with Seeker boon | The price of the domination-path: the cruelty it asks of you will return. Those you bend do not forget. |
| PDV_Price_Daedric_Molag_Devoted | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" PrimaryPrice | Passive SPEL; paired with Devoted boon | The price deepens: isolation of the predator. Those who sense Molag Bal's claim keep their distance or their silence. |
| PDV_Price_Daedric_Molag_Champion | Price description | Quiet | Narrator | 200/140 | DaedricMatrix "Molag Bal" PrimaryPrice | Passive SPEL; paired with Champion boon | The full price: everything mediated through dominance. Molag Bal's Champion relates to others through leverage, and leverage corrodes. |

**Tier-up notifications and Champion entry.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Molag_SeekerEntry | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Molag Bal marks you a Seeker of the domination-path. |
| PDV_Notif_Daedric_Molag_DevotedEntry | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.1 | One per save | Molag Bal's grip deepens. Devoted. |
| PDV_Notif_Daedric_Molag_Lapse | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2 | One per direction per save | Molag Bal's claim loosens. The domination-edge fades; the leverage withdraws. |
| PDV_Msg_Daedric_Molag_ChampionEntry | MessageBox | Marked | God-voice | 500/280 | DaedricMatrix "Molag Bal"; Architecture v3 Section 11 | One-time on first Champion tier | Title: "Molag Bal's Instrument" Body: "You have done it three times -- bent the will, taken the leverage, made the hierarchy work in your favor. That is the commitment. You are useful to me; in my terms, that is the closest thing to honor I extend. Use the domination well. Do not mistake it for permission to stop." |

**Commitment / pact.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Molag_Commitment | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.3; DaedricMatrix "Molag Bal" CommitmentSignal | Fires once when commitment gate clears; curse-access reframe: player carries vampirism and has signaled three times | Title: "Molag Bal's Touch" Body: "The thirst is in you, and you know what the thing under the hunger is: the hierarchy reflex, the dominance that makes sense now in a way it did not before the curse. That is mine. You chose to keep it three times when the cure was available. That is the commitment I record." |

**Stigma band crossings.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Molag_Stigma_Suspected | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Suspected | Your Molag Bal devotion is suspected. The domination-path draws wary eyes. |
| PDV_Notif_Daedric_Molag_Stigma_Known | Notification | Noted | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Known | Your Molag Bal devotion is known. Domination-cult devotion is not trusted. |
| PDV_Notif_Daedric_Molag_Stigma_Notorious | Notification | Marked | Narrator | 80/60 | Architecture v3 Section 11.2; Section 5 | On entering Notorious | You are openly Molag Bal's. The enslaver's servant is feared wherever you walk. |

**Neglect texture and exit.**

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Notif_Daedric_Molag_NeglectTexture | Notification | Noted | Player-2nd | 80/60 | Architecture v3 Section 11.2 | One per lapse-band crossing | You ease the grip. Molag Bal's domination-edge withdraws; the leverage fades. |
| PDV_Msg_Daedric_Molag_Exit | MessageBox | Marked | God-voice | 500/280 | Architecture v3 Section 11.4; Section 11.6 | Fires once on renunciation; residue persists | Title: "Molag Bal's Dismissal" Body: "You leave the domination-path. Molag Bal does not argue; there are others. The vampiric authority withdraws, the coercive leverage fades, and the hierarchy-reflex Molag Bal sharpened in you dulls back toward ordinary cruelty. The curse remains if you carry it, but his favor is withdrawn." |

**Per-race responses** (`PDV_Msg_Daedric_Molag_Response_*`). Narrator, 500/280. All ten races; Redguard Hostile; Dunmer and Orc Taboo; all others Curse.

| Slot ID | Surface | Surfacing | Voice | Budget | Source | Anti-farm / dep notes | Draft prose |
|---|---|---|---|---|---|---|---|
| PDV_Msg_Daedric_Molag_Response_Nord | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Nord cell | One-time on a Nord committing | Title: "Sovngarde Severed" Body: "For a Nord, Molag Bal's vampiric claim cuts Sovngarde off completely -- the thirst and the hall cannot coexist, and Molag Bal does not compromise. Cure first, then rededicate; even cured, the scar on the bridge is deeper than most curses leave. Tsun will mark what walked into Molag Bal's domain." |
| PDV_Msg_Daedric_Molag_Response_Imperial | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Imperial cell | One-time on an Imperial committing | Title: "The Civic Faith Collapses" Body: "For an Imperial, Molag Bal's vampiric claim collapses the civic-faith frame entirely -- the Nine Divines are a religion of the living community, and the undead do not qualify. Devotion stops. Cure first, then return; but the floor is lower than where you began, and the community remembers the absence." |
| PDV_Msg_Daedric_Molag_Response_Breton | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Breton cell | One-time on a Breton committing | Title: "Danger the Tradition Reads" Body: "A Breton can read Molag Bal -- the witchcraft tradition knows his pressure and has navigated it before, but it names the price clearly: this is not a safe lane, and the cost is severe. Cover may delay the exit; cure or renunciation are the clean ones. The tradition holds the knowledge of what Molag Bal costs." |
| PDV_Msg_Daedric_Molag_Response_Dunmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Dunmer cell | One-time on a Dunmer committing | Title: "House of Troubles Pressure" Body: "For a Dunmer, Molag Bal sits in the House of Troubles -- the Dunmer theology knows him as one who tested the Tribunal, not one who was honored. Vampirism has its own Dunmer lane, but it is not devotion; it is an alternative that replaces the ancestors. Cure first, then ancestor rededication rebuilds what the curse closed." |
| PDV_Msg_Daedric_Molag_Response_Altmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Altmer cell | One-time on an Altmer committing | Title: "Catastrophic Apostasy" Body: "For an Altmer, Molag Bal's vampiric claim is catastrophic apostasy -- the flight from daylight is the flight from Auri-El, and there is no clean recovery. Cure brings the door back open; but Aldmeri theology does not restore an Apotheosis-track cleanly after this kind of breach. The damage does not fully reverse." |
| PDV_Msg_Daedric_Molag_Response_Khajiit | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Khajiit cell | One-time on a Khajiit committing | Title: "Moon Corrupted by the Thirst" Body: "A Khajiit's moon-identity remains under the vampiric curse, but it is corrupted and thinned -- Molag Bal's thirst competes with the Lattice's light and weakens both the devotional identity and the community bond. Cure cleanses the corruption; shadow withdrawal may delay the community response while the path is carried." |
| PDV_Msg_Daedric_Molag_Response_Bosmer | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Bosmer cell | One-time on a Bosmer committing | Title: "Hard Break Across All Paths" Body: "For a Bosmer, Molag Bal's vampiric claim breaks theology across all three paths: on the Old Contract, the undead violate the Pact directly; on the Green Way, Y'ffre is the Now and you have stepped outside it; on the Hidden Art, the witch-mothers can hold it, but at severe cost. Cure is the cleanest exit; re-entry is costly on every path." |
| PDV_Msg_Daedric_Molag_Response_Redguard | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Redguard cell | One-time on a Redguard committing | Title: "Against the Far Shores" Body: "For a Redguard, Molag Bal's vampiric claim breaks the Far Shores entirely -- Tu'whacca guides souls through the proper death-cycle, and the undead have stepped outside the cycle in the most destructive way. Devotion across all sects collapses. Cure first, then return through Tu'whacca's rites before any other god. Even cured, the restoration takes time." |
| PDV_Msg_Daedric_Molag_Response_Orc | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Orc cell | One-time on an Orc committing | Title: "Against the Code" Body: "For an Orc, Molag Bal's vampiric claim contradicts Malacath's code entirely -- the code is endurance and provision, and the thirst is dependency. An Orc who feeds on others has placed survival above the kin's code. Malacath does not look away from this. Cure and hard renunciation are the exits; the kin will remember the breach longer than the code does." |
| PDV_Msg_Daedric_Molag_Response_Argonian | MessageBox | Marked | Narrator | 500/280 | DaedricMatrix "Molag Bal" Argonian cell | One-time on an Argonian committing | Title: "The Hist Grieved" Body: "For an Argonian, Molag Bal's vampiric claim damages the Hist relation deeply and raises Sithis-pressure -- the undead Saxhleel is a soul the Hist cannot receive, and the void reads it as its own. But Sithis's pressure does not justify the curse; it only marks its gravity. Cure first, then slow recovery; the Hist reaches again, but it takes time and grief." |

---

## 8. Coverage

| Prince | Tone | Boon | Price | Tier-up | Commitment | Stigma | Neglect/Exit | Per-race response | Status |
|---|---|---|---|---|---|---|---|---|---|
| Boethiah | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (8 non-native) | PILOT COMPLETE |
| Azura | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (8 non-native) | COMPLETE (7.1) |
| Mephala | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (8 non-native) | COMPLETE (7.2) |
| Malacath | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (9 non-native) | COMPLETE (7.3) |
| Meridia | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.4) |
| Nocturnal | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.5) |
| Hermaeus Mora | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.6) |
| Mehrunes Dagon | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.7) |
| Sheogorath | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.8) |
| Clavicus Vile | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.9) |
| Vaermina | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.10) |
| Sanguine | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.11) |
| Namira | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.12) |
| Peryite | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.13) |
| Hircine | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.14) |
| Molag Bal | drafted | drafted | drafted | drafted | drafted | drafted | drafted | drafted (10 races) | COMPLETE (7.15) |

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
