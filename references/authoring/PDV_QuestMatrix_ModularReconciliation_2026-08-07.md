# Quest Matrix Modular Reconciliation

Date: 2026-08-07 AEST

## Authority decision

The current source CSVs, not the stale packaged ARR JSON, are the migration
authority. The old packaged file reported 62 watched quests but fails the
current compiler contract: its source resolves to 31 watches and 51 cells.

## Reconciled result

- The 51 active ARR-source cells decompose exactly into eight new per-mod
  channels: Vigilant 32, Unslaad 7, Forgotten City 3, Glenmoril 3, DAc0da 2,
  Ebony Blade Curse 2, Olenveld 1, and Skyrim Extended Cut - Saints and
  Seducers 1.
- The current source contains no rows for CH IMBM Dialogue Addon, Heart of
  Dibella Quest Expansion, Darbalag, Become a Bard, or Bards Reborn. Their old
  watch entries were metadata without reaction cells, so no empty compatibility
  option is created.
- Fourteen Creation Club cells moved from the three optional channels into the
  core matrix: The Cause 3, Ghosts of the Tribunal 2, and Divine Crusader 9.
- Core is now 2,144 cells, 234 quest-stage keys, and 157 watched quests.
- Active PatchHub data is 39 channels after adding eight source-backed channels
  and retiring the three Creation Club channels.
- Global compiled reconciliation passes across core plus all 39 channels with
  2,670 cells and zero duplicate `plugin|FormID|stage|deity` keys.

## Adjudicated duplicate

The new global gate found one pre-existing duplicate in The Rot Below:
Meridia appeared twice at `CJ03Elroy.esp:02DA43|120`. The stronger Hierophant
of Rot/Namira-defeat cell is retained; the lower duplicate Adabelle slay cell is
removed under the standing double-credit rule. The channel now has 17 cells.

## Proof boundary

Tranche merge, compiler, PapyrusUtil shape, decomposition set equality, and
global duplicate gates pass against repository outputs. The live Anvil runtime
matrix is still the previous 2,130/231/154 build, so the signal-floor audit
correctly remains red for runtime JSON drift until the guarded core sync and
compile stage. No runtime, player-surface, semantic, or support proof is claimed.
