--! Debugger

local DEBUG = false

if DEBUG then
    getfenv().getfenv = function()
        return setmetatable({}, {
            __index = function()
                return function()
                    return true
                end
            end
        })
    end
end


--! Services

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


--! Interface Manager

local UISettings = {
    TabWidth = 160,
    Size = { 580, 460 },
    Theme = "VSC Dark High Contrast",
    Acrylic = false,
    Transparency = true,
    MinimizeKey = "RightShift",
    ShowNotifications = true,
    ShowWarnings = true,
    RenderingMode = "RenderStepped",
    AutoImport = true
}

local InterfaceManager = {}

function InterfaceManager:ImportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile("UISettings.ttwizz") and getfenv().readfile("UISettings.ttwizz") then
            for Key, Value in next, HttpService:JSONDecode(getfenv().readfile("UISettings.ttwizz")) do
                UISettings[Key] = Value
            end
        end
    end)
end

function InterfaceManager:ExportSettings()
    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().writefile then
            getfenv().writefile("UISettings.ttwizz", HttpService:JSONEncode(UISettings))
        end
    end)
end

InterfaceManager:ImportSettings()

UISettings.__LAST_RUN__ = os.date()
InterfaceManager:ExportSettings()


--! Colors Handler

local ColorsHandler = {}

function ColorsHandler:PackColour(Colour)
    return typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
end

function ColorsHandler:UnpackColour(Colour)
    return typeof(Colour) == "table" and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or typeof(Colour) == "Color3" and Colour or Color3.fromRGB(255, 255, 255)
end


--! Configuration Importer

local ImportedConfiguration = {}

pcall(function()
    if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
        ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
        for Key, Value in next, ImportedConfiguration do
            if Key == "FoVColour" then
                ImportedConfiguration[Key] = ColorsHandler:UnpackColour(Value)
            end
        end
    end
end)


--! Configuration Initializer

local Configuration = {}

--? Aimbot

Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
Configuration.OnePressAimingMode = ImportedConfiguration["OnePressAimingMode"] or false
Configuration.AimKey = ImportedConfiguration["AimKey"] or "RMB"
Configuration.AimMode = ImportedConfiguration["AimMode"] or "Camera"
Configuration.SilentAimMethods = ImportedConfiguration["SilentAimMethods"] or { "Mouse.Hit / Mouse.Target", "GetMouseLocation" }
Configuration.SilentAimChance = ImportedConfiguration["SilentAimChance"] or 100
Configuration.OffAimbotAfterKill = ImportedConfiguration["OffAimbotAfterKill"] or false
Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false

Configuration.UseOffset = ImportedConfiguration["UseOffset"] or false
Configuration.OffsetType = ImportedConfiguration["OffsetType"] or "Static"
Configuration.StaticOffsetIncrement = ImportedConfiguration["StaticOffsetIncrement"] or 10
Configuration.DynamicOffsetIncrement = ImportedConfiguration["DynamicOffsetIncrement"] or 10
Configuration.AutoOffset = ImportedConfiguration["AutoOffset"] or false
Configuration.MaxAutoOffset = ImportedConfiguration["MaxAutoOffset"] or 50

Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 50
Configuration.UseNoise = ImportedConfiguration["UseNoise"] or false
Configuration.NoiseFrequency = ImportedConfiguration["NoiseFrequency"] or 50

--? Bots

Configuration.SpinBot = ImportedConfiguration["SpinBot"] or false
Configuration.OnePressSpinningMode = ImportedConfiguration["OnePressSpinningMode"] or false
Configuration.SpinKey = ImportedConfiguration["SpinKey"] or "Q"
Configuration.SpinBotVelocity = ImportedConfiguration["SpinBotVelocity"] or 50
Configuration.SpinPartDropdownValues = ImportedConfiguration["SpinPartDropdownValues"] or { "Head", "HumanoidRootPart" }
Configuration.SpinPart = ImportedConfiguration["SpinPart"] or "HumanoidRootPart"
Configuration.RandomSpinPart = ImportedConfiguration["RandomSpinPart"] or false

Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
Configuration.OnePressTriggeringMode = ImportedConfiguration["OnePressTriggeringMode"] or false
Configuration.SmartTriggerBot = ImportedConfiguration["SmartTriggerBot"] or false
Configuration.TriggerKey = ImportedConfiguration["TriggerKey"] or "E"
Configuration.TriggerBotChance = ImportedConfiguration["TriggerBotChance"] or 100

--? Checks

Configuration.AliveCheck = ImportedConfiguration["AliveCheck"] or false
Configuration.GodCheck = ImportedConfiguration["GodCheck"] or false
Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
Configuration.FollowCheck = ImportedConfiguration["FollowCheck"] or false
Configuration.VerifiedBadgeCheck = ImportedConfiguration["VerifiedBadgeCheck"] or false
Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
Configuration.WaterCheck = ImportedConfiguration["WaterCheck"] or false

Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
Configuration.WhitelistedGroupCheck = ImportedConfiguration["WhitelistedGroupCheck"] or false
Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
Configuration.BlacklistedGroupCheck = ImportedConfiguration["BlacklistedGroupCheck"] or false
Configuration.BlacklistedGroup = ImportedConfiguration["BlacklistedGroup"] or 0

Configuration.IgnoredPlayersCheck = ImportedConfiguration["IgnoredPlayersCheck"] or false
Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
Configuration.TargetPlayersCheck = ImportedConfiguration["TargetPlayersCheck"] or false
Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}

Configuration.PremiumCheck = ImportedConfiguration["PremiumCheck"] or false

--? Visuals

Configuration.FoV = ImportedConfiguration["FoV"] or false
Configuration.FoVKey = ImportedConfiguration["FoVKey"] or "R"
Configuration.FoVThickness = ImportedConfiguration["FoVThickness"] or 2
Configuration.FoVOpacity = ImportedConfiguration["FoVOpacity"] or 0.8
Configuration.FoVFilled = ImportedConfiguration["FoVFilled"] or false
Configuration.FoVColour = ImportedConfiguration["FoVColour"] or Color3.fromRGB(255, 255, 255)


--! Constants

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

