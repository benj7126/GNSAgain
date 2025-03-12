local Workspace = require("workspace")
local Elements = Workspace:new()

function Elements:new(workspace)
    local elms = Workspace.new(Elements)

    -- tmp
    local elm = require("elements.box"):new()
    elm.es.width.percent = 0.9
    elm.es.height.percent = 0.9
    elm.es.vAlign = 0.5
    elm.es.hAlign = 0.5

    local elm2 = require("elements.box"):new()
    elm2.es.width.percent = 0.9
    elm2.es.height.percent = 0.9
    elm2.es.vAlign = 0.5
    elm2.es.hAlign = 0.5
    elm2.color = rl.color(255, 0, 0)
    table.insert(elm.elements, elm2)

    elms.elements = {elm}

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

return Elements