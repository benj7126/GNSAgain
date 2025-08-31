-- should be able to pull an element from toolbox into this and modify it?

-- naming, adding things, changing values and such.

local Workspace = require("workspaces.workspace")
local Editor = Workspace:new()
RegisterClass(Editor, "W-Editor")

function Editor:new()
    local editor = Workspace.new(Editor)

    editor.editorId = getUUID() -- pass this onto inspector and elementBreakdown on creation and make it link all good.

    -- this and 'elements' could be based on the same thing that let's you pan and zoom.
    editor.offset = {x=0, y=0}
    editor.zoom = 1

    editor.elm = nil -- should be in a note
    editor.toolboxItem = nil
    
    self.workspaces = {}

    return editor
end

function Editor:resize(x, y, w, h) self.sizes = {x, y, w, h} end

function Editor:draw()
    if self.elm then
        self.elm:draw()
    end
end

function Editor:update()
    if self.elm then
        self.elm:draw()
    end
end

function Editor:handleEvent(event)
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
end

function Editor:propagateEvent(event)
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

return Editor