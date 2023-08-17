local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Net = Red.Server("Slot")

local SlotService = {}

function SlotService.Init()
    SlotService._state = {
        slots = {
            {}, {}, {}, {}
        };

        roots = workspace.Slots:GetChildren();
    };

    local function createSlotTouchedCallback(slot)
        return function(part)
            local character = part:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if not player then
                return;
            end

            SlotService.tryJoin(player, slot)
        end
    end

    local roots = SlotService.getSlotRoots()
    for _, root in ipairs(roots) do
        local onTouched = createSlotTouchedCallback(tonumber(root.Name))
        root.Touched:Connect(onTouched)
    end
end

function SlotService.Start()

end

function SlotService.getSlots() 
    return SlotService._state.slots 
end

function SlotService.getSlotRoots() 
    return SlotService._state.roots 
end

function SlotService.getSlotRoot(slot)
    if typeof(slot) == "number" then
        slot = tostring(slot)
    end

    for _, root in ipairs(SlotService.getSlotRoots()) do
        if root.name == slot then
            return root;
        end
    end
end

function SlotService.getPlayerSlot(player)
    local slots = SlotService.getSlots()
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

function SlotService.updateSlotCount(slot)
    local slotRoot = SlotService.getSlotRoot(slot)
    local counterLabel = slotRoot:FindFirstChild("CounterLabel", true)
    local playersLabel = slotRoot:FindFirstChild("PlayersLabel", true)
    local amount = #SlotService.getSlots()[slot]

    if counterLabel then
        counterLabel.Text = tostring(amount)
    end

    if playersLabel then
        playersLabel.Text = (amount == 1)
            and "Player"
            or "Players"
    end
end

function SlotService.placeCharacterInSlot(charRoot, slot)
    assert(charRoot and charRoot:IsA("Instance") and charRoot:IsA("BasePart"), "Need to provide a valid root of type BasePart for character")
    if type(slot) == "number" then
        slot = tostring(slot)
    end

    local slotRoot = SlotService.getSlotRoot(slot)
    charRoot.CFrame = slotRoot.CFrame - slotRoot.CFrame.LookVector * 5
end

function SlotService.tryJoin(player, slot)
    assert(player and typeof(player) == "Instance" and player:IsA("Player"), "Need to pass player into the 1st argument.")
    assert(slot and type(slot) == "number", "Slot provided needs to be a number (2nd argument).")

    local isInSlot = SlotService.playerIsInSlot(player)
    if isInSlot then
        return false;
    end

    local slots = SlotService.getSlots()
    table.insert(slots[slot], player)

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        SlotService.placeCharacterInSlot(root, slot)
        SlotService.updateSlotCount(slot)
    end

    return true;
end

function SlotService.tryLeave(player, slot)
    assert(player and typeof(player) == "Instance" and player:IsA("Player"), "Need to pass player into the 1st argument.")
    assert(slot and type(slot) == "number", "Slot provided needs to be a number (2nd argument).")

    local slots = SlotService.getSlots()
    local slotNumber = SlotService.getPlayerSlot(player)
    if slotNumber == slot then
        table.remove(slots[slot], table.find(slots[slot], player))
    else
        return false;
    end
end

return SlotService