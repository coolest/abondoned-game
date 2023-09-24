local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Services = ServerScriptService.Services
local RagdollService = require(Services.RagdollService)

local Packages = ReplicatedStorage.Packages
local GoodSignal = require(Packages.goodsignal)
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)
local getPlayersNearPosition = require(Utils.getPlayersNearPosition)

local signal = GoodSignal.new()

local Net = Red.Server("Death", {"OnReset", "DeathEffect"})
Net:On("OnReset", function(player)
    signal:Fire(player)
end)

local deadContainer = Instance.new("Folder")
deadContainer.Name = "__dead"
deadContainer.Parent = workspace

signal:Connect(function(obj)
    local isPlayer = obj.Parent == Players
    local character = isPlayer and obj.Character or obj
    assert(character and character:FindFirstChild("Humanoid"), "Please provide a valid character/player!")

    local system = SystemsHelper.getSystemFromCharacter(character)
    local player = Players:GetPlayerFromCharacter(character)
    RagdollService.ragdollOn(character)
    character.Parent = deadContainer
    character:SetAttribute("Dead", true)

    if system then
        local submarine = SystemsHelper.getSubmarineInSystem(system)
        if submarine then
            local chain = submarine:FindFirstChild(character.Name .. "-Chain")
            chain:Destroy()
        end

        local charactersContainer = SystemsHelper.getCharactersInSystem(system)
        local characters = charactersContainer:GetChildren()
        if #characters == 0 then
            system:Destroy()
        end
    end

    -- death effect
    task.wait(1/2)

    local rootPos = character and character.PrimaryPart and character.PrimaryPart.Position
    if rootPos then
        Net:FireList(getPlayersNearPosition(rootPos, 200), "DeathEffect", character)
    end

    task.wait(1.5)
    player:LoadCharacter()
end)

return {
    Signal = signal,
    SystemsStarted = function() end;
};