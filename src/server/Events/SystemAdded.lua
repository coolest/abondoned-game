local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local GoodSignal = require(Packages.goodsignal)

local signal = GoodSignal.new()

return {
    Signal = signal,
    SystemsStarted = function() end;
};