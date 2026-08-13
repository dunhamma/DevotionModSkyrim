# Compat Proof Harness — Tier 2 (EVT_350 heal) + Tier 3 (Hircine spell faucet)

LIVING test procedure. Authored 2026-08-13 for branch `claude/mod-compat-1.5.0`
(commits `1a716041`, `96adfb45`, `205bfd9b`). Run it in a play session to convert the
gate-green declaration proof into runtime proof. Delete or archive once run.

## The one question this harness answers

All three commits share a single unproven assumption:

> **Does `Actor.OnSpellCast` fire for these spells** — a concentration heal (Healing Hands),
> a transformation (Force of Nature), a summon (Call Hound of Hircine)?

Every gate is green, but firing is caster-side via `OnSpellCast` and has not been observed in
game. If the traces below appear, all of Tier 2/3 is proven. If a trace never appears for a
given spell, `OnSpellCast` does not fire for that spell class and that lane needs a different
hook (not a scoring bug).

## Prerequisites

1. **Active plugins** in the profile: `Devotion.esp`, `MysticismMagic.esp`,
   `Triumvirate - Mage Archetypes.esp` (all confirmed active in `Devotion Dev` on 2026-08-13).
2. **The heal FormList must be in the live `Devotion.esp`** — record `071790`
   `PDV_FLST_HealCureOtherEffects`. It was authored into the MO2 ESP; if the ESP was
   redeployed since 2026-08-13, re-author it (it is not git-tracked). Verify with
   `housecarl_read_record 071790:Devotion.esp` (expect items `01CEA7`, `0B62ED`).
3. **Compiled `.pex` current**: `PDV_PlayerEvents.pex` rebuilt from the committed source.
4. **Matrix JSON current**: `PDV_QuestReactionMatrix.json` regenerated (contains
   `faucetSpellFormsHircineServeADaedraHircineFormIdsCsv`).
5. **Debug level 2**: MCM → Devotion → (debug page) → **Debug Level** slider to `2`. This is
   what makes the `Trace(2, ...)` lines below write to the log. Do NOT use `cqf`.
