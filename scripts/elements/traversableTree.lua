local Element = require("elements.element")
local List = require("elements.list")
local Button = require("elements.button")
local FreeContainer = require("elements.freeContainer")
local TraversableTree = Element:from()
RegisterClass(TraversableTree, "TraversableTree")
local VarSpec = require("varSpec")

function TraversableTree:new(forLoad)
    local tree = Element.new(TraversableTree, forLoad) -- dont save element.list somehow?

    tree.sortFunc = nil -- needs to be code
    tree.contents = {}
    self.names = {}
    tree.offset = 16
    tree.spacing = 2

    tree.lastSizes = {0, 0, 0, 0}

    return tree
end

local function deepPrint(object, depth)
    for i = 1, #object do
        if type(object[i]) == "table" then
            if getmetatable(object[i]) == nil then
                deepPrint(object[i], depth.."-")
            else
                print(depth, object[i])
            end
        else
            print(depth, object[i])
        end
    end
end

function TraversableTree:updateList()
    -- should probably have a way to insert and add instead of self.contents so i dont have to re-make the whole thing each time
    -- but this is a temporary solution like many others.

    print("update - list")
    deepPrint(self.contents, "")
    local list = self:getListOf(self.contents, 0, self.names)
    self.elements.list = list

    if self.elements.list then self.elements.list:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

function TraversableTree:getCollapseButton(inputList, offset)
    local button = Button:new()

    if inputList[1] == true then
        button.elements[2].text = "<"
    else
        button.elements[2].text = ">"
    end

    button.es.width.percent = 0
    button.es.width.pixels = 16
    button.es.height.percent = 0
    button.es.height.pixels = 16
    button.elements[2].fontSize = 16
    
    button.elements[2].xCenter = false
    button.elements[2].es.left.pixels = 2

    button.listOffsetX = offset - self.offset

    button.click = function (_, button)
        if button == 0 then
            inputList[1] = not inputList[1] -- flip it

            self:resize(self.parentSizes[1], self.parentSizes[2], self.parentSizes[3], self.parentSizes[4])
        end
    end

    return button
end

function TraversableTree:getFunctionButton(string, func, offset)
    local button = Button:new()

    button.elements[2].text = string

    button.elements[2]:prepare()

    button.es.width.percent = 0
    button.es.width.pixels = button.elements[2].textWidth
    button.es.height.percent = 0
    button.es.height.pixels = 16
    button.elements[2].fontSize = 16
    
    button.elements[2].xCenter = false
    button.elements[2].es.left.pixels = 2

    button.listOffsetX = offset - self.offset

    button.click = function (_, button)
        if button == 0 then
            func()
        end
    end

    return button
end

function TraversableTree:getListOf(inputList, offset, names)
    names = names or {}

    local items = {}
    for i = 1, #inputList do
        if type(inputList[i]) == "function" then
            local name = "func - " .. i
            if names[i] then name = names[i] end

            table.insert(items, self:getFunctionButton(name, inputList[i], offset))
        else
            table.insert(items, inputList[i])
        end
    end

    if #items <= 1 then return nil end

    local list = List:new()
    list.adjustToHeight = true
    list.allowCustomW = true
    list.ySpacing = self.spacing
    
    local header = self:getCollapseButton(inputList, offset)

    local collected = FreeContainer:new()
    collected.listOffsetX = offset
    collected.elements = {header, items[2]}
    items[2].es.left.pixels = 16

    if items[1] == false then -- if it is collapsed
        return collected
    end

    table.insert(list.elements, collected)
    offset = offset + self.offset

    for i = 3, #items do
        local _names = {}
        if names[i] then _names = names[i] end

        local obj = items[i]
        if getmetatable(obj) == nil then -- if no metatable; then its not an element
            local subObject = self:getListOf(obj, offset, _names)
            if subObject then table.insert(list.elements, subObject) end
        else
            obj.listOffsetX = offset
            table.insert(list.elements, obj)
        end
    end

    if self.sortFunc then
        table.sort(list.elements, self.sortFunc)
    end

    return list
end

function TraversableTree:resize(x, y, w, h)
    print(x, y, w, h)
    self.parentSizes = {x, y, w, h}
    self.es:recalculate(x, y, w, h)

    self:updateList()
end

return TraversableTree

--[[ use example
local TraversableTree = require("elements.traversableTree")
local Button = require("elements.button")
topWorkspace = require("workspaces.elements"):new()
local tree = TraversableTree:new()
tree.es.width.percent = 0.3

local b1 = Button:new()
local b2 = Button:new()
local b3 = Button:new()
local b4 = Button:new()
local b5 = Button:new()
local b6 = Button:new()
local bs = {b1, b2, b3, b4, b5, b6}

for i, v in ipairs(bs) do
    v.es.width.percent = 0
    v.es.height.percent = 0
    v.es.height.pixels = 16
    v.elements[2].fontSize = 16

    v.click = function () print("Pressed the "..i.."'th *click me*") end

    v.elements[2]:prepare()
    v.es.width.pixels = v.elements[2].textWidth + 10
end
b2.es.width.pixels = 60
b2.es.height.pixels = 60

b4.es.width.pixels = 200
b4.es.height.pixels = 200

b5.es.width.pixels = 120
b5.es.height.pixels = 30

tree.contents = {b1, b2, b3, {"elms", b4, {"ghmmm", b5}, b6}}
]]--