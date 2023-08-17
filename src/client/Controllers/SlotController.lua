local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Slot")

local SlotController = {}

function SlotController.Init()
    SlotController._state = {}
end

function SlotController.Start()
    
end

return SlotController