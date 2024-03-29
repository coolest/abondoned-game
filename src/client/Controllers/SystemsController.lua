local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

local Helpers = ReplicatedStorage.Helpers
local SystemsHelper = require(Helpers.SystemsHelper)

local Utils = ReplicatedStorage.Utils
local warn = require(Utils.warn)

local Net = Red.Client("Systems")

--[[
    Controller Start
]]

local SystemsController = {}

function SystemsController.Init()
    Net:On("New", SystemsController.newSystem)

    SystemsController._state = {
        systems = {}
    };
    
    Net:Call("RequestAll"):Then(SystemsController.loadSystems, function(err)
        warn("Existing Systems will be out of sync with server -- could not fetch: " .. err)
    end)
end

function SystemsController.Start()
    RunService:BindToRenderStep("HealthGui", Enum.RenderPriority.First.Value, function()
        local systems = SystemsController.getSystems()
        for i = #systems, 1, -1 do
            local system = systems[i]
            if not system then
                table.remove(systems, i)

                continue
            end

            local submarine = SystemsHelper.getSubmarineInSystem(system)
            local healthBarGui = SystemsHelper.getHealthBarInSystem(system)
            if healthBarGui then
                local part = healthBarGui.Parent

                part.Position = submarine.Position
            end
        end
    end)

    RunService:BindToRenderStep("FakeChainForce", Enum.RenderPriority.First.Value, function()
        local character = Player.Character
        if not character or character:GetAttribute("Ragdoll") or character:GetAttribute("Dead") then
            return;
        end

        local charRoot = character:FindFirstChild("HumanoidRootPart")
        local isCharacterInASystem = character.Parent.Name == "__characters"
        if not (isCharacterInASystem and charRoot) then
            return;
        end

        local system = character.Parent.Parent
        local submarine = SystemsHelper.getSubmarineInSystem(system)
        if not submarine then
            return warn("Could not find submarine")
        end

        local distance = (charRoot.Position - submarine.Position).Magnitude
        local maxDistance = SystemsHelper.getMaximumLengthAllowed(system) + 1
        if distance > maxDistance then
            local look = CFrame.lookAt(charRoot.Position, submarine.Position).LookVector
            local shiftPower = distance-maxDistance
            local delta = look * shiftPower

            charRoot.CFrame = charRoot.CFrame + delta
        end
    end)
end

function SystemsController.loadSystems(systems)
    for _, system in ipairs(systems) do
        SystemsController.addSystem(system)
    end
end

function SystemsController.getSystems()
    return SystemsController._state.systems
end

function SystemsController.addSystem(system)
    local systems = SystemsController.getSystems()
    table.insert(systems, system)
end

function SystemsController.newSystem(system)
    SystemsController.addSystem(system)
end

return SystemsController