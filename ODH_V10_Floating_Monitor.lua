-- ODH V10 Floating Ping Monitor
-- Display-only: reads ping and shows a profile. Does not change gameplay settings.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
    local old = playerGui:FindFirstChild("ODHV10FloatingMonitor")
    if old then old:Destroy() end
end)

local function getPingMs()
    local ok, seconds = pcall(function()
        return player:GetNetworkPing()
    end)
    if not ok or type(seconds) ~= "number" then return nil end
    return math.max(0, math.floor(seconds * 1000 + 0.5))
end

local function getProfile(ping)
    if ping <= 40 then return "40 V10"
    elseif ping <= 80 then return "30–85"
    elseif ping <= 120 then return "85–125 V10"
    else return "OMEGA ZERO Ω" end
end

local gui = Instance.new("ScreenGui")
gui.Name = "ODHV10FloatingMonitor"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(260, 126)
panel.Position = UDim2.new(1, -276, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(13, 24, 35)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(35, 165, 180)
stroke.Transparency = 0.2
stroke.Thickness = 1.3

local title = Instance.new("TextButton")
title.Name = "TitleBar"
title.Size = UDim2.new(1, -42, 0, 32)
title.Position = UDim2.fromOffset(10, 4)
title.BackgroundTransparency = 1
title.Text = "ODH  •  V10 MONITOR"
title.TextColor3 = Color3.fromRGB(230, 245, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local collapse = Instance.new("TextButton")
collapse.Name = "CollapseButton"
collapse.Size = UDim2.fromOffset(28, 28)
collapse.Position = UDim2.new(1, -33, 0, 5)
collapse.BackgroundColor3 = Color3.fromRGB(31, 69, 83)
collapse.BorderSizePixel = 0
collapse.Text = "⌄"
collapse.TextColor3 = Color3.new(1, 1, 1)
collapse.Font = Enum.Font.GothamBold
collapse.TextSize = 20
collapse.Parent = panel
Instance.new("UICorner", collapse).CornerRadius = UDim.new(0, 7)

local pingLabel = Instance.new("TextLabel")
pingLabel.Name = "PingLabel"
pingLabel.Size = UDim2.new(1, -20, 0, 30)
pingLabel.Position = UDim2.fromOffset(10, 42)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: checking..."
pingLabel.TextColor3 = Color3.fromRGB(75, 255, 130)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 20
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Parent = panel

local profileLabel = Instance.new("TextLabel")
profileLabel.Name = "ProfileLabel"
profileLabel.Size = UDim2.new(1, -20, 0, 38)
profileLabel.Position = UDim2.fromOffset(10, 78)
profileLabel.BackgroundTransparency = 1
profileLabel.Text = "Profile: waiting for ping"
profileLabel.TextColor3 = Color3.fromRGB(220, 230, 240)
profileLabel.Font = Enum.Font.Gotham
profileLabel.TextSize = 12
profileLabel.TextWrapped = true
profileLabel.TextXAlignment = Enum.TextXAlignment.Left
profileLabel.TextYAlignment = Enum.TextYAlignment.Top
profileLabel.Parent = panel

local reopen = Instance.new("TextButton")
reopen.Name = "ReopenButton"
reopen.Size = UDim2.fromOffset(48, 42)
reopen.Position = UDim2.new(1, -60, 0.35, 0)
reopen.BackgroundColor3 = Color3.fromRGB(13, 40, 53)
reopen.BackgroundTransparency = 0.05
reopen.BorderSizePixel = 0
reopen.Text = "⌄"
reopen.TextColor3 = Color3.fromRGB(235, 250, 255)
reopen.Font = Enum.Font.GothamBold
reopen.TextSize = 24
reopen.Visible = false
reopen.Parent = gui
Instance.new("UICorner", reopen).CornerRadius = UDim.new(0, 10)
local reopenStroke = Instance.new("UIStroke", reopen)
reopenStroke.Color = Color3.fromRGB(35, 165, 180)
reopenStroke.Thickness = 1.3

collapse.Activated:Connect(function()
    panel.Visible = false
    reopen.Visible = true
end)
reopen.Activated:Connect(function()
    reopen.Visible = false
    panel.Visible = true
end)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function updateDrag(input)
    local delta = input.Position - dragStart
    local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    panel.Position = pos
    reopen.Position = UDim2.new(pos.X.Scale,
        pos.X.Offset + panel.AbsoluteSize.X - reopen.AbsoluteSize.X,
        pos.Y.Scale, pos.Y.Offset)
end
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then updateDrag(input) end
end)

local alive = true
gui.Destroying:Connect(function() alive = false end)
task.spawn(function()
    while alive and gui.Parent do
        local ping = getPingMs()
        if ping then
            pingLabel.Text = string.format("Ping: %d ms", ping)
            profileLabel.Text = "Matching range: " .. getProfile(ping)
        else
            pingLabel.Text = "Ping: unavailable"
            profileLabel.Text = "Could not read network ping"
        end
        task.wait(2)
    end
end)
