-- should have a global 'object selected'?
-- or maby each inspector should have an inspector identifier and then a global table where you set the elements of all insepctors..?

-- ^^ just like the inspector (but inspector only interacts with single elements while this displays all sub-elements of an element - so different lists)


local Element = require("elements.element")
local TraversableTree = require("elements.traversableTree")
local Box = require("elements.box")
local ObjectTree = Element:from()
RegisterClass(ObjectTree, "Inspector")

Inspector = require("elements.inspector")

ObjectTree.objectSelection = {} -- could add metatable that calls 'subscribed functions'
ObjectTree.hooks = {}

ObjectTree.setObject = function (object, id)
    ObjectTree.objectSelection[id] = object

    if ObjectTree.hooks[id] then
        for obj, _ in pairs(ObjectTree.hooks[id]) do
            if obj ~= "count" then
                obj:regenTree()
            end
        end
    end
end

function ObjectTree:new(forLoad)
    local i = Element.new(ObjectTree, forLoad)

    i.objectID = nil
    i:setID(getUUID())

    i.elements["tree"] = TraversableTree:new()

    if not forLoad then
        local box = Box:new()
        box.es.width.percent = 1
        box.es.height.percent = 1
        -- i.elements["bg"] = box
    end

    return i
end

function ObjectTree:setID(id)
    if self.objectID then
        ObjectTree.hooks[self.objectID].count = ObjectTree.hooks[self.objectID].count - 1
        ObjectTree.hooks[self.objectID][self] = nil

        if ObjectTree.hooks[self.objectID].count == 0 then
            ObjectTree.hooks[self.objectID] = nil
        end
    end

    self.objectID = id

    if not ObjectTree.hooks[self.objectID] then
        ObjectTree.hooks[self.objectID] = {count = 0}
    end

    ObjectTree.hooks[self.objectID].count = ObjectTree.hooks[self.objectID].count + 1
    ObjectTree.hooks[self.objectID][self] = true
end

local function sortfunction (a, b)
    local a_val, b_val = a[1], b[1]

    if type(a_val) == type(b_val) then
        return a_val < b_val
    elseif type(a_val) == 'number' and type(b_val) == 'string' then
        return true
    else
        return false
    end
end

local function getObjectChildren(object, objectID)
    local retList = {false, object}
    local nameList = {}

    if object.elements then
        local sorted = {}
        for i, v in pairs(object.elements) do
            table.insert(sorted, {i, v})
        end

        table.sort(sorted, sortfunction)

        for _, v in pairs(sorted) do
            print(v[2], " - -")
            table.insert(retList, v[2])
        end
    end

    if object.workspaces then
        local sorted = {}
        for i, v in pairs(object.workspaces) do
            table.insert(sorted, {i, v})
        end

        table.sort(sorted, sortfunction)

        for _, v in pairs(sorted) do
            table.insert(retList, v[2])
        end
    end

    for i = 2, #retList do
        local v = retList[i]
        if v ~= object and ((v.elements and next(v.elements)) or (v.workspaces and next(v.workspaces))) then
            retList[i], nameList[i] = getObjectChildren(v)
        else
            retList[i] = function ()
                Inspector.setObject(v, objectID)
            end

            local name = v.name or ""
            if name == "" then name = GetClassName(getmetatable(v)) end

            nameList[i] = name
        end
    end

    return retList, nameList
end

function ObjectTree:getBranches()
    if not ObjectTree.objectSelection[self.objectID] then
        return {}
    end

    return getObjectChildren(ObjectTree.objectSelection[self.objectID], self.objectID)
end

function ObjectTree:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)

    self:regenTree()
end


function ObjectTree:regenTree()
    self.elements["tree"].contents, self.elements["tree"].names = self:getBranches()
    for _, elm in pairs(self.elements) do elm:resize(self.es.x, self.es.y, self.es.w, self.es.h) end
end

return ObjectTree