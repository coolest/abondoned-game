local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MOVEMENT_SPEED = Vector2.new(5, 5)

local texture = ReplicatedStorage._GAME_ITEMS._reflection
local map = workspace

local reflections = {};
for _, v in ipairs(map:GetChildren()) do
    local isValid = v:IsA("BasePart") or v:IsA("UnionOperation")
    if not isValid then
        continue
    end

    if v.Material == Enum.Material.Sand then
        local reflection = texture:Clone()
        reflection.Parent = v

        table.insert(reflections, reflection)
    end
end

RunService:BindToRenderStep("Reflections", Enum.RenderPriority.Last.Value, function(dt)
    for _, reflection in ipairs(reflections) do
        reflection.OffsetStudsU += MOVEMENT_SPEED.X * dt
        reflection.OffsetStudsV += MOVEMENT_SPEED.Y * dt
    end
end)

return true;