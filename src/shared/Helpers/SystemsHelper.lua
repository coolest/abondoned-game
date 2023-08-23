local SystemsHelper = {}

function SystemsHelper.getCharactersInSystem(system)
    return system:FindFirstChild("__characters")
end

function SystemsHelper.getSubmarineInSystem(system)
    return system:FindFirstChild("__submarine")
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
    return character.Parent.Name == "__characters" and character.Parent.Parent
end

return SystemsHelper