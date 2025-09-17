local colors = require("colors")
local vector = require("vendor/hump/vector")
local Timer = require("vendor/hump/timer")
local lick = require("vendor/lick")

lick.reset = true

local function uniform(a, b)
    return a + (b - a) * math.random()
end

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

Meteor = {}

function Meteor:new(x, y, speed, direction)
    self.__index = self
    return setmetatable({
        x = x or math.random(0, WIN_WIDTH),
        y = y or -100,
        speed = speed or math.random(100, 400),
        direction = direction or vector(uniform(-0.6, 0.6), 1),
        rotation_speed = math.random(math.rad(-60), math.rad(60)),
        rotation = 0,
        is_dead = false,
    }, self)
end

function Meteor:update(dt)
    self.y = self.y + self.direction.y * self.speed * dt
    self.x = self.x + self.direction.x * self.speed * dt
    self.rotation = self.rotation + self.rotation_speed * dt
end

Player = {}

function Player:new(x, y)
    self.__index = self
    return setmetatable({
        x = x, -- refactor to use vector()
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

local function filterDead(list)
    -- TODO: create a sprite group abstraction that does this automatically
    local new_list = {}
    for _, item in ipairs(list) do
        if not item.is_dead then
            table.insert(new_list, item)
        end
    end
    return new_list
end

local player = Player:new(0, 0)
local Images = {}
local starPositions = {}
local meteors = {}


local function addMeteor()
    table.insert(meteors, Meteor:new())
end


function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
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

    Timer.every(1, addMeteor)
end

function love.update(dt)
    Timer.update(dt)

    player:update(dt)

    local killLowerOffset = vector(-500, -500)
    local killUpperOffset = vector(WIN_WIDTH, WIN_HEIGHT) + vector(500, 500)
    for _, meteor in ipairs(meteors) do
        meteor:update(dt)

        -- TODO: refactor this to use a rectangle class which says if it is contained
        if meteor.x < killLowerOffset.x or meteor.x > killUpperOffset.x
            or meteor.y < killLowerOffset.y or meteor.y > killUpperOffset.y
        then
            meteor.is_dead = true
        end
    end

    meteors = filterDead(meteors)
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
    for _, meteor in ipairs(meteors) do
        love.graphics.draw(Images.meteor, meteor.x, meteor.y, meteor.rotation, 1, 1, Images.meteor:getWidth() / 2,
            Images.meteor:getHeight() / 2)
    end

    love.graphics.draw(Images.player, player.x, player.y)
end
