return function(old, updates)
    local new = {}

    for key, val in pairs(old) do
        new[key] = val;
    end

    for key, val in pairs(updates) do
        new[key] = val;
    end

    return new;
end