local Workspace = require("workspaces.workspace")
local Selection = require("workspaces.selection")
local List      = require("elements.list")
local Button    = require("elements.button")
local Stacked = Workspace:new()
RegisterClass(Stacked, "W-Stacked")

function Stacked:addWorkspace(workspace)
    table.insert(self.workspaces, workspace)
    local button = Button:new()

    button.elements[2].text = GetClassName(getmetatable(workspace)) -- would like to make this editable...
                                                                  -- likely when ctrl is held.

    button.elements[2].fontSize = 24
    button.elements[2]:prepTB()
    button.es.width.pixels = button.elements[2].textWidth + 10
    button.es.width.percent = 0
    button.elements[2].xCenter = true
    button.elements[2].yCenter = true

    local idx = #self.workspaces
    button.press = function (_, button)
        if button == 0 then
            self.list.elements[self.focused].elements[1].color = rl.color(255, 255, 0)
            self.focused = idx
            self.list.elements[self.focused].elements[1].color = rl.color(255, 100, 0)
            self.workspaces[self.focused]:resize(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
        end
    end

    -- should also allow inserting at position.
    -- option to change to newly inserted workspace??

    table.insert(self.list.elements, button)
    
    self.list.cols = #self.list.elements

    self.list:resize(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
    self:placeButton(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
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
    plusButton.es.width.percent = 0
    plusButton.es.width.pixels = stacked.list.type - 2 -- a square
    plusButton.es.height.pixels = stacked.list.type - 2 -- a square
    plusButton.es.height.percent = 0
    plusButton.elements[2].textSizeFit = true
    plusButton.elements[2].text = "+"

    plusButton.press = function (_, button)
        if button == 0 then stacked:addWorkspace(Selection:new()) end
    end

    stacked.plusButton = plusButton

    stacked:addWorkspace(workspace or Selection:new())

    stacked.list.elements[stacked.focused].elements[1].color = rl.color(255, 100, 0)

    return stacked
end

function Stacked:placeButton(x, y, w, h)
    local lastElm = self.list.elements[#self.list.elements]
    self.plusButton.es.left.pixels = lastElm.es.x + lastElm.es.w
    self.plusButton.es.top.pixels = lastElm.es.y
    self.plusButton:resize(x, y, w, h)
end

function Stacked:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    self.workspaces[self.focused]:resize(x, y, w, h)
    self.list:resize(x, y, w, h)
    self:placeButton(x, y, w, h)
end

function Stacked:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
    self.workspaces[self.focused]:draw()
    self.list:draw()
    if rl.isCtrlDown() then self.plusButton:draw() end
    scissor.exit()
end

function Stacked:update()
    self.workspaces[self.focused]:update()
    self.list:update()
end

function Stacked:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    if rl.isCtrlDown() and WithingBox(self.plusButton.es.x, self.plusButton.es.y, self.plusButton.es.w, self.plusButton.es.h, event.pos) then
        self.plusButton:propagateEvent(event)
        return
    end
    for _, elm in pairs(self.list.elements) do
        if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
            if rl.isCtrlDown() then
                -- if event is press, then pick up workspace.
            else
                self.list:propagateEvent(event)
            end
            return
        end
    end
    self.workspaces[self.focused]:propagateEvent(event)
end

--[[
function Split:dropInto(x, y, workspace)
    table.insert(self.workspaces, workspace) -- for now
end]]

return Stacked