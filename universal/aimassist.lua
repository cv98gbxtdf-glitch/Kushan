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


--! Hub

local K = getgenv().KUSHAN

if not K or not K.Library or not K.Window then
    return
end

local Library = K.Library


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
    if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) and UISettings.AutoImport then
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


--! Key Handler

local function KeyToString(Value)
    if typeof(Value) == "EnumItem" then
        if Value.EnumType == Enum.UserInputType then
            return Value == Enum.UserInputType.MouseButton1 and "MB1" or Value == Enum.UserInputType.MouseButton2 and "MB2" or Value == Enum.UserInputType.MouseButton3 and "MB3" or Value.Name
        end
        return Value.Name
    end
    if Value == "RMB" then
        return "MB2"
    elseif Value == "LMB" then
        return "MB1"
    elseif Value == "MMB" then
        return "MB3"
    end
    return typeof(Value) == "string" and Value or "None"
end

local function StringToKey(Value)
    if Value == "RMB" or Value == "MB2" then
        return Enum.UserInputType.MouseButton2
    elseif Value == "LMB" or Value == "MB1" then
        return Enum.UserInputType.MouseButton1
    elseif Value == "MMB" or Value == "MB3" then
        return Enum.UserInputType.MouseButton3
    elseif typeof(Value) == "string" and Value ~= "None" then
        return Enum.KeyCode[Value]
    end
    return nil
end

local function ToKeyCode(Value)
    local Key = StringToKey(Value)
    if Key and Key.EnumType == Enum.KeyCode then
        return Key
    end
    return Enum.KeyCode.RightShift
end


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

Library.ToggleKeybind = ToKeyCode(UISettings.MinimizeKey)

local SensitivityChanged; SensitivityChanged = UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Library then
        SensitivityChanged:Disconnect()
    elseif not Aiming or not DEBUG and (getfenv().mousemoverel and IsComputer and Configuration.AimMode == "Mouse" or getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod and Configuration.AimMode == "Silent") then
        MouseSensitivity = UserInputService.MouseDeltaSensitivity
    end
end)


--! UI Initializer

