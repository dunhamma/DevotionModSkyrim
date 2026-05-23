#include <windows.h>

#include <CKPE.Module.h>
#include <CKPE.PathUtils.h>
#include <CKPE.PluginAPI.PluginAPI.h>

#include <atomic>
#include <cstdint>
#include <sstream>
#include <string>
#include <unordered_set>

using namespace CKPE;

namespace
{
    constexpr const wchar_t* PipeName = L"\\\\.\\pipe\\CreationKitAuthoringBridge";
    constexpr const char* ResultSchema = "creation-authoring.ck-command-result.v1";

    std::atomic_bool BridgeRunning{ false };
    PluginAPI::CKPEPluginInterface BridgeInterface{};

    const std::unordered_set<std::string> KnownCommands = {
        "heartbeat",
        "version",
        "environment",
        "getEnvironment",
        "capabilities",
        "openProject",
        "loadPlugin",
        "findRecord",
        "updateRecord",
        "createRecord",
        "attachScript",
        "setProperty",
        "setArrayProperty",
        "addFormListEntry",
        "addAlias",
        "addStoryManagerNode",
        "setSharesEvent",
        "createDialogueBranch",
        "createDialogueTopic",
        "createDialogueInfo",
        "createScene",
        "placeReference",
        "savePlugin",
        "generateSeq",
        "generateLip",
        "exportFaceGen"
    };

    bool Contains(const std::string& request, const char* token)
    {
        return request.find(token) != std::string::npos;
    }

    std::string EscapeJson(const std::string& value)
    {
        std::ostringstream stream;
        for (const char c : value)
        {
            switch (c)
            {
            case '\\':
                stream << "\\\\";
                break;
            case '"':
                stream << "\\\"";
                break;
            case '\n':
                stream << "\\n";
                break;
            case '\r':
                stream << "\\r";
                break;
            case '\t':
                stream << "\\t";
                break;
            default:
                stream << c;
                break;
            }
        }
        return stream.str();
    }

    std::string PassResult(const std::string& command, const std::string& evidenceJson = "{}")
    {
        std::ostringstream stream;
        stream
            << "{\"schema\":\"" << ResultSchema << "\","
            << "\"status\":\"PASS\","
            << "\"transport\":\"named-pipe\","
            << "\"commands\":[{\"op\":\"" << EscapeJson(command) << "\",\"status\":\"PASS\",\"evidence\":"
            << evidenceJson
            << "}],"
            << "\"message\":\"CreationKitAuthoringBridge command completed inside CKPE.\"}";
        return stream.str();
    }

    std::string UnsafeBlockedResult(const std::string& message)
    {
        std::ostringstream stream;
        stream
            << "{\"schema\":\"" << ResultSchema << "\","
            << "\"status\":\"UNSAFE_BLOCKED\","
            << "\"transport\":\"named-pipe\","
            << "\"commands\":[],"
            << "\"message\":\"" << EscapeJson(message) << "\"}";
        return stream.str();
    }

    std::string UnsupportedResult(const std::string& message)
    {
        std::ostringstream stream;
        stream
            << "{\"schema\":\"" << ResultSchema << "\","
            << "\"status\":\"UNSUPPORTED\","
            << "\"transport\":\"named-pipe\","
            << "\"commands\":[],"
            << "\"message\":\"" << EscapeJson(message) << "\"}";
        return stream.str();
    }

    std::string EnvironmentJson()
    {
        std::ostringstream stream;
        stream
            << "{"
            << "\"ckpeVersion\":" << BridgeInterface.CKPEVersion << ","
            << "\"ckpeCommonVersion\":" << BridgeInterface.CKPECommonVersion << ","
            << "\"ckpeGameLibraryVersion\":" << BridgeInterface.CKPEGameLibraryVersion << ","
            << "\"runtimeVersion\":" << BridgeInterface.RuntimeVersion << ","
            << "\"pipe\":\"\\\\\\\\.\\\\pipe\\\\CreationKitAuthoringBridge\""
            << "}";
        return stream.str();
    }

    std::string CapabilitiesJson()
    {
        std::ostringstream stream;
        stream
            << "{\"implemented\":[\"heartbeat\",\"version\",\"environment\",\"capabilities\"],"
            << "\"blocked\":[";

        bool first = true;
        for (const auto& command : KnownCommands)
        {
            if (command == "heartbeat" || command == "version" || command == "environment" || command == "getEnvironment" || command == "capabilities")
            {
                continue;
            }
            if (!first)
            {
                stream << ",";
            }
            first = false;
            stream << "\"" << EscapeJson(command) << "\"";
        }

        stream
            << "],"
            << "\"productRule\":\"A CK command is shippable only after CKPE execution plus MO2 readback verification.\"}";
        return stream.str();
    }

