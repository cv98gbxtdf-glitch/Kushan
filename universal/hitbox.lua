local K       = getgenv().KUSHAN
local Library = K.Library

local CombatBox = K.Tabs.Combat:AddLeftGroupbox("Hitbox", "box")

local HitboxEnabled      = false
local HitboxSize         = 10
local HitboxTransparency = 0.7
local HitboxColor        = Color3.fromRGB(255, 0, 0)
local SelectedBone       = "Head"
local OriginalProperties = {}
local TeamFilterEnabled  = false

local function GetTargetPart(character)
    if not character then return nil end
    return ({
        Head  = character:FindFirstChild("Head"),
        Torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
        Waist = character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart"),
    })[SelectedBone] or character:FindFirstChild("HumanoidRootPart")
end

local function isPlayerDead(character)
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0
end

local function getDistanceToPlayer(player)
    local lc = game.Players.LocalPlayer.Character
    local lr = lc and lc:FindFirstChild("HumanoidRootPart")
    local oc = player.Character
    local or_ = oc and oc:FindFirstChild("HumanoidRootPart")
    if not lr or not or_ then return math.huge end
    return (lr.Position - or_.Position).Magnitude
end

local function getSortedPlayers()
    local lp      = game.Players.LocalPlayer
    local players = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p == lp then continue end
        if not p.Character then continue end
        if isPlayerDead(p.Character) then continue end
        if TeamFilterEnabled and p.Team == lp.Team then continue end
        table.insert(players, p)
    end
    table.sort(players, function(a, b)
        return getDistanceToPlayer(a) < getDistanceToPlayer(b)
    end)
    return players
end

local function restorePlayer(player)
    if not OriginalProperties[player] then return end
    for part, props in pairs(OriginalProperties[player]) do
        if part and part.Parent then
            part.Size         = props.Size
            part.Transparency = props.Transparency
            part.Color        = props.Color
            part.Material     = props.Material
            part.CanCollide   = props.CanCollide
            part.CastShadow   = props.CastShadow
        end
    end
    OriginalProperties[player] = nil
end

local function applyHitbox(player)
    local character  = player.Character
    local targetPart = GetTargetPart(character)
    if not targetPart then return end

    OriginalProperties[player] = OriginalProperties[player] or {}

    local allParts = {
        "Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart",
        "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
        "LeftUpperLeg","RightUpperLeg",
    }

    for _, partName in ipairs(allParts) do
        local part = character:FindFirstChild(partName)
        if not part then continue end
        if not OriginalProperties[player][part] then
            OriginalProperties[player][part] = {
                Size         = part.Size,
                Transparency = part.Transparency,
                Color        = part.Color,
                Material     = part.Material,
                CanCollide   = part.CanCollide,
                CastShadow   = part.CastShadow,
            }
        end
        local isTarget = (part == targetPart)
        local origSize = OriginalProperties[player][part].Size
        local scale    = isTarget and HitboxSize or (HitboxSize * 0.8)
        local scalar   = scale / math.max(math.max(origSize.X, origSize.Y, origSize.Z), 1)
        part.Size         = origSize * scalar
        part.Transparency = isTarget and HitboxTransparency or math.min(HitboxTransparency + 0.2, 1)
        part.Color        = HitboxColor
        part.Material     = Enum.Material.ForceField
        part.CanCollide   = false
        part.CastShadow   = false
    end
end

local function UpdateHitboxes()
    local active = {}
    if HitboxEnabled then
        for _, p in ipairs(getSortedPlayers()) do
            active[p] = true
            applyHitbox(p)
        end
    end
    for p in pairs(OriginalProperties) do
        if not active[p] then restorePlayer(p) end
    end
end

task.spawn(function()
    while true do UpdateHitboxes() task.wait(0.07) end
end)

game.Players.PlayerRemoving:Connect(function(p) OriginalProperties[p] = nil end)

-- UI
CombatBox:AddToggle("HitboxToggle", {
    Text = "Hitbox Extender", Default = false,
    Callback = function(v)
        HitboxEnabled = v
        if not v then for p in pairs(OriginalProperties) do restorePlayer(p) end end
        UpdateHitboxes()
    end,
})

CombatBox:AddToggle("HitboxTeamFilter", {
    Text = "Filter Teammates", Default = false,
    Callback = function(v) TeamFilterEnabled = v; UpdateHitboxes() end,
})

CombatBox:AddDropdown("BoneSelect", {
    Text = "Target Bone", Values = {"Head","Torso","Waist"}, Default = 1,
    Callback = function(v) SelectedBone = v; if HitboxEnabled then UpdateHitboxes() end end,
})

CombatBox:AddSlider("HitboxSize", {
    Text = "Hitbox Size", Min = 1, Max = 50, Default = 10, Suffix = " studs",
    Callback = function(v) HitboxSize = v; if HitboxEnabled then UpdateHitboxes() end end,
})

CombatBox:AddSlider("HitboxTransparency", {
    Text = "Transparency", Min = 0, Max = 1, Default = 0.7,
    Callback = function(v) HitboxTransparency = v; if HitboxEnabled then UpdateHitboxes() end end,
})

CombatBox:AddButton({
    Text = "Reset Hitboxes",
    Callback = function()
        for p in pairs(OriginalProperties) do restorePlayer(p) end
        Library:Notify("All hitboxes reset.", 3)
    end,
})
