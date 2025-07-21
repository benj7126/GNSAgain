local Element = require("elements.element")
local Label = Element:from()
RegisterClass(Label, "Label")
local VarSpec = require("varSpec")

function Label:new(forLoad)
    local label = Element.new(Label)

    label.text = VarSpec:new("")
    label.lines = {}

    label.fontName = VarSpec:new("")
    label.fontSize = VarSpec:new(20)

    label.color = VarSpec:new(rl.color(0,0,0)) -- unsure if this actually works well

    label.spacing = VarSpec:new(0.2)
    label.lineSpacing = VarSpec:new(0.2)

    label.xCenter = VarSpec:new(false)
    label.yCenter = VarSpec:new(false)
    label.textWidth = 0
    label.textHeight = 0

    label.textSizeFit = VarSpec:new(false)

    label.wrapping = VarSpec:new(1) --[[
    enum Wrapping
    {
        CharWrapping, // normal(?) wrapping 0
        WordWrapping, // word wrappoing 1
        NoWrapping // no wrapping at all 2
    } ]]

    -- tb.highlightPosition = -1; should be a seperate thing?

    local resize = label.resize
    label.resize = function(self, ...)
        resize(self, ...)
        self:prepare() -- dont have to prepare everything every time i resize something above me.
                       -- might just be fixed by elements workspace not having to recalc any sub-elements though..?
    end

    return label
end

local LabelBuilder = {}

function LabelBuilder:new(textbox, mousePos)
    local lb = {}
    setmetatable(lb, self)
    self.__index = self
    
    lb.tb = textbox

    lb.textOffsetX = 0
    lb.peakTextOffsetX = 0

    return lb
end

function LabelBuilder:insertBuffer(lineBuffer, codepointBuffer)
    for _, cpNWidth in pairs(codepointBuffer) do
        self.textOffsetX = self.textOffsetX + cpNWidth[2];

        table.insert(lineBuffer, {codepoint = cpNWidth[1], width = cpNWidth[2]})
    end
end

function Label:prepare()
    self.lines = {}

    local CpC = rl.getCodepointCounter(self.text, self.fontName, self.fontSize, self.spacing)
    local LB = LabelBuilder:new(self, false) -- true if i have a cursor position

    local codepointBuffer = {} -- List<Tuple<int, float>>;
    local codepointBufferWidth = 0 -- float;

    local lineBuffer = {} -- List<TextboxChars>;
    local lineWidth = 0 -- float;

    while CpC:hasNext() do
        local codepoint, charWidth, nextCharWidth = CpC:nexCodepoint();

        if codepoint == 10 then -- if newline
            LB:insertBuffer(lineBuffer, codepointBuffer)
            codepointBuffer = {}

            --LB:insertBuffer(lineBuffer, {{32, 0}}) -- insert space with no width at end for making it work well, iirc
                                                   -- might not mean anything...

                                                   -- i will have to try without this and see if it works the same (after everything is up and running)
            table.insert(self.lines, lineBuffer)
            lineBuffer = {}
            codepointBufferWidth = 0
            lineWidth = 0
            
            LB:insertBuffer(lineBuffer, {{32, 0}}) -- welp, its down here...
                                                   -- it works here, so let it be

            LB.peakTextOffsetX = math.max(LB.peakTextOffsetX, LB.textOffsetX)
            LB.textOffsetX = 0
        else
            table.insert(codepointBuffer, {codepoint, charWidth})
            codepointBufferWidth = codepointBufferWidth + charWidth

            -- 32 = ' ' | 9 = '\t'                   character(0) or no wrapping(2)
            if codepoint == 32 or codepoint == 9 or self.wrapping == 0 or self.wrapping == 2 or lineWidth + nextCharWidth + codepointBufferWidth > self.es.w then

                if lineWidth + nextCharWidth + codepointBufferWidth > self.es.w and self.wrapping ~= 2 and not (codepoint == 32 or codepoint == 9) then
                    -- if word wrapping
                    if self.wrapping == 1 and lineWidth ~= 0 then
                        table.insert(self.lines, lineBuffer)
                        lineBuffer = {}
                        lineWidth = 0
                    else
                        LB:insertBuffer(lineBuffer, codepointBuffer)
                        table.insert(self.lines, lineBuffer)
                        lineBuffer = {}
                        lineWidth = 0

                        codepointBuffer = {}
                        codepointBufferWidth = 0
                    end

                    LB.peakTextOffsetX = math.max(LB.peakTextOffsetX, LB.textOffsetX)
                    LB.textOffsetX = 0
                else
                    LB:insertBuffer(lineBuffer, codepointBuffer)
                    codepointBuffer = {}
                    lineWidth = lineWidth + codepointBufferWidth
                    codepointBufferWidth = 0
                end
            end
        end
    end

    LB:insertBuffer(lineBuffer, codepointBuffer);
    table.insert(self.lines, lineBuffer)
    lineWidth = lineWidth + codepointBufferWidth
    codepointBufferWidth = 0

    self.textHeight = #self.lines * (self.fontSize + self.lineSpacing) - self.lineSpacing
    self.textWidth = math.max(LB.peakTextOffsetX, LB.textOffsetX)

    if self.textSizeFit then
        local widthRatio = self.es.w / self.textWidth
        local heightRatio = self.es.h / self.textHeight

        local newFontSize = 1
        if widthRatio < heightRatio then -- adjust with width ratio
            newFontSize = math.floor(self.fontSize * widthRatio)
        else -- adjust with height ratio
            newFontSize = math.floor(self.fontSize * heightRatio)
        end

        local actualRatio = newFontSize / self.fontSize
        self.textHeight = self.textHeight * actualRatio
        self.textWidth = self.textWidth * actualRatio

        self.fontSize = newFontSize

        for _, line in pairs(self.lines) do
            for _, char in pairs(line) do
                char.width = char.width * actualRatio
            end
        end
    end
end

function Label:draw()
    local font = rl.getFont(self.fontName, self.fontSize);

    local startX = 0
    if self.xCenter then
        startX = (self.es.w - self.textWidth) / 2
    end
    
    local textOffsetY = 0
    local textOffsetX = startX

    if self.yCenter then
        textOffsetY = (self.es.h - self.textHeight) / 2
    end

    for _, line in pairs(self.lines) do
        for _, char in pairs(line) do
            -- dont draw invisible shit
            if char.codepoint ~= 32 and char.codepoint ~= 9 then
                rl.drawTextCodepoint(font, char.codepoint, rl.vec(self.es.x + textOffsetX, self.es.y + textOffsetY), self.fontSize, self.color)
            end

            textOffsetX = textOffsetX + char.width
        end

        textOffsetY = textOffsetY + self.fontSize + self.lineSpacing
        textOffsetX = startX
    end
end

return Label