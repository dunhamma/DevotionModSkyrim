#pragma once

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

#include <filesystem>
#include <memory>
#include <optional>
#include <string>
#include <string_view>

#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

namespace WinAPI = SKSE::WinAPI;
namespace logs = SKSE::log;
namespace stl = SKSE::stl;

using namespace std::literals;

