local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Area = workspace.Spawns["1"]

local function getCFrameInArea()
    local pos, size = Area.Position, Area.Size
    local x_min, x_max, z_min, z_max = pos.X-size.X/2, pos.X+size.X/2, pos.Z-size.Z/2, pos.Z+size.Z/2

    return CFrame.new(
        math.random(x_min, x_max),
        pos.Y + 5,
        math.random(z_min, z_max)
    );
end

--[[
    Service Start
]]

local SubmarineService = {}

function SubmarineService.Init()
    SubmarineService._state = {
        systems = {};
    }
end

function SubmarineService.Start()
    local function getSubmarineInSystem(system)
        return system:FindFirstChild("__submarine")
    end

    local function getCharactersInSystem(system)
        local characters = {}
        for _, obj in ipairs(system:GetChildren()) do
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                continue
            end

            table.insert(characters, obj)
        end

        return characters
    end

    local function getChainsValue(chains)
        local total = 0;
        local guess = nil;
        for i = 1, #chains:GetChildren() do
            local chain = chains:FindFirstChild(tostring(i))
            if not chain then
                continue
            end

            local top = chain.Top
            local bottom = chain.Bottom
            local look = CFrame.lookAt(bottom.WorldCFrame.Position, top.WorldCFrame.Position).LookVector
            local dist = (bottom.WorldCFrame.Position - top.WorldCFrame.Position).Magnitude
            if guess then
                total += (guess-top.WorldCFrame.Position).Magnitude
            end

            guess = bottom.WorldCFrame.Position + 2*look*dist
        end

        return total
    end

    local function updateSystem(system)
        local characters = getCharactersInSystem(system)
        local velocity = Vector3.new();
        for _, character in ipairs(characters) do
            local root = character:FindFirstChild("HumanoidRootPart")
            
            local multiplier = 0;
            local chains = character:FindFirstChild("__chains")
            if chains then
                local chainsValue = getChainsValue(chains)
                if chainsValue > 4 then
                    multiplier = 0
                elseif chainsValue > 3.25 then
                    multiplier = 0.15
                elseif chainsValue > 2 then
                    multiplier = 0.3
                elseif chainsValue > 1.5 then
                    multiplier = 0.45
                elseif chainsValue > 1 then
                    multiplier = 0.6
                else
                    multiplier = 0.7
                end
            end

            if root then
                velocity += root.AssemblyLinearVelocity * multiplier
            end
        end

        local submarine = getSubmarineInSystem(system)
        submarine.AssemblyLinearVelocity = velocity
    end

    local counter = 0;
    RunService.PostSimulation:Connect(function(dt)
        counter += 1
        counter %= 300;

        local systems = SubmarineService.getSystems();
        for _, system in ipairs(systems) do
            updateSystem(system)
        end
    end)
end

function SubmarineService.getSystems()
    return SubmarineService._state.systems
end

function SubmarineService.registerSystem(system)
    assert(system and system:IsA("Folder"), "System has to be a folder.")

    local systems = SubmarineService.getSystems()
    table.insert(systems, system)
end

function SubmarineService.newChain(chain)
    return ReplicatedStorage._GAME_ITEMS.Chain[chain]:Clone()
end

function SubmarineService.newSubmarine()
    return ReplicatedStorage._GAME_ITEMS.Submarine:Clone()
end

function SubmarineService.drawChains(submarine, character, amount)
    assert(character and character:IsA("Model"), "Not a valid character provided.")
    assert(submarine, "Need to provide a submarine.")

    local root = character:FindFirstChild("HumanoidRootPart")
    assert(root, "Could not find root part for character!")

    local look = CFrame.lookAt(root.Position, submarine.Position).LookVector
    local chains = character:FindFirstChild("__chains")
    if not chains then
        chains = Instance.new("Folder")
        chains.Name = "__chains"
        chains.Parent = character

        do
            local chain = SubmarineService.newChain("Even")
            chain.CFrame = (root.CFrame + look) * CFrame.Angles(math.pi/2, 0, 0)
            chain.Name = "0"
            chain.Parent = chains;

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chain.Bottom
            constraint.Attachment1 = Instance.new("Attachment", root)
            --constraint.Length = 0.1
            constraint.Parent = chain;
        end

        for i = 1, amount do
            local chain = SubmarineService.newChain(i%2 == 0 and "Even" or "Odd")
            chain.CFrame = (root.CFrame + look*i/10) * CFrame.Angles(math.pi/2, 0, 0)

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chains:FindFirstChild(tostring(i-1)).Top
            constraint.Attachment1 = chain.Bottom
            constraint.MaxFrictionTorque = 5;
            constraint.Parent = chain;

            chain.Name = tostring(i)
            chain.Parent = chains;
        end

        local chain = chains:FindFirstChild(tostring(amount))
        if chain then
            chain.Transparency = 1;

            local constraint = Instance.new("BallSocketConstraint")
            constraint.Attachment0 = chain.Bottom
            constraint.Attachment1 = submarine.Attachment
            --constraint.Length = 0.1
            constraint.Parent = chain;
        end
    end
end

function SubmarineService.buildSystem(players)
    local name = "GROUP"
    for _, player in ipairs(players) do
        name = name .. "-" .. player.Name
    end

    local container = Instance.new("Folder")
    container.Name = name;
    container.Parent = workspace

    local cframe = getCFrameInArea()
    local sub = SubmarineService.newSubmarine();
    sub.Name = "__submarine"
    sub.CFrame = cframe
    sub.Parent = container
    sub:SetNetworkOwner(nil)
    
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.VectorVelocity = Vector3.new();
    linearVelocity.Name = "_velocity"
    linearVelocity.Parent = sub;

    local characters = {}
    for _, player in ipairs(players) do
        local character = player.Character
        if character then
            table.insert(characters, character)
        end
    end

    local radians = math.pi * 2
    local increment = radians / (#characters)
    for _, character in ipairs(characters) do
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = cframe + (cframe * CFrame.Angles(0, radians, 0)).LookVector * 10
            character.Parent = container

            SubmarineService.drawChains(sub, character, 25 + #characters * 5)
        end

        radians -= increment
    end

    SubmarineService.registerSystem(container)
end

return SubmarineService