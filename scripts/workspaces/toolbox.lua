-- so that you can split and have a toolbox to the side and then move items from it to an elements workspace.

local TraversableTree = require("elements.traversableTree")
local Workspace = require("workspaces.workspace")
local Toolbox = Workspace:new()

-- want this to have 'folders' as well

RegisterClass(Toolbox, "W-Toolbox")

Toolbox.notes = {} -- should be shared in some other way probably
                   -- some way to hook into when these are changed and a system to keep track of them not in here.

function Toolbox:new() -- maby this should just be a subworkspace of singleElement?
    local toolbox = Workspace.new(Toolbox)

    toolbox.tree = TraversableTree:new()
    toolbox.tree.contents = Toolbox.notes

    return toolbox
end

function Toolbox:resize(x, y, w, h)
    self.tree:resize(x, y, w, h)
end

function Toolbox:draw() self.tree:draw() end

function Toolbox:update() self.tree:update() end

function Toolbox:propagateEvent(event)
    self.tree:propagateEvent(event)
end

return Toolbox