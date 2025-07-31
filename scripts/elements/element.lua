-- should be in elements as it is an "empty" element
-- potentially for events..?

local StyleDimension = {}

StyleDimension.saveAll = true -- tmp solution
function StyleDimension:new(p)
    local sd = {}
    setmetatable(sd, self)
    self.__index = self
    
    sd.pixels, sd.percent = 0, p
    
    return sd
end

function StyleDimension:getValue(containerSize)
    return self.pixels + (self.percent * containerSize);
end

local ElementStyle = {}

ElementStyle.saveAll = true -- tmp solution | should probably be a ElementStyle VarSpec type.
function ElementStyle:saveRules(rules) -- this is not used any more; have to make it be reflected in varSpec ^^
    rules["left"] = 0
    rules["top"] = 0
    rules["width"] = 0
    rules["height"] = 0
    
    rules["vAlign"] = 0
    rules["hAlign"] = 0
end

function ElementStyle:new()
    local es = {}
    setmetatable(es, self)
    self.__index = self

    es.left = StyleDimension:new(0.0)
    es.top = StyleDimension:new(0.0)

    es.width = StyleDimension:new(1.0)
    es.height = StyleDimension:new(1.0)

    es.x, es.y, es.w, es.h = 0, 0, 0, 0

    es.vAlign, es.hAlign = 0, 0

    return es
end

function ElementStyle:recalculate(x, y, w, h)
    self.x = x + self.left:getValue(w)
    self.y = y + self.top:getValue(h)

    self.w = self.width:getValue(w)
    self.h = self.height:getValue(h)

    -- think this is how it's supposed to work...
    self.x = self.x + (w - self.w) * self.hAlign
    self.y = self.y + (h - self.h) * self.vAlign
end

function ElementStyle:contains(x, y)
    if (x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h) then
        return true
    else
        return false
    end
end

local VarSpecMT = require("varSpecMT")

local Element = {}
Element.__index = Element
RegisterClass(Element, "Element")
VarSpecMT(Element) -- applies to element(this)

function Element:from() --          i do 'from' because i dont want to override
    local newMT = {}  --          any methods "subclassing"
    setmetatable(newMT, self) --  would also be a waste to add the variables to a class, no?

    VarSpecMT(newMT) -- applies to all sub-elements, only once and not on creation.
    return newMT
end

local VarSpec = require("varSpec")

local id = 0
function Element:new(forLoad) -- tmp solution?
    local element = {}
    setmetatable(element, self)

    -- intergrate 'VarSpecs' into __index and __newindex

    element.es = ElementStyle:new() -- when i get the time; make it -> VarSpec:new(ElementStyle:new())
    element.elements = {}
    element.parent = nil

    element.id = id -- element id test thing
    id = id + 1

    element.draw = require("modules.draw.defaultDraw") -- when making an inspector there should be and element that
                                                       -- lets you add a bunch of functions and switch between them

                                                       -- while im at it, it would also be neat to have it so that i
                                                       -- can just specify the location and it would load everything
                                                       -- there; then they would return the function and its 'name'

    -- loads a shit; things from here \/
    -- https://github.com/benj7126/GNSUsingCS/blob/master/Element.cs

    -- should somehow have code in this shit :/
    -- it should somehow be a string that i can load into an element so that i can edit it in the program
    -- some thougths on code https://discord.com/channels/@me/768734775913086977/1351935935545217054

    -- apply a wrapper for pre and post calls and other relevant things - if i think of any
    -- might make stuff slower but we will see... (it would be quite convinient though)
    -- could be used for error messages, maby?

    return element
end

function Element:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)
    for _, elm in pairs(self.elements) do elm:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

function Element:placeInto(parent, subVar, index)
    self.parent = parent

    subVar = subVar or "elements"
    
    if index then
        parent[subVar][index] = self
    else
        table.insert(parent[subVar], self)
    end
end

function Element:draw() end

function Element:update() end

function Element:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    local elmLoop = {}
    for _, elm in pairs(self.elements) do table.insert(elmLoop, elm) end

    for i = #elmLoop, 1, -1 do
        local elm = elmLoop[i]
        if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
            elm:propagateEvent(event, i)
            return
        end
    end
end

function Element:handleEvent(event) return false end -- didnt "consume" the event -> dont want to block

return Element