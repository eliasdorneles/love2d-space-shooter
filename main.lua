local vector = require("vendor/hump/vector")
local Timer = require("vendor/hump/timer")
local colors = require("colors")
local Rect = require("rect")

local lick = require("vendor/lick")
lick.reset = true

local function uniform(a, b)
    return a + (b - a) * math.random()
end


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

function Meteor:new(pos, speed, direction)
    self.__index = self
    return setmetatable({
        pos = pos or vector(math.random(0, WIN_WIDTH), -100),
        speed = speed or math.random(100, 400),
        direction = direction or vector(uniform(-0.6, 0.6), uniform(0.8, 1)),
        rotation_speed = math.random(math.rad(-60), math.rad(60)),
        rotation = 0,
        is_dead = false,
    }, self)
end

function Meteor:update(dt)
    self.pos = self.pos + self.direction * self.speed * dt
    self.rotation = self.rotation + self.rotation_speed * dt
end

Player = {}

function Player:new(pos)
    self.__index = self
    return setmetatable({
        pos = pos or vector(),
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
    self.direction:normalizeInplace()
end

function Player:move(dt)
    self.pos = self.pos + self.direction * self.speed * dt
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

local player = Player:new()
local Images = {}
local starPositions = {}
local meteors = {}
local bigRect = Rect:new(0, 0)


local function addMeteor()
    table.insert(meteors, Meteor:new())
end


function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
    bigRect.width, bigRect.height = WIN_WIDTH, WIN_HEIGHT
    bigRect:inflateInplace(500, 500)

    Images.player = love.graphics.newImage("images/player.png")
    Images.meteor = love.graphics.newImage("images/meteor.png")
    Images.laser = love.graphics.newImage("images/laser.png")
    Images.star = love.graphics.newImage("images/star.png")

    player.pos = vector(WIN_WIDTH / 2 - Images.player:getWidth() / 2, WIN_HEIGHT - 200)

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


    for _, meteor in ipairs(meteors) do
        meteor:update(dt)

        local meteorRect = Rect:new(meteor.pos.x, meteor.pos.y, Images.meteor:getWidth(), Images.meteor:getHeight())
        if not bigRect:contains(meteorRect) then
            print('meteor killed')
            meteor.is_dead = true
        end
    end

    meteors = filterDead(meteors)
end

function love.draw()
    withColor("#100040", function()
        love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    end)

    if love.timer.getTime() < 5 then
        love.graphics.printf("Get Ready!", 0, WIN_HEIGHT / 2 - 50, WIN_WIDTH, "center")
        love.graphics.printf("Use SPACE to shoot and move with arrow keys", 0, WIN_HEIGHT / 2, WIN_WIDTH, "center")
    end
    for _, starPos in ipairs(starPositions) do
        love.graphics.draw(Images.star, starPos.x, starPos.y, starPos.scale, starPos.scale)
    end
    for _, meteor in ipairs(meteors) do
        love.graphics.draw(Images.meteor, meteor.pos.x, meteor.pos.y, meteor.rotation, 1, 1, Images.meteor:getWidth() / 2,
            Images.meteor:getHeight() / 2)
    end

    love.graphics.draw(Images.player, player.pos.x, player.pos.y)
end
