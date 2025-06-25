local enumerator = _modules:GetEnumerator()

local function dict_iterator(state)
    if state:MoveNext() then
        local current_pair = state.Current
        return current_pair.Key, current_pair.Value
    else
        return nil
    end
end

for key, _ in dict_iterator, enumerator do
    if key ~= "core" and key ~= "ensureClasses" then
        if package.loaded[key] == nil then
            require(key)
        end
    end
end