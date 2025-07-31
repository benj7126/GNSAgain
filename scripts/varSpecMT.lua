local VarSpec = require("varSpec")

-- should probably have either some sort of warning if i set the value of a varspec to another varspec?
-- or just override the current varspec?

return function (MT)
    MT.__index = function(t, k)
        local value = rawget(t, k)
        
        if not value then
            value = rawget(t, "_"..k)
            if value then value = value:get() end
        end

        if value then
            return value
        end

        return MT[k]
    end
    MT.__newindex = function (t, k, v)
        local potentialVarSpec = rawget(t, "_"..k)
        if potentialVarSpec then
            potentialVarSpec:set(v)
            return
        end

        if getmetatable(v) == VarSpec and k:sub(1, 1) ~= "_" then
            rawset(t, "_"..k, v)
            return
        end

        rawset(t, k, v)
    end
end