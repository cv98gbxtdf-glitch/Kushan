local K          = getgenv().KUSHAN
local Library    = K.Library
local ESPLibrary = K.ESPLibrary
local Options    = K.Options

local ESPBox         = K.Tabs.Visuals:AddLeftGroupbox("Player ESP",   "users")
local ESPSettingsBox = K.Tabs.Visuals:AddRightGroupbox("ESP Settings", "sliders-horizontal")

-- State
local ESPInstances       = {}
local ESPEnabled         = false
local ESPTeamFilter      = false
local ESPRainbow         = false
local ESPHealthColor     = false
local ESPShowDistance    = true
local ESPMaxDistance     = 1000
local ESPFillTrans       = 0.5
local ESPTracerEnabled   = false
local ESPTracerFrom      = "Bottom"
local ESPArrowEnabled    = false
local ESPBox2DEnabled    = false
local ESPBox3DEnabled    = false
local ESPSkeletonEnabled = false

local function getESPColor(player)
    if player.Team then return player.TeamColor.Color end
    return Color3.fromRGB(255, 100, 100)
end

local function removeESP(player)
    if ESPInstances[player] then
        ESPInstances[player]:Destroy()
        ESPInstances[player] = nil
    end
end

local function createESP(player)
    removeESP(player)
    if not ESPEnabled then return end
    if not player.Character then return end
    if ESPTeamFilter and player.Team == game.Players.LocalPlayer.Team then return end
    if not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local color    = getESPColor(player)
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

    local settings = {
        Name    = player.Name,
        Model   = player.Character,
        Color   = color,
        MaxDistance = ESPMaxDistance,
        TextSize    = 16,

        ESPType             = "Highlight",
        FillColor           = color,
        OutlineColor        = Color3.fromRGB(255, 255, 255),
        FillTransparency    = ESPFillTrans,
        OutlineTransparency = 0,

        Tracer   = { Enabled = ESPTracerEnabled,   Color = color, From = ESPTracerFrom, Thickness = 2 },
        Arrow    = { Enabled = ESPArrowEnabled,    Color = color },
        Box2D    = { Enabled = ESPBox2DEnabled,    Color = color, Thickness = 2 },
        Box3D    = { Enabled = ESPBox3DEnabled,    Color = color, Thickness = 1.5 },
        Skeleton = { Enabled = ESPSkeletonEnabled, Color = Color3.fromRGB(255, 255, 255), Thickness = 1 },
    }

    if ESPHealthColor and humanoid then
        settings.BeforeUpdate = function(self)
            local pct = humanoid.Health / math.max(humanoid.MaxHealth, 1)
            local c   = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
            self.CurrentSettings.FillColor    = c
            self.CurrentSettings.OutlineColor = c
            self.CurrentSettings.Color        = c
        end
    end

    ESPInstances[player] = ESPLibrary:Add(settings)
end

local function refreshAllESP()
    for player in pairs(ESPInstances) do removeESP(player) end
    ESPLibrary.GlobalConfig.Rainbow  = ESPRainbow
    ESPLibrary.GlobalConfig.Distance = ESPShowDistance
    if not ESPEnabled then return end
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            createESP(player)
        end
    end
end

-- Hooks
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart", 10)
            task.wait(0.5)
            createESP(player)
        end)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        createESP(player)
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- UI
ESPBox:AddToggle("ESPEnabled", {
    Text = "Enable ESP", Default = false,
    Callback = function(v) ESPEnabled = v; refreshAllESP() end,
})

ESPBox:AddToggle("ESPTeamFilter", {
    Text = "Filter Teammates", Default = false,
    Callback = function(v) ESPTeamFilter = v; refreshAllESP() end,
})

ESPBox:AddToggle("ESPRainbow", {
    Text = "Rainbow Mode", Default = false,
    Callback = function(v) ESPRainbow = v; ESPLibrary.GlobalConfig.Rainbow = v end,
})

ESPBox:AddToggle("ESPHealthColor", {
    Text = "Health Color", Default = false,
    Callback = function(v) ESPHealthColor = v; refreshAllESP() end,
})

ESPBox:AddToggle("ESPShowDistance", {
    Text = "Show Distance", Default = true,
    Callback = function(v) ESPShowDistance = v; ESPLibrary.GlobalConfig.Distance = v end,
})

ESPBox:AddButton({
    Text = "Clear All ESP",
    Callback = function()
        ESPLibrary:Clear()
        ESPInstances = {}
        Library:Notify("All ESP cleared.", 3)
    end,
})

ESPSettingsBox:AddSlider("ESPMaxDistance", {
    Text = "Max Distance", Min = 100, Max = 5000, Default = 1000, Suffix = " studs",
    Callback = function(v)
        ESPMaxDistance = v
        for _, inst in pairs(ESPInstances) do inst.CurrentSettings.MaxDistance = v end
    end,
})

ESPSettingsBox:AddSlider("ESPFillTrans", {
    Text = "Fill Transparency", Min = 0, Max = 1, Default = 0.5,
    Callback = function(v)
        ESPFillTrans = v
        for _, inst in pairs(ESPInstances) do inst.CurrentSettings.FillTransparency = v end
    end,
})

ESPSettingsBox:AddDivider()

ESPSettingsBox:AddToggle("ESPTracer", {
    Text = "Tracers", Default = false,
    Callback = function(v)
        ESPTracerEnabled = v
        ESPLibrary.GlobalConfig.Tracers = v
        for _, inst in pairs(ESPInstances) do inst.CurrentSettings.Tracer.Enabled = v end
    end,
})

ESPSettingsBox:AddDropdown("ESPTracerFrom", {
    Text = "Tracer Origin", Values = {"Bottom","Top","Center","Mouse"}, Default = 1,
    Callback = function(v) ESPTracerFrom = v; refreshAllESP() end,
})

ESPSettingsBox:AddToggle("ESPArrow", {
    Text = "Off-Screen Arrows", Default = false,
    Callback = function(v) ESPArrowEnabled = v; ESPLibrary.GlobalConfig.Arrows = v end,
})

ESPSettingsBox:AddToggle("ESPBox2D", {
    Text = "2D Boxes", Default = false,
    Callback = function(v) ESPBox2DEnabled = v; ESPLibrary.GlobalConfig.Boxes2D = v end,
})

ESPSettingsBox:AddToggle("ESPBox3D", {
    Text = "3D Boxes", Default = false,
    Callback = function(v) ESPBox3DEnabled = v; ESPLibrary.GlobalConfig.Boxes3D = v end,
})

ESPSettingsBox:AddToggle("ESPSkeleton", {
    Text = "Skeleton", Default = false,
    Callback = function(v) ESPSkeletonEnabled = v; ESPLibrary.GlobalConfig.Skeleton = v end,
})
