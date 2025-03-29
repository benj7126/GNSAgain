local Element = require("elements.element")
local Label = Element:from()
RegisterClass(Label, "Label")

function Label:saveRules(rules)
    Element:saveRules(rules)
    rules["text"] = 0
    rules["fontName"] = 0
    rules["fontSize"] = 0
    rules["color"] = 0
    rules["spacing"] = 0
    rules["lineSpacing"] = 0
    rules["textWidth"] = 0
    rules["wrapping"] = 0
end

function Label:new(forLoad)
    local label = Element.new(Label)

    label.text = ""
    label.lines = {}

    label.fontName = ""
    label.fontSize = 20

    label.color = rl.color(0,0,0)

    label.spacing = 0.2
    label.lineSpacing = 0.2

    label.textWidth = 0

    label.wrapping = 1 --[[
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
        self:prepTB()
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

function LabelBuilder:InsertBuffer(lineBuffer, codepointBuffer)
    for _, cpNWidth in pairs(codepointBuffer) do
        self.textOffsetX = self.textOffsetX + cpNWidth[2];

        table.insert(lineBuffer, {codepoint = cpNWidth[1], width = cpNWidth[2]})
    end
end

function Label:prepTB()
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
            LB:InsertBuffer(lineBuffer, codepointBuffer)
            codepointBuffer = {}

            --LB:InsertBuffer(lineBuffer, {{32, 0}}) -- insert space with no width at end for making it work well, iirc
                                                   -- might not mean anything...

                                                   -- i will have to try without this and see if it works the same (after everything is up and running)
            table.insert(self.lines, lineBuffer)
            lineBuffer = {}
            codepointBufferWidth = 0
            lineWidth = 0
            
            LB:InsertBuffer(lineBuffer, {{32, 0}}) -- welp, its down here...
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
                        LB:InsertBuffer(lineBuffer, codepointBuffer)
                        table.insert(self.lines, lineBuffer)
                        lineBuffer = {}
                        lineWidth = 0

                        codepointBuffer = {}
                        codepointBufferWidth = 0
                    end

                    LB.peakTextOffsetX = math.max(LB.peakTextOffsetX, LB.textOffsetX)
                    LB.textOffsetX = 0
                else
                    LB:InsertBuffer(lineBuffer, codepointBuffer)
                    codepointBuffer = {}
                    lineWidth = lineWidth + codepointBufferWidth
                    codepointBufferWidth = 0
                end
            end
        end
    end

    LB:InsertBuffer(lineBuffer, codepointBuffer);
    table.insert(self.lines, lineBuffer)
    lineWidth = lineWidth + codepointBufferWidth
    codepointBufferWidth = 0

    self.textWidth = math.max(LB.peakTextOffsetX, LB.textOffsetX)
end

function Label:draw()
    local font = rl.getFont(self.fontName, self.fontSize);

    local textOffsetY = 0
    local textOffsetX = 0

    for _, line in pairs(self.lines) do
        for _, char in pairs(line) do
            -- dont draw invisible shit
            if char.codepoint ~= 32 and char.codepoint ~= 9 then
                rl.drawTextCodepoint(font, char.codepoint, rl.vec(self.es.x + textOffsetX, self.es.y + textOffsetY), self.fontSize, self.color);
            end

            textOffsetX = textOffsetX + char.width;
        end

        textOffsetY = textOffsetY + self.fontSize + self.lineSpacing;
        textOffsetX = 0;
    end
end

return Label