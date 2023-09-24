local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = ReplicatedStorage.Helpers
local SystemHelper = require(Helpers.SystemsHelper)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

return function(pos, distance)
    assert(pos and typeof(pos) == "Vector3", "Position needs to be a Vector3")

    local systems = workspace:FindFirstChild("__Systems"):GetChildren()
    local systemsNearPosition = {}
    for _, system in ipairs(systems) do
        local degree = 0;

        local characters = SystemHelper.getCharactersInSystem(system):GetChildren()
        for _, character in ipairs(characters) do
            local root = character and character.PrimaryPart
            if not root then
                continue
            end

            local isInRange = (root.Position - pos).Magnitude < distance
            if isInRange then
                degree += 1
            end
        end

        local submarine = SystemHelper.getSubmarineInSystem(system)
        if not submarine then
            continue
        end

        local isInRange = (submarine.Position - pos).Magnitude < distance
        if isInRange then
            degree += 1
        end

        if degree > 0 then
            systemsNearPosition[system] = degree
        end
    end
    
    return systemsNearPosition
end