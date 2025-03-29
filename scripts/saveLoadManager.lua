-- should generate and create element from string
-- use C# to read and write - so that it uses that
-- fancy zipfile-like structure

local classList = {}
function RegisterClass(metatable, className)
    classList[metatable] = className
    classList[className] = metatable
end

local function breakdownObject(elm, indent, ami) -- this could be used for any object, really.
    local string = ""

    local MT = getmetatable(elm)
    local saveRules = {} -- might make the values mean things? probably not though...
    if MT and MT.saveRules then MT:saveRules(saveRules) else saveRules = nil end

    for i, v in pairs(elm) do
        if saveRules then
            if not saveRules[i] then v = nil end -- if not in save, dont save it.
        end
        
        local t = type(v)
        
        if t == "table" then
            v = "{"..breakdownObject(v, indent.."\t") .. "\n"..indent.."}"
        elseif t == "userdata" then
            v = nil
        elseif t == "function" then
            v = nil
        elseif t == "boolean" then
            if v then
                v = "true"
            else
                v = "false"
            end
        elseif t == "string" then
            v = '[[' .. v .. ']]'
        end

        if v then
            string = string .. "\n" .. indent .. i .. " = " .. v .. ","
        end
    end

    if elm.elements then
        for i, subElm in pairs(elm.elements) do
            ami:enter(tostring(i))
            ami:writeString("elm.src", CreateStringFromElement(subElm, ami))
            ami:exit()
        end
        
        string = string .. "\n" .. indent .. "elements = " .. #elm.elements .. ","
    end

    return string:sub(0, #string-1)
end

function CreateStringFromElement(elm, ami)
    if not classList[getmetatable(elm)] then
        -- error about saving element
        return nil
    end

    local string = "return {" .. breakdownObject(elm, "\t", ami)
    local output = string .. '\n}, "' .. classList[getmetatable(elm)] .. '"'

    return output
end

function SaveElement(elm, path)
    local ami = getAMI(path, 2) -- tmp
    ami:writeString("elm.src", CreateStringFromElement(elm, ami))
    ami:close()
end

local function applyModification(table, mod)
    for i, v in pairs(mod) do
        local didGoDownDepth = false
        if type(v) == "table" then
            if table[i] then
                applyModification(table[i], v)
                didGoDownDepth = true
            end
        end

        if not didGoDownDepth then table[i] = v end
    end
end

function LoadElement(path)
    local ami = getAMI(path, 3) -- tmp
    local elm = CreateElementFromAMI(ami)
    ami:close()

    return elm
end

function CreateElementFromAMI(ami)
    local str = ami:readString("elm.src")
    print(str, "elm.src")
    local chunk, err = load(str)
    if not chunk then
        print(err)
        return nil
        -- writte err to 'console'
    end

    local modifications, class = chunk()

    if not classList[class] then
        if class == nil then class = "nil" end
        print("No such class [" .. class .. "], make sure to register classes with \"RegisterClass(MT, name)\"")
        return nil
    end

    -- we override elements in the elm, because if the elements are not the same as when created, it might
    -- try to treat the elements weirdly and it would be better to just trust the save file...
    -- but this also means that there should be a way to not append elements when creating an element with :new().
    local newElements = nil
    if modifications.elements and type(modifications.elements) == "number" then -- should this be some id/uuid instead of idx???
        local elementCount = modifications.elements
        modifications.elements = nil
        
        newElements = {}

        for i = 1, elementCount do
            ami:enter(tostring(i))
            local elm = CreateElementFromAMI(ami)
            newElements[i] = elm
            ami:exit()
        end
    end

    local useOwnElementList = false
    if newElements then useOwnElementList = true end
    local elm = classList[class]:new(useOwnElementList)

    applyModification(elm, modifications)

    if newElements then
        elm.elements = newElements
    end

    return elm
end

-- should only really work for workspaces
-- that contain elements
-- wouldnt want to save the splits
-- of a workspace (well, maby - but 
-- only if its actually open, ig)
function CreateStringFromWorkspace()
    
end

function CreateWorkspaceFromString()
    
end