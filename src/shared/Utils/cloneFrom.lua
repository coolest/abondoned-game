return function (startIndex, endIndex, tbl)
    local new = {}

    for i = startIndex, endIndex do
        table.insert(new, tbl[i])
    end

    return new;
end