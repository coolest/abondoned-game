local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local function knockback(root, force)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = force
    bodyVelocity.Parent = root

    Red.Spawn(function()
        task.wait(1/2)

        bodyVelocity:Destroy()
    end)
end

return function(obj, force)
    local objType = typeof(obj)
    assert(objType == "Instance", "Object provided needs to be a roblox instance")

    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        knockback(obj, force)
    elseif obj:IsA("Model") and obj.PrimaryPart then
        knockback(obj.PrimaryPart, force)
    end
end