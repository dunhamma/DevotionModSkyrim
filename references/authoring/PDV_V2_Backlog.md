# PDV V2 Backlog (stub)

**Created:** 2026-05-31
**Status:** Stub. Standing collection point for work explicitly deferred past
the V1 (1.0) release. Not a committed V2 plan - items here are scoped enough to
not be lost, and will be triaged into a real V2 roadmap after 1.0 ships.
**Owner docs:** `PDV_Architecture_v3.md` (Section 21.3 non-goals, Section 23
deferred decisions, Section 25.9 content track); `PDV_TargetEndStates_1.0.md`
(Voiced Content Scope).

> Add to this file whenever a decision defers work past 1.0. Keep each item to:
> what it is, why it is V2 not V1, what already exists, and the first V2 step.

---

## 1. Voiced NPC dialogue (primary V2 theme)

**Decision:** `PDV_Architecture_v3.md` Section 21.3 - V1 ships no voiced NPC
dialogue; all spoken-dialogue content is V2 with its voice files. Choice made
2026-05-31.

**Why V2, not V1:** Credible NPC recognition lines need voice acting. The
project owner is not producing voice files for V1, and silent/subtitle-only NPC
dialogue reads as unfinished. Deferring removes the only NPC-dialogue authoring
risk from the V1 critical path (the CK-safe dialogue pattern that caused the
Phase 11 CTD becomes a V2 concern).

### 1.1 Deferred items

| Item | What exists today | First V2 step |
|---|---|---|
| Phase 11 privilege dialogue families | Architecture in Section 9 (Restoration / Dialogue / spoken Recognition privilege). Pilot is prep-only. | Rebuild the CK-safe dialogue authoring pattern (the Phase 11 CTD remediation), then re-prove. |
| Arngeir / Kynareth recognition pilot | Section 9.4 D-10 spec; was runtime-proven before the CTD; design retained as the V2 spec. | Re-author the Arngeir line through the proven CK-safe path; voice it. |
| Phase 18 Nord recognition quartet | Froki, Heimskr, Andurs, Aela - CK-authored and **live in the ESP**, unvoiced. Phase 18 dialogue verifier assertions exist. | First V2 step is actually a **V1 removal**: disable/remove these `DLBR`/`DIAL`/`INFO` records from the V1 release ESP (see Build Actions). Re-add voiced in V2. |
| 39 `PDV_Dlog_*_Recognition` stubs | Draft prose complete (CAT-1) in `race-sheets/PDV_RaceContent_Manifest.md`; excluded from CAT-6 V1 promotion. | Ratify prose, voice it, promote via the Phase 19 pipeline. |
| Khajiit Champion signature moments (4 of 5) | Khenarthi wind-speed, Azurah spell-ward, Rajhin shadow-slip, Alkosh dragon-stagger were guide fantasies with stat-only records behind them; the Nexus-final pass de-promised them, so V1 copy is honest. Baan Dar's cheat-death SHIPS and holds Khajiit's one-save-per-race slot (`PDV_MGEF_Khajiit_BaanDar_T3_AvoidDeath`, ESP-verified 2026-07-15). | Owner ruling 2026-07-15: post-1.0 by design. Design four bespoke NON-save mechanics (the save slot is taken), then record + script + anti-farm + Requiem-proof each; re-promise in guides only when they fire in-game. |

### 1.2 Scope-mapping reminder

Per Section 21.3, every race's "dialogue privilege" / "recognition" payoff is
delivered in V1 through a **non-voiced** surface (MessageBox, notification,
Survey readout, faction/disposition effect). V2 adds the spoken-dialogue layer
on top; it does not replace the V1 non-voiced surface, it enriches it.

### 1.3 Pending V1 build actions (CK-side, blocking the V1 release ESP)

- [ ] Disable or remove the live Phase 18 Nord dialogue `DLBR`/`DIAL`/`INFO`
      records (Froki, Heimskr, Andurs, Aela) from the V1 release build.
- [ ] Move the Phase 18 per-speaker positive/negative **dialogue** verifier
      assertions to a V2-scoped gate so the V1 verifier does not expect them.
      (Source: `references/authoring/PDV_Phase18StatusNord.manifest.json` and
      `PDV_Phase18_StatusNord_Runbook.md` - the non-dialogue Phase 18 rows stay
      in V1.)

> These two are CK / verifier-tool actions on the build machine; they cannot be
> done from the planning docs and are the only V1-blocking part of the voice
> deferral.

