local Element = require("elements.element")
local Box = Element:from()

function Box:saveRules(rules)
    Element:saveRules(rules)
    rules["color"] = 0
end

function Box:new(forLoad)
    local b = Element.new(Box, forLoad)

    b.color = rl.color(255, 255, 0) -- i should have color
                                    -- and vec, tbf, be lua tables.
                                    -- cuz easier saving and loading.

    RegisterClass(Box, "Box")

    return b
end

function Box:draw()
    rl.rec(self.es.x, self.es.y, self.es.w, self.es.h, self.color)
end

return Box