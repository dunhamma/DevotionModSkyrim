# PDV Requiem-Build — Smoke-Test Tracker (Track A build + Track B in-game)

Status: LIVE TRACKER (updated as build slices land and smoke checks complete)
Created: 2026-06-20
Plan of record: `C:\Users\Admin\.claude\plans\let-s-kick-off-the-memoized-hellman.md`
Provenance: `PDV_RequiemBuild_Handoff_2026-06-20.md`,
`PDV_RequiemRegenConversion_Plan.md`, `PDV_OpenDecisions_RulingMemo.md`.

One file for both tracks. **Track A** = implementation/build state. **Track B** =
in-game smoke status. The load-bearing proof a regen conversion worked is in-game
only (HP bar moves under a Requiem list) — readback proves records EXIST, not that
they are FELT. The smoke sweep doubles as the magnitude-tuning pass (magnitudes are
PROVISIONAL).

Decisions ruled 2026-06-20: conversions-first (HoonDing its own slice); Namira =
heal-on-feed lifesteal; Nord startup and Requiem-tail records are folded into
`Devotion.esp`, with runtime/manual proof still pending.

2026-06-20 closeout update: the Nord startup gate and the former Requiem-tail
record work are now built and folded directly into `Devotion.esp`; no persistent
houseCARL patch plugin ships. This supersedes the older "deferred/planned" Track
A rows below for Nord Shor, HoonDing Champion save, HoonDing named bosses,
Ash'abah necromancer/warlock detection, and Namira contract cleanup. The same
helper also added the Ash'abah clearable-undead-site burden hook. Machine proof
is compile/readback only: `PDV__ManagerQuest` and `PDV_ActionRouter` compile
0/0, `pdv-requiem-tail-author --check --all` passes, `pdv_verify` is `FAIL=0`,
reward readback is `FAIL=0`, and houseCARL readback confirms the folded records.
Runtime/manual rows remain PENDING until tested in Skyrim.

---

## Track A — build checklist

