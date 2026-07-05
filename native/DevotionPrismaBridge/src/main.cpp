#include "pch.h"

#include "PrismaUI_API.h"

namespace
{
    constexpr auto kPapyrusScript = "PDV_PrismaBridge"sv;
    constexpr auto kViewPath = "Devotion/index.html"sv;
    constexpr auto kReceiveFunction = "ReceivePDVJson"sv;
    constexpr auto kReceiveOverlayFunction = "ReceivePDVOverlayJson"sv;
    // Phase 0 choice-panel round trip: C++ -> JS sends the option grid through
    // kReceiveChoiceFunction; JS -> C++ returns the pick by calling the
    // kChoiceResultListener global (registered via RegisterJSListener).
    constexpr auto kReceiveChoiceFunction = "ReceivePDVChoice"sv;
    constexpr auto kChoiceResultListener = "PDVChoiceResult"sv;
    // Main-panel close channel: the focused dashboard panel calls
    // window.PDVPanelClose("main|close") (ESC or the in-view X button); C++ releases
    // focus AND hides the view, so the player is never trapped or left a lingering panel.
    constexpr auto kPanelCloseListener = "PDVPanelClose"sv;
    constexpr std::size_t kMaxPendingOverlayPayloads = 16;

    PRISMA_UI_API::IVPrismaUI2* g_prisma = nullptr;
    PrismaView g_view = 0;
    std::string g_lastPayload;
    std::deque<std::string> g_pendingOverlayPayloads;

    // Choice-panel return-channel state. Status codes match the Papyrus contract:
    //   -3 = no choice active, -2 = pending (focused, awaiting a pick),
    //   -1 = cancelled (ESC / cancel), >=0 = chosen option index.
    // Phase 0 keeps these plain (single choice at a time); Phase 1 adds a mutex.
    std::string g_choicePendingMenu;
    std::string g_choiceResultMenu;
    int g_choiceStatus = -3;
    // First ShowChoice on a cold view must NOT focus before the DOM is ready and
    // window.ReceivePDVChoice exists, or the grid never renders and the player is
    // focused/paused on an empty view (an unrecoverable trap). Defer to OnDomReady.
    std::string g_pendingChoicePayload;
    bool g_choiceFocusPending = false;
    // Main panel: same cold-view hazard -- defer the focus to OnDomReady so we never
    // focus an empty, not-yet-interactive view (ESC/close cannot release that).
    bool g_panelFocusPending = false;
    bool g_choicePause = false;
    bool g_domReady = false;
    bool g_journalVisible = false;
    bool g_panelVisible = false;
    bool g_inputSinkRegistered = false;

    std::filesystem::path LogPath()
    {
        auto relPath = std::filesystem::path("Data\\SKSE\\Plugins");
        return std::filesystem::absolute(relPath);
    }

    void InitLogging()
    {
        auto path = LogPath();
        const auto plugin = SKSE::PluginDeclaration::GetSingleton();
        path /= fmt::format("{}.log", plugin->GetName());

        std::shared_ptr<spdlog::sinks::sink> sink;
        if (WinAPI::IsDebuggerPresent()) {
            sink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
        } else {
            sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(path.string(), true);
        }

        auto logger = std::make_shared<spdlog::logger>("global", sink);
        logger->set_level(spdlog::level::info);
        logger->flush_on(spdlog::level::info);
        spdlog::set_default_logger(std::move(logger));
        spdlog::set_pattern("%d.%m.%Y %H:%M:%S [%s:%#] %v");
    }

    const char* ConsoleLevelName(PRISMA_UI_API::ConsoleMessageLevel a_level)
    {
        switch (a_level) {
        case PRISMA_UI_API::ConsoleMessageLevel::Log:
            return "log";
        case PRISMA_UI_API::ConsoleMessageLevel::Warning:
            return "warning";
        case PRISMA_UI_API::ConsoleMessageLevel::Error:
            return "error";
        case PRISMA_UI_API::ConsoleMessageLevel::Debug:
            return "debug";
        case PRISMA_UI_API::ConsoleMessageLevel::Info:
            return "info";
        default:
            return "unknown";
        }
    }

    void OnConsoleMessage(
        PrismaView a_view,
        PRISMA_UI_API::ConsoleMessageLevel a_level,
        const char* a_message) noexcept
    {
        logs::info("Prisma view {} [{}]: {}", a_view, ConsoleLevelName(a_level), a_message ? a_message : "");
    }

