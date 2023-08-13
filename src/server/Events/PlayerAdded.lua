local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(Packages.goodsignal)
local Red = require(Packages.red)

local LoadingNet = Red.Server("Load", {"Complete"})

local signal = GoodSignal.new()
local loaded = false;

local function waitForLoading(player)
    if not loaded then
        repeat
            RunService.Heartbeat:Wait()
        until loaded
    end

    signal:Fire(player)
end

local function onSystemsStarted()
    Players.PlayerAdded:Connect(waitForLoading)

    -- If players join before signal starts
    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(waitForLoading, player)
    end
end

LoadingNet:On("Complete", function(player)
    loaded = true;
end)

return {
    Signal = signal,
    SystemsStarted = onSystemsStarted
};