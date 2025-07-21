local Element = require("elements.element")
local List = require("elements.list")
local Button = require("elements.button")
local TraversableTree = Element:from()
RegisterClass(TraversableTree, "TraversableTree")
local VarSpec = require("varSpec")

function TraversableTree:new(forLoad)
    local tree = Element.new(TraversableTree, forLoad) -- dont save element.list somehow?

    tree.sortFunc = nil -- needs to be code
    tree.contents = {}
    tree.offset = 20
    tree.spacing = 2

    tree.lastSizes = {0, 0, 0, 0}

    return tree
end

function TraversableTree:updateList()
    -- should probably have a way to insert and add instead of self.contents so i dont have to re-make the whole thing each time
    -- but this is a temporary solution like many others.

    local list = self:getListOf(self.contents, 0)
    self.elements.list = list
    
    if self.elements.list then self.elements.list:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

function TraversableTree:getCollapseButton(items, offset)
    local button = Button:new()

    local str = items[1]

    if str:sub(1,1) == "_" then -- add another label that holds 'v' and '>'? maby think of other characters?
        button.elements[2].text = "< "..str:sub(2, #str)
    else
        button.elements[2].text = "> "..str
    end

    button.es.width.percent = 0
    button.es.width.pixels = self.es.w - offset
    button.es.height.percent = 0
    button.es.height.pixels = 16
    button.elements[2].fontSize = 16
    
    button.elements[2].xCenter = false
    button.elements[2].es.left.pixels = 2

    button.listOffsetX = offset - self.offset

    button.click = function (_, button)
        if button == 0 then
            if items[1]:sub(1, 1) == "_" then
                items[1] = items[1]:sub(2, #items[1])
            else
                items[1] = "_"..items[1]
            end
            
            self:resize(self.parentSizes[1], self.parentSizes[2], self.parentSizes[3], self.parentSizes[4])
        end
    end

    return button
end

function TraversableTree:getListOf(items, offset)
    local list = List:new()
    list.adjustToHeight = true
    list.allowCustomW = true
    list.ySpacing = self.spacing

    local header;
    local hasHeader = 1
    if items[1] and type(items[1]) == "string" then
        hasHeader = 2
        header = self:getCollapseButton(items, offset)

        if items[1]:sub(1, 1) == "_" then
            return nil, header
        end
    end

    for i = hasHeader, #items do
        local obj = items[i]
        if getmetatable(obj) == nil then -- if no metatable; then its not an element
            local subList, subHeader = self:getListOf(obj, offset + self.offset)
            if subHeader then table.insert(list.elements, subHeader) end
            if subList then table.insert(list.elements, subList) end
        else
            obj.listOffsetX = offset
            table.insert(list.elements, obj)
        end
    end

    if self.sortFunc then
        table.sort(list.elements, self.sortFunc)
    end

    return list, header
end

function TraversableTree:resize(x, y, w, h)
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