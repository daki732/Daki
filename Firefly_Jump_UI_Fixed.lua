local shared = odh_shared_plugins

if not shared then
    warn("[Firefly Jump+] ODH plugin API not found")
    return
end

local section = shared.AddSection("Firefly Jump+")

section:AddLabel("Firefly Jump+")
section:AddParagraph("About", "Firefly Jar jump UI prototype. UI only; no movement automation.")

section:AddToggle("Enable Firefly Jump UI", function(enabled)
    if enabled then
        shared.Notify("Firefly Jump UI enabled", 2)
    else
        shared.Notify("Firefly Jump UI disabled", 2)
    end
end)

section:AddSlider("Cooldown Display (seconds)", 1, 10, 2, function(value)
    print("[Firefly Jump+] Cooldown display: " .. tostring(value) .. " seconds")
end)

section:AddToggle("Show Cooldown Status", function(enabled)
    shared.Notify(enabled and "Cooldown status shown" or "Cooldown status hidden", 2)
end)

section:AddButton("Check Status", function()
    shared.Notify("Firefly Jump+ UI loaded", 3)
end)