---

## 2. Other already-deferred items (carried from existing docs)

These were deferred before this session; listed here so V2 has one index.

- **Breton Vigilant of Stendarr pressure encounter.** CAT-5 / Section 25.9 marks
  it optional/slip-able post-1.0 unless promoted by a later content pass. Likely
  also voice-coupled if it surfaces as dialogue.
- **Architectural deferrals (Section 23):** per-race ESP split, JContainers
  escalation (e.g. timestamped per-Prince stigma history), SPID adoption, custom
  race authoring support, multi-character cross-save patron memory, and
  localization (string-table externalization for non-English).
- **Jyggalag.** Out of 1.0 scope unless future adopted Creation Club /
  Sheogorath-Jyggalag content is explicitly added (Daedric manifest Section 7).
- **Unique rune for aggregate (mixed) surface displays (+/- rune).** Owner idea
  (2026-07-05, Mega Packet Sitting 1). The quest-reaction surfacing aggregation
  (one toast + one Book of Days line per quest fire) can carry BOTH gains and
  displeasure at once (a "deed weighed" mixed fire -- e.g. natives approve while a
  TABOO deity takes offense). For 1.0 the aggregate leads its tone/symbol with the
  stronger side. V2 polish: author a dedicated **aggregate rune/glyph that visually
  carries both a plus and a minus component** so a mixed beat reads as mixed at a
  glance (toast + Chronicle symbol), instead of borrowing the stronger side's
  single-valence symbol. Copy/symbol per pdv-player-copy guardrails; pairs with the
  medallion-glyph work.

## 3. Curse-access notoriety enhancement (Hircine / Molag Bal)

