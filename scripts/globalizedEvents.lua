local eventsToRun = {
    pre={["*"]={}},
    post={["*"]={}}
}

function PreNextEvent(type, method)
    if not eventsToRun.pre[type] then eventsToRun.pre[type] = {} end
    table.insert(eventsToRun.pre[type], method)
end

function PostNextEvent(type, method)
    if not eventsToRun.post[type] then eventsToRun.post[type] = {} end
    table.insert(eventsToRun.post[type], method)
end

function eventCalled(event, eventList)
    if #eventList == 0 then return {} end

    local newList = {}
    
    for _, method in pairs(eventList) do
        if not method(event) then
            table.insert(newList, method)
        end
    end

    return newList
end

function PreEventCalled(event)
    if eventsToRun.pre[event.type] then
        eventsToRun.pre[event.type] = eventCalled(event, eventsToRun.pre[event.type])
    end
    
    eventsToRun.pre["*"] = eventCalled(event, eventsToRun.pre["*"])
end

function PostEventCalled(event)
    if eventsToRun.post[event.type] then
        eventsToRun.post[event.type] = eventCalled(event, eventsToRun.post[event.type])
    end

    eventsToRun.post["*"] = eventCalled(event, eventsToRun.post["*"])
end