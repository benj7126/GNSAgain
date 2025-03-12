local DropInto = require("workspaces.dropInto")
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

function Stacked:dropInto(x, y, workspace)
    table.insert(self.workspaces, workspace) -- for now
end

return Stacked