local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ReplicatedStorage.Events
local CharacterAdded = require(Events.CharacterAdded)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Services = ServerScriptService.Services
local CollisionService;

local addToCharacters
local addToRagdoll

local Net = Red.Server("Ragdoll", {"On", "Off"})

local whitelist = {"Head", "RightLowerArm", "LeftLowerArm", "LeftHand", "RightHand", "LeftLowerLeg", "RightLowerArm", "LeftFoot", "RightFoot", "LowerTorso", "UpperTorso"}

local RagdollService = {}

-- inner functions
local function toggle(character, ragdollEnabled)
    local root = character.PrimaryPart
    if root then
        root.CanCollide = not ragdollEnabled
        root.Massless = ragdollEnabled
    end

    local motors, constraints = RagdollService.getRagdollComponents(character:GetDescendants())
    for _, motor in ipairs(motors) do
        motor.Enabled = not ragdollEnabled
    end
    for _, constraint in ipairs(constraints) do
        constraint.Enabled = ragdollEnabled
    end

    character:SetAttribute("Ragdoll", ragdollEnabled)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = ragdollEnabled
        humanoid.AutoRotate = not ragdollEnabled;
    end

    if ragdollEnabled then
        addToRagdoll(character)
    else
        addToCharacters(character)
    end
end

-- exposed
function RagdollService.Init()
    CollisionService    = require(Services.CollisionService)
    addToCharacters     = CollisionService.addToCollisionGroup("Characters")
    addToRagdoll        = CollisionService.addToCollisionGroup("Ragdoll")

    CharacterAdded.Signal:Connect(RagdollService.setUpRagdoll)

    local function toggleClientReq(on)
        return function(plr)
            local char = plr.Character
            if char then
                toggle(char, on)
            end
        end
    end

    Net:On("On", toggleClientReq(true))
    Net:On("Off", toggleClientReq(false))
end

function RagdollService.Start()

end

function RagdollService.setUpRagdoll(character)
    for _, part in ipairs(character:GetChildren()) do
        if not part:IsA("BasePart") then
            continue
        end
        
		local motor = part:FindFirstChildWhichIsA("Motor6D")
        if not motor then
            continue
        end

        local shouldWeld = table.find(whitelist, part.Name)
        if shouldWeld then
            local weld = Instance.new("WeldConstraint")
            weld.Enabled = false;
            weld.Name = "__ragdoll-id"

            weld.Part0 = motor.Part0
            weld.Part1 = motor.Part1
            weld.Parent = motor.Parent
        else
            local ballsocketConstraint = Instance.new("BallSocketConstraint")
            ballsocketConstraint.Enabled = false;
            ballsocketConstraint.Name = "__ragdoll-id"

            local attachment1 = Instance.new("Attachment")
            attachment1.CFrame = motor.C0
            attachment1.Parent = motor.Part0

            local attachment2 = Instance.new("Attachment")
            attachment2.CFrame = motor.C1
            attachment2.Parent = motor.Part1

            ballsocketConstraint.Attachment0 = attachment1
            ballsocketConstraint.Attachment1 = attachment2
            ballsocketConstraint.Parent = motor.Parent
        end
	end
end

function RagdollService.getRagdollComponents(desc)
    local motors = {}
    local ragdollConstraints = {}

    for _, v in ipairs(desc) do
        if v:IsA("Motor6D") then
            table.insert(motors, v)
        elseif v.Name == "__ragdoll-id" then
            table.insert(ragdollConstraints, v)
        end
    end

    return motors, ragdollConstraints
end

function RagdollService.ragdollOn(character)
    assert(character and character:FindFirstChildOfClass("Humanoid") and character.PrimaryPart, "Did not provide a valid character!")

    toggle(character, true)

    local player = Players:GetPlayerFromCharacter(character)
    Net:Fire(player, "On")
end

function RagdollService.ragdollOff(character)
    assert(character and character:FindFirstChildOfClass("Humanoid") and character.PrimaryPart, "Did not provide a valid character!")
    
    toggle(character, false)

    local player = Players:GetPlayerFromCharacter(character)
    Net:Fire(player, "Off")
end

return RagdollService;