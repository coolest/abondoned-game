local ServerScriptService = game:GetService("ServerScriptService")

local Plugins = ServerScriptService.Plugins
local Documents = require(Plugins.Documents)

local Events = ServerScriptService.Events
local PlayerAdded = require(Events.PlayerAdded)

local CheckpointService = {}

function CheckpointService.Init()
    PlayerAdded.Signal:Connect(function(...)
        task.defer(CheckpointService.onPlayerAdded, ...)
    end)
end

function CheckpointService.Start()

end

function CheckpointService.onPlayerAdded(plr)
    local obj = Documents[plr]
    if obj.__type == "goodsignal" then
        obj:Wait()
    end

    local document = Documents[plr]
end

return CheckpointService