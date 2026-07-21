-- Load Obsidian Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- =====================
-- GAME DETECTION
-- =====================
local SUPPORTED_GAMES = {
    [130960021905304] = "NinjaGame", -- replace with actual PlaceId from print(game.PlaceId)
}

local currentPlaceId = game.PlaceId
local currentGame    = SUPPORTED_GAMES[currentPlaceId]
local isSupported    = currentGame ~= nil

local function forGame(gameName, fn)
    if currentGame == gameName then fn() end
end

-- =====================
-- WINDOW
-- =====================
local Window = Library:CreateWindow({
    Title      = "KUSHAN",
    Footer     = "v3.0",
    NotifySide = "Right",
    Icon       = 101385867250567,
})

-- =====================
-- TABS (universal always added, game-specific gated)
-- =====================
local Tabs = {
    Combat = Window:AddTab("Combat", "sword"),
}

if isSupported then
    Tabs.AutoMission = Window:AddTab("Auto Mission", "crosshair")
end

-- =====================
-- GROUPBOXES
-- =====================
local CombatBox = Tabs.Combat:AddLeftGroupbox("Hitbox", "box")

local MissionBox
if Tabs.AutoMission then
    MissionBox = Tabs.AutoMission:AddLeftGroupbox("Mission Settings", "settings")
end

local Options = Library.Options

-- =====================
-- NOTIFY ON LOAD
-- =====================
if isSupported then
    Library:Notify("Game detected: " .. currentGame .. " — all features enabled.", 4)
else
    Library:Notify("Unsupported game — universal features only.", 4)
end

-- =====================
-- HITBOX SYSTEM (UNIVERSAL)
-- =====================
local HitboxEnabled      = false
local HitboxSize         = 10
local HitboxTransparency = 0.7
local HitboxColor        = Color3.fromRGB(255, 0, 0)
local SelectedBone       = "Head"
local OriginalProperties = {}
local TeamFilterEnabled  = false

local function GetTargetPart(character)
    if not character then return nil end
    local boneMap = {
        Head  = character:FindFirstChild("Head"),
        Torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
        Waist = character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart"),
    }
    return boneMap[SelectedBone] or character:FindFirstChild("HumanoidRootPart")
end

local function isPlayerDead(character)
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0
end

local function getDistanceToPlayer(player)
    local localChar = game.Players.LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local otherChar = player.Character
    local otherRoot = otherChar and otherChar:FindFirstChild("HumanoidRootPart")
    if not localRoot or not otherRoot then return math.huge end
    return (localRoot.Position - otherRoot.Position).Magnitude
end

local function getSortedPlayers()
    local localPlayer = game.Players.LocalPlayer
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        if not player.Character then continue end
        if isPlayerDead(player.Character) then continue end
        if TeamFilterEnabled and player.Team == localPlayer.Team then continue end
        table.insert(players, player)
    end
    -- Sort nearest first
    table.sort(players, function(a, b)
        return getDistanceToPlayer(a) < getDistanceToPlayer(b)
    end)
    return players
end

local function restorePlayer(player)
    if OriginalProperties[player] then
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
end

local function applyHitbox(player)
    local character  = player.Character
    local targetPart = GetTargetPart(character)
    if not targetPart then return end

    if not OriginalProperties[player] then
        OriginalProperties[player] = {}
    end

    local allParts = { "Head", "UpperTorso", "LowerTorso", "Torso",
                       "HumanoidRootPart", "LeftUpperArm", "RightUpperArm",
                       "LeftLowerArm", "RightLowerArm", "LeftUpperLeg", "RightUpperLeg" }

    for _, partName in ipairs(allParts) do
        local part = character:FindFirstChild(partName)
        if not part then continue end

        -- Store original if not already stored
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

        local isTarget  = (part == targetPart)
        -- Scale relative to original size so proportions stay natural
        local origSize  = OriginalProperties[player][part].Size
        local scale     = isTarget and HitboxSize or (HitboxSize * 0.8)
        local maxOrig   = math.max(origSize.X, origSize.Y, origSize.Z)
        local scalar    = scale / math.max(maxOrig, 1)

        part.Size         = origSize * scalar
        part.Transparency = isTarget and HitboxTransparency or math.min(HitboxTransparency + 0.2, 1)
        part.Color        = HitboxColor
        part.Material     = Enum.Material.ForceField
        part.CanCollide   = false
        part.CastShadow   = false -- no giant shadow giveaway
    end
