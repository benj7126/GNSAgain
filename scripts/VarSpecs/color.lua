VarSpecTypes[function (varSpec, initialValue)
    if isColor(initialValue) then return 2 else return -1 end
end] = function (varSpec)
    varSpec.toSaveValue = function (self)
        local c = self:get()
        return '{' .. c.R .. "," .. c.G .. "," .. c.B .. "," .. c.A .. '}'
    end

    varSpec.fromSaveValue = function (self, value)
        value = value or {}
        self:set(rl.color(value[1] or 255, value[2] or 255, value[3] or 255, value[4] or 255))
    end
end