local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Reset")

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
    Net:Fire("OnReset")
end)

StarterGui:SetCore("ResetButtonCallback", resetBindable)
