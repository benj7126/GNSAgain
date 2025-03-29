-- should generate and create element from string
-- use C# to read and write - so that it uses that
-- fancy zipfile-like structure

local classList = {}
function RegisterClass(metatable, className)
    classList[metatable] = className
    classList[className] = metatable
end

local function breakdownObject(obj, indent, ami) -- this could be used for any object, really.
    local string = ""

    local MT = getmetatable(obj)
    local saveRules = {} -- might make the values mean things? probably not though...
    if MT and MT.saveRules then MT:saveRules(saveRules) else saveRules = nil end

    for i, v in pairs(obj) do
        if saveRules then
            if not saveRules[i] then v = nil end -- if not in save, dont save it.
        end
        
        local t = type(v)
        
        if t == "table" then
            v = "{"..breakdownObject(v, indent.."\t", ami) .. "\n"..indent.."}"
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

    if obj.elements then
        for i, subObj in pairs(obj.elements) do
            ami:enter("e-" .. tostring(i))
            ami:writeString("src", CreateStringFromObject(subObj, ami))
            ami:exit()
        end
        
        string = string .. "\n" .. indent .. "elements = " .. #obj.elements .. ","
    end

    if obj.workspaces then
        for i, subObj in pairs(obj.workspaces) do
            ami:enter("w-" .. tostring(i))
            ami:writeString("src", CreateStringFromObject(subObj, ami))
            ami:exit()
        end
        
        string = string .. "\n" .. indent .. "workspaces = " .. #obj.workspaces .. ","
    end

    return string:sub(0, #string-1)
end

function CreateStringFromObject(obj, ami)
    if not classList[getmetatable(obj)] then
        -- error about saving element
        return nil
    end

    local string = "return {" .. breakdownObject(obj, "\t", ami)
    local output = string .. '\n}, "' .. classList[getmetatable(obj)] .. '"'

    return output
end

function SaveObject(obj, path)
    local ami = getAMI(path, 2) -- tmp
    ami:writeString("src", CreateStringFromObject(obj, ami))
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

function LoadObject(path)
    local ami = getAMI(path, 3) -- tmp
    local elm = CreateObjectFromAMI(ami)
    ami:close()

    return elm
end

function CreateObjectFromAMI(ami)
    local str = ami:readString("src")
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
            ami:enter("e-"..tostring(i))
            local obj = CreateObjectFromAMI(ami)
            newElements[i] = obj
            ami:exit()
        end
    end

    local newWorkspaces = nil
    if modifications.workspaces and type(modifications.workspaces) == "number" then -- should this be some id/uuid instead of idx???
        local workspaceCount = modifications.workspaces
        modifications.workspaces = nil
        
        newWorkspaces = {}

        for i = 1, workspaceCount do
            ami:enter("w-"..tostring(i))
            local obj = CreateObjectFromAMI(ami)
            newWorkspaces[i] = obj
            ami:exit()
        end
    end

    local useOwnElementList = false
    if newElements then useOwnElementList = true end
    local obj = classList[class]:new(useOwnElementList)

    applyModification(obj, modifications)

    if newElements then
        obj.elements = newElements
    end
    if newWorkspaces then
        obj.workspaces = newWorkspaces
    end

    return obj
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