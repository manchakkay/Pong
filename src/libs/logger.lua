Log = {
    print = function(t, m)
        if (loggerConfig ~= nil and loggerConfig[t] == true) then
            print(tostring(m))
        end
    end
}
