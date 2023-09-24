local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local Flipper = require(Packages.flipper)

local Helpers = ReplicatedStorage.Helpers
local SystemHelper = require(Helpers.SystemsHelper)

local Net = Red.Client("Death")

local identity = function(v) return v end;

local function tweenProperty(objs, property, constructor, opts)
    opts = opts or {frequency = 2/3, dampingRatio = 1.25}

    local motor = Flipper.SingleMotor.new(0)
    motor:onStep(function(alpha)
        for _, obj in ipairs(objs) do
            obj[property] = math.max(obj[property], constructor(alpha))
        end
    end)

    motor:setGoal(Flipper.Spring.new(1, opts))
    motor:start()
end

local function removeSystemEffect(system)
    local healthGui = SystemHelper.getHealthBarInSystem(system)
    local submarine = SystemHelper.getSubmarineInSystem(system)
    if not (submarine and healthGui) then
        return;
    end

    local healthContainer = healthGui.Parent
    local submarineContainer = submarine.Parent

    local objsNumber = {}
    local objsNumberSeq = {}

    for _, submarineComponent in ipairs(submarineContainer:GetDescendants()) do
        local isValidNumber = 
            submarineComponent:IsA("BasePart") or submarineComponent:IsA("UnionOperation") or submarineComponent:IsA("Decal") or submarineComponent:IsA("Texture")
        local isValidNumberSeq =
            submarineComponent:IsA("Beam")

        if isValidNumber then
            table.insert(objsNumber, submarineComponent)
        elseif isValidNumberSeq then
            table.insert(objsNumberSeq, submarineComponent)
        end
    end

    healthContainer.Transparency = 1;
    local objsBackground = {}
    local objsText = {}
    for _, healthGuiComponent in ipairs(healthContainer:GetDescendants()) do
        local isValidBackground =
            healthGuiComponent:IsA("Frame")
        local isValidText =
            healthGuiComponent:IsA("TextLabel")
        local isValidNumber =
            healthGuiComponent:IsA("UIStroke")

        if isValidBackground then
            table.insert(objsBackground, healthGuiComponent)
        elseif isValidText then
            table.insert(objsText, healthGuiComponent)
        elseif isValidNumber then
            table.insert(objsNumber, healthGuiComponent)
        end
    end

    tweenProperty(objsText, "TextTransparency", identity)
    tweenProperty(objsNumber, "Transparency", identity)
    tweenProperty(objsNumberSeq, "Transparency", function(v) return NumberSequence.new(v) end)
    tweenProperty(objsBackground, "BackgroundTransparency", identity, {frequency = 2, dampingRatio = 1.25})
end

local function deathEffect(character)
    local objs = {}

    for _, v in ipairs(character:GetDescendants()) do
        local isValidPart = v:IsA("BasePart") or v:IsA("UnionOperation")
        local isValidImage = v:IsA("Decal") or v:IsA("Texture")
        if not (isValidPart or isValidImage) then
            continue
        end

        table.insert(objs, v)
    end

    tweenProperty(objs, "Transparency", identity)
end

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
    Net:Fire("OnReset")
end)

StarterGui:SetCore("ResetButtonCallback", resetBindable)
Net:On("DeathEffect", deathEffect)
Net:On("RemoveSystemEffect", removeSystemEffect)

return true;