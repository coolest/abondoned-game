local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Flipper = require(Packages.flipper)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local TweenController = {}

function TweenController.Init()
    TweenController._state = {
        activeTweens = {};
    }
end

function TweenController.Start()
    
end

function TweenController.getActiveTweens()
    return TweenController._state.activeTweens
end

function TweenController.formatGui(gui)
    local tweenInfo = {values = {}, metadata = {gui = gui; type = "TweenInfo"}}

    local guiObjects = gui:GetDescendants()
    table.insert(guiObjects, gui)

    for _, guiObj in ipairs(guiObjects) do
        local ignore = guiObj:GetAttribute("ignore")
        if ignore then
            continue
        end

        local isText = guiObj:IsA("TextLabel")
        if isText then
            tweenInfo.values[guiObj] = "TextTransparency"
        end
    
        local isBg = guiObj:IsA("Frame")
        if isBg then
            tweenInfo.values[guiObj] = "BackgroundTransparency"
        end

        local isImg = guiObj:IsA("ImageButton")
        if isImg then
            tweenInfo.values[guiObj] = "ImageTransparency"
        end
    
        local isReg = guiObj:IsA("UIStroke")
        if isReg then
            tweenInfo.values[guiObj] = "Transparency"
        end

        local override = guiObj:GetAttribute("override")
        if override then
            tweenInfo.values[guiObj] = override
        end
    end

    return tweenInfo
end

function TweenController._tween(tweenIn, tweenInfo, opts)
    local metadata = tweenInfo.metadata
    local gui = metadata.gui

    local activeTweens = TweenController.getActiveTweens()
    local tweenMotor = activeTweens[gui]

    local initialValue = tweenIn and 1 or 0
    local finalValue = 1-initialValue
    if tweenMotor then
        initialValue = tweenMotor:getValue()

        tweenMotor:stop()
    end

    local motor = Flipper.SingleMotor.new(initialValue)
    activeTweens[gui] = motor

    motor:onStep(function(val)
        for v, p in pairs(tweenInfo.values) do
            v[p] = val
        end
    end)

    motor:onStart(function()
        task.wait();

        gui.Visible = true;
    end)

    motor:onComplete(function()
        gui.Visible = tweenIn

        activeTweens[gui] = nil;
    end)

    motor:setGoal(Flipper.Spring.new(finalValue, opts or {frequency = 4}))
    motor:start()
end

function TweenController.tweenIn(tweenInfo, opts)
    assert(type(tweenInfo) == "table" and tweenInfo.metadata and tweenInfo.metadata.type == "TweenInfo", `Need to provide valid TweenInfo, provided {tweenInfo}`)

    TweenController._tween(
        true,
        tweenInfo,
        opts
    )
end

function TweenController.tweenOut(tweenInfo, opts)
    assert(type(tweenInfo) == "table" and tweenInfo.metadata and tweenInfo.metadata.type == "TweenInfo", `Need to provide valid TweenInfo, provided {tweenInfo}`)

    TweenController._tween(
        false,
        tweenInfo,
        opts
    )
end

return TweenController