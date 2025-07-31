-- bad name but what can you do?
local Element = require("elements.element")
local InstanceDisplayer = Element:from()
RegisterClass(InstanceDisplayer, "InstanceDisplayer")
local VarSpec = require("varSpec")

InstanceDisplayer.Elements = {}

--[[targetWidth & targetHeight; number for a target value - nil for indefinite
]]
function InstanceDisplayer.AddInstance(id, element, targetWidth, targetHeight)
    element:resize(0, 0, targetWidth or math.maxinteger, targetHeight or math.maxinteger)

    InstanceDisplayer.Elements[id] = element
end

function InstanceDisplayer:new(forLoad, displayID)
    local idspl = Element.new(InstanceDisplayer, forLoad)

    idspl.draw = nil

    idspl.elements = nil

    idspl.displayElement = VarSpec:new(displayID or "")

    return idspl
end

function InstanceDisplayer:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)
end

function InstanceDisplayer:draw()
    local elm = InstanceDisplayer.Elements[self.displayElement]
    if elm then
        rl.camera.set(-self.es.x, -self.es.y)
        elm:draw()
        rl.camera.reset()
    end
end

function InstanceDisplayer:update()
    local elm = InstanceDisplayer.Elements[self.displayElement]
    if elm then
        elm:update()
    end
end

function InstanceDisplayer:propagateEvent(event)
    event:passed(self)

    event.pos = vec(event.pos.X - self.es.x, event.pos.Y - self.es.y)

    local elm = InstanceDisplayer.Elements[self.displayElement]
    if elm then
        elm:propagateEvent(event)
    end
end

return InstanceDisplayer