end

local function UpdateHitboxes()
    local activePlayers = {}
    if HitboxEnabled then
        local sorted = getSortedPlayers()
        for _, player in ipairs(sorted) do
            activePlayers[player] = true
            applyHitbox(player)
        end
    end
    -- Restore any player no longer in the active set
    for player in pairs(OriginalProperties) do
        if not activePlayers[player] then
            restorePlayer(player)
        end
    end
end

-- Hitbox update loop
task.spawn(function()
    while true do
        UpdateHitboxes()
        task.wait(0.07)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    OriginalProperties[player] = nil
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if HitboxEnabled then applyHitbox(player) end
    end)
end)

-- =====================
-- UI: COMBAT TAB (UNIVERSAL)
-- =====================
CombatBox:AddToggle("HitboxToggle", {
    Text    = "Hitbox Extender",
    Default = false,
    Callback = function(value)
        HitboxEnabled = value
        if not value then
            for player in pairs(OriginalProperties) do
                restorePlayer(player)
            end
        end
        UpdateHitboxes()
    end,
})

CombatBox:AddToggle("TeamFilter", {
    Text    = "Filter Teammates",
    Default = false,
    Callback = function(value)
        TeamFilterEnabled = value
        UpdateHitboxes()
    end,
})

CombatBox:AddDropdown("BoneSelect", {
    Text    = "Target Bone",
    Values  = { "Head", "Torso", "Waist" },
    Default = 1,
    Callback = function(value)
        SelectedBone = value
        if HitboxEnabled then UpdateHitboxes() end
    end,
})

CombatBox:AddSlider("HitboxSize", {
    Text     = "Hitbox Size",
    Min      = 1,
    Max      = 50,
    Default  = 10,
    Suffix   = " studs",
    Callback = function(value)
        HitboxSize = value
        if HitboxEnabled then UpdateHitboxes() end
    end,
})

CombatBox:AddSlider("HitboxTransparency", {
    Text     = "Transparency",
    Min      = 0,
    Max      = 1,
    Default  = 0.7,
    Suffix   = "",
    Callback = function(value)
        HitboxTransparency = value
        if HitboxEnabled then UpdateHitboxes() end
    end,
})

CombatBox:AddButton({
    Text = "Reset Hitboxes",
    Callback = function()
        for player in pairs(OriginalProperties) do
            restorePlayer(player)
        end
        Library:Notify("All hitboxes reset.", 3)
    end,
})

