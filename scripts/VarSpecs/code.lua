return function (varSpec, env)
    env.print = print
    env.rl = rl
    
    varSpec.set = function (self, code) -- only when manually wanting to save, we actually set it..?
        self.code = code

        local func, err = load(code, nil, nil, env)

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
        return self.code
    end
end