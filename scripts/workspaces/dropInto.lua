-- this is irrelevant with how events work.

local Workspace = require("workspaces.workspace")
local Decorator = Workspace:new()

function Decorator:dropInto(x, y, workspace) end

return Decorator