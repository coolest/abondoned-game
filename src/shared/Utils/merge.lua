return function(...)
    local merged = {}
    for _, t in ipairs(table.pack(...)) do
        for key, val in pairs(t) do
            merged[key] = val;
        end
    end

    return merged;
end