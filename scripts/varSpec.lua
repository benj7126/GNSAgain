local VarSpecs = {}

-- could have custom saving option
-- so that it used that to save the value
-- could be used for multiple things
-- fix if the thing in value is a
-- workspace id and we use that as some
-- ref nonsense.

function VarSpecs:new(value, options)
    local es = {}
    setmetatable(es, self)
    self.__index = self

    es.value = value
    es.options = options or {}

    es.options.save = es.options.save or true -- have true as default

    return es
end

return VarSpecs