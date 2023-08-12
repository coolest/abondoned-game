local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(Packages.goodsignal)
local Red = require(Packages.red)

local LoadingNet = Red.Server("Load", {"Complete"})

local signal = GoodSignal.new()
local loadings = {}

local function waitForLoading(player)
    repeat RunService.Heartbeat:Wait()
    until loadings[player.Name]

    loadings[player.Name] = nil;
    
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
    loadings[player.Name] = true;
end)

return {
    Signal = signal,
    SystemsStarted = onSystemsStarted
};