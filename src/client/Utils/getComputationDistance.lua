local UserInputService = game:GetService("UserInputService")
local GameSettings = UserSettings().GameSettings

local distances = {20, 35, 50, 50, 75, 75, 100, 150, 200, 250}

return function()
    local qualityLevel = GameSettings.SavedQualityLevel.Value

    local isAutomaticQuality = qualityLevel == 0
    if isAutomaticQuality then
        qualityLevel = 7

        local isMouseEnabled = UserInputService.MouseEnabled
        if isMouseEnabled then
            qualityLevel += 1
        end
    end

    return distances[qualityLevel]
end