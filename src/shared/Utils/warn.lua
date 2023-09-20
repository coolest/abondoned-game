return function(str)
    local traceback = debug.traceback(5)

    warn(traceback .. "\n" .. str)
end