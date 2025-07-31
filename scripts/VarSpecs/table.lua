VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "table" then return 1 else return -1 end
end] = function (varSpec)
    -- make all sub elements be varspecs too... maby?
    -- idfk........
    varSpec.toSaveValue = function (self, indent, ami)
        return "{"..BreakdownObject(self:get(), indent.."\t", ami) .. "\n"..indent.."}"
    end
end