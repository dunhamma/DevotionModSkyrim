set_xmakever("2.7.8")

set_project("DevotionPrismaBridge")
set_version("0.1.0")
set_license("MIT")
set_languages("c++20")
set_optimize("faster")
set_warnings("allextra", "error")

set_allowedarchs("windows|x64")
set_allowedmodes("debug", "releasedbg")
set_defaultarchs("windows|x64")
set_defaultmode("releasedbg")

add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")

set_policy("package.requires_lock", true)

add_requires("commonlibsse-ng", { configs = { skyrim_vr = false } })

target("DevotionPrismaBridge")
    add_packages("fmt", "spdlog", "commonlibsse-ng")

    add_rules("@commonlibsse-ng/plugin", {
        name = "DevotionPrismaBridge",
        author = "PlayerDevotion",
        description = "Papyrus bridge for PlayerDevotion Prisma UI panels"
    })

    add_files("src/**.cpp")
    add_headerfiles("src/**.h", "include/**.h")
    add_includedirs("src", "include/prisma")
    set_pcxxheader("src/pch.h")

    after_build(function(target)
        local mod_path = os.getenv("PDV_MOD_PATH")
        if mod_path then
            local plugins = path.join(mod_path, "SKSE/Plugins")
            os.mkdir(plugins)
            os.trycp(target:targetfile(), plugins)
            os.trycp(target:symbolfile(), plugins)
        end
    end)

