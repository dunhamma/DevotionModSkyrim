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

---

## 3. Triage note

After 1.0 ships, convert this stub into a real V2 roadmap: group the voiced
dialogue work into a single CAT-style content lane (draft -> ratify -> voice ->
promote), decide whether voice is recorded, AI-generated, or community-sourced,
and sequence it against any post-1.0 architecture work pulled from Section 23.
