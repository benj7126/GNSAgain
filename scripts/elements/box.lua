local Element = require("elements.element")
local Box = Element:from()
RegisterClass(Box, "Box")
local VarSpec = require("varSpec")

function Box:new(forLoad)
    local b = Element.new(Box, forLoad)

    b.color = VarSpec:new(rl.color(255, 255, 0)) -- i should have color
                                    -- and vec, tbf, be lua tables.
                                    -- cuz easier saving and loading.
                                    -- *less stupid
    
    return b
end

function Box:draw()
    rl.rec(self.es.x, self.es.y, self.es.w, self.es.h, self.color)
end

return Box