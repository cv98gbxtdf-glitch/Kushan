-- Load Obsidian Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- =====================
-- DEBUG CONSOLE
-- =====================
-- Potassium: rconsolecreate / rconsoleprint for non-intrusive logging
rconsolecreate()
rconsolesettitle("KUSHAN Debug")

local function log(msg)
	rconsoleprint("[KUSHAN] " .. tostring(msg) .. "\n")
end

-- Create Window
local Window = Library:CreateWindow({
	Title = "KUSHAN",
	Footer = "v2.0",
	NotifySide = "Right",
	Icon = 101385867250567,
})

-- Tabs
local Tabs = {
	AutoMission = Window:AddTab("Auto Mission", "crosshair"),
}

-- Groupboxes
local MissionBox = Tabs.AutoMission:AddLeftGroupbox("Mission Settings", "settings")

local Options = Library.Options

-- =====================
-- RANK ELIGIBILITY
-- =====================
local MISSION_RANKS = {
	D = { "Academy Student", "Genin", "Chunin", "Jonin", "Anbu", "Advisor", "Council", "Kage" },
	C = { "Genin", "Chunin", "Jonin", "Anbu", "Advisor", "Council", "Kage" },
	B = { "Chunin", "Jonin", "Anbu", "Advisor", "Council", "Kage" },
	A = { "Jonin", "Anbu", "Advisor", "Council", "Kage" },
}

local function canDoMission(playerRating, missionRank)
	local eligible = MISSION_RANKS[missionRank]
	if not eligible then return false end
	return table.find(eligible, playerRating) ~= nil
end

-- =====================
-- MISSION STATE TRACKING
-- =====================
local missionRunning = false
local missionThread  = nil

local activeMission = {
	running  = false,
	progress = {},
}

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
		log("Mission started")
	elseif eventType == "Progress" and data then
		activeMission.progress[data.KeyId] = { Current = data.Current, Total = data.Total }
	elseif eventType == "Clear" then
		activeMission.running  = false
		activeMission.progress = {}
		log("Mission cleared by server")
	end
end)

local function waitForMissionComplete()
	while missionRunning and activeMission.running do
		task.wait(0.5)
	end
end

-- =====================
-- SHARED HELPERS
-- =====================

-- Teleport the local character root to a position safely
local function teleportTo(position)
	local character = game.Players.LocalPlayer.Character
	if not character then return false end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
	task.wait(0.15)
	return true
end

-- Distance between root and a target BasePart
local function distanceTo(root, targetPart)
	return (root.Position - targetPart.Position).Magnitude
end

-- =====================
-- AUTO MISSION FUNCTIONS
-- =====================

