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
| Hircine | pending (curse-access) |
| Molag Bal | pending (curse-access) |
| Mehrunes Dagon | pending |
| Sheogorath | pending |
| Namira / Namiira | pending |
| Sanguine / Sangiin | pending |
| Clavicus Vile | pending |
| Peryite | pending |
| Vaermina | pending |

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
| 9 others | -- | -- | -- | -- | -- | -- | -- | -- | pending (Section 7 ledger) |

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
