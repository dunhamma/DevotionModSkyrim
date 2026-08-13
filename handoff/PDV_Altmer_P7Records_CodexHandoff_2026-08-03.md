# Codex Handoff — P7 record half: Trinimac curated book sources (2026-08-03)

## TL;DR

Create **one FormList** (`PDV_FLST_P2_AltmerTrinimacSources`) in `Devotion.esp`, fill it with
**3 vanilla BOOK records** on the martial-orthodox axis, and add the matching `sourceProperties`
entry to the P2 receivers manifest. **Records and manifest only — do not touch any `.psc`.**

This is the record half of packet P7 in the Altmer lane plan. The Papyrus half (new signal 3122,
`HandleAltmerTrinimacOrthodoxy`, the EventBus route, the `PlayerEvents` routing arm) is **not
yours** and will be done separately — it depends on P6 landing first.

## Why you can run this in parallel right now

Claude is working **P3** in the same session, which touches `PDV__ManagerQuest.psc` **only** and
writes **no records**. So the ESP is uncontended and yours; the manager is Claude's. Do not cross
that line — parallel edits to `PDV__ManagerQuest.psc` on a stale base have reverted shared work
before (`commit -a` on a stale checkout; always verify your diff is `+N/-0`).

## Before you start — snapshot

```bash
node tools/pdv_snapshot_live.mjs --label P7-records-pre
```

`Devotion.esp` is **not git-tracked** and the houseCARL in-place lane has no undo. This is
mandatory, not optional. Snapshots land in `generated/live-devotion-backups/` (already gitignored;
the repo is public, so nothing in-development gets published).

## Context you need

Trinimac has **zero** curated book sources today. Only four Altmer P2 FormLists exist —
`071055` Auri-El (2 books), `071056` Lorkhan penalties (1), `071057` Magnus (2), `071058` Xarxes
(3). His curated lane is consequently near-dead: `SIGNAL_ALTMER_ORTHODOX_PRESSURE` (2302) fires at
most 3 times per playthrough (piggybacking Xarxes's books) and `SIGNAL_FALLEN_GOD_ORTHODOXY` (2301)
has no award site at all.

Trinimac's theology, for picking books: Auri-El's champion and general, the martial defense of
civilization, pre-Malacath memory, orthodoxy enforced by force. His stance is
`Stance_Altmer = 0` (NATIVE) and `Stance_Orc = 2` (TABOO) — the Orc betrayal memory is live, so
books framing Malacath/Orsimer sympathetically are **wrong** for this list.

## The work

### 1. Choose 3 BOOK records

Enumerate candidates rather than guessing:

```
housecarl_cross_plugin_query type=Book editorid_contains=Book4Rare
housecarl_cross_plugin_query type=Book editorid_contains=Book3Valuable
```

Match the shape of the existing Altmer fills — they are all vanilla `Book4Rare*` /
`Book3Valuable*` lore books from `Skyrim.esm`, one-shot per book form. Pick for the
martial-orthodox / fallen-champion / civilization-defense axis.

**Do not reuse any book already in `071055`, `071057`, or `071058`** — read those three
FormLists first (`housecarl_read_record ... fields=["Items"] depth=2 resolve_names=true`) and
exclude their contents. A book in two lists would double-score.

Record your three picks **with FormIDs and a one-line justification each** in the handoff-back
before filling anything. If you cannot find three defensible candidates, **fill two and say so** —
do not pad the list to hit a number.

### 2. Create and fill the FormList

`housecarl_create_record` a `FormList` with EditorID **`PDV_FLST_P2_AltmerTrinimacSources`** in
`Devotion.esp` (in-place: `target="Devotion.esp"`, `in_place=true`), then add the 3 books.
FormList contents live under the `Items` field.

### 3. Add the manifest entry

`references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` — add a `sourceProperties`
entry matching the exact schema of the four existing Altmer entries (`property`, `race`,
`sourceKinds`, `route`, `acceptedUse`, `rejectedUse`). Route name is
`RouteAltmerTrinimacOrthodoxy` (Claude will author that function later; declaring it here is
correct and expected).

## Verification — this is the claim, not your description of the work

1. `housecarl_read_record <newFormID> fields=["Items"] depth=2 resolve_names=true` → all 3 items
   resolve to real BOOK records. **Paste this output.**
2. Re-read `071055`, `071057`, `071058` and confirm **no overlap** with your picks.
3. `node tools/pdv_ascii_guard.mjs` → clean (the manifest is a tracked JSON).
4. `node tools/pdv_verify.mjs` → **FAIL must be 0.** Current baseline is
   **FAIL 0 / PASS 4119 / WARN 2** (WARNs are SEQ mtime + MO2 profile confirmation, both benign
   and pre-existing). If PASS moves, say by how much and why.
5. Report the plugin **master order** result for `Devotion.esp` per the standing ESP rule.

## Do NOT

- Touch **any** `.psc` file. Not the manager, not `PDV_EventBus`, not `PDV_PlayerEvents`.
- Create the 3122 signal, `HandleAltmerTrinimacOrthodoxy`, or any route function.
- Touch `tools/pdv_verify.mjs` or `tools/pdv_compile.mjs`.
- Place any activator. `PDV_ACTI_Altmer*Signal` / `PDV_REFR_Altmer*Signal` are **QA test harness**,
  never shippable ingress — do not extend that pattern or treat it as world content.
- Delete anything from `tools/pdv_reserved_signals.json`. 2301 stays listed until its award site
  actually exists, which is the Papyrus half.

## Hand back

A short doc in `handoff/` with: the 3 chosen books + FormIDs + why each; the readback output; the
gate results; the master-order result; and anything you found that contradicts this brief. If a
doc you read disagrees with what the ESP actually contains, **the ESP wins** — say so explicitly
rather than reconciling silently. Two live examples from this week: `BC-0236` asserted a
`PRESSURE` stance that does not exist in the enum, and two deity script headers claimed handlers
were "telemetry stubs" years after they were wired.
