local Workspace = {}
RegisterClass(Workspace, "W-Workspace")
local varSpecMT = require("varSpecMT")

function Workspace:new()
    local workspace = {}
    
    --[[ workspace.draw = function()
        scissor.enter(workspace.sizes[1], workspace.sizes[2], workspace.sizes[3], workspace.sizes[4])
        getmetatable(workspace).draw(workspace)
        scissor.exit()
    end]]-- this might not work with selector workspace though :/

    workspace.elements = {}
    
    setmetatable(workspace, self)
    varSpecMT(self) -- dont create *that* many workspaces... probably
                    -- so i will just let this do it on every new; at lest for now. (a pain to fix.)

    workspace.sizes = {0, 0, 0, 0} -- need for if i change anything in workspace ad want to resize down
    return workspace
end

function Workspace:setupRefs() end

function Workspace:resize(x, y, w, h) self.sizes = {x, y, w, h} end -- could i instead treat this as a "next time you draw, know that you should resize..?"
function Workspace:_resize() self:resize(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4]) end

function Workspace:draw() end -- rl.rec(0, 30, 400, 400, rl.color(0, 0, 255)) end

function Workspace:update() end

function Workspace:propagateEvent(event)
    if self:handleEvent(event) then return end
end

function Workspace:handleEvent(event) return false end -- didnt "consume" the event -> dont want to block

return Workspace