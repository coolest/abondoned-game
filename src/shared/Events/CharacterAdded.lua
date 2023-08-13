local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(Packages.goodsignal)
local Red = require(Packages.red)

local loaded = true;
local signal = GoodSignal.new()

if IS_SERVER then
    loaded = false;

    local LoadingNet = Red.Server("Load", {"Complete"})

    LoadingNet:On("Complete", function(player)
        loaded = true;
    end)
end


local function waitForLoading(character)
    if not loaded then
        repeat
            RunService.Heartbeat:Wait()
        until loaded
    end
    
    signal:Fire(character)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(waitForLoading)
end

local function onSystemsStarted()
    Players.PlayerAdded:Connect(onPlayerAdded)

    -- If players join before signal starts
    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
end

return {
    Signal = signal,
    SystemsStarted = onSystemsStarted
};