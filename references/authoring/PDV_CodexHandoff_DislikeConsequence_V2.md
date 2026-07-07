# Codex Handoff - Minor Dislike-Consequence Packet (V1 tracked gate)

**Created:** 2026-07-07 (as V2). **Pulled into V1 as a tracked gate 2026-07-07.**
**Priority:** HIGH - now a 1.0 SHIP GATE, not a deferral. Tracked as
`C-DISLIKE-DEBUFF-BUILD` (machine) + `C-DISLIKE-DEBUFF-TUNING` (human sign-off)
in `references/authoring/PDV_1_0_EndStateContract.json`.
**Owner on execution:** Codex (headless). Claude authored this handoff; do not
treat it as built.
**Sequencing (important):** build this BEFORE the user's race felt-proof
sittings so the per-domain stings prove through C-FELT-FAMILY in the same
passes. Headless build runs in parallel with the user's play lane.
**Gate impact:** closes C-DISLIKE-DEBUFF-BUILD (records + audit) and feeds
C-DISLIKE-DEBUFF-TUNING (the anti-stack sitting) and C-FELT-FAMILY (per-domain
felt proof, via the felt-registry extension in Section 8).

---

## 1. Problem statement

Every deity dislike lane (32 deity actors, sentiment `-` in
`references/authoring/PDV_DeityLikesDislikes.csv`) currently produces ONLY a
piety loss plus loss surfacing (toast / Book of Days / panel Ledger row). The
confirmed design intent was that a real transgression against a god you have a
relationship with should also carry a small FELT consequence, in the spirit of
the neglect rework: flat, Requiem-felt, mild magnitude, and biting on genuine
transgression rather than ordinary play. That felt layer was never specced or
built. This packet designs and builds it.

Piety economy, dispatch, anti-farm, and surfacing already exist and are proven -
this packet adds ONLY the felt overlay on top of the existing negative-award
path. Do not re-architect scoring.

---

## 2. Deliverables (in order; user reviews after D1 before D2 build)

- **D1 - Design dossier** `PDV_DislikeConsequence_DesignReference.md`: the full
  per-deity/domain mapping, magnitude bands, trigger + anti-repeat rules, and
  the record inventory, following the framework this handoff locks in Sections
  4-8. STOP after D1 and let the user review the domain map + magnitudes before
  minting records.
- **D2 - Record spec** `PDV_DislikeConsequenceRecords.spec.json`: MGEF/SPEL/
  keyword/FormList contracts in the same shape as the neglect entries in
  `PDV_*RewardRecords.spec.json`, ready for the record-author tool.
- **D3 - Build**: mint records (houseCARL headless or the existing
  record-author tool), wire the manager dispatch (Section 7), compile, verify.
- **D4 - Verifier hook** (Section 8) so the packet cannot silently drift.
- **D5 - Handoff-back note**: what was built, readback proof, and the exact
  in-game test plan (Section 10) for the user to run in V2.

Research/design (D1) does NOT gate on runtime proof. D3/D4 gate on
readback/compile only; felt proof is the user's V2 play pass.

---

## 3. Locked architecture decision (do not re-litigate)

**Use a SHARED DOMAIN-KEYED disfavor overlay, NOT 32 bespoke per-deity
debuffs.** Rationale:

- 32 persistent per-deity debuffs would over-stack (a single
  `murder-defenseless` displeases ~8 deities at once) and fight Requiem, which
  is exactly the failure the neglect rework avoided.
- A god withholds grace in its OWN domain. The felt effect should express the
  DEITY's domain (what that god would withhold), so a small shared set of
  domain overlays reads as thematically correct across many deities.

So: a handful of domain overlay MGEFs (Section 5), each fired as a SHORT,
FLAT, REFRESHABLE sting when a real transgression is scored against a deity the
player has standing with. This is a "sting that fades," not a persistent tax
(that lane is owned by neglect).

