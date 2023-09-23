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

local signal = GoodSignal.new()

local Net = Red.Server("Reset", "OnReset")
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

    RagdollService.ragdollOn(character)
    character.Parent = deadContainer
    character:SetAttribute("Dead", true)

    local system = SystemsHelper.getSystemFromCharacter(character)
    if not system then
        return;
    end

    local chains = character:FindFirstChild("__chains")
    if chains then
        chains:Destroy()
    end

    local charactersContainer = SystemsHelper.getCharactersInSystem(system)
    local characters = charactersContainer:GetChildren()
    if #characters == 0 then
        -- clean up system
        --system:Destroy()
    end
end)

return {
    Signal = signal,
    SystemsStarted = function() end;
};