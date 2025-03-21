require("globalizedEvents")

local elmspace = require("workspaces.elements"):new()
local topWorkspace = require("workspaces.stacked"):new(elmspace)

local test = require("elements.textbox"):new()
test.es.width.percent = 0.4
test.es.height.percent = 0.4
test.vAlign = 0.5

local b = require("elements.button"):new()
b.es.left.percent = 0.5
b.es.width.pixels = 60
b.es.height.pixels = 24
b.vAlign = 0.5

elmspace.elements = {test, b}

function WithingBox(x, y, w, h, pos)
    return pos.X > x and pos.X < x + w and pos.Y > y and pos.Y < y + h; -- when its a raylib vec, its big x and y, this is
                                                                        -- an inconsistency that should be fixed at some point.
end

function CoreUpdate()
    topWorkspace:update()
end

function CoreDraw()
    topWorkspace:draw()
end

function CorePropagateEvent(event)
    PreEventCalled(event)
    topWorkspace:propagateEvent(event)
    PostEventCalled(event)
end

topWorkspace:resize(0, 0, 1200, 800)