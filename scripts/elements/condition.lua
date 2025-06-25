local Element = require("elements.element")
local Condition = Element:from()
RegisterClass(Condition, "Condition")
local VarSpec = require("varSpec")

function Condition:new(forLoad, elm)
    local cond = Element.new(Condition, forLoad)

    cond.draw = nil

    if not forLoad then
        cond.includeUpdate = false
        cond.cond = function (self) -- how do i even save this :/ - should it be module-based..? Maby module and custom code - when i get to that; later.
            return true
        end

        cond.elements.containing = elm or Element:new() -- could this be a varspec? - instead of in elements like this; though maby dosent matter?
    end
    
    return cond
end

function Condition:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)
    self.elements.containing:resize(self.es.x, self.es.y, self.es.w, self.es.h)
end

function Condition:draw()
    if self:cond() then
        self.elements.containing:draw()
    end
end

function Condition:update()
    if self.includeUpdate and self:cond() then
        self.elements.containing:update()
    end
end

function Condition:propagateEvent(event)
    event:passed(self)

    if self:cond() and WithingBox(self.elements.containing.es.x, self.elements.containing.es.y, self.elements.containing.es.w, self.elements.containing.es.h, event.pos) then
        self.elements.containing:propagateEvent(event)
        return
    end
end

return Condition