local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Red = require(Packages.red)

return function(t, obj)
    Red.Spawn(function()
        task.wait(t)

        if obj then
            obj:Destroy()
        end
    end)
end