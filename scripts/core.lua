local elmspace = require("workspaces.elements"):new()
local topWorkspace = require("workspaces.stacked"):new(elmspace)

function CoreUpdate()
    topWorkspace:update()
end

function CoreDraw()
    topWorkspace:draw()
end

topWorkspace:resize(0, 0, 1200, 800)