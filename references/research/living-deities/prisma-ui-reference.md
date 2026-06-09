# Prisma UI — Reference Notes (for PDV diegetic UI)

> Captured 2026-06-09 from prismaui.dev docs, the `PrismaUI-SKSE/framework` repo
> (license), and the `example-skse-plugin` source (`PrismaUI_API.h`, `main.cpp`).
> Source-available; Nexus mod 148718; org `github.com/PrismaUI-SKSE`.

## What it is
A **source-available SKSE framework** that renders **web UI (HTML5 / CSS3 / JS
ES2022; React/Vue/Svelte ok)** inside Skyrim via the **Ultralight SDK**. Built on
**CommonLibSSE-NG**. It runs *alongside* the vanilla SWF/Scaleform system (does
not replace it), so it coexists with other UI mods. Reported to be lighter-weight
than Papyrus-driven UIs.

## Consumption model (this is why PDV's architecture is correct)
- The public API is **C++ only — there is no native Papyrus API.** A Papyrus mod
  therefore needs a **bridge DLL** that calls Prisma's C++ API and exposes Papyrus
  functions upward. **PDV's `DevotionPrismaBridge.dll` is exactly that bridge** —
  this is the necessary, idiomatic pattern, not an accident.
- A consuming mod **ships its own UI content** under
  `<YourPlugin>/PrismaUI/views/<UI-Name>/index.html` (+ css/js/assets). The view
  content is **bundled in your mod**; the engine is not.

## API surface (`IVPrismaUI1`, extended by `IVPrismaUI2`)
Obtain via `RequestPluginAPI<IVPrismaUI1>()` during SKSE data-loaded. `PrismaView`
is a `uint64_t` handle. **One view instance can serve all interfaces** — you manage
layers in JS.

- **Lifecycle:** `CreateView(htmlPath, onDomReadyCallback)` → `PrismaView`;
  `Destroy(view)`; `IsValid(view)`.
- **C++ → JS:** `Invoke(view, script, cb=null)` (run arbitrary JS, optional result
  callback); `InteropCall(view, functionName, argument)` (call a named JS function
  with a string arg).
- **JS → C++:** `RegisterJSListener(view, functionName, cb)` — JS calls
  `functionName`, the C++ callback receives a `const char* argument`.
- **Focus:** `Focus(view, pauseGame=false, disableFocusMenu=false)` (captures input,
  shows cursor, optionally pauses game), `Unfocus(view)` (returns control, hides
  cursor, resumes), `HasFocus(view)`, `HasAnyActiveFocus()`.
- **Visibility:** `Show(view)`, `Hide(view)`, `IsHidden(view)` — **independent of
  focus** (you can Show without Focus → non-interactive overlay).
- **Z-order / scroll:** `Get/SetOrder(view)`, `Get/SetScrollingPixelSize(view)`.
- **Dev:** `CreateInspectorView` / `SetInspectorVisibility` (Chrome-devtools-style
  live inspector); V2 adds `RegisterConsoleCallback` (Log/Warning/Error/Debug/Info).

**Data flow:** everything crosses the bridge as **strings (JSON)** — C++ pushes
state in via `Invoke`/`InteropCall`; JS sends actions back via the registered
listener.

## License (matters for our dependency decision)
"**Prisma UI License**":
- ✅ Use in non-commercial or small-commercial (< US$100k revenue/funding) projects
  — **PDV qualifies** (free mod).
- ✅ **"Share and distribute the original, official framework files with anyone"** —
  redistribution of the *unmodified official* DLL is **explicitly permitted**
  (unusual; most frameworks forbid it).
- ❌ May **not** distribute *modified* versions without written permission.
- Ultralight component → must comply with the **Ultralight Free License Agreement**.

## Implications for PDV (decisions + open questions)
- **Bundle in PDV:** your view content (`PrismaUI/views/PDV/...`) + your
  `DevotionPrismaBridge.dll` + your OAR animation files.
- **Hard-install (do NOT bundle) the engines** (Prisma core, OAR): the license
  *allows* bundling Prisma's official DLL, so the reason is now purely **technical
  hygiene** — the DLL is runtime-version-specific (CommonLib-NG/Address Library), so
  a bundled copy goes stale and crashes users on Skyrim/SKSE updates, plus it
  double-installs against users who already have it, plus Ultralight-license
  compliance travels with redistribution. Let users get/update it from its own page.
- **Soft vs hard is nearly free to make SOFT** (see architecture note): because all
  data crosses as a JSON state blob, the *same* state can render to MCM/MessageBox
  when Prisma is absent. One state model, two renderers.
- **Elegant shape (proposed):** ONE Prisma view for PDV with JS-managed layers —
  non-focusing **toast** layer, summonable+pausing **panel** layer, **medallion**
  glyph element — fed by a **single JSON "devotion state" contract** via
  `InteropCall("pdvRender", state)` and one `RegisterJSListener("pdvAction", ...)`.
  Keeps the bridge DLL tiny/stable; all UX lives in hot-reloadable web content
  (fits the data-driven/authorable constraint); the Inspector enables dev without
  recompiling the DLL.
