local Element = require("elements.element")
local List = Element:from()
RegisterClass(List, "List")
local VarSpec = require("varSpec")

function List:new(forLoad)
    local list = Element.new(List, forLoad)

    list.xSpacing = VarSpec:new(10)
    list.ySpacing = VarSpec:new(10)
    list.cols = VarSpec:new(1)
    list.allowCustomW = false

    list.type = VarSpec:new(1)
    -- 1 -> one, total, offset
    -- 2 -> on offset pr col
    -- larger than 2 -> enoforce height of "type-2", and one offset
    -- should have above be a selection of two choices and other, and have other be an int. somehow

    return list
end

function List:resize(x, y, w, h)
    self.es:recalculate(x, y, w, h)
    if self.cols < 1 then self.cols = 1 end

    local offsetX = 0
    local offsetY = 0
    if self.type == 2 then
        offsetY = {}
        for _ = 1, self.cols do table.insert(offsetY, 0) end
    end

    local largestH = 0
    for i, elm in pairs(self.elements) do
        elm.es.left.percent = 0
        elm.es.top.percent = 0
        
        elm.es.height.percent = 0
        if self.type > 2 then
            elm.es.height.pixels = self.type-2
        end

        local thisIdxY = i % self.cols

        if not self.allowCustomW then
            elm.es.width.percent = 1 / self.cols
            if self.cols > 1 then
                elm.es.hAlign = 1 / (self.cols-1) * ((i-1) % self.cols)
                elm.es.width.pixels = -self.xSpacing + self.xSpacing / self.cols
            else
                elm.es.width.pixels = 0
            end
            
            elm.es.left.pixels = 0
        else
            elm.es.left.pixels = offsetX
        end

        if self.type == 2 then
            elm.es.top.pixels = offsetY[thisIdxY + 1]
        else
            elm.es.top.pixels = offsetY
        end

        elm:resize(self.es.x, self.es.y, self.es.w, self.es.h)
        
        offsetX = offsetX + elm.es.w + self.xSpacing -- only used if customw allowed

        if self.type == 2 then
            offsetY[thisIdxY + 1] = offsetY[thisIdxY + 1] + elm.es.h + self.ySpacing
        else
            largestH = math.max(largestH, elm.es.h)
            if thisIdxY == 0 then
                offsetY = offsetY + largestH + self.ySpacing
                largestH = 0
            end
        end
    end
end

return List