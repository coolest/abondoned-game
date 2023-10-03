local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local HealthService = require(Services.HealthService)
local RagdollService = require(Services.RagdollService)
local MovementService = require(Services.MovementService)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local getPlayersNearPosition = require(Utils.getPlayersNearPosition)
local getSystemsNearPosition = require(Utils.getSystemsNearPosition)
local getSubmarinesNearPosition = require(Utils.getSubmarinesNearPosition)
local assert = require(Utils.assert)

local Helpers = ReplicatedStorage.Helpers
local SystemHelper = require(Helpers.SystemsHelper)
local SpecialParts = require(Helpers.SpecialParts)

local Net = Red.Server("Volcano", {"Lavaball"})

local LAVABALL_DAMAGE = 50;

local volcanos = {}
for _, v in ipairs(SpecialParts.getVolcanos()) do
    table.insert(volcanos, {
        model = v;
        spawnsPerSecond = 4;
        lastSpawn = os.clock();
    })
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
                HealthService.damageSystem(system, LAVABALL_DAMAGE*degree)
            end

            local systemsAfflicted = {}
            local players = getPlayersNearPosition(lavaballPos, 10)
            for _, player in ipairs(players) do
                local focusCharacter = player.Character
                local system = SystemHelper.getSystemFromCharacter(focusCharacter)
                if not system then
                    continue
                end

                local charactersContainer = SystemHelper.getCharactersInSystem(system)
                local submarine = SystemHelper.getSubmarineInSystem(system)
                if not (charactersContainer and submarine)then
                    continue
                end

                table.insert(systemsAfflicted, system)

                local rootPart = focusCharacter.PrimaryPart
                local force = Vector3.new(0, 50, 0) + (rootPart.Position - lavaballPos).Unit * 50
                RagdollService.ragdollOn(focusCharacter)
                MovementService.knockback(focusCharacter, force)

                local knockbackComplete = MovementService.getSignalForKnockbackComplete(focusCharacter)
                knockbackComplete:Connect(function()
                    task.wait(0.5 + 1/5)

                    for _, character in ipairs(charactersContainer:GetChildren()) do
                        RagdollService.ragdollOff(character)
                    end    
                end)

                task.delay(1/5, function()
                    MovementService.knockback(submarine, force)
                    for _, character in ipairs(charactersContainer:GetChildren()) do
                        if focusCharacter == character then
                            continue
                        end

                        RagdollService.ragdollOn(character)
                        MovementService.knockback(character, force)
                    end
                end)
            end

            local submarines = getSubmarinesNearPosition(lavaballPos, 10)
            for _, submarine in ipairs(submarines) do
                local system = SystemHelper.getSystemFromSubmarine(submarine)
                if not system or table.find(systemsAfflicted, system) then
                    continue
                end

                local charactersContainer = SystemHelper.getCharactersInSystem(system)
                local characters = charactersContainer:GetChildren()
                local focusCharacter = characters[1]

                local force = Vector3.new(0, 50, 0) + (submarine.Position - lavaballPos).Unit * 50

                MovementService.knockback(submarine, force)
                task.delay(1/5, function()
                    for _, character in ipairs(charactersContainer:GetChildren()) do
                        RagdollService.ragdollOn(character)
    
                        MovementService.knockback(character, force/2)
                    end

                    local knockbackComplete = MovementService.getSignalForKnockbackComplete(focusCharacter)
                    knockbackComplete:Connect(function()
                        task.wait(1/2)
    
                        for _, character in ipairs(charactersContainer:GetChildren()) do
                            RagdollService.ragdollOff(character)
                        end    
                    end)
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