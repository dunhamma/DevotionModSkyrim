## PDV_MCM VMAD Consolidation Checklist

Purpose: remove the duplicate `PDV_MCM` script attachments on the
`PDV_MCM` quest record in `PlayerDevotion_Framework.esp` so strict verifier
runs stop carrying the known duplicate-VMAD warning.

This is a manual xEdit/CK cleanup packet. The current live warning shape is:

- `PDV_MCM` has `3` same-name `PDV_MCM` VMAD entries
- property groups are split as:
  - `#0 = [PDV_FLST_AllDeities, PDV_GLO_ActiveDeityIndex, PDV_GLO_ActivePiety, PDV_GLO_ActiveTier, PDV_GLO_DebugLevel, PDV_GLO_PatronDeity, PDV_Manager]`
  - `#1 = [PDV_CurseStateService, PDV_FLST_DaedricPaths_All, PDV_FLST_RepTracks_All, PDV_FLST_SacredPlaces_All, PDV_FLST_StateTracks_All, PDV_FLST_Substrates_All]`
  - `#2 = [PDV_EventBusService]`

The canonical end state is:

- exactly `1` `PDV_MCM` script attachment on the `PDV_MCM` quest record
- that single attachment owns all `14` required properties:
  - `PDV_Manager`
  - `PDV_FLST_AllDeities`
  - `PDV_GLO_ActivePiety`
  - `PDV_GLO_ActiveTier`
  - `PDV_GLO_ActiveDeityIndex`
  - `PDV_GLO_PatronDeity`
  - `PDV_GLO_DebugLevel`
  - `PDV_FLST_RepTracks_All`
  - `PDV_FLST_StateTracks_All`
  - `PDV_FLST_Substrates_All`
  - `PDV_FLST_SacredPlaces_All`
  - `PDV_FLST_DaedricPaths_All`
  - `PDV_CurseStateService`
  - `PDV_EventBusService`

Reference artifact:

- `D:\Wabbajack\modlists\Anvil\mods\Devotion\PDV_VmadConsolidationOverlay.esp`
- source manifest: `references\authoring\PDV_VmadConsolidation.manifest.json`

Use that overlay only as a reference/check artifact. It is not the desired
steady-state runtime answer if the goal is to remove the warning from the
framework record itself.

### Recommended xEdit Packet

1. Launch xEdit through MO2 on the `Devotion Dev` profile.
2. Load `PlayerDevotion_Framework.esp`.
3. Navigate to:
   - `QUST -> PDV_MCM`
   - `VMAD - Virtual Machine Adapter`
   - `Scripts`
4. Confirm there are `3` `PDV_MCM` entries.
5. Pick the first `PDV_MCM` entry as the canonical survivor.
6. On that survivor, add any missing properties so it contains the full
   14-property union listed above.
7. Copy property values exactly from the existing split entries:
   - from current `#1`, copy:
     - `PDV_CurseStateService`
     - `PDV_FLST_DaedricPaths_All`
     - `PDV_FLST_RepTracks_All`
     - `PDV_FLST_SacredPlaces_All`
     - `PDV_FLST_StateTracks_All`
     - `PDV_FLST_Substrates_All`
   - from current `#2`, copy:
     - `PDV_EventBusService`
8. Verify the surviving `PDV_MCM` attachment points to:
   - `PDV_Manager -> PDV__ManagerQuest`
   - `PDV_FLST_AllDeities -> PDV_FLST_AllDeities`
   - `PDV_GLO_ActivePiety -> PDV_GLO_ActivePiety`
   - `PDV_GLO_ActiveTier -> PDV_GLO_ActiveTier`
   - `PDV_GLO_ActiveDeityIndex -> PDV_GLO_ActiveDeityIndex`
   - `PDV_GLO_PatronDeity -> PDV_GLO_PatronDeity`
   - `PDV_GLO_DebugLevel -> PDV_GLO_DebugLevel`
   - `PDV_FLST_RepTracks_All -> PDV_FLST_RepTracks_All`
   - `PDV_FLST_StateTracks_All -> PDV_FLST_StateTracks_All`
   - `PDV_FLST_Substrates_All -> PDV_FLST_Substrates_All`
   - `PDV_FLST_SacredPlaces_All -> PDV_FLST_SacredPlaces_All`
   - `PDV_FLST_DaedricPaths_All -> PDV_FLST_DaedricPaths_All`
   - `PDV_CurseStateService -> PDV_CurseState`
   - `PDV_EventBusService -> PDV_EventBus`
9. Delete the extra duplicate `PDV_MCM` script entries after the canonical
   one has the full property union.
10. Save `PlayerDevotion_Framework.esp`.

### CK Variant

If CK presents multiple `PDV_MCM` script rows on the quest script pane:

1. Keep one `PDV_MCM` row only.
2. Re-enter the missing properties from the other duplicate rows onto the
   surviving row.
3. Remove the duplicate same-name rows.
4. Save the framework ESP.

xEdit is preferred because the duplicate shape is easier to audit there.

### Verification

After the merge-back:

```text
node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

Expected result:

- `PDV_MCM script attachments` warning disappears
- only the stale `SEQ` freshness warning remains unless SEQ is refreshed too

### Safety Notes

- Do not remove `PDV_EventBusService` or `PDV_CurseStateService`; both are
  currently used by the hardened MCM/runtime debug surface.
- Do not leave `PDV_VmadConsolidationOverlay.esp` active as a permanent
  substitute for merge-back if the goal is a warning-free framework baseline.
- Re-test the `PDV_MCM` Status and Debug pages after consolidation to confirm
  manager access, piety map display, structural map display, and debug actions
  still work.
