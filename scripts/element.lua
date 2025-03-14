local StyleDimension = {}

function StyleDimension:new()
    local sd = {}
    setmetatable(sd, self)
    self.__index = self
    
    sd.pixels, sd.percent = 0, 0.0

    return sd
end

function StyleDimension:getValue(containerSize)
    return self.pixels + (self.percent * containerSize);
end

local ElementStyle = {}

function ElementStyle:new()
    local es = {}
    setmetatable(es, self)
    self.__index = self

    es.left = StyleDimension:new()
    es.top = StyleDimension:new()

    es.width = StyleDimension:new()
    es.height = StyleDimension:new()

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

local Element = {}

function Element:new()
    local element = {}
    setmetatable(element, self)
    self.__index = self
    
    element.es = ElementStyle:new()
    element.elements = {}

    element.draw = require("modules.draw.defaultDraw") -- when making an inspector there should be and element that
                                                       -- lets you add a bunch of functions and switch between them

                                                       -- while im at it, it would also be neat to have it so that i
                                                       -- can just specify the location and it would load everything
                                                       -- there; then they would return the function and its 'name'

    -- loads a shit; things from here \/
    -- https://github.com/benj7126/GNSUsingCS/blob/master/Element.cs

    -- should somehow have code in this shit :/
    -- it should somehow be a string that i can load into an element so that i can edit it in the program

    return element
end

function Element:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)
    for _, elm in pairs(self.elements) do elm:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

function Element:draw() end

function Element:update() end

return Element