local MonthlyLabels = { "🎅%s❄️", "☃️%s🏂", "🌷%s☘️", "🌺%s🎀", "🐝%s🌼", "🌈%s😎", "🌞%s🏖️", "☀️%s💐", "🌦%s🍁", "🎃%s💀", "🍂%s☕", "🎄%s🎁" }
local PremiumLabels = { "💫PREMIUM💫", "✨PREMIUM✨", "🌟PREMIUM🌟", "⭐PREMIUM⭐", "🤩PREMIUM🤩" }


--! Names Handler

local function GetPlayerName(String)
    if typeof(String) == "string" and #String > 0 then
        for _, _Player in next, Players:GetPlayers() do
            if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                return _Player.Name
            end
        end
    end
    return ""
end


--! Fields

local Status = ""
local Fluent = nil
local ShowWarning = false

local RobloxActive = true
local Clock = os.clock()

local Aiming = false
local Target = nil
local Tween = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity

local Spinning = false
local Triggering = false
local ShowingFoV = false

do
    local Obsidian = nil
    if getgenv().KUSHAN and getgenv().KUSHAN.Library then
        Obsidian = getgenv().KUSHAN.Library
    else
        local Success, Result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
        end)
        if Success then
            Obsidian = Result
        end
    end

    if Obsidian then
        Fluent = Obsidian
        Fluent.Options = Fluent.Options or {}
    end
end

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Fluent then
        SensitivityChanged:Disconnect()
    elseif not Aiming or not DEBUG and (getfenv().mousemoverel and IsComputer and Configuration.AimMode == "Mouse" or getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod) then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)


--! UI Initializer

