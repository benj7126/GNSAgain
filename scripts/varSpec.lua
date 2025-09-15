local VarSpecs = {}

VarSpecTypes = {}

-- could have custom saving option
-- so that it used that to save the value
-- could be used for multiple things
-- fix if the thing in value is a
-- workspace id and we use that as some
-- ref nonsense.

-- thoughts on 'options'.
-- Code? -- lets it know that the string is not just text, but code.
         -- could it then return the code block..?

function VarSpecs:new(value, options)
    local vs = {}
    setmetatable(vs, self)
    self.__index = self
    vs.options = options or {}

    local highest = {nil, nil}

    for typeEval, applyType in pairs(VarSpecTypes) do
        local eval = typeEval(vs, value)
        if eval > 0 then
            if not highest[1] or eval > highest[1] then
                highest = {eval, applyType}
            elseif highest[1] and highest[1] == eval then
                print("potential confilcit in evaluation of varSpec type for; " .. tostring(value) .. " | " .. type(value))
            end
        end
    end

    if highest[1] then
        highest[2](vs)
    else
        print("no viable varSpec type for; " .. tostring(value) .. " | " .. type(value))
    end

    vs.options.save = vs.options.save or true -- have true as default -- should change this to the other thing..?

    vs:set(value)

    return vs
end

function VarSpecs:inspectorElement()
    print("missing, varSpec")
end

function VarSpecs:len()
    return #self.value
end
function VarSpecs:__len()
    return self:len()
end

function VarSpecs:get()
    return self.value
end

function VarSpecs:set(v)
    self.value = v
end

function VarSpecs:toSaveValue()
    return self.value
end

function VarSpecs:fromSaveValue(v)
    self:set(v)
end

return VarSpecs