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

    tb.heldMode = 0; -- SelectTextChar-1, SelectTextWord-2, SelectTextLine-3

    tb.savedCursorVisualX = -1;
    tb.cursorPosition = 0;

    tb.highlightPosition = -1;

    tb.highlightColor = rl.color(0, 0, 200, 100)
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

function Textbox:correctCusorVisual()
    local label = self.elements[1]

    local curIndex = 0
    local textOffsetY = 0
    local textOffsetX = 0

    for _, line in pairs(label.lines) do
        if curIndex + #line >= self.cursorPosition then
            for _, char in pairs(line) do
                if self.cursorPosition == curIndex then
                    self.cursorVisualX = textOffsetX
                    self.cursorVisualY = textOffsetY
                    return
                end
    
                curIndex = curIndex + 1
                textOffsetX = textOffsetX + char.width;
            end
            
            self.cursorVisualX = textOffsetX
            self.cursorVisualY = textOffsetY
            return
        end

        curIndex = curIndex + #line
        textOffsetY = textOffsetY + label.fontSize + label.lineSpacing;
    end
end

function Textbox:placeCursorOnLineAt(vec, line, curIndex)
    local label = self.elements[1]
    -- local spacing = label.spacing
    local textOffsetX = label.es.x

    for _, char in pairs(line) do
        if textOffsetX + char.width*0.5 > vec.X then -- textOffsetX + char.width - (char.width - spacing)/2
            self.cursorVisualX = textOffsetX
            self.cursorPosition = curIndex
            return
        end

        curIndex = curIndex + 1
        textOffsetX = textOffsetX + char.width;
    end

    self.cursorVisualX = textOffsetX
    self.cursorPosition = curIndex
end

-- outOfBoundsFrontEnd makes it so that if its out of bounds, it will place at start (if above) or end (if below)
function Textbox:placeCursorAt(vec, outOfBoundsStartEnd) -- forceEOL, been replaced by 'correctCusorVisual'
    local label = self.elements[1]
    outOfBoundsStartEnd = outOfBoundsStartEnd or false

    local curIndex = 0

    local yLine = math.floor((vec.Y - label.es.y) / (label.fontSize + label.lineSpacing))

    if yLine < 0 then
        self.cursorVisualY = label.es.y

        if outOfBoundsStartEnd then -- or not label.lines[1] then | theres always 1 line (if its been calculated)
            self.cursorVisualX = label.es.x
            self.cursorPosition = 0
        else
            self:placeCursorOnLineAt(vec, label.lines[1], curIndex, false)
        end
        return
    end

    -- count characters in aboce line
    for i = 1, yLine do
        if label.lines[i+1] then
            curIndex = curIndex + #label.lines[i]
        else
            if outOfBoundsStartEnd  then
                forceEOL = true
            end
            
            self.cursorVisualY = (i-1) * (label.fontSize + label.lineSpacing)
            self:placeCursorOnLineAt(vec, label.lines[i], curIndex)

            return
        end
    end

    self.cursorVisualY = (yLine) * (label.fontSize + label.lineSpacing)
    self:placeCursorOnLineAt(vec, label.lines[yLine+1], curIndex)
end

function Textbox:draw()
    local label = self.elements[1]

    local curIndex = 0
    local textOffsetY = 0
    local textOffsetX = 0

    for _, line in pairs(label.lines) do
        for _, char in pairs(line) do
            if self.highlightPosition ~= self.cursorPosition and self.highlightPosition ~= -1 and InBetween(curIndex, self.highlightPosition, self.cursorPosition) then
                rl.rec(label.es.x + math.floor(textOffsetX), label.es.y + math.floor(textOffsetY), math.ceil(char.width), label.fontSize, self.highlightColor);
            end

            curIndex = curIndex + 1
            textOffsetX = textOffsetX + char.width;
        end

        textOffsetY = textOffsetY + label.fontSize + label.lineSpacing;
        textOffsetX = 0;
    end
end

