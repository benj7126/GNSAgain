local eventsToRun = {pre={},post={}}

function PreNextEvent(type, method)
    if not eventsToRun.pre[type] then eventsToRun.pre[type] = {} end
    table.insert(eventsToRun.pre[type], method)
end

function PostNextEvent(type, method)
    if not eventsToRun.post[type] then eventsToRun.post[type] = {} end
    table.insert(eventsToRun.post[type], method)
end

function PreEventCalled(event)
    if eventsToRun.pre[event.type] then
        local newList = {}
        
        for _, method in pairs(eventsToRun.pre[event.type]) do
            if not method(event) then
                table.insert(newList, method)
            end
        end

        eventsToRun.pre[event.type] = newList
    end
end

function PostEventCalled(event)
    if eventsToRun.post[event.type] then
        local newList = {}

        for _, method in pairs(eventsToRun.post[event.type]) do
            if not method(event) then
                table.insert(newList, method)
            end
        end

        eventsToRun.post[event.type] = newList
    end
end