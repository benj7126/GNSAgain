local Element = require("elements.element")
local Box = require("elements.box")
local Label = require("elements.label")
local Button = Element:from()
RegisterClass(Button, "Button")

function Button:new(forLoad)
    local b = Element.new(Button, forLoad)

    b.pressed = {false, false, false}

    if not forLoad then
        local box = Box:new()
        box.es.width.percent = 1
        box.es.height.percent = 1
        table.insert(b.elements, box)

        local label = Label:new()
        label.es.width.percent = 1
        label.es.height.percent = 1

        label.wrapping = 2 -- no wrapping
        label.text = "click me" -- should have something that could tell me how big this is
                                -- or something that makes the box match the size automatically. 
        table.insert(b.elements, label)
    end

    return b
end

function Button:handleEvent(event)
    if event.type == "mousepress" then
        self.pressed[event.button] = true
        
        PostNextEvent("mouserelease", function(nEvent)
            if event.button == nEvent.button then
                self.pressed[event.button] = false
                return true -- remove from list
            end

            return false -- keep it, was not the same button.
        end)

        return true
    elseif event.type == "mouserelease" then
        if self.pressed[event.button] then -- pressed automatically set to false from PostNextEvent above
            print("button pressed with; " .. event.button)
        end
    end
    return false
end

return Button