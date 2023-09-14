return function(object)
    assert(object and typeof(object) == "Instance", debug.traceback(3) .. "\nObject provided needs to be a roblox instance!")

    for _, particle in ipairs(object:GetDescendants()) do
        local isValid = particle:IsA("ParticleEmitter")
        if not isValid then
            continue
        end

        local emitDelay = particle:GetAttribute("EmitDelay")
        local emitCount = particle:GetAttribute("EmitCount")
        if emitCount == 0 then
            particle:Emit(emitCount)
        else
            task.delay(emitDelay, particle.Emit, particle, emitCount)
        end
    end
end