local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterAdded = require(ReplicatedStorage.Events.CharacterAdded)

return CharacterAdded.Signal:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 30)
    if not humanoid then
        return;
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return;
    end

    root.CustomPhysicalProperties = PhysicalProperties.new(35, 0.5, 0.3)

    humanoid.JumpPower = 100;
end)