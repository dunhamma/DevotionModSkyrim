Scriptname PDV_PrismaBridge Hidden
{Native bridge between PlayerDevotion Papyrus scripts and the Prisma UI SKSE API.}

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
