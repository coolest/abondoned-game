local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Server("Systems", {"New"})

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

local SystemsService = {}

function SystemsService.Init()
    SystemsService._state = {
        systems = {};
    }
end

function SystemsService.Start()
    local function updateSystem(system)
        local submarine = SystemsHelper.getSubmarineInSystem(system)
        local characters = SystemsHelper.getCharactersInSystem(system):GetChildren()

        local velocity = Vector3.new();
        for _, character in ipairs(characters) do
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then
                continue
            end

            local dist = (submarine.Position - root.Position).Magnitude
            local maxDist = SystemsHelper.getMaximumLengthAllowed(system)
            local multiplier = math.clamp((dist-maxDist).Magnitude, 1, 100)
            if (dist-maxDist).Magnitude < 1 then
                velocity += root.AssemblyLinearVelocity * multiplier
            end
        end

        submarine.AssemblyLinearVelocity = velocity
    end

    local counter = 0;
    RunService.PostSimulation:Connect(function(dt)
        counter += 1
        counter %= 300;

        local systems = SystemsService.getSystems();
        for _, system in ipairs(systems) do
            updateSystem(system)
        end
    end)
end

function SystemsService.getSystems()
    return SystemsService._state.systems
end

function SystemsService.registerSystem(system)
    assert(system and system:IsA("Folder"), "System has to be a folder.")

    local systems = SystemsService.getSystems()
    table.insert(systems, system)
end

function SystemsService.newChainBeam()
    return ReplicatedStorage._GAME_ITEMS.ChainBeam:Clone()
end

function SystemsService.newSubmarine()
    return ReplicatedStorage._GAME_ITEMS.Submarine:Clone()
end

function SystemsService.drawChains(submarine, character, amount)
    assert(character and character:IsA("Model"), "Not a valid character provided.")
    assert(submarine, "Need to provide a submarine.")

    local root = character:FindFirstChild("HumanoidRootPart")
    assert(root, "Could not find root part for character!")

    local chains = character:FindFirstChild("__chains")
    if not chains then
        chains = Instance.new("Folder")
        chains.Name = "__chains"
        chains.Parent = character

        local submarineAttachment = submarine:FindFirstChild("Attachment")
        local characterAttachment = Instance.new("Attachment")
        characterAttachment.Parent = root;

        if submarineAttachment then
            local chainBeam = SystemsService.newChainBeam()
            chainBeam.Attachment0 = submarineAttachment
            chainBeam.Attachment1 = characterAttachment
            chainBeam.Name = character.Name .. "-Chain"
            chainBeam.Parent = submarine
        end
    end
end

function SystemsService.buildSystem(players)
    local name = "GROUP"
    for _, player in ipairs(players) do
        name = name .. "-" .. player.Name
    end

    local systemContainer = Instance.new("Folder")
    systemContainer.Name = name;
    systemContainer.Parent = workspace
    systemContainer:SetAttribute("MaxDistance", 10 + #players)

    local charactersContainer = Instance.new("Folder")
    charactersContainer.Name = "__characters"
    charactersContainer.Parent = systemContainer

    local cframe = getCFrameInArea()
    local sub = SystemsService.newSubmarine();
    sub.Name = "__submarine"
    sub.CFrame = cframe
    sub.Parent = systemContainer
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
            character.Parent = charactersContainer

            SystemsService.drawChains(sub, character)
        end

        radians -= increment
    end

    SystemsService.registerSystem(systemContainer)

    Net:FireAll("New", systemContainer)
end

return SystemsService