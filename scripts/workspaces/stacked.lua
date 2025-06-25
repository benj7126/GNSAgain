local Workspace = require("workspaces.workspace")
local Selection = require("workspaces.selection")
local List      = require("elements.list")
local Button    = require("elements.button")
local Condition = require("elements.condition")
local Split     = require("workspaces.split")
local Stacked = Workspace:new()
RegisterClass(Stacked, "W-Stacked")

function Stacked:addWorkspace(workspace)
    table.insert(self.workspaces, workspace)
    local button = Button:new()

    button.elements[2].text = GetClassName(getmetatable(workspace)) -- would like to make this editable...
                                                                  -- likely when ctrl is held.

    button.elements[2].fontSize = 24
    button.elements[2]:prepare() -- make it calculate width based on text in it, duh.
    button.es.width.pixels = button.elements[2].textWidth + 10
    button.es.width.percent = 0
    button.elements[2].xCenter = true
    button.elements[2].yCenter = true

    local idx = #self.workspaces
    button.click = function (_, button)
        if button == 0 then
            self.list.elements[self.focused].elements[1].color = rl.color(255, 255, 0)
            self.focused = idx
            self.list.elements[self.focused].elements[1].color = rl.color(255, 100, 0)
            self.workspaces[self.focused]:resize(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
        end
    end

    -- should also allow inserting at position.
    -- option to change to newly inserted workspace??

    table.insert(self.list.elements, math.max(#self.list.elements, 1), button)
    
    self.list.cols = #self.list.elements

    self.list:resize(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
end

function Stacked:new(workspace)
    local stacked = Workspace.new(Stacked)

    stacked.workspaces = {}
    stacked.focused = 1

    local list = List:new()
    list.xSpacing = 0
    list.allowCustomW = true
    list.es.height.percent = 0
    list.es.height.pixels = 24 + 10 -- margin
    list.es.top.pixels = -24 - 10 -- margin
    list.es.top.percent = 1
    list.type = 2+24 + 10 -- margin
    
    stacked.list = list

    local plusButton = Button:new()
    plusButton.elements[2].textSizeFit = true
    plusButton.elements[2].text = "+"
    stacked.plusButton = plusButton
    
    local cond = Condition:new(false, plusButton)
    cond.es.width.percent = 0
    cond.es.width.pixels = stacked.list.type - 2 -- a square
    cond.es.height.pixels = stacked.list.type - 2 -- a square
    cond.es.height.percent = 0

    cond.cond = function() return rl.isCtrlDown() end

    table.insert(stacked.list.elements, cond)

    stacked:addWorkspace(workspace or Selection:new(Stacked))

    stacked.list.elements[stacked.focused].elements[1].color = rl.color(255, 100, 0)
    
    stacked:setupRefs()

    return stacked
end

function Stacked:setupRefs()
    self.plusButton.click = function (_, button)
        if button == 0 then self:addWorkspace(Selection:new(Stacked)) end
    end
end

function Stacked:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    self.workspaces[self.focused]:resize(x, y, w, h)
    self.list:resize(x, y, w, h)
end

function Stacked:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
    self.workspaces[self.focused]:draw()
    self.list:draw()
    scissor.exit()
end

function Stacked:update()
    self.workspaces[self.focused]:update()
    self.list:update()
end

function Stacked:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    for _, elm in pairs(self.list.elements) do
        if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
            return self.list:propagateEvent(event)
            -- if event is press, then pick up workspace, maby?
            -- just make the click button do that for me, no?
        end
    end
    self.workspaces[self.focused]:propagateEvent(event)
end

--[[
function Split:dropInto(x, y, workspace)
    table.insert(self.workspaces, workspace) -- for now
end]]

return Stacked