do
    local Window = Fluent and Fluent:CreateWindow({
        Title = "Open Aimbot",
        Footer = "By @ttwiz_z",
        NotifySide = "Right",
        Icon = 101385867250567,
    }) or nil

    if not Window then
        return
    end

    local function compatOption(option, key, value)
        if option and typeof(option) == "table" then
            option.Value = option.Value ~= nil and option.Value or value
            if type(option.SetValue) ~= "function" then
                function option:SetValue(v)
                    self.Value = v
                end
            end
            if Fluent and Fluent.Options then
                Fluent.Options[key] = option
            end
        end
        return option
    end

    local function makeToggle(group, key, text, default, callback)
        local option = group:AddToggle(key, {
            Text = text,
            Default = default,
            Callback = function(value)
                if callback then callback(value) end
            end,
        })
        return compatOption(option, key, default)
    end

    local function makeDropdown(group, key, text, values, default, callback, multi)
        local defaultIndex = typeof(default) == "number" and default or table.find(values, default) or 1
        local option = group:AddDropdown(key, {
            Text = text,
            Values = values,
            Default = defaultIndex,
            Multi = multi or false,
            Callback = function(value)
                if callback then callback(value) end
            end,
        })
        return compatOption(option, key, default)
    end

    local function makeSlider(group, key, text, value, min, max, callback, suffix, rounding)
        local option = group:AddSlider(key, {
            Text = text,
            Default = value,
            Min = min,
            Max = max,
            Rounding = rounding or 1,
            Suffix = suffix or "",
            Callback = function(v)
                if callback then callback(v) end
            end,
        })
        return compatOption(option, key, value)
    end

    local function makeInput(group, key, text, default, callback, numeric)
        local option = group:AddInput(key, {
            Text = text,
            Default = default,
            Numeric = numeric or false,
            Finished = true,
            Callback = function(value)
                if callback then callback(value) end
            end,
        })
        return compatOption(option, key, default)
    end

    local function makeKeyPicker(group, key, text, default, callback)
        local option = group:AddKeyPicker(key, {
            Text = text,
            Default = default,
            Mode = "Toggle",
        })
        if option and type(option.OnChanged) == "function" then
            option:OnChanged(function(value)
                if callback then callback(value) end
            end)
        end
        return compatOption(option, key, default)
    end

    local function makeButton(group, text, callback)
        return group:AddButton(text, function()
            if callback then callback() end
        end)
    end

    local function notifyDialog(title, content)
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = 3,
        })
    end

    local Tabs = {
        Aimbot = Window:AddTab("Aimbot", "crosshair"),
        Bots = Window:AddTab("Bots", "bot"),
        Checks = Window:AddTab("Checks", "list-checks"),
        Visuals = Window:AddTab("Visuals", "box"),
        Settings = Window:AddTab("Settings", "settings")
    }

    local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox("Aimbot")
    local AimOffsetGroup = Tabs.Aimbot:AddRightGroupbox("Aim Offset")
    local SensitivityGroup = Tabs.Aimbot:AddRightGroupbox("Sensitivity & Noise")

    makeToggle(AimbotGroup, "Aimbot", "Aimbot", Configuration.Aimbot, function(Value)
        Configuration.Aimbot = Value
        if not IsComputer then Aiming = Value end
    end)

    if IsComputer then
        makeToggle(AimbotGroup, "OnePressAimingMode", "One-Press Mode", Configuration.OnePressAimingMode, function(Value)
            Configuration.OnePressAimingMode = Value
        end)

        makeKeyPicker(AimbotGroup, "AimKey", "Aim Key", Configuration.AimKey, function(Value)
            Configuration.AimKey = Value
        end)
    end

    makeDropdown(AimbotGroup, "AimMode", "Aim Mode", { "Camera", "Mouse", "Silent" }, Configuration.AimMode, function(Value)
        Configuration.AimMode = Value
    end)

    if getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod then
        makeDropdown(AimbotGroup, "SilentAimMethods", "Silent Aim Methods", { "Mouse.Hit / Mouse.Target", "GetMouseLocation", "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist" }, 1, function(Value)
            Configuration.SilentAimMethods = typeof(Value) == "table" and Value or { Value }
        end, true)

        makeSlider(AimbotGroup, "SilentAimChance", "Silent Aim Chance", Configuration.SilentAimChance, 1, 100, function(Value)
            Configuration.SilentAimChance = Value
        end, "%", 1)
    end

    makeToggle(AimbotGroup, "OffAimbotAfterKill", "Off After Kill", Configuration.OffAimbotAfterKill, function(Value)
        Configuration.OffAimbotAfterKill = Value
    end)

    makeDropdown(AimbotGroup, "AimPart", "Aim Part", Configuration.AimPartDropdownValues, Configuration.AimPart, function(Value)
        Configuration.AimPart = Value
    end)

    makeToggle(AimbotGroup, "RandomAimPart", "Random Aim Part", Configuration.RandomAimPart, function(Value)
        Configuration.RandomAimPart = Value
    end)

    makeInput(AimbotGroup, "AddAimPart", "Add Aim Part", "", function(Value)
        Value = tostring(Value or "")
        if #Value > 0 and not table.find(Configuration.AimPartDropdownValues, Value) then
            table.insert(Configuration.AimPartDropdownValues, Value)
            if Fluent.Options and Fluent.Options.AimPart then
                Fluent.Options.AimPart:SetValue(Value)
            end
        end
    end, false)

    makeInput(AimbotGroup, "RemoveAimPart", "Remove Aim Part", "", function(Value)
        Value = tostring(Value or "")
        if #Value > 0 and table.find(Configuration.AimPartDropdownValues, Value) then
            table.remove(Configuration.AimPartDropdownValues, table.find(Configuration.AimPartDropdownValues, Value))
        end
    end, false)

    makeToggle(AimOffsetGroup, "UseOffset", "Use Offset", Configuration.UseOffset, function(Value)
        Configuration.UseOffset = Value
    end)

    makeDropdown(AimOffsetGroup, "OffsetType", "Offset Type", { "Static", "Dynamic", "Static & Dynamic" }, Configuration.OffsetType, function(Value)
        Configuration.OffsetType = Value
    end)

    makeSlider(AimOffsetGroup, "StaticOffsetIncrement", "Static Offset Increment", Configuration.StaticOffsetIncrement, 1, 50, function(Value)
        Configuration.StaticOffsetIncrement = Value
    end, "", 1)

    makeSlider(AimOffsetGroup, "DynamicOffsetIncrement", "Dynamic Offset Increment", Configuration.DynamicOffsetIncrement, 1, 50, function(Value)
        Configuration.DynamicOffsetIncrement = Value
    end, "", 1)

    makeToggle(AimOffsetGroup, "AutoOffset", "Auto Offset", Configuration.AutoOffset, function(Value)
        Configuration.AutoOffset = Value
    end)

    makeSlider(AimOffsetGroup, "MaxAutoOffset", "Max Auto Offset", Configuration.MaxAutoOffset, 1, 50, function(Value)
        Configuration.MaxAutoOffset = Value
    end, "", 1)

    makeToggle(SensitivityGroup, "UseSensitivity", "Use Sensitivity", Configuration.UseSensitivity, function(Value)
        Configuration.UseSensitivity = Value
    end)

    makeSlider(SensitivityGroup, "Sensitivity", "Sensitivity", Configuration.Sensitivity, 1, 100, function(Value)
        Configuration.Sensitivity = Value
    end, "%", 1)

    makeToggle(SensitivityGroup, "UseNoise", "Use Noise", Configuration.UseNoise, function(Value)
        Configuration.UseNoise = Value
    end)

    makeSlider(SensitivityGroup, "NoiseFrequency", "Noise Frequency", Configuration.NoiseFrequency, 1, 100, function(Value)
        Configuration.NoiseFrequency = Value
    end, "%", 1)

    local BotGroup = Tabs.Bots:AddLeftGroupbox("SpinBot")
    local TriggerGroup = Tabs.Bots:AddRightGroupbox("TriggerBot")

    BotGroup:AddLabel("SpinBot does not function normally in RenderStepped Rendering Mode.", true)

    makeToggle(BotGroup, "SpinBot", "SpinBot", Configuration.SpinBot, function(Value)
        Configuration.SpinBot = Value
        if not IsComputer then Spinning = Value end
    end)

    if IsComputer then
        makeToggle(BotGroup, "OnePressSpinningMode", "One-Press Mode", Configuration.OnePressSpinningMode, function(Value)
            Configuration.OnePressSpinningMode = Value
        end)

        makeKeyPicker(BotGroup, "SpinKey", "Spin Key", Configuration.SpinKey, function(Value)
            Configuration.SpinKey = Value
        end)
    end

    makeSlider(BotGroup, "SpinBotVelocity", "SpinBot Velocity", Configuration.SpinBotVelocity, 1, 50, function(Value)
        Configuration.SpinBotVelocity = Value
    end, "", 1)

    makeDropdown(BotGroup, "SpinPart", "Spin Part", Configuration.SpinPartDropdownValues, Configuration.SpinPart, function(Value)
        Configuration.SpinPart = Value
    end)

    makeToggle(BotGroup, "RandomSpinPart", "Random Spin Part", Configuration.RandomSpinPart, function(Value)
        Configuration.RandomSpinPart = Value
    end)

    if getfenv().mouse1click and IsComputer then
        makeToggle(TriggerGroup, "TriggerBot", "TriggerBot", Configuration.TriggerBot, function(Value)
            Configuration.TriggerBot = Value
        end)

        makeToggle(TriggerGroup, "OnePressTriggeringMode", "One-Press Mode", Configuration.OnePressTriggeringMode, function(Value)
            Configuration.OnePressTriggeringMode = Value
        end)

        makeToggle(TriggerGroup, "SmartTriggerBot", "Smart TriggerBot", Configuration.SmartTriggerBot, function(Value)
            Configuration.SmartTriggerBot = Value
        end)

        makeKeyPicker(TriggerGroup, "TriggerKey", "Trigger Key", Configuration.TriggerKey, function(Value)
            Configuration.TriggerKey = Value
        end)

        makeSlider(TriggerGroup, "TriggerBotChance", "TriggerBot Chance", Configuration.TriggerBotChance, 1, 100, function(Value)
            Configuration.TriggerBotChance = Value
        end, "%", 1)
    end

    local SimpleChecks = Tabs.Checks:AddLeftGroupbox("Simple Checks")
    local AdvancedChecks = Tabs.Checks:AddRightGroupbox("Advanced Checks")
    local ExpertChecks = Tabs.Checks:AddLeftGroupbox("Expert Checks")

    makeToggle(SimpleChecks, "AliveCheck", "Alive Check", Configuration.AliveCheck, function(Value) Configuration.AliveCheck = Value end)
    makeToggle(SimpleChecks, "GodCheck", "God Check", Configuration.GodCheck, function(Value) Configuration.GodCheck = Value end)
    makeToggle(SimpleChecks, "TeamCheck", "Team Check", Configuration.TeamCheck, function(Value) Configuration.TeamCheck = Value end)
    makeToggle(SimpleChecks, "FriendCheck", "Friend Check", Configuration.FriendCheck, function(Value) Configuration.FriendCheck = Value end)
    makeToggle(SimpleChecks, "FollowCheck", "Follow Check", Configuration.FollowCheck, function(Value) Configuration.FollowCheck = Value end)
    makeToggle(SimpleChecks, "VerifiedBadgeCheck", "Verified Badge Check", Configuration.VerifiedBadgeCheck, function(Value) Configuration.VerifiedBadgeCheck = Value end)
    makeToggle(SimpleChecks, "WallCheck", "Wall Check", Configuration.WallCheck, function(Value) Configuration.WallCheck = Value end)
    makeToggle(SimpleChecks, "WaterCheck", "Water Check", Configuration.WaterCheck, function(Value) Configuration.WaterCheck = Value end)

    makeToggle(AdvancedChecks, "FoVCheck", "FoV Check", Configuration.FoVCheck, function(Value) Configuration.FoVCheck = Value end)
    makeSlider(AdvancedChecks, "FoVRadius", "FoV Radius", Configuration.FoVRadius, 10, 1000, function(Value) Configuration.FoVRadius = Value end, "", 1)
    makeToggle(AdvancedChecks, "MagnitudeCheck", "Magnitude Check", Configuration.MagnitudeCheck, function(Value) Configuration.MagnitudeCheck = Value end)
    makeSlider(AdvancedChecks, "TriggerMagnitude", "Trigger Magnitude", Configuration.TriggerMagnitude, 10, 1000, function(Value) Configuration.TriggerMagnitude = Value end, "", 1)
    makeToggle(AdvancedChecks, "TransparencyCheck", "Transparency Check", Configuration.TransparencyCheck, function(Value) Configuration.TransparencyCheck = Value end)
    makeSlider(AdvancedChecks, "IgnoredTransparency", "Ignored Transparency", Configuration.IgnoredTransparency, 0.1, 1, function(Value) Configuration.IgnoredTransparency = Value end, "", 1)
    makeToggle(AdvancedChecks, "WhitelistedGroupCheck", "Whitelisted Group Check", Configuration.WhitelistedGroupCheck, function(Value) Configuration.WhitelistedGroupCheck = Value end)
    makeInput(AdvancedChecks, "WhitelistedGroup", "Whitelisted Group", tostring(Configuration.WhitelistedGroup), function(Value) Configuration.WhitelistedGroup = #tostring(Value) > 0 and tonumber(Value) or 0 end, true)
    makeToggle(AdvancedChecks, "BlacklistedGroupCheck", "Blacklisted Group Check", Configuration.BlacklistedGroupCheck, function(Value) Configuration.BlacklistedGroupCheck = Value end)
    makeInput(AdvancedChecks, "BlacklistedGroup", "Blacklisted Group", tostring(Configuration.BlacklistedGroup), function(Value) Configuration.BlacklistedGroup = #tostring(Value) > 0 and tonumber(Value) or 0 end, true)

    makeToggle(ExpertChecks, "IgnoredPlayersCheck", "Ignored Players Check", Configuration.IgnoredPlayersCheck, function(Value) Configuration.IgnoredPlayersCheck = Value end)
    makeDropdown(ExpertChecks, "IgnoredPlayers", "Ignored Players", Configuration.IgnoredPlayersDropdownValues, 1, function(Value) Configuration.IgnoredPlayers = typeof(Value) == "table" and Value or { Value } end, true)
    makeInput(ExpertChecks, "AddIgnoredPlayer", "Add Ignored Player", "", function(Value)
        Value = #GetPlayerName(Value or "") > 0 and GetPlayerName(Value or "") or tostring(Value or "")
        if #Value > 0 and not table.find(Configuration.IgnoredPlayersDropdownValues, Value) then
            table.insert(Configuration.IgnoredPlayersDropdownValues, Value)
        end
    end, false)

    makeToggle(ExpertChecks, "TargetPlayersCheck", "Target Players Check", Configuration.TargetPlayersCheck, function(Value) Configuration.TargetPlayersCheck = Value end)
    makeDropdown(ExpertChecks, "TargetPlayers", "Target Players", Configuration.TargetPlayersDropdownValues, 1, function(Value) Configuration.TargetPlayers = typeof(Value) == "table" and Value or { Value } end, true)
    makeInput(ExpertChecks, "AddTargetPlayer", "Add Target Player", "", function(Value)
        Value = #GetPlayerName(Value or "") > 0 and GetPlayerName(Value or "") or tostring(Value or "")
        if #Value > 0 and not table.find(Configuration.TargetPlayersDropdownValues, Value) then
            table.insert(Configuration.TargetPlayersDropdownValues, Value)
        end
    end, false)

    makeToggle(Tabs.Checks:AddRightGroupbox("Premium Checks"), "PremiumCheck", "Premium Check", Configuration.PremiumCheck, function(Value) Configuration.PremiumCheck = Value end)

    if DEBUG or getfenv().Drawing and getfenv().Drawing.new then
        local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("FoV")
        makeToggle(VisualsGroup, "FoV", "FoV", Configuration.FoV, function(Value)
            Configuration.FoV = Value
            if not IsComputer then ShowingFoV = Value end
        end)

        if IsComputer then
            makeKeyPicker(VisualsGroup, "FoVKey", "FoV Key", Configuration.FoVKey, function(Value)
                Configuration.FoVKey = Value
            end)
        end

        makeSlider(VisualsGroup, "FoVThickness", "FoV Thickness", Configuration.FoVThickness, 1, 10, function(Value)
            Configuration.FoVThickness = Value
        end, "", 1)

        makeSlider(VisualsGroup, "FoVOpacity", "FoV Opacity", Configuration.FoVOpacity, 0.1, 1, function(Value)
            Configuration.FoVOpacity = Value
        end, "", 1)

        makeToggle(VisualsGroup, "FoVFilled", "FoV Filled", Configuration.FoVFilled, function(Value)
            Configuration.FoVFilled = Value
        end)
    end

    local SettingsGroup = Tabs.Settings:AddLeftGroupbox("UI")
    local SettingsExtras = Tabs.Settings:AddRightGroupbox("Notifications & Warnings")

    makeToggle(SettingsExtras, "ShowNotifications", "Show Notifications", UISettings.ShowNotifications, function(Value)
        UISettings.ShowNotifications = Value
        InterfaceManager:ExportSettings()
    end)

    makeToggle(SettingsExtras, "ShowWarnings", "Show Warnings", UISettings.ShowWarnings, function(Value)
        UISettings.ShowWarnings = Value
        InterfaceManager:ExportSettings()
    end)

    makeDropdown(SettingsGroup, "RenderingMode", "Rendering Mode", { "Heartbeat", "RenderStepped", "Stepped" }, UISettings.RenderingMode, function(Value)
        UISettings.RenderingMode = Value
        InterfaceManager:ExportSettings()
        notifyDialog("Open Aimbot", "Changes will take effect after the Restart!")
    end)

    if getfenv().isfile and getfenv().readfile and getfenv().writefile and getfenv().delfile then
        local ConfigGroup = Tabs.Settings:AddLeftGroupbox("Configuration Manager")
        makeToggle(ConfigGroup, "AutoImport", "Auto Import", UISettings.AutoImport, function(Value)
            UISettings.AutoImport = Value
            InterfaceManager:ExportSettings()
        end)

        makeButton(ConfigGroup, "Import Configuration File", function()
            if getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
                local ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
                for Key, Value in next, ImportedConfiguration do
                    if Key == "AimKey" or Key == "SpinKey" or Key == "TriggerKey" or Key == "FoVKey" then
                        if Fluent.Options and Fluent.Options[Key] then
                            Fluent.Options[Key]:SetValue(Value)
                        end
                        Configuration[Key] = Value ~= "RMB" and Enum.KeyCode[Value] or Enum.UserInputType.MouseButton2
                    elseif Key == "AimPart" or Key == "SpinPart" or typeof(Configuration[Key]) == "table" then
                        Configuration[Key] = Value
                    elseif Key == "FoVColour" then
                        if Fluent.Options and Fluent.Options[Key] then
                            Fluent.Options[Key]:SetValue(ColorsHandler:UnpackColour(Value))
                        end
                    elseif Configuration[Key] ~= nil and Fluent.Options and Fluent.Options[Key] then
                        Fluent.Options[Key]:SetValue(Value)
                    end
                end
                notifyDialog("Configuration Manager", string.format("Configuration File %s.ttwizz has been successfully loaded!", game.GameId))
            else
                notifyDialog("Configuration Manager", string.format("Configuration File %s.ttwizz could not be found!", game.GameId))
            end
        end)

        makeButton(ConfigGroup, "Export Configuration File", function()
            local ExportedConfiguration = { __LAST_UPDATED__ = os.date() }
            for Key, Value in next, Configuration do
                if Key == "AimKey" or Key == "SpinKey" or Key == "TriggerKey" or Key == "FoVKey" then
                    ExportedConfiguration[Key] = Fluent.Options and Fluent.Options[Key] and Fluent.Options[Key].Value or Value
                elseif Key == "FoVColour" then
                    ExportedConfiguration[Key] = ColorsHandler:PackColour(Value)
                else
                    ExportedConfiguration[Key] = Value
                end
            end
            getfenv().writefile(string.format("%s.ttwizz", game.GameId), HttpService:JSONEncode(ExportedConfiguration))
            notifyDialog("Configuration Manager", string.format("Configuration File %s.ttwizz has been successfully overwritten!", game.GameId))
        end)

        makeButton(ConfigGroup, "Delete Configuration File", function()
            if getfenv().isfile(string.format("%s.ttwizz", game.GameId)) then
                getfenv().delfile(string.format("%s.ttwizz", game.GameId))
                notifyDialog("Configuration Manager", string.format("Configuration File %s.ttwizz has been successfully removed!", game.GameId))
            else
                notifyDialog("Configuration Manager", string.format("Configuration File %s.ttwizz could not be found!", game.GameId))
            end
        end)
    end

    local WikiGroup = Tabs.Settings:AddRightGroupbox("Discord & Wiki")
    if getfenv().setclipboard then
        makeButton(WikiGroup, "Copy Invite Link", function()
            getfenv().setclipboard("https://twix.cyou/pix")
            notifyDialog("Open Aimbot", "Invite Link has been copied to the Clipboard!")
        end)

        makeButton(WikiGroup, "Copy Wiki Link", function()
            getfenv().setclipboard("https://moderka.org/Open-Aimbot")
            notifyDialog("Open Aimbot", "Wiki Link has been copied to the Clipboard!")
        end)
    else
        WikiGroup:AddLabel("https://twix.cyou/pix", true)
        WikiGroup:AddLabel("https://moderka.org/Open-Aimbot", true)
    end

    if UISettings.ShowWarnings then
        if DEBUG then
            notifyDialog("Warning", "Running in Debugging Mode. Some Features may not work properly.")
        elseif ShowWarning then
            notifyDialog("Warning", string.format("Your Software does not support all the Features of Open Aimbot!"))
        else
            notifyDialog("Open Aimbot", "✨Upgrade to unlock all Options✨ – Contact @ttwiz_z via Discord to buy")
        end
    end
end


--! Notifications Handler

local function Notify(Message)
    if Fluent and typeof(Message) == "string" then
        Fluent:Notify({
            Title = string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")),
            Content = Message,
            Duration = 1.5,
        })
    end
end

Notify("✨Upgrade to unlock all Options✨")


--! Fields Handler

local FieldsHandler = {}

function FieldsHandler:ResetAimbotFields(SaveAiming, SaveTarget)
    Aiming = SaveAiming and Aiming or false
    Target = SaveTarget and Target or nil
    if Tween then
        Tween:Cancel()
        Tween = nil
    end
    UserInputService.MouseDeltaSensitivity = MouseSensitivity
end

function FieldsHandler:ResetSecondaryFields()
    Spinning   = false
    Triggering = false
    ShowingFoV = false
end


--! Input Handler

do
    if IsComputer then
        local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
            if not Fluent then
                InputBegan:Disconnect()
            elseif not UserInputService:GetFocusedTextBox() then
                if Configuration.Aimbot and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                    if Aiming then
                        FieldsHandler:ResetAimbotFields()
                        Notify("[Aiming Mode]: OFF")
                    else
                        Aiming = true
                        Notify("[Aiming Mode]: ON")
                    end
                elseif Configuration.SpinBot and (Input.KeyCode == Configuration.SpinKey or Input.UserInputType == Configuration.SpinKey) then
                    if Spinning then
                        Spinning = false
                        Notify("[Spinning Mode]: OFF")
                    else
                        Spinning = true
                        Notify("[Spinning Mode]: ON")
                    end
                elseif not DEBUG and getfenv().mouse1click and Configuration.TriggerBot and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
                    if Triggering then
                        Triggering = false
                        Notify("[Triggering Mode]: OFF")
                    else
                        Triggering = true
                        Notify("[Triggering Mode]: ON")
                    end
                elseif not DEBUG and getfenv().Drawing and getfenv().Drawing.new and Configuration.FoV and (Input.KeyCode == Configuration.FoVKey or Input.UserInputType == Configuration.FoVKey) then
                    if ShowingFoV then
                        ShowingFoV = false
                        Notify("[FoV Show]: OFF")
                    else
                        ShowingFoV = true
                        Notify("[FoV Show]: ON")
                    end
                end
            end
        end)

        local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
            if not Fluent then
                InputEnded:Disconnect()
            elseif not UserInputService:GetFocusedTextBox() then
                if Aiming and not Configuration.OnePressAimingMode and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                    FieldsHandler:ResetAimbotFields()
                    Notify("[Aiming Mode]: OFF")
                elseif Spinning and not Configuration.OnePressSpinningMode and (Input.KeyCode == Configuration.SpinKey or Input.UserInputType == Configuration.SpinKey) then
                    Spinning = false
                    Notify("[Spinning Mode]: OFF")
                elseif Triggering and not Configuration.OnePressTriggeringMode and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
                    Triggering = false
                    Notify("[Triggering Mode]: OFF")
                end
            end
        end)

        local WindowFocused; WindowFocused = UserInputService.WindowFocused:Connect(function()
            if not Fluent then WindowFocused:Disconnect()
            else RobloxActive = true end
        end)

        local WindowFocusReleased; WindowFocusReleased = UserInputService.WindowFocusReleased:Connect(function()
            if not Fluent then WindowFocusReleased:Disconnect()
            else RobloxActive = false end
        end)
    end
