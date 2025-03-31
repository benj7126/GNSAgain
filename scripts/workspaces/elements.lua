local Workspace = require("workspaces.workspace")
local Elements = Workspace:new()
RegisterClass(Elements, "W-Elements")

function Elements:new(workspace)
    local elms = Workspace.new(Elements)

    self.saveAlone = true

    self.elements = {}
    self.workspaces = {}
    self.sizes = nil -- if i dont use it ig i should just kill it, no?

    return elms
end

function Elements:resize(x, y, w, h)
    -- self.sizes = {x, y, w, h} might not care
    for _, elms in pairs(self.elements) do
        elms:resize(x, y, w, h)
    end
end

function Elements:draw()
    for _, elms in pairs(self.elements) do
        scissor.enter(elms.es.x, elms.es.y, elms.es.w, elms.es.h)
        elms:draw()
        scissor.exit()
    end
end

function Elements:update()
    for _, elms in pairs(self.elements) do
        elms:update()
    end
end

function Elements:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end
    local elmLoop = {}
    for _, elm in pairs(self.elements) do table.insert(elmLoop, elm) end

    for i = #elmLoop, 1, -1 do
        local elm = elmLoop[i]
        if WithingBox(elm.es.x, elm.es.y, elm.es.w, elm.es.h, event.pos) then
            elm:propagateEvent(event)
            return
        end
    end
end

return Elements