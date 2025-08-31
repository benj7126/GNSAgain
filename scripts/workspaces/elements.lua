local Workspace = require("workspaces.workspace")
local Elements = Workspace:new()
RegisterClass(Elements, "W-Elements")

function Elements:new()
    local elms = Workspace.new(Elements)

    -- elms.saveAlone = true ??

    elms.offset = {x=0, y=0}
    elms.zoom = 1

    elms.elements = {}
    elms.workspaces = {}
    elms.sizes = nil -- if i dont use it ig i should just kill it, no?

    return elms
end

function Elements:resize(x, y, w, h)
    self.sizes = {x, y, w, h}

    for _, elms in pairs(self.elements) do
        elms:resize(math.mininteger, math.mininteger, math.maxinteger, math.maxinteger)
        elms:resize(0, 0, math.maxinteger, math.maxinteger)
        print(elms.es.x, elms.es.y, elms.es.w, elms.es.h)
    end
end

function Elements:draw()
    scissor.enter(self.sizes[1], self.sizes[2], self.sizes[3], self.sizes[4])

    for _, elms in pairs(self.elements) do
        rl.camera.set(-self.offset.x, -self.offset.y)
        elms:draw()
        rl.camera.reset()
    end
    
    scissor.exit()
end

function Elements:update()
    for _, elms in pairs(self.elements) do
        elms:update()
    end
end

function Elements:handleEvent(event)
    if event.button == 0 and event.type == "mouserelease" then
        local heldItem = GetHeldItem()

        if heldItem then
            local mt = getmetatable(heldItem)
            if GetClassName(mt) == "ToolboxItem" then
                print(event, event.pos, event.pos.X, event.pos.Y)
                event.pos = vec(event.pos.X - self.offset.x, event.pos.Y - self.offset.y)
                heldItem:dropInto(self, event)
                return true
            end
        end
    elseif event.button == 2 and event.type == "mousepress" then
        FakeDragEvent(event, function () end, function (_)
            local vel = rl.mouse.getMouseVelocity()
            
            self.offset.x = self.offset.x + vel.X
            self.offset.y = self.offset.y + vel.Y
        end)
    end
    return false
end

function Elements:propagateEvent(event)
    event:passed(self)
    if self:handleEvent(event) then return end

    event.pos = vec(event.pos.X - self.offset.x, event.pos.Y - self.offset.y)
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