**Why deferred:** V1 uses **Model B** for curse-access stigma (decided
2026-06-01): social readability for Hircine (werewolf) and Molag Bal (vampire)
is driven by the Phase 15 curse-state overlay (known-werewolf / known-vampire
visibility), not an independent per-act Daedric stigma counter. Model B is one
coherent signal that cannot desync from the curse (no "wariness faded but you
are still a werewolf" incoherence, no orphaned stigma after a cure). The
independent per-act stigma model (Model A) was rejected for V1 because it
double-fired with the curse-state and contradicted itself on abstention/cure.

**The V2 enhancement** re-adds the finer notoriety dial, but done properly --
**witness-based, not a quiet per-act counter**, with a concrete consequence:

- **Trigger:** notoriety accrues when the player is **caught (witnessed) by NPCs
  killing as a werewolf** (and the vampire-feeding equivalent for Molag Bal),
  not from unseen devotional acts. This ties the signal to the actual visible
  fact, so it cannot desync from the curse the way Model A did.
- **Bands:** reuse `Suspected` / `Known` / `Notorious` (the four-band shape minus
  the silent `Latent` floor, per D-15).
- **Consequence at `Known` or above:** the **Vigilants of Stendarr** track the
  player down and **randomly attack** (beast/undead hunters acting on the
  notoriety). Notoriety should decay with time/lying-low so it stays recoverable.
- **Interaction:** layers on top of the curse-state social reaction; must not
  double-fire the curse-state onset/cure messages (the V1 desync failure mode).
- **Surfacing:** band-crossing notifications -- the V1 price descriptions already
  carry the passive per-tier social texture, so these fire only on a real
  witnessed-notoriety band change.

**Ready band copy (pulled from the V1 manifest on the Model B decision):**

| Band | Hircine | Molag Bal |
|---|---|---|
| Suspected | Your Hircine devotion is suspected. The beast-path draws wary eyes. | Your Molag Bal devotion is suspected. The domination-path draws wary eyes. |
| Known | Your Hircine devotion is known. The hunt-path marks its follower plainly. | Your Molag Bal devotion is known. Domination-cult devotion is not trusted. |
| Notorious | You are openly Hircine's. The beast-walker is not welcome in the settled hold. | You are openly Molag Bal's. The enslaver's servant is feared wherever you walk. |

(When this lands, the band copy may want a rephrase from "devotion is suspected"
toward "you have been seen" to match the witness-based trigger.)

---

## 4. Per-race bespoke curse-onset chronicle lines

**Decision:** 2026-06-30, during the Prisma authoring-beats pass
(`references/authoring/PDV_PrismaAuthoringBeats_Copy.md` beat #5). A bespoke Nord werewolf-onset
Book of Days line was drafted, then deferred.

**What it is:** Today, when a curse takes hold, the curse seam
(`PDV__ManagerQuest.psc` `HandleCurseStateTransition` -> `SurfaceCurseTransitionDiegetic`) fires a
toast and a pinned Book of Days entry. The chronicle line is resolved by
`PDV_DiegeticDirector.ResolveJournalLine(deityIndex, "curse.onset")`. Khajiit / Dunmer / Imperial /
Altmer have bespoke `curse.onset` arms; the other races fall to the generic
`"A curse changes the shape of devotion."` This item authors race-specific curse-onset (and likely
curse-cure) chronicle lines for the remaining races.

**Why V2, not V1:** Owner ruling -- if we give one race (Nord) a bespoke werewolf-onset line, every
race deserves the same, so it is all-or-nothing equity work, not a one-off. It also has a wiring
prerequisite: `ResolveJournalLine` currently receives only `(deityIndex, toneKey)` and the curse
seam passes `deityIndex = -1`, so the resolver knows the race and "curse.onset" but **not the curse
type** (werewolf vs vampire). A race-specific `curse.onset` arm added today would fire identically
for that race's werewolf and vampire onset. The generic line is coherent and ships fine for 1.0.

**What exists today:**
- The generic fallback line (acceptable for 1.0).
- Bespoke curse arms already authored for Khajiit / Dunmer / Imperial / Altmer (the voice template).
- Good race-aware *toast* context already exists for several races in `GetCurseContextForRace`
  (e.g. Nord werewolf onset = "The hunt pulls against Sovngarde."), which is a strong starting point.
- A drafted Nord werewolf-onset candidate line, retained in the beat-5 section of the authoring-copy
  doc: "The beast-shape takes you. The hunt pulls against Sovngarde, and your devotion bends toward
  Hircine's pull."

**First V2 step:** thread the curse type (werewolf/vampire) into `ResolveJournalLine` (so onset
lines can branch by beast vs blood), then author the per-race `curse.onset`/`curse.cure` line set,
reusing the `GetCurseContextForRace` phrases as seeds.

**Related (separate) item:** the curse *toast* title/message in `SendPrismaCurseToast`
(`PDV__ManagerQuest.psc`) are still marked PLACEHOLDER (e.g. "Lycanthropy takes hold" /
"Lycanthropy has taken root in your blood."). Finalizing those is a small standalone copy pass that
can ride with this one.

---

## 5. Breton / Y'ffre sky-welcoming ritual investigation

**Decision:** 2026-07-09. The proposed Green Way / Y'ffre weather hook is
deferred out of V1 and becomes a V2 investigation item. It should not ship as a
passive "weather changed, award piety" detector.

**What it is:** A player-initiated sky-welcoming ritual, effectively a prayer or
open-sky devotional act for Breton Green Way and possibly other Y'ffre-aligned
surfaces. The fantasy is that the player deliberately welcomes or answers the
living sky, rather than being rewarded because rain, clear sky, or storm weather
happened to transition nearby.

**Why V2, not V1:** Passive weather detection is too ambient and too easy to
misread as generic nature spam. It also needs interaction design: where the
ritual is performed, whether it is a power, lesser ritual, activator, standing
stone adjunct, or prayer surface, how it avoids overlap with shrine prayer and
standing-stone hooks, and how it communicates "you performed the rite" rather
than "weather farmed you piety." V1 should keep Green Way support to already
scoped curated sources, not add a new ritual surface late.

**What exists today:**
- `PDV_PlayerEvents.OnWeatherChange(...)` can receive PO3 weather changes and
  route a whitelisted weather form as `po3_weather`.
- `PDV_FLST_P2_BretonGreenWaySources` declares `weather` as a possible source
  kind.
- The old Green Way env-shell handoff proposed passive curated weather fills,
  but that part is now explicitly superseded by this V2 item.

**First V2 step:** Design the ritual surface before touching FormLists or
weather records. Decide whether it is a prayer spell/power, a standing-stone or
outdoor activator, or a scripted open-sky action. Then define the anti-farm rule
(likely once per day), eligible locations/weather context, player-facing copy,
and whether any passive weather readback remains only as context after the
player performs the ritual.

## 6. Triage note

After 1.0 ships, convert this stub into a real V2 roadmap: group the voiced
dialogue work into a single CAT-style content lane (draft -> ratify -> voice ->
promote), decide whether voice is recorded, AI-generated, or community-sourced,
and sequence it against any post-1.0 architecture work pulled from Section 23.
