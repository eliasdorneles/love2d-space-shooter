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

function Rect:getCenterX()
    return self.pos.x + self.width / 2
end

function Rect:getCenterY()
    return self.pos.y + self.height / 2
end

function Rect:setCenter(pos)
    self.pos = pos - vector(self.width / 2, self.height / 2)
end

function Rect:getMidTop()
    return self.pos + vector(self.width / 2, 0)
end

function Rect:setMidTop(pos)
    self.pos.x = pos.x - self.width / 2
    self.pos.y = pos.y
end

function Rect:getMidBottom()
    return self.pos + vector(self.width / 2, self.height)
end

function Rect:setMidBottom(pos)
    self.pos.x = pos.x - self.width / 2
    self.pos.y = pos.y - self.height
end

function Rect:getMidLeft()
    return self.pos + vector(0, self.height / 2)
end

function Rect:setMidLeft(pos)
    self.pos.x = pos.x
    self.pos.y = pos.y - self.height / 2
end

function Rect:getMidRight()
    return self.pos + vector(self.width, self.height / 2)
end

function Rect:setMidRight(pos)
    self.pos.x = pos.x - self.width
    self.pos.y = pos.y - self.height / 2
end

function Rect:getTopLeft()
    return self.pos
end

function Rect:setTopLeft(pos)
    self.pos = pos
end

function Rect:getTopRight()
    return self.pos + vector(self.width, 0)
end

function Rect:setTopRight(pos)
    self.pos.x = pos.x - self.width
    self.pos.y = pos.y
end

function Rect:getBottomRight()
    return self.pos + vector(self.width, self.height)
end

function Rect:setBottomRight(pos)
    self.pos.x = pos.x - self.width
    self.pos.y = pos.y - self.height
end

function Rect:getBottomLeft()
    return self.pos + vector(0, self.height)
end

function Rect:setBottomLeft(pos)
    self.pos.x = pos.x
    self.pos.y = pos.y - self.height
end

function Rect:contains(otherRect)
    return (
        self:getLeft() <= otherRect:getLeft()
        and self:getRight() >= otherRect:getRight()
        and self:getTop() <= otherRect:getTop()
        and self:getBottom() >= otherRect:getBottom()
    )
end

function Rect:collidePoint(point)
    return (
        point.x >= self:getLeft() and point.x <= self:getRight()
        and point.y >= self:getTop() and point.y <= self:getBottom()
    )
end

function Rect:collideRect(otherRect)
    return (
        self:getLeft() < otherRect:getRight() and self:getRight() > otherRect:getLeft()
        and self:getTop() < otherRect:getBottom() and self:getBottom() > otherRect:getTop()
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

function Rect:__tostring()
    return string.format("Rect(%g, %g, %g, %g)", self.pos.x, self.pos.y, self.width, self.height)
end

function Rect:inflated(x, y)
    local copy = self:copy()
    copy:inflateInplace(x, y)
    return copy
end

function Rect.fromImage(image, pos)
    local rect = Rect:new(0, 0, image:getWidth(), image:getHeight())
    if pos then
        rect.pos = rect.pos + pos
    end
    return rect
end

return Rect
