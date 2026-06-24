# Disable V1 Voiced Dialogue (Codex Handoff, 2026-06-25) -- queue B / release-prep B18

## Goal

V1 ships NO voiced NPC dialogue (`PDV_Architecture_v3.md` Section 21.3 voiced-content
non-goal; `PDV_TargetEndStates_1.0.md` Phase 18A/B closeout build action). The
CK-authored Nord recognition dialogue chains (Froki, Heimskr, Andurs, Aela) plus the
Phase 11 Arngeir/Kyne recognition pilot are live in the ship ESP and MUST be
removed/disabled from the V1 release `Devotion.esp`. The proven branch/topic/INFO
pattern is RETAINED as the V2 specification -- it is parked, not deleted, in
`references/authoring/PDV_Phase18_DialogueDrafts.md`,
`PDV_RecognitionDialogueScalePacket.md`, and `PDV_V2_Backlog.md`.

This is a record-removal-from-ESP task, not a Papyrus task. No `.psc` edits.

## Verify-current-state FIRST (grep before authoring)

Multiple items were found already-built / already-correct this session; do NOT trust
this doc's enumeration blindly -- re-query the live ESP before removing anything, because
FormIDs drift if the ESP was re-saved. Re-run the houseCARL scans below and diff against
the record list. Authored as of 2026-06-25 against the live `Devotion.esp`.

### Re-confirm scan (houseCARL, MO2 Anvil instance)

    housecarl_cross_plugin_query plugins=[Devotion.esp] type=DLBR   (expect 5)
    housecarl_cross_plugin_query plugins=[Devotion.esp] type=DIAL   (expect 5)
    housecarl_cross_plugin_query plugins=[Devotion.esp] type=INFO   (expect 5 DialogResponses, all unnamed)
    housecarl_cross_plugin_query plugins=[Devotion.esp] editorid_contains=Dlog   (expect 0 -- stubs are draft-only)

## The exact record list to REMOVE (15 records: 5 DLBR + 5 DIAL + 5 INFO)

All are PDV-OWNED records authored directly into `Devotion.esp` (override_depth=1,
defining plugin = Devotion.esp). The 5 unnamed INFOs (DialogResponses) are the spoken
NPC responses -- prompts/speakers below confirm each is a recognition response, NOT
generic status dialogue.

Chain 1 -- Phase 11 Arngeir/Kyne recognition pilot (privilege subsystem 9.4, V2-deferred):
  - DLBR 0704F2:Devotion.esp  PDV_DIAL_Phase11ArngeirKyneRecognitionBranch
  - DIAL 0704F3:Devotion.esp  PDV_DIAL_Phase11ArngeirKyneRecognitionTopic  ("Has Kyne marked my path?")
  - INFO 0704F4:Devotion.esp  (unnamed) Speaker 02C6C7 Arngeir  Prompt "Has Kyne marked my path?"

Chain 2 -- Froki / Kyne Champion:
  - DLBR 070A89:Devotion.esp  PDV_DIAL_Nord_Froki_KyneChampionBranch
  - DIAL 070A8A:Devotion.esp  PDV_TIF_Nord_Froki_KyneChampion
  - INFO 070A8B:Devotion.esp  (unnamed) Speaker 0185F6 Froki  Prompt "I sleep where Kyne sleeps. I hunt where she hunts."

Chain 3 -- Heimskr / Talos Champion:
  - DLBR 070A8C:Devotion.esp  PDV_DIAL_Nord_Heimskr_TalosChampionBranch
  - DIAL 070A8D:Devotion.esp  PDV_TIF_Nord_Heimskr_TalosChampion
  - INFO 070A8E:Devotion.esp  (unnamed) Speaker 013BAC Heimskr  Prompt "The old breath is mine to carry. Tell me what is needed."

Chain 4 -- Andurs / broad death-rite:
  - DLBR 070FF0:Devotion.esp  PDV_DIAL_Nord_Andurs_DeathRiteBranch
  - DIAL 070FF1:Devotion.esp  PDV_TIF_Nord_Andurs_DeathRite
  - INFO 070FF2:Devotion.esp  (unnamed) Speaker 013BA8 Andurs  Prompt "I keep the rites. What is owed the dead here?"

Chain 5 -- Aela / Hircine tension:
  - DLBR 070FF3:Devotion.esp  PDV_DIAL_Nord_Aela_HircineTensionBranch
  - DIAL 070FF4:Devotion.esp  PDV_TIF_Nord_Aela_HircineTension
  - INFO 070FF5:Devotion.esp  (unnamed) Speaker 01A696 Aela  Prompt "The hunt pulls at Sovngarde. What do you see in me?"

