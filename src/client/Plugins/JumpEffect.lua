local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = workspace.Assets

local GameItems = ReplicatedStorage._GAME_ITEMS
local jumpVFX = GameItems.VFX.Jump
local jumpBubblesVFX = GameItems.VFX.JumpBubbles

local Utils = ReplicatedStorage.Utils
local Emit = require(Utils.emit)

local Event = ReplicatedStorage.Events
local CharacterAdded = require(Event.CharacterAdded)

CharacterAdded.Signal:Connect(function(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return;
    end

    local root = character.PrimaryPart
    if not root then
        return;
    end

    humanoid.StateChanged:Connect(function(newState)
        local isJumping = newState == Enum.HumanoidStateType.Jumping
        if isJumping then
            local vfx = jumpVFX:Clone()
            vfx.CFrame = root.CFrame - Vector3.new(0, humanoid.HipHeight + 1, 0)
            vfx.Anchored = true;
            vfx.Parent = assets

            Emit(vfx)

            local bubbles = jumpBubblesVFX:Clone()      
            bubbles.CFrame = root.CFrame - Vector3.new(0, humanoid.HipHeight, 0)
            bubbles.Anchored = false;
            bubbles.Parent = assets

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = root
            weld.Part1 = bubbles
            weld.Parent = bubbles

            local emitter = bubbles:FindFirstChild("Bubbles", true)
            if emitter then
                for i = 1, 10 do
                    local emitCount = emitter:GetAttribute("EmitCount")

                    task.delay(i/30, emitter.Emit, emitter, emitCount-i)
                end
            end

            task.delay(3, vfx.Destroy, vfx)
            task.delay(3, bubbles.Destroy, bubbles)
        end
    end)
end)

return true;