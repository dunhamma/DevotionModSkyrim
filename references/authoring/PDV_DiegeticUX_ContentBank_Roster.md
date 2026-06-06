# PDV Diegetic UX — Roster Content Bank (D3, remaining 8 races)

**Status:** Content-locked draft for the diegetic medallion/journal/MessageBox copy of the 8 non-pilot
races. Pilot races (Khajiit/Khenarthi + Dunmer) are in `handoff/PDV_DiegeticUX_D1PilotPacket.md`.
**Grammar:** identical to the pilot packet (Architecture §5.1/§5.2). `{n}` = day count; `{path}`/`{mode}`/
`{sect}`/`{standing}`/`{integrity}`/`{exposure}`/`{stones}` = runtime values.
**Date:** 2026-06-05

## Scope note — what's new vs what reuses existing slots
The **medallion** and **journal** copy below is **new diegetic surface** (no prior slot) — author it here.
The **transition MessageBox/notification** copy mostly **reuses the existing God-voice/Narrator slots**
already inventoried per race in `references/authoring/PDV_TransitionSurfacing_CoverageMap.md` +
`race-sheets/PDV_RaceContent_Manifest.md`; this doc adds a MessageBox only where the diegetic layer needs a
beat that doesn't yet exist (chiefly **curse cure**, the audit's "missing half", and the **emergence**
beats for races whose emergence is a real event rather than →Champion). Tone/channel emphasis per race is in
`references/authoring/PDV_DiegeticUX_PerRaceImplementationMap.md`.

Per the CoverageMap emergence reconciliation: real `emergence` MessageBoxes are authored here only for
**Breton** and **Orc** (life-mode); the rest surface Devoted via the existing per-deity Champion entry
(→Champion) and need no new emergence box.

---

## Nord — Kyne — `deity: kyne`
```yaml
name:        "Amulet of Kyne"
name_dim:    "Amulet of Kyne (still)"
name_curse:  "Amulet of Kyne (shadowed)"
tierLabels:  [Observant, Faithful, Devoted, Champion]
medallion:
  favored:      "Kyne's breath fills your lungs."
  neglect_hint: "The storm has gone still for {n} days. Honor the hunt and the dead."
  cursed:       "Kyne turns her face from the beast you carry."
journal:
  tier.Faithful:   "You reached Faithful. The pantheon of Skyrim marks you."
  curse.onset:     "The beast-blood rises; Kyne's wind recoils from it."
  curse.cure:      "The taint is burned away. Kyne's breath returns to you, clean."
  neglect.drop:    "{n} days unhonored. The Widow of Shor has gone quiet."
  favor.digest:    "The day's devotions kept; the hunt was clean."
messagebox:
  curse.cure:                               # release — Loud; god-voice
    title: "— Kyne —"
    body:  "The beast is driven from your blood. Breathe deep — the storm is yours again. Hunt cleanly, honor the fallen, and I will ride the wind at your shoulder."
```

## Imperial — the Divines (Stendarr / Akatosh / Talos) + Concordat — `deity: imperial_divines`
```yaml
name:        "Amulet of the Divines"
name_dim:    "Amulet of the Divines (tarnished)"
name_curse:  "Amulet of the Divines (lightless)"
tierLabels:  [Observant, Faithful, Devoted, Champion]
medallion:
  favored:      "The Divines keep your covenant."
  neglect_hint: "The shrines stand neglected {n} days. Mercy and law await."
  cursed:       "No blessing reaches you through the curse."
  standing:     "Concordat standing: {standing}."        # extra line, Imperial only
journal:
  tier.Faithful:        "You reached Faithful. The Imperial cult counts you devout."
  reorientation.switch: "Your standing shifts; the Concordat marks you {standing}."
  curse.onset:          "The curse bars the Divines' light from you."
  curse.cure:           "The shadow is lifted; the Divines' mercy reaches you once more."
  neglect.drop:         "{n} days from any shrine. The Divines' favor cools."
  favor.digest:         "The day's observances kept under law."
messagebox:
  curse.cure:                               # release — Loud; god-voice
    title: "— Akatosh —"
    body:  "The corruption is undone, and time runs true in you again. Keep faith, and keep the law; the covenant holds."
# Concordat standing change = reorientation, Medium (Narrator) — NO offer-time 'blocked' popup
# (Imperial rule, PDV_RaceDesign_Imperial.md:226). Surface via the journal line + medallion standing only.
```

