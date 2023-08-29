local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local assets = workspace.Assets
local indicatorContainer = Instance.new("Folder")
indicatorContainer.Name = "__indicators"
indicatorContainer.Parent = assets

local IndicatorController = {}

function IndicatorController.Init()
    IndicatorController._state = {
        hazardIndicatorBorders = {};
        hazardCountdownLabels = {};
    }
end

function IndicatorController.Start()
    RunService:BindToRenderStep("HazardIndicatorHandler", Enum.RenderPriority.Last.Value, function(dt)
        local currentTime = os.clock()

        local borders = IndicatorController.getHazardIndicatorBorders()
        for i = #borders, 1, -1 do
            local border = borders[i]
            if not border then
                table.remove(borders, i)
            end

            border.Rotation += dt * 275
        end

        local countdowns = IndicatorController.getHazardCountdownLabel()
        for i = #countdowns, 1, -1 do
            local countdownWrapper = countdowns[i]
            if not countdownWrapper then
                table.remove(countdowns, i)
            end

            local countdown = countdownWrapper.label
            local startTime = countdownWrapper.start
            local delta = 3-math.floor(currentTime-startTime)

            countdown.Text = tostring(delta)
        end
    end)
end

function IndicatorController.getHazardIndicatorBorders()
    return IndicatorController._state.hazardIndicatorBorders
end

function IndicatorController.getHazardCountdownLabel()
    return IndicatorController._state.hazardCountdownLabels
end

function IndicatorController.addToHazardIndicatorBorders(obj)
    assert(obj and obj:IsA("ImageLabel"), "Border needs to be a valid ImageLabel")

    table.insert(IndicatorController._state.hazardIndicatorBorders, obj)
end

function IndicatorController.addToHazardCountdownLabels(obj)
    assert(obj and typeof(obj) == "table" and obj.label:IsA("TextLabel") and typeof(obj.start) == "number", "Object provided needs to be a valid table with keys {label} consisting of a valid TextLabel and {start} consisting of a valid Number")

    table.insert(IndicatorController._state.hazardCountdownLabels, obj)
end

function IndicatorController.newHazardIndicator()
    return ReplicatedStorage._GAME_ITEMS.HazardIndicator:Clone()
end

function IndicatorController.createHazardIndicator(pos)
    local indicator = IndicatorController.newHazardIndicator()
    indicator.Position = pos
    indicator.Parent = indicatorContainer

    local gui = indicator:FindFirstChild("Gui")
    local countdownLabel = gui and gui:FindFirstChild("Countdown")
    local border = gui and gui:FindFirstChild("Border")
    if not (countdownLabel and border) then
        indicator:Destroy()

        return;
    end

    countdownLabel.TextTransparency = 1
    countdownLabel.TextColor3 = Color3.new(1, 0.290196, 0.290196)
    border.ImageTransparency = 1;
    border.ImageColor3 = Color3.new(1, 0.290196, 0.290196)

    TweenService:Create(border, TweenInfo.new(1/4), {ImageTransparency = 0}):Play()
    TweenService:Create(countdownLabel, TweenInfo.new(1/4), {TextTransparency = 0}):Play()

    TweenService:Create(border, TweenInfo.new(3), {ImageColor3 = Color3.new(1, 0, 0)}):Play()
    TweenService:Create(countdownLabel, TweenInfo.new(3), {TextColor3 = Color3.new(1, 0, 0)}):Play()

    IndicatorController.addToHazardIndicatorBorders(border)
    IndicatorController.addToHazardCountdownLabels({
        label = countdownLabel;
        start = os.clock();
    })

    task.delay(3.25, function()
        TweenService:Create(border, TweenInfo.new(1/4), {ImageTransparency = 1}):Play()
        TweenService:Create(countdownLabel, TweenInfo.new(1/4), {TextTransparency = 1}):Play()

        task.wait(1/4)

        indicator:Destroy()
    end)
end

return IndicatorController