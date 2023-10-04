local PhysicsService = game:GetService("PhysicsService")

local CollisionService = {}

function CollisionService.Init()
    PhysicsService:RegisterCollisionGroup("Characters")
    PhysicsService:RegisterCollisionGroup("Ragdoll")
    PhysicsService:RegisterCollisionGroup("Submarine")
    PhysicsService:RegisterCollisionGroup("Boundary")

    PhysicsService:CollisionGroupSetCollidable("Characters", "Characters", false)
    PhysicsService:CollisionGroupSetCollidable("Boundary", "Characters", false)
    PhysicsService:CollisionGroupSetCollidable("Boundary", "Submarine", false)
    PhysicsService:CollisionGroupSetCollidable("Characters", "Ragdoll", false)
    PhysicsService:CollisionGroupSetCollidable("Submarine", "Ragdoll", false)
end

function CollisionService.Start()
    local addToBoundaryCG = CollisionService.addToCollisionGroup("Boundary")

    local boundaries = workspace.Boundaries
    addToBoundaryCG(boundaries)
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