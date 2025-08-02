--[[
    Custom Grow a Garden Script
    Owner: moonitt14
    Type: LocalScript
]]

local ownerUsername = "moonitt14"
local gardenPosition = Vector3.new(100, 5, 100) -- set your custom garden location
local toolNames = {"Watering Can", "Hoe", "Seed Bag"}

-- Wait for game to load
repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Check if the player is the garden owner
local isOwner = player.Name == ownerUsername

-- Teleport owner to their garden
if isOwner then
    character:MoveTo(gardenPosition)
    print("[+] Welcome back to your garden, " .. ownerUsername)
end

-- Give tools to owner
local function giveTools()
    if not isOwner then return end

    for _, toolName in ipairs(toolNames) do
        local tool = ReplicatedStorage:FindFirstChild(toolName)
        if tool then
            local clone = tool:Clone()
            clone.Parent = player.Backpack
            print("[+] Given tool:", toolName)
        end
    end
end

giveTools()

-- Auto-collect plants around the player (for owner only)
local function collectNearbyPlants(radius)
    if not isOwner then return end

    local range = radius or 15
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Plant" then
            local dist = (obj.Position - character.HumanoidRootPart.Position).Magnitude
            if dist <= range then
                firetouchinterest(character.HumanoidRootPart, obj, 0)
                wait(0.1)
                firetouchinterest(character.HumanoidRootPart, obj, 1)
                print("[+] Collected plant at distance:", math.floor(dist))
            end
        end
    end
end

collectNearbyPlants()

-- OPTIONAL: Teleport others to your garden (if you're the owner)
local function teleportOthersToOwner()
    if not isOwner then return end

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Name ~= ownerUsername and otherPlayer.Character then
            otherPlayer.Character:MoveTo(gardenPosition + Vector3.new(5, 0, 0))
            print("[>] Teleported " .. otherPlayer.Name .. " to your garden.")
        end
    end
end

-- Enable below if you want to teleport others automatically
-- teleportOthersToOwner()
