local Workspace = require("workspaces.workspace")
local SingleElements = Workspace:new()
RegisterClass(SingleElements, "W-Elements")

function SingleElements:new(elem)
    local sElm = Workspace.new(SingleElements)

    sElm.elements = {}
    sElm.elements.elem = elem or nil

    return sElm
end

function SingleElements:resize(x, y, w, h)
    self.sizes = {x, y, w, h}
    if self.elements.elem then
        self.elements.elem:resize(x, y, w, h)
    end
end

function SingleElements:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])

    if self.elements.elem then
        self.elements.elem:draw()
    end

    scissor.exit()
end

function SingleElements:update()
    if self.elements.elem then
        self.elements.elem:update()
    end
end

return SingleElements