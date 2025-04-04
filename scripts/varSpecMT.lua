local VarSpec = require("varSpec")

return function (MT)
    MT.__index = function(t, k)
        local value = rawget(t, k)
        
        if not value then
            value = rawget(t, "_"..k)
            if value then value = value.value end
        end

        if value then
            return value
        end

        return MT[k]
    end
    MT.__newindex = function (t, k, v)
        local potentialVarSpec = rawget(t, "_"..k)
        if potentialVarSpec then
            potentialVarSpec.value = v
            return
        end

        if getmetatable(v) == VarSpec and k:sub(1, 1) ~= "_" then
            rawset(t, "_"..k, v)
            return
        end

        rawset(t, k, v)
    end
end