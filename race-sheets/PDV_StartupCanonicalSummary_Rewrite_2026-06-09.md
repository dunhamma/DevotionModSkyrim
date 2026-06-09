# Startup Canonical Summary - Rewrite (task #18)

**Status:** REVIEW-READY copy. Not yet authored into source.
**Targets (paste on the Windows box):**
- `PDV__ManagerQuest.psc` -> `GetStartupCanonicalSummary` (the 10 per-race blurbs,
  inline string literals, ~:6822-6841).
- `PDV__ManagerQuest.psc` -> `STARTUP_ADVISORY_TEXT` (the shared advisory, ~:353).

**Voice:** Narrator - literary, second-person, lightly fatalistic - matching the
existing `PDV_MSG_Startup*` setup rows. Each race blurb names *who* they worship,
*how* worship works for them, and *what it costs* to stray, so all ten read at
parity.

**ASCII-safe:** no smart quotes / em-dashes (uses `'` and ` - `). Papyrus string
literals: none of these contain a double-quote, so no escaping is needed.

**Why this rewrite:** the prior blurbs were inconsistent in length and framing, and
the Dunmer line was flagged as poorly worded. These are rebuilt from
`race-sheets/Devotion_Races_Overview.md` (the locked classification + per-race
essence) and the `PDV_RaceDesign_*` sheets, to a uniform shape.

---

## STARTUP_ADVISORY_TEXT (shared, race-agnostic)

> In Devotion, the gods notice how you live. Your quest choices, the company you
> keep, your conduct in battle, and the shrines you tend are all weighed, and at
> each dawn your standing with the divine rises or falls. Worship can be broad,
> honoring many at once, but to reach the deepest devotion you must let one god
> become your own - and that is a turn of the heart, not a menu setting. The gods
> reward meaningful, varied action; repetition alone does not move them. How your
> race meets the divine is described below.

---

## GetStartupCanonicalSummary - per-race blurbs

### Nord
> Your gods are the Eight and the hidden Ninth, and beneath them the Old Ways of
> Sovngarde - Shor, Tsun, and Stuhn, who measure a life by its deeds. Worship
> broadly and the whole pantheon answers with blended favor; let your actions name
> one god above the rest, and that god will reach for you. The divine here is
> earned in the doing, never simply declared.

### Imperial
> You keep the Nine Divines, the civic faith of the Empire, where devotion is
> bound up with law, politics, and conscience. Honor the cult and its gods know
> you; where you stand on Talos and the Concordat is read as plainly as any
> prayer. Civic virtue is its own piety, and carries its own price.

### Breton
> Breton faith is the tradition you walk, and the gods take their shape from it -
> the Knight's Road of vow and service, the Hidden Art of occult power bought with
> secrecy, or the Green Way of Y'ffre and the living land. You choose your
> tradition once; it defines who you are, and the gods only color it. Only a rare,
> hard turn will ever move you from it.

### Dunmer
> You keep no single god but a layered inheritance - the ancestors who always
> watch, and the Good Daedra of the Reclamations: Azura, Boethiah, and Mephala.
> Honor them through cumulative practice, ancestor rites and the portable shrine,
> and the shared layer answers before any single focus does; in time one
> Reclamation may become your own. These layers add, they never compete, and even
> the curse of vampirism does not wholly close the path.

### Altmer
> You follow the Aldmeri pantheon - Auri-El, Magnus, Xarxes, and the orthodox
> order of the Ancestors. Devotion here is self-cultivation, judged less by single
> deeds than by the coherence of a whole life lived in discipline. Stray from the
> order and the loss is your own clarity; the curse of the beast severs the
> connection entirely.

### Redguard
> You keep the Yokudan spine - Satakal the Worldskin, Tu'whacca who guides the
> dead, and the ancestors always at your shoulder - within the sect you stand in:
> Crown, Forebear, or Ash'abah. Your sect sets your bearing and your burden among
> others, not a different theology; the ancestor reverence runs beneath all three.
> Duty is the shape of faith here, and it asks to be carried.

### Orc
> Malacath is your god, and that will not change - you do not choose a deity but
> the life you keep under his code: Stronghold, City, or Legion and Exile.
> Strength, the oath, and the forge are honored; the Stronghold standing is earned
> through kin and conduct, never merely claimed. The code holds wherever you go,
> and a broken word is the one thing Malacath does not forget.

### Bosmer
> You answer to Y'ffre and the Green Pact, the covenant that binds the Bosmer to
> the living forest, with four distinct paths held within that one covenant. Your
> faith is kept or broken by how you treat the green and the law of the hunt: eat
> no plant of Tamriel, waste no kill. To break the Pact is to wound the god
> himself.

### Khajiit
> You are born inside the Lunar Lattice, the order of Masser and Secunda, with
> Khenarthi on the road and Azurah at the threshold of dawn and dusk. No god will
> ever formally call you; your strongest emphasis emerges in silence, from how you
> live beneath the moons. You do not choose your way into this faith - you deepen
> within the order you were born to.

### Argonian
> Yours is an exile's spirituality - the Hist of your hatching, the community you
> choose in distant lands, and the Void where Sithis waits. Faith here is the work
> of holding connection across distance: a bed of your own, the people you keep,
> the Hist carried close even far from the marsh. Let the connection lapse and it
> fades gently rather than punishing; Sithis stirs only when you turn to him.

---

## Per-race source anchors (for the reviewer)

| Race | Anchor (Races_Overview classification) |
| --- | --- |
| Nord | Old Ways + Nine Divines; deeds reveal which god notices you |
| Imperial | Nine Divines; civic faith shaped by politics and conscience |
| Breton | Three-Track (Knight / Druid / Witch); tradition defines identity |
| Dunmer | Good Daedra + Ancestors; cumulative layers, never competing gods |
| Altmer | Aldmeri Pantheon; self-cultivation judged by coherence and orthodoxy |
| Redguard | Yokudan Pantheon; sect-shaped, duty-driven, ancestors present |
| Orc | Malacath; one god, three ways to carry the code |
| Bosmer | Y'ffre / Green Pact; four distinct paths within one covenant |
| Khajiit | Lunar Lattice; born inside a cosmic order, deepen within it |
| Argonian | Hist + Community + Sithis; exile spirituality across distance |
