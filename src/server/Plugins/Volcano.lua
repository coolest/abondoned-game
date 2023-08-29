local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local getPlayersNearPosition = require(Utils.getPlayersNearPosition)

local Net = Red.Server("Volcano", {"Lavaball"})

local map = workspace

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

    local radius = math.random(50, 90)
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

        task.delay(3.25, function()
            
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