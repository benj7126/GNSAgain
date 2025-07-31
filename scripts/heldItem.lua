local heldItem = nil

--[[ dont work when i use the camera to offset.
local useOffset = true

local offset = {}

function SetHeldItem(item, extraOffset)
    heldItem = item

    print(heldItem.es.x, heldItem.es.y)

    local pos = rl.mouse.getMousePosition()
    if useOffset then
        offset = {pos.X + extraOffset[1], pos.Y + extraOffset[2]}
    end
end]]

-- when dropping an item; what should i do if i somehow have an elements workspace inside an elements workspace (with a workspace element between ig.)
-- should it just save last viable drop instance and then; when theres no more sub-objects

function SetHeldItem(item)
    heldItem = item
end

function GetHeldItem()
    return heldItem
end

function ClearHeldItem()
    heldItem = nil
end

function DrawHeldItem()
    if not heldItem then return end

    if type(heldItem) == "table" and heldItem.draw then
        local pos = rl.mouse.getMousePosition()

        -- rl.camera.set(-(pos.X - offset[1]), -(pos.Y - offset[2]))
        rl.camera.set(-pos.X + heldItem.es.x , -pos.Y + heldItem.es.y)
        heldItem:draw()
        rl.camera.reset()
    end
end