require("saveLoadManager")
require("globalizedEvents")
require("ensureClasses")
require("heldItem")

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

-- could make elemnts of elements - like the ones not in the list of elements be varSpecs and changeable like that somehow?

local Selection = require("workspaces.selection")
local Stacked = require("workspaces.stacked")
local Split = require("workspaces.split")


--
-- There are many places where i should probably sort tables.
--


-- tmp solution, want to make 'custom'
-- things somehow, so that its not c#
-- objects.
-- And i want to find a better save solution.
--[[local mt = getmetatable(rl.vec(0, 0))
mt.saveAll = true
local mt = getmetatable(rl.color(0, 0, 0))
mt.saveAll = true
-- annnd its user data, so it no work.

local loaded = nil -- LoadObject("core")
if not loaded then
    local elmspace = Elements:new()
    loaded = Stacked:new(elmspace)

    local test = Textbox:new()
    test.es.width.percent = 0.4
    test.es.height.percent = 1
    test.elements.label.wrapping = 2

    local list = List:new()
    list.es.left.percent = 0.5
    list.es.width.pixels = 200
    list.es.height.percent = 24

    list.cols = 4
    list.type = 1

    local box = Box:new()
    box.es.left.percent = 0.5
    box.es.width.pixels = 200
    box.es.height.percent = 24
    box.color = rl.color(0, 0, 255)

    for i = 1, 30 do
        local b = Button:new()
        b.es.height.pixels = 30

        if i == 1 then
            b.elements[2].textSizeFit = true
            b.elements[2].xCenter = true
            b.elements[2].yCenter = true
        elseif i == 2 then
            b.elements[2].textSizeFit = false
            b.elements[2].xCenter = true
            b.elements[2].yCenter = true
        elseif i == 3 then
            b.elements[2].textSizeFit = false
            b.elements[2].xCenter = false
            b.elements[2].yCenter = true
        elseif i == 4 then
            b.elements[2].textSizeFit = false
            b.elements[2].xCenter = false
            b.elements[2].yCenter = false
        elseif i == 5 then
            b.elements[2].textSizeFit = true
            b.elements[2].xCenter = false
            b.elements[2].yCenter = false
        elseif i == 6 then
            b.es.height.pixels = 50
            b.elements[2].textSizeFit = true
        end

        table.insert(list.elements, b)
    end

    elmspace.elements = {box, test, list}
end

local topWorkspace = loaded]]
--[[
local loaded = nil

Reference = require("workspaces.reference")
if not loaded then
    loaded = Reference:new()

    loaded:resize(0, 0, 1200, 800) -- to set the workspace to the correct value

    loaded.workspace.elements = {elm, test}
end]]

local loaded = LoadObject("core") -- "origin" feels better, no?

if not loaded then -- the defaults
    loaded = Stacked:new(Split:new(Selection:new(Split))) -- should maby be a reference to a 'main' elements workspace?
    loaded:addWorkspace(Split:new(Selection:new(Split))) -- then this should be a split, at like 0.2~0.3 with toolbox at left and editor at right
    loaded:addWorkspace(Split:new(Selection:new(Split))) -- and lastly; settings..?
end

---- important stuff;;; \/

-- in the process of making everything use 'placeInto' - so as to have parents.
-- working on making split work with string-based stuff.
-- i also need to save/load the parent.

local topWorkspace = loaded

--[[
local TraversableTree = require("elements.traversableTree")
local Button = require("elements.button")
topWorkspace = require("workspaces.elements"):new()
local tree = TraversableTree:new()
tree.es.width.percent = 0.3

local b1 = Button:new()
local b2 = Button:new()
local b3 = Button:new()
local b4 = Button:new()
local b5 = Button:new()
local b6 = Button:new()
local bs = {b1, b2, b3, b4, b5, b6}

for i, v in ipairs(bs) do
    v.es.width.percent = 0
    v.es.height.percent = 0
    v.es.height.pixels = 16
    v.elements[2].fontSize = 16

    v.click = function () print("Pressed the "..i.."'th *click me*") end

    v.elements[2]:prepare()
    v.es.width.pixels = v.elements[2].textWidth + 10
end
b2.es.width.pixels = 60
b2.es.height.pixels = 60

b4.es.width.pixels = 200
b4.es.height.pixels = 200

b5.es.width.pixels = 120
b5.es.height.pixels = 30

tree.contents = {b1, {"_hides b2", b2}, b3, {"elms", b4, {"ghmmm", b5}, b6}}

topWorkspace.elements = {tree}
]]--

function WithingBox(x, y, w, h, pos)
    return pos.X > x and pos.X < x + w and pos.Y > y and pos.Y < y + h; -- when its a raylib vec, its big x and y, this is
                                                                        -- an inconsistency that should be fixed at some point.

                                                                        -- probably by removing raylib vec, somehow...
end

-- TODO: How workspaces should intract - or smthn;
 -- Split, stacked and things like that are just for organizing stuff
 -- elements should never be a subworkspace of anything - directly
 -- that is because i want all elements to be shown/interacted with via reference workspace.
 -- singleElement shoulde likely do something where it has a reference to said element using
 -- a method similar to how reference workspace works.

 -- other workspaces should do other cool things, and element workspaces should be able to have
 -- rules enforced on them or somethign like that to decide behaviour; mainly not in the core things.

 -- notes should be able to be pulled into 'categories'/sub-workspace

function CoreUpdate()
    -- print(test.elements.label.text)
    topWorkspace:update()

    -- tmp test for save and load
    -- b.elements[2] = CreateElementFromString(test.elements[1].text) or b.elements[2]
    -- topWorkspace:resize(0, 0, 1200, 800)
end

-- stupid stuff... | need to make the scissoring work right :/

function CoreDraw()
    topWorkspace:draw()
    DrawHeldItem()
end

function Quitting()
    SaveObject(topWorkspace, "core")
end

function CorePropagateEvent(event)
    PreEventCalled(event)
    topWorkspace:propagateEvent(event)
    PostEventCalled(event)
end

topWorkspace:resize(0, 0, 1200, 800)