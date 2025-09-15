local CRDTDoc, _ = require("CRDT")

-- figure something out for 'label._text.value' [duplicate from elements/textbox.lua]

VarSpecTypes[function (varSpec, initialValue)
    if getmetatable(initialValue) == CRDTDoc then return math.maxinteger else return -1 end
end] = function (varSpec)
    varSpec.inspectorElement = function (self)
        -- should be able to link it so that a textbox directly changes this ones char list and dosen't have its own..?
    end

    varSpec.toSaveValue = function (self, indent, ami)
        return "{"..BreakdownObject(self:get(), indent.."\t", ami) .. "\n"..indent.."}"
    end
    varSpec.fromSaveValue = function (self, mod)
        ApplyModification(self, mod)
    end

    varSpec.get = function (self)
        return self.value:getText()
    end

    varSpec.len = function (self)
        return #self.value.chars
    end
end