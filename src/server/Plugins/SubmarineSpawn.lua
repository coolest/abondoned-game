local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Area = workspace.Spawns["1"]

local function newChain(chain)
    return ReplicatedStorage._GAME_ITEMS.Chain[chain]:Clone()
end

local function newSubmarine()
    return ReplicatedStorage._GAME_ITEMS.Submarine:Clone()
end

local function getCFrameInArea()
    local pos, size = Area.Position, Area.Size
    local x_min, x_max, z_min, z_max = pos.X-size.X/2, pos.X+size.X/2, pos.Z-size.Z/2, pos.Z+size.Z/2

    return CFrame.new(
        math.random(x_min, x_max),
        pos.Y + 5,
        math.random(z_min, z_max)
    );
end

local function drawChains(submarine, character, amount)
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
            local chain = newChain("Even")
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
            local chain = newChain(i%2 == 0 and "Even" or "Odd")
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

return function(players)
    local name = "GROUP"
    for _, player in ipairs(players) do
        name = name .. "-" .. player.Name
    end

    local container = Instance.new("Folder")
    container.Name = name;
    container.Parent = workspace

    local cframe = getCFrameInArea()
    local sub = newSubmarine();
    sub.Name = "__submarine"
    sub.CFrame = cframe
    sub.Parent = container
    sub:SetNetworkOwner(nil)
    
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

            drawChains(sub, character, 25 + #characters * 5)
        end

        radians -= increment
    end
end