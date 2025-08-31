local Label = require("elements.label")
local Textbox = require("elements.textbox")
local Box = require("elements.box")

VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "number" then return 1 else return -1 end
end] = function (varSpec)
    varSpec.inspectorElement = function (self) -- somehow ability to dissalow certain changes to changes for textbox.
        local b = Box:new()
        b.es.width.pixels = 240
        b.es.width.percent = 0
        b.es.height.pixels = 20
        b.es.height.percent = 0

        local tb = Textbox:new()
        tb.es.width.percent = 0.5

        tb.es.left.percent = 0.5

        tb.elements.label.text = tostring(self:get())

        tb._textChanged.env.vs = self
        tb._textChanged.env.tonumber = tonumber
        tb.textChanged = [[local tb = ...;
                           local int = tonumber(tb.elements.label.text);
                           if int then
                               vs:set(int)
                           end]]

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