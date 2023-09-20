local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = ReplicatedStorage.Events
local CharacterAdded = require(Events.CharacterAdded)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Services = ServerScriptService.Services
local CollisionService = require(Services.CollisionService)

local addToCharacters = CollisionService.addToCollisionGroup("Characters")
local addToRagdoll = CollisionService.addToCollisionGroup("Ragdoll")

local Net = Red.Server("Ragdoll", {"On", "Off"})

local FALLING_VALUE_UNTIL_RAGDOLL = -125;

local whitelist = {"Head", "RightLowerArm", "LeftLowerArm", "LeftHand", "RightHand", "LeftLowerLeg", "RightLowerArm", "LeftFoot", "RightFoot", "LowerTorso", "UpperTorso"}

local RagdollService = {}

-- inner functions
local function toggle(character, ragdollEnabled)
    local motors, constraints = RagdollService.getRagdollComponents(character:GetDescendants())
    for _, motor in ipairs(motors) do
        motor.Enabled = not ragdollEnabled
    end
    for _, constraint in ipairs(constraints) do
        constraint.Enabled = ragdollEnabled
    end

    character:SetAttribute("Ragdoll", ragdollEnabled)
    character:SetAttribute("ragdoll_inital", nil)

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
    CharacterAdded.Signal:Connect(RagdollService.setUpRagdoll)

    RunService.PostSimulation:Connect(function()
        local players = Players:GetPlayers()
        local characters = {}
        for _, player in ipairs(players) do
            local character = player.Character
            if character and SystemsHelper.getSystemFromCharacter(character) then
                table.insert(characters, character)
            end
        end

        for _, character in ipairs(characters) do
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then
                continue
            end

            local fallingValue = root.AssemblyLinearVelocity.Y
            local shouldBeRagdolled = fallingValue < FALLING_VALUE_UNTIL_RAGDOLL

            local currentTime = os.clock()
            local isRagdolled = character:GetAttribute("Ragdoll")
            local initial = character:GetAttribute("ragdoll_inital")
            if shouldBeRagdolled and not isRagdolled then
                if not initial then
                    character:SetAttribute("ragdoll_inital", currentTime)
                else
                    local delta = currentTime - initial
                    if delta > 1/3 then
                        local system = SystemsHelper.getSystemFromCharacter(character)
                        local submarine = system and SystemsHelper.getSubmarineInSystem(system)
                        if submarine then
                            local look = CFrame.lookAt(root.Position, submarine.Position).LookVector
                    
                            root.AssemblyLinearVelocity -= look * 100
                        end

                        RagdollService.ragdollOn(character)
                    end
                end
            elseif not shouldBeRagdolled and isRagdolled then
                if not initial then
                    character:SetAttribute("ragdoll_inital", currentTime)
                else
                    local delta = currentTime - initial
                    if delta > 2 then
                        RagdollService.ragdollOff(character)
                    end
                end
            end
        end
    end)

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
    toggle(character, true)

    local player = Players:GetPlayerFromCharacter(character)
    Net:Fire(player, "On")
end

function RagdollService.ragdollOff(character)
    toggle(character, false)

    local player = Players:GetPlayerFromCharacter(character)
    Net:Fire(player, "Off")
end

return RagdollService;