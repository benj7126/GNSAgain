local DropInto = require("workspaces.workspace")
local Stacked = DropInto:new()

function Stacked:new(workspace)
    local stacked = DropInto.new(Stacked)

    stacked.workspaces = {workspace}
    stacked.focused = 1

    return stacked
end

function Stacked:resize(x, y, w, h)
    self.sizes = {x, y, w, h}
    self.workspaces[self.focused]:resize(x, y, w, h)
end

function Stacked:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
    self.workspaces[self.focused]:draw()
    scissor.exit()
end

function Stacked:update()
    self.workspaces[self.focused]:update()
end

function Stacked:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    self.workspaces[1]:propagateEvent(event)
    --[[ above is temp solution
    for _, elm in pairs(self.elements) do
        if WithingBox(self.es.x, self.es.y, self.es.w, self.es.h, event.pos) then
            elm:propagateEvent(event)
            return
        end
    end]]
end

--[[
function Split:dropInto(x, y, workspace)
    table.insert(self.workspaces, workspace) -- for now
end]]

return Stacked