-- should have a global 'object selected'?
-- or maby each inspector should have an inspector identifier and then a global table where you set the elements of all insepctors..?

-- this should totally be able to inspect workspaces as well and edit things on the go.


-- if i ever wonder "why not just have them have an id and a function that returns the right one..."
-- then it's because i might want to have two with the save tag at once for some reason and then there can't be only one of them.


local Element = require("elements.element")
local List = require("elements.list")
local Box = require("elements.box")
local Inspector = Element:from()
RegisterClass(Inspector, "Inspector")

Inspector.objectSelection = {} -- could add metatable that calls 'subscribed functions'
Inspector.hooks = {}

Inspector.setObject = function (object, id)
    Inspector.objectSelection[id] = object

    if Inspector.hooks[id] then
        print(Inspector.hooks[id], "a")
        for obj, _ in pairs(Inspector.hooks[id]) do
            if obj ~= "count" then
                obj:regenTree()
            end
        end
    end
end

function Inspector:new(forLoad)
    local i = Element.new(Inspector, forLoad)

    i.objectID = nil
    i:setID(getUUID())

    i.elements["list"] = List:new()
    i.elements["list"].allowCustomW = true

    if not forLoad then
        local box = Box:new()
        box.es.width.percent = 1
        box.es.height.percent = 1
        -- i.elements["bg"] = box
    end

    return i
end

function Inspector:setID(id)
    if self.objectID then
        Inspector.hooks[self.objectID].count = Inspector.hooks[self.objectID].count - 1
        Inspector.hooks[self.objectID][self] = nil

        if Inspector.hooks[self.objectID].count == 0 then
            Inspector.hooks[self.objectID] = nil
        end
    end

    self.objectID = id

    if not Inspector.hooks[self.objectID] then
        Inspector.hooks[self.objectID] = {count = 0}
    end

    Inspector.hooks[self.objectID].count = Inspector.hooks[self.objectID].count + 1
    Inspector.hooks[self.objectID][self] = true
end

local function sortfunction (a, b)
    local a_val, b_val = a._varSpec.index, b._varSpec.index

    return a_val < b_val
end

local varSpec = require("varSpec")
function Inspector:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)

    self:regenTree()
end

function Inspector:regenTree()
    self.elements["list"].elements = {}

    local object = Inspector.objectSelection[self.objectID]
    if not object then return end

    for _, v in pairs(object) do
        if getmetatable(v) == varSpec then
            local inspElm = v:inspectorElement()

            if inspElm then
                table.insert(self.elements["list"].elements, inspElm)
            end
        end
    end

    table.sort(self.elements["list"].elements, sortfunction)

    for _, elm in pairs(self.elements) do elm:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

return Inspector