local Element = require("elements.element")
local Label = require("elements.label")
local Textbox = Element:from()
RegisterClass(Textbox, "Textbox")
local VarSpec = require("varSpec")

-- would like to write this less ugly.
-- would like even more to have a program though; so later.

-- "static variables"
Textbox.cursorVisualX = 0;
Textbox.cursorVisualY = 0;

Textbox.heldMode = 0;

Textbox.savedCursorVisualX = -1;
Textbox.cursorPosition = 0;

Textbox.highlightPosition = -1;

function Textbox:new(forLoad)
    local tb = Element.new(Textbox, forLoad)

    local draw = require("modules.draw.reverseDraw")
    tb.draw = function(...)
        if not tb.elements.label.lines then
            -- write to console thing that this wants a label as its first child
            return
        end

        draw(...)

        local label = tb.elements.label
        rl.rec(label.es.x + Textbox.cursorVisualX, label.es.y + Textbox.cursorVisualY, 1, label.fontSize, tb.cursorColor);
    end

    tb.highlightColor = VarSpec:new(rl.color(0, 0, 200, 100))
    tb.cursorColor = VarSpec:new(rl.color(255, 150, 0))

    -- if it is loaded from disc then it will already have a label.
    if not forLoad then
        local label = Label:new()
        label.es.width.percent = 1
        label.es.height.percent = 1

        label.text = ""

        tb.elements.label = label
    end

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
    local label = self.elements.label

    local curIndex = 0
    local textOffsetY = 0
    local textOffsetX = 0

    for _, line in pairs(label.lines) do
        if curIndex + #line >= Textbox.cursorPosition then
            for _, char in pairs(line) do
                if Textbox.cursorPosition == curIndex then
                    Textbox.cursorVisualX = textOffsetX
                    Textbox.cursorVisualY = textOffsetY
                    return
                end
    
                curIndex = curIndex + 1
                textOffsetX = textOffsetX + char.width;
            end
            
            Textbox.cursorVisualX = textOffsetX
            Textbox.cursorVisualY = textOffsetY
            return
        end

        curIndex = curIndex + #line
        textOffsetY = textOffsetY + label.fontSize + label.lineSpacing;
    end
end

function Textbox:placeCursorOnLineAt(vec, line, curIndex)
    local label = self.elements.label
    -- local spacing = label.spacing
    local textOffsetX = label.es.x

    for _, char in pairs(line) do
        if textOffsetX + char.width*0.5 > vec.X then -- textOffsetX + char.width - (char.width - spacing)/2
            Textbox.cursorVisualX = textOffsetX
            Textbox.cursorPosition = curIndex
            return
        end

        curIndex = curIndex + 1
        textOffsetX = textOffsetX + char.width;
    end

    Textbox.cursorVisualX = textOffsetX
    Textbox.cursorPosition = curIndex
end

-- outOfBoundsFrontEnd makes it so that if its out of bounds, it will place at start (if above) or end (if below)
function Textbox:placeCursorAt(vec, outOfBoundsStartEnd) -- forceEOL, been replaced by 'correctCusorVisual'
    local label = self.elements.label
    outOfBoundsStartEnd = outOfBoundsStartEnd or false

    local curIndex = 0

    local yLine = math.floor((vec.Y - label.es.y) / (label.fontSize + label.lineSpacing))

    if yLine < 0 then
        Textbox.cursorVisualY = label.es.y

        if outOfBoundsStartEnd then -- or not label.lines[1] then | theres always 1 line (if its been calculated)
            Textbox.cursorVisualX = label.es.x
            Textbox.cursorPosition = 0
        else
            self:placeCursorOnLineAt(vec, label.lines[1], curIndex)
        end
        return
    end

    -- count characters in above line(s)
    for i = 1, yLine do
        if label.lines[i+1] then
            curIndex = curIndex + #label.lines[i]
        else
            if outOfBoundsStartEnd then
                Textbox.cursorPosition = #label.text
                self:correctCusorVisual()
                return
            end

            Textbox.cursorVisualY = (i-1) * (label.fontSize + label.lineSpacing)
            self:placeCursorOnLineAt(vec, label.lines[i], curIndex)

            return
        end
    end

    Textbox.cursorVisualY = (yLine) * (label.fontSize + label.lineSpacing)
    self:placeCursorOnLineAt(vec, label.lines[yLine+1], curIndex)
