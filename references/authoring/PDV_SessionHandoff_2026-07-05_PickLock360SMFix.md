# PDV Session Handoff -- Event 360 (pick-owned-lock) SM-tree fix

**Date:** 2026-07-05
**Context:** Mega Packet Sitting 1, Section E1 (Imperial day-to-day signal sweep). Found
during the E1 transgression pass -- see `PDV_MegaPacket_OneOh_2026-07-02.md` E1.
**Proof boundary:** machine-verified (readback + check_errors) DONE; **in-game route proof PENDING**.

---

## Bug

PDV event `360` (pick-owned-lock) never fired in-game. Picking an owned lock produced no
EventBus `event 360 delta` and **not even** the `HandleStoryPickLock skipped: lock is not owned`
Trace(3) -- i.e. `HandleStoryPickLock` was never called. The Story Manager LockPick event was
not reaching PDV. (Detection is irrelevant: the handler only checks `IsPlayerRef` +
`IsOwnedReference`, no crime gate.)

## Root cause (Devotion.esp SM tree)

The receiver script (`PDV__SM_PickLock.psc` -> `PDV_Router.HandleStoryPickLock`), the receiver
quest (`PDV__SM_PickLock` 0714A8), and the quest node (`PDV__SM_PickLockNode` 0714AF, SharesEvent,
1 quest) were all correct. The defect was the **event-node parenting**:

- `PDV__SM_PickLockNode` (0714AF) was parented DIRECTLY to the **shared vanilla** LockPick event
  node `05BD7B:Skyrim.esm` (Type=LockPick).
- Every WORKING transgression uses a **dedicated PDV event node**: e.g. `PDV__SM_TrespassNode`
  (0714B2) -> `PDV__SM_TrespassEvent` (0714B1, Type=TrespassActorEvent, parent = SM root
  00005B). PickLock was the ONLY transgression reusing a vanilla shared node -- and the only one
  that never fired. In this load order the shared vanilla LockPick node does not dispatch to
  PDV's added sibling quest node.

## Fix applied (in-place, Devotion.esp -- via houseCARL)

Mirrored the proven Trespass wiring:

1. Created dedicated event node **`PDV__SM_PickLockEvent` = 071618:Devotion.esp** --
   StoryManagerEventNode, `Type=LockPick`, `Parent=00005B:Skyrim.esm` (SM root), `Flags=0`,
   `MaxConcurrentQuests=0`, no conditions, null PreviousSibling. Structural match to the working
   `PDV__SM_TrespassEvent` (0714B1).
2. Re-parented **`PDV__SM_PickLockNode` (0714AF)** `Parent`: `05BD7B:Skyrim.esm` ->
   `071618:Devotion.esp`. Still SharesEvent, still routes to `PDV__SM_PickLock` (0714A8).

Resulting tree mirrors Trespass:
`PickLockEvent (LockPick, Root) -> PickLockNode (SharesEvent) -> PDV__SM_PickLock quest -> receiver`.

No Papyrus change; no recompile. Pure ESP SM-tree data.

## Machine verification (DONE)

- `check_errors` on Devotion.esp: 0 missing masters, 0 unscannable, **0 new dangling refs**
  (the 59 dangling are the pre-existing PlayerRef `000014` artifact -- flags vanilla `CW01A` too --
  none touch 071618 / 0714AF / 0714A8).
- New node 071618 read back: Type=LockPick, Parent=Root, Flags=0, MaxConcurrentQuests=0.
- Receiver quest 0714A8 untouched: `Flags=0` (no StartGameEnabled -- correct for an SM-driven
  quest, same as Trespass), VMAD intact. **No SGE/SEQ regression** (SM-event quests are not in the
  `.seq`; the `.seq` file was not touched).
- Backup: `Backups\picklock-sm-fix\Devotion.esp.pre-picklock-20260705-164505.bak`.
- New live FormID **071618** in Devotion.esp -- record alongside the other `0716xx` SM records so a
  future FormList/manifest pass doesn't treat it as a stray.

## In-game proof (PENDING -- fill on test)

Setup: **full exe relaunch** so the edited Devotion.esp loads (plugins load only at launch, not at
save-load), then **load the existing Imperial save** -- SM node trees are read live from the plugin,
NOT serialized into the save, and the receiver quest never started, so there is no baked state to
clear. A brand-new character is NOT required. DebugLevel 3. Pick an **owned** lock. (Only if it
still misfires on the existing save is a clean new-character run worth doing to rule out save state.)

- Expect: `[PDV] EventBus: <Zenithar> event 360 delta -0.5` (Imperial reads it as a Divine dislike).
- Also acceptable diagnostic if it still misfires: the `HandleStoryPickLock skipped: lock is not
  owned` Trace(3) on an UNowned lock proves the event now reaches PDV.