## Breton — Stendarr (Integrity) / Witchcraft exposure / Green Way — `deity: breton`
**Special: the legibility medallion.** Breton's headline audit fix is making three opaque numbers legible.
The medallion renders all three (this is its whole job for Breton).
```yaml
name:        "Reliquary of the Wyrd"
name_dim:    "Reliquary of the Wyrd (clouded)"
name_curse:  "Reliquary of the Wyrd (broken)"
tierLabels:  [Observant, Faithful, Devoted, Champion]
medallion:                                  # Breton renders these three lines verbatim
  integrity:  "Integrity: {integrity}/100   (Stendarr's penance caps restoration at 75)"
  exposure:   "Witchcraft known: {exposure}   <gold→red as it nears the point of no return>"
  greenway:   "Green Way: {stones}/13 standing stones walked"
  cursed:     "The Wyrd is severed; the old paths are dark to you."
journal:
  tier.Faithful:    "You reached Faithful. Stendarr counts your mercies."
  emergence.onset:  "You take up the Green Way. The Druid-paths of the Reach open to you."
  warning.exposure: "Your witchcraft is nearly known. Past this point there is no quiet return."
  curse.onset:      "The curse closes the old paths against you."
  curse.cure:       "The Wyrd knits whole again; the green roads reopen."
  neglect.drop:     "{n} days unobserved. Mercy and the wood both grow distant."
  favor.digest:     "The day's mercies kept; the old ways tended."
messagebox:
  emergence.onset:                          # Druidic Trial — Loud; old-power voice
    title: "— The Green —"
    body:  "You have walked the standing stones and the wood has taken your measure. Walk now as a Druid of the Wyrd: keep faith with the green, and the old powers of the Reach are yours."
  curse.cure:
    title: "— Stendarr —"
    body:  "The corruption is cleansed by your penance. Rise — my mercy is not spent on you. Show it now to others, as it was shown to you."
```

## Altmer — Auri-El / Trinimac (Apotheosis), Lorkhan adjacency — `deity: auri_el`
**Special: terminal curse — NO cure beat.** The scar is permanent; do not fire `release`.
```yaml
name:        "Sun-in-Splendor pendant"
name_dim:    "Sun-in-Splendor pendant (dimmed)"
name_curse:  "Sun-in-Splendor pendant (extinguished)"   # permanent
tierLabels:  [Observant, Faithful, Devoted, Ascendant]
medallion:
  favored:      "Auri-El's light lifts you toward heaven."
  neglect_hint: "Your ascent stalls; {n} days without rite."
  cursed:       "Beast-blood has severed you from Apotheosis. There is no road back."
journal:
  tier.Faithful:   "You reached Faithful. Auri-El marks your ascent."
  lorkhan.first:   "You drew near the Doom-Drum's heart. Lorkhan's mortality drags at your ascent."
  curse.onset:     "The beast takes you. Apotheosis is annihilated; the ladder to heaven is cut."
  # curse.cure:    N/A — terminal (Altmer position is terminal, PDV_RaceDesign_Altmer.md:367)
  neglect.drop:    "{n} days idle. The light withdraws from you by degrees."
  favor.digest:    "The day's rites kept; the ascent continues."
messagebox:
  curse.onset:                              # dread, terminal — Loud; god-voice. NO cure box exists.
    title: "— Auri-El —"
    body:  "You have let the beast into your blood. The ladder is cut and Apotheosis is lost to you; no rite restores what beast-form has unmade. Walk on, then, as mortal things walk."
```

## Bosmer — Y'ffre / Green Pact (branch substrate), four paths — `deity: yffre`
```yaml
name:        "Pact-token of Y'ffre"
name_dim:    "Pact-token of Y'ffre (fraying)"
name_curse:  "Pact-token of Y'ffre (wrong)"
tierLabels:  [Wayward, Pact-Keeper, Green-Sworn, "Voice of the Wood"]
medallion:
  favored:      "The Green Pact holds; the wood knows your name."
  neglect_hint: "The Pact frays; {n} days astray from the green."
  cursed:       "The wild recoils from the wrongness in your shape."
  path:         "Your path: {path}."                   # extra line — which of the four
journal:
  substrate.act:        "The wood marked your keeping of the Pact today."
  tier.Pact-Keeper:     "You are Pact-Keeper. Y'ffre's law sits well in you."
  reorientation.switch: "Your road bends; you walk now the path of {path}."
  curse.onset:          "The wrongness takes your shape; the wood draws back."
  curse.cure:           "The wild forgives you; the Green Pact is whole again."
  neglect.drop:         "{n} days from the green. Y'ffre's story forgets you a little."
  favor.digest:         "The day's keeping noted; the Pact held."
messagebox:
  curse.cure:
    title: "— Y'ffre —"
    body:  "The wrongness is gone from your shape; you are as the Pact made you. Eat no plant of the green, waste nothing of the kill, and the wood will keep you in its story."
```

## Argonian — the Hist (substrate) + Sithis — `deity: hist`
**Special: the curse silences the substrate.** Curse screen = hist-void look; cure = Hist-restoration.
```yaml
name:        "Hist-amber pendant"
name_dim:    "Hist-amber pendant (dull)"
name_curse:  "Hist-amber pendant (silent)"
tierLabels:  [Untouched, Hist-Touched, Hist-Marked, "Root-and-Branch"]
medallion:
  favored:      "The Hist's sap runs warm in your thoughts."
  neglect_hint: "The Hist grows distant; {n} days from deep water."
  cursed:       "The curse has silenced the Hist within you."
journal:
  substrate.act:    "You drank of the Hist today; it remembers."
  tier.Hist-Touched:"The Hist marks you. You are heard in the deep root."
  void.rise:        "Sithis stirs beneath the root; the Void claims its share of you."
  curse.onset:      "Cold blood. The Hist's voice falls silent; you are cut from the root."
  curse.cure:       "The Hist speaks again; its sap returns, and the silence lifts."
  neglect.drop:     "{n} days from the water. The root's voice thins."
  favor.digest:     "The day's communion kept; the sap was not forgotten."
messagebox:
  curse.cure:                               # release, multi-beat Hist-restoration
    title: "— The Hist —"
    body:  "[A green silence — then warmth floods back through your thoughts.] The root knows you once more. Return to the water, drink deep, and you will not be alone in your own skull again."
```

