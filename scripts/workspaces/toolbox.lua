-- so that you can split and have a toolbox to the side and then move items from it to an elements workspace.

local Workspace = require("workspaces.workspace")
local Button = require("elements.button")
local Toolbox = Workspace:new()

-- want this to have 'folders' as well

RegisterClass(Toolbox, "W-Toolbox")

function Toolbox:new()
    local toolbox = Workspace.new(Toolbox)

    toolbox:setupRefs()

    return toolbox
end

function Toolbox:setupRefs()
    
end

return Toolbox