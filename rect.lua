local vector = require("vendor/hump/vector")

Rect = {}

function Rect:new(x, y, width, height)
    self.__index = self
    return setmetatable({
        pos = vector(x, y),
        width = width,
        height = height,
    }, self)
end

function Rect:getTop()
    return self.pos.y
end

function Rect:getBottom()
    return self.pos.y + self.height
end

function Rect:getLeft()
    return self.pos.x
end

function Rect:getRight()
    return self.pos.x + self.width
end

function Rect:getCenter()
    return self.pos + vector(self.width / 2, self.height / 2)
end

function Rect:setCenter(pos)
    self.pos = pos - vector(self.width / 2, self.height / 2)
end

function Rect:contains(otherRect)
    return (
        self:getLeft() <= otherRect:getLeft()
        and self:getRight() >= otherRect:getRight()
        and self:getTop() <= otherRect:getTop()
        and self:getBottom() >= otherRect:getBottom()
    )
end

function Rect:inflateInplace(x, y)
    self.pos.x = self.pos.x - x / 2
    self.pos.y = self.pos.y - y / 2
    self.width = self.width + x
    self.height = self.height + y
end

function Rect:copy()
    return Rect:new(self.pos.x, self.pos.y, self.width, self.height)
end

function Rect:toStr()
    print(string.format("Rect(%f, %f, %f, %f)", self.pos.x, self.pos.y, self.width, self.height))
end

function Rect:inflated(x, y)
    local copy = self:copy()
    copy:inflateInplace(x, y)
    return copy
end

return Rect