## Orc — Malacath (forge substrate) + life-mode — `deity: malacath`
```yaml
name:        "Mark of the Spurned"
name_dim:    "Mark of the Spurned (cold)"
name_curse:  "Mark of the Spurned (turned)"
tierLabels:  [Outcast, Sworn, Bloody-Handed, "Champion of the Code"]
medallion:
  favored:      "Malacath weighs your oaths and finds them kept."
  neglect_hint: "An oath grows cold; {n} days untended."
  cursed:       "Even the god of the spurned spurns the beast in you."
  mode:         "Life: {mode}."                        # Stronghold / City / Exile
journal:
  substrate.act:        "The forge counted your work today."
  tier.Sworn:           "You are Sworn. Malacath knows your bloody hand."
  reorientation.switch: "You take up the {mode} life; the code shapes you anew."
  oath.frame:           "You have given your word. Malacath is listening — keep it."
  curse.onset:          "The beast strains at your discipline; Malacath watches, unimpressed."
  curse.cure:           "Your word is clean again; Malacath turns back toward you."
  neglect.drop:         "{n} days, an oath untended. The Bloody-Handed grows cold."
  favor.digest:         "The day's labor kept; the code held."
messagebox:
  reorientation.switch:                     # life-mode emergence — Loud; god-voice
    title: "— Malacath —"
    body:  "So this is the life you choose. Keep the code: shelter your kin, keep your word, break what insults you. Fail and you are nothing; succeed, and even the gods who spurned us will be made to look."
  curse.cure:
    title: "— Malacath —"
    body:  "The beast is mastered — you kept discipline where weaker things break. Good. A strong arm that keeps its word is all I have ever asked. Keep it."
```

## Redguard — Tu'whacca / Satakal / HoonDing (sect substrate) — `deity: tuwhacca`
```yaml
name:        "Amulet of Tu'whacca"
name_dim:    "Amulet of Tu'whacca (dim)"
name_curse:  "Amulet of Tu'whacca (clouded)"
tierLabels:  [Observant, Faithful, Devoted, Champion]
medallion:
  favored:      "Tu'whacca keeps the road to the Far Shores open for you."
  neglect_hint: "The road dims; {n} days without rite for the dead."
  cursed:       "The curse clouds the road to the Far Shores."
  sect:         "Way: {sect}."                         # Crown / Ash'abah / Forebear
journal:
  substrate.act:        "You walked a step of the Walkabout today."
  tier.Faithful:        "You reached Faithful. The Yokudan dead count you faithful."
  reorientation.switch: "You turn to the {sect} way; Crown and Forebear walk different roads."
  curse.onset:          "A shadow falls across the road to the Far Shores."
  curse.cure:           "The road clears; Tu'whacca will guide your dead again."
  neglect.drop:         "{n} days, the dead untended. The road grows faint."
  favor.digest:         "The day's duty to the dead was kept."
messagebox:
  curse.cure:
    title: "— Tu'whacca —"
    body:  "The shadow on the road is gone. Walk on; when your time comes I will see you to the Far Shores, and the gods of Yokuda will know your name."
```

---

## Daedric / shared (note, not a per-deity bank)
Daedric Princes use the **existing** `PDV_Notif_Daedric_<Prince>_Stigma_<band>` (stigma → `neglect`/
`reorientation` tones, dread-leaning) and the God-voice commitment/exit MessageBoxes
(`PDV_ContentDestinationMatrix.md`). Meridia's cleansing-light overlay reuses the `release`/`revelation`
**screen**. No per-Prince diegetic medallion/body-mark in V1 (avoid art sprawl); curse/scar is shared via
`PDV_CurseState`. The medallion, when a Daedric path is active, shows the Prince name + stigma band using
the same grammar.

## Coverage gate (per `PDV_TransitionSurfacing_CoverageMap.md` discipline)
- Author each block's `journal` + `medallion` strings into the per-deity bank.
- **N/A on record:** Altmer `curse.cure` (terminal); Argonian/Bosmer/Dunmer/Nord/Imperial/Redguard
  `emergence` MessageBox (→Champion reuse); per-Prince body-marks (V1).
- Special medallion renderers: **Breton** (3-number legibility), and the optional standing/mode/sect/path
  extra lines (Imperial/Orc/Redguard/Bosmer). Codex: these are extra `medallion.*` keys the Director
  appends when the race has the field; the base 3-line grammar is unchanged.