All 5 DIAL topics hang off Quest 00C325 (PDV__ManagerQuest). Remove the DIAL/DLBR/INFO
records ONLY; the manager quest itself stays.

## DO-NOT-TOUCH list

- Quest 00C325 PDV__ManagerQuest -- the core manager; it merely HOLDS the dialogue
  branches. Removing it would destroy the whole mod. Only its child dialogue records go.
- MESG 071002 PDV_Msg_Altmer_VampireExiledPath_Recognition -- a non-voiced MESSAGE
  (the only other "Recognition" record); player-facing message box, stays in V1.
- The "4 unnamed INFOs are live Phase 18 Nord status dialogue, never clean them up"
  memory (unnamed-info-records-are-live.md): RECONCILED THIS SESSION. The unnamed INFOs
  in Devotion.esp are NOT a separate generic-status set -- they ARE the recognition
  quartet (Froki/Heimskr/Andurs/Aela) plus Arngeir, proven by matching the
  PDV_Phase18_DialogueDrafts.md prompts/speakers exactly. There is no distinct
  "status dialogue" INFO set to preserve. For V1, Section 21.3 explicitly overrides the
  old "do not touch" framing for these specific records -- they are the voiced records to
  disable. UPDATE that memory after this lands so a future session does not re-add them.
- The 39 PDV_Dlog_*_Recognition stubs: draft-only in the race content manifest /
  PDV_RecognitionDialogueScalePacket.md. They were NEVER CK-authored to the ESP
  (editorid_contains=Dlog returns 0). Nothing to remove; they stay as V2 spec.
- All non-voiced surfaces (Survey, MCM, MESG/Notif toasts, spells/MGEF, books/notes,
  shrine activators, Prisma) -- untouched.

## Disable method

These are records the DEFINING plugin (Devotion.esp) owns, not overrides of a master.
houseCARL's `housecarl_remove_record` only drops a record from a houseCARL-OWNED patch
(it cannot edit Devotion.esp in place -- see housecarl-holds-esp-lock memory), so it is
the WRONG tool for an in-place defining-plugin deletion. Use ONE of:

1. PREFERRED -- xEdit (SSEEdit) on Devotion.esp directly: select each of the 15 records,
   right-click > Remove (physical record removal, NOT "set as Deleted"/ITM stub). Removing
   the DIAL also offers to remove its child INFOs; still verify all 15 are gone. Save.
   Because the DLBR/DIAL/INFO are self-contained PDV records with no external masters
   referencing them, removal leaves no dangling pointers (the holder quest 00C325 does
   not store the branches as properties; the branches reference the quest, not vice
   versa -- one-way link, safe to drop).
2. ALTERNATIVE -- CK: open Devotion.esp as active, delete the 5 DialogBranch records
   (Quest > Player Dialogue / Misc tab), which cascades the topic+INFO children, then
   save. CK delete on PDV-owned records is safe since nothing external links them.

Do NOT use IsDeleted/deleted-stub flags (dirty edit). Physical removal only.

After removal, re-run the re-confirm scan: all four queries must return 0 for the
recognition chains (DLBR/DIAL/INFO counts drop to 0; Dlog stays 0).

## Serialize note

This does NOT touch PDV__ManagerQuest.psc or any `.psc`, so no Papyrus serialization
concern. BUT it writes Devotion.esp in place -- serialize the ESP write with any
concurrent ESP author (Codex, houseCARL overlay, open CK/xEdit). Confirm no Skyrim / CK /
xEdit holds the lock first (housecarl-holds-esp-lock). Back up Devotion.esp before the
xEdit/CK pass.

## Verify

After the ESP edit (no compile needed for record-removal-only, but run the suite to
prove nothing downstream referenced the removed FormIDs):

1. pdv_compile.mjs            -> 0 errors / 0 warnings (no .psc touched; sanity)
2. pdv_verify.mjs             -> FAIL=0
3. pdv_signal_e2e_gate.mjs    -> 0 RED
4. pdv_integrity_harness.mjs  -> PASS

If any gate references the removed dialogue records (it should not -- they are voiced V2
records with no piety/signal wiring), treat that as a finding and reconcile the gate, not
re-add the record.

## Post-land doc sync

- Flip the Phase 18A/B "Build action: disable/remove these records from the V1 release
  ESP" line in PDV_TargetEndStates_1.0.md to DONE.
- Update the unnamed-info-records-are-live memory per the DO-NOT-TOUCH reconciliation
  above.
- Note the removal in AGENTS.md release-prep status (do not overwrite AGENTS.md broadly).
