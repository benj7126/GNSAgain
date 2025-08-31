local Element = require("elements.element")
local FreeContainer = Element:from()
RegisterClass(FreeContainer, "FreeContainer")

function FreeContainer:resize(x, y, w, h)
    self.es.x = x + self.es.left.pixels
    self.es.y = y + self.es.top.pixels
    self.es.w = 0
    self.es.h = 0

    for _, elm in pairs(self.elements) do
        elm:resize(self.es.x, self.es.y, w, h)
        self.es.w = math.max(self.es.w, elm.es.x + elm.es.w - self.es.x)
        self.es.h = math.max(self.es.h, elm.es.y + elm.es.h - self.es.y)
    end

    print("container")
    print(self.es.x, self.es.y, self.es.w, self.es.h)
end

return FreeContainer