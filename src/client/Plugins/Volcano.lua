local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local Emit = require(Utils.emit)

local Controllers = script.Parent.Parent.Controllers
local IndicatorController = require(Controllers.IndicatorController)

local Net = Red.Client("Volcano")

local assets = workspace.Assets
local lavaball = ReplicatedStorage._GAME_ITEMS.Lavaball
local explosion = ReplicatedStorage._GAME_ITEMS.VFX.Explosion

local lavaballs = {}

local function spawnLavaBall(info)
    local arc = info.arc
    local startPos = info.startPos
    local endPos = info.endPos

    IndicatorController.createHazardIndicator(endPos)
    
    task.wait(1)

    local model = lavaball:Clone()
    model:PivotTo(CFrame.new(startPos))
    model.Parent = assets

    local speedUp = -1/10;
    local alpha = 0;
    local positionHandler = function(dt)
        speedUp += dt/11

        local boost = math.clamp(speedUp*speedUp, 0, 1/30)
        alpha = math.clamp(boost+alpha+dt/3.25, 0, 1)
        
        local pos = startPos*(1-alpha) + endPos*alpha
        local yPosDelta = math.clamp(arc * math.cos((alpha*0.675)*1.5*math.pi + 1.5*math.pi), 0, math.huge)
        model:PivotTo(CFrame.new(pos + Vector3.new(0, yPosDelta, 0)))

        return alpha == 1
    end

    table.insert(lavaballs, {
        model = model;
        handler = positionHandler;
    })
end

local function createExplosion(ball)
    local primary = ball.PrimaryPart
    local vfx = explosion:Clone()
    vfx.Position = primary.Position
    vfx.Parent = assets

    ball:Destroy()

    Emit(vfx)
end

RunService:BindToRenderStep("Lavaballs", Enum.RenderPriority.Last.Value, function(dt)
    for i = #lavaballs, 1, -1 do
        local lavaballWrapper = lavaballs[i]
        local updateHandler = lavaballWrapper.handler
        local isFinished = updateHandler(dt)
        if isFinished then
            table.remove(lavaballs, i)

            local model = lavaballWrapper.model
            task.spawn(createExplosion, model)
        end
    end
end)

Net:On("Lavaball", spawnLavaBall)

return true;