local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = ReplicatedStorage.Helpers
local SystemHelper = require(Helpers.SystemsHelper)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

return function(pos, distance)
    assert(pos and typeof(pos) == "Vector3", "Position needs to be a Vector3")

    local systems = workspace:FindFirstChild("__Systems"):GetChildren()
    local subsNearPosition = {}
    for _, system in ipairs(systems) do
        local submarine = SystemHelper.getSubmarineInSystem(system)
        if not submarine then
            continue
        end

        local isInRange = (submarine.Position - pos).Magnitude < distance
        if isInRange then
            table.insert(subsNearPosition, submarine)
        end
    end
    
    return subsNearPosition
end