end


--! Math Handler

local MathHandler = {}

function MathHandler:CalculateDirection(Origin, Position, Magnitude)
    return typeof(Origin) == "Vector3" and typeof(Position) == "Vector3" and typeof(Magnitude) == "number" and (Position - Origin).Unit * Magnitude or Vector3.zero
end

function MathHandler:CalculateChance(Percentage)
    return typeof(Percentage) == "number" and math.round(math.clamp(Percentage, 1, 100)) / 100 >= math.round(Random.new():NextNumber() * 100) / 100 or false
end

function MathHandler:Abbreviate(Number)
    if typeof(Number) == "number" then
        local Abbreviations = { D=10^33,N=10^30,O=10^27,Sp=10^24,Sx=10^21,Qn=10^18,Qd=10^15,T=10^12,B=10^9,M=10^6,K=10^3 }
        local Selected, Result = 0, tostring(math.round(Number))
        for Key, Value in next, Abbreviations do
            if math.abs(Number) < 10^36 then
                if math.abs(Number) >= Value and Value > Selected then
                    Selected = Value
                    Result = string.format("%s%s", tostring(math.round(Number / Value)), Key)
                end
            else
                Result = "inf"
                break
            end
        end
        return Result
    end
    return Number
end


--! Targets Handler

local function IsReady(Target)
    if Target and Target:FindFirstChildWhichIsA("Humanoid") and Configuration.AimPart and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
        local _Player = Players:GetPlayerFromCharacter(Target)
        if not _Player or _Player == Player then return false end
        local Humanoid   = Target:FindFirstChildWhichIsA("Humanoid")
        local Head       = Target:FindFirstChildWhichIsA("Head")
        local TargetPart = Target:FindFirstChild(Configuration.AimPart)
        local NativePart = Player.Character and Player.Character:FindFirstChild(Configuration.AimPart)
        if not NativePart then return false end
        if Configuration.AliveCheck and Humanoid.Health == 0 or Configuration.GodCheck and (Humanoid.Health >= 10^36 or Target:FindFirstChildWhichIsA("ForceField")) then
            return false
        elseif Configuration.TeamCheck and _Player.TeamColor == Player.TeamColor or Configuration.FriendCheck and _Player:IsFriendsWith(Player.UserId) then
            return false
        elseif Configuration.FollowCheck and _Player.FollowUserId == Player.UserId or Configuration.VerifiedBadgeCheck and _Player.HasVerifiedBadge then
            return false
        elseif Configuration.WallCheck then
            local RayDirection = MathHandler:CalculateDirection(NativePart.Position, TargetPart.Position, (TargetPart.Position - NativePart.Position).Magnitude)
            local RaycastParameters = RaycastParams.new()
            RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
            RaycastParameters.FilterDescendantsInstances = { Player.Character }
            RaycastParameters.IgnoreWater = not Configuration.WaterCheck
            local RaycastResult = workspace:Raycast(NativePart.Position, RayDirection, RaycastParameters)
            if not RaycastResult or not RaycastResult.Instance or not RaycastResult.Instance:FindFirstAncestor(_Player.Name) then
                return false
            end
        elseif Configuration.MagnitudeCheck and (TargetPart.Position - NativePart.Position).Magnitude > Configuration.TriggerMagnitude then
            return false
        elseif Configuration.TransparencyCheck and Head and Head:IsA("BasePart") and Head.Transparency >= Configuration.IgnoredTransparency then
            return false
        elseif Configuration.WhitelistedGroupCheck and _Player:IsInGroup(Configuration.WhitelistedGroup) or Configuration.BlacklistedGroupCheck and not _Player:IsInGroup(Configuration.BlacklistedGroup) then
            return false
        elseif Configuration.IgnoredPlayersCheck and table.find(Configuration.IgnoredPlayers, _Player.Name) or Configuration.TargetPlayersCheck and not table.find(Configuration.TargetPlayers, _Player.Name) then
            return false
        end
        local OffsetIncrement = Configuration.UseOffset and (Configuration.AutoOffset and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 100, 0) or Vector3.new(0, Configuration.StaticOffsetIncrement, 0)) or Vector3.zero
        local NoiseFrequency = Configuration.UseNoise and Vector3.new(Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100), Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100), Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100)) or Vector3.zero
        return true, Target, { workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position + OffsetIncrement + NoiseFrequency) }, TargetPart.Position + OffsetIncrement + NoiseFrequency, (TargetPart.Position - NativePart.Position).Magnitude
    end
    return false
