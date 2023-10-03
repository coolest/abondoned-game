local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameSettings = UserSettings().GameSettings

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local Player = Players.LocalPlayer

local distances = {20, 35, 50, 50, 75, 75, 100, 150, 200, 250}

return function(object, opts)
    assert(object and typeof(object) == "Instance", debug.traceback(5) .. "\nObject provided needs to be a roblox instance!")

    if opts then
        local qualityLevel = GameSettings.SavedQualityLevel.Value
        local character = Player.Character
        local root = character and character.PrimaryPart
        if not root then
            return;
        end

        local emitPos = opts.position
        local distance = distances[qualityLevel]
        local isOutsideRange = (root.Position - emitPos).Magnitude > distance
        if isOutsideRange then
            return;
        end
    end

    for _, particle in ipairs(object:GetDescendants()) do
        local isValid = particle:IsA("ParticleEmitter")
        if not isValid then
            continue
        end

        local emitDelay = particle:GetAttribute("EmitDelay")
        local emitCount = particle:GetAttribute("EmitCount")
        if emitCount == 0 then
            particle:Emit(emitCount)
        else
            task.delay(emitDelay, particle.Emit, particle, emitCount)
        end
    end
end