-- =====================
-- GAME-SPECIFIC: NINJA GAME
-- =====================
forGame("NinjaGame", function()

    -- Rank system
    local RANK_ORDER = {
        ["F-"] = 0,  ["F"] = 1,   ["F+"] = 2,
        ["E-"] = 3,  ["E"] = 4,   ["E+"] = 5,
        ["D-"] = 6,  ["D"] = 7,   ["D+"] = 8,
        ["C-"] = 9,  ["C"] = 10,  ["C+"] = 11,
        ["B-"] = 12, ["B"] = 13,  ["B+"] = 14,
        ["A-"] = 15, ["A"] = 16,  ["A+"] = 17,
        ["S-"] = 18, ["S"] = 19,  ["S+"] = 20,
        ["SS-"] = 21,["SS"] = 22, ["SS+"] = 23,
        ["SS++"] = 24,
    }

    local function hasRank(playerRank, requiredRank)
        local playerLevel   = RANK_ORDER[playerRank]   or -1
        local requiredLevel = RANK_ORDER[requiredRank] or 999
        return playerLevel >= requiredLevel
    end

    -- Mission state
    local missionRunning = false
    local missionThread  = nil
    local activeMission  = { running = false, progress = {} }

    local UpdateMissionInfo = game:GetService("ReplicatedStorage").GameInfo.Events.Missions.UpdateMissionInfo
    UpdateMissionInfo.OnClientEvent:Connect(function(eventType, data)
        if eventType == "Start" then
            activeMission.running  = true
            activeMission.progress = {}
            if data and data.Keys then
                for _, key in ipairs(data.Keys) do
                    activeMission.progress[key.Id] = { Current = key.Current, Total = key.Total }
                end
            end
        elseif eventType == "Progress" and data then
            activeMission.progress[data.KeyId] = { Current = data.Current, Total = data.Total }
        elseif eventType == "Clear" then
            activeMission.running  = false
            activeMission.progress = {}
        end
    end)

    local function waitForMissionComplete()
        while missionRunning and activeMission.running do task.wait(0.5) end
    end

    -- Helpers
    local function teleportTo(position)
        local character = game.Players.LocalPlayer.Character
        if not character then return false end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        task.wait(0.15)
        return true
    end

    local function distanceTo(root, targetPart)
        return (root.Position - targetPart.Position).Magnitude
    end

    -- Mission functions
    local function autoCleanStreets()
        local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
        local MAX_DISTANCE = 5
        while missionRunning and activeMission.running do
            for _, obj in ipairs(missionStuff:GetChildren()) do
                if not (missionRunning and activeMission.running) then return end
                if obj.Name == "Trash Pile" and obj:IsA("Model") then
                    local character = game.Players.LocalPlayer.Character
                    if not character then continue end
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if not targetPart then continue end
                    if distanceTo(root, targetPart) > MAX_DISTANCE then
                        teleportTo(targetPart.Position)
                    end
                    local event = obj:FindFirstChildWhichIsA("RemoteEvent")
                    if event and event.Name == "Interact" then
                        event:FireServer()
                    end
                    task.wait(2.2)
                end
            end
            task.wait(0.5)
        end
    end

    local function autoRescueCat()
        local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
        local MAX_DISTANCE = 5
        local function isCat(obj)
            return (obj.Name == "Cat" or obj.Name == "maxwell") and obj:IsA("MeshPart")
        end
        while missionRunning and activeMission.running do
            local cat, part
            for _, obj in ipairs(missionStuff:GetChildren()) do
                if isCat(obj) then cat = obj
                elseif obj.Name == "Part" then part = obj end
            end
            if cat and part and part:IsA("BasePart") then
                local character = game.Players.LocalPlayer.Character
                if not character then task.wait(0.5) continue end
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then task.wait(0.5) continue end
                if distanceTo(root, part) > MAX_DISTANCE then
                    teleportTo(part.Position)
                end
                if distanceTo(root, cat) <= MAX_DISTANCE then
                    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end
            task.wait(0.2)
        end
    end

    local function autoFoodDelivery()
        local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
        local MAX_DISTANCE = 5
        while missionRunning and activeMission.running do
            for _, obj in ipairs(missionStuff:GetChildren()) do
                if not (missionRunning and activeMission.running) then return end
                if obj.Name == "Door" and obj:IsA("Model") then
                    local character = game.Players.LocalPlayer.Character
                    if not character then continue end
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if not targetPart then continue end
                    if distanceTo(root, targetPart) > MAX_DISTANCE then
                        teleportTo(targetPart.Position)
                    end
                    local event = obj:FindFirstChildWhichIsA("RemoteEvent")
                    if event and event.Name == "Interact" then
                        event:FireServer()
                    end
                    task.wait(5.2)
                end
            end
            task.wait(0.5)
        end
    end

    local function autoRareFlower()
        Library:Notify("RareFlower not yet implemented.", 4)
    end

    local MISSION_FUNCTIONS = {
        CleanStreets = autoCleanStreets,
        RescueCat    = autoRescueCat,
        FoodDelivery = autoFoodDelivery,
        RareFlower   = autoRareFlower,
    }

    local function findAndAcceptMission(cooldownUntil)
        local player        = game.Players.LocalPlayer
        local playerRank    = player.leaderstats and player.leaderstats.Rank and player.leaderstats.Rank.Value or "F-"
        local playerVillage = player.Team and player.Team.Name or ""
        local MissionList   = game:GetService("ReplicatedStorage"):WaitForChild("Missions"):WaitForChild("List")
        local now           = os.clock()

        for _, mission in ipairs(MissionList:GetChildren()) do
            local missionRank    = mission:GetAttribute("MissionRank")
            local missionVillage = mission:GetAttribute("Village")
            local missionKey     = mission:GetAttribute("MissionKey")

            if not (missionRank and missionVillage and missionKey) then continue end
            if cooldownUntil[mission.Name] and now < cooldownUntil[mission.Name] then continue end
            if not hasRank(playerRank, missionRank) then continue end
            if missionVillage ~= playerVillage then continue end

            local acceptEvent = mission:FindFirstChild("Accept")
            if acceptEvent and acceptEvent:IsA("RemoteEvent") then
                acceptEvent:FireServer()
                local name = mission:GetAttribute("MissionName") or mission.Name
                Library:Notify("Accepted: " .. name, 4)
                local cd = mission:GetAttribute("TotalCooldown") or 90
                cooldownUntil[mission.Name] = os.clock() + cd
                return missionKey
            end
        end
        return nil
    end

    -- No Fall Damage
    local selfHarmHook    = nil
    local originalNamecall = nil

    local function enableNoFallDamage()
        local selfHarm = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
            game:GetService("ReplicatedStorage").Events:FindFirstChild("SelfHarm")
        if not selfHarm then
            Library:Notify("SelfHarm event not found.", 3)
            return
        end
        originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if self == selfHarm and method == "FireServer" then return end
            return originalNamecall(self, ...)
        end)
        selfHarmHook = true
        Library:Notify("No Fall Damage enabled.", 3)
    end

    local function disableNoFallDamage()
        if selfHarmHook and originalNamecall then
            hookmetamethod(game, "__namecall", originalNamecall)
            originalNamecall = nil
            selfHarmHook     = nil
            Library:Notify("No Fall Damage disabled.", 3)
        end
    end

    -- Mission UI
    MissionBox:AddToggle("MissionEnabled", {
        Text    = "Auto Missions",
        Default = false,
        Callback = function(value)
            missionRunning = value
            if value then
                if missionThread then
                    task.cancel(missionThread)
                    missionThread = nil
                end
                missionThread = task.spawn(function()
                    local cooldownUntil = {}
                    while missionRunning do
                        game:GetService("ReplicatedStorage").Events.Dialogue:FireServer("-1001", true)
                        task.wait(1)
                        game:GetService("ReplicatedStorage").GameInfo.Events.Squad.Create:FireServer()
                        task.wait(1)

                        local missionKey = findAndAcceptMission(cooldownUntil)
                        if not missionKey then
                            Library:Notify("All missions on cooldown, waiting...", 3)
                            task.wait(10)
                            continue
                        end

                        local startTimeout = os.clock() + 5
                        while missionRunning and not activeMission.running and os.clock() < startTimeout do
                            task.wait(0.2)
                        end

                        if not activeMission.running then
                            Library:Notify("Mission didn't start in time, retrying...", 3)
                            task.wait(2)
                            continue
                        end

                        local missionFn = MISSION_FUNCTIONS[missionKey]
                        if missionFn then
                            Library:Notify("Running: " .. missionKey, 4)
                            missionFn()
                            waitForMissionComplete()
                            if missionRunning then
                                Library:Notify(missionKey .. " complete! Finding next...", 3)
                                task.wait(2)
                            end
                        else
                            Library:Notify("No handler for: " .. missionKey, 4)
                            waitForMissionComplete()
                            task.wait(2)
                        end
                    end
                end)
            else
                Library:Notify("Auto missions stopped.", 3)
                if missionThread then
                    task.cancel(missionThread)
                    missionThread = nil
                end
            end
        end,
    })

    MissionBox:AddDivider()

    MissionBox:AddToggle("NoFallDamage", {
        Text    = "No Fall Damage",
        Default = false,
        Callback = function(value)
            if value then enableNoFallDamage() else disableNoFallDamage() end
        end,
    })

end) -- end forGame("NinjaGame")
