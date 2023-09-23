local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function onCharacterAdded(character)
    local animate = character:WaitForChild("Animate")
    animate.idle.Animation1.AnimationId = "rbxassetid://707894699"
    animate.idle.Animation2.AnimationId = "rbxassetid://707894699"
    animate.run.RunAnim.AnimationId = "rbxassetid://845403127"
    animate.jump.JumpAnim.AnimationId = "rbxassetid://742637942"
    animate.fall.FallAnim.AnimationId = "rbxassetid://742637151"
end

local character = player.Character
if character then
    onCharacterAdded(character)
end

return player.CharacterAdded:Connect(onCharacterAdded)