local function autoCleanStreets()
	-- Uses firetouchinterest (Potassium) to trigger trash pile interactions
	-- without needing to teleport + find RemoteEvent manually.
	local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
	local MAX_DISTANCE  = 5

	while missionRunning and activeMission.running do
		for _, obj in ipairs(missionStuff:GetChildren()) do
			if not (missionRunning and activeMission.running) then return end
			if obj.Name == "Trash Pile" and obj:IsA("Model") then
				local character = game.Players.LocalPlayer.Character
				if not character then continue end
				local root       = character:FindFirstChild("HumanoidRootPart")
				if not root then continue end
				local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if not targetPart then continue end

				if distanceTo(root, targetPart) > MAX_DISTANCE then
					teleportTo(targetPart.Position)
				end

				-- Potassium: firetouchinterest — triggers the Touched signal on the pile
				-- so the server-side handler picks it up without needing FireServer manually.
				firetouchinterest(targetPart, root, true)
				task.wait(0.05)
				firetouchinterest(targetPart, root, false)

				-- Fallback: also fire the RemoteEvent if the game uses one
				local event = obj:FindFirstChildWhichIsA("RemoteEvent")
				if event and event.Name == "Interact" then
					event:FireServer()
				end

				log("Cleaned trash pile: " .. obj:GetFullName())
				task.wait(2.0) -- server-side cooldown for this interaction
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

	-- Hook FireServer to log everything fired during this mission
	local originalNamecall2
	originalNamecall2 = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if method == "FireServer" then
			local ok, path = pcall(function() return self:GetFullName() end)
			if ok then
				log("[RescueCat FireServer] " .. path)
				local args = {...}
				for i, arg in ipairs(args) do
					log("  arg[" .. i .. "] = " .. tostring(arg) .. " [" .. typeof(arg) .. "]")
				end
			end
		end
		return originalNamecall2(self, ...)
	end))

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

			local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt then
				-- Log prompt state
				log("RescueCat: prompt found on " .. prompt.Parent:GetFullName())
				log("  HoldDuration=" .. prompt.HoldDuration)
				log("  MaxActivationDistance=" .. prompt.MaxActivationDistance)
				log("  RequiresLineOfSight=" .. tostring(prompt.RequiresLineOfSight))
				log("  Enabled=" .. tostring(prompt.Enabled))

				-- Log all connections on Triggered
				local conns = getconnections(prompt.Triggered)
				log("  Triggered connections: " .. #conns)
				for i, conn in ipairs(conns) do
					log("    [" .. i .. "] LuaConnection=" .. tostring(conn.LuaConnection)
						.. " ForeignState=" .. tostring(conn.ForeignState))
					if conn.Function then
						local info = debug.getinfo(conn.Function)
						log("      source=" .. tostring(info and info.source)
							.. " line=" .. tostring(info and info.linedefined))
					end
				end

				local originalDuration = getproximitypromptduration(prompt)
				setproximitypromptduration(prompt, 0)
				fireproximityprompt(prompt)
				setproximitypromptduration(prompt, originalDuration)
				log("RescueCat: prompt fired, watching for changes...")

				-- Wait for cat or part to be removed
				local waited = 0
				local confirmed = false
				while missionRunning and activeMission.running and waited < 4 do
					task.wait(0.2)
					waited += 0.2
					local catGone  = not cat.Parent or cat.Parent ~= missionStuff
					local partGone = not part.Parent or part.Parent ~= missionStuff
					if catGone or partGone then
						confirmed = true
						log("RescueCat: object removed — interaction confirmed")
						break
					end
				end

				if confirmed then
					task.wait(1.5)
				else
					log("RescueCat: no object removal in 4s — prompt likely didn't register")
					task.wait(1.0)
				end
			else
				log("RescueCat: no ProximityPrompt found on Part")
				task.wait(0.5)
			end
		else
			task.wait(0.3)
		end
	end

	-- Clean up hook when mission ends
	hookmetamethod(game, "__namecall", originalNamecall2)
	log("RescueCat: namecall hook cleaned up")
end

local function autoFoodDelivery()
	-- Uses firetouchinterest on Door parts in addition to RemoteEvent,
	-- covering both touch-gated and event-gated door implementations.
	local missionStuff = workspace:WaitForChild("Thrown"):WaitForChild("MissionStuff")
	local MAX_DISTANCE  = 5

	while missionRunning and activeMission.running do
		for _, obj in ipairs(missionStuff:GetChildren()) do
			if not (missionRunning and activeMission.running) then return end
			if obj.Name == "Door" and obj:IsA("Model") then
				local character = game.Players.LocalPlayer.Character
				if not character then continue end
				local root       = character:FindFirstChild("HumanoidRootPart")
				if not root then continue end
				local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if not targetPart then continue end

				if distanceTo(root, targetPart) > MAX_DISTANCE then
					teleportTo(targetPart.Position)
				end

				-- Potassium: firetouchinterest covers touch-triggered door handlers
				firetouchinterest(targetPart, root, true)
				task.wait(0.05)
				firetouchinterest(targetPart, root, false)

				local event = obj:FindFirstChildWhichIsA("RemoteEvent")
				if event and event.Name == "Interact" then
					event:FireServer()
				end

				log("Delivered to door: " .. obj:GetFullName())
				task.wait(5.0)
			end
		end
		task.wait(0.5)
	end
end

local function autoRareFlower()
	Library:Notify("RareFlower auto not yet implemented, skipping.", 4)
	log("RareFlower: skipped (not implemented)")
end

-- MissionKey -> function mapping
local MISSION_FUNCTIONS = {
	CleanStreets = autoCleanStreets,
	RescueCat    = autoRescueCat,
	FoodDelivery = autoFoodDelivery,
	RareFlower   = autoRareFlower,
}

-- =====================
-- FIND & ACCEPT MISSION
-- =====================

local function openMissionGUI()
	game:GetService("ReplicatedStorage").GameInfo.Events.Squad.Create:FireServer()
	game.Players.LocalPlayer.PlayerGui:WaitForChild("Missions").Enabled = true
	task.wait(0.5)
end

local function findAndAcceptMission(cooldownUntil)
	local player        = game.Players.LocalPlayer
	local playerRating  = player:WaitForChild("leaderstats"):WaitForChild("Rating").Value
	local playerVillage = player.Team and player.Team.Name or ""
	local MissionList   = game:GetService("ReplicatedStorage"):WaitForChild("Missions"):WaitForChild("List")
	local now           = os.clock()

	for _, mission in ipairs(MissionList:GetChildren()) do
		local missionRank    = mission:GetAttribute("MissionRank")
		local missionVillage = mission:GetAttribute("Village")
		local missionKey     = mission:GetAttribute("MissionKey")

		if not (missionRank and missionVillage and missionKey) then continue end
		if cooldownUntil[mission.Name] and now < cooldownUntil[mission.Name] then continue end
		if not canDoMission(playerRating, missionRank) then continue end
		if missionVillage ~= playerVillage then continue end

		local acceptEvent = mission:FindFirstChild("Accept")
		if acceptEvent and acceptEvent:IsA("RemoteEvent") then
			acceptEvent:FireServer()
			local name = mission:GetAttribute("MissionName") or mission.Name
			Library:Notify("Accepted: " .. name, 4)
			log("Accepted mission: " .. name .. " (key=" .. missionKey .. ")")
			local cd = mission:GetAttribute("TotalCooldown") or 90
			cooldownUntil[mission.Name] = os.clock() + cd
			return missionKey
		end
	end

	return nil
end

-- =====================
-- NO FALL DAMAGE (Reversible via hookmetamethod)
-- =====================
-- Potassium: hookmetamethod on the SelfHarm RemoteEvent's metatable.
-- We intercept __namecall so that when the game calls SelfHarm:FireServer()
-- we silently drop the call. This is fully reversible by unhooring,
-- unlike Destroy() which permanently breaks the RemoteEvent.

local selfHarmHook   = nil
local originalNamecall = nil

local function enableNoFallDamage()
	local selfHarm = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and
		game:GetService("ReplicatedStorage").Events:FindFirstChild("SelfHarm")

	if not selfHarm then
		Library:Notify("SelfHarm RemoteEvent not found.", 3)
		log("NoFallDamage: SelfHarm not found")
		return
	end

	-- Potassium: hookmetamethod intercepts __namecall on the game's metatable.
	-- We check if the method being called is FireServer on the SelfHarm remote
	-- and drop it silently; all other calls pass through normally.
	originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		if self == selfHarm and method == "FireServer" then
			return -- block fall damage fire
		end
		return originalNamecall(self, ...)
	end)

	selfHarmHook = true
	Library:Notify("No Fall Damage enabled (reversible).", 3)
	log("NoFallDamage: hook applied")
