local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Plugins = ServerScriptService.Plugins
local Documents = require(Plugins.Documents)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

return function (player)
    local obj = Documents[player]
    assert(obj, `Document does not exist for {player and player.Name or "--NULL-PLAYER"}!`)

    if obj.__type == "goodsignal" then
        obj:Wait()
    end

    return Documents[player]:read()
end