local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Plugins = ServerScriptService.Plugins
local Documents = require(Plugins.Documents)

local Utils = ReplicatedStorage.Utils
local getCharacterFromPart = require(Utils.getCharacterFromPart)
local patch = require(Utils.patch)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local checkpoints = {}

local function createCheckpointTriggerHandler(checkpoint)
    local checkpointNum = checkpoint:GetAttribute("Checkpoint")

    return function (part)
        local triggerChar = getCharacterFromPart(part)
        if not triggerChar then
            return;
        end

        local system = SystemsHelper.getSystemFromCharacter(triggerChar)
        if not system then
            return;
        end

        local characters = SystemsHelper.getCharactersInSystem(system)
        for _, character in ipairs(characters) do
            local player = Players:GetPlayerFromCharacter(character)
            if not player then
                continue
            end

            local playerDocument = Documents[player]
            local ok, result = pcall(function()
                return playerDocument:read() -- maybe failed to fetch data, so this may not exist
            end)

            if ok then
                local data = result
                playerDocument:write(
                    patch(data, {
                        checkpoint = math.max(data.checkpoint, checkpointNum)
                    }
                ))
            end
        end
    end
end

for _, checkpoint in ipairs(checkpoints) do
    local checkpointTriggeredHandler = createCheckpointTriggerHandler(checkpoint)

    checkpoint.Touched:Connect(checkpointTriggeredHandler)
end

return true;