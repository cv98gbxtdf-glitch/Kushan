local BASE        = "https://raw.githubusercontent.com/cv98gbxtdf-glitch/Kushan/refs/heads/main/"
local HttpService = game:GetService("HttpService")

-- Shared environment all modules read from
getgenv().KUSHAN = {
    BASE    = BASE,
    Version = "v3.0",
}

local K = getgenv().KUSHAN

-- Libraries
K.Library    = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
K.ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()

-- Game detection via gameList.json
local ok, gameList = pcall(function()
    return HttpService:JSONDecode(game:HttpGet(BASE .. "core/gameList.json"))
end)

local gameName    = ok and gameList[tostring(game.PlaceId)] or nil
K.GameName        = gameName
K.IsSupported     = gameName ~= nil

-- Window
K.Window = K.Library:CreateWindow({
    Title      = "KUSHAN",
    Footer     = K.Version,
    NotifySide = "Right",
    Icon       = 101385867250567,
})

-- Universal tabs (always present)
K.Tabs = {
    Visuals = K.Window:AddTab("Visuals", "eye"),
    Combat  = K.Window:AddTab("Combat",  "sword"),
}

-- Game tab (only if supported)
if K.IsSupported then
    K.Tabs.Game = K.Window:AddTab(gameName, "crosshair")
end

K.Options = K.Library.Options

-- Module loader with error handling
local function loadModule(path)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(BASE .. path))()
    end)
    if not ok then
        warn("[KUSHAN] Failed to load " .. path .. ": " .. tostring(err))
        K.Library:Notify("Failed to load module: " .. path, 5)
    end
end

-- Always load universal modules
loadModule("universal/esp.lua")
loadModule("universal/hitbox.lua")

-- Load game module only if detected
if K.IsSupported then
    loadModule("games/" .. gameName .. ".lua")
    K.Library:Notify("Loaded: " .. gameName .. " — all features active.", 4)
else
    K.Library:Notify("Unsupported game — universal features only.", 4)
end
