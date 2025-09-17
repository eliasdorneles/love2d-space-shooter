math = require("math")
LICK = require("vendor/lick")
LICK.reset = true
local colors = require("colors")

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
    }, self)
end

function Player:move()

end

local function withColor(color, func, ...)
    local old_r, old_g, old_b, old_a = love.graphics.getColor()
    love.graphics.setColor(love.math.colorFromBytes(colors.color(color)))
    func(...)
    love.graphics.setColor(old_r, old_g, old_b, old_a)
end

function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
    print("win size", WIN_WIDTH, WIN_HEIGHT)
    IMAGES = {}
    IMAGES.player = love.graphics.newImage("images/player.png")
    IMAGES.meteor = love.graphics.newImage("images/meteor.png")
    IMAGES.laser = love.graphics.newImage("images/laser.png")
    IMAGES.star = love.graphics.newImage("images/star.png")

    STAR_POS = {}
    for i = 1, math.random(15, 20) do
        STAR_POS[i] = {
            x = math.random(0, WIN_WIDTH),
            y = math.random(0, WIN_HEIGHT),
            scale = math.random(3, 7) / 10
        }
    end
    PLAYER = Player:new(WIN_WIDTH / 2, WIN_HEIGHT - 200)
end

function love.update(dt)
    local direction = { x = 0, y = 0 }
    if love.keyboard.isDown("down") then
        direction.y = 1
    end
    if love.keyboard.isDown("up") then
        direction.y = -1
    end
    if love.keyboard.isDown("left") then
        direction.x = -1
    end
    if love.keyboard.isDown("right") then
        direction.x = 1
    end
    PLAYER.y = PLAYER.y + direction.y * PLAYER.speed * dt
    PLAYER.x = PLAYER.x + direction.x * PLAYER.speed * dt
end

function love.draw()
    withColor("#100040", function()
        love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    end)

    love.graphics.print("Hello, Players!", WIN_WIDTH / 2, WIN_HEIGHT / 2 - 100)
    love.graphics.print("Get ready", WIN_WIDTH / 2, WIN_HEIGHT / 2 - 50)
    for i = 1, #STAR_POS do
        local scale = STAR_POS[i].scale
        love.graphics.draw(IMAGES.star, STAR_POS[i].x, STAR_POS[i].y, scale, scale)
    end
    love.graphics.draw(IMAGES.player, PLAYER.x, PLAYER.y)
end
