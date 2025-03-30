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

-- things need to be required once to acutally be loaded...
-- might want to cheat that and just 'load' everything at startup?
local Reference = require("workspaces.reference")
local Elements = require("workspaces.elements")
local Stacked = require("workspaces.stacked")
local Textbox = require("elements.textbox")
local Button = require("elements.button")

--[[
local loaded = LoadObject("core")
if not loaded then
    local elmspace = Elements:new()
    loaded = Stacked:new(elmspace)
    
    local test = Textbox:new()
    test.es.width.percent = 0.4
    test.es.height.percent = 1
    test.elements.label.wrapping = 2
    
    local b = Button:new()
    b.es.left.percent = 0.5
    b.es.width.pixels = 60
    b.es.height.pixels = 24
    b.es.vAlign = 0.5
end

local topWorkspace = loaded
]]

local loaded = LoadObject("core")
if not loaded then
    loaded = Reference:new()

    loaded:resize(0, 0, 1200, 800)
    
    local test = Textbox:new()
    test.es.width.percent = 1
    test.es.height.percent = 1
    test.elements.label.wrapping = 2
    
    loaded.workspace.elements = {test}
else
    print(loaded.targetId, "e")
end
print(loaded.targetId)

local topWorkspace = loaded


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
    if event.type == "mousepress" then
        SaveObject(topWorkspace, "core")
    end

    PreEventCalled(event)
    topWorkspace:propagateEvent(event)
    PostEventCalled(event)
end

topWorkspace:resize(0, 0, 1200, 800)