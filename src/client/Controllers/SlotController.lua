local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local gui = Player.PlayerGui.Gui

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local goodsignal = require(Packages.goodsignal)

local Net = Red.Client("Slot")

local SlotController = {}

function SlotController.Init()
    local slotGui = gui.Slots

    local onJoin = goodsignal.new()
    local onLeave = goodsignal.new()

    Net:On("Join", function()
        SlotController.toggleSlotGuis(true)
        onJoin:Fire()
    end)
    Net:On("Start", function()
        SlotController.toggleSlotGuis(false)
    end)

    SlotController.SLOT_GUI = slotGui
    SlotController._state = {
        onJoin = onJoin;
        onLeave = onLeave
    };
    
    slotGui.Start.MouseButton1Click:Connect(function()
        SlotController.toggleSlotGuis(false)

        local ok = Net:Fire("Start")
        if not ok then
            SlotController.toggleSlotGuis(true)
        end
    end)

    slotGui.Leave.MouseButton1Click:Connect(function()
        onLeave:Fire()
        SlotController.toggleSlotGuis(false)

        local ok = Net:Fire("Leave")
        if not ok then
            SlotController.toggleSlotGuis(true)
        end
    end)
end

function SlotController.Start()
    
end

function SlotController.getSlotGui()
    return SlotController.SLOT_GUI
end

function SlotController.toggleSlotGuis(visible)
    SlotController.getSlotGui().Visible = visible
end

function SlotController.getLeaveSignal()
    return SlotController._state.onLeave
end

function SlotController.getJoinSignal()
    return SlotController._state.onJoin
end

return SlotController