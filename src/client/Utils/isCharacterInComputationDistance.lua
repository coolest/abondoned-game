local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local ClientUtils = script.Parent
local getComputationDistance = require(ClientUtils.getComputationDistance)

local Player = Players.LocalPlayer

return function(pos, bias)
    assert(pos and typeof(pos) == "Vector3", "Type of 'pos' must be a Vector3!")

    local character = Player.Character
    local root = character and character.PrimaryPart
    if not root then
        return false;
    end

    local distance = getComputationDistance()
    local isInsideRange = (root.Position - pos).Magnitude < distance + (bias or 0)
    
    return isInsideRange
end