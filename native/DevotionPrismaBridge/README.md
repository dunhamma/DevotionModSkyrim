# DevotionPrismaBridge

Thin SKSE native bridge between PlayerDevotion Papyrus scripts and Prisma UI.

This is intentionally small. Prisma exposes a C++ SKSE API, not a Papyrus API,
so PDV calls these native Papyrus functions and the DLL forwards them to
Prisma:

- `PDV_PrismaBridge.IsAvailable()`
- `PDV_PrismaBridge.OpenDevotionPanel()`
- `PDV_PrismaBridge.CloseDevotionPanel()`
- `PDV_PrismaBridge.ToggleDevotionPanel()`
- `PDV_PrismaBridge.SendJson(payload)`
- `PDV_PrismaBridge.SendOverlayJson(payload)`

The first UI view is loaded from:

```text
Data/PrismaUI/views/Devotion/index.html
```

## Build

This scaffold follows the CommonLibSSE-NG `xmake` pattern used by Anvil's
installed SKSE source mods.

Installed build prerequisites on this machine:

- Visual Studio Build Tools 2022 at `C:\BuildTools`
- portable xmake at `C:\Users\Admin\Documents\xmake-v3.0.8-win64\`
- network/package access for `commonlibsse-ng` the first time xmake restores it
- the vendored Prisma API header at `include/prisma/PrismaUI_API.h`

Build from this folder:

```powershell
$env:PDV_MOD_PATH = "D:\Wabbajack\modlists\Anvil\mods\Devotion"
& "C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe" f -y -m releasedbg
& "C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe" -y
```

The `after_build` hook copies the DLL and PDB to:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\
```

Current verified output:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\DevotionPrismaBridge.dll
D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\DevotionPrismaBridge.pdb
```

`dumpbin /exports` should show:

```text
SKSEPlugin_Load
SKSEPlugin_Query
SKSEPlugin_Version
```

Note: the vendored `include/prisma/PrismaUI_API.h` is a local
CommonLibSSE-NG-compatible shim. It avoids including `Windows.h`, which collides
with CommonLib's `SKSE::WinAPI` declarations under warnings-as-errors. The
installed MO2 Prisma API Header File mod is unchanged.

## Runtime Shape

The plugin waits until SKSE `PostLoad`, then asks Prisma for
`IVPrismaUI2`. The view is created lazily the first time Papyrus opens the
panel or sends JSON. That keeps startup low-risk while still allowing PDV to
probe availability from Papyrus.

The UI exposes global JavaScript functions:

```js
ReceivePDVJson(payload)
ReceivePDVOverlayJson(payload)
```

The bridge calls those functions through Prisma `InteropCall`.
`SendJson(payload)` is for focused panel data. `SendOverlayJson(payload)` shows
the view without focusing or pausing the panel path and sends the payload to the
overlay receiver, which is currently used for transient devotion toasts.

The Devotion view accepts compact event payloads and expands player-facing copy
client-side. Current event names:

```json
{ "toast": { "event": "favor", "deity": "Kyne", "symbol": "kyne", "context": "Clean hunt", "amount": 4 } }
{ "toast": { "event": "dawn" } }
{ "toast": { "event": "neglect", "deity": "Kyne" } }
{ "toast": { "event": "tier", "deity": "Kyne", "symbol": "kyne", "tierLabel": "Devoted" } }
{ "toast": { "event": "rivalry", "rival": "Auri-El", "rivalSymbol": "auri-el" } }
```

Explicit `title`, `message`, `tone`, or `symbol` fields still override the
event defaults when Papyrus needs authored wording for a special case.

## Static Demo

`scratch/DevotionPrismaDemo.html` is a single-file static demo for sharing the
current player-facing prototype outside the dev environment. It embeds the
current Devotion view CSS/JS and forces demo mode, so it does not require
Skyrim, SKSE, Prisma, MO2, or the rest of this repo.
