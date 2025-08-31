local Label = require("elements.label")
local Textbox = require("elements.textbox")
local Box = require("elements.box")

VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "string" then return 1 else return -1 end
end] = function (varSpec)
    varSpec.toSaveValue = function (self)
        return '[[' .. self:get() .. ']]'
    end
    varSpec.inspectorElement = function (self) -- TODO: some way to make this shorter; on all places where this is done.
        local b = Box:new()
        b.es.width.pixels = 240
        b.es.width.percent = 0
        b.es.height.pixels = 20
        b.es.height.percent = 0

        local tb = Textbox:new()
        tb.es.width.percent = 0.5

        tb.es.left.percent = 0.5

        tb.elements.label.text = self:get()

        tb._textChanged.env.vs = self
        tb.textChanged = "local tb = ...; vs:set(tb.elements.label.text)"

        local b2 = Box:new()
        b2.color = rl.color(200, 200, 200)

        table.insert(tb.elements, b2)

        local l = Label:new()
        l.es.width.percent = 0.5

        l.text = self.field

        l.textSizeFit = true -- this no work :/

        table.insert(b.elements, tb)
        table.insert(b.elements, l)

        b._varSpec = self
        
        return b
    end
end