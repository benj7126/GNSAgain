local CRDTChar = {}
CRDTChar.Min = 0
CRDTChar.Max = 255 -- 255

-- TODO: Would be neat to use some math random that leans more towards lower values as you normally write and add forward?
function rnd(min, max)
    local v = max - min

    local r = math.random()
    -- return min + math.floor(v*r)
    -- return min + math.floor(v*r^4)
    return min + math.floor(v*(r/(1 + v/50)))
    -- return min
end


function CRDTChar:new(value)
    local c = {}
    setmetatable(c, self)
    self.__index = self

    c.path = {}
    c.value = value

    return c
end

function CRDTChar:newBetween(value, L, R)
    local c = CRDTChar:new(value)
    local lPath = L and L.path or {}
    local rPath = R and R.path or {}
    local len =  math.max(L and #L.path or 0, R and #R.path or 0)

    for i = 1, len do
        local l, r = lPath[i] or CRDTChar.Min, rPath[i] or CRDTChar.Max+1

        if l == r then
            table.insert(c.path, l)
        else
            local diff = math.abs(l - r)

            if diff == 2 then
                table.insert(c.path, l + 1)
                return c
            elseif diff == 1 then
                if i == len then
                    table.insert(c.path, l)
                    table.insert(c.path, rnd(CRDTChar.Min+1, (rPath[i+1] or CRDTChar.Max+1)-1))
                    return c
                else
                    table.insert(c.path, l)
                end
            else
                table.insert(c.path, rnd(l + 1, r - 1))
                return c
            end
        end
    end
    
    table.insert(c.path, rnd((lPath[len+1] or CRDTChar.Min) + 1, (rPath[len+1] or CRDTChar.Max+1) - 1))

    return c
end

function CRDTChar:__lt(other)
    if getmetatable(other) ~= CRDTChar then return true end -- true => nil at end, ig?

    for i = 1, math.max(#self.path, #other.path) do
        local l = self.path[i] or CRDTChar.Min
        local r = other.path[i] or (CRDTChar.Max + 1)

        if l ~= r then
            return l < r
        end
    end

    return false
end

function CRDTChar:__eq(other)
    if #self.path ~= #other.path then
        return false
    end

    for i = 1, #self.path do
        if self.path[i] ~= other.path[i] then
            return false
        end
    end

    return true
end

local CRDTDoc = {}

function CRDTDoc:new()
    local cd = {}
    setmetatable(cd, self)
    self.__index = self

    cd.chars = {}
    cd.text = ""
    cd.changed = true
    cd.gen = 0 -- like generation

    return cd
end

function CRDTDoc:valueAt(idx) -- char as in a character
    return self.chars[idx].value
end

function CRDTDoc:insertAt(char, idx) -- char as in a character
    print("insert at ", idx)
    self:insert(CRDTChar:newBetween(char, self.chars[idx], self.chars[idx+1]))
end

function CRDTDoc:removeAt(idx) -- char as in a character
    self.changed = true

    table.remove(self.chars, idx)
end

function CRDTDoc:removeRange(l, r) -- char as in a character
    self.changed = true

    for i = r, l, -1 do
        table.remove(self.chars, i)
    end
end

function CRDTDoc:getCharIdx(char) -- char as in a crdt character
    self.changed = true
    local left, right = 1, #self.chars + 1

    while left < right do
        local mid = math.floor((left + right) / 2)
        if self.chars[mid] < char then
            left = mid + 1
        else
            right = mid
        end
    end

    return left
end

function CRDTDoc:insert(char) -- char as in a crdt character
    self.changed = true

    io.write("Added: " .. char.value .. " [")
    for i = 1, #char.path do
            io.write(char.path[i])
        if i ~= #char.path then
            io.write(", ")
        end
    end
    print("]")

    table.insert(self.chars, self:getCharIdx(char), char)
end

function CRDTDoc:remove(char) -- char as in a crdt character
    self.changed = true

    table.remove(self.chars, self:getCharIdx(char))
end

function CRDTDoc:getText()
    if self.changed then
        self.text = ""
        for _, c in ipairs(self.chars) do
            self.text = self.text .. c.value
        end
        self.gen = (self.gen + 1) % 100000
    end

    return self.text
end

return CRDTDoc, CRDTChar