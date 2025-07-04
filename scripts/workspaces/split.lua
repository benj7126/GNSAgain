local Workspace = require("workspaces.workspace")
local Selection = require("workspaces.selection")
local Button = require("elements.button")
local Condition = require("elements.condition")
local Split = Workspace:new()
RegisterClass(Split, "W-Split")

function Split:new(workspace)
    local split = Workspace.new(Split)

    split.workspaces = {workspace or Selection:new(Split)}
    split.horizontal = nil
    split.splits = {}
    split.dragging = -1

    split.sidesButtons = {
        Button:new(), -- top
        Button:new(), -- bot
        Button:new(), -- left
        Button:new() -- right
    }

    split.elements = {
        Condition:new(false, split.sidesButtons[1]),
        Condition:new(false, split.sidesButtons[2]), 
        Condition:new(false, split.sidesButtons[3]),
        Condition:new(false, split.sidesButtons[4])
    }

    split.splitButtons = {}

    for i = 1, 4 do
        table.remove(split.sidesButtons[i].elements, 2)
    end

    for i = 1, 2 do
        split.elements[i].es.height.percent = 0
        split.elements[i].es.height.pixels = 20
        split.elements[i].es.width.percent = 0.5
    end
    for i = 3, 4 do
        split.elements[i].es.width.percent = 0
        split.elements[i].es.width.pixels = 20
        split.elements[i].es.height.percent = 0.5
    end

    split.elements[1].es.hAlign = 0.5
    split.elements[2].es.hAlign = 0.5
    split.elements[2].es.vAlign = 1

    split.elements[3].es.vAlign = 0.5
    split.elements[4].es.vAlign = 0.5
    split.elements[4].es.hAlign = 1

    split:setupRefs()

    return split
end

function getVertDrag(self)
    return function(_, button, _)
        if self.dragging > 0 and button == 0 then
            self.splits[self.dragging] = self:limitValue((rl.mouse.getMousePosition().Y - self.sizes[2]) / self.sizes[4])
            self:_resize()

            -- remove on release if size is too small(?)
        end
    end
end

function getHoriDrag(self)
    return function(_, button, _)
        if self.dragging > 0 and button == 0 then
            self.splits[self.dragging] = self:limitValue((rl.mouse.getMousePosition().X - self.sizes[1]) / self.sizes[3])
            self:_resize()

            -- remove on release if size is too small(?)
        end
    end
end

function Split:newSplit(atEnd)
    if atEnd then
        table.insert(self.splits, 1)
    else
        table.insert(self.splits, 1, 0)
    end

    local nButton = Button:new()
    local nCondition = Condition:new(false, nButton)
    nCondition.cond = function () return rl.isCtrlDown() end

    table.remove(nButton.elements, 2)
    
    if self.horizontal then
        nCondition.es.width.percent = 0
        nCondition.es.width.pixels = 10
        nCondition.es.left.pixels = -5;
        nCondition.es.height.percent = 0.5
        
        nCondition.es.vAlign = 0.5

        nButton.drag = getHoriDrag(self)
    else
        nCondition.es.height.percent = 0
        nCondition.es.height.pixels = 10
        nCondition.es.top.pixels = -5;
        nCondition.es.width.percent = 0.5
        
        nCondition.es.hAlign = 0.5

        nButton.drag = getVertDrag(self)
    end

    table.insert(self.splitButtons, nButton)
    table.insert(self.elements, nCondition)

    local nTable = Split:new()
    nTable.horizontal = not self.horizontal

    if #self.workspaces == 1 then
        self.workspaces[1] = Split:new(self.workspaces[1])
        self.workspaces[1].horizontal = not self.horizontal
    end

    if atEnd then
        table.insert(self.workspaces, nTable)
        self.dragging = #self.splits
    else
        table.insert(self.workspaces, 1, nTable)
        self.dragging = 1
    end
end

function Split:addPress(idx, hori, atEnd)
    self.sidesButtons[idx].press = function (_, button)
        if button == 0 then
            self.horizontal = hori

            self:newSplit(atEnd)

            self:_resize()
        end
    end
    self.sidesButtons[idx].release = function () self.dragging = -1 end
end

function Split:limitValue(v)
    local below = 0
    local above = 1

    if self.splits[self.dragging-1] then
        below = self.splits[self.dragging-1]
    end
    if self.splits[self.dragging+1] then
        above = self.splits[self.dragging+1]
    end

    return math.min(math.max(v, below), above)
end

function Split:setupRefs()
    self:addPress(1, false, false)
    self:addPress(2, false, true)

    self:addPress(3, true, false)
    self:addPress(4, true, true)

    for i = 1, 2 do
        self.sidesButtons[i].drag = getVertDrag(self)

        self.elements[i].cond = function ()
            return rl.isCtrlDown() and (self.horizontal == false or self.horizontal == nil)
        end
    end
    for i = 3, 4 do
        self.sidesButtons[i].drag = getHoriDrag(self)

        self.elements[i].cond = function ()
            return rl.isCtrlDown() and (self.horizontal == true or self.horizontal == nil)
        end
    end
end

function Split:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    local lastV = 0
    if self.horizontal == nil then
        self.workspaces[1]:resize(x, y, w, h)
    else
        for i = 1, #self.workspaces - 1 do
            local workspace = self.workspaces[i]
            local thisV = self.splits[i]
            local vDiff = thisV - lastV

            if self.horizontal then
                workspace:resize(x + w * lastV, y, w * vDiff, h)

                self.elements[i+4].es.left.percent = thisV
            else
                workspace:resize(x, y + h * lastV, w, h * vDiff)

                self.elements[i+4].es.top.percent = thisV
            end

            lastV = thisV
        end
    end
    local lastWorkspace = self.workspaces[#self.workspaces]
    if self.horizontal then
        lastWorkspace:resize(x + w * lastV, y, w * (1 - lastV), h)
    else
        lastWorkspace:resize(x, y + h * lastV, w, h * (1 - lastV))
    end

    for _, elm in pairs(self.elements) do
        elm:resize(x, y, w, h)
    end
end

function Split:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])

    for _, workspace in pairs(self.workspaces) do
        workspace:draw()
    end

    for _, elm in pairs(self.elements) do
        elm:draw()
    end

    scissor.exit()
end

function Split:update()
    for _, workspace in pairs(self.workspaces) do
        workspace:update()
    end
end

function Split:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    
    for _, workspace in pairs(self.workspaces) do
        local sizes = workspace.sizes
        if WithingBox(sizes[1], sizes[2], sizes[3], sizes[4], event.pos) then
            workspace:propagateEvent(event)
            return
        end
    end
end

function Split:handleEvent(event)
    for i, elm in pairs(self.elements) do
        if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
            elm:propagateEvent(event)
            return true
        end
    end
end

--[[
function Split:dropInto(x, y, workspace)
    table.insert(self.workspaces, workspace) -- for now
end]]

return Split