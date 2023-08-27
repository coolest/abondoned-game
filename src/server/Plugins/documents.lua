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

local defaultData = {
    plays = 0;

    checkpoint = 1;
}

local documents = {}
local collection = Lapis.createCollection("PlayerData", {
	defaultData = defaultData,

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

    for k, v in pairs(defaultData) do
        if not data[k] then
            document:write(
                patch(data, {
                    [k] = v
                })
            )
        end
    end

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