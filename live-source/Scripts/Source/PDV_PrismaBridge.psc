Scriptname PDV_PrismaBridge Hidden
{Native bridge between Devotion Papyrus scripts and the Prisma UI SKSE API.}

Bool Function IsAvailable() Global Native
{Returns true when the SKSE bridge has acquired Prisma UI's native API.}

Bool Function OpenDevotionPanel() Global Native
{Creates the Prisma view if needed, then shows and focuses the Devotion panel.}

Bool Function CloseDevotionPanel() Global Native
{Unfocuses and hides the Devotion panel if it has been created.}

Bool Function ToggleDevotionPanel() Global Native
{Shows the panel when hidden, or hides it when visible.}

Bool Function SendJson(String payload) Global Native
{Sends a JSON string to the Devotion Prisma panel.}

Bool Function SendOverlayJson(String payload) Global Native
{Sends a JSON string to the Devotion Prisma overlay without focusing the panel.}

Bool Function SupportsChoice() Global Native
{Returns true when the bridge DLL supports the focused choice-panel channel (Phase 0+). False on an older DLL, so callers fall back to a vanilla MessageBox.}

Bool Function ShowChoice(String menuId, String payload, Bool pauseGame) Global Native
{Renders a choice grid from the JSON payload, then focuses the view once it is ready. pauseGame=true is modal (but freezes the Papyrus watchdog); false keeps the game running. menuId tags the result so ConsumePendingChoice can match it. Returns false when the view/bridge is unavailable.}

Int Function ConsumePendingChoice(String menuId) Global Native
{Non-blocking poll for a choice result: -3 none, -2 pending, -1 cancelled, >=0 chosen index. Returns and clears the stored result only when menuId matches the menu that produced it.}

Bool Function CancelChoice() Global Native
{Force-release the choice view (Unfocus + Hide) and post a cancel result. Used by the Papyrus watchdog when no pick arrives in time; safe to call with nothing pending.}
