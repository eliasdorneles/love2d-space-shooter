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

function M.Group:update(dt)
    for _, sprite in ipairs(self.sprites) do
        sprite:update(dt)
    end
    self.sprites = filter(self.sprites, function(it) return not it.is_dead end)
end

function M.Group:draw()
    for _, sprite in ipairs(self.sprites) do
        sprite:draw()
    end
end

return M
