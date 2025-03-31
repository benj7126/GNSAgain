local VarSpecs

function VarSpecs:new(value, options)
    local es = {}
    setmetatable(es, self)

    return es
end

return VarSpecs