local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Flipper = require(Packages.flipper)
local Red = require(Packages.red)

local Helpers = ReplicatedStorage.Helpers
local SystemHelper = require(Helpers.SystemsHelper)

local Net = Red.Client("Damage")

local targets = {}

Net:On("UpdateHealthBar", function(healthBarGui, maxHealth, health, change)
    local healthBar = healthBarGui:FindFirstChild("HealthBar", true)
    local healthLabel = healthBarGui:FindFirstChild("HealthAmount", true)
    local newSize = health/maxHealth

    local hasTarget = targets[healthBar] ~= nil
    if hasTarget then
        targets[healthBar] = UDim2.new(newSize, 0, 1, 0);

        return;
    end

    local oldHealth = health+change 
    local initialSize = healthBar.Size
    targets[healthBar] = UDim2.new(newSize, 0, 1, 0);

    local motor = Flipper.SingleMotor.new(0)
    motor:onStep(function(alpha)
        healthBar.Size = initialSize:Lerp(targets[healthBar], alpha)

        local newDisplayHealth = math.floor(oldHealth*(1-alpha) + health*alpha)
        healthLabel.Text = tostring(newDisplayHealth) .. "/" .. tostring(maxHealth)
    end)

    motor:setGoal(Flipper.Spring.new(1, {frequency = 2}))
    motor:start()

    motor:onComplete(function()
        targets[healthBar] = nil;
    end)
end)

-- For making client have correct information displayed for health bars upon join
local function handleServerInfo(serverInfo)
    for _, healthInfo in ipairs(serverInfo) do
        local currentHealth = healthInfo[1]
        local maxHealth = healthInfo[2]
        local submarine = healthInfo[3]
        if not submarine then
            continue
        end
        
        local system = SystemHelper.getSystemFromSubmarine(submarine)
        local healthBarGui = SystemHelper.getHealthBarInSystem(system)
    
        local healthBar = healthBarGui:FindFirstChild("HealthBar", true)
        local healthLabel = healthBarGui:FindFirstChild("HealthAmount", true)
    
        healthBar.Size = UDim2.new(currentHealth/maxHealth, 0, 1, 0)
        healthLabel.Text = tostring(currentHealth) .. "/" .. tostring(maxHealth)
    end
end

Net:Call("RequestAll"):Then(handleServerInfo, function(err)
    warn("Existing HealthBars will be out of sync with server -- could not fetch: ", err)
end)

return true;