end


--! Arguments Handler

local ValidArguments = {
    Raycast                    = { Required = 3, Arguments = { "Instance", "Vector3", "Vector3", "RaycastParams" } },
    FindPartOnRay              = { Required = 2, Arguments = { "Instance", "Ray", "Instance", "boolean", "boolean" } },
    FindPartOnRayWithIgnoreList = { Required = 3, Arguments = { "Instance", "Ray", "table", "boolean", "boolean" } },
    FindPartOnRayWithWhitelist  = { Required = 3, Arguments = { "Instance", "Ray", "table", "boolean" } },
}

local function ValidateArguments(Arguments, Method)
    if typeof(Arguments) ~= "table" or typeof(Method) ~= "table" or #Arguments < Method.Required then return false end
    local Matches = 0
    for Index, Argument in next, Arguments do
        if typeof(Argument) == Method.Arguments[Index] then Matches = Matches + 1 end
    end
    return Matches >= Method.Required
end


--! Silent Aim Handler

do
    if not DEBUG and getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod then
        local OldIndex; OldIndex = getfenv().hookmetamethod(game, "__index", getfenv().newcclosure(function(self, Index)
            if Fluent and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and table.find(Configuration.SilentAimMethods, "Mouse.Hit / Mouse.Target") and Aiming and IsReady(Target) then
                if Index == "Hit" or Index == "hit" then
                    return select(6, IsReady(Target))
                elseif Index == "Target" or Index == "target" then
                    return select(7, IsReady(Target))
                elseif Index == "X" or Index == "x" then
                    return select(3, IsReady(Target))[1].X
                elseif Index == "Y" or Index == "y" then
                    return select(3, IsReady(Target))[1].Y
                elseif Index == "UnitRay" or Index == "unitRay" then
                    return Ray.new(self.Origin, (select(6, IsReady(Target)) - self.Origin).Unit)
                end
            end
            return OldIndex(self, Index)
        end))

        local OldNameCall; OldNameCall = getfenv().hookmetamethod(game, "__namecall", getfenv().newcclosure(function(...)
            local Method    = getfenv().getnamecallmethod()
            local Arguments = { ... }
            local self      = Arguments[1]
            if Fluent and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and Aiming and IsReady(Target) and select(3, IsReady(Target))[2] and MathHandler:CalculateChance(Configuration.SilentAimChance) then
                if table.find(Configuration.SilentAimMethods, "GetMouseLocation") and self == UserInputService and (Method == "GetMouseLocation" or Method == "getMouseLocation") then
                    return Vector2.new(select(3, IsReady(Target))[1].X, select(3, IsReady(Target))[1].Y)
                elseif table.find(Configuration.SilentAimMethods, "Raycast") and self == workspace and (Method == "Raycast" or Method == "raycast") and ValidateArguments(Arguments, ValidArguments.Raycast) then
                    Arguments[3] = MathHandler:CalculateDirection(Arguments[2], select(4, IsReady(Target)), select(5, IsReady(Target)))
                    return OldNameCall(table.unpack(Arguments))
                elseif table.find(Configuration.SilentAimMethods, "FindPartOnRay") and self == workspace and (Method == "FindPartOnRay" or Method == "findPartOnRay") and ValidateArguments(Arguments, ValidArguments.FindPartOnRay) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, MathHandler:CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                elseif table.find(Configuration.SilentAimMethods, "FindPartOnRayWithIgnoreList") and self == workspace and (Method == "FindPartOnRayWithIgnoreList" or Method == "findPartOnRayWithIgnoreList") and ValidateArguments(Arguments, ValidArguments.FindPartOnRayWithIgnoreList) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, MathHandler:CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                elseif table.find(Configuration.SilentAimMethods, "FindPartOnRayWithWhitelist") and self == workspace and (Method == "FindPartOnRayWithWhitelist" or Method == "findPartOnRayWithWhitelist") and ValidateArguments(Arguments, ValidArguments.FindPartOnRayWithWhitelist) then
                    Arguments[2] = Ray.new(Arguments[2].Origin, MathHandler:CalculateDirection(Arguments[2].Origin, select(4, IsReady(Target)), select(5, IsReady(Target))))
                    return OldNameCall(table.unpack(Arguments))
                end
            end
            return OldNameCall(...)
        end))
    end
