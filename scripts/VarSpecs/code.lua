VarSpecTypes[function (varSpec, initialValue)
    if varSpec.options["code"] and type(initialValue) == "string" then return math.maxinteger else return -1 end
end] = function (varSpec)
    varSpec.env = varSpec.options["code"] or {}
    varSpec.env.print = print
    varSpec.env.rl = rl

    varSpec.set = function (self, code) -- only when manually wanting to save, we actually set it..?
        self.code = code

        local func, err = load(code, nil, nil, self.env)

        if func then
            self.func = func
        else
            print("Error reading code:", err)
        end
    end

    varSpec.get = function (self)
        return self.func
    end

    varSpec.toSaveValue = function (self)
        return '[[' .. self.code .. ']]'
    end
end