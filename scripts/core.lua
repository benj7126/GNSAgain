require("globalizedEvents")
require("saveLoadManager")

local elmspace = require("workspaces.elements"):new()
local topWorkspace = require("workspaces.stacked"):new(elmspace)

local test = require("elements.textbox"):new()
test.es.width.percent = 0.4
test.es.height.percent = 1
test.elements[1].wrapping = 2

local b = require("elements.button"):new()
b.es.left.percent = 0.5
b.es.width.pixels = 60
b.es.height.pixels = 24
b.es.vAlign = 0.5

-- SaveElement(b, "test")
-- SaveElement(b, "test2")

local loadedB = LoadElement("test")

elmspace.elements = {test, loadedB}

function WithingBox(x, y, w, h, pos)
    return pos.X > x and pos.X < x + w and pos.Y > y and pos.Y < y + h; -- when its a raylib vec, its big x and y, this is
                                                                        -- an inconsistency that should be fixed at some point.
end

function CoreUpdate()
    topWorkspace:update()

    -- tmp test for save and load
    -- b.elements[2] = CreateElementFromString(test.elements[1].text) or b.elements[2]
    topWorkspace:resize(0, 0, 1200, 800)
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