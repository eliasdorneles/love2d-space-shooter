---@diagnostic disable: lowercase-global
--- Here is a collection of generic functions that complete the standard
--- library for my use

function uniform(a, b)
    return a + (b - a) * math.random()
end

function random_choice(list)
    return list[math.random(1, #list)]
end

function list_range(start, stop, step)
    local list = {}
    local count = 1
    for i = start, stop, step do
        list[count] = i
        count = count + 1
    end
    return list
end

function filter(list, predicate)
    predicate = predicate or function(it) return it end
    local new_list = {}
    for _, item in ipairs(list) do
        if predicate(item) then
            table.insert(new_list, item)
        end
    end
    return new_list
end

