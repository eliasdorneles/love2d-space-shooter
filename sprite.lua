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

return M
