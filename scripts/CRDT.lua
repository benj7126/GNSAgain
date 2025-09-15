local CRDTChar = {}
CRDTChar.Min = 0
CRDTChar.Max = 255

-- TODO: Would be neat to use some math random that leans more towards lower values as you normally write and add forward?


function CRDTChar:new(value)
    local c = {}
    setmetatable(c, self)
    self.__index = self

    c.path = {}
    c.value = value

    return c
end

local function handleAdjacentValues(path, lPath, rPath, i)
    local leftVal = lPath[i] or CRDTChar.Min
    local rightVal = rPath[i] or CRDTChar.Max
    local leftNext = lPath[i+1] or CRDTChar.Min
    local rightNext = rPath[i+1] or CRDTChar.Max
    
    if math.random() < 0.5 then -- pick a random side
        -- left side
        table.insert(path, leftVal)
        table.insert(path, math.random(leftNext, CRDTChar.Max))
        if leftNext == CRDTChar.Max then
            table.insert(path, math.random(CRDTChar.Min, CRDTChar.Max))
        end
    else
        -- right side, fallback to left if no room
        if rightNext ~= CRDTChar.Min then
            table.insert(path, rightVal)
            table.insert(path, math.random(CRDTChar.Min, rightNext))
        else
            table.insert(path, leftVal)
            table.insert(path, math.random(leftNext, CRDTChar.Max))
            if leftNext == CRDTChar.Max then
                table.insert(path, math.random(CRDTChar.Min, CRDTChar.Max))
            end
        end
    end
end

function CRDTChar:newBetween(value, L, R)
    local c = CRDTChar:new(value)
    local lPath = L and L.path or {}
    local rPath = R and R.path or {}

    print(L, R)
    if L then
        io.write("L is: " .. L.value .. " [")
        for i = 1, #L.path do
                io.write(L.path[i])
            if i ~= #L.path then
                io.write(", ")
            end
        end
        print("]")
    end
    if R then
        io.write("R is: " .. R.value .. " [")
        for i = 1, #R.path do
                io.write(R.path[i])
            if i ~= #R.path then
                io.write(", ")
            end
        end
        print("]")
    end

    if #lPath == 0 and #rPath == 0 then
        c.path = {math.random(CRDTChar.Min, CRDTChar.Max)}
        return c
    end

    local maxLen = math.max(#lPath, #rPath)

    if not R then -- fill r to enforce it being 'max'.
        maxLen = maxLen + 1
        for _ = 1, #lPath-1 do
            table.insert(rPath, CRDTChar.Max)
        end
        table.insert(rPath, CRDTChar.Max+1)
    end

    for i = 1, maxLen do
        local l = lPath[i] or (CRDTChar.Min - 1)
        local r = rPath[i] or (CRDTChar.Max + 1)

        print("checking", l, r)
        if l == r then
            print("added", l, r)
            table.insert(c.path, l)
        else
            local diff = math.abs(l - r)
            if diff == 2 then
                table.insert(c.path, l + 1)
            elseif diff == 1 then
                handleAdjacentValues(c.path, lPath, rPath, i)
            else
                print(l, r)
                table.insert(c.path, math.random(l + 1, r - 1)) -- math.min for making default rPath work
            end
            return c
        end
    end

    return c
end

function CRDTChar:__lt(other)
    if getmetatable(other) == CRDTChar then return true end -- true => nil at end, ig?

    for i = 1, math.max(#self.path, #other.path) do
        local l = self.path[i] or (CRDTChar.Min - 1)
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
        if self.chars < char then
            left = mid + 1
        else
            right = mid
        end
    end

    print("Got physical idx; ", left)

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