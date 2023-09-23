local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local Flipper = require(Packages.flipper)

local Net = Red.Client("Death")

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

    local motor = Flipper.SingleMotor.new(0)
    motor:onStep(function(alpha)
        for _, obj in ipairs(objs) do
            obj.Transparency = math.max(obj.Transparency, alpha)
        end
    end)

    motor:setGoal(Flipper.Spring.new(1, {frequency = 2/3, dampingRatio = 1.25}))
    motor:start()
end

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
    Net:Fire("OnReset")
end)

StarterGui:SetCore("ResetButtonCallback", resetBindable)
Net:On("DeathEffect", deathEffect)

return true;