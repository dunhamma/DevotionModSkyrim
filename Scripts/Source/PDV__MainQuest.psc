Scriptname PDV__MainQuest extends Quest

; ──────────────────────────────────────────────────────────────────────────
; PDV bootstrap quest. RunOnce + Start Game Enabled. Stage fragments handle
; one-shot setup (initial defaults, version migration, sub-quest startup);
; this script carries any helpers the fragments call.
;
; Currently empty of behavior — structure in place for future bootstrap
; work. When stage fragments are added in CK, they auto-generate a
; companion PDV_QF_MainQuest script. Stage fragment logic lives there.
; Runtime logic does NOT live here OR in the QF script — runtime goes in
; PDV__ManagerQuest.
;
; Created 2026-05-09 — see Claude.md Decisions Log "Bootstrap / Manager
; quest split".
; ──────────────────────────────────────────────────────────────────────────

Event OnInit()
    Debug.Trace("[PDV] MainQuest (boot) initialized.")
EndEvent
