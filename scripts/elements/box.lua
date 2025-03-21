local Element = require("elements.element")
local Box = Element:from()

function Box:new(workspace)
    local b = Element.new(Box)

    b.color = rl.color(255, 255, 0)

    return b
end

function Box:draw()
    rl.rec(self.es.x, self.es.y, self.es.w, self.es.h, self.color)
end

return Box