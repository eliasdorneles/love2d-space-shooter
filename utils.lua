---@diagnostic disable: lowercase-global
--- Here is a collection of generic functions that complete the standard
--- library for my use

function uniform(a, b)
    return a + (b - a) * math.random()
end

function random_choice(in_list)
    return in_list[math.random(1, #in_list)]
end

function range(start, stop, step)
    step = step or 1
    local value = start - step
    return function()
        value = value + step
        if step > 0 and value <= stop then
            return value
        elseif step < 0 and value >= stop then
            return value
        end
    end
end

function filter(in_list, predicate)
    predicate = predicate or function(it) return it end
    local new_list = {}
    for _, item in ipairs(in_list) do
        if predicate(item) then
            table.insert(new_list, item)
        end
    end
    return new_list
end

function reversed(t)
    local i = #t + 1
    return function()
        i = i - 1
        if i > 0 then return t[i] end
    end
end

function list(it)
    local new_list = {}
    for x in it do
        table.insert(new_list, x)
    end
    return new_list
end

function min(list)
    m = nil
    for _, n in ipairs(list) do
        if m == nil then m = n end
        if n < m then m = n end
    end
    return m
end

function max(list)
    m = nil
    for _, n in ipairs(list) do
        if m == nil then m = n end
        if n > m then m = n end
    end
    return m
end
