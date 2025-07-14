local VarSpecs = {}

VarSpecs.options = {
    ["code"] = require("VarSpecs.code"),
}

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

    for option, v in pairs(vs.options) do
        if VarSpecs.options[option] then
            VarSpecs.options[option](vs, v)
        end
    end

    vs.options.save = vs.options.save or true -- have true as default -- should change this to the other thing..?

    vs:set(value)

    return vs
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

return VarSpecs