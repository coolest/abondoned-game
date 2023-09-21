local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local RagdollService;

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)
local GoodSignal = require(Packages.goodsignal)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local FALLING_VALUE_UNTIL_RAGDOLL = -125;
local MIN_FALL_TIME = 1/2;
local REMOVE_TIME = 1/2

local MovementService = {}

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

function MovementService.Init()
    RagdollService = require(Services.RagdollService)
    
    MovementService._state = {
        initialStatesKnockback = {};
        initialStatesFalling = {};
    }

    RunService.PostSimulation:Connect(function()

        --// Mark Falling
        local players = Players:GetPlayers()
        local characters = {}
        for _, player in ipairs(players) do
            local character = player.Character
            if character and SystemsHelper.getSystemFromCharacter(character) then
                table.insert(characters, character)
            end
        end

        for _, character in ipairs(characters) do
            local isRagdolled = character:GetAttribute("Ragdoll")
            if isRagdolled then
                continue
            end
            
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then
                continue
            end

            local fallingValue = root.AssemblyLinearVelocity.Y
            local isFalling = fallingValue < FALLING_VALUE_UNTIL_RAGDOLL
            local fallingStart = character:GetAttribute("fall")
            if isFalling and not fallingStart then
                character:SetAttribute("fall", os.clock())
            elseif isFalling then
                local fallingTime = os.clock() - fallingStart
                if fallingTime < 1/3 then
                    continue
                end
                
                --[[
                local system = SystemsHelper.getSystemFromCharacter(character)
                local submarine = system and SystemsHelper.getSubmarineInSystem(system)
                if submarine then
                    local look = CFrame.lookAt(root.Position, submarine.Position).LookVector
            
                    root.AssemblyLinearVelocity -= look * 100
                end
                ]]

                RagdollService.ragdollOn(character)
                MovementService.addFallingInitialState(character)

                local fallingComplete = MovementService.getSignalForFallingComplete(character)
                fallingComplete:Connect(function()
                    task.wait(1/2)

                    RagdollService.ragdollOff(character)
                end)
            end
        end

        --// Knockback
        local initialStates = MovementService.getKnockbackInitialStates()
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

        --// Falling End
        initialStates = MovementService.getFallingInitialStates()
        for i = #initialStates, 1, -1 do
            local initialState = initialStates[i]
            local root = initialState[1]
            local timestamp = initialState[3]
            local signal = initialState[4]

            local hasStopped = root.AssemblyLinearVelocity.Magnitude * 25 < math.abs(FALLING_VALUE_UNTIL_RAGDOLL)
            local justStarted = os.clock()-timestamp < MIN_FALL_TIME
            if not justStarted and hasStopped then
                signal:Fire()

                table.remove(initialStates, i)
            end
        end
    end)
end

function MovementService.Start()

end

function MovementService.getKnockbackInitialStates()
    return MovementService._state.initialStatesKnockback
end

function MovementService.addKnockbackInitialState(root, force)
    assert(root and root:IsA("BasePart"), "Did not provide a valid root-part.")

    local initialStates = MovementService.getKnockbackInitialStates()
    table.insert(initialStates, {root, force, os.clock(), GoodSignal.new()})
end

function MovementService.knockback(obj, force)
    local root = getRootPartFromObject(obj)
    MovementService.addKnockbackInitialState(root, force)

    local velocity = Instance.new("LinearVelocity")
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = force
    velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    velocity.Attachment0 = root:FindFirstChild("__velocity-attachment")
    velocity.Parent = root

    Red.Spawn(function()
        task.wait(REMOVE_TIME)

        velocity:Destroy()
    end)
end

function MovementService.getSignalForKnockbackComplete(obj)
    local root = getRootPartFromObject(obj)
    local initialStates = MovementService.getKnockbackInitialStates()
    for _, initialState in ipairs(initialStates) do
        local initialStateRoot = initialState[1]
        local signal = initialState[4]

        if initialStateRoot == root then
            return signal;
        end
    end
end

function MovementService.getFallingInitialStates()
    return MovementService._state.initialStatesFalling
end

function MovementService.addFallingInitialState(obj)
    local root = getRootPartFromObject(obj)

    local initialStates = MovementService.getFallingInitialStates()
    table.insert(initialStates, {root, root.Position, os.clock(), GoodSignal.new()})
end

function MovementService.getSignalForFallingComplete(obj)
    local root = getRootPartFromObject(obj)
    local initialStates = MovementService.getFallingInitialStates()
    for _, initialState in ipairs(initialStates) do
        local initialStateRoot = initialState[1]
        local signal = initialState[4]

        if initialStateRoot == root then
            return signal;
        end
    end
end

return MovementService