require("utils")

local M = {}

M.Group = {}

function M.Group:new()
    self.__index = self
    return setmetatable({
        sprites = {}
    }, self)
end

function M.Group:add(sprite)
    table.insert(self.sprites, sprite)
end

function M.Group:addAll(sprites_to_add)
    for _, sprite in ipairs(sprites_to_add) do
        self:add(sprite)
    end
end

function M.Group:iter()
    local i = 0
    return function()
        i = i + 1
        if i <= #self.sprites then
            return self.sprites[i]
        end
    end
end

function M.Group:killall()
    for sprite in self:iter() do
        sprite.is_dead = true
    end
end

function M.Group:cleanup()
    self.sprites = filter(self.sprites, function(it) return not it.is_dead end)
end

function M.Group:update(dt)
    for sprite in self:iter() do
        sprite:update(dt)
    end
    self:cleanup()
end

function M.Group:draw()
    for sprite in self:iter() do
        sprite:draw()
    end
end

M.Registry = {}

function M.Registry:new()
    self.__index = self
    return setmetatable({
        groups = {}
    }, self)
end

function M.Registry:getGroup(name)
    if not self.groups[name] then
        self.groups[name] = M.Group:new()
    end
    return self.groups[name]
end

function M.Registry:_check_group(name)
    if not self.groups[name] then
        error(string.format("Group not found in registry: '%s'", name))
    end
end

function M.Registry:groupiter(name)
    return self:getGroup(name):iter()
end

function M.Registry:add(name, sprite)
    self:getGroup(name):add(sprite)
end

function M.Registry:addAll(name, sprites_to_add)
    self:getGroup(name):addAll(sprites_to_add)
end

function M.Registry:iteritems()
    local i = 0
    local k, _ = next(self.groups)
    return function()
        if k then
            i = i + 1
            if i <= #self.groups[k].sprites then
                return k, self.groups[k].sprites[i]
            end
            -- next group:
            i = 1
            k, _ = next(self.groups, k)
            if k and i <= #self.groups[k].sprites then
                return k, self.groups[k].sprites[i]
            end
        end
    end
end

function M.Registry:update(dt)
    for _, group in pairs(self.groups) do
        group:update(dt)
    end
end

function M.Registry:cleanup(name)
    if name then
        self:getGroup(name):cleanup()
    else
        for _, group in pairs(self.groups) do
            group:cleanup()
        end
    end
end

function M.Registry:killall(name)
    if name then
        self:getGroup(name):killall()
    else
        for _, group in pairs(self.groups) do
            group:killall()
        end
    end
end

function M.Registry:draw(name)
    if name then
        self:getGroup(name):draw()
    else
        for _, group in pairs(self.groups) do
            group:draw()
        end
    end
end

return M
