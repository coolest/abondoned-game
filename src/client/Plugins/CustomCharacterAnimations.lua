local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Events
local CharacterAdded = require(Events.CharacterAdded)

return CharacterAdded.Signal:Connect(function(character)
    local animate = character:FindFirstChild("Animate")
    animate.idle.Animation1.AnimationId = "rbxassetid://707894699"
    animate.idle.Animation2.AnimationId = "rbxassetid://707894699"
    animate.run.RunAnim.AnimationId = "rbxassetid://845403127"
    animate.jump.JumpAnim.AnimationId = "rbxassetid://742637942"
    animate.fall.FallAnim.AnimationId = "rbxassetid://742637151"
end)