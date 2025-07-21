-- so that you can split and have a toolbox to the side and then move items from it to an elements workspace.

local TraversableTree = require("elements.traversableTree")
local Workspace = require("workspaces.workspace")
local Toolbox = Workspace:new()

local InstanceDisplayer = require("elements.instanceDisplayer")
local ToolboxItem = require("elements.toolboxItem")
-- want this to have 'folders' as well

RegisterClass(Toolbox, "W-Toolbox")

-- have to make it possible to draw all these at different positions even though they are only one item...
-- i dont quite want to make a copy each time; not sure...

-- maby just have this be constant size fx (400, infty) - with scroll - and then use transforms to draw it different places..?
-- then make it not scaleable/fixed size, and have a thing that tells 'selection' that it can only be placed inside a split? and maby that the split has to make it the right size..?

Toolbox.tree = TraversableTree:new()
InstanceDisplayer.AddInstance("toolbox", Toolbox.tree, 400, nil)

function Toolbox:new() -- maby this should just be a subworkspace of singleElement?
    local toolbox = Workspace.new(Toolbox)

    toolbox.display = InstanceDisplayer:new(false, "toolbox")

    local e = ToolboxItem:new()
    table.insert(Toolbox.tree.contents, e)
    Toolbox.tree:updateList()

    return toolbox
end

function Toolbox:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    self.display:resize(x, y, w, h)
end

function Toolbox:draw() self.display:draw() end

function Toolbox:update() self.display:update() end

function Toolbox:propagateEvent(event)
    self.display:propagateEvent(event)
end

return Toolbox