If, during D1, a specific deity clearly needs a bespoke flavor beyond its domain
overlay, note it as an exception in the dossier for user sign-off - do not
default to bespoke.

---

## 4. Magnitude bands (must stay below neglect and consistent with pacing)

Reference points already shipped (do not exceed these; dislikes are the
MILDEST felt tier):

- Neglect debuffs: `-3` to `-8` on a resist, or `-5%` rate, PERSISTENT until
  repaired (`PDV_*RewardRecords.spec.json` neglect entries).
- Prince prices: `-8` skill, persistent while the pact holds.
- Pacing violation class E (`PDV_PietyPaceBalancingTable.md`): `-1.0 to -15`
  piety + rival erosion; the CSV dislike deltas run `-0.25` to `-2.0`.

Dislike sting bands, keyed to the act's CSV `baseDelta` magnitude:

| CSV |delta| | Band | Felt effect | Duration |
|---|---|---|---|---|
| <= 0.5 | **none** | loss-surfacing only (no debuff) | - |
| 0.5 < d <= 1.0 | **light** | `-2` resist / `-3%`-equivalent flat / `-3` skill | ~2 in-game hours |
| > 1.0 | **sharp** | `-4` resist / `-5`-equivalent flat / `-5` skill | ~4 in-game hours |

The `<= 0.5` cutoff is deliberate: it keeps incidental low-delta rows
(`trespass -0.25`, `cook-meal -0.25`, `sleep-in-inn -0.25`, `smith-item -0.25`)
as surfacing-only, so ordinary play does not get stung. Only genuine
transgressions (murder, necromancy, Daedra-truck, serious theft) reach a felt
band. Confirm the final cutoff in D1 against the full CSV.

**Requiem-proof authoring (critical):** author each penalty as a FLAT
value-modifier with a fixed timed duration (mirror the Requiem-proof heal
doctrine in reverse - a flat penalty that expires), NOT a rate-multiplier that
Requiem zeroes out. Verify each MGEF resolves to a felt HP/stat delta under
Requiem, same standard as the reward penalties.

---

## 5. Domain taxonomy + overlay records (D1 finalizes the exact map)

Group the 32 deities by the grace they would withhold. Starting taxonomy (Codex
finalizes membership in D1, one row per deity, from the CSV roster):

| Domain | Withheld grace (felt) | Candidate AV(s) | Example deities |
|---|---|---|---|
| Sky / storm / hunt | the weather/road turns | ResistFrost or ResistShock | Kyne, Kynareth, Khenarthi, HoonDing |
| Death / ancestors | the rest is troubled | flat Restore-Health dip / ResistDisease | Arkay, Tu'whacca, Xarxes, Magnus |
| Mercy / protection | the ward thins | flat incoming-damage / ResistMagic | Mara, Stendarr, Dibella, Stuhn |
| War / honor | combat grace falters | flat weapon-damage / stamina pool | Shor, Tsun, Talos, Leki, Trinimac, Malacath |
| Order / trade / lore | speech and study sour | Speechcraft / Magicka pool | Zenithar, Julianos, Akatosh, Z'en, Y'ffre |
| Moon / luck / shadow | fortune turns | Sneak / movement | Azurah, Rajhin, Baan Dar, Alkosh |
| Void / secrets | a quiet unease | very mild single AV | Sithis, Mephala, The Hist, Boethiah |

Record inventory (target ~6-7 MGEF, one per domain, single magnitude authored at
the SHARP band; the light band can reuse the same MGEF at reduced magnitude if
the author tool supports per-cast magnitude, otherwise mint light+sharp per
domain = ~12-14 MGEF - Codex picks the cheaper path that stays Requiem-proof and
records it in D1). Each MGEF wrapped in a self-targeted timed-ability SPEL. Plus:

- one keyword or FormList per domain, OR a single `DomainForDeity()` resolver in
  the manager keyed by deity index (prefer the resolver - name-based, immune to
  FormList order drift per the FormList-index-drift lesson).
