local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local assets = workspace.Assets

local GameItems = ReplicatedStorage._GAME_ITEMS
local cameraBubbles = GameItems.VFX.Bubbles

cameraBubbles.Parent = assets
cameraBubbles.Anchored = true;
cameraBubbles.CanCollide = false;

RunService:BindToRenderStep("CameraBubbles", Enum.RenderPriority.Camera.Value+1, function()
    local camCFrame = camera.CFrame

    cameraBubbles.CFrame = camCFrame + camCFrame.LookVector * 5
end)

return true;