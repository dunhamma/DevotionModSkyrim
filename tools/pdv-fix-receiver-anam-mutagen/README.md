# Receiver `ANAM` fix (issue #17 — Craft Item / cooking CTD)

## What this fixes

The Story Manager receiver quests produced by the generic-faucet receiver-author
pass are **missing the QUST `ANAM` (Next Alias ID) subrecord** that the Creation Kit
writes for every quest. The working, CK-authored `PDV__SM_KillActor` receiver has
`ANAM = 0`; the batch-authored receivers (`PDV__SM_CraftItem`, `NewVoicePower`,
`IncreaseSkill`, `ChangeLocation`, `PickLock`, `Trespass`, `AssaultActor`,
`AddToPlayer`) do not.

When the Story Manager starts one of these malformed quests to deliver an event, the
engine reads uninitialised alias bookkeeping and dereferences an invalid handle
(`RAX = RDX = 0xFFFFFFFF`) while marshalling the event arguments → **CTD**. The
`Craft Item` receiver is the one players hit first because cooking and tempering are
common early actions, so it surfaced as a cooking crash.

Fault: `EXCEPTION_ACCESS_VIOLATION at SkyrimSE.exe+04CF782`, stack through
`StoryEventArguments<Ref,Location,Form,…>` → `VirtualMachine::Func39/36` →
`BSTEventSink<TESQuestInitEvent>::Handle` → `BGSStoryTeller`.

## The fix

Add `ANAM = 0x00000000` to each receiver quest so the record is well-formed, matching
`PDV__SM_KillActor`. Two interchangeable ways:

### Option A — pure Node patcher (no .NET needed), recommended

Surgical: inserts only the missing `ANAM` subrecord (after the `NEXT` marker) and
fixes the record/GRUP sizes. Does not touch anything else.

```
node tools/pdv_fix_receiver_anam.mjs "<path-to-Devotion.esp>" --out "<path-to-Devotion.esp.fixed>"
# or a dry run first:
node tools/pdv_fix_receiver_anam.mjs "<path-to-Devotion.esp>" --dry
```

### Option B — Mutagen (this project)

Re-serialises the whole plugin through Mutagen, which always emits `ANAM`.

```
dotnet run --project tools/pdv-fix-receiver-anam-mutagen -- "<path-to-Devotion.esp>" "<out.esp>"
```

Pin the `Mutagen.Bethesda.Skyrim` version in the `.csproj` to whatever the rest of the
project uses.

## Verify

1. Open the patched plugin in xEdit/SSEEdit → each `PDV__SM_*` quest now shows
   **ANAM - Next Alias ID: 000000**.
2. In-game (a save is fine): **cook a grilled leek** and **temper an item** at a
   grindstone/armor bench. No CTD = fixed.

## Also fix it at the source

The external generic-faucet receiver-author tool (`pdv-phase20-p2-receiver-author`,
not checked into this repo) must set `Quest.NextAliasID = 0` on every quest it
authors so re-runs don't reintroduce the missing `ANAM`. See the note added to
`references/authoring/PDV_FaucetDetection_CKChecklist.md`.