- player-facing text per domain in the PDV voice (short, diegetic, names the
  withheld grace, not the mechanic - see `pdv-player-copy` skill).

---

## 6. Trigger + anti-repeat rules

- **Standing gate (this is what makes it "bite on real transgression"):** the
  sting fires only when the player has real standing with the offended deity -
  piety `>= Observant (25)` OR the deity is/was an accepted patron. A murder by
  someone with no relationship to Arkay produces the piety loss + surfacing but
  NO sting. Confirm the exact floor in D1.
- **Band gate:** the act's CSV `|delta|` must reach the light or sharp band
  (Section 4). Sub-0.5 acts never sting.
- **Refresh-not-stack:** re-committing refreshes the same domain sting's
  duration; it does not add a second instance. One active sting per domain.
- **Global simultaneous cap:** at most 3 domain stings active at once (mirrors
  the contextual-favor one-active spirit; prevents a 8-deity murder pileup).
  Oldest expires or is suppressed when a 4th would fire.
- **Anti-repeat cadence:** a per-deity-per-domain StorageUtil day/refresh key so
  the same transgression spammed in one day does not re-sting repeatedly beyond
  the refresh. Reuse the existing anti-farm helpers
  (`ConsumeOncePerDaySignal` / day-key guards) - see `pdv_antifarm_sweep_audit`.

---

## 7. Manager wiring (exact insertion site)

The negative award already flows through
`PDV__ManagerQuest.AwardPietyInternal(PDV_DeityBase deity, Float amount, ...)`
(live-source line ~10468). The dislike/likes deltas are read from the `PDV.LD.*`
StorageUtil table written by `LoadRowsForDeity` / `WriteLD`.

- Add `ApplyDisfavorSting(PDV_DeityBase deity, Float amount, String sourceTag)`
  and call it from the negative-award path ONLY when `amount < 0` AND the source
  is a dislike/likes-dislikes event (not decay, not neglect, not a scripted
  penalty - gate on the source tag so you do not double-sting neglect/prince
  prices). Confirm the exact discriminator by tracing the sourceTag/reason
  strings into `AwardPietyInternal` before wiring.
- `ApplyDisfavorSting` resolves the domain (`DomainForDeity`), checks the
  standing gate + band + caps, then `Game.GetPlayer().AddSpell(domainStingSpell,
  False)` with the timed-ability handling refresh.
- Mirror the neglect sync shape: `SyncKyneNeglectSpell` /
  `SyncOnePatronNeglectSpell` (live-source ~11581, ~11660) are the reference for
  add/refresh/remove of a manager-held penalty spell property.
- Bump the appropriate version constant if StorageUtil layout changes, per the
  likes/dislikes version-gate pattern (`LIKES_DISLIKES_VERSION`).

Do NOT edit `pdv_compile`/`pdv_verify`/`pdv_author` toolchain scripts except the
additive verifier hook in Section 8. Snapshot the live untracked manager before
editing (live-manager-not-in-git risk) and sync live-source -> MO2 per the
split-toolchain drift rule.

---

## 8. Verifier + gate wiring

- Add a strict flag `--strict-dislike-consequence` to a NEW audit tool
  `tools/pdv_dislike_consequence_audit.mjs` (do not bloat `pdv_verify`), or a
  small readback check that: every domain MGEF/SPEL exists in the ESP, every
  deity resolves to exactly one domain, magnitudes match the spec bands, each
  penalty is Requiem-proof-shaped (flat value-modifier), and the anti-repeat +
  standing gates are present in manager source. Ship it with `--self-test`
  fixtures (repo convention).
- Add the felt-effect registry class: the disfavor stings are a new felt-effect
  CLASS. Extend `tools/pdv_felt_registry_gen.mjs` `CLASS_BY_KEY` /
  manager-scan to enumerate them, so `pdv_felt_trace_audit.mjs` traces
  declared -> wired -> record exhaustively (they currently do not exist, so this
  is additive).

