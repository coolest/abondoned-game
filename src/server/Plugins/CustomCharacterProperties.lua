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

    root.CustomPhysicalProperties = PhysicalProperties.new(25, 0.5, 0.3)
    humanoid.JumpPower = 65;

    --[[
    local db = true;
    humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if not db then
            return;
        end

        db = false;
        humanoid.JumpPower = 0;

        local isJumping = humanoid.Jump
        if isJumping then
            local velocity = root.CFrame.LookVector * 10 + root.CFrame.UpVector * 30
            root.AssemblyLinearVelocity += velocity*3
        end

        task.wait(8/10)

        db = true;
        humanoid.JumpPower = 50;
    end)
    ]]
end)