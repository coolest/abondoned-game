local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Client("Volcano")

local assets = workspace.Assets
local lavaball = ReplicatedStorage._GAME_ITEMS.Lavaball

local lavaballs = {}

local function spawnLavaBall(info)
    local arc = info.arc
    local startPos = info.startPos
    local endPos = info.endPos

    local model = lavaball:Clone()
    model.Position = startPos
    model.Parent = assets

    local alpha = 0;
    local positionHandler = function(dt)
        alpha = math.clamp(alpha+dt/3.25, 0, 1)
        
        local pos = startPos*(1-alpha) + endPos*alpha
        local yPosDelta = math.clamp(arc * math.cos((alpha*0.69)*1.5*math.pi + 1.5*math.pi), 0, math.huge)
        model.Position = pos + Vector3.new(0, yPosDelta, 0)

        return alpha == 1
    end

    -- do danger circle

    table.insert(lavaballs, {
        model = model;
        handler = positionHandler;
    })
end

RunService:BindToRenderStep("Lavaballs", Enum.RenderPriority.Last.Value, function(dt)
    for i = #lavaballs, 1, -1 do
        local lavaballWrapper = lavaballs[i]
        local updateHandler = lavaballWrapper.handler
        local isFinished = updateHandler(dt)
        if isFinished then
            table.remove(lavaballs, i)

            local model = lavaballWrapper.model
            task.delay(1, model.Destroy, model)
        end
    end
end)

Net:On("Lavaball", spawnLavaBall)

return true;