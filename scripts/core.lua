require("globalizedEvents")
require("saveLoadManager")

-- should add another layer for loading elements
-- that are based on elements based on classes
-- and make it so that it only saves values that
-- have changed compared ot the original

-- You have the elements.box placed in a template called a note
-- and then in a workspace, that note template is used and the
-- new element that is a box, should be based on the note template
-- that is based on a box...

-- templates specify what elements are where and some most values
-- while notes based on templates mainly modify things like text.

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

-- SaveObject(b, "test")
-- SaveObject(b, "test2")

local loadedB = LoadObject("test")

elmspace.elements = {test, loadedB}

SaveObject(topWorkspace, "w-test")
topWorkspace = LoadObject("w-test")

function WithingBox(x, y, w, h, pos)
    return pos.X > x and pos.X < x + w and pos.Y > y and pos.Y < y + h; -- when its a raylib vec, its big x and y, this is
                                                                        -- an inconsistency that should be fixed at some point.

                                                                        -- probably by removing raylib vec, somehow...
end

function CoreUpdate()
    topWorkspace:update()

    -- tmp test for save and load
    -- b.elements[2] = CreateElementFromString(test.elements[1].text) or b.elements[2]
    -- topWorkspace:resize(0, 0, 1200, 800)
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