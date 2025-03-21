local Workspace = {}

function Workspace:new()
    local workspace = {}
    setmetatable(workspace, self)
    self.__index = self
    workspace.sizes = {0, 0, 0, 0}
    return workspace
end

function Workspace:resize(x, y, w, h) end -- could i instead treat this as a "next time you draw, know that you should resize..?"

function Workspace:draw() end -- rl.rec(0, 30, 400, 400, rl.color(0, 0, 255)) end

function Workspace:update() end

function Workspace:propagateEvent(event)
    if self:handleEvent(event) then return end
end

function Workspace:handleEvent(event) return false end -- didnt "consume" the event -> dont want to block

return Workspace