VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "boolean" then return 1 else return -1 end
end] = function (varSpec)
    varSpec.toSaveValue = function (self)
        if self:get() then
            return "true"
        else
            return "false"
        end
    end
end