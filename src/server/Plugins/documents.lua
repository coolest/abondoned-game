local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ServerScriptService.Events
local PlayerAdded = require(Events.PlayerAdded).Signal

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local ServerPackages = ServerScriptService.Packages
local Lapis = require(ServerPackages.lapis)

local Utils = ReplicatedStorage.Utils
local patch = require(Utils.patch);

local Net = Red.Server("Data", { "getPlayerData" })

--

local documents = {}
local collection = Lapis.createCollection("PlayerData", {
	defaultData = {
        plays = 0;

		attempts = 0;
        completions = 0;

        coins = 0;
        uniqueComrades = 0;
	},

    validate = function()
        return true;
    end;
})

local function onPlayerAdded(player)
    local ok, document = collection:load(`Player{player.UserId}`):await()
    if not ok then
        return;
    end

    local data = document:read()

    print(`{player.Name} joined with {data.plays} plays`)

    document:write(
        patch(data, {
            plays = data.plays + 1;
        })
    );

    documents[player] = document
end

local function onPlayerRemoving(player)
	local document = documents[player]
    if not document then
        warn("Document does not exist for", player)

        return;
    end

    documents[player] = nil
    document:close():catch(warn)
end

local function getPlayerData(player)
    local document = documents[player]
    if not document then
        return
    end

    return document:read()
end

Net:On("getPlayerData", getPlayerData)

PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

return documents;