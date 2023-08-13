local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterAdded = require(ReplicatedStorage.Events.CharacterAdded)

local CollisionService = {}

function CollisionService.Init()
    PhysicsService:RegisterCollisionGroup("Characters")
    PhysicsService:RegisterCollisionGroup("Chains")

    PhysicsService:CollisionGroupSetCollidable("Characters", "Chains", false)
    PhysicsService:CollisionGroupSetCollidable("Chains", "Chains", false)

    local addToCharactersCG = CollisionService.addToCollisionGroup("Characters")
    CharacterAdded.Signal:Connect(addToCharactersCG)

    local addToChainsCG = CollisionService.addToCollisionGroup("Chains")
    addToChainsCG(ReplicatedStorage._GAME_ITEMS.Chain)
end

function CollisionService.Start()

end

function CollisionService.addToCollisionGroup(collisionGroup)
    return function(object)
        if object:IsA("BasePart") or object:IsA("UnionOperation") then
            object.CollisionGroup = collisionGroup
        elseif object:IsA("Model") or object:IsA("Folder") then
            for _, child in ipairs(object:GetDescendants()) do
                local isValid = child:IsA("BasePart") or child:IsA("UnionOperation")
                if isValid then
                    child.CollisionGroup = collisionGroup
                end
            end
        end
    end
end

return CollisionService