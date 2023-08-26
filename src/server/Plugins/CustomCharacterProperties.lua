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

    local animate = character:FindFirstChild("Animate")
    animate.idle.Animation1.AnimationId = "rbxassetid://707894699"
    animate.idle.Animation2.AnimationId = "rbxassetid://707894699"
    animate.run.RunAnim.AnimationId = "rbxassetid://845403127"
    animate.jump.JumpAnim.AnimationId = "rbxassetid://742637942"
    animate.fall.FallAnim.AnimationId = "rbxassetid://742637151"
end)