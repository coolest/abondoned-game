local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local gui = Player.PlayerGui.Gui

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Slot")

local SlotController = {}

function SlotController.Init()
    local slotGui = gui.Slots

    Net:On("Join", function()
        SlotController.toggleSlotGuis(true)
    end)
    Net:On("Start", function()
        SlotController.toggleSlotGuis(false)
    end)

    SlotController._state = {}
    SlotController.SLOT_GUI = slotGui

    slotGui.Start.MouseButton1Click:Connect(function()
        SlotController.toggleSlotGuis(false)

        local ok = Net:Fire("Start")
        if not ok then
            SlotController.toggleSlotGuis(true)
        end
    end)

    slotGui.Leave.MouseButton1Click:Connect(function()
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

return SlotController