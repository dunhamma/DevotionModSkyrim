#include "pch.h"

#include "PrismaUI_API.h"

namespace
{
    constexpr auto kPapyrusScript = "PDV_PrismaBridge"sv;
    constexpr auto kViewPath = "Devotion/index.html"sv;
    constexpr auto kReceiveFunction = "ReceivePDVJson"sv;
    constexpr auto kReceiveOverlayFunction = "ReceivePDVOverlayJson"sv;

    PRISMA_UI_API::IVPrismaUI2* g_prisma = nullptr;
    PrismaView g_view = 0;
    std::string g_lastPayload;
    std::string g_pendingOverlayPayload;

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

    bool SendLastPayload()
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view)) {
            return false;
        }

        const auto payload = g_lastPayload.empty() ? "{}" : g_lastPayload;
        g_prisma->InteropCall(g_view, kReceiveFunction.data(), payload.c_str());
        return true;
    }

    bool SendOverlayPayload(const std::string& a_payload)
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view)) {
            return false;
        }

        g_prisma->Show(g_view);
        g_prisma->InteropCall(g_view, kReceiveOverlayFunction.data(), a_payload.c_str());
        return true;
    }

    void OnDomReady(PrismaView a_view) noexcept
    {
        logs::info("Prisma DOM ready for view {}", a_view);
        if (!g_lastPayload.empty()) {
            SendLastPayload();
        }
        if (!g_pendingOverlayPayload.empty()) {
            SendOverlayPayload(g_pendingOverlayPayload);
            g_pendingOverlayPayload.clear();
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

        g_view = g_prisma->CreateView(kViewPath.data(), OnDomReady);
        if (!g_view || !g_prisma->IsValid(g_view)) {
            logs::error("Failed to create Prisma view from {}", kViewPath);
            g_view = 0;
            return false;
        }

        g_prisma->SetOrder(g_view, 900);
        g_prisma->RegisterConsoleCallback(g_view, OnConsoleMessage);
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
        g_prisma->Focus(g_view, true, false);
        SendLastPayload();
        return true;
    }

    bool ClosePanel()
    {
        if (!g_prisma || !g_view || !g_prisma->IsValid(g_view)) {
            return true;
        }

        g_prisma->Unfocus(g_view);
        g_prisma->Hide(g_view);
        return true;
    }

    bool TogglePanel()
    {
        if (!EnsureView()) {
            return false;
        }

        if (g_prisma->IsHidden(g_view)) {
            return OpenPanel();
        }

        return ClosePanel();
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
            g_pendingOverlayPayload = overlayPayload;
            return false;
        }

        if (!SendOverlayPayload(overlayPayload)) {
            g_pendingOverlayPayload = overlayPayload;
            return false;
        }

        return true;
    }

    bool RegisterPapyrus(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("IsAvailable", kPapyrusScript.data(), PapyrusIsAvailable);
        a_vm->RegisterFunction("OpenDevotionPanel", kPapyrusScript.data(), PapyrusOpenDevotionPanel);
        a_vm->RegisterFunction("CloseDevotionPanel", kPapyrusScript.data(), PapyrusCloseDevotionPanel);
        a_vm->RegisterFunction("ToggleDevotionPanel", kPapyrusScript.data(), PapyrusToggleDevotionPanel);
        a_vm->RegisterFunction("SendJson", kPapyrusScript.data(), PapyrusSendJson);
        a_vm->RegisterFunction("SendOverlayJson", kPapyrusScript.data(), PapyrusSendOverlayJson);
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
