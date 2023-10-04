local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local SystemsService

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Utils = ReplicatedStorage.Utils
local assert = require(Utils.assert)

local ServerUtils = ServerScriptService.Utils
local getPlayerData = require(ServerUtils.getPlayerData)

local Net = Red.Server("Slot", {"Join", "Leave", "Start"})

local SlotService = {}

function SlotService.Init()
    SystemsService = require(Services.SystemsService)
    
    Net:On("Leave", SlotService.tryLeave)
    Net:On("Start", SlotService.tryStart)

    SlotService._state = {
        slots = {};
        roots = {};
    };

    local slotsContainers = workspace.Slots
    for _, container in ipairs(slotsContainers:GetChildren()) do
        local checkpoint = tonumber(container.Name)
        local slotRoots = container:GetChildren();

        SlotService._state.slots[checkpoint] = {}
        SlotService._state.roots[checkpoint] = {}

        for _, slotRoot in ipairs(slotRoots) do
            table.insert(SlotService._state.slots[checkpoint]   , {})
            table.insert(SlotService._state.roots[checkpoint]   , slotRoot)
        end
    end

    local function createSlotTouchedCallback(slot)
        return function(part)
            local character = part:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if not player then
                return;
            end

            if SystemsHelper.getSystemFromCharacter(character) then
                return
            end

            SlotService.tryJoin(player, slot)
        end
    end

    local roots = SlotService.getAllSlotRoots()
    for _, root in ipairs(roots) do
        local onTouched = createSlotTouchedCallback(tonumber(root.Name))
        root.Touched:Connect(onTouched)
    end
end

function SlotService.Start()

end

function SlotService.getSlots(checkpoint)
    return SlotService._state.slots[checkpoint]
end

function SlotService.getAllSlotRoots() 
    local slots = {}
    for _, checkpointRoots in ipairs(SlotService.getSlotRoots()) do
        for _, root in ipairs(checkpointRoots) do
            table.insert(slots, root)
        end
    end

    return slots;
end

function SlotService.getSlotRoots()
    return SlotService._state.roots
end

function SlotService.getSlotRoot(checkpoint, slot)
    if typeof(slot) == "number" then
        slot = tostring(slot)
    end

    local roots = SlotService.getSlotRoots()
    local checkpointRoots = roots[checkpoint]
    for _, root in ipairs(checkpointRoots) do
        if root.Name == slot then
            return root;
        end
    end
end

function SlotService.getPlayerSlot(player)
    local ok, result = pcall(getPlayerData, player)
    if not ok then
        warn(result)

        return false;
    end

    local checkpoint = result.checkpoint
    local slots = SlotService.getSlots(checkpoint)
    for i, slot in ipairs(slots) do
        if table.find(slot, player) then
            return i;
        end
    end

    return false
end

function SlotService.playerIsInSlot(player)
    return type(SlotService.getPlayerSlot(player)) == "number"
end

function SlotService.updateSlotCount(checkpoint, slot)
    if type(slot) == "string" then
        slot = tonumber(slot)
    end

    local slotRoot = SlotService.getSlotRoot(checkpoint, slot)
    local counterLabel = slotRoot:FindFirstChild("CounterLabel", true)
    local playersLabel = slotRoot:FindFirstChild("PlayersLabel", true)
    local amount = #SlotService.getSlots(checkpoint)[slot]

    if counterLabel then
        counterLabel.Text = tostring(amount)
    end

    if playersLabel then
        playersLabel.Text = (amount == 1)
            and "Player"
            or "Players"
    end
end

function SlotService.placeCharacterInSlot(charRoot, checkpoint, slot)
    assert(charRoot and charRoot:IsA("Instance") and charRoot:IsA("BasePart"), "Need to provide a valid root of type BasePart for character")
    if type(slot) == "number" then
        slot = tostring(slot)
    end

    local slotRoot = SlotService.getSlotRoot(checkpoint, slot)
    charRoot.CFrame = slotRoot.CFrame - slotRoot.CFrame.LookVector * 5
end

function SlotService.removeCharacterFromSlot(charRoot, checkpoint, slot)
    assert(charRoot and charRoot:IsA("Instance") and charRoot:IsA("BasePart"), "Need to provide a valid root of type BasePart for character")
    if type(slot) == "number" then
        slot = tostring(slot)
    end

    local slotRoot = SlotService.getSlotRoot(checkpoint, slot)
    charRoot.CFrame = slotRoot.CFrame + slotRoot.CFrame.LookVector * 10
end

function SlotService.tryJoin(player, slot)
    assert(player and typeof(player) == "Instance" and player:IsA("Player"), "Need to pass player into the 1st argument.")
    assert(slot and type(slot) == "number", "Slot provided needs to be a number (2nd argument).")

    local isInSlot = SlotService.playerIsInSlot(player)
    if isInSlot then
        return false;
    end

    local ok, result = pcall(getPlayerData, player)
    if not ok then
        warn(result)

        return;
    end

    local checkpoint = result.checkpoint
    local slots = SlotService.getSlots(checkpoint)
    table.insert(slots[slot], player)

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        SlotService.placeCharacterInSlot(root, checkpoint, slot)
        SlotService.updateSlotCount(checkpoint, slot)

        Net:Fire(player, "Join")
    end

    return true;
end

function SlotService.tryLeave(player)
    assert(player and typeof(player) == "Instance" and player:IsA("Player"), "Need to pass player into the 1st argument.")

    local ok, result = pcall(getPlayerData, player)
    if not ok then
        warn(result)

        return;
    end

    local checkpoint = result.checkpoint
    local slots = SlotService.getSlots(checkpoint)
    local slotNumber = SlotService.getPlayerSlot(player)
    if slotNumber then
        local slot = tostring(slotNumber)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            SlotService.removeCharacterFromSlot(root, checkpoint, slot)
        end

        table.remove(slots[slotNumber], table.find(slots[slotNumber], player))

        SlotService.updateSlotCount(checkpoint, slotNumber)

        return true;
    else
        return false;
    end
end

function SlotService.tryStart(player)
    assert(player and typeof(player) == "Instance" and player:IsA("Player"), "Need to pass player into the 1st argument.")

    local ok, result = pcall(getPlayerData, player)
    if not ok then
        warn(result)

        return;
    end

    local checkpoint = result.checkpoint
    local slots = SlotService.getSlots(checkpoint)
    local slotNumber = SlotService.getPlayerSlot(player)
    if slotNumber then
        local players = table.clone(slots[slotNumber])
        table.clear(slots[slotNumber])

        SystemsService.buildSystem(players)
        SlotService.updateSlotCount(checkpoint, slotNumber)

        Net:FireList(players, "Start")
    end
end

return SlotService