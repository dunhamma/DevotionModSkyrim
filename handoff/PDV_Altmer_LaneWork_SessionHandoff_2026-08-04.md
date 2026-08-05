# Altmer lane work — session handoff (2026-08-04)

## TL;DR

Seventeen of eighteen packets from the Altmer lane audit have landed; only **P17 (cadence sizing)**
is left, and it is deliberately last because it needs a real save played to Champion. All gates
green **by exit code**: `pdv_verify`, `pdv_signal_e2e_gate`, `pdv_ascii_guard`,
`pdv_substrate_pacing_audit`, `pdv_prisma_ui_audit`, `pdv_housecarl_p2_readback
--check-source-fill`.

- **Plan:** `C:\Users\Admin\.claude\plans\do-a-thorough-audit-sharded-piglet.md` (packet index shows
  per-packet status; the P9 / P12 / P16 respecs are recorded inline with the originals kept).
- **Branch:** `altmer/late-game-feeds-2026-08-03`, three commits (`69bf417b`, `817dd39b`,
  `6af69e2a`). **Only P11 is UNCOMMITTED** — see "Commit state" below.
- **Latest snapshot:** `generated/live-devotion-backups/P11-records-pre-20260804-203512` (the
  pre-P11 ESP; `Devotion.esp` went 638,606 -> 640,700 -> 641,389 bytes across P11's two writes,
  additive both times).

## Landed

| Packet | What it did |
|---|---|
| P13 | Doc drift: stale "telemetry stub" headers, `DELTA_ANCESTOR_SPINE` comments, BC-0236, five `DESIGN INTENT` markers |
| P1 | Syrabane stance repair (the blocker) — **reverted once, re-applied, see below** |
| P3 | Auri-El signal 202 reachable + capped at 1/day |
| P6 | Altmer crisis re-entry after 30 days; first-ever caller of `SetAltmerCrisisState(NONE)` |
| P7 | Trinimac: revived dead 2301, added 3122, 3 curated books (records by Codex) |
| P5 | Xarxes `RECORD_KEPT` 3120 dawn cadence |
| P4 | Magnus `APERTURE_KEPT` 3121 + graded (non-patron) sleep gate |
| P15 | Book re-read credit after 30 days — books were a one-shot harvest |
| P10 | Post-Champion "Long Devotion" marks + the **all-race** silent-re-climb fix |
| P8 | Syrabane's 11 likes/dislikes rows |
| P16 | Craft reweighting (xarxes 331, auri-el 313) |
| P12 | Distinctiveness: 3 edits only, after the respec cut it down |
| P9 | Syrabane: 4 signals wired, 3111 retired-not-wired with reasons |
| P2 | Substrate headroom (`HighThreshold` 60), feed variety, per-source voice |
| P18 | Dawn act moved to the spine; Auri-El's free +2.0/day removed |
| P14 | The Ordered Focus practice token |
| P11 | Recurring ambient layer + the 12 Altmer MESG records (2026-08-04, later session) |

## OPEN — player-facing copy needs the owner's pass

Everything below is **my draft**, written to keep momentum. None of it has been through the
`pdv-player-copy` skill or a voice-conformance check.

**P11 ambient records — NOT open, already authored.** `handoff/PDV_Altmer_P11_NotificationCopy_2026-08-04.md`
is the string source: manifest-anchored, player-second-person, under the 60-character target, with
its own reasoning per deity. All twelve records carry that copy verbatim, and the EditorIDs are the
ones that packet specified. It is now consumed — the wire-in checklist at its end is done.

Each line exists TWICE — in the MESG record and as the fallback string in the manager's
`ShowChampionAmbientForDeity`. The fallback only shows if a property comes back None, so editing
the record alone is enough for normal play; edit both to keep them honest.

**Book of Days heritage lines** — `GetAltmerHeritageSourceLine`, `PDV__ManagerQuest.psc`.
**These were re-voiced by the owner on 2026-08-04 and are no longer the draft below**; the list is
kept only as the record of what the draft said. Live wording is in the source.
- "You met the dawn under open sky, as the ancestral order asks."
- "You kept the dawn rite at the shrine, as the ancestors kept it."
- "An Aldmeri dream settles your ancestral inheritance."  *(pre-existing, relocated)*
- "Magicka bound into lawful form; the discipline holds."
- "Ordered craft at the forge, in the manner set down for you."
- "Ordered study, and the inheritance sits a little straighter."
- "A school mastered further, in the ancestral discipline."
- "A heritage text read closely; the line is remembered."
- "Orthodoxy upheld at cost, and the ancestral order holds."  *(default arm)*

**Signal surfacing** — headline + body pairs:
- Magnus: "The design holds" / "marks magicka bound into lawful form."
- Trinimac: "Trinimac remembered" / "The champion's name is spoken as it was, before the defilement."
- Trinimac: "Civilization held" / "marks a foe of the elven project put down."
- Syrabane: "The sickness lifts" / "marks a curse turned aside before it took root."
- Syrabane: "The ward holds" / "marks hostile magic stopped before it landed."
- Syrabane: "Survived the arcane" / "marks a mage outlasted when the odds were bad."
- Syrabane: "The ward learned" / "Containment is the first art the apprentice is trusted with."

**Long Devotion (P10):** `"<Deity> marks another season of unbroken devotion."`

**Item name (ESP `0716E4`):** **"Ordered Focus"** — and its **mesh is a placeholder**, vanilla
`Dungeons\Mines\Ore\IngotMoonstone.nif`. Moonstone is the elven metal so it reads defensibly, but
it is a reused ingot; the Dunmer equivalent got a bespoke NIF
(`PDV\Clutter\PDV_DunmerAncestralUrn.nif`). Worth commissioning one if the token lands well.

