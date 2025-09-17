local colors = require("colors")
local vector = require("vendor/vector")
local lick = require("vendor/lick")

lick.reset = true

-- Rect = {}
--
-- function Rect:new(x, y, width, height)
--     self.__index = self
--     return setmetatable({
--         x = x,
--         y = y,
--         width = width,
--         height = height,
--     }, self)
-- end
--
-- Sprite = {}
--
-- function Sprite:new(image)
--     self.__index = self
--     return setmetatable({
--         image = image,
--         rect = Rect:new(0, 0, image.getWidth(), image.getHeight()),
--     }, self)
-- end

Player = {}

function Player:new(x, y)
    self.__index = self
    return setmetatable({
        x = x,
        y = y,
        speed = 200,
        direction = vector(),
    }, self)
end

function Player:input()
    self.direction = vector()
    if love.keyboard.isDown("down") then
        self.direction.y = 1
    end
    if love.keyboard.isDown("up") then
        self.direction.y = -1
    end
    if love.keyboard.isDown("left") then
        self.direction.x = -1
    end
    if love.keyboard.isDown("right") then
        self.direction.x = 1
    end
end

function Player:move(dt)
    self.y = self.y + self.direction.y * self.speed * dt
    self.x = self.x + self.direction.x * self.speed * dt
end

function Player:update(dt)
    self:input()
    self:move(dt)
end

local function withColor(color, func, ...)
    local old_r, old_g, old_b, old_a = love.graphics.getColor()
    love.graphics.setColor(love.math.colorFromBytes(colors.color(color)))
    func(...)
    love.graphics.setColor(old_r, old_g, old_b, old_a)
end

local player = Player:new(0, 0)
local starPositions = {}
local Images = {}

function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
    print("win size", WIN_WIDTH, WIN_HEIGHT)
    Images.player = love.graphics.newImage("images/player.png")
    Images.meteor = love.graphics.newImage("images/meteor.png")
    Images.laser = love.graphics.newImage("images/laser.png")
    Images.star = love.graphics.newImage("images/star.png")

    player.x = WIN_WIDTH / 2
    player.y = WIN_HEIGHT - 200

    for i = 1, math.random(15, 20) do
        starPositions[i] = {
            x = math.random(0, WIN_WIDTH),
            y = math.random(0, WIN_HEIGHT),
            scale = math.random(3, 7) / 10
        }
    end
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    withColor("#100040", function()
        love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    end)

    love.graphics.print("Hello, Players!", WIN_WIDTH / 2, WIN_HEIGHT / 2 - 100)
    love.graphics.print("Get ready", WIN_WIDTH / 2, WIN_HEIGHT / 2 - 50)
    for i = 1, #starPositions do
        local scale = starPositions[i].scale
        love.graphics.draw(Images.star, starPositions[i].x, starPositions[i].y, scale, scale)
    end
    love.graphics.draw(Images.player, player.x, player.y)
end
