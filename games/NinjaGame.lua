local K       = getgenv().KUSHAN
local Library = K.Library
local Options = K.Options

local MissionBox = K.Tabs.Game:AddLeftGroupbox("Mission Settings", "settings")

-- Rank system
local RANK_ORDER = {
    ["F-"]=0,["F"]=1,["F+"]=2,["E-"]=3,["E"]=4,["E+"]=5,
    ["D-"]=6,["D"]=7,["D+"]=8,["C-"]=9,["C"]=10,["C+"]=11,
    ["B-"]=12,["B"]=13,["B+"]=14,["A-"]=15,["A"]=16,["A+"]=17,
    ["S-"]=18,["S"]=19,["S+"]=20,["SS-"]=21,["SS"]=22,["SS+"]=23,["SS++"]=24,
}

local function hasRank(playerRank, requiredRank)
    return (RANK_ORDER[playerRank] or -1) >= (RANK_ORDER[requiredRank] or 999)
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

local function teleportTo(position)
    local character = game.Players.LocalPlayer.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    task.wait(0.15)
    return true
end

local function distanceTo(root, part)
    return (root.Position - part.Position).Magnitude
end

-- Mission functions
local function autoCleanStreets()
    local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
    while missionRunning and activeMission.running do
        for _, obj in ipairs(missionStuff:GetChildren()) do
            if not (missionRunning and activeMission.running) then return end
            if obj.Name == "Trash Pile" and obj:IsA("Model") then
                local char = game.Players.LocalPlayer.Character
                if not char then continue end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local tp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if not tp then continue end
                if distanceTo(root, tp) > 5 then teleportTo(tp.Position) end
                local ev = obj:FindFirstChildWhichIsA("RemoteEvent")
                if ev and ev.Name == "Interact" then ev:FireServer() end
                task.wait(2.2)
            end
        end
        task.wait(0.5)
    end
end

local function autoRescueCat()
    local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
    local function isCat(obj) return (obj.Name=="Cat" or obj.Name=="maxwell") and obj:IsA("MeshPart") end
    while missionRunning and activeMission.running do
        local cat, part
        for _, obj in ipairs(missionStuff:GetChildren()) do
            if isCat(obj) then cat = obj elseif obj.Name == "Part" then part = obj end
        end
        if cat and part and part:IsA("BasePart") then
            local char = game.Players.LocalPlayer.Character
            if not char then task.wait(0.5) continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then task.wait(0.5) continue end
            if distanceTo(root, part) > 5 then teleportTo(part.Position) end
            if distanceTo(root, cat) <= 5 then
                local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
            end
        end
        task.wait(0.2)
    end
end

local function autoFoodDelivery()
    local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
    while missionRunning and activeMission.running do
        for _, obj in ipairs(missionStuff:GetChildren()) do
            if not (missionRunning and activeMission.running) then return end
            if obj.Name == "Door" and obj:IsA("Model") then
                local char = game.Players.LocalPlayer.Character
                if not char then continue end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local tp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if not tp then continue end
                if distanceTo(root, tp) > 5 then teleportTo(tp.Position) end
                local ev = obj:FindFirstChildWhichIsA("RemoteEvent")
                if ev and ev.Name == "Interact" then ev:FireServer() end
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
        local mRank    = mission:GetAttribute("MissionRank")
        local mVillage = mission:GetAttribute("Village")
        local mKey     = mission:GetAttribute("MissionKey")
        if not (mRank and mVillage and mKey) then continue end
        if cooldownUntil[mission.Name] and now < cooldownUntil[mission.Name] then continue end
        if not hasRank(playerRank, mRank) then continue end
        if mVillage ~= playerVillage then continue end
        local acceptEvent = mission:FindFirstChild("Accept")
        if acceptEvent and acceptEvent:IsA("RemoteEvent") then
            acceptEvent:FireServer()
            local name = mission:GetAttribute("MissionName") or mission.Name
            Library:Notify("Accepted: " .. name, 4)
            cooldownUntil[mission.Name] = now + (mission:GetAttribute("TotalCooldown") or 90)
            return mKey
        end
    end
    return nil
end

-- No Fall Damage
local selfHarmHook, originalNamecall = nil, nil

local function enableNoFallDamage()
    local selfHarm = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        and game:GetService("ReplicatedStorage").Events:FindFirstChild("SelfHarm")
    if not selfHarm then Library:Notify("SelfHarm not found.", 3) return end
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if self == selfHarm and getnamecallmethod() == "FireServer" then return end
        return originalNamecall(self, ...)
    end)
    selfHarmHook = true
    Library:Notify("No Fall Damage enabled.", 3)
end

local function disableNoFallDamage()
    if selfHarmHook and originalNamecall then
        hookmetamethod(game, "__namecall", originalNamecall)
        originalNamecall, selfHarmHook = nil, nil
        Library:Notify("No Fall Damage disabled.", 3)
    end
end

-- UI
MissionBox:AddToggle("MissionEnabled", {
    Text = "Auto Missions", Default = false,
    Callback = function(value)
        missionRunning = value
        if value then
            if missionThread then task.cancel(missionThread) missionThread = nil end
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

                    local timeout = os.clock() + 5
                    while missionRunning and not activeMission.running and os.clock() < timeout do
                        task.wait(0.2)
                    end

                    if not activeMission.running then
                        Library:Notify("Mission didn't start, retrying...", 3)
                        task.wait(2)
                        continue
                    end

                    local fn = MISSION_FUNCTIONS[missionKey]
                    if fn then
                        Library:Notify("Running: " .. missionKey, 4)
                        fn()
                        waitForMissionComplete()
                        if missionRunning then
                            Library:Notify(missionKey .. " complete!", 3)
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
            if missionThread then task.cancel(missionThread) missionThread = nil end
        end
    end,
})

MissionBox:AddDivider()

MissionBox:AddToggle("NoFallDamage", {
    Text = "No Fall Damage", Default = false,
    Callback = function(v)
        if v then enableNoFallDamage() else disableNoFallDamage() end
    end,
})
