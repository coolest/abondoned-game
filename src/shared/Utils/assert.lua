return function (predicate, msg)
    local traceback = debug.traceback(5)

    assert(predicate, traceback .. "\n" .. msg)
end