local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Events = ServerScriptService.Events
local SystemAdded = require(Events.SystemAdded)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Utils = ReplicatedStorage.Utils
local getPlayersNearPosition = require(Utils.getPlayersNearPosition)
local getCharacterFromPart = require(Utils.getCharacterFromPart)
local assert = require(Utils.assert)

local Net = Red.Server("Damage", {"UpdateHealthBar", "RequestAll"})

local HealthService = {}

function HealthService.Init()
    HealthService._state = {
        healths = {};
    }
end

function HealthService.Start()
    SystemAdded.Signal:Connect(HealthService.onSystemAdded)

    Net:On("RequestAll", function()
        local healthTables = HealthService.getHealths()
        local packet = {}
        for _, healthTable in ipairs(healthTables) do
            table.insert(packet, {
                healthTable[1], healthTable[2], healthTable[3]
            });
        end

        return packet
    end)

    local function onPartTouchedHealthPad(part)
        local character = getCharacterFromPart(part)
        if not character then
            return;
        end

        HealthService.fullHealSystemFromCharacter(character)
    end

    local healthPads = {}
    for _, healthPad in ipairs(healthPads) do
        healthPad.Touched:Connect(onPartTouchedHealthPad)
    end
end

function HealthService.getHealths()
    return HealthService._state.healths
end

function HealthService.onSystemAdded(system)
    assert(SystemsHelper.verifySystem(system), debug.traceback(3) .. "\nProvided value was not verified to be a system!")

    local characterContainer = SystemsHelper.getCharactersInSystem(system)
    local submarine = SystemsHelper.getSubmarineInSystem(system)
    local healths = HealthService.getHealths()
    table.insert(healths, {
        750, 750, submarine, unpack(characterContainer:GetChildren())
    })
end

function HealthService.getHealthTableFromCharacter(character)
    local healths = HealthService.getHealths()
    for _, healthTable in ipairs(healths) do
        if table.find(healthTable, character) then
            return healthTable
        end
    end
end

function HealthService.getHealthTableFromSubmarine(submarine)
    local healths = HealthService.getHealths()
    for _, healthTable in ipairs(healths) do
        if healthTable[3] == submarine then
            return healthTable
        end
    end
end

function HealthService.changeHealth(healthTable, inc)
    healthTable[1] += inc;

    local health = healthTable[1]
    local maxHealth = healthTable[2]
    local sub = healthTable[3]
    local system = SystemsHelper.getSystemFromSubmarine(sub)
    local healthBarGui = SystemsHelper.getHealthBarInSystem(system)
    Net:FireList(getPlayersNearPosition(sub.Position, 200), "UpdateHealthBar", healthBarGui, maxHealth, health, inc)

    local isAlive = health > 0
    if isAlive then
        return;
    end
    
    for i = 3, #healthTable do
        local character = healthTable[i]
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0;
        end
    end
end

function HealthService.damageSystemFromCharacter(character, value)
    local healthTable = HealthService.getHealthTableFromCharacter(character)
    assert(healthTable, "Could not find health table - invalid character given.")
    assert(value and typeof(value) == "number", "Number provided needs to be a valid number")

    HealthService.changeHealth(healthTable, -value)
end

function HealthService.damageSystemFromSubmarine(submarine, value)
    local healthTable = HealthService.getHealthTableFromSubmarine(submarine)
    assert(healthTable, "Could not find health table - invalid submarine given.")
    assert(value and typeof(value) == "number", "Number provided needs to be a valid number")

    HealthService.changeHealth(healthTable, -value)
end

function HealthService.damageSystem(system, value)
    assert(SystemsHelper.verifySystem(system), "Did not provide a valid system.")

    local submarine = SystemsHelper.getSubmarineInSystem(system)
    HealthService.damageSystemFromSubmarine(submarine, value)
end

function HealthService.fullHealSystemFromCharacter(character)
    local healthTable = HealthService.getHealthTableFromCharacter(character)
    assert(healthTable, "Could not find health table - invalid character given.")

    HealthService.changeHealth(healthTable, healthTable[2]-healthTable[1])
end

return HealthService