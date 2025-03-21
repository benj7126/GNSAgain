local Element = require("elements.element")
local Label = require("elements.label")
local Textbox = Element:from()

function Textbox:new()
    local tb = Element.new(Textbox)

    local draw = require("modules.draw.reverseDraw")
    tb.draw = function(...)
        if not tb.elements[1].lines then
            -- write to console thing that this wants a label as its first child
            return
        end

        draw(...)

        local label = tb.elements[1]
        rl.rec(label.es.x + tb.cursorVisualX, label.es.y + tb.cursorVisualY, 1, label.fontSize, tb.cursorColor);
    end

    local label = Label:new()
    label.es.width.percent = 1
    label.es.height.percent = 1

    label.text = ""

    table.insert(tb.elements, label)

    tb.cursorVisualX = 0;
    tb.cursorVisualY = 0;

    tb.savedCursorVisualX = -1;
    tb.savedCursorVisualY = -1;
    tb.cursorPosition = 0;

    tb.highlightPosition = -1;

    tb.highlightColor = rl.color(0, 0, 200)
    tb.cursorColor = rl.color(255, 150, 0)


    return tb
end
local function InBetween(val, v1, v2)
    if v1 > v2 then
        return val < v1 and val > v2 - 1
    else
        return val < v2 and val > v1 - 1
    end
end

function Textbox:draw()
    local curIndex = 0
    local textOffsetY = 0
    local textOffsetX = 0

    local label = self.elements[1]

    for _, line in pairs(label.lines) do
        for _, char in pairs(line) do
            if self.highlightPosition ~= self.cursorPosition and self.highlightPosition ~= -1 and InBetween(curIndex, self.highlightPosition, self.cursorPosition) then
                rl.rec(label.es.x + math.floor(textOffsetX), label.es.y + math.floor(textOffsetY), math.ceiling(char.width), label.fontSize, self.highlightColor);
            end

            curIndex = curIndex + 1
            textOffsetX = textOffsetX + char.width;
        end

        textOffsetY = textOffsetY + label.fontSize + label.lineSpacing;
        textOffsetX = 0;
    end
end

function Textbox:handleEvent(event)
    print("Event; ".. event.type)
    print("")
    if event.type == "mousepress" then
        rl.setInput(event)
        return true
    elseif event.type == "input" then
        if not self.elements[1].lines then
            -- write to console thing that this wants a label as its first child
            return
        end
        self.elements[1].text = self.elements[1].text .. event.key;
        self.elements[1]:resize(self.es.x, self.es.y, self.es.w, self.es.h)
    end
    return false
end

--[[
function Textbox:EndOfLineCursorCheck()
    if self.setCursor then
        if self.mPos.Y < self.textOffsetY + self.tb.lineSpacing + self.tb.fontSize then
            self.tb.cursorPosition = self.curIndex;
            self.setCursor = false;

            self.tb.cursorVisualX = self.textOffsetX;
            self.tb.cursorVisualY = self.textOffsetY;
        end
    end
end

function Textbox:InsertBuffer(lineBuffer, codepointBuffer)
    for _, cpNWidth in pairs(codepointBuffer) do
        if self.setCursor then
            if self.mPos.Y < self.textOffsetY + self.tb.lineSpacing + self.tb.fontSize and self.mPos.X < self.textOffsetX + cpNWidth[2] / 2 then
                self.tb.cursorPosition = self.curIndex;
                self.setCursor = false;
            end
        end

        if self.curIndex == self.tb.cursorPosition and self.tb.cursorVisualX == -1 then -- && InputManager.CheckSelected(this) then
            self.tb.cursorVisualX = self.textOffsetX;
            self.tb.cursorVisualY = self.textOffsetY;
        end

        self.curIndex = self.curIndex + 1;
        self.textOffsetX = self.textOffsetX + cpNWidth[2];

        table.insert(lineBuffer, {codepoint = cpNWidth[1], width = cpNWidth[2]})
    end
end]]

return Textbox