local SystemsHelper = {}

function SystemsHelper.getCharactersInSystem(system)
    return system:FindFirstChild("__characters")
end

function SystemsHelper.getSubmarineInSystem(system)
    return system:FindFirstChild("__submarine") and system:FindFirstChild("__submarine").PrimaryPart
end

function SystemsHelper.getHealthBarInSystem(system)
    return system:FindFirstChild("__health") and system.__health:FindFirstChild("Gui")
end

function SystemsHelper.verifySystem(system)
    return 
        SystemsHelper.getCharactersInSystem(system) and
        SystemsHelper.getSubmarineInSystem(system)
end

function SystemsHelper.getMaximumLengthAllowed(system)
    local characters = SystemsHelper.getCharactersInSystem(system)
    if not characters then
        return math.huge
    end

    return 15 + #(characters:GetChildren())
end

function SystemsHelper.getSystemFromCharacter(character)
    return character.Parent and character.Parent.Name == "__characters" and character.Parent.Parent
end

function SystemsHelper.getSystemFromSubmarine(submarine)
    local path1 = submarine.Name == "__submarine" and submarine.Parent
    local path2 = submarine.Parent.Name == "__submarine" and submarine.Parent.Parent
    assert(path1 or path2, "Did not provide a valid submarine object to pull from.")
    
    return path1 or path2
end

return SystemsHelper