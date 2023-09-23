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
    --[[
    local function handleChainMovement(submarine, dt)
        local beams = {}
        for _, v in ipairs(submarine:GetChildren()) do
            if v:IsA("Beam") then
                table.insert(beams, v)
            end
        end

        for _, beam in ipairs(beams) do
            local mode = beam:GetAttribute("Mode")
            if not mode then
                beam:SetAttribute("Mode", -1)
                mode = -1
            end

            local curve0 = beam.CurveSize0
            local curve1 = beam.CurveSize1
            curve0 += dt*20*mode
            curve1 -= dt*20*mode

            beam.CurveSize0 = math.clamp(curve0, -0.3, 0.3)
            beam.CurveSize1 = math.clamp(curve1, -0.3, 0.3)

            if math.abs(curve0) >= 0.3 then
                beam:SetAttribute("Mode", mode * (-1))
            end
        end
    end

    RunService:BindToRenderStep("ChainMovement", Enum.RenderPriority.Character.Value, function(dt)
        local systems = SystemsController.getSystems()
        for _, system in ipairs(systems) do
            local submarine = SystemsHelper.getSubmarineInSystem(system)
            if submarine then
                handleChainMovement(submarine, dt)
            end
        end
    end)
    ]]

    RunService:BindToRenderStep("HealthGui", Enum.RenderPriority.First.Value, function()
        local systems = SystemsController.getSystems()
        for _, system in ipairs(systems) do
            local submarine = SystemsHelper.getSubmarineInSystem(system)
            local healthBarGui = SystemsHelper.getHealthBarInSystem(system)
            local part = healthBarGui.Parent

            part.Position = submarine.Position
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
        local submarine = system:FindFirstChild("__submarine")
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