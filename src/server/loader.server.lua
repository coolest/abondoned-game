local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--

for _, src in ipairs(ServerScriptService.Plugins:GetChildren()) do
    local ok, err = pcall(require, src)
    if not ok then
        error(string.format("Issue starting plugin, %s:\n%s", src.Name, err))
    end
end

--

local services = {}

for _, src in ipairs(ServerScriptService.Services:GetChildren()) do
    table.insert(services, require(src))
end

for _, service in ipairs(services) do
    local ok, err = pcall(service.Init)
    if not ok then
        error(string.format("Issue initializing service, %s", err))
    end
end

for _, service in ipairs(services) do
    local ok, err = pcall(service.Start)
    if not ok then
        error(string.format("Issue initializing service, %s", err))
    end
end

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