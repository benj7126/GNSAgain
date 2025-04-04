local Workspace = require("workspaces.workspace")
local Selection = require("workspaces.selection")
local Split = Workspace:new()
RegisterClass(Split, "W-Split")

function Split:new(workspace)
    local split = Workspace.new(Split)

    split.workspaces = {workspace or Selection:new()}
    split.horizontal = true
    split.splits = {}
    split.sizes = {}

    return split
end

function Split:resize(x, y, w, h)
    self.sizes = {{x, y, w, h}} -- each split should have its own set of sizes
    for _, workspace in pairs(self.workspaces) do
        workspace:resize(x, y, w, h)
    end
end

function Split:draw()
    for _, workspace in pairs(self.workspaces) do
        scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])
        workspace:draw()
        scissor.exit()
    end
end

function Split:update()
    for _, workspace in pairs(self.workspaces) do
        workspace:update()
    end
end

function Split:propagateEvent(event)
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

return Split