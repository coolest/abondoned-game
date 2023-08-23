local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Ragdoll")

local Camera = workspace.CurrentCamera

local function changeHumanoidState(state)
    local character = Player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end
    
    humanoid:ChangeState(state)
end

Net:On("On", function()
    changeHumanoidState(Enum.HumanoidStateType.Physics)


end)

Net:On("Off", function()
    changeHumanoidState(Enum.HumanoidStateType.GettingUp)
end)

return true;