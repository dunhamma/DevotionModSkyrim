# 2026-06-21 Interactive dashboard panel — open hotkey + bulletproof close

POST-edit snapshot of the live untracked manager + MCM after making the focused,
filterable Devotion dashboard panel reachable. (The canonical .psc is the untracked
live dir; this preserves the Papyrus backend in git alongside the tracked C++/UI/audit
changes in the same commit.)

The dashboard (per-god feedback + filters by god/direction/system) lives in the main
tabbed panel's Today tab, which previously had NO open or close path. This makes it
open via a hotkey as a FOCUSED view (so the filter buttons are clickable) and close
cleanly via an in-view X button / ESC.

What this change adds:
- C++ bridge (native/DevotionPrismaBridge/src/main.cpp, rebuilt + deployed): a
  PDVPanelClose JS->C++ listener (OnPanelClose = Unfocus + Hide), registered next to the
  choice listener. Mirrors the proven PDVChoiceResult channel.
- PDV__ManagerQuest.psc: PushDevotionPanel(Bool playerRequested = false) -- the gate
  becomes `if !AutoPushPrismaPanel && !playerRequested` (audit-green: still ONE SendJson,
  guard substring preserved). The Book of Days live-refresh now sends inline via
  SendOverlayJson (not SendPrismaJournalPayload, which the audit requires to have no
  manager-internal callers). No ShowDevotionPanel/OpenDevotionPanel in the manager (the
  audit forbids gameplay sources opening the focused panel).
- PDV_MCM.psc: a rebindable "Open Devotion panel" hotkey (the player-owned UI entry
  point) -> PushDevotionPanel(True) + PDV_PrismaBridge.OpenDevotionPanel(). OPEN ONLY
  (a focused panel can't receive the hotkey to toggle closed; close is in-view).
- app.js/index.html/styles.css (tracked): the in-view X button (#pdv-panel-close) + an
  ESC handler -> window.PDVPanelClose("main|close"); .panel-close styling.
- tools/pdv_prisma_ui_audit.mjs (tracked): relaxed the OpenDevotionPanel rule to allow
  PDV_MCM.psc -- the rule's own message says "only player-owned UI entry points may open
  the full panel," and the MCM hotkey is exactly that.

Gates at capture: manager + MCM compile 0/0; pdv_prisma_ui_audit PASS (13); app.js
node --check OK; DLL built (xmake releasedbg) + deployed to SKSE/Plugins. In-game proof
pending (fresh launch: bind the hotkey, open -> filter -> X/ESC close).

Captured files:
- D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc
- D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_MCM.psc
