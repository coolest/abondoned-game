local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local GoodSignal = require(Packages.goodsignal)
local Red = require(Packages.red)

local signal = GoodSignal.new()

local IS_SERVER = RunService:IsServer()
if IS_SERVER then
    local Net = Red.Server("Death", "Death")

    signal:Connect(function(player)
        Net:Fire(player, "Death")
    end)
else
    local Net = Red.Client("Death")

    Net:On("Death", function()
        signal:Fire()
    end)
end

return {
    Signal = signal,
    SystemsStarted = function() end;
};