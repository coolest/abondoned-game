local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

return function (part)
    assert(part and (part:IsA("BasePart") or part:IsA("UnionOperation")), "Object provided needs to be a basepart.")

    local parent = part.Parent
    local grandparent = parent.Parent
    local greatGrandparent = grandparent.Parent

    for _, maybeCharacter in ipairs({parent, grandparent, greatGrandparent}) do
        local humanoid = maybeCharacter:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            continue
        end

        -- assume if it has a humanoid it is a character
        return maybeCharacter
    end
end