local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local GoodSignal = require(Packages.goodsignal)

local REMOVE_TIME = 1/2

local KnockbackService = {}

local function getRootPartFromObject(obj)
    local objType = typeof(obj)
    assert(objType == "Instance", debug.traceback(3) .. "Object provided needs to be a roblox instance")

    if obj:IsA("BasePart") or obj:IsA("UnionOperation") then
        return obj
    elseif obj:IsA("Model") and obj.PrimaryPart then
        return obj.PrimaryPart
    else
        error(debug.traceback(3) .. "Could not find root-part from given object!")
    end
end

function KnockbackService.Init()
    KnockbackService._state = {
        initialStates = {}
    }

    RunService.PostSimulation:Connect(function()
        local initialStates = KnockbackService.getKnockbackInitialStates()
        for i = #initialStates, 1, -1 do
            local initialState = initialStates[i]
            local root = initialState[1]
            local force = initialState[2]
            local timestamp = initialState[3]
            local signal = initialState[4]

            local hasStopped = root.AssemblyLinearVelocity.Magnitude * 25 < force.Magnitude
            local justStarted = os.clock()-timestamp < REMOVE_TIME
            if not justStarted and hasStopped then
                signal:Fire()

                table.remove(initialStates, i)
            end
        end
    end)
end

function KnockbackService.Start()

end

function KnockbackService.getKnockbackInitialStates()
    return KnockbackService._state.initialStates
end

function KnockbackService.addKnockbackInitialState(root, force)
    assert(root and root:IsA("BasePart"), "Did not provide a valid root-part.")

    local initialStates = KnockbackService.getKnockbackInitialStates()
    table.insert(initialStates, {root, force, os.clock(), GoodSignal.new()})
end

function KnockbackService.knockback(obj, force)
    local root = getRootPartFromObject(obj)
    KnockbackService.addKnockbackInitialState(root, force)

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = force
    bodyVelocity.Parent = root

    Red.Spawn(function()
        task.wait(REMOVE_TIME)

        bodyVelocity:Destroy()
    end)
end

function KnockbackService.getSignalForKnockbackComplete(obj)
    local root = getRootPartFromObject(obj)
    local initialStates = KnockbackService.getKnockbackInitialStates()
    for _, initialState in ipairs(initialStates) do
        local initialStateRoot = initialState[1]
        local signal = initialState[4]

        if initialStateRoot == root then
            return signal;
        end
    end
end

return KnockbackService