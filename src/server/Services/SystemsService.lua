local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Plugins = ServerScriptService.Plugins
local Documents = require(Plugins.Documents)

local Events = ServerScriptService.Events
local SystemAdded = require(Events.SystemAdded)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local Net = Red.Server("Systems", {"New", "RequestAll"})

local gameItems = ReplicatedStorage._GAME_ITEMS
local systems = Instance.new("Folder", workspace)
systems.Name = "__Systems"

local function getSpawnCFrameFromCheckpoint(checkpoint)
    checkpoint = workspace.Checkpoints:FindFirstChild("Checkpoint" .. tostring(checkpoint))
    assert(checkpoint, "Could not find checkpoint in workspace.Checkpoints")

    local pos, size = checkpoint.Position, checkpoint.Size
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

    Net:On("RequestAll", function()
        return SystemsService.getSystems()
    end)
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
            local multiplier = math.clamp(dist-maxDist, 1, 100)
            local dampeningValue = math.clamp(math.abs(maxDist-dist), 1, math.huge)

            if dampeningValue < 3 then
                local assemblyVelocity = CFrame.lookAt(submarine.Position, root.Position).LookVector * root.AssemblyLinearVelocity.Magnitude * 2
                velocity += Vector3.new(assemblyVelocity.X, assemblyVelocity.Y/5, assemblyVelocity.Z) * multiplier / dampeningValue
            elseif (dist-maxDist) > 3 then
                local look = CFrame.lookAt(submarine.Position, root.Position).LookVector
                velocity += look*15 * multiplier/2
            end
        end

        submarine.AssemblyLinearVelocity = velocity
    end

    RunService.PreSimulation:Connect(function()
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

    SystemAdded.Signal:Fire(system)
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

    local lowestCheckpoint = math.huge;
    for _, player in ipairs(players) do
        local document = Documents[player]
        local data = document:read()
        if data.checkpoint < lowestCheckpoint then
            lowestCheckpoint = data.checkpoint
        end
    end

    local cframe = getSpawnCFrameFromCheckpoint(lowestCheckpoint)

    local systemContainer = Instance.new("Folder")
    systemContainer.Name = name;
    systemContainer.Parent = systems
    systemContainer:SetAttribute("MaxDistance", 10 + #players)

    local charactersContainer = Instance.new("Folder")
    charactersContainer.Name = "__characters"
    charactersContainer.Parent = systemContainer

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

    local health = gameItems.Health:Clone()
    health.Name = "__health"
    health.Parent = systemContainer

    SystemsService.registerSystem(systemContainer)

    Net:FireAll("New", systemContainer)
end

return SystemsService