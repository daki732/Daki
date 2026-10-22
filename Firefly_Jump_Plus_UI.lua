-- Firefly Jump+ (UI-only ODH addon)
-- Uses the ODH UI API pattern from the file you supplied.
-- This version contains UI/configuration only; it does not manipulate gameplay.

local shared = odh_shared_plugins

if not shared or shared.game_name ~= "Murder Mystery 2" then
    return
end

local tab = shared.CreateTab(
    "Firefly Jump+",
    "/aux0on/GPIcon/refs/heads/main/Untitled163_20260919034104"
)

local config = {
    enabled = false,
    cooldown = 1.0,
}

local mainSection = tab:AddSection("Firefly Jump+", "Main")

mainSection:AddToggle("Enable Firefly Jump+", function(value)
    config.enabled = value
    -- UI toggle only; no automatic jump/gameplay manipulation is performed.
end)

local settingsSection = tab:AddSection("Settings", "Cooldown")

settingsSection:AddSlider("Cooldown (seconds)", 0.2, 5.0, config.cooldown, function(value)
    config.cooldown = value
end)
