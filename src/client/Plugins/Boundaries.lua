local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packges = ReplicatedStorage.Packages
local flipper = require(Packges.flipper)

local Client = script.Parent.Parent
local Controllers = Client.Controllers
local SlotController = require(Controllers.SlotController)

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

local tweenInfo = {}
tweenInfo[getSystemNotificationGui] = "BackgroundTransparency"
for _, v in ipairs(getSystemNotificationGui:GetDescendants()) do
    local isText = v:IsA("TextLabel")
    if isText then
        tweenInfo[v] = "TextTransparency"
    end

    local isBg = v:IsA("Frame")
    if isBg then
        tweenInfo[v] = "BackgroundTransparency"
    end

    local isReg = v:IsA("UIStroke")
    if isReg then
        tweenInfo[v] = "Transparency"
    end
end

local function changeBoundaryTransparency(value)
    for _, boundary in ipairs(boundaries) do
        boundary.Transparency = value
    end
end

local function tweenNotification(tweenIn)
    local initialValue = tweenIn and 1 or 0
    local finalValue = 1-initialValue

    local motor = flipper.SingleMotor.new(initialValue)
    motor:onStep(function(val)
        for v, p in pairs(tweenInfo) do
            v[p] = val
        end
    end)

    motor:onStart(function()
        task.wait();
        getSystemNotificationGui.Visible = true;
    end)

    motor:onComplete(function()
        getSystemNotificationGui.Visible = tweenIn
    end)

    motor:setGoal(flipper.Spring.new(finalValue, {frequency = 4}))
    motor:start()
end

local function onCharacterAdded(character)
    tweenNotification(true)
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
    tweenNotification(false)
end)

SlotController.getLeaveSignal():Connect(function()
    tweenNotification(true)
end)

return true;