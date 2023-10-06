local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local gui = Player.PlayerGui.Gui

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local goodsignal = require(Packages.goodsignal)

local Net = Red.Client("Slot")

local Client = script.Parent.Parent
local Controllers = Client.Controllers
local TweenController = require(Controllers.TweenController)

local SlotController = {}

function SlotController.Init()
    local slotGui = gui.Slots
    
    local onJoin = goodsignal.new()
    local onLeave = goodsignal.new()

    SlotController._state = {
        onJoin = onJoin;
        onLeave = onLeave;

        slotGui = slotGui;
    };
end

function SlotController.Start()
    local slotGui = SlotController.getSlotGui()
    local slotGuiTweenInfo = TweenController.formatGui(slotGui)

    local onLeave = SlotController.getLeaveSignal()
    local onJoin = SlotController.getJoinSignal()
    
    Net:On("Join", function()
        TweenController.tweenIn(slotGuiTweenInfo)

        onJoin:Fire()
    end)

    Net:On("Start", function()
        TweenController.tweenOut(slotGuiTweenInfo)
    end)
    
    slotGui.Start.MouseButton1Click:Connect(function()
        TweenController.tweenOut(slotGuiTweenInfo)

        local ok = Net:Fire("Start")
        if not ok then
            TweenController.tweenIn(slotGuiTweenInfo)
        end
    end)

    slotGui.Leave.MouseButton1Click:Connect(function()
        onLeave:Fire()
        TweenController.tweenOut(slotGuiTweenInfo)

        local ok = Net:Fire("Leave")
        if not ok then
            TweenController.tweenIn(slotGuiTweenInfo)
        end
    end)
end

function SlotController.getSlotGui()
    return SlotController._state.slotGui
end

function SlotController.getLeaveSignal()
    return SlotController._state.onLeave
end

function SlotController.getJoinSignal()
    return SlotController._state.onJoin
end

return SlotController