---

## 9. Effect on the 1.0 felt-family gate (this IS a 1.0 gate now)

Today `C-FELT-FAMILY` proves deity-`price` families by LOSS SURFACING (cheap;
mostly retro-credited). Because the shared overlay is DOMAIN-keyed (~6-7 domain
stings, not 32 bespoke), the added felt-proof surface is ~6-7 DOMAIN
observations, and each fires during a race sitting the user is already running
(you transgress against your native deities in that race's pass anyway). So the
per-domain felt proof rides `C-FELT-FAMILY` in the existing sittings once the
felt registry enumerates the new disfavor class (Section 8) - do NOT create a
separate felt ledger.

The one genuinely-additional cost is `C-DISLIKE-DEBUFF-TUNING`: a dedicated
anti-stack / Requiem-felt sitting (32 sources feeding 6-7 stings alongside
neglect + prince prices) with a real over-stack iteration risk. When D3 lands,
regenerate the felt registry so the domain stings appear as families, and
update the affected deity-`price` family slots' expected text from
loss-surfacing to domain-sting felt proof.

---

## 10. In-game test plan (user runs in V2; Codex records it in D5)

Per domain (not per deity - domains cluster):

1. **Positive:** as a worshipper WITH standing, commit a sharp-band
   transgression in that domain; confirm the domain sting appears in Active
   Effects at the sharp magnitude and duration, and fades on schedule.
2. **Standing-gate negative:** as a character with NO standing with that deity,
   commit the same act; confirm piety-surfacing still happens but NO sting.
3. **Band-gate negative:** commit a sub-0.5 act; confirm NO sting.
4. **Anti-stack:** trigger >3 domains at once; confirm the cap holds and no
   pileup.
5. **Requiem felt:** confirm the penalty is felt on the HP/stat bar under
   Requiem (flat, not regen-zeroed).
6. **Refresh:** re-commit; confirm duration refreshes, no second stack.

Record results in a new `PDV_DislikeConsequence_TestLedger.json` (clone the
manual-evidence-ledger v2 slot shape).

---

## 11. Guardrails / non-goals

- Do NOT add a felt debuff to sub-0.5 incidental acts - ordinary play must stay
  unstung.
- Do NOT make stings persistent - that is neglect's lane. Stings fade.
- Do NOT alter piety deltas, dispatch, anti-farm, or surfacing - additive
  overlay only.
- Do NOT double-sting neglect, decay, prince prices, or scripted penalties -
  gate strictly on dislike/likes-dislikes source.
- Keep player copy diegetic and ASCII-safe (`pdv-player-copy`, ascii guard).
- Prince (Daedric) dislike lanes are OUT of scope here - Princes already carry
  `PDV_Price_*` felt penalties. This packet is the 32 DEITY lanes only.
- No new meshes; no voiced content.

---

## 12. Source references

- Dislike roster + deltas: `references/authoring/PDV_DeityLikesDislikes.csv`
  (sentiment `-`; 32 deities).
- Magnitude/pacing anchors: `references/authoring/PDV_PietyPaceBalancingTable.md`
  (violation class E), neglect entries in each
  `references/authoring/PDV_*RewardRecords.spec.json`.
- Requiem-proof shape: neglect + reward penalty MGEFs (flat value-modifier).
- Manager insertion: `AwardPietyInternal` (~10468), `LoadRowsForDeity`/`WriteLD`
  (~9206/~8767), neglect sync (`SyncKyneNeglectSpell` ~11581,
  `SyncOnePatronNeglectSpell` ~11660), `IsNeglectFlagActive` (~11569).
- Felt registry/trace: `tools/pdv_felt_registry_gen.mjs`,
  `tools/pdv_felt_trace_audit.mjs`.
- Contract exclusion: `X-DISLIKE-DEBUFF` in
  `references/authoring/PDV_1_0_EndStateContract.json`.
