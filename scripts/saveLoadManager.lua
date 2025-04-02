local VarSpec = require("varSpec")

local classList = {}
function RegisterClass(metatable, className)
    classList[metatable] = className
    classList[className] = metatable
end

local function elmWorkspaceListHelper(list, ami, char)
    local highestNumber = 0;

    local newList = {}

    for i, subObj in pairs(list) do
        ami:enter(char.."-" .. i)
        ami:writeString("src", CreateStringFromObject(subObj, ami))
        ami:exit()

        if type(i) == "number" then
            if i > highestNumber then highestNumber = i end
        else
            table.insert(newList, i)
        end
    end
    
    return {highestNumber, newList}
end

local function breakdownObject(obj, indent, ami) -- this could be used for any object, really.
    local string = ""

    -- local MT = getmetatable(obj)
    -- local saveRules = {} -- might make the values mean things? probably not though...
    -- if MT and MT.saveRules then MT:saveRules(saveRules) else saveRules = nil end
    
    local onlyNumberIndex = true
    for i, _ in pairs(obj) do if type(i) ~= "number" then onlyNumberIndex = false end end


    local saveAll = false
    local MT = getmetatable(obj)
    if MT == nil then
        saveAll = true
    elseif type(MT) == "table" and MT.saveAll then
        saveAll = true
    end

    for i, v in pairs(obj) do
        if not saveAll then
            if getmetatable(v) == VarSpec and v.options.save == true then
                v = v.value
                i = i:sub(2, #i)
            else
                v = nil
            end
        end

        -- also check against base somehow...

        local t = type(v)

        if t == "table" then
            v = "{"..breakdownObject(v, indent.."\t", ami) .. "\n"..indent.."}"
        elseif t == "userdata" then
            v = nil -- currently dont save userdata
        elseif t == "function" then
            v = nil -- currently dont save functions
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
            if onlyNumberIndex then
                string = string .. "\n" .. indent .. v .. ","
            else
                string = string .. "\n" .. indent .. i .. " = " .. v .. ","
            end
        end
    end

    if obj.elements then
        string = string .. "\n" .. indent .. "elements = {"..breakdownObject(elmWorkspaceListHelper(obj.elements, ami, "e"), indent.."\t", ami) .. "\n"..indent.."},"
    end
    if obj.workspaces then
        string = string .. "\n" .. indent .. "workspaces = {"..breakdownObject(elmWorkspaceListHelper(obj.workspaces, ami, "w"), indent.."\t", ami) .. "\n"..indent.."},"
    end

    if obj.extraSave then
        obj:extraSave()
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

    if not ami then return ami end

    local elm = CreateObjectFromAMI(ami)
    ami:close()

    return elm
end

local function elmWorkspaceSetupListHelper(list, ami, char)
    local objCount = list[1]
    local objList = list[2]

    local newObjects = {}

    for i = 1, objCount do
        ami:enter(char.."-"..i)
        local obj = CreateObjectFromAMI(ami)
        newObjects[i] = obj
        ami:exit()
    end

    for _, v in pairs(objList) do
        ami:enter(char.."-"..v)
        local obj = CreateObjectFromAMI(ami)
        newObjects[v] = obj
        ami:exit()
    end

    return newObjects
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
    if modifications.elements then
        newElements = elmWorkspaceSetupListHelper(modifications.elements, ami, "e")
    end

    local newWorkspaces = nil
    if modifications.workspaces then
        newWorkspaces = elmWorkspaceSetupListHelper(modifications.workspaces, ami, "w")
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