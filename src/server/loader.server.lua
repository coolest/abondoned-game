local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerLoaded = Instance.new("BindableEvent")
ServerLoaded.Name = "SERVER_LOADED"
ServerLoaded.Parent = ReplicatedStorage

local function prettyPrint(str, loadTime)
    loadTime *= 1_000_000;

    local label = string.format("%-30s", str)
    local perf = string.format("%dµs", math.ceil(loadTime))

    print(label, perf)
end

print(("/"):rep(50))
print("[SERVER LOADING]")
print(("/"):rep(50))

--

local start = os.clock()

for _, src in ipairs(ServerScriptService.Plugins:GetChildren()) do
    local ok, err = pcall(require, src)
    if not ok then
        error(string.format("Issue starting plugin, %s:\n%s", src.Name, err))
    end
end

prettyPrint("Loaded plugins in: ", os.clock()-start, "s")

--

start = os.clock()

local services = {}

for _, src in ipairs(ServerScriptService.Services:GetChildren()) do
    table.insert(services, require(src))
end

prettyPrint("Required services in: ", os.clock()-start, "s")
start = os.clock()

for _, service in ipairs(services) do
    local ok, err = pcall(service.Init)
    if not ok then
        error(string.format("Issue initializing service, %s", err))
    end
end

prettyPrint("Initialized services in: ", os.clock()-start, "s")
start = os.clock()

for _, service in ipairs(services) do
    local ok, err = pcall(service.Start)
    if not ok then
        error(string.format("Issue starting service, %s", err))
    end
end

prettyPrint("Started services in: ", os.clock()-start, "s")
start = os.clock()

--

local Events = {}
for _, sharedEvent in ipairs(ReplicatedStorage.Events:GetChildren()) do
    table.insert(Events, sharedEvent)
end
for _, serverEvent in ipairs(ServerScriptService.Events:GetChildren()) do
    table.insert(Events, serverEvent)
end

for _, event in ipairs(Events) do
    local eventTable = require(event)

    local ok, res = pcall(eventTable.SystemsStarted)
    if not ok then
        error(string.format("Issue starting event, %s:\n%s", event.Name, res))
    end
end

prettyPrint("Loaded events in: ", os.clock()-start, "s")
print(("/"):rep(50))

ServerLoaded:Fire()