do
    local Window = K.Window

    local DialogIndex = 0

    local function ShowDialog(Info)
        if Library.ActiveDialog then
            pcall(function()
                Library.ActiveDialog:Dismiss()
            end)
        end
        DialogIndex = DialogIndex + 1
        return Window:AddDialog(DialogIndex, Info)
    end

    local function AddInfo(Tab, Title, Content)
        local Box = Tab:AddLeftGroupbox(Title, nil, true, false, true)
        Box:AddLabel(Content, true)
        return Box
    end

    local Tabs = {}

    Tabs.Aimbot = Window:AddTab("Aimbot", "crosshair")

    AddInfo(Tabs.Aimbot, string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")), "✨Universal Aim Assist Framework✨\nhttps://github.com/ttwizz/Open-Aimbot")

    local AimbotSection = Tabs.Aimbot:AddLeftGroupbox("Aimbot", "crosshair")

    local AimbotToggle = AimbotSection:AddToggle("Aimbot", { Text = "Aimbot", Tooltip = "Toggles the Aimbot", Default = Configuration.Aimbot })
    AimbotToggle:OnChanged(function(Value)
        Configuration.Aimbot = Value
        if not IsComputer then
            Aiming = Value
        end
    end)

    if IsComputer then
        local OnePressAimingModeToggle = AimbotSection:AddToggle("OnePressAimingMode", { Text = "One-Press Mode", Tooltip = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressAimingMode })
        OnePressAimingModeToggle:OnChanged(function(Value)
            Configuration.OnePressAimingMode = Value
        end)

        local AimKeybind = AimbotSection:AddLabel("Aim Key"):AddKeyPicker("AimKey", {
            Text = "Aim Key",
            Default = KeyToString(Configuration.AimKey),
            Mode = "Always",
            ChangedCallback = function(KeyCode)
                Configuration.AimKey = KeyCode
            end
        })
        Configuration.AimKey = StringToKey(AimKeybind.Value)
    end

    local AimModeDropdown = AimbotSection:AddDropdown("AimMode", {
        Text = "Aim Mode",
        Tooltip = "Changes the Aim Mode",
        Values = { "Camera" },
        Default = Configuration.AimMode,
        Callback = function(Value)
            Configuration.AimMode = Value
        end
    })
    if getfenv().mousemoverel and IsComputer then
        table.insert(AimModeDropdown.Values, "Mouse")
        AimModeDropdown:BuildDropdownList()
    else
        ShowWarning = true
    end
    if getfenv().hookmetamethod and getfenv().newcclosure and getfenv().checkcaller and getfenv().getnamecallmethod then
        table.insert(AimModeDropdown.Values, "Silent")
        AimModeDropdown:BuildDropdownList()

        local SilentAimMethodsDropdown = AimbotSection:AddDropdown("SilentAimMethods", {
            Text = "Silent Aim Methods",
            Tooltip = "Sets the Silent Aim Methods",
            Values = { "Mouse.Hit / Mouse.Target", "GetMouseLocation", "Raycast", "FindPartOnRay", "FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist" },
            Multi = true,
            Default = Configuration.SilentAimMethods
        })
        SilentAimMethodsDropdown:OnChanged(function(Value)
            Configuration.SilentAimMethods = {}
            for Key, _ in next, Value do
                if typeof(Key) == "string" then
                    table.insert(Configuration.SilentAimMethods, Key)
                end
            end
        end)

        AimbotSection:AddSlider("SilentAimChance", {
            Text = "Silent Aim Chance",
            Tooltip = "Changes the Hit Chance for Silent Aim",
            Default = Configuration.SilentAimChance,
            Min = 1,
            Max = 100,
            Rounding = 1,
            Callback = function(Value)
                Configuration.SilentAimChance = Value
            end
        })
    else
        ShowWarning = true
    end

    local OffAimbotAfterKillToggle = AimbotSection:AddToggle("OffAimbotAfterKill", { Text = "Off After Kill", Tooltip = "Disables the Aiming Mode after killing a Target", Default = Configuration.OffAimbotAfterKill })
    OffAimbotAfterKillToggle:OnChanged(function(Value)
        Configuration.OffAimbotAfterKill = Value
    end)

    local AimPartDropdown = AimbotSection:AddDropdown("AimPart", {
        Text = "Aim Part",
        Tooltip = "Changes the Aim Part",
        Values = Configuration.AimPartDropdownValues,
        Default = Configuration.AimPart,
        Callback = function(Value)
            Configuration.AimPart = Value
        end
    })

    local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPart", { Text = "Random Aim Part", Tooltip = "Selects every second a Random Aim Part from Dropdown", Default = Configuration.RandomAimPart })
    RandomAimPartToggle:OnChanged(function(Value)
        Configuration.RandomAimPart = Value
    end)

    AimbotSection:AddInput("AddAimPart", {
        Text = "Add Aim Part",
        Tooltip = "After typing, press Enter",
        Finished = true,
        Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and not table.find(Configuration.AimPartDropdownValues, Value) then
                table.insert(Configuration.AimPartDropdownValues, Value)
                AimPartDropdown:SetValue(Value)
            end
        end
    })

    AimbotSection:AddInput("RemoveAimPart", {
        Text = "Remove Aim Part",
        Tooltip = "After typing, press Enter",
        Finished = true,
        Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and table.find(Configuration.AimPartDropdownValues, Value) then
                if Configuration.AimPart == Value then
                    AimPartDropdown:SetValue(nil)
                end
                table.remove(Configuration.AimPartDropdownValues, table.find(Configuration.AimPartDropdownValues, Value))
                AimPartDropdown:SetValues(Configuration.AimPartDropdownValues)
            end
        end
    })

    AimbotSection:AddButton({
        Text = "Clear All Items",
        Tooltip = "Removes All Elements",
        Func = function()
            local Items = #Configuration.AimPartDropdownValues
            AimPartDropdown:SetValue(nil)
            Configuration.AimPartDropdownValues = {}
            AimPartDropdown:SetValues(Configuration.AimPartDropdownValues)
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been cleared!" or Items == 1 and "1 Item has been cleared!" or string.format("%s Items have been cleared!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    local AimOffsetSection = Tabs.Aimbot:AddRightGroupbox("Aim Offset")

    local UseOffsetToggle = AimOffsetSection:AddToggle("UseOffset", { Text = "Use Offset", Tooltip = "Toggles the Offset", Default = Configuration.UseOffset })
    UseOffsetToggle:OnChanged(function(Value)
        Configuration.UseOffset = Value
    end)

    AimOffsetSection:AddDropdown("OffsetType", {
        Text = "Offset Type",
        Tooltip = "Changes the Offset Type",
        Values = { "Static", "Dynamic", "Static & Dynamic" },
        Default = Configuration.OffsetType,
        Callback = function(Value)
            Configuration.OffsetType = Value
        end
    })

    AimOffsetSection:AddSlider("StaticOffsetIncrement", {
        Text = "Static Offset Increment",
        Default = Configuration.StaticOffsetIncrement,
        Min = 1, Max = 50, Rounding = 1,
        Callback = function(Value) Configuration.StaticOffsetIncrement = Value end
    })

    AimOffsetSection:AddSlider("DynamicOffsetIncrement", {
        Text = "Dynamic Offset Increment",
        Default = Configuration.DynamicOffsetIncrement,
        Min = 1, Max = 50, Rounding = 1,
        Callback = function(Value) Configuration.DynamicOffsetIncrement = Value end
    })

    local AutoOffsetToggle = AimOffsetSection:AddToggle("AutoOffset", { Text = "Auto Offset", Default = Configuration.AutoOffset })
    AutoOffsetToggle:OnChanged(function(Value) Configuration.AutoOffset = Value end)

    AimOffsetSection:AddSlider("MaxAutoOffset", {
        Text = "Max Auto Offset",
        Default = Configuration.MaxAutoOffset,
        Min = 1, Max = 50, Rounding = 1,
        Callback = function(Value) Configuration.MaxAutoOffset = Value end
    })

    local SensitivityNoiseSection = Tabs.Aimbot:AddRightGroupbox("Sensitivity & Noise")

    local UseSensitivityToggle = SensitivityNoiseSection:AddToggle("UseSensitivity", { Text = "Use Sensitivity", Default = Configuration.UseSensitivity })
    UseSensitivityToggle:OnChanged(function(Value) Configuration.UseSensitivity = Value end)

    SensitivityNoiseSection:AddSlider("Sensitivity", {
        Text = "Sensitivity",
        Tooltip = "Smoothes out the Mouse / Camera Movements when Aiming",
        Default = Configuration.Sensitivity,
        Min = 1, Max = 100, Rounding = 1,
        Callback = function(Value) Configuration.Sensitivity = Value end
    })

    local UseNoiseToggle = SensitivityNoiseSection:AddToggle("UseNoise", { Text = "Use Noise", Default = Configuration.UseNoise })
    UseNoiseToggle:OnChanged(function(Value) Configuration.UseNoise = Value end)

    SensitivityNoiseSection:AddSlider("NoiseFrequency", {
        Text = "Noise Frequency",
        Default = Configuration.NoiseFrequency,
        Min = 1, Max = 100, Rounding = 1,
        Callback = function(Value) Configuration.NoiseFrequency = Value end
    })

    Tabs.Bots = Window:AddTab("Bots", "bot")

    AddInfo(Tabs.Bots, string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")), "✨Universal Aim Assist Framework✨\nhttps://github.com/ttwizz/Open-Aimbot")

    local SpinBotSection = Tabs.Bots:AddLeftGroupbox("SpinBot")

    SpinBotSection:AddLabel("NOTE: SpinBot does not function normally in RenderStepped Rendering Mode.", true)

    local SpinBotToggle = SpinBotSection:AddToggle("SpinBot", { Text = "SpinBot", Default = Configuration.SpinBot })
    SpinBotToggle:OnChanged(function(Value)
        Configuration.SpinBot = Value
        if not IsComputer then Spinning = Value end
    end)

    if IsComputer then
        local OnePressSpinningModeToggle = SpinBotSection:AddToggle("OnePressSpinningMode", { Text = "One-Press Mode", Default = Configuration.OnePressSpinningMode })
        OnePressSpinningModeToggle:OnChanged(function(Value) Configuration.OnePressSpinningMode = Value end)

        local SpinKeybind = SpinBotSection:AddLabel("Spin Key"):AddKeyPicker("SpinKey", {
            Text = "Spin Key",
            Default = KeyToString(Configuration.SpinKey),
            Mode = "Always",
            ChangedCallback = function(KeyCode) Configuration.SpinKey = KeyCode end
        })
        Configuration.SpinKey = StringToKey(SpinKeybind.Value)
    end

    SpinBotSection:AddSlider("SpinBotVelocity", {
        Text = "SpinBot Velocity",
        Default = Configuration.SpinBotVelocity,
        Min = 1, Max = 50, Rounding = 1,
        Callback = function(Value) Configuration.SpinBotVelocity = Value end
    })

    local SpinPartDropdown = SpinBotSection:AddDropdown("SpinPart", {
        Text = "Spin Part",
        Values = Configuration.SpinPartDropdownValues,
        Default = Configuration.SpinPart,
        Callback = function(Value) Configuration.SpinPart = Value end
    })

    local RandomSpinPartToggle = SpinBotSection:AddToggle("RandomSpinPart", { Text = "Random Spin Part", Default = Configuration.RandomSpinPart })
    RandomSpinPartToggle:OnChanged(function(Value) Configuration.RandomSpinPart = Value end)

    SpinBotSection:AddInput("AddSpinPart", {
        Text = "Add Spin Part", Finished = true, Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and not table.find(Configuration.SpinPartDropdownValues, Value) then
                table.insert(Configuration.SpinPartDropdownValues, Value)
                SpinPartDropdown:SetValue(Value)
            end
        end
    })

    SpinBotSection:AddInput("RemoveSpinPart", {
        Text = "Remove Spin Part", Finished = true, Placeholder = "Part Name",
        Callback = function(Value)
            if #Value > 0 and table.find(Configuration.SpinPartDropdownValues, Value) then
                if Configuration.SpinPart == Value then SpinPartDropdown:SetValue(nil) end
                table.remove(Configuration.SpinPartDropdownValues, table.find(Configuration.SpinPartDropdownValues, Value))
                SpinPartDropdown:SetValues(Configuration.SpinPartDropdownValues)
            end
        end
    })

    SpinBotSection:AddButton({
        Text = "Clear All Items",
        Func = function()
            local Items = #Configuration.SpinPartDropdownValues
            SpinPartDropdown:SetValue(nil)
            Configuration.SpinPartDropdownValues = {}
            SpinPartDropdown:SetValues(Configuration.SpinPartDropdownValues)
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been cleared!" or Items == 1 and "1 Item has been cleared!" or string.format("%s Items have been cleared!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    if getfenv().mouse1click and IsComputer then
        local TriggerBotSection = Tabs.Bots:AddRightGroupbox("TriggerBot")

        local TriggerBotToggle = TriggerBotSection:AddToggle("TriggerBot", { Text = "TriggerBot", Default = Configuration.TriggerBot })
        TriggerBotToggle:OnChanged(function(Value) Configuration.TriggerBot = Value end)

        local OnePressTriggeringModeToggle = TriggerBotSection:AddToggle("OnePressTriggeringMode", { Text = "One-Press Mode", Default = Configuration.OnePressTriggeringMode })
        OnePressTriggeringModeToggle:OnChanged(function(Value) Configuration.OnePressTriggeringMode = Value end)

        local SmartTriggerBotToggle = TriggerBotSection:AddToggle("SmartTriggerBot", { Text = "Smart TriggerBot", Default = Configuration.SmartTriggerBot })
        SmartTriggerBotToggle:OnChanged(function(Value) Configuration.SmartTriggerBot = Value end)

        local TriggerKeybind = TriggerBotSection:AddLabel("Trigger Key"):AddKeyPicker("TriggerKey", {
            Text = "Trigger Key",
            Default = KeyToString(Configuration.TriggerKey),
            Mode = "Always",
            ChangedCallback = function(KeyCode) Configuration.TriggerKey = KeyCode end
        })
        Configuration.TriggerKey = StringToKey(TriggerKeybind.Value)

        TriggerBotSection:AddSlider("TriggerBotChance", {
            Text = "TriggerBot Chance",
            Default = Configuration.TriggerBotChance,
            Min = 1, Max = 100, Rounding = 1,
            Callback = function(Value) Configuration.TriggerBotChance = Value end
        })
    else
        ShowWarning = true
    end

    Tabs.Checks = Window:AddTab("Checks", "list-checks")

    AddInfo(Tabs.Checks, string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")), "✨Universal Aim Assist Framework✨\nhttps://github.com/ttwizz/Open-Aimbot")

    local SimpleChecksSection = Tabs.Checks:AddLeftGroupbox("Simple Checks")

    local AliveCheckToggle = SimpleChecksSection:AddToggle("AliveCheck", { Text = "Alive Check", Default = Configuration.AliveCheck })
    AliveCheckToggle:OnChanged(function(Value) Configuration.AliveCheck = Value end)

    local GodCheckToggle = SimpleChecksSection:AddToggle("GodCheck", { Text = "God Check", Default = Configuration.GodCheck })
    GodCheckToggle:OnChanged(function(Value) Configuration.GodCheck = Value end)

    local TeamCheckToggle = SimpleChecksSection:AddToggle("TeamCheck", { Text = "Team Check", Default = Configuration.TeamCheck })
    TeamCheckToggle:OnChanged(function(Value) Configuration.TeamCheck = Value end)

    local FriendCheckToggle = SimpleChecksSection:AddToggle("FriendCheck", { Text = "Friend Check", Default = Configuration.FriendCheck })
    FriendCheckToggle:OnChanged(function(Value) Configuration.FriendCheck = Value end)

    local FollowCheckToggle = SimpleChecksSection:AddToggle("FollowCheck", { Text = "Follow Check", Default = Configuration.FollowCheck })
    FollowCheckToggle:OnChanged(function(Value) Configuration.FollowCheck = Value end)

    local VerifiedBadgeCheckToggle = SimpleChecksSection:AddToggle("VerifiedBadgeCheck", { Text = "Verified Badge Check", Default = Configuration.VerifiedBadgeCheck })
    VerifiedBadgeCheckToggle:OnChanged(function(Value) Configuration.VerifiedBadgeCheck = Value end)

    local WallCheckToggle = SimpleChecksSection:AddToggle("WallCheck", { Text = "Wall Check", Default = Configuration.WallCheck })
    WallCheckToggle:OnChanged(function(Value) Configuration.WallCheck = Value end)

    local WaterCheckToggle = SimpleChecksSection:AddToggle("WaterCheck", { Text = "Water Check", Default = Configuration.WaterCheck })
    WaterCheckToggle:OnChanged(function(Value) Configuration.WaterCheck = Value end)

    local AdvancedChecksSection = Tabs.Checks:AddRightGroupbox("Advanced Checks")

    local FoVCheckToggle = AdvancedChecksSection:AddToggle("FoVCheck", { Text = "FoV Check", Default = Configuration.FoVCheck })
    FoVCheckToggle:OnChanged(function(Value) Configuration.FoVCheck = Value end)

    AdvancedChecksSection:AddSlider("FoVRadius", {
        Text = "FoV Radius", Default = Configuration.FoVRadius,
        Min = 10, Max = 1000, Rounding = 1,
        Callback = function(Value) Configuration.FoVRadius = Value end
    })

    local MagnitudeCheckToggle = AdvancedChecksSection:AddToggle("MagnitudeCheck", { Text = "Magnitude Check", Default = Configuration.MagnitudeCheck })
    MagnitudeCheckToggle:OnChanged(function(Value) Configuration.MagnitudeCheck = Value end)

    AdvancedChecksSection:AddSlider("TriggerMagnitude", {
        Text = "Trigger Magnitude", Default = Configuration.TriggerMagnitude,
        Min = 10, Max = 1000, Rounding = 1,
        Callback = function(Value) Configuration.TriggerMagnitude = Value end
    })

    local TransparencyCheckToggle = AdvancedChecksSection:AddToggle("TransparencyCheck", { Text = "Transparency Check", Default = Configuration.TransparencyCheck })
    TransparencyCheckToggle:OnChanged(function(Value) Configuration.TransparencyCheck = Value end)

    AdvancedChecksSection:AddSlider("IgnoredTransparency", {
        Text = "Ignored Transparency", Default = Configuration.IgnoredTransparency,
        Min = 0.1, Max = 1, Rounding = 1,
        Callback = function(Value) Configuration.IgnoredTransparency = Value end
    })

    local WhitelistedGroupCheckToggle = AdvancedChecksSection:AddToggle("WhitelistedGroupCheck", { Text = "Whitelisted Group Check", Default = Configuration.WhitelistedGroupCheck })
    WhitelistedGroupCheckToggle:OnChanged(function(Value) Configuration.WhitelistedGroupCheck = Value end)

    AdvancedChecksSection:AddInput("WhitelistedGroup", {
        Text = "Whitelisted Group", Default = tostring(Configuration.WhitelistedGroup),
        Numeric = true, Finished = true, Placeholder = "Group Id",
        Callback = function(Value) Configuration.WhitelistedGroup = #tostring(Value) > 0 and tonumber(Value) or 0 end
    })

    local BlacklistedGroupCheckToggle = AdvancedChecksSection:AddToggle("BlacklistedGroupCheck", { Text = "Blacklisted Group Check", Default = Configuration.BlacklistedGroupCheck })
    BlacklistedGroupCheckToggle:OnChanged(function(Value) Configuration.BlacklistedGroupCheck = Value end)

    AdvancedChecksSection:AddInput("BlacklistedGroup", {
        Text = "Blacklisted Group", Default = tostring(Configuration.BlacklistedGroup),
        Numeric = true, Finished = true, Placeholder = "Group Id",
        Callback = function(Value) Configuration.BlacklistedGroup = #tostring(Value) > 0 and tonumber(Value) or 0 end
    })

    local ExpertChecksSection = Tabs.Checks:AddLeftGroupbox("Expert Checks")

    local IgnoredPlayersCheckToggle = ExpertChecksSection:AddToggle("IgnoredPlayersCheck", { Text = "Ignored Players Check", Default = Configuration.IgnoredPlayersCheck })
    IgnoredPlayersCheckToggle:OnChanged(function(Value) Configuration.IgnoredPlayersCheck = Value end)

    local IgnoredPlayersDropdown = ExpertChecksSection:AddDropdown("IgnoredPlayers", {
        Text = "Ignored Players", Values = Configuration.IgnoredPlayersDropdownValues,
        Multi = true, Default = Configuration.IgnoredPlayers
    })
    IgnoredPlayersDropdown:OnChanged(function(Value)
        Configuration.IgnoredPlayers = {}
        for Key, _ in next, Value do
            if typeof(Key) == "string" then table.insert(Configuration.IgnoredPlayers, Key) end
        end
    end)

    ExpertChecksSection:AddInput("AddIgnoredPlayer", {
        Text = "Add Ignored Player", Finished = true, Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetPlayerName(Value) > 0 and GetPlayerName(Value) or ""
            if #Value > 0 and not table.find(Configuration.IgnoredPlayersDropdownValues, Value) then
                table.insert(Configuration.IgnoredPlayersDropdownValues, Value)
                if not table.find(Configuration.IgnoredPlayers, Value) then
                    IgnoredPlayersDropdown.Value[Value] = true
                    table.insert(Configuration.IgnoredPlayers, Value)
                end
                IgnoredPlayersDropdown:BuildDropdownList()
            end
        end
    })

    ExpertChecksSection:AddInput("RemoveIgnoredPlayer", {
        Text = "Remove Ignored Player", Finished = true, Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetPlayerName(Value) > 0 and GetPlayerName(Value) or ""
            if #Value > 0 and table.find(Configuration.IgnoredPlayersDropdownValues, Value) then
                if table.find(Configuration.IgnoredPlayers, Value) then
                    IgnoredPlayersDropdown.Value[Value] = nil
                    table.remove(Configuration.IgnoredPlayers, table.find(Configuration.IgnoredPlayers, Value))
                    IgnoredPlayersDropdown:Display()
                end
                table.remove(Configuration.IgnoredPlayersDropdownValues, table.find(Configuration.IgnoredPlayersDropdownValues, Value))
                IgnoredPlayersDropdown:SetValues(Configuration.IgnoredPlayersDropdownValues)
            end
        end
    })

    ExpertChecksSection:AddButton({
        Text = "Deselect All Items",
        Func = function()
            local Items = #Configuration.IgnoredPlayers
            IgnoredPlayersDropdown:SetValue({})
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been deselected!" or string.format("%s Items have been deselected!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    ExpertChecksSection:AddButton({
        Text = "Clear Unselected Items",
        Func = function()
            local Cache, Items = {}, 0
            for _, Value in next, Configuration.IgnoredPlayersDropdownValues do
                if table.find(Configuration.IgnoredPlayers, Value) then
                    table.insert(Cache, Value)
                else
                    Items = Items + 1
                end
            end
            Configuration.IgnoredPlayersDropdownValues = Cache
            IgnoredPlayersDropdown:SetValues(Configuration.IgnoredPlayersDropdownValues)
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been cleared!" or string.format("%s Items have been cleared!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    local TargetPlayersCheckToggle = ExpertChecksSection:AddToggle("TargetPlayersCheck", { Text = "Target Players Check", Default = Configuration.TargetPlayersCheck })
    TargetPlayersCheckToggle:OnChanged(function(Value) Configuration.TargetPlayersCheck = Value end)

    local TargetPlayersDropdown = ExpertChecksSection:AddDropdown("TargetPlayers", {
        Text = "Target Players", Values = Configuration.TargetPlayersDropdownValues,
        Multi = true, Default = Configuration.TargetPlayers
    })
    TargetPlayersDropdown:OnChanged(function(Value)
        Configuration.TargetPlayers = {}
        for Key, _ in next, Value do
            if typeof(Key) == "string" then table.insert(Configuration.TargetPlayers, Key) end
        end
    end)

    ExpertChecksSection:AddInput("AddTargetPlayer", {
        Text = "Add Target Player", Finished = true, Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetPlayerName(Value) > 0 and GetPlayerName(Value) or ""
            if #Value > 0 and not table.find(Configuration.TargetPlayersDropdownValues, Value) then
                table.insert(Configuration.TargetPlayersDropdownValues, Value)
                if not table.find(Configuration.TargetPlayers, Value) then
                    TargetPlayersDropdown.Value[Value] = true
                    table.insert(Configuration.TargetPlayers, Value)
                end
                TargetPlayersDropdown:BuildDropdownList()
            end
        end
    })

    ExpertChecksSection:AddInput("RemoveTargetPlayer", {
        Text = "Remove Target Player", Finished = true, Placeholder = "Player Name",
        Callback = function(Value)
            Value = #GetPlayerName(Value) > 0 and GetPlayerName(Value) or ""
            if #Value > 0 and table.find(Configuration.TargetPlayersDropdownValues, Value) then
                if table.find(Configuration.TargetPlayers, Value) then
                    TargetPlayersDropdown.Value[Value] = nil
                    table.remove(Configuration.TargetPlayers, table.find(Configuration.TargetPlayers, Value))
                    TargetPlayersDropdown:Display()
                end
                table.remove(Configuration.TargetPlayersDropdownValues, table.find(Configuration.TargetPlayersDropdownValues, Value))
                TargetPlayersDropdown:SetValues(Configuration.TargetPlayersDropdownValues)
            end
        end
    })

    ExpertChecksSection:AddButton({
        Text = "Deselect All Items",
        Func = function()
            local Items = #Configuration.TargetPlayers
            TargetPlayersDropdown:SetValue({})
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been deselected!" or string.format("%s Items have been deselected!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    ExpertChecksSection:AddButton({
        Text = "Clear Unselected Items",
        Func = function()
            local Cache, Items = {}, 0
            for _, Value in next, Configuration.TargetPlayersDropdownValues do
                if table.find(Configuration.TargetPlayers, Value) then
                    table.insert(Cache, Value)
                else
                    Items = Items + 1
                end
            end
            Configuration.TargetPlayersDropdownValues = Cache
            TargetPlayersDropdown:SetValues(Configuration.TargetPlayersDropdownValues)
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = Items == 0 and "Nothing has been cleared!" or string.format("%s Items have been cleared!", Items),
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    local PremiumChecksSection = Tabs.Checks:AddRightGroupbox("Premium Checks")

    local PremiumCheckToggle = PremiumChecksSection:AddToggle("PremiumCheck", { Text = "Premium Check", Default = Configuration.PremiumCheck })
    PremiumCheckToggle:OnChanged(function(Value) Configuration.PremiumCheck = Value end)

    PremiumChecksSection:AddLabel("✨Upgrade to unlock all Options✨\nContact @ttwiz_z via Discord to buy", true)

    if DEBUG or getfenv().Drawing and getfenv().Drawing.new then
        local FoVSection = K.Tabs.Visuals:AddRightGroupbox("FoV", "circle")

        local FoVToggle = FoVSection:AddToggle("FoV", { Text = "FoV", Tooltip = "Graphically Displays the FoV Radius", Default = Configuration.FoV })
        FoVToggle:OnChanged(function(Value)
            Configuration.FoV = Value
            if not IsComputer then ShowingFoV = Value end
        end)

        if IsComputer then
            local FoVKeybind = FoVSection:AddLabel("FoV Key"):AddKeyPicker("FoVKey", {
                Text = "FoV Key",
                Default = KeyToString(Configuration.FoVKey),
                Mode = "Always",
                ChangedCallback = function(KeyCode) Configuration.FoVKey = KeyCode end
            })
            Configuration.FoVKey = StringToKey(FoVKeybind.Value)
        end

        FoVSection:AddSlider("FoVThickness", {
            Text = "FoV Thickness", Default = Configuration.FoVThickness,
            Min = 1, Max = 10, Rounding = 1,
            Callback = function(Value) Configuration.FoVThickness = Value end
        })

        FoVSection:AddSlider("FoVOpacity", {
            Text = "FoV Opacity", Default = Configuration.FoVOpacity,
            Min = 0.1, Max = 1, Rounding = 1,
            Callback = function(Value) Configuration.FoVOpacity = Value end
        })

        local FoVFilledToggle = FoVSection:AddToggle("FoVFilled", { Text = "FoV Filled", Default = Configuration.FoVFilled })
        FoVFilledToggle:OnChanged(function(Value) Configuration.FoVFilled = Value end)

        FoVSection:AddLabel("FoV Colour"):AddColorPicker("FoVColour", {
            Default = Configuration.FoVColour,
            Callback = function(Value) Configuration.FoVColour = Value end
        })
    else
        ShowWarning = true
    end

    Tabs.Settings = Window:AddTab("Aimbot Settings", "settings")

    AddInfo(Tabs.Settings, string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")), "✨Universal Aim Assist Framework✨\nhttps://github.com/ttwizz/Open-Aimbot")

    local UISection = Tabs.Settings:AddLeftGroupbox("UI")

    if IsComputer then
        UISection:AddLabel("Minimize Key"):AddKeyPicker("MinimizeKey", {
            Text = "Minimize Key",
            Default = KeyToString(UISettings.MinimizeKey),
            Mode = "Always",
            ChangedCallback = function(KeyCode)
                if typeof(KeyCode) == "EnumItem" and KeyCode.EnumType == Enum.KeyCode then
                    UISettings.MinimizeKey = KeyCode.Name
                    Library.ToggleKeybind = KeyCode
                    InterfaceManager:ExportSettings()
                end
            end
        })
    end

    local NotificationsWarningsSection = Tabs.Settings:AddLeftGroupbox("Notifications & Warnings")

    local NotificationsToggle = NotificationsWarningsSection:AddToggle("ShowNotifications", { Text = "Show Notifications", Default = UISettings.ShowNotifications })
    NotificationsToggle:OnChanged(function(Value)
        UISettings.ShowNotifications = Value
        InterfaceManager:ExportSettings()
    end)

    local WarningsToggle = NotificationsWarningsSection:AddToggle("ShowWarnings", { Text = "Show Warnings", Default = UISettings.ShowWarnings })
    WarningsToggle:OnChanged(function(Value)
        UISettings.ShowWarnings = Value
        InterfaceManager:ExportSettings()
    end)

    local PerformanceSection = Tabs.Settings:AddLeftGroupbox("Performance")

    PerformanceSection:AddLabel("NOTE: Heartbeat fires every frame, after the physics simulation. RenderStepped fires every frame, prior to rendering. Stepped fires every frame, prior to the physics simulation.", true)

    PerformanceSection:AddDropdown("RenderingMode", {
        Text = "Rendering Mode",
        Values = { "Heartbeat", "RenderStepped", "Stepped" },
        Default = UISettings.RenderingMode,
        Callback = function(Value)
            UISettings.RenderingMode = Value
            InterfaceManager:ExportSettings()
            ShowDialog({
                Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                Description = "Changes will take effect after the Restart!",
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    })

    if getfenv().isfile and getfenv().readfile and getfenv().writefile and getfenv().delfile then
        local ConfigurationManager = Tabs.Settings:AddRightGroupbox("Configuration Manager")

        local AutoImportToggle = ConfigurationManager:AddToggle("AutoImport", { Text = "Auto Import", Default = UISettings.AutoImport })
        AutoImportToggle:OnChanged(function(Value)
            UISettings.AutoImport = Value
            InterfaceManager:ExportSettings()
        end)

        ConfigurationManager:AddLabel(string.format("Manager for %s\nUniverse ID is %s", game.Name, game.GameId), true)

        ConfigurationManager:AddButton({
            Text = "Import Configuration File",
            Func = function()
                xpcall(function()
                    if getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
                        local ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
                        for Key, Value in next, ImportedConfiguration do
                            if Key == "AimKey" or Key == "SpinKey" or Key == "TriggerKey" or Key == "FoVKey" then
                                if Library.Options[Key] then
                                    Library.Options[Key]:SetValue({ KeyToString(Value) })
                                end
                                Configuration[Key] = StringToKey(Value)
                            elseif Key == "AimPart" or Key == "SpinPart" or typeof(Configuration[Key]) == "table" then
                                Configuration[Key] = Value
                            elseif Key == "FoVColour" then
                                if Library.Options[Key] then
                                    Library.Options[Key]:SetValueRGB(ColorsHandler:UnpackColour(Value))
                                end
                            elseif Configuration[Key] ~= nil and Library.Options[Key] then
                                Library.Options[Key]:SetValue(typeof(Value) == "number" and tostring(Value) or Value)
                            end
                        end
                        ShowDialog({
                            Title = "Configuration Manager",
                            Description = string.format("Configuration File %s.ttwizz has been successfully loaded!", game.GameId),
                            FooterButtons = {{ Title = "Confirm" }}
                        })
                    else
                        ShowDialog({
                            Title = "Configuration Manager",
                            Description = string.format("Configuration File %s.ttwizz could not be found!", game.GameId),
                            FooterButtons = {{ Title = "Confirm" }}
                        })
                    end
                end, function()
                    ShowDialog({
                        Title = "Configuration Manager",
                        Description = string.format("An Error occurred when loading the Configuration File %s.ttwizz", game.GameId),
                        FooterButtons = {{ Title = "Confirm" }}
                    })
                end)
            end
        })

        ConfigurationManager:AddButton({
            Text = "Export Configuration File",
            Func = function()
                xpcall(function()
                    local ExportedConfiguration = { __LAST_UPDATED__ = os.date() }
                    for Key, Value in next, Configuration do
                        if Key == "AimKey" or Key == "SpinKey" or Key == "TriggerKey" or Key == "FoVKey" then
                            ExportedConfiguration[Key] = Library.Options[Key].Value
                        elseif Key == "FoVColour" then
                            ExportedConfiguration[Key] = ColorsHandler:PackColour(Value)
                        else
                            ExportedConfiguration[Key] = Value
                        end
                    end
                    getfenv().writefile(string.format("%s.ttwizz", game.GameId), HttpService:JSONEncode(ExportedConfiguration))
                    ShowDialog({
                        Title = "Configuration Manager",
                        Description = string.format("Configuration File %s.ttwizz has been successfully overwritten!", game.GameId),
                        FooterButtons = {{ Title = "Confirm" }}
                    })
                end, function()
                    ShowDialog({
                        Title = "Configuration Manager",
                        Description = string.format("An Error occurred when overwriting the Configuration File %s.ttwizz", game.GameId),
                        FooterButtons = {{ Title = "Confirm" }}
                    })
                end)
            end
        })

        ConfigurationManager:AddButton({
            Text = "Delete Configuration File",
            Func = function()
                if getfenv().isfile(string.format("%s.ttwizz", game.GameId)) then
                    getfenv().delfile(string.format("%s.ttwizz", game.GameId))
                    ShowDialog({
                        Title = "Configuration Manager",
                        Description = string.format("Configuration File %s.ttwizz has been successfully removed!", game.GameId),
                        FooterButtons = {{ Title = "Confirm" }}
                    })
                else
                    ShowDialog({
                        Title = "Configuration Manager",
                        Description = string.format("Configuration File %s.ttwizz could not be found!", game.GameId),
                        FooterButtons = {{ Title = "Confirm" }}
                    })
                end
            end
        })
    else
        ShowWarning = true
    end

    local DiscordWikiSection = Tabs.Settings:AddRightGroupbox("Discord & Wiki")

    if getfenv().setclipboard then
        DiscordWikiSection:AddButton({
            Text = "Copy Invite Link",
            Tooltip = "Paste it into the Browser Tab",
            Func = function()
                getfenv().setclipboard("https://twix.cyou/pix")
                ShowDialog({
                    Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                    Description = "Invite Link has been copied to the Clipboard!",
                    FooterButtons = {{ Title = "Confirm" }}
                })
            end
        })
        DiscordWikiSection:AddButton({
            Text = "Copy Wiki Link",
            Tooltip = "Paste it into the Browser Tab",
            Func = function()
                getfenv().setclipboard("https://moderka.org/Open-Aimbot")
                ShowDialog({
                    Title = string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot"),
                    Description = "Wiki Link has been copied to the Clipboard!",
                    FooterButtons = {{ Title = "Confirm" }}
                })
            end
        })
    else
        DiscordWikiSection:AddLabel("https://twix.cyou/pix\nPaste it into the Browser Tab", true)
        DiscordWikiSection:AddLabel("https://moderka.org/Open-Aimbot\nPaste it into the Browser Tab", true)
    end

    if UISettings.ShowWarnings then
        if DEBUG then
            ShowDialog({
                Title = "Warning",
                Description = "Running in Debugging Mode. Some Features may not work properly.",
                FooterButtons = {{ Title = "Confirm" }}
            })
        elseif ShowWarning then
            ShowDialog({
                Title = "Warning",
                Description = string.format("Your Software does not support all the Features of %s 🔥FREE🔥!", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")),
                FooterButtons = {{ Title = "Confirm" }}
            })
        else
            ShowDialog({
                Title = string.format("%s 💫PREMIUM💫", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")),
                Description = "✨Upgrade to unlock all Options✨ – Contact @ttwiz_z via Discord to buy",
                FooterButtons = {{ Title = "Confirm" }}
            })
        end
    end
end


--! Notifications Handler

local function Notify(Message)
    if Library and UISettings.ShowNotifications and typeof(Message) == "string" then
        Library:Notify({
            Title = string.format("%s 🔥FREE🔥", string.format(MonthlyLabels[os.date("*t").month], "Open Aimbot")),
            Description = Message,
            Time = 1.5
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
            if not Library then
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
            if not Library then
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
            if not Library then WindowFocused:Disconnect()
            else RobloxActive = true end
        end)

        local WindowFocusReleased; WindowFocusReleased = UserInputService.WindowFocusReleased:Connect(function()
            if not Library then WindowFocusReleased:Disconnect()
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
    if Target and Target:FindFirstChildWhichIsA("Humanoid") and Configuration.AimPart and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") and Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid") and Player.Character:FindFirstChild(Configuration.AimPart) and Player.Character:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
        local _Player = Players:GetPlayerFromCharacter(Target)
        if not _Player or _Player == Player then return false end
        local Humanoid   = Target:FindFirstChildWhichIsA("Humanoid")
        local Head       = Target:FindFirstChildWhichIsA("Head")
        local TargetPart = Target:FindFirstChild(Configuration.AimPart)
        local NativePart = Player.Character:FindFirstChild(Configuration.AimPart)
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
        local OffsetIncrement = Configuration.UseOffset and (Configuration.AutoOffset and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 <= Configuration.MaxAutoOffset and TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 or Configuration.MaxAutoOffset, 0) + Humanoid.MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Configuration.OffsetType == "Static" and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) or Configuration.OffsetType == "Dynamic" and Humanoid.MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) + Humanoid.MoveDirection * Configuration.DynamicOffsetIncrement / 10) or Vector3.zero
        local NoiseFrequency = Configuration.UseNoise and Vector3.new(Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100), Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100), Random.new():NextNumber(-Configuration.NoiseFrequency / 100, Configuration.NoiseFrequency / 100)) or Vector3.zero
        return true, Target, { workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position + OffsetIncrement + NoiseFrequency) }, TargetPart.Position + OffsetIncrement + NoiseFrequency, (TargetPart.Position + OffsetIncrement + NoiseFrequency - NativePart.Position).Magnitude, CFrame.new(TargetPart.Position + OffsetIncrement + NoiseFrequency) * CFrame.fromEulerAnglesYXZ(math.rad(TargetPart.Orientation.X), math.rad(TargetPart.Orientation.Y), math.rad(TargetPart.Orientation.Z)), TargetPart
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
            if Library and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and table.find(Configuration.SilentAimMethods, "Mouse.Hit / Mouse.Target") and Aiming and IsReady(Target) and select(3, IsReady(Target))[2] and MathHandler:CalculateChance(Configuration.SilentAimChance) and self == Mouse then
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
            if Library and not getfenv().checkcaller() and Configuration.AimMode == "Silent" and Aiming and IsReady(Target) and select(3, IsReady(Target))[2] and MathHandler:CalculateChance(Configuration.SilentAimChance) then
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
    if not DEBUG and getfenv().mouse1click and IsComputer and Triggering and (Configuration.SmartTriggerBot and Aiming or not Configuration.SmartTriggerBot) and Mouse.Target and IsReady(Mouse.Target:FindFirstAncestorWhichIsA("Model")) and MathHandler:CalculateChance(Configuration.TriggerBotChance) then
        getfenv().mouse1click()
    end
end


--! Random Parts Handler

local function HandleRandomParts()
    if Library and os.clock() - Clock >= 1 then
        if Configuration.RandomAimPart and #Configuration.AimPartDropdownValues > 0 and Library.Options.AimPart then
            Library.Options.AimPart:SetValue(Configuration.AimPartDropdownValues[Random.new():NextInteger(1, #Configuration.AimPartDropdownValues)])
        end
        if Configuration.RandomSpinPart and #Configuration.SpinPartDropdownValues > 0 and Library.Options.SpinPart then
            Library.Options.SpinPart:SetValue(Configuration.SpinPartDropdownValues[Random.new():NextInteger(1, #Configuration.SpinPartDropdownValues)])
        end
        Clock = os.clock()
    end
end


--! Visuals Handler

local VisualsHandler = {}

function VisualsHandler:Visualize(Object)
    if not DEBUG and Library and getfenv().Drawing and getfenv().Drawing.new and typeof(Object) == "string" then
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
    if not Library then return self:ClearVisuals() end
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
    if DEBUG or not Library or not getfenv().queue_on_teleport then
        OnTeleport:Disconnect()
    else
        getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/cv98gbxtdf-glitch/Kushan/refs/heads/main/Kushan.luau\", true))()")
        OnTeleport:Disconnect()
    end
end)

local PlayerRemoving; PlayerRemoving = Players.PlayerRemoving:Connect(function(_Player)
    if not Library then
        PlayerRemoving:Disconnect()
    else
        if _Player == Player then
            Library:Unload()
            FieldsHandler:ResetAimbotFields()
            FieldsHandler:ResetSecondaryFields()
            VisualsHandler:ClearVisuals()
            PlayerRemoving:Disconnect()
        end
    end
end)


--! Aimbot Handler

local AimbotLoop; AimbotLoop = RunService[UISettings.RenderingMode]:Connect(function()
    if Library.Unloaded then
        Library = nil
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
