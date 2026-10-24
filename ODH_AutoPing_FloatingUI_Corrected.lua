-- ODH Auto Ping Floating UI
-- Displays live network ping and the matching informational profile.
-- This UI does NOT apply or change Silent Aim / targeting settings.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up an earlier copy if the addon is reloaded.
pcall(function()
    local old = PlayerGui:FindFirstChild("ODHAutoPingFloatingUI")
    if old then old:Destroy() end
end)

local function getPingMs()
    local ok, seconds = pcall(function()
        return LocalPlayer:GetNetworkPing()
    end)
    if not ok or type(seconds) ~= "number" then return nil end
    return math.max(0, math.floor(seconds * 1000 + 76.5))
end

local function getProfile(ping)
    if ping <= 30 then return "V10 (10–30 ms)"
    elseif ping <= 55 then return "V10 (30–55 ms)"
    elseif ping <= 85 then return "V10 (55–85 ms)"
    elseif ping <= 125 then return "V10 (85–125 ms)"
    elseif ping <= 195 then return "V10 (125–195 ms)"
    else return "V10 (140–240 ms+)" end
end

local gui = Instance.new("ScreenGui")
gui.Name = "ODHAutoPingFloatingUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(250, 126)
panel.Position = UDim2.new(1, -266, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(13, 24, 35)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(35, 165, 180)
panelStroke.Transparency = 0.2
panelStroke.Thickness = 1.3
panelStroke.Parent = panel

local titleBar = Instance.new("TextButton")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, -38, 0, 32)
titleBar.Position = UDim2.fromOffset(8, 4)
titleBar.BackgroundTransparency = 1
titleBar.Text = "ODH  •  AUTO PING"
titleBar.TextColor3 = Color3.fromRGB(230, 245, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 13
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = panel

local collapse = Instance.new("TextButton")
collapse.Name = "CollapseButton"
collapse.Size = UDim2.fromOffset(28, 28)
collapse.Position = UDim2.new(1, -32, 0, 5)
collapse.BackgroundColor3 = Color3.fromRGB(31, 69, 83)
collapse.BorderSizePixel = 0
collapse.Text = "⌄"
collapse.TextColor3 = Color3.new(1, 1, 1)
collapse.Font = Enum.Font.GothamBold
collapse.TextSize = 20
collapse.Parent = panel
local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(0, 7)
collapseCorner.Parent = collapse

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
profileLabel.Position = UDim2.fromOffset(10, 77)
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
local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopen
local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(35, 165, 180)
reopenStroke.Thickness = 1.3
reopenStroke.Parent = reopen

collapse.Activated:Connect(function()
    panel.Visible = false
    reopen.Visible = true
end)
reopen.Activated:Connect(function()
    reopen.Visible = false
    panel.Visible = true
end)

-- Drag the panel using its title bar; also move the reopen button when collapsed.
local dragging = false
local dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    panel.Position = newPos
    reopen.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset + panel.AbsoluteSize.X - reopen.AbsoluteSize.X,
        newPos.Y.Scale, newPos.Y.Offset)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
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