function Textbox:delete()
    local label = self.elements[1]

    label.text = label.text:sub(1, self.cursorPosition) .. label.text:sub(self.cursorPosition+2, #label.text)
end

function Textbox:backspace()
    local label = self.elements[1]
    
    if self.cursorPosition ~= 0 then
        -- local toRem = label.text:sub(self.cursorPosition, self.cursorPosition)

        label.text = label.text:sub(1, self.cursorPosition-1) .. label.text:sub(self.cursorPosition+1, #label.text)

        self.cursorPosition = self.cursorPosition - 1
        --[[
        if toRem == "\n" then
            self.cursorPosition = self.cursorPosition - 1
            self:correctCusorVisual()
            -- self:placeCursorAt(rl.vec(0, self.cursorVisualY - (label.fontSize + label.lineSpacing)/2), true)
        else
            self.cursorVisualX = self.cursorVisualX - rl.getCharWidth(toRem, label.fontName, label.fontSize, label.spacing)
            self.cursorPosition = self.cursorPosition - 1
        end]]
    end
end

function Textbox:right()
    local label = self.elements[1]
    if self.cursorPosition ~= #self.elements[1].text then
        local movePast = label.text:sub(self.cursorPosition+1, self.cursorPosition+1)
        
        if movePast ~= "\n" then
            self.cursorVisualX = self.cursorVisualX + rl.getCharWidth(movePast, label.fontName, label.fontSize, label.spacing)
        else
            self.cursorVisualX = 0
            self.cursorVisualY = self.cursorVisualY + label.fontSize + label.lineSpacing
        end

        self.cursorPosition = self.cursorPosition + 1
    end
end

function Textbox:left()
    local label = self.elements[1]

    if self.cursorPosition ~= 0 then
        local movePast = label.text:sub(self.cursorPosition, self.cursorPosition)

        self.cursorPosition = self.cursorPosition - 1

        if movePast == "\n" then
            self:correctCusorVisual()
            -- self:placeCursorAt(rl.vec(0, self.cursorVisualY - (label.fontSize + label.lineSpacing)/2), true)
        else
            self.cursorVisualX = self.cursorVisualX - rl.getCharWidth(movePast, label.fontName, label.fontSize, label.spacing)
        end
    end
end

function Textbox:deleteSelectedArea()
    local label = self.elements[1]

    if self.highlightPosition ~= -1 then
        if self.highlightPosition < self.cursorPosition then
            local hp = self.highlightPosition
            self.highlightPosition = self.cursorPosition
            self.cursorPosition = hp
        end

        label.text = label.text:sub(1, self.cursorPosition) .. label.text:sub(self.highlightPosition+1, #label.text)
    end
end

function Textbox:handleEvent(event)
    local label = self.elements[1]

    if event.type == "mousepress" then
        rl.setInput(event)

        self.highlightPosition = -1
        self.savedCursorVisualX = -1
        
        self.heldMode = math.fmod(event.presses-1, 3)+1
        if self.heldMode == 1 then
            self:placeCursorAt(event.pos)
        end

        PreNextEvent("mouserelease", function(nEvent)
            self.heldMode = 0

            return true
        end)

        PostNextEvent("mousemoved", function(nEvent) -- needs to be global
            if self.heldMode == 0 then return true end
            
            local pastCursorPos = self.cursorPosition
            self:placeCursorAt(nEvent.pos)

            if pastCursorPos ~= self.cursorPosition and self.highlightPosition == -1 then
                self.highlightPosition = pastCursorPos
            end

            return false
        end)

        return true
    elseif event.type == "input" then
        if not label.lines then
            -- write to console thing that this wants a label as its first child
            return
        end

        if self.highlightPosition ~= -1 then
            self:deleteSelectedArea()
            self.highlightPosition = -1
        end
        
        self.savedCursorVisualX = -1

        label.text = label.text:sub(1, self.cursorPosition) .. event.key .. label.text:sub(self.cursorPosition+1, #label.text)
        self.cursorPosition = self.cursorPosition + 1

        -- self.cursorVisualX = self.cursorVisualX + rl.getCharWidth(event.key, label.fontName, label.fontSize, label.spacing)
        label:prepTB() -- TODO: ideally i would like to only update from the change, and as little as possible
        self:correctCusorVisual() -- well, what if wrap..?
        -- self:updateVisualCursor() should be able to calculate the location on the run.
    elseif event.type == "specialKey" then
        if event.key >= 262 and event.key <= 265 then -- any movement key
            if rl.isShiftDown() and self.highlightPosition == -1 then
                self.highlightPosition = self.cursorPosition
            elseif not rl.isShiftDown() then
                self.highlightPosition = -1
            end
        end

        if event.key == 261 or event.key == 259 or event.key == 257 then
            local wasHighlight = self.highlightPosition

            if self.highlightPosition == -1 then
                if event.key == 261 then -- delete
                    self:ctrlRepeatAction(self.delete, event.additions, false, true)
                elseif event.key == 259 then -- backspace
                    self:ctrlRepeatAction(self.backspace, event.additions, true);
                end
            else
                self:deleteSelectedArea()
                self.highlightPosition = -1
            end
            
            if event.key == 257 then -- enter
                label.text = label.text:sub(1, self.cursorPosition) .. "\n" .. label.text:sub(self.cursorPosition+1, #label.text)
    
                self.cursorVisualY = self.cursorVisualY + label.fontSize + label.lineSpacing
                self.cursorVisualX = 0
                self.cursorPosition = self.cursorPosition + 1
            end

            label:prepTB() -- ideally from self.cursorPosition until "out of bounds"
            if wasHighlight ~= -1 or event.key == 259 then -- backspace needs either this or with a pos, this is probabbly better.
                self:correctCusorVisual()
            end
            -- self:updateVisualCursor()
        elseif event.key == 263 then -- left
            self:ctrlRepeatAction(self.left, event.additions, true);
            -- self:updateVisualCursor()
        elseif event.key == 262 then -- right
            self:ctrlRepeatAction(self.right, event.additions, false);
            -- self:updateVisualCursor()
        end
        if event.key == 264 or event.key == 265 then
            if self.savedCursorVisualX == -1 then
                self.savedCursorVisualX = self.cursorVisualX
            end

            if event.key == 265 then -- up
                self:placeCursorAt(rl.vec(self.savedCursorVisualX, self.cursorVisualY - (label.fontSize + label.lineSpacing)/2), true)
            elseif event.key == 264 then -- down
                self:placeCursorAt(rl.vec(self.savedCursorVisualX, self.cursorVisualY + (label.fontSize + label.lineSpacing)*1.5), true)
            end
        else
            self.savedCursorVisualX = -1 -- if you click a key that is not up or down; use actual x for this
        end
    end
    return false
end

function Textbox:isChangeOfType(lastc, newc)
    local lastIsSpace = lastc == " " or lastc == "\n" or lastc == "\t"
    local newIsSpace = newc == " " or newc == "\n" or newc == "\t"
    
    return lastIsSpace ~= newIsSpace
end

function Textbox:ctrlRepeatAction(action, additions, left, useLength)
    if not additions:Contains(2) then action(self) return end -- if there is no ctrl, do it once

    local offset = 1
    if left then offset = 0 end

    local position = self.cursorPosition + offset - 1

    local condition = function ()
        return position ~= self.cursorPosition + offset
    end

    local lastSize = #self.elements[1].text + 1
    if useLength then
        condition = function ()
            return #self.elements[1].text ~= lastSize
        end
    end

    while condition() do
        position = self.cursorPosition + offset
        lastSize = #self.elements[1].text

        local lastc = self.elements[1].text:sub(self.cursorPosition + offset, self.cursorPosition + offset)

        action(self)

        local newc = self.elements[1].text:sub(self.cursorPosition + offset, self.cursorPosition + offset)

        if self:isChangeOfType(lastc, newc) then
            return false
        end
    end

    return true
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