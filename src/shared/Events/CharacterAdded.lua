local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(Packages.goodsignal)

local loaded = false;
local signal = GoodSignal.new()

local loadedSignal = IS_SERVER
    and ReplicatedStorage:FindFirstChild("SERVER_LOADED")
    or  ReplicatedStorage:FindFirstChild("CLIENT_LOADED")

loadedSignal.Event:Connect(function()
    loaded = true;
end)

local function waitForLoading(character)
    if not loaded then
        repeat
            RunService.PostSimulation:Wait()
        until loaded
    end
    
    signal:Fire(character)
end

local function onPlayerAdded(player)
    local character = player.Character
    if character then
        task.spawn(waitForLoading, character)
    end

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