6. **Papyrus log**: `C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\`
   — read `Papyrus.0.log` after each step.

### Contamination guards (from prior sittings)

- Confirm the **QR perf-sweep queue is idle** before starting — a draining sweep emits stray
  toasts and reward-sync races that read like boon bugs.
- Do **not** read results over an open MCM (`Message.Show` cannot fire over an open menu).
  Close the MCM, act, then open the Book of Days / Ledger.
- A **fresh save is safest** for the anti-farm day-key checks; a save that already banked a
  heal today will show the cap already spent.

---

## Test A — Tier 2: EVT_HEAL_OR_CURE_NPC (350)

**Front-loaded IDs:** event `350`; trace string `Heal/cure-other cast detected:`; scoring
deities in the table below; heal FormList `071790`.

### A1 — Vanilla positive (the core proof)

1. Console: `player.addspell 00012FD2` (Healing Hands / "Heal Other").
2. Equip it. Cast it once (target does not matter — detection is caster-side).
3. **Log expectation:** `[PDV] ... Heal/cure-other cast detected: Healing Hands` (or "Heal
   Other" if Mysticism renamed it).
4. **Ledger expectation:** open Book of Days / the Ledger; the 350-scoring deities gain (see
   table). **Mara +0.75 is the clearest single tell.**

If A1's trace appears → `OnSpellCast` fires for concentration heals and the whole heal lane
is proven. If it never appears → that is the finding; stop and report.

### A2 — Anti-farm cap

5. Cast Healing Hands again the same day. It keeps scoring up to each deity's `dailyCap`
   (Mara 2, Kyne 3, …), then stops. Casting past the cap should bank nothing further that day.

### A3 — Mysticism coverage (should be free)

6. With Mysticism active, Healing Hands *is* Mysticism's overridden version, yet uses the same
   effect FormID `01CEA7`. Repeat A1 — it should fire identically. This proves the
   override-in-place free-coverage claim.

### A4 — Triumvirate coverage

7. Learn **Aura of Vigor** and/or **Aura of Thorns** (Triumvirate cleric spells). Find the
   runtime FormID with `help "Aura of Vigor" 4 SPEL`, then `player.addspell <id>`, or buy the
   tome. Base spell EditorIDs: `TVR_Cleric_R050_Spell_Aura_2` (`1E7429`),
   `TVR_Cleric_R075_Spell_Aura_3` (`1E742B`).
8. Cast it. Expect the same detection trace + Ledger gain. (These are aura spells — casting
   fires `OnSpellCast`; confirm.)

### A5 — Self-heal negative control (must NOT score)

9. Cast a **Self** heal — Fast Healing, Close Wounds, or Healing. Expect **no** trace and **no**
   350 gain. This proves the other-delivery curation: combat self-sustain does not read as
   healing worship.

### A6 — Two-sided axis (optional)

10. The murder-cult princes dislike mercy. After A1, Boethiah / Sithis / Mephala should tick
    **down** (small negatives) from the same emission. Visible only if those deities have live
    piety on the character.

### EVT_350 scoring reference

| Deity | Δ | tier | cap/day | origin gate |
|---|---|---|---|---|
| Mara | +0.75 | medium | 2 | — |
| auri-el, azura, Stuhn, The Hist, Tu'whacca, Syrabane | +0.75 | medium | 2 | — |
| Arkay, Stendarr, Kynareth, Y'ffre, Z'en | +0.5 | small | 3 | — |
| kyne, Dibella, Tsun, khenarthi, akatosh | +0.25 | small | 3 | — |
| **Boethiah** | −0.25 | small | 3 | — |
| **sithis, Mephala** | −0.5 | small | 2–3 | — |
| Y'ffre | +0.5 | small | 3 | breton |
| Stuhn | +0.75 | medium | 2 | nord |
| khenarthi | +0.5 | small | 3 | khajiit |

Ungated rows score on any character, so a Nord or Imperial worshipping the Divines is a
convenient test subject. (23 rows total; deltas are the CSV base before stance scaling.)

---

## Test B — Tier 3: Hircine spell faucet

**Front-loaded IDs:** faucet key `Hircine.serve_a_daedra:hircine`; spells Force of Nature
`28E6EB`, Call Hound of Hircine `27009A`; anti-farm trace
`QuestReaction faucet repeat blocked: Hircine serve_a_daedra:hircine`.

### B1 — Positive

1. Learn **Force of Nature** (`help "Force of Nature" 4 SPEL` → `player.addspell <id>`, or the
   Druid vendor). EditorID `TVR_Druid_A025_Spell_ForceOfNature`.
2. Cast it (you should transform into the Horned Lord — this also exercises Tier 1.1's
   temp-race deferral if origin is unresolved).
3. **Ledger expectation:** Hircine piety gains a small serve-a-daedra tick. There is no
   dedicated positive trace on the faucet route (consistent with the shipped Sanguine/Vaermina/
   Sheogorath lanes); the Ledger is the positive proof surface.
4. Repeat with **Call Hound of Hircine** (`27009A`) — same Hircine tick.

### B2 — Shared daily cap

5. Cast Force of Nature again the same day → **log expectation:**
   `QuestReaction faucet repeat blocked: Hircine serve_a_daedra:hircine`. Proves the once/dawn
   cap.
6. Equip the **Savior's Hide** the same day → no additional Hircine tick (spell and equip
   share the one `serve_a_daedra:hircine` cap). Proves cap sharing.

---

## If a trace never appears

`OnSpellCast` not firing for a spell class is a **hook** finding, not a scoring bug — the
scoring path is gate-proven. Pivots, in order of preference:
- Concentration heals silent → try the target-side detection only after confirming a
  caster-on-other hook exists (none does today; see the Tier 2 as-built note in
  `PDV_DeadWiring_Burndown.md`).
- Transformation/summon silent → the Hircine lane needs an alternate trigger (the transform
  applies a race — a race-change or beast-form event could substitute).

Record which spells fired and which did not; that table is the whole deliverable of this run.