    std::string HandleRequest(const std::string& request)
    {
        if (Contains(request, "\"heartbeat\""))
        {
            return PassResult("heartbeat", EnvironmentJson());
        }

        if (Contains(request, "\"version\"") || Contains(request, "\"environment\"") || Contains(request, "\"getEnvironment\""))
        {
            return PassResult("environment", EnvironmentJson());
        }

        if (Contains(request, "\"capabilities\""))
        {
            return PassResult("capabilities", CapabilitiesJson());
        }

        bool knownCommandSeen = false;
        for (const auto& command : KnownCommands)
        {
            if (Contains(request, command.c_str()))
            {
                knownCommandSeen = true;
                break;
            }
        }

        if (knownCommandSeen)
        {
            return UnsafeBlockedResult("CreationKitAuthoringBridge is loaded through real CKPE PluginAPI, but mutating CK object handlers are not yet verifier-proven.");
        }

        return UnsupportedResult("Packet contains no supported CreationKitAuthoringBridge command.");
    }

    DWORD WINAPI PipeThread(void*)
    {
        for (;;)
        {
            HANDLE pipe = CreateNamedPipeW(
                PipeName,
                PIPE_ACCESS_DUPLEX,
                PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
                1,
                1024 * 1024,
                1024 * 1024,
                0,
                nullptr);

            if (pipe == INVALID_HANDLE_VALUE)
            {
                return 1;
            }

            if (ConnectNamedPipe(pipe, nullptr) || GetLastError() == ERROR_PIPE_CONNECTED)
            {
                char buffer[64 * 1024] = {};
                DWORD bytesRead = 0;
                ReadFile(pipe, buffer, sizeof(buffer) - 1, &bytesRead, nullptr);

                const std::string response = HandleRequest(std::string(buffer, bytesRead));
                DWORD bytesWritten = 0;
                WriteFile(pipe, response.c_str(), static_cast<DWORD>(response.size()), &bytesWritten, nullptr);
                FlushFileBuffers(pipe);
                DisconnectNamedPipe(pipe);
            }

            CloseHandle(pipe);
        }
    }
}

extern "C"
{
    __declspec(dllexport) PluginAPI::CKPEPluginVersionData CKPEPlugin_Version =
    {
        PluginAPI::CKPEPluginVersionData::kVersion,
        1,
        "Creation Kit Authoring Bridge",
        "Devotion Automation",
        PluginAPI::CKPEPluginVersionData::kGameSkyrimSE,
        0,
        { MAKE_EXE_VERSION_EX(1, 5, 73, 0), MAKE_EXE_VERSION_EX(1, 6, 1378, 1), 0 },
        0
    };

    __declspec(dllexport) bool CKPEPlugin_HasDependencies() noexcept(true)
    {
        return false;
    }

    __declspec(dllexport) std::uint32_t CKPEPlugin_GetDependCount() noexcept(true)
    {
        return 0;
    }

    __declspec(dllexport) const char* CKPEPlugin_GetDependAt(std::uint32_t) noexcept(true)
    {
        return nullptr;
    }

    __declspec(dllexport) std::uint32_t CKPEPlugin_Load(const PluginAPI::CKPEPluginInterface* intf) noexcept(true)
    {
        if (!intf)
        {
            return false;
        }

        BridgeInterface = *intf;

        auto logPath = PathUtils::GetCKPELogsPluginPath() + L"CreationKitAuthoringBridge.log";
        auto normalizedLogPath = logPath;
        PathUtils::CreateFolder(PathUtils::ExtractFilePath(PathUtils::Normalize(normalizedLogPath)));
        if (!PluginAPI::UserPluginLogger.Open(logPath))
        {
            CKPE::_ERROR(L"CreationKitAuthoringBridge failed to open log file \"%s\"", logPath.c_str());
            return false;
        }

        PluginAPI::_MESSAGE("CreationKitAuthoringBridge loading through CKPE PluginAPI.");

        if (!BridgeRunning.exchange(true))
        {
            HANDLE thread = CreateThread(nullptr, 0, PipeThread, nullptr, 0, nullptr);
            if (thread)
            {
                CloseHandle(thread);
            }
            else
            {
                BridgeRunning = false;
                PluginAPI::_ERROR("CreationKitAuthoringBridge failed to start named pipe thread.");
                return false;
            }
        }

        PluginAPI::_MESSAGE("CreationKitAuthoringBridge named pipe ready.");
        return true;
    }
}

BOOL APIENTRY DllMain(HMODULE, DWORD, LPVOID)
{
    return TRUE;
}
