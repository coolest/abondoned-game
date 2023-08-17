local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ReplicatedStorage.Events
local CharacterAdded = require(Events.CharacterAdded)

local Services = ServerScriptService.Services
local SlotService = require(Services.SlotService)

local spawns = workspace.Spawns
local counter = math.random(1, 2)

local function spawnCharacter(character)
    if not workspace:WaitForChild(character.Name, 5) then
        return;
    end

    local player = Players:GetPlayerFromCharacter(character)
    local charRoot = character:FindFirstChild("HumanoidRootPart")
    if not charRoot then
        return;
    end

    if SlotService.playerIsInSlot(player) then
        SlotService.placeCharacterInSlot(charRoot, SlotService.getPlayerSlot(player))
    else
        counter += 1;
        counter %= 60;

        local spawnPart = spawns:FindFirstChild(tostring(counter%2 + 1))
        local pos, size = spawnPart.Position, spawnPart.Size
        local x_min, x_max, z_min, z_max = pos.X-size.X/2, pos.X+size.X/2, pos.Z-size.Z/2, pos.Z+size.Z/2

        charRoot.CFrame = CFrame.new(
            math.random(x_min, x_max),
            pos.Y + 5,
            math.random(z_min, z_max)
        );
    end
end

CharacterAdded.Signal:Connect(spawnCharacter)

return spawnCharacter
