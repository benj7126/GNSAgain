local Element = require("elements.element")
local Box = require("elements.box")
local Label = require("elements.label")
local Selection = Element:from()
RegisterClass(Selection, "Selection")

function Selection:saveRules(rules)
    Element:saveRules(rules)
end

function Selection:new(forLoad)
    local sel = Element.new(Selection, forLoad)

    if not forLoad then
        local box = Box:new()
        box.es.width.percent = 1
        box.es.height.percent = 1
        sel.elements["background"] = box
    end

    return sel
end

return Selection