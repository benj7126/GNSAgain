local Element = require("elements.element")
local NoteWrapper = Element:from()
RegisterClass(NoteWrapper, "NoteWrapper")
local VarSpec = require("varSpec")

local alottedSize = 0 -- how much percent dose to this; idk if it should do any... should it? it probably should in same (or maby most cases..? - like for trello thing and others like it.)

function NoteWrapper:new(forLoad, elmID, x, y) -- tmp, would like some other way to decide on this.
    local nw = Element.new(NoteWrapper, forLoad)

    nw.elements.containing = elm or Element:new()
    nw.elements.containing.parent = nw

    elm = nw.elements.containing

    if not forLoad then
        nw.size = {
            w=elm.prefW or (elm.es.width.pixels + elm.es.width.percent * alottedSize), -- do something like this for textbox and then scale to fit width..?
            h=elm.prefH or (elm.es.height.pixels + elm.es.height.percent * alottedSize)
        }
        nw.pos = {x=(x - nw.size.w/2) or 0,  y=(y - nw.size.h/2) or 0}
        
        nw.es = {}
    end

    setmetatable(nw.es, {
        __index = function (_, k)
            if k == "x" then return nw.pos.x end
            if k == "y" then return nw.pos.y end
            if k == "w" then return nw.size.w end
            if k == "h" then return nw.size.h end
        end,
        __newindex = function (_, k, v)
            if k == "x" then nw.pos.x = v end
            if k == "y" then nw.pos.y = v end
            if k == "w" then nw.size.w = v end
            if k == "h" then nw.size.h = v end
        end
    })

    nw.elements.containing:resize(nw.es.x, nw.es.y, nw.es.w, nw.es.h)

    return nw
end

function NoteWrapper:resize(x, y, w, h) self.elements.containing:resize(self.es.x, self.es.y, self.es.w, self.es.h) end

function NoteWrapper:draw() end

function NoteWrapper:update() end

function NoteWrapper:propagateEvent(event)
    local elm = self.elements.containing
    if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
        elm:propagateEvent(event)
    end
end

return NoteWrapper