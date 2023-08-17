local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local SubmarineController = {}

function SubmarineController.Init()
    Player.CharacterAdded:Connect(SubmarineController.OnCharacterAdded)
    if Player.Character then
        task.spawn(SubmarineController.OnCharacterAdded, Player.Character)
    end
end

function SubmarineController.Start()
    RunService:BindToRenderStep("SubmarineController", Enum.RenderPriority.Character.Value-1, function(dt)
        local character = Player.Character
        local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
        local submarine = character and character:FindFirstChild("__submarine")

        if not (submarine and character) then
            return;
        end

        local chain = character:FindFirstChild("__chains")
        local rootChain = chain:FindFirstChild("0")
        if rootChain then
            --rootChain.CFrame = characterRoot.CFrame
        end
    end)
end

function SubmarineController.OnCharacterAdded(character)
    
end

function SubmarineController.addSubmarine()
    local startPosition = root.Position - root.CFrame.LookVector * 10

    local sub = SubmarineController.newSubmarine();
    sub.Name = "__submarine"
    sub.CFrame = CFrame.lookAt(startPosition, root.Position)
    sub.Parent = character;
end

function SubmarineController.drawChain(character, submarine)
    assert(character and character:IsA("Model"), "Not a valid character provided.")
    assert(submarine, "Need to provide a submarine.")

    local root = character:FindFirstChild("HumanoidRootPart")
    assert(root, "Could not find root part for character!")

    local chains = character:FindFirstChild("__chains")
    if not chains then
        print("here")
        chains = Instance.new("Folder")
        chains.Name = "__chains"
        chains.Parent = character

        do
            local chain = SubmarineController.newChain("Even")
            chain.CFrame = (root.CFrame - root.CFrame.LookVector) * CFrame.Angles(math.pi/2, 0, 0)
            chain.Name = "0"
            chain.Parent = chains;

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chain.Bottom
            constraint.Attachment1 = Instance.new("Attachment", root)
            --constraint.Length = 0.1
            constraint.Parent = chain;
        end

        for i = 1, 30 do
            local chain = SubmarineController.newChain(i%2 == 0 and "Even" or "Odd")

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chains:FindFirstChild(tostring(i-1)).Top
            constraint.Attachment1 = chain.Bottom
            constraint.MaxFrictionTorque = 5;
            constraint.Parent = chain;

            chain.Name = tostring(i)
            chain.Parent = chains;
        end

        local chain = chains:FindFirstChild("30")
        if chain then
            chain.Transparency = 1;

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chain.Bottom
            constraint.Attachment1 = submarine.Attachment
            --constraint.Length = 0.1
            constraint.Parent = chain;
        end
    end
end;

function SubmarineController.newSubmarine()
    return ReplicatedStorage._GAME_ITEMS.Submarine:Clone()
end

function SubmarineController.newChain(chain)
    return ReplicatedStorage._GAME_ITEMS.Chain[chain]:Clone()
end

return SubmarineController