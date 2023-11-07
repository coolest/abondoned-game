local Players = game:GetService("Players")

local Client = script.Parent.Parent
local Controllers = Client.Controllers
local SlotController = require(Controllers.SlotController)
local TweenController = require(Controllers.TweenController)

local boundaries = workspace.Boundaries:GetDescendants()
for i = #boundaries, 1, -1 do
    local isValid = boundaries[i]:IsA("BasePart")
    if not isValid then
        table.remove(boundaries, i)
    end
end

local player = Players.LocalPlayer
local gui = player.PlayerGui.Gui
local getSystemNotificationGui = gui.GetSystemNotification

local tweenInfo = TweenController.formatGui(getSystemNotificationGui)

local function changeBoundaryTransparency(value)
    for _, boundary in ipairs(boundaries) do
        boundary.Transparency = value
    end
end

local function onCharacterAdded(character)
    TweenController.tweenIn(tweenInfo)
    changeBoundaryTransparency(0.5)

    character:GetAttributeChangedSignal("system"):Wait()

    changeBoundaryTransparency(1)
end

--
local currCharacter = player.Character
if currCharacter then
    task.spawn(onCharacterAdded, currCharacter)
end

player.CharacterAdded:Connect(onCharacterAdded)

SlotController.getJoinSignal():Connect(function()
    TweenController.tweenOut(tweenInfo)
end)

SlotController.getLeaveSignal():Connect(function()
    TweenController.tweenIn(tweenInfo)
end)

return true;