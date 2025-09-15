local Element = require("elements.element")
local Button = require("elements.button")
local ToolboxItem = Button:from()

local NoteWrapper = require("elements.noteWrapper")

RegisterClass(ToolboxItem, "ToolboxItem")
local VarSpec = require("varSpec")

function ToolboxItem:new(forLoad)
    local tbi = Element.new(ToolboxItem, forLoad)

    tbi.pressed = {false, false, false} -- should i have some sort of method that adds all variables; and then call that in new and make it work like that...?

    local test = Button:new()
    test.es.width.pixels = 80
    test.es.height.pixels = 40
    
    test.es.width.percent = 0
    test.es.height.percent = 0

    test.press = function ()
        print("You pressed a placed button; yay!")
    end
    
    tbi.src = {} -- make this be saved. VarSpec?
    tbi.paths = {}

    tbi.elm = nil

    tbi:saveObject(test)

    return tbi
end

function ToolboxItem:dropInto(workspace, event)
    table.insert(workspace.elements, NoteWrapper:new(false, self:loadObject(), event.pos.X, event.pos.Y))
end

function ToolboxItem:draw()
    if self.elm then self.elm:draw() end
end

function ToolboxItem:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)

    w = math.min(w, 100)
    h = math.min(h, 100)

    if not self.elm then self.elm = self:loadObject() end
    self.elm:resize(self.es.x, self.es.y, w, h)

    self.es.x = self.elm.es.x
    self.es.y = self.elm.es.y
    self.es.w = self.elm.es.w
    self.es.h = self.elm.es.h
end

function ToolboxItem:saveObject(object)
    self.src = {}
    self.paths = {}

    self:writeString("src", CreateStringFromObject(object, self))
    
    print(GetClassName(getmetatable(object)), "fa")
    print(GetClassName(getmetatable(object.es)), "fa")
    self.elm = self:loadObject()
    print(GetClassName(getmetatable(self.elm)), "fa")
    print(GetClassName(getmetatable(self.elm.es)), "fa")

    print(self)
    print(self.elm)
    print(self.elm.es)
    print(self.elm.es.recalculate)
    print(self.elm.resize)

    self.elm:resize(self.es.x, self.es.y, self.es.w, self.es.h)
end

function ToolboxItem:loadObject()
    self.paths = {}

    return CreateObjectFromAMI(self)
end

function ToolboxItem:fullPath()
    local path = self.src

    for _, v in pairs(self.paths) do
        if not path[v] then
            path[v] = {}
        end

        path = path[v]
    end

    return path
end

function ToolboxItem:enter(path)
    table.insert(self.paths, path)
end

function ToolboxItem:writeString(thisPath, string)
    local path = self:fullPath()

    path[thisPath] = string
end

function ToolboxItem:readString(thisPath)
    local path = self:fullPath()

    return path[thisPath]
end

function ToolboxItem:exit()
    table.remove(self.paths, #self.paths)
end

function ToolboxItem:press(button)
    if button == 0 then
        SetHeldItem(self)
    end
end

function ToolboxItem:anyRelease(button)
    if button == 0 and self == GetHeldItem() then
        ClearHeldItem()
    end
end

return ToolboxItem