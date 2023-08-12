local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.red)
local LoadingNet = Red.Client("Load")

local PlayerScripts = script.Parent

--

print("[CLIENT LOADING]")

local start = os.clock()

for _, src in ipairs(PlayerScripts:WaitForChild("Plugins"):GetChildren()) do
    local ok, err = pcall(require, src)
    if not ok then
        error(string.format("Issue starting plugin, %s:\n%s", src.Name, err))
    end
end

print("Loaded plugins in: ", os.clock()-start, "s")

--

start = os.clock()

local controllers = {}
for _, src in ipairs(PlayerScripts:WaitForChild("Controllers"):GetChildren()) do
    controllers[src.Name] = require(src)
end

print("Required controllers in: ", os.clock()-start, "s")

start = os.clock()
for name, controller in pairs(controllers) do
    local ok, err = pcall(controller.Init)
    if not ok then
        error(string.format("Issue initializing controller, %s, %s", name, err))
    end
end

print("Initialized controllers in: ", os.clock()-start, "s")

start = os.clock()
for name, controller in pairs(controllers) do
    local ok, err = pcall(controller.Start)
    if not ok then
        error(string.format("Issue starting controller, %s, %s", err))
    end
end

print("Started controllers in: ", os.clock()-start, "s")

--

start = os.clock()

local Events = {}
for _, sharedEvent in ipairs(ReplicatedStorage.Events:GetChildren()) do
    table.insert(Events, sharedEvent)
end
for _, clientEvent in ipairs(PlayerScripts:WaitForChild("Events"):GetChildren()) do
    table.insert(Events, clientEvent)
end

for _, event in ipairs(Events) do
    local eventTable = require(event)

    local ok, res = pcall(eventTable.SystemsStarted)
    if not ok then
        error(string.format("Issue starting event, %s:\n%s", event.Name, res))
    end
end

print("Loaded events in: ", os.clock()-start, "s")

LoadingNet:Fire("Complete")