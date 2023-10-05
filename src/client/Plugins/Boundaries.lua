local Players = game:GetService("Players")

local boundaries = workspace.Boundaries:GetDescendants()
for i = #boundaries, 1, -1 do
    local isValid = boundaries[i]:IsA("BasePart")
    if not isValid then
        table.remove(boundaries, i)
    end
end

local player = Players.LocalPlayer

local function changeBoundaryTransparency(value)
    for _, boundary in ipairs(boundaries) do
        boundary.Transparency = value
    end
end

local function onCharacterAdded(character)
    --[[
        if checkpoint >= 2 then show gui saying they need to get in a system
    ]]
    changeBoundaryTransparency(0.5)

    character:GetAttributeChangedSignal("system"):Wait()

    changeBoundaryTransparency(1)
end

--
local currCharacter = player.Character
if currCharacter then
    task.spawn(onCharacterAdded, currCharacter)
end

player.CharacterAdded:Connect(onCharacterAdded)

return true;