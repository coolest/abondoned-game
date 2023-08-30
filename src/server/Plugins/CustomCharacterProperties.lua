local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Events
local CharacterAdded = require(Events.CharacterAdded)

local assets = workspace.Assets

local GameItems = ReplicatedStorage._GAME_ITEMS
local bubblesPart = GameItems.VFX.BubblesSpawn
local mouthBreathingVFX = ReplicatedStorage._GAME_ITEMS.VFX.MouthHolder.Attachment

return CharacterAdded.Signal:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 30)
    if not humanoid then
        return;
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return;
    end

    local head = character:FindFirstChild("Head")
    if head then
        mouthBreathingVFX:Clone().Parent = head
    end

    local bubbles = bubblesPart:Clone()
    bubbles.CFrame = root.CFrame - Vector3.new(0, humanoid.HipHeight, 0)
    bubbles.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = bubbles
    weld.Parent = root

    root.CustomPhysicalProperties = PhysicalProperties.new(35, 0.5, 0.3)
    humanoid.JumpPower = 100;

    local animate = character:FindFirstChild("Animate")
    animate.idle.Animation1.AnimationId = "rbxassetid://707894699"
    animate.idle.Animation2.AnimationId = "rbxassetid://707894699"
    animate.run.RunAnim.AnimationId = "rbxassetid://845403127"
    animate.jump.JumpAnim.AnimationId = "rbxassetid://742637942"
    animate.fall.FallAnim.AnimationId = "rbxassetid://742637151"
end)