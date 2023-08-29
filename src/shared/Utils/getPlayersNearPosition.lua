local Players = game:GetService("Players")

return function(pos, distance)
    assert(pos and typeof(pos) == "Vector3", "Position needs to be a Vector3")

    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local root = character and character.PrimaryPart
        if not root then
            continue
        end

        local isInRange = (root.Position - pos).Magnitude < distance
        if isInRange then
            table.insert(players, player)
        end
    end

    return players
end