    // JS -> C++ return channel. The view calls window.PDVChoiceResult("<menu>|<token>")
    // where <token> is the chosen index or "cancel". We store the result and
    // immediately release focus so the player is never trapped on the panel.
    void OnChoiceResult(const char* a_argument) noexcept
    {
        const std::string arg = a_argument ? a_argument : "";
        const auto bar = arg.find_last_of('|');
        const std::string menu = (bar == std::string::npos) ? std::string() : arg.substr(0, bar);
        const std::string token = (bar == std::string::npos) ? arg : arg.substr(bar + 1);

        int status = -1;  // default to cancel on empty/garbage
        if (!token.empty() && token != "cancel") {
            int parsed = 0;
            bool digits = true;
            for (const char c : token) {
                if (c < '0' || c > '9') {
                    digits = false;
                    break;
                }
                parsed = (parsed * 10) + (c - '0');
            }
            if (digits) {
                status = parsed;
            }
        }

        g_choiceResultMenu = menu;
        g_choiceStatus = status;
        logs::info("Prisma choice result: menu='{}' status={}", menu, status);

        if (g_prisma && g_view && g_prisma->IsValid(g_view)) {
            g_prisma->Unfocus(g_view);
        }
    }

    void HidePrismaView() noexcept
    {
        if (g_prisma && g_view && g_prisma->IsValid(g_view)) {
            g_prisma->Unfocus(g_view);
            g_prisma->Hide(g_view);
        }
    }

    void ClosePanelSurface(std::string_view a_source) noexcept
    {
        g_panelFocusPending = false;
        g_panelVisible = false;
        g_journalVisible = false;
        logs::info("Prisma focused panel close requested by {}", a_source);
        HidePrismaView();
    }

    void HideJournalDom() noexcept
    {
        if (g_prisma && g_view && g_prisma->IsValid(g_view) && g_domReady) {
            g_prisma->InteropCall(g_view, kReceiveOverlayFunction.data(), "{\"journalClose\":true}");
        }
    }

    void CloseJournalSurface(std::string_view a_source, bool a_requireVisible = false) noexcept
    {
        if (a_requireVisible && !g_journalVisible) {
            return;
        }
        HideJournalDom();
        g_journalVisible = false;
        logs::info("Prisma journal close requested by {}", a_source);
        HidePrismaView();
    }

    // JS -> C++ close channel for the focused main panel and Book of Days X button.
    // Journal close uses the same native module as hotkey and ESC close so state,
    // focus, cursor, and view visibility cannot drift by close route.
    void OnPanelClose(const char* a_argument) noexcept
    {
        const std::string arg = a_argument ? a_argument : "";
        if (arg.find("journal") != std::string::npos) {
            CloseJournalSurface("js_panel_close");
            return;
        }
        if (arg.empty()) {
            ClosePanelSurface("js_panel_close");
        } else {
            ClosePanelSurface(arg);
        }
    }

    class PrismaInputSink final : public RE::BSTEventSink<RE::InputEvent*>
    {
    public:
        static PrismaInputSink* GetSingleton()
        {
            static PrismaInputSink singleton;
            return std::addressof(singleton);
        }

        RE::BSEventNotifyControl ProcessEvent(
            RE::InputEvent* const* a_event,
            RE::BSTEventSource<RE::InputEvent*>*) override
        {
            if ((!g_journalVisible && !g_panelVisible && !g_panelFocusPending) || !a_event) {
                return RE::BSEventNotifyControl::kContinue;
            }

            for (auto* event = *a_event; event; event = event->next) {
                const auto* button = event->AsButtonEvent();
                if (!button || !button->IsDown()) {
                    continue;
                }

                const bool keyboardEscape =
                    button->GetDevice() == RE::INPUT_DEVICES::kKeyboard &&
                    button->GetIDCode() == 1;  // DIK_ESCAPE
                if (keyboardEscape) {
                    if (g_journalVisible) {
                        CloseJournalSurface("keyboard_escape", true);
                    } else {
                        ClosePanelSurface("keyboard_escape");
                    }
                    return RE::BSEventNotifyControl::kStop;
                }
            }

            return RE::BSEventNotifyControl::kContinue;
        }
    };

    void RegisterInputSink()
    {
        if (g_inputSinkRegistered) {
            return;
        }
        auto* inputManager = RE::BSInputDeviceManager::GetSingleton();
        if (!inputManager) {
            logs::warn("Input sink registration skipped: BSInputDeviceManager unavailable");
            return;
        }
        inputManager->AddEventSink(PrismaInputSink::GetSingleton());
        g_inputSinkRegistered = true;
        logs::info("Registered Prisma ESC input sink");
    }

