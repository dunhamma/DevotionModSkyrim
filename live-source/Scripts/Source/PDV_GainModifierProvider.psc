Scriptname PDV_GainModifierProvider extends Quest

; Gain-modifier provider base (ADR Option A, PDV_2_0_ProviderSeam_ExtractionSpec).
;
; WHY THIS EXISTS. The piety gain pipeline lives in LEDGER, but the factors that scale a gain
; are owned by other modules: ORIGIN knows the Orc life-mode and Imperial vampire-halt factors,
; DAEDRIC knows the stigma factor. Before this seam LEDGER reached BACK through the manager by
; name (Manager.GetOrcLifeModeGainMultiplier and friends), which made the ledger depend on the
; very modules that are supposed to depend on it. This base inverts that into a one-way pull:
; LEDGER loops a list of base-typed providers and never names a concrete module.
;
; A provider returns 1.0 -- the identity factor -- for any phase it does not care about, so a
; module that contributes nothing is silently harmless.
;
; PHASES. The gain scalars are consumed at THREE sites in LEDGER, not two: award time, dawn
; consolidation, and decay. Decay was missing from the original spec; routing it through the
; same providers is what keeps one scalar sourced from one place instead of drifting between an
; award-time value and a decay-time one.

; PHASE constants live on PDV__ManagerQuest (PHASE_PER_EVENT / PHASE_AT_DAWN / PHASE_DECAY).
; They are NOT declared here: Papyrus cannot read a property off a type, so a consumer would
; need an instance anyway, and duplicating them would let the two copies drift.

; Override in a module that owns a gain factor. Return 1.0 for phases you do not scale.
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    return 1.0
EndFunction
