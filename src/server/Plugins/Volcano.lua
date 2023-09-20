local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local DamageService = require(Services.DamageService)
local RagdollService = require(Services.RagdollService)
local MovementService = require(Services.MovementService)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local getPlayersNearPosition = require(Utils.getPlayersNearPosition)
local getSystemsNearPosition = require(Utils.getSystemsNearPosition)
local assert = require(Utils.assert)

local Net = Red.Server("Volcano", {"Lavaball"})

local map = workspace

local LAVABALL_DAMAGE = 50;

local volcanos = {}
for _, v in ipairs(map:GetChildren()) do
    if v.Name == "Volcano" then
        table.insert(volcanos, {
            model = v;
            spawnsPerSecond = 4;
            lastSpawn = os.clock();
        })
    end
end

local function spawnLavaBall(model)
    assert(model and model:IsA("Model") and model.PrimaryPart, "Need to provide a valid volcano with a valid primary part")

    local radius = math.random(70, 125)
    local arc = math.random(50, 100)
    local centerPos = model.PrimaryPart.Position
    local theta = math.random(0, 360)
    local delta = (CFrame.new(centerPos)*CFrame.Angles(0, math.rad(theta), 0)).LookVector * radius
    local dropPosition = centerPos + delta
    local castResult = workspace:Raycast(dropPosition, Vector3.new(0, -100, 0))
    if castResult and castResult.Position then
        local lavaballPos = castResult.Position

        Net:FireList(getPlayersNearPosition(lavaballPos, 200), 'Lavaball', {
            arc = arc,
            startPos = centerPos,
            endPos = lavaballPos,
        })

        task.delay(3, function()
            local systems = getSystemsNearPosition(lavaballPos, 10)
            for system, degree in pairs(systems) do
                DamageService.damageSystem(system, LAVABALL_DAMAGE*degree)
            end

            local players = getPlayersNearPosition(lavaballPos, 10)
            for _, player in ipairs(players) do
                local character = player.Character
                local rootPart = character.PrimaryPart
                RagdollService.ragdollOn(character)

                local force = Vector3.new(0, 50, 0) + (rootPart.Position - lavaballPos).Unit * 50
                MovementService.knockback(character, force)

                local knockbackComplete = MovementService.getSignalForKnockbackComplete(character)
                knockbackComplete:Connect(function()
                    task.wait(1/2)

                    RagdollService.ragdollOff(character)
                end)
            end
        end)
    end
end

RunService.PostSimulation:Connect(function()
    local currentTime = os.clock()

    for _, volcano in ipairs(volcanos) do
        local delta = 1/volcano.spawnsPerSecond
        local lastSpawn = volcano.lastSpawn

        if currentTime-lastSpawn > delta then
            volcano.lastSpawn = currentTime

            spawnLavaBall(volcano.model)
        end
    end
end)

return true;