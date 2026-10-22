-- ODH Auto Ping Profile Monitor
-- Reads ping and announces the matching profile. It does NOT modify Silent Aim
-- or any targeting settings.

local shared = odh_shared_plugins
local section = shared.AddSection("Auto Ping Profile Monitor")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local currentProfile = ""

-- Ranges are made non-overlapping so exactly one profile is selected.
local profiles = {
    { Name = "V10 (10-30ms)", Min = 10, Max = 30, Vertical = 162, Horizontal = 168, X = -5, Y = -8, Z = 0, Sim = 58, Interval = 52 },
    { Name = "V10 (31-55ms)", Min = 31, Max = 55, Vertical = 167, Horizontal = 173, X = -5, Y = -8, Z = 0, Sim = 62, Interval = 54 },
    { Name = "V10 (56-85ms)", Min = 56, Max = 85, Vertical = 171, Horizontal = 178, X = -6, Y = -8, Z = 0, Sim = 67, Interval = 58 },
    { Name = "V10 (86-125ms)", Min = 86, Max = 125, Vertical = 176, Horizontal = 184, X = -7, Y = -8, Z = 0, Sim = 71, Interval = 62 },
    { Name = "V10 (126-195ms)", Min = 126, Max = 195, Vertical = 180, Horizontal = 189, X = -8, Y = -9, Z = 0, Sim = 78, Interval = 68 },
    { Name = "V10 (196-240ms)", Min = 196, Max = 240, Vertical = 184, Horizontal = 194, X = -9, Y = -9, Z = 0, Sim = 82, Interval = 72 },
}

local function getPingMs()
    local ok, pingSeconds = pcall(function()
        return LocalPlayer:GetNetworkPing()
    end)
    if not ok or type(pingSeconds) ~= "number" then
        return nil
    end
    return math.max(0, math.floor(pingSeconds * 1000 + 0.5))
end

local function getProfile(ping)
    for _, profile in ipairs(profiles) do
        if ping >= profile.Min and ping <= profile.Max then
            return profile
        end
    end
    if ping < 10 then
        return profiles[1]
    end
    return nil -- above 240ms: don't pretend one of the listed profiles matches
end

section:AddLabel("Monitors ping and announces the matching preset")
section:AddLabel("Preset values are shown in code; this monitor does not apply them")

section:AddToggle("Enable Ping Monitor", function(state)
    enabled = state
    if state then
        shared.Notify("Auto Ping Profile Monitor enabled", 3)
    else
        shared.Notify("Auto Ping Profile Monitor disabled", 3)
    end
end)

section:AddButton("Check Ping Now", function()
    local ping = getPingMs()
    if not ping then
        shared.Notify("Could not read ping", 3)
        return
    end
    local profile = getProfile(ping)
    if profile then
        shared.Notify(string.format("Ping: %d ms | %s", ping, profile.Name), 4)
    else
        shared.Notify(string.format("Ping: %d ms | No listed preset above 240 ms", ping), 4)
    end
end)

task.spawn(function()
    while task.wait(2) do
        if enabled then
            local ping = getPingMs()
            if ping then
                local profile = getProfile(ping)
                local profileName = profile and profile.Name or "No listed preset (>240ms)"
                if currentProfile ~= profileName then
                    currentProfile = profileName
                    if profile then
                        shared.Notify(string.format("Ping: %d ms | Matching preset: %s", ping, profile.Name), 4)
                    else
                        shared.Notify(string.format("Ping: %d ms | No listed preset above 240 ms", ping), 4)
                    end
                end
            end
        end
    end
end)
