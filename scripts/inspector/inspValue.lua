local InspValue = {}

function InspValue:new()
    local es = {}
    setmetatable(es, self)
    self.__index = self

    return es
end

function InspValue:genElement() -- idk if this is best approach; returns one element; likely containing multiple elements.

end

return InspValue

-- shouldn't this just be handled by VarSpec?