end


--! Bots Handler

local function HandleBots()
    if Spinning and Configuration.SpinPart and Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid") and Player.Character:FindFirstChild(Configuration.SpinPart) and Player.Character:FindFirstChild(Configuration.SpinPart):IsA("BasePart") then
        Player.Character:FindFirstChild(Configuration.SpinPart).CFrame = Player.Character:FindFirstChild(Configuration.SpinPart).CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(Configuration.SpinBotVelocity), 0)
    end
    if not DEBUG and getfenv().mouse1click and IsComputer and Triggering and (Configuration.SmartTriggerBot and Aiming or not Configuration.SmartTriggerBot) and Mouse.Target and IsReady(Mouse.Target:FindFirstAncestorOfClass("Model")) then
        getfenv().mouse1click()
    end
end


--! Random Parts Handler

local function HandleRandomParts()
    if Fluent and os.clock() - Clock >= 1 then
        if Configuration.RandomAimPart and #Configuration.AimPartDropdownValues > 0 then
            if Fluent.Options and Fluent.Options.AimPart then
                Fluent.Options.AimPart:SetValue(Configuration.AimPartDropdownValues[Random.new():NextInteger(1, #Configuration.AimPartDropdownValues)])
            end
        end
        if Configuration.RandomSpinPart and #Configuration.SpinPartDropdownValues > 0 then
            if Fluent.Options and Fluent.Options.SpinPart then
                Fluent.Options.SpinPart:SetValue(Configuration.SpinPartDropdownValues[Random.new():NextInteger(1, #Configuration.SpinPartDropdownValues)])
            end
        end
        Clock = os.clock()
    end
end


--! Visuals Handler

local VisualsHandler = {}

function VisualsHandler:Visualize(Object)
    if not DEBUG and Fluent and getfenv().Drawing and getfenv().Drawing.new and typeof(Object) == "string" then
        if string.lower(Object) == "fov" then
            local FoV = getfenv().Drawing.new("Circle")
            FoV.Visible     = false
            FoV.ZIndex      = 4
            FoV.NumSides    = 1000
            FoV.Radius      = Configuration.FoVRadius
            FoV.Thickness   = Configuration.FoVThickness
            FoV.Transparency = Configuration.FoVOpacity
            FoV.Filled      = Configuration.FoVFilled
            FoV.Color       = Configuration.FoVColour
            return FoV
        end
    end
    return nil
end

local Visuals = { FoV = VisualsHandler:Visualize("FoV") }

function VisualsHandler:ClearVisual(Visual, Key)
    local FoundVisual = table.find(Visuals, Visual)
    if Visual and (FoundVisual or Key == "FoV") then
        if Visual.Destroy then Visual:Destroy()
        elseif Visual.Remove then Visual:Remove() end
        if FoundVisual then table.remove(Visuals, FoundVisual)
        elseif Key == "FoV" then Visuals.FoV = nil end
    end
end

function VisualsHandler:ClearVisuals()
    for Key, Visual in next, Visuals do
        self:ClearVisual(Visual, Key)
    end
end

function VisualsHandler:VisualizeFoV()
    if not Fluent then return self:ClearVisuals() end
    local MouseLocation = UserInputService:GetMouseLocation()
    Visuals.FoV.Position    = Vector2.new(MouseLocation.X, MouseLocation.Y)
    Visuals.FoV.Radius      = Configuration.FoVRadius
    Visuals.FoV.Thickness   = Configuration.FoVThickness
    Visuals.FoV.Transparency = Configuration.FoVOpacity
    Visuals.FoV.Filled      = Configuration.FoVFilled
    Visuals.FoV.Color       = Configuration.FoVColour
    Visuals.FoV.Visible     = ShowingFoV
end


--! Player Events Handler

local OnTeleport; OnTeleport = Player.OnTeleport:Connect(function()
    if DEBUG or not Fluent or not getfenv().queue_on_teleport then
        OnTeleport:Disconnect()
    else
        getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ttwizz/Open-Aimbot/master/source.lua\", true))()")
        OnTeleport:Disconnect()
    end
end)

local PlayerRemoving; PlayerRemoving = Players.PlayerRemoving:Connect(function(_Player)
    if not Fluent then
        PlayerRemoving:Disconnect()
    else
        if _Player == Player then
            Fluent:Destroy()
            FieldsHandler:ResetAimbotFields()
            FieldsHandler:ResetSecondaryFields()
            VisualsHandler:ClearVisuals()
            PlayerRemoving:Disconnect()
        end
    end
end)


--! Aimbot Handler

local AimbotLoop; AimbotLoop = RunService[UISettings.RenderingMode]:Connect(function()
    if Fluent and Fluent.Unloaded then
        Fluent = nil
        FieldsHandler:ResetAimbotFields()
        FieldsHandler:ResetSecondaryFields()
        VisualsHandler:ClearVisuals()
        AimbotLoop:Disconnect()
    elseif not Configuration.Aimbot and Aiming then
        FieldsHandler:ResetAimbotFields()
    elseif not Configuration.SpinBot and Spinning then
        Spinning = false
    elseif not Configuration.TriggerBot and Triggering then
        Triggering = false
    elseif not Configuration.FoV and ShowingFoV then
        ShowingFoV = false
    end
    if RobloxActive then
        HandleBots()
        HandleRandomParts()
        if not DEBUG and getfenv().Drawing and getfenv().Drawing.new then
            VisualsHandler:VisualizeFoV()
        end
        if Aiming then
            local OldTarget = Target
            local Closest   = math.huge
            if not IsReady(OldTarget) then
                if OldTarget and not Configuration.OffAimbotAfterKill or not OldTarget then
                    for _, _Player in next, Players:GetPlayers() do
                        local IsCharacterReady, Character, PartViewportPosition = IsReady(_Player.Character)
                        if IsCharacterReady and PartViewportPosition[2] then
                            local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(PartViewportPosition[1].X, PartViewportPosition[1].Y)).Magnitude
                            if Magnitude <= Closest and Magnitude <= (Configuration.FoVCheck and Configuration.FoVRadius or Closest) then
                                Target  = Character
                                Closest = Magnitude
                            end
                        end
                    end
                else
                    FieldsHandler:ResetAimbotFields()
                end
            end
            local IsTargetReady, _, PartViewportPosition, PartWorldPosition = IsReady(Target)
            if IsTargetReady then
                if not DEBUG and getfenv().mousemoverel and IsComputer and Configuration.AimMode == "Mouse" then
                    if PartViewportPosition[2] then
                        FieldsHandler:ResetAimbotFields(true, true)
                        local MouseLocation = UserInputService:GetMouseLocation()
                        local Sensitivity   = Configuration.UseSensitivity and Configuration.Sensitivity / 5 or 10
                        getfenv().mousemoverel((PartViewportPosition[1].X - MouseLocation.X) / Sensitivity, (PartViewportPosition[1].Y - MouseLocation.Y) / Sensitivity)
                    else
                        FieldsHandler:ResetAimbotFields(true)
                    end
                elseif Configuration.AimMode == "Camera" then
                    UserInputService.MouseDeltaSensitivity = 0
                    if Configuration.UseSensitivity then
                        Tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(math.clamp(Configuration.Sensitivity, 9, 99) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition) })
                        Tween:Play()
                    else
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition)
                    end
                elseif not DEBUG and getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod and Configuration.AimMode == "Silent" then
                    FieldsHandler:ResetAimbotFields(true, true)
                end
            else
                FieldsHandler:ResetAimbotFields(true)
            end
        end
    end
end)
