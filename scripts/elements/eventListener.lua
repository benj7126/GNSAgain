local Element = require("element")
local EventListener = Element:new()

function EventListener:new(workspace)
    local b = Element.new(EventListener)

    return b
end

function EventListener:draw()
end

return EventListener