**Item name (ESP `0716E4`) reads `Ancestral Focus` in the plugin**, not "Ordered Focus" as recorded
above. One of the two is wrong; the ESP is what ships.

**P11 runtime proof is open.** Nothing about the ambient layer has been seen in game. The sequence:
reach Champion with a patron, sleep 4 days -> one notification; 1 more day -> none; 4 more -> the
other variant (or the same one again if that deity has no Long Devotion mark yet). Separately, an
Altmer at the top heritage band should see the exemplar line on the same 4-day cadence, and the
quiet line once on the way down.

## Remaining packets

**P17 — cadence sizing.** Deliberately last. **Do not tune blind** — it needs a real save played to
Champion. Over-tuning shows up as "the cap is always full and nothing feels earned", which no gate
catches.

## Other open items for the owner

- **P10's decay-floor change is the only edit touching every race.** It is gated on a per-deity
  `MarkHigh` ratchet, but that gate *is* the safety argument. Regression test: a Nord Kyne Champion
  with `MarkHigh == 0` must still floor at 50 and still lose T3 on idle.
- **3111 `APPRENTICE_AID`** is `retired-not-wired` in `tools/pdv_reserved_signals.json`. Confirm or
  overrule. Held loosely — the "no source exists" conclusion was wrong once already (wards).
- **Breton/Magnus overlay stacking** is logged as `PDV_V2_Backlog.md` §9b. A Breton out-earns an
  Altmer for Magnus roughly 2:1 because origin overlays stack. Invisible at current tuning.
- **Five files in the working tree are NOT mine** — `PDV_RaceDesign_Khajiit.md`,
  `PDV_PreBetaRaceGateLedger.md`, `PDV_SubstratePacingContracts.json`, `pdv_prisma_ui_audit.mjs`,
  `pdv_substrate_pacing_audit.mjs`. Left untouched. Find out whose they are before committing.

## Commit state — read before committing

Commits `69bf417b` and `817dd39b` cover P13/P1/P3/P6/P7/P5/P4/P15/P10/P8/P16/P12/P9.
`6af69e2a` (2026-08-04, Codex) covers **P2, P18 and P14**.
**Only P11 is uncommitted**, in two files: `live-source/Scripts/Source/PDV__ManagerQuest.psc` and
`tools/pdv_prisma_ui_audit.mjs` (plus this handoff). Stage deliberately, file by file — do **not**
`commit -a`.

On the five files listed above as "not mine": `pdv_prisma_ui_audit.mjs` now also carries MY changes
(the two assertions reworked for the P2 refactor and for the copy-pinning problem), so it is a
SHARED file — do not revert it wholesale to resolve the Khajiit author's half. The other four
(`PDV_RaceDesign_Khajiit.md`, `PDV_PreBetaRaceGateLedger.md`, `PDV_SubstratePacingContracts.json`,
`pdv_substrate_pacing_audit.mjs`) remain untouched by me.

**The ESP is not git-tracked**, so no record work appears in any diff — three new FormLists, the new
MISC, every VMAD binding, and the Syrabane stance repair exist only in the live plugin and the
snapshots. `tools/pdv_snapshot_live.mjs` is the rollback mechanism.

## Traps found this session — all now in AGENTS.md and memory

1. **An in-place write silently reverted an earlier one.** P1's 10 stance properties were gone two
   packets later; everything built on them was scoring 0.0. **The only tell was file size** — an
   additive edit made the plugin *smaller*. Probable trigger: the houseCARL instance was switched
   away and back in between. **Re-verify earlier records after every later write.**
2. **A gate's verdict is its exit code.** Piping a gate through `grep` returns grep's status and
   discards the FAIL. A packet was signed off this way while `sourceFill` was RED.
3. **houseCARL's instance is global and persisted.** `Devotion.esp` exists in both Anvil and
   ARR 2.5, so a wrong-instance read returns a different, older record set instead of erroring.
4. **`REQ_` on a `Skyrim.esm` FormID is a RENAMED vanilla record.** A null result from one EditorID
   stem is not evidence of absence — this produced a wrong "no vanilla ward tomes exist" claim.
5. **`housecarl_diff_record` misses ADDED list elements** — reports `complete: true, delta_count: 0`
   for a record that gained 10 properties. Use it for "what was retuned", never "what was added".
6. **Comments are scanned as code.** Writing an illustrative `SIGNAL_*` or deity-dot-constant
   example in a comment fails `pdv_verify` / the parity gate. Happened twice.
7. **`live-source/` and the MO2 tree are separate directories**, not a junction. The compiler and
   verifier read MO2; an edit made only in the repo mirror passes a gate that never saw it.
8. **Never pin player-facing prose in a gate.** Two of the Prisma UI audit's assertions matched an
   exact sentence in the source. A copy edit that changed nothing about behaviour turned the gate
   red; the P2 refactor did the same earlier the same day. Both now assert the STRUCTURE — the arm
   exists, it returns a non-empty line, the entry is unpinned and setup-quiet-respecting — and are
   negative-tested in both directions. A gate that reds on a wording change trains people to
   ignore it. (2026-08-04)
9. **`Devotion.esp` changed size (+2 bytes) during a window in which only READ calls ran** — a
   `pdv_snapshot_live --records` fingerprint pass plus three read-only houseCARL queries. Cause not
   established; every record checked afterwards was intact (P1's 14 Syrabane properties, P14's
   MISC). Flagged rather than explained: if you see it again, that is a second data point. The
   `--records` fingerprint pass itself never finished (~15 min, killed); a plain snapshot took
   seconds, and the file-level snapshot is the actual rollback. (2026-08-04)
