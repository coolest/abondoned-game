local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ServerScriptService.Events
local PlayerAdded = require(Events.PlayerAdded)

local DamageService = {}

function DamageService.Init()
    DamageService._state = {
        healths = {};
    }
end

function DamageService.Start()
    PlayerAdded.Signal:Connect(DamageService.onPlayerAdded)
    Players.PlayerRemoving:Connect(DamageService.onPlayerRemoving)
end

function DamageService.getHealths()
    return DamageService._state.healths
end

function DamageService.registerCharacter(character)
    local healths = DamageService.getHealths()
    local key = character.Name

    healths[key] = 100;
end

function DamageService.removePlayerOrCharacter(plrOrCharacter)
    local healths = DamageService.getHealths()
    local key = plrOrCharacter.Name

    healths[key] = nil;
end

function DamageService.onPlayerAdded(player)
    player.CharacterAdded:Connect(DamageService.registerCharacter)
end

function DamageService.onPlayerRemoving(player)
    DamageService.removePlayerOrCharacter(player)
end

function DamageService.damageCharacter(character, value)
    assert(character and typeof(character) == "Instance" and character:IsA("Model"), "Need to provide a valid character.")
    assert(value and typeof(value) == "number", "Number provided needs to be a valid number")

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local healths = DamageService.getHealths()
    local key = character.Name

    healths[key] -= value

    local newHealth = healths[key]
    humanoid.Health = newHealth
end

return DamageService