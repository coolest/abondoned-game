local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Data")

local DocumentController = {}

function DocumentController.getDataCached()
    return DocumentController._state.data;
end
function DocumentController.getDataYields()
    return Net:Call("getPlayerData"):Catch(error):Await()
end

function DocumentController.Init()
    DocumentController._state = {
        updater = nil;
        data = nil;
    };
end

function DocumentController.Start()
    DocumentController._state.updater = Red.Clock.Clock(60, function()
        local prData = Net:Call("getPlayerData"):Catch(error)

        DocumentController._state.data = prData:Await()
    end)
end

return DocumentController