end

function Textbox:draw()
    local label = self.elements.label

    local curIndex = 0
    local textOffsetY = 0
    local textOffsetX = 0

    for _, line in pairs(label.lines) do
        for _, char in pairs(line) do
            if Textbox.highlightPosition ~= Textbox.cursorPosition and Textbox.highlightPosition ~= -1 and InBetween(curIndex, Textbox.highlightPosition, Textbox.cursorPosition) then
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
    local label = self.elements.label

    label.text = label.text:sub(1, Textbox.cursorPosition) .. label.text:sub(Textbox.cursorPosition+2, #label.text)
end

function Textbox:backspace()
    local label = self.elements.label
    
    if Textbox.cursorPosition ~= 0 then
        label.text = label.text:sub(1, Textbox.cursorPosition-1) .. label.text:sub(Textbox.cursorPosition+1, #label.text)

        Textbox.cursorPosition = Textbox.cursorPosition - 1
    end
end

function Textbox:right()
    local label = self.elements.label
    if Textbox.cursorPosition ~= #self.elements.label.text then
        local movePast = label.text:sub(Textbox.cursorPosition+1, Textbox.cursorPosition+1)
        
        if movePast ~= "\n" then
            Textbox.cursorVisualX = Textbox.cursorVisualX + rl.getCharWidth(movePast, label.fontName, label.fontSize, label.spacing)
        else
            Textbox.cursorVisualX = 0
            Textbox.cursorVisualY = Textbox.cursorVisualY + label.fontSize + label.lineSpacing
        end

        Textbox.cursorPosition = Textbox.cursorPosition + 1
    end
end

function Textbox:left()
    local label = self.elements.label

    if Textbox.cursorPosition ~= 0 then
        local movePast = label.text:sub(Textbox.cursorPosition, Textbox.cursorPosition)

        Textbox.cursorPosition = Textbox.cursorPosition - 1

        if movePast == "\n" then
            self:correctCusorVisual()
            -- self:placeCursorAt(rl.vec(0, Textbox.cursorVisualY - (label.fontSize + label.lineSpacing)/2), true)
        else
            Textbox.cursorVisualX = Textbox.cursorVisualX - rl.getCharWidth(movePast, label.fontName, label.fontSize, label.spacing)
        end
    end
end

function Textbox:deleteSelectedArea()
    local label = self.elements.label

    if Textbox.highlightPosition ~= -1 then
        if Textbox.highlightPosition < Textbox.cursorPosition then
            local hp = Textbox.highlightPosition
            Textbox.highlightPosition = Textbox.cursorPosition
            Textbox.cursorPosition = hp
        end

        label.text = label.text:sub(1, Textbox.cursorPosition) .. label.text:sub(Textbox.highlightPosition+1, #label.text)
    end
end

function Textbox:handleEvent(event)
    local label = self.elements.label

    if event.type == "mousepress" then
        rl.setInput(event)

        Textbox.highlightPosition = -1
        Textbox.savedCursorVisualX = -1
        
        Textbox.heldMode = math.fmod(event.presses-1, 3)+1
        if Textbox.heldMode == 1 then
            self:placeCursorAt(event.pos)
        end

        PreNextEvent("mouserelease", function(nEvent)
            Textbox.heldMode = 0

            return true
        end)

        PostNextEvent("mousemoved", function(nEvent) -- needs to be global
            if Textbox.heldMode == 0 then return true end
            
            local pastCursorPos = Textbox.cursorPosition
            self:placeCursorAt(nEvent.pos)

            if pastCursorPos ~= Textbox.cursorPosition and Textbox.highlightPosition == -1 then
                Textbox.highlightPosition = pastCursorPos
            end

            return false
        end)

        return true
    elseif event.type == "input" then
        if not label.lines then
            -- write to console thing that this wants a label as its first child
            return
        end

        if Textbox.highlightPosition ~= -1 then
            self:deleteSelectedArea()
            Textbox.highlightPosition = -1
        end
        
        Textbox.savedCursorVisualX = -1

        label.text = label.text:sub(1, Textbox.cursorPosition) .. event.key .. label.text:sub(Textbox.cursorPosition+1, #label.text)
        Textbox.cursorPosition = Textbox.cursorPosition + 1

        -- Textbox.cursorVisualX = Textbox.cursorVisualX + rl.getCharWidth(event.key, label.fontName, label.fontSize, label.spacing)
        label:prepare() -- TODO: ideally i would like to only update from the change, and as little as possible
        self:correctCusorVisual() -- well, what if wrap..?
        -- self:updateVisualCursor() should be able to calculate the location on the run.
    elseif event.type == "specialKey" then
        if event.key >= 262 and event.key <= 265 then -- any movement key
            if rl.isShiftDown() and Textbox.highlightPosition == -1 then
                Textbox.highlightPosition = Textbox.cursorPosition
            elseif not rl.isShiftDown() then
                Textbox.highlightPosition = -1
            end
        end

        if event.key == 261 or event.key == 259 or event.key == 257 then
            local wasHighlight = Textbox.highlightPosition

            if Textbox.highlightPosition == -1 then
                if event.key == 261 then -- delete
                    self:ctrlRepeatAction(self.delete, event.additions, false, true)
                elseif event.key == 259 then -- backspace
                    self:ctrlRepeatAction(self.backspace, event.additions, true);
                end
            else
                self:deleteSelectedArea()
                Textbox.highlightPosition = -1
            end
            
            if event.key == 257 then -- enter
                label.text = label.text:sub(1, Textbox.cursorPosition) .. "\n" .. label.text:sub(Textbox.cursorPosition+1, #label.text)
    
                Textbox.cursorVisualY = Textbox.cursorVisualY + label.fontSize + label.lineSpacing
                Textbox.cursorVisualX = 0
                Textbox.cursorPosition = Textbox.cursorPosition + 1
            end

            label:prepare() -- ideally from Textbox.cursorPosition until "out of bounds"
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
            if Textbox.savedCursorVisualX == -1 then
                Textbox.savedCursorVisualX = Textbox.cursorVisualX
            end

            if event.key == 265 then -- up
                self:placeCursorAt(rl.vec(Textbox.savedCursorVisualX, Textbox.cursorVisualY - (label.fontSize + label.lineSpacing)/2), true)
            elseif event.key == 264 then -- down
                self:placeCursorAt(rl.vec(Textbox.savedCursorVisualX, Textbox.cursorVisualY + (label.fontSize + label.lineSpacing)*1.5), true)
            end
        else
            Textbox.savedCursorVisualX = -1 -- if you click a key that is not up or down; use actual x for this
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

    local position = Textbox.cursorPosition + offset - 1

    local condition = function ()
        return position ~= Textbox.cursorPosition + offset
    end

    local lastSize = #self.elements.label.text + 1
    if useLength then
        condition = function ()
            return #self.elements.label.text ~= lastSize
        end
    end

    while condition() do
        position = Textbox.cursorPosition + offset
        lastSize = #self.elements.label.text

        local lastc = self.elements.label.text:sub(Textbox.cursorPosition + offset, Textbox.cursorPosition + offset)

        action(self)

        local newc = self.elements.label.text:sub(Textbox.cursorPosition + offset, Textbox.cursorPosition + offset)

        if self:isChangeOfType(lastc, newc) then
            return false
        end
    end

    return true
end

RegisterClass(Textbox, "Textbox")

return Textbox