end

local function disableNoFallDamage()
	if selfHarmHook and originalNamecall then
		-- Potassium: restorefunction undoes our hookmetamethod
		-- by swapping the hook back out for the original.
		hookmetamethod(game, "__namecall", originalNamecall)
		originalNamecall = nil
		selfHarmHook     = nil
		Library:Notify("No Fall Damage disabled.", 3)
		log("NoFallDamage: hook removed")
	else
		Library:Notify("No Fall Damage was not active.", 3)
	end
end

-- =====================
-- TOGGLE: AUTO MISSIONS
-- =====================

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
					openMissionGUI()

					local missionKey = findAndAcceptMission(cooldownUntil)
					if not missionKey then
						Library:Notify("All missions on cooldown, waiting...", 3)
						log("All missions on cooldown — waiting 10s")
						task.wait(10)
						continue
					end

					-- Wait for server "Start" event confirmation
					local startTimeout = os.clock() + 5
					while missionRunning and not activeMission.running and os.clock() < startTimeout do
						task.wait(0.2)
					end

					if not activeMission.running then
						Library:Notify("Mission didn't start in time, retrying...", 3)
						log("Mission did not start within timeout — retrying")
						task.wait(2)
						continue
					end

					local missionFn = MISSION_FUNCTIONS[missionKey]
					if missionFn then
						Library:Notify("Running: " .. missionKey, 4)
						log("Running mission function: " .. missionKey)
						missionFn()
						waitForMissionComplete()
						if missionRunning then
							Library:Notify(missionKey .. " complete! Finding next...", 3)
							log(missionKey .. " complete")
							task.wait(2)
						end
					else
						Library:Notify("No handler for: " .. missionKey .. ", waiting out.", 4)
						log("No handler for missionKey: " .. missionKey)
						waitForMissionComplete()
						task.wait(2)
					end
				end
			end)
		else
			Library:Notify("Auto missions stopped.", 3)
			log("Auto missions disabled")
			if missionThread then
				task.cancel(missionThread)
				missionThread = nil
			end
		end
	end,
})

MissionBox:AddDivider()

-- =====================
-- TOGGLE: NO FALL DAMAGE
-- =====================

MissionBox:AddToggle("NoFallDamage", {
	Text    = "No Fall Damage",
	Default = false,
	Callback = function(value)
		if value then
			enableNoFallDamage()
		else
			disableNoFallDamage()
		end
	end,
})