Per-item columns: **Spec** (spec edited) · **Auth** (reward author run + dry-run
reviewed) · **RB** (readback FAIL=1 = the lone unrelated GreenPact KID; PASS was
1284 pre-B1, 1278 after removing the 2 swallowed Tu'whacca HealRateMult effects) ·
**Papyrus** (manager/script edits) · **Comp** (`pdv_compile --script
PDV__ManagerQuest` = 0/0) · **Snap** (live manager snapshotted) · **Commit**.
`—` = not applicable to that item. `·` = pending.

### Build A — 8 converted races (DONE + LIVE, commit 4116d6b)
| Race / reward | Spec | Auth | RB | Papyrus | Comp | Snap | Commit |
|---|---|---|---|---|---|---|---|
| Imperial Civic/Arkay → Fortify Health | ✅ | ✅ | ✅ | — | — | ✅ | ✅ |
| Imperial Mara → event sleep-mercy heal | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dunmer home-prayer pulse (event) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Argonian/Khajiit/Bosmer/Breton/Orc → Fortify Health (20 fx) | ✅ | ✅ | ✅ | — | — | ✅ | ✅ |
| Orc Code Holds health half (event) | — | — | ✅ | ✅ | ✅ | ✅ | ✅ |

### Build B1 — heal conversions + text (BUILT + verified; commit pending)
| Item | Spec | Auth | RB | Papyrus | Comp | Snap | Commit |
|---|---|---|---|---|---|---|---|
| B1.0 snapshot live manager (pre-edit) | — | — | — | — | — | ✅ | — |
| B1.1 Redguard Tu'whacca T2/T3 → event heal | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | · |
| B1.2 Ash'abah stigma (text-only) | — | — | — | ✅ | ✅ | ✅ | · |
| B1.3 Daedric Namira → heal-on-feed (scripted) | ⏸ | ⏸ | ⏸ | ✅ | ✅ | ✅ | · |
| B1.4 Breton Vigilant nod (verify only) | — | — | — | ✅ | — | — | — |
| B1.5 B1 deploy: compile + readback + snapshot + commit | — | — | ✅ | — | ✅ | ✅ | · |

B1.3 ⏸ = Namira scripted lifesteal is built + felt; the Daedric CONTRACT cleanup
(remove inert HealRateMult boon + fix text) + targeted ESP edits are now complete
in the Requiem-tail closeout, without a broad Daedric re-author. B1 lives in
`generated/live-devotion-snapshot/2026-06-20-requiem-b1/`.

### Build B2 — HoonDing make-way rebuild (Papyrus core BUILT + verified; commit pending)
| Item | Papyrus | Comp | Route-proof (in-game) | Snap | Commit |
|---|---|---|---|---|---|
| B2a make-way 2501 → breakthrough kills (V1 dragons) | ✅ | ✅ | PENDING | ✅ | · |
| B2b road-passage → Forebear/Leki lane (off HoonDing) | ✅ | ✅ | PENDING | ✅ | · |
| B2c drop weekly cap → dragon daily soft-decay | ✅ | ✅ | PENDING | ✅ | · |
| B2d retire dead signal 2502 | ✅ | ✅ | n/a | ✅ | · |
| B2e HoonDing Champion cheat-death save | ⏸ | — | — | — | — |
| B2f named-boss/milestone/final-boss FormList qualify | ⏸ | — | — | — | — |

B2e/B2f ⏸ = creation-authoring/CKPE work (attach the save MGEF as an extra effect;
build the curated boss FormList) — split to the capstone session (task #11),
bundled with the Nord Shor re-attach. Superseded 2026-06-20: the helper now
folds these records into `Devotion.esp`; V1 make-way = dragons plus the listed
boss FormList. B2 lives in
`generated/live-devotion-snapshot/2026-06-20-requiem-b2/`. Compile 0/0 (3 scripts),
verify FAIL=0.

### Ash'abah mid-game entry — DONE (concurrent, commit 7f90f49)
The gap flagged this session (mid-game Ash'abah sect unreachable) is FIXED:
`HandleRedguardAshAbahMajorBurden` (a UNIQUE/named-undead kill routes reason
`redguard_deathduty_major` → sect entry); shared `ApplyRedguardAshAbahDutyRewards`;
gate hardened to `StringContainsToken`. Compile 0/0, verify FAIL=0, pushed.

### Requiem-tail record closeout - folded into `Devotion.esp`
The former CK-blocked tail is now complete through direct Mutagen helpers plus
houseCARL readback. No persistent patch plugin ships.
| Item | Approach | Status |
|---|---|---|
| 1. Nord Shor convert + Sovngarde save re-attach | spec (extra-effect) + direct helper VMAD attach | BUILT/readback PASS |
| 2. HoonDing Champion cheat-death save | spec extra-effect + direct helper VMAD attach | BUILT/readback PASS; runtime PENDING |
| 3. HoonDing named-boss FormList (beyond dragons) | FLST + manager qualify | BUILT/readback PASS; runtime PENDING |
| 4. Ash'abah named-necromancer detection (beyond unique undead) | faction properties + manager qualify | BUILT/readback PASS; runtime PENDING |
| 5. Namira boon contract cleanup | targeted MGEF/text edits (NO full Daedric re-author) | BUILT/readback PASS; runtime PENDING |
| 6. Ash'abah clearable-undead-site hook | 43-entry FLST + armed clear hook | BUILT/readback PASS; runtime PENDING |

---

## Track B — in-game smoke status

Proof classes: **[R]** ROUTE/RUNTIME (Papyrus log marker / Trace / numeric move) ·
**[M]** MANUAL-ACCEPTANCE (HP bar moved, "reads as earned"). Status: PENDING / PASS
/ FAIL / TUNED (magnitude adjusted to feel right under Requiem). Do NOT mark a
race-level `pass` in `PDV_Phase20_ManualEvidenceLedger.json` until the in-game HP
proof is recorded.

### Preflight (every session)
Disposable new save (or `coc qasmoke`); MO2: disable "Devotion – Living Deities
Test"; `set PDV_GLO_OriginRace to <race>`; `set PDV_GLO_DebugLevel to 2`; MCM →
Developer Options → unlock Status/Debug. Origin indices: 0 Nord, 1 Imperial (see
each run-sheet for the rest). Papyrus log:
`…\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

### Sweep A — 8 converted races (READY NOW — no build needed)
Core check: each converted reward is felt under Requiem. Use `player.getav Health`
before/after and watch the HP bar.

| Check | Race / reward | How to seed → observe | Proof | Status | Note |
|---|---|---|---|---|---|
| A1 | Argonian Fortify Health | seed deity to tier (MCM Apply target piety / force tier) → max Health rises | [M] | PENDING | |
| A2 | Khajiit BaanDar T2/T3 Fortify Health | seed BaanDar to tier → max Health rises (BaanDar T3 cheat-death save still present) | [M] | PENDING | |
| A3 | Bosmer LivingStory/BanditRoad T2/T3 Fortify Health | seed to tier → max Health rises | [M] | PENDING | |
| A4 | Breton Tradition/GreenWay Fortify Health | seed to tier → max Health rises | [M] | PENDING | |
| A5 | Orc Malacath T2 Fortify Health | seed to tier → max Health rises | [M] | PENDING | |
| A6 | Imperial Civic T1/T2 + Arkay T2/T3 Fortify Health | seed to tier → max Health rises (T1 was fully dead pre-conversion) | [M] | PENDING | |
| A7 | Imperial Mara sleep-mercy (event) | sleep in a bed → HP bar restores once/day (Devoted 25 / Champion 40) | [M] | PENDING | |
| A8 | Dunmer home-prayer pulse (event) | sleep in a bed (declare home → notice) → pray with urn AT home → HP bar moves; pray elsewhere → NO pulse | [M] | PENDING | |
| A9 | Orc Code Holds health half (event) | trigger near-death → flat Health restore (paired with the existing stamina restore, Seeker 40 / Devoted 60) | [M] | PENDING | |
| A10 | Beta-feel poles (existing run-sheets) | run `PDV_RunSheet_Dunmer/Imperial/Orc_BetaFeel.md` (Orc life-mode runtime) | mixed | PENDING | |

### Sweep B1 — heal conversions + text (after B1 deploy) → run-sheet: `PDV_RunSheet_Redguard_BetaFeel.md`
| Check | Surface | How to observe | Proof | Status | Note |
|---|---|---|---|---|---|
| B1.a | Redguard Tu'whacca event-heal | death-duty/Ash'abah act → HP bar restores, T2 smaller / T3 larger, once/day; repeat same day → no 2nd heal | [M] + [R] | PENDING | |
| B1.b | Namira heal-on-feed | Namira path → feed (cannibalism) → HP pulse, tier-scaled; feed past cap → no heal | [M] + [R] | PENDING | |
| B1.c | Ash'abah stigma | marked death-duty → stigma label in Survey/status + marked-moment notice, paired with Tu'whacca heal; **NO piety drop** | [M] | PENDING | |
| B1.d | Breton Vigilant nod | raise WitchcraftExposure ≥ 50 → Survey line reads well (no build) | [M] | PENDING | |

### Sweep B2 — HoonDing rebuild (after B2 deploy; disposable save) → run-sheet: `PDV_RunSheet_Redguard_BetaFeel.md`
| Check | Surface | How to observe | Proof | Status | Note |
|---|---|---|---|---|---|
| B2.a | make-way on dragon | kill a dragon → make-way fires once (piety moves + Trace) | [R] | PENDING | |
| B2.b | dragon daily decay | kill 2nd dragon same day → soft-decayed (×0.7) | [R] | PENDING | |
| B2.c | generic kill rejected | kill a generic bandit → does NOT fire | [R] | PENDING | negative |
| B2.d | boss/milestone dedup | named boss / major-quest milestone → fires once; re-trigger same source → no re-fire | [R] | PENDING | |
| B2.e | road-passage reroute | road-passage event → Forebear/Leki lane, NOT HoonDing make-way | [R] | PENDING | negative |
| B2.f | HoonDing Champion save | drop to <20% health → cheat-death save fires once/day | [M] | PENDING | |

---

## Notes / parking
- Current extra Redguard/HoonDing runtime rows after the Requiem-tail closeout:
  test a listed HoonDing boss in addition to a dragon; test the HoonDing
  Champion low-health save once/day; test one approved Ash'abah clearable undead
  site from `PDV_FLST_RedguardAshAbahUndeadClearSites`; and confirm a non-listed
  clearable site stays silent. These are runtime/manual PENDING until recorded.
- Evidence sink: `PDV_Phase20_ManualEvidenceLedger.json` (Redguard + Daedric/Namira
  blocks). Route proof checker: `node ./tools/pdv_phase20_runtime_check.mjs`.
- Final gate after all slices (+ Nord whenever done): `node ./tools/pdv_verify.mjs`
  then `node ./tools/pdv_beta_readiness_audit.mjs --strict`.
- Magnitudes are PROVISIONAL; record TUNED values back into the reward spec / manager
  by hand (cumulative-rebalance tools are not idempotent — do NOT re-run them).
