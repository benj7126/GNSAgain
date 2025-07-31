VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "string" then return 1 else return -1 end
end] = function (varSpec)
    varSpec.toSaveValue = function (self)
        return '[[' .. self:get() .. ']]'
    end
end