    bool SendLastPayload()
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view)) {
            return false;
        }

        const auto payload = g_lastPayload.empty() ? "{}" : g_lastPayload;
        g_prisma->InteropCall(g_view, kReceiveFunction.data(), payload.c_str());
        return true;
    }

    void QueueOverlayPayload(const std::string& a_payload)
    {
        if (g_pendingOverlayPayloads.size() >= kMaxPendingOverlayPayloads) {
            g_pendingOverlayPayloads.pop_front();
            logs::warn("Prisma overlay queue capped at {}; dropped oldest deferred overlay", kMaxPendingOverlayPayloads);
        }
        g_pendingOverlayPayloads.push_back(a_payload);
        logs::info("Prisma overlay deferred until DOM ready (queued={})", g_pendingOverlayPayloads.size());
    }

    bool SendOverlayPayload(const std::string& a_payload)
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view)) {
            return false;
        }

        if (!g_domReady) {
            QueueOverlayPayload(a_payload);
            return true;
        }

        g_prisma->Show(g_view);
        g_prisma->InteropCall(g_view, kReceiveOverlayFunction.data(), a_payload.c_str());
        const bool isJournalPayload =
            a_payload.find("\"mode\":\"journal\"") != std::string::npos &&
            a_payload.find("\"journal\":") != std::string::npos;
        if (a_payload.find("\"journalClose\"") != std::string::npos) {
            CloseJournalSurface("papyrus_journal_close");
        } else if (isJournalPayload) {
            g_journalVisible = true;
            g_prisma->Focus(g_view, true, false);
        }
        return true;
    }

    void OnDomReady(PrismaView a_view) noexcept
    {
        logs::info("Prisma DOM ready for view {}", a_view);
        g_domReady = true;
        if (g_panelFocusPending && !g_lastPayload.empty()) {
            SendLastPayload();
        }
        // Deferred cold-view panel open: data is now rendered and the ESC/X close is
        // bound, so focusing is safe and the player can dismiss the panel.
        if (g_panelFocusPending && g_prisma && g_view && g_prisma->IsValid(g_view)) {
            g_prisma->Show(g_view);
            g_prisma->Focus(g_view, true, false);
            g_panelVisible = true;
            logs::info("Prisma deferred panel focus (cold-view open)");
            g_panelFocusPending = false;
        }
        while (!g_pendingOverlayPayloads.empty()) {
            std::string pendingPayload = std::move(g_pendingOverlayPayloads.front());
            g_pendingOverlayPayloads.pop_front();
            if (!SendOverlayPayload(pendingPayload)) {
                QueueOverlayPayload(pendingPayload);
                break;
            }
        }
        // Deferred choice: render the grid on the now-ready DOM, THEN focus.
        if (g_choiceFocusPending && g_prisma && g_view && g_prisma->IsValid(g_view)) {
            g_prisma->InteropCall(g_view, kReceiveChoiceFunction.data(), g_pendingChoicePayload.c_str());
            g_prisma->Show(g_view);
            g_prisma->Focus(g_view, g_choicePause, false);
            logs::info("Prisma deferred choice sent + focused (pause={})", g_choicePause);
            g_choiceFocusPending = false;
            g_pendingChoicePayload.clear();
        }
    }

    void AcquirePrisma()
    {
        if (g_prisma) {
            return;
        }

        g_prisma = PRISMA_UI_API::RequestPluginAPI<PRISMA_UI_API::IVPrismaUI2>();
        if (g_prisma) {
            logs::info("Prisma UI API v2 acquired");
        } else {
            logs::warn("Prisma UI API v2 unavailable");
        }
    }

    bool EnsureView()
    {
        AcquirePrisma();

        if (!g_prisma) {
            return false;
        }

        if (g_view && g_prisma->IsValid(g_view)) {
            return true;
        }

        g_domReady = false;  // new view: DOM not loaded until OnDomReady fires
        g_view = g_prisma->CreateView(kViewPath.data(), OnDomReady);
        if (!g_view || !g_prisma->IsValid(g_view)) {
            logs::error("Failed to create Prisma view from {}", kViewPath);
            g_view = 0;
            return false;
        }

        g_prisma->SetOrder(g_view, 900);
        g_prisma->RegisterConsoleCallback(g_view, OnConsoleMessage);
        g_prisma->RegisterJSListener(g_view, kChoiceResultListener.data(), OnChoiceResult);
        g_prisma->RegisterJSListener(g_view, kPanelCloseListener.data(), OnPanelClose);
        g_prisma->Hide(g_view);
        logs::info("Created Prisma view {} from {}", g_view, kViewPath);
        return true;
    }

    bool OpenPanel()
    {
        if (!EnsureView()) {
            return false;
        }

        g_prisma->Show(g_view);
        g_panelVisible = true;
        if (g_domReady) {
            g_prisma->Focus(g_view, true, false);
            SendLastPayload();
        } else {
            // Cold view: focusing before OnDomReady traps the player on an empty,
            // not-yet-interactive view (the same hazard guarded for the choice grid).
            // Defer the focus -- OnDomReady re-sends g_lastPayload (rendering the panel
            // and binding its ESC/X close) and then focuses cleanly.
            g_panelFocusPending = true;
        }
        return true;
    }

    bool ClosePanel()
    {
        ClosePanelSurface("papyrus_panel_close");
        return true;
    }

    bool TogglePanel()
    {
        if (!EnsureView()) {
            return false;
        }

        if (g_panelVisible || g_panelFocusPending) {
            return ClosePanel();
        }

        return OpenPanel();
    }

    bool PapyrusIsAvailable(RE::StaticFunctionTag*)
    {
        AcquirePrisma();
        return g_prisma != nullptr;
    }

    bool PapyrusOpenDevotionPanel(RE::StaticFunctionTag*)
    {
        return OpenPanel();
    }

    bool PapyrusCloseDevotionPanel(RE::StaticFunctionTag*)
    {
        return ClosePanel();
    }

    bool PapyrusToggleDevotionPanel(RE::StaticFunctionTag*)
    {
        return TogglePanel();
    }

    bool PapyrusIsJournalVisible(RE::StaticFunctionTag*)
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view) || g_prisma->IsHidden(g_view)) {
            g_journalVisible = false;
        }
        return g_journalVisible;
    }

    bool PapyrusIsPanelVisible(RE::StaticFunctionTag*)
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view) || g_prisma->IsHidden(g_view)) {
            g_panelVisible = false;
            g_panelFocusPending = false;
        }
        return g_panelVisible || g_panelFocusPending;
    }

    bool PapyrusSendJson(RE::StaticFunctionTag*, RE::BSFixedString a_payload)
    {
        const auto* payload = a_payload.data();
        g_lastPayload = payload && payload[0] ? payload : "{}";

        if (!EnsureView()) {
            return false;
        }

        return SendLastPayload();
    }

    bool PapyrusSendOverlayJson(RE::StaticFunctionTag*, RE::BSFixedString a_payload)
    {
        const auto* payload = a_payload.data();
        const auto overlayPayload = payload && payload[0] ? std::string(payload) : "{}";

        if (!EnsureView()) {
            return false;
        }

        return SendOverlayPayload(overlayPayload);
    }

    bool ShowChoiceImpl(const std::string& a_menuId, const std::string& a_payload, bool a_pauseGame)
    {
        if (!EnsureView()) {
            return false;
        }

        g_choicePendingMenu = a_menuId;
        g_choiceResultMenu.clear();
        g_choiceStatus = -2;  // pending until JS reports a pick or cancel
        g_choicePause = a_pauseGame;

        if (!g_domReady) {
            // View still loading: defer the grid + focus to OnDomReady so we never
            // focus/pause an empty view. Returns true (the choice IS in flight).
            g_pendingChoicePayload = a_payload;
            g_choiceFocusPending = true;
            logs::info("Prisma choice deferred until DOM ready (menu='{}')", a_menuId);
            return true;
        }

        g_prisma->InteropCall(g_view, kReceiveChoiceFunction.data(), a_payload.c_str());
        g_prisma->Show(g_view);
        // disableFocusMenu = false keeps PrismaUI's own focus-menu escape on top of
        // the JS ESC/cancel handler.
        g_prisma->Focus(g_view, a_pauseGame, false);
        return true;
    }

    bool CancelChoiceImpl()
    {
        // Watchdog / external cancel: release focus and post a cancel result the
        // manager's poll consumes. Safe to call with nothing pending.
        if (g_prisma && g_view && g_prisma->IsValid(g_view)) {
            g_prisma->Unfocus(g_view);
            g_prisma->Hide(g_view);
        }
        g_choiceFocusPending = false;
        g_pendingChoicePayload.clear();
        if (!g_choicePendingMenu.empty()) {
            g_choiceResultMenu = g_choicePendingMenu;
        }
        g_choiceStatus = -1;  // cancelled
        return true;
    }

    bool PapyrusSupportsChoice(RE::StaticFunctionTag*)
    {
        AcquirePrisma();
        return g_prisma != nullptr;
    }

    bool PapyrusShowChoice(RE::StaticFunctionTag*, RE::BSFixedString a_menuId, RE::BSFixedString a_payload, bool a_pauseGame)
    {
        const auto* menu = a_menuId.data();
        const auto* payload = a_payload.data();
        return ShowChoiceImpl(menu && menu[0] ? menu : "choice", payload && payload[0] ? payload : "{}", a_pauseGame);
    }

    bool PapyrusCancelChoice(RE::StaticFunctionTag*)
    {
        return CancelChoiceImpl();
    }

    std::int32_t PapyrusConsumePendingChoice(RE::StaticFunctionTag*, RE::BSFixedString a_menuId)
    {
        const std::string menu = a_menuId.data() ? a_menuId.data() : "";
        const int status = g_choiceStatus;

        if (status == -2) {
            // Still awaiting a pick; only report pending for the live menu.
            return (menu == g_choicePendingMenu) ? -2 : -3;
        }
        if (status == -3) {
            return -3;
        }

        // Final result (-1 cancel or >=0 index): deliver once to the matching menu.
        if (menu == g_choiceResultMenu) {
            g_choiceStatus = -3;
            g_choicePendingMenu.clear();
            g_choiceResultMenu.clear();
            return status;
        }
        return -3;
    }

    bool RegisterPapyrus(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("IsAvailable", kPapyrusScript.data(), PapyrusIsAvailable);
        a_vm->RegisterFunction("OpenDevotionPanel", kPapyrusScript.data(), PapyrusOpenDevotionPanel);
        a_vm->RegisterFunction("CloseDevotionPanel", kPapyrusScript.data(), PapyrusCloseDevotionPanel);
        a_vm->RegisterFunction("ToggleDevotionPanel", kPapyrusScript.data(), PapyrusToggleDevotionPanel);
        a_vm->RegisterFunction("IsJournalVisible", kPapyrusScript.data(), PapyrusIsJournalVisible);
        a_vm->RegisterFunction("IsPanelVisible", kPapyrusScript.data(), PapyrusIsPanelVisible);
        a_vm->RegisterFunction("SendJson", kPapyrusScript.data(), PapyrusSendJson);
        a_vm->RegisterFunction("SendOverlayJson", kPapyrusScript.data(), PapyrusSendOverlayJson);
        a_vm->RegisterFunction("SupportsChoice", kPapyrusScript.data(), PapyrusSupportsChoice);
        a_vm->RegisterFunction("ShowChoice", kPapyrusScript.data(), PapyrusShowChoice);
        a_vm->RegisterFunction("ConsumePendingChoice", kPapyrusScript.data(), PapyrusConsumePendingChoice);
        a_vm->RegisterFunction("CancelChoice", kPapyrusScript.data(), PapyrusCancelChoice);
        logs::info("Registered Papyrus functions for {}", kPapyrusScript);
        return true;
    }

    void ProcessMessage(SKSE::MessagingInterface::Message* a_message)
    {
        if (!a_message) {
            return;
        }

        if (a_message->type == SKSE::MessagingInterface::kPostLoad) {
            AcquirePrisma();
        } else if (a_message->type == SKSE::MessagingInterface::kInputLoaded) {
            RegisterInputSink();
        }
    }

    void InitPapyrus()
    {
        const auto papyrus = SKSE::GetPapyrusInterface();
        if (!papyrus || !papyrus->Register(RegisterPapyrus)) {
            stl::report_and_fail("Failed to register Papyrus interface");
        }
    }

    void InitMessaging()
    {
        const auto messaging = SKSE::GetMessagingInterface();
        if (!messaging || !messaging->RegisterListener(ProcessMessage)) {
            stl::report_and_fail("Failed to register SKSE message listener");
        }
    }
}

SKSEPluginLoad(const SKSE::LoadInterface* a_skse)
{
    InitLogging();

    const auto plugin = SKSE::PluginDeclaration::GetSingleton();
    logs::info(
        "{} version {} loading into {}",
        plugin->GetName(),
        plugin->GetVersion().string(),
        REL::Module::get().version().string("."sv));

    SKSE::Init(a_skse);
    InitPapyrus();
    InitMessaging();

    logs::info("{} loaded", plugin->GetName());
    return true;
}
