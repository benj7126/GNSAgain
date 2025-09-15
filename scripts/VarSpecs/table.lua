local FreeContainer = require("elements.freeContainer")
local Button = require("elements.button")
local List = require("elements.list")

local VarSpec = require("varSpec")

local function sortfunction (a, b)
    local a_val, b_val = a._varSpec.index, b._varSpec.index

    return a_val < b_val
end

VarSpecTypes[function (varSpec, initialValue, ...)
    if type(initialValue) == "table" then return 1 else return -1 end
end] = function (varSpec)
    varSpec.toSaveValue = function (self, indent, ami)
        return "{"..BreakdownObject(self:get(), indent.."\t", ami) .. "\n"..indent.."}"
    end
    varSpec.fromSaveValue = function (self, mod)
        ApplyModification(self, mod)
    end

    varSpec.inspectorElement = function (self) -- TODO: some way to make this shorter; on all places where this is done.
        local fc = FreeContainer:new()
        fc.es.width.pixels = 240
        fc.es.width.percent = 0
        fc.es.height.pixels = 20
        fc.es.height.percent = 0

        local b = Button:new()
        b.es.width.pixels = 240
        b.es.width.percent = 0
        b.es.height.pixels = 20
        b.es.height.percent = 0

        b.elements[2].text = self.field
        b.elements[2].textSizeFit = true

        fc.elements.box = b
        fc.elements.list = List:new()
        fc.elements.list.allowCustomW = true
        fc.elements.list.adjustToHeight = true
        fc.elements.list.es.top.pixels = 20

        for _, v in pairs(varSpec:get()) do
            if getmetatable(v) == VarSpec then
                print(_, v)
                local inspElm = v:inspectorElement()

                if inspElm then
                    table.insert(fc.elements.list.elements, inspElm)
                end
            end
        end

        table.sort(fc.elements.list.elements, sortfunction)

        fc._varSpec = self

        if #fc.elements.list.elements == 0 then return nil end

        return fc
    end
end