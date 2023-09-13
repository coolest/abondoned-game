local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ServerScriptService.Events
local SystemAdded = require(Events.SystemAdded)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local DamageService = {}

function DamageService.Init()
    DamageService._state = {
        healths = {};
    }
end

function DamageService.Start()
    SystemAdded.Signal:Connect(DamageService.onSystemAdded)
end

function DamageService.getHealths()
    return DamageService._state.healths
end

function DamageService.onSystemAdded(system)
    assert(SystemsHelper.verifySystem(system), debug.traceback(3) .. "\nProvided value was not verified to be a system!")

    local characterContainer = SystemsHelper.getCharactersInSystem(system)
    local submarine = SystemsHelper.getSubmarineInSystem(system)
    local healths = DamageService.getHealths()
    table.insert(healths, {
        750, submarine, unpack(characterContainer:GetChildren())
    })
end

function DamageService.getHealthTableFromCharacter(character)
    local healths = DamageService.getHealths()
    for _, healthTable in ipairs(healths) do
        if table.find(healthTable, character) then
            return healthTable
        end
    end
end

function DamageService.getHealthTableFromSubmarine(submarine)
    local healths = DamageService.getHealths()
    for _, healthTable in ipairs(healths) do
        if healthTable[2] == submarine then
            return healthTable
        end
    end
end

function DamageService.damageHealthTable(healthTable, value)
    healthTable[1] -= value;

    local health = healthTable[1]
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

function DamageService.damageCharacter(character, value)
    local healthTable = DamageService.getHealthTableFromCharacter(character)
    assert(healthTable, "Could not find health table - invalid character given.")
    assert(value and typeof(value) == "number", "Number provided needs to be a valid number")

    DamageService.damageHealthTable(healthTable, value)
end

function DamageService.damageSubmarine(submarine, value)
    local healthTable = DamageService.getHealthTableFromSubmarine(submarine)
    assert(healthTable, "Could not find health table - invalid submarine given.")
    assert(value and typeof(value) == "number", "Number provided needs to be a valid number")

    DamageService.damageHealthTable(healthTable, value)
end

return DamageService