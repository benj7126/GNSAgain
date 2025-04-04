local Box = require("elements.box")
local List= require("elements.list")
local Button = require("elements.button")
local Selection = {}
RegisterClass(Selection, "W-Selection")

function Selection:new()
    local sel = {}
    setmetatable(sel, self)
    self.__index = self
    
    sel.sizes = {0, 0, 0, 0}
    sel.select = function (newWorkspace)
        sel.select = nil
        sel.selector = nil
        setmetatable(sel, getmetatable(newWorkspace))

        local sizes = sel.sizes
        sel.sizes = nil

        for i, v in pairs(newWorkspace) do
            sel[i] = v
        end

        sel:resize(sizes[1], sizes[2], sizes[3], sizes[4])
    end

    sel.selector = Box:new()
    sel.selector.color = rl.color(100, 100, 100)
    --sel.selector.draw = require("modules.draw.reverseDraw") -- want to make this a VarSpec at some point
    
    sel.selector.es.width.pixels = -20
    sel.selector.es.height.pixels = -20
    
    sel.selector.es.vAlign = 0.5
    sel.selector.es.hAlign = 0.5

    local list = List:new()
    for name, mt in pairs(GetClasses()) do
        if name:sub(1, 2) == "W-" then
            local button = Button:new()
            button.elements[2].text = name:sub(3, #name)

            button.es.height.pixels = 24
            
            button.press = function (_, button)
                if button == 0 then
                    sel.select(mt:new())
                end
            end

            table.insert(list.elements, button)
        end
    end

    sel.selector.elements.list = list

    return sel
end

function Selection:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    self.selector.elements.list.cols = math.floor(w / 200)
    self.selector:resize(x, y, w, h)
end

function Selection:draw()
    self.selector:draw()
end

function Selection:update()
    self.selector:update()
end

function Selection:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    self.selector:propagateEvent(event)
end

function Selection:handleEvent(event) return false end

return Selection