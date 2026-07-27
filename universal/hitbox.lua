local K       = getgenv().KUSHAN
local Library = K.Library

local CombatBox = K.Tabs.Combat:AddLeftGroupbox("Hitbox", "box")

-- =====================
-- LOAD LIMBEXTENDER
-- =====================
local LimbExtender = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/cv98gbxtdf-glitch/Kushan/refs/heads/main/universal/LimbExtender.lua"
))()

if not LimbExtender then
    Library:Notify("Failed to load LimbExtender.", 5)
    return
end

-- =====================
-- CREATE CONTROLLER
-- =====================
local controller = LimbExtender.new({
    PLAYER_ENABLED   = true,
    NPC_ENABLED      = false,
    TARGET_LIMB      = "Head",
    LIMB_SIZE        = 10,
    LIMB_TRANSPARENCY = 0.7,
    LIMB_CAN_COLLIDE = false,
    TEAM_CHECK       = false,
    FORCEFIELD_CHECK = false,
    LISTEN_FOR_INPUT = false, -- Obsidian handles input
    MOBILE_BUTTON    = false,
})

if not controller then
    Library:Notify("LimbExtender controller failed to initialize.", 5)
    return
end

-- =====================
-- UI
-- =====================
CombatBox:AddToggle("HitboxToggle", {
    Text    = "Hitbox Extender",
    Default = false,
    Callback = function(v)
        controller:Toggle(v)
    end,
})

CombatBox:AddToggle("HitboxTeamFilter", {
    Text    = "Filter Teammates",
    Default = false,
    Callback = function(v)
        controller:Set("TEAM_CHECK", v)
    end,
})

CombatBox:AddToggle("HitboxForceField", {
    Text    = "ForceField Check",
    Default = false,
    Callback = function(v)
        controller:Set("FORCEFIELD_CHECK", v)
    end,
})

CombatBox:AddDropdown("BoneSelect", {
    Text    = "Target Bone",
    Values  = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso" },
    Default = 1,
    Callback = function(v)
        controller:Set("TARGET_LIMB", v)
    end,
})

CombatBox:AddSlider("HitboxSize", {
    Text     = "Hitbox Size",
    Min      = 1,
    Max      = 50,
    Default  = 10,
    Suffix   = " studs",
    Callback = function(v)
        controller:Set("LIMB_SIZE", v)
    end,
})

CombatBox:AddSlider("HitboxTransparency", {
    Text     = "Transparency",
    Min      = 0,
    Max      = 1,
    Default  = 0.7,
    Callback = function(v)
        controller:Set("LIMB_TRANSPARENCY", v)
    end,
})

CombatBox:AddButton({
    Text = "Reset Hitboxes",
    Callback = function()
        controller:Stop()
        -- Also flip the toggle off so state stays in sync
        if K.Options.HitboxToggle then
            K.Options.HitboxToggle:SetValue(false)
        end
        Library:Notify("Hitboxes reset.", 3)
    end,
})
