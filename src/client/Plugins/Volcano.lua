local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Client = script.Parent.Parent
local ClientUtils = Client.Utils
local Emit = require(ClientUtils.emit)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Helpers = ReplicatedStorage.Helpers
local SpecialParts = require(Helpers.SpecialParts)

local Controllers = script.Parent.Parent.Controllers
local IndicatorController = require(Controllers.IndicatorController)

local Net = Red.Client("Volcano")

local assets = workspace.Assets
local lavaball = ReplicatedStorage._GAME_ITEMS.Lavaball
local explosion = ReplicatedStorage._GAME_ITEMS.VFX.Explosion

local lavaballs = {}
local volcanos = SpecialParts.getVolcanos()

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

    Emit(vfx, {
        position = primary.Position,
        bias = 25,
    })
end

local volcanoEmitTimestamp = os.clock();
RunService:BindToRenderStep("Volcano", Enum.RenderPriority.Last.Value, function(dt)
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

    local currTime = os.clock()
    local hasEnoughedTimeElapsed = currTime - volcanoEmitTimestamp > 1/4
    if not hasEnoughedTimeElapsed then
        return;
    end

    volcanoEmitTimestamp = currTime
    for _, volcano in ipairs(volcanos) do
        local attachment = volcano.Emit.Attachment
        Emit(attachment, {
            position = attachment.WorldPosition,
            bias = 100
        })
    end
end)

Net:On("Lavaball", spawnLavaBall)

return true;