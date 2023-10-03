
local healthPads  = {}
local checkpoints = {}
local volcanos = {}

local specialParts = workspace.Special:GetChildren()
for _, part in ipairs(specialParts) do
    local isCheckpoint = part:GetAttribute("Checkpoint")
    if isCheckpoint then
        table.insert(checkpoints, part)
    end

    local isHealth = part:GetAttribute("Health")
    if isHealth then
        table.insert(healthPads, part)
    end

    local isVolcano = part.Name == "Volcano"
    if isVolcano then
        table.insert(volcanos, part)
    end
end

--// Interface

local SpecialParts = {}

function SpecialParts.getHealthPads()
    return healthPads
end

function SpecialParts.getCheckpoints()
    return checkpoints
end

function SpecialParts.getVolcanos()
    return volcanos
end

return SpecialParts