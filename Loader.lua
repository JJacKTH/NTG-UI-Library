--[[
    NTG UI Library - Loader
    Thin wrapper for remote loading
]]

local BASE_URL = "https://raw.githubusercontent.com/JJacKTH/NTG-UI-Library/main/"
local cb = "?cb=" .. tostring(os.time())

local function safeLoad(url, name)
    local content
    local ok, err = pcall(function()
        content = game:HttpGet(url)
    end)
    if not ok or not content or content == "" then
        error("[NTGUI] Failed to download " .. name .. " from: " .. url .. " | Error: " .. tostring(err or "empty response"))
    end
    local func, compileErr = loadstring(content)
    if not func then
        error("[NTGUI] Failed to compile " .. name .. " | Error: " .. tostring(compileErr))
    end
    local runOk, result = pcall(func)
    if not runOk then
        error("[NTGUI] Failed to execute " .. name .. " | Error: " .. tostring(result))
    end
    return result
end

return safeLoad(BASE_URL .. "Main.lua" .. cb, "Main")
