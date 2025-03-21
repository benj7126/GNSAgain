local Element = require("elements.element")
local Label = Element:from()

function Label:new()
    local label = Element.new(Label)

    label.text = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sagittis tempor sapien, a pharetra est iaculis varius. Proin tempor mauris non consectetur iaculis. Proin a orci convallis erat finibus pharetra. Mauris elit massa, vehicula eget rutrum at, elementum eget purus. Mauris congue ex nisi, sed suscipit lacus posuere auctor. Donec quis aliquam urna. Morbi et imperdiet mauris. Donec sit amet aliquam ipsum. Cras egestas massa vulputate mauris imperdiet condimentum. Sed pharetra ex a odio placerat, quis rhoncus nibh porta. Praesent sed sem in mauris gravida tempus. In viverra nibh vitae sapien scelerisque malesuada. Maecenas a euismod turpis.
Suspendisse euismod semper ultricies. Ut et odio purus. Mauris augue mauris, bibendum vitae auctor non, consequat aliquam quam. Curabitur eget vehicula odio. Morbi ut est ultricies, maximus mi eget, sollicitudin elit. Morbi sit amet odio ac ante egestas faucibus. Nam blandit lorem luctus arcu finibus dignissim. Sed facilisis commodo consectetur. Suspendisse mattis venenatis mattis. Mauris blandit malesuada imperdiet.
Praesent ac magna ac mi commodo aliquet. Cras in scelerisque purus. Integer at felis sed nulla semper sollicitudin eu quis mi. Sed tristique, turpis et eleifend scelerisque, lorem ipsum semper lorem, vitae elementum nulla urna a lacus. Sed feugiat metus et urna convallis, nec aliquam massa pellentesque. Integer pellentesque erat eget sapien dapibus blandit. Donec egestas tempus odio, at mollis mauris. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Etiam rhoncus consectetur turpis vitae facilisis. Etiam finibus libero auctor ornare cursus. Vestibulum posuere sodales eros a eleifend. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin elit lectus, dictum et metus at, tempor aliquet magna. Fusce et ligula in velit dignissim efficitur in tempor nibh.
Nulla semper nibh eu dolor pellentesque, a tristique nulla porttitor. Morbi vitae sem vitae sem rhoncus rhoncus at in tellus. Proin orci diam, placerat id laoreet ac, rutrum sed odio. Etiam sed sollicitudin metus. Curabitur rutrum, purus nec rhoncus tristique, leo metus mattis massa, at ultrices risus nunc sed orci. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Phasellus maximus dui facilisis tincidunt finibus. Donec vel dolor eget neque suscipit feugiat. Morbi tellus nunc, varius a mauris accumsan, cursus porttitor sem. Sed id nulla pretium, venenatis velit egestas, blandit ex. Fusce vitae leo id mauris eleifend tempus. Cras vestibulum eros a lectus lobortis varius. Pellentesque sit amet enim elementum, ultrices lectus ullamcorper, dignissim nibh. Mauris a porttitor orci. Mauris sed rhoncus tortor.
Etiam vehicula, lorem mollis laoreet tristique, leo ex tristique risus, quis varius orci elit mollis est. Phasellus semper dignissim est, sed rutrum felis eleifend quis. Cras mattis et risus et volutpat. Fusce et scelerisque arcu. Duis fringilla placerat vestibulum. Maecenas pharetra nisl in ante pellentesque facilisis. Aliquam imperdiet mauris vitae molestie malesuada. Curabitur a lectus vel est dictum molestie non vel urna. Morbi tortor mi, congue eu enim nec, aliquet viverra justo. Vestibulum nec dui vitae leo eleifend rhoncus et nec lectus. Vivamus auctor felis quam, sed blandit velit finibus nec. In odio turpis, hendrerit vel sem in, faucibus aliquet nunc. Vivamus eget erat vitae dolor faucibus dapibus. Quisque suscipit finibus laoreet]]
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
        self:prepTB(self.es.x, self.es.y, self.es.w, self.es.h)
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

function Label:prepTB(x, y, w, h)
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

            LB:InsertBuffer(lineBuffer, {{32, 0}}) -- insert space with no width at end for making it work well, iirc
            table.insert(self.lines, lineBuffer)
            lineBuffer = {}
            codepointBufferWidth = 0
            lineWidth = 0

            LB.peakTextOffsetX = math.max(LB.peakTextOffsetX, LB.textOffsetX)
            LB.textOffsetX = 0
        else
            table.insert(codepointBuffer, {codepoint, charWidth})
            codepointBufferWidth = codepointBufferWidth + charWidth

            -- 32 = ' ' | 9 = '\t'                   character(0) or no wrapping(2)
            if codepoint == 32 or codepoint == 9 or self.wrapping == 0 or self.wrapping == 2 or lineWidth + nextCharWidth + codepointBufferWidth > w then

                if lineWidth + nextCharWidth + codepointBufferWidth > w and self.wrapping ~= 2 and not (codepoint == 32 or codepoint == 9) then
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