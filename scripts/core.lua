local elmspace = require("workspaces.elements"):new()
local topWorkspace = require("workspaces.stacked"):new(elmspace)

local testL = require("elements.label"):new()
testL.es.width.percent = 0.4
testL.es.height.percent = 0.4
testL.vAlign = 0.5

function CoreUpdate()
    topWorkspace:update()
    testL:update()
end

function CoreDraw()
    topWorkspace:draw()
    testL:draw()
end

topWorkspace:resize(0, 0, 1200, 800)
testL:resize(0, 0, 1200, 800)