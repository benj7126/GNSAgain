local Element = require("elements.element")
local Box = require("elements.box")
local Label = require("elements.label")
local Button = Element:from()
RegisterClass(Button, "Button")

-- maby no base elements should add elements to its elements list..?

function Button:new(forLoad)
    local b = Element.new(Button, forLoad)

    b.pressed = {false, false, false}

    -- should i have a border?
    -- color change when hovering?
        -- modules with variables
            -- add color (-x on r, g and b)
            -- set color (set color to given color when hovering)

    if not forLoad then
        local box = Box:new()
        box.es.width.percent = 1
        box.es.height.percent = 1
        -- b.elements.bg = box
        table.insert(b.elements, box) -- sadly need it to be ordered

        local label = Label:new() -- need a way to center text.
        label.es.width.percent = 1
        label.es.height.percent = 1

        label.xCenter = true
        label.yCenter = true
        label.wrapping = 2 -- no wrapping
        label.text = "click me" -- should have something that could tell me how big this is
                                -- or something that makes the box match the size automatically. 
        -- b.elements.label = label
        table.insert(b.elements, label) -- might want some way to force order on named things...
    end

    return b
end

function Button:press(button)
    -- run some function of the code that i dont have yet, ig.
end

function Button:release(button)
    -- run some function of the code that i dont have yet, ig.
end

function Button:click(button)
    -- run some function of the code that i dont have yet, ig.
end

function Button:drag(button)
    -- run some function of the code that i dont have yet, ig.
end

function Button:handleEvent(event)
    if event.type == "mousepress" then
        self:press(event.button)

        self.pressed[event.button] = true
        
        PostNextEvent("mouserelease", function(nEvent)
            if event.button == nEvent.button then
                self.pressed[event.button] = false
                return true -- remove from list
            end

            return false -- keep it, was not the same button.
        end)
        
        PostNextEvent("*", function(nEvent)
            if nEvent.type == "mouserelease" then
                return true -- remove from list
            end

            self:drag(event.button)

            return false -- keep it
        end)

        return true
    elseif event.type == "mouserelease" then
        self:release(event.button)
        if self.pressed[event.button] then -- pressed automatically set to false from PostNextEvent above
            self:click(event.button)
        end
    end
    return false
end

return Button