RESULT (2026-07-05, post-relaunch session, Papyrus.0.log opened 05:23:43PM > 16:45 fix write):
**FAIL -- 360 still does not fire.** Picked an owned lock inside a house; log shows NO `event 360`,
NO `HandleStoryPickLock`, NO skip-trace anywhere. Control event **`362` (steal-item) fired cleanly**
same session (4 deities), and `344`/`345` also fired -- so SM dedicated-node dispatch, router, and
EventBus are all healthy. Fix confirmed intact + uncontested via readback (Devotion.esp sole toucher
of 0714AF and 071618).

### Reinterpretation -- SM route is DEAD for LockPick (not a wiring bug)
Both wirings failed: the ORIGINAL config already had the quest node under the (first) vanilla
LockPick event node with SharesEvent -- if the engine raised a LockPick event and delivered it to
that vanilla node, the original quest node would have received it. It did not. The dedicated-node
config also receives nothing. Two independent correct configs -> zero dispatch, with a working
control (362) in the same session => **the Skyrim "Lock Pick" Story Manager event is not raised by
the engine in this SKSE/mod setup.** The dedicated-node correlation with Trespass/Assault was a red
herring (their events are actually emitted). No SM wiring can fix an unemitted event.

The SM records (071618 event node, 0714AF quest node, 0714A8 quest, `PDV__SM_PickLock.psc`) are now
harmless but vestigial. Keep them (correct-by-pattern, no cost) OR remove later; do NOT keep
attempting SM variations.

### Fallback -- BUILT 2026-07-05 (compile PASS 0/0; in-game retest PENDING)
Menu-hook detection in `PDV_PlayerEvents.psc` (live MO2 source), fresh `.pex` deployed 17:43:
1. `RegisterForMenu("Lockpicking Menu")` added to `RegisterForPlayerEvents()` (called from both
   `OnInit` and `OnPlayerLoadGame`, so registrations survive game loads per SKSE requirement).
   Menu-name string verified against the shipped SKSE `UI.psc` valid-menu list.
2. New `Event OnMenuOpen`: captures `Game.GetCurrentCrosshairRef()` + its `IsLocked()` state into
   script vars (`PDV_LockpickMenuTargetRef` / `PDV_LockpickMenuTargetWasLocked`).
3. `OnMenuClose` extended (existing RaceSex handler untouched) -> `ResolveLockpickMenuClose()`:
   clears capture state, then routes `EVT_PICK_OWNED_LOCK` (360) via `RouteGenericAction` ->
   `PDV_EventBusService.RouteAction` (same proven path as the 365 fallback) IF the captured ref
   went locked->unlocked AND `IsOwnedLockReference()` passes.
4. `IsOwnedLockReference`: ref-level `GetActorOwner`/`GetFactionOwner` (mirrors the router's
   `IsOwnedReference`) PLUS a parent-cell ownership fallback -- house doors/chests often carry no
   per-ref owner and inherit the cell's owner (how the crime system reads them). Skip traces at
   Trace(3): "no locked target captured" / "target still locked" / "lock is not owned"; success
   logs Trace(2) "Owned lock picked; event 360 routed."

Concurrency note: built alongside a parallel session's 365 OnSpellCast rework in the SAME file;
one clobber was caught and re-applied on the fresh copy; final file verified to hold BOTH changes
before compile.

RETEST (no new game needed): full exe relaunch (new .pex loads at launch), LOAD the existing
Imperial save (OnPlayerLoadGame re-registers the menu hook), DebugLevel 3, pick an OWNED lock ->
expect `[PDV] EventBus: Zenithar event 360 delta -0.5` (+ the other Divine dislike rows per CSV).
Negative probe: pick an UNowned lock -> `[PDV] PlayerEvents: Lockpick menu closed: lock is not
owned.` proves the hook fires and the gate holds.

RETEST RESULT: **PASS 2026-07-05 05:53PM** (existing Imperial save, exe relaunch). Picked an owned
door lock; log shows the full chain, CSV-exact:
`[PDV] EventBus: Zenithar event 360 delta -0.500000` ->
`RouteAction complete: event 360, scored deities 1` ->
`[PDV] PlayerEvents: Owned lock picked; event 360 routed.`
Load-time re-registration confirmed working (OnPlayerLoadGame hooks refreshed at load). Event 360
is CLOSED -- the E1 owned-lock row is provable via this route from now on.

## Related

- Pattern reference: [[housecarl-headless-ck-via-mutagen]] (in-place lane on Devotion.esp).
- Sibling wiring already proven: Trespass (361), AssaultActor (364). Steal-item (362) wired
  separately (see `steal-item-sm-wiring-acquiretype`), also pending in-game route proof in E1/E3.
