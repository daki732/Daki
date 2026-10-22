-- Firefly Jump+ (UI Only)
-- ODH plugin interface based on PluginExample.lua.
-- This file intentionally contains UI controls only; it does not automate movement.

local shared = odh_shared_plugins
local section = shared.AddSection("Firefly Jump+")

section:AddLabel("Firefly Jump+")
section:AddParagraph(
    "About",
    "UI prototype for a Firefly Jar jump helper. Movement automation is not implemented."
)

local enabled = false
local showCooldown = true
local cooldownSeconds = 2
local statusText = "Disabled"

section:AddToggle("Enable Firefly Jump UI", function(bool)
    enabled = bool
    if enabled then
        statusText = "Enabled (UI only)"
        shared.Notify("Firefly Jump UI enabled", 2)
    else
        statusText = "Disabled"
        shared.Notify("Firefly Jump UI disabled", 2)
    end
    print("[Firefly Jump+] " .. statusText)
end)

section:AddSlider("Cooldown Display (seconds)", 1, 10, 2, function(value)
    cooldownSeconds = value
    print("[Firefly Jump+] Cooldown display set to " .. tostring(cooldownSeconds) .. "s")
end)

section:AddToggle("Show Cooldown Status", function(bool)
    showCooldown = bool
    if showCooldown then
        shared.Notify("Cooldown status display enabled", 2)
    else
        shared.Notify("Cooldown status display disabled", 2)
    end
end)

section:AddButton("Check Status", function()
    local cooldownState = showCooldown and
        ("Cooldown display: " .. tostring(cooldownSeconds) .. "s") or
        "Cooldown display hidden"

    shared.Notify(
        "Firefly Jump+: " .. statusText .. " | " .. cooldownState,
        4
    )
end)

section:AddLabel("Note: This is an interface-only prototype.")
