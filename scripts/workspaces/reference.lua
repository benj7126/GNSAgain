local Workspace = require("workspaces.workspace")
local Elements = require("workspaces.elements")
local Reference = Workspace:new()
RegisterClass(Reference, "W-Reference")
local VarSpec = require("varSpec")

-- maby all Elements should just act like this automatically?
-- can't really think of a case where this is not the optimal solution...
-- or let there be a variable that says if they should be saved separately, seems easy enough to make...

-- but at the same time i do want it to be possible to have like, a ref to a workspace...
-- so that the same workspace can be open twice, fx...
-- but idk what the best way to do that is.

local WorkspaceRefs = {}

function Reference:new(newId)
    local ref = Workspace.new(Reference)

    ref.targetId = VarSpec:new(newId or getUUID()) -- fx if its origin is somewhere else or something...
    ref.workspace = {}

    return ref
end

function Reference:resize(x, y, w, h)
    if not WorkspaceRefs[self.targetId] then
        local loaded = LoadObject(self.targetId)

        if not loaded then
            loaded = Elements:new() -- should maby be a selectionWorkspace or something somehow..? maby not.
                                    -- or, does it ever need to not be an Elements workspace,
                                    -- i feel like the single element should just use 'WorkspaceRefs'
                                    -- and the index/path from 'Elements' workspace of/to said element
        end

        WorkspaceRefs[self.targetId] = loaded
    end

    self.workspace = WorkspaceRefs[self.targetId]

    self.workspace:resize(x, y, w, h)
end

function Reference:draw()
    self.workspace:draw()
end

function Reference:update()
    self.workspace:update()
end

function Reference:propagateEvent(event)
    self.workspace:propagateEvent(event)
end

function Reference:extraSave()
    SaveObject(WorkspaceRefs[self.targetId], self.targetId)
end

return Reference