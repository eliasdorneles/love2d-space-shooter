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

function Meteor:new(image)
    self.__index = self
    return setmetatable({
        image = image,
        rect = Rect.fromImage(image, vector(math.random(0, WIN_WIDTH), -100)),
        speed = math.random(100, 400),
        direction = vector(uniform(-0.6, 0.6), uniform(0.8, 1)),
        rotation_speed = math.random(math.rad(-60), math.rad(60)),
        rotation = 0,
        is_dead = false,
    }, self)
end

function Meteor:update(dt)
    self.rect.pos = self.rect.pos + self.direction * self.speed * dt
    self.rotation = self.rotation + self.rotation_speed * dt
end

Player = {}

function Player:new()
    self.__index = self
    return setmetatable({
        rect = nil,
        image = nil,
        speed = 200,
        direction = vector(),
    }, self)
end

function Player:init(image)
    self.image = image
    self.rect = Rect.fromImage(image, vector(WIN_WIDTH / 2 - image:getWidth() / 2, WIN_HEIGHT - 200))
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
    self.rect.pos = self.rect.pos + self.direction * self.speed * dt
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


function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
    bigRect.width, bigRect.height = WIN_WIDTH, WIN_HEIGHT
    bigRect:inflateInplace(500, 500)

    Images.laser = love.graphics.newImage("images/laser.png")
    Images.star = love.graphics.newImage("images/star.png")

    player:init(love.graphics.newImage("images/player.png"))

    for i = 1, math.random(15, 20) do
        starPositions[i] = {
            x = math.random(0, WIN_WIDTH),
            y = math.random(0, WIN_HEIGHT),
            scale = math.random(3, 7) / 10
        }
    end

    local meteorImg = love.graphics.newImage("images/meteor.png")
    Timer.every(1, function() table.insert(meteors, Meteor:new(meteorImg)) end)
end

function love.update(dt)
    Timer.update(dt)

    player:update(dt)


    for _, meteor in ipairs(meteors) do
        meteor:update(dt)

        if not bigRect:contains(meteor.rect) then
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
        love.graphics.draw(meteor.image, meteor.rect.pos.x, meteor.rect.pos.y, meteor.rotation, 1, 1,
            meteor.image:getWidth() / 2,
            meteor.image:getHeight() / 2)
    end

    love.graphics.draw(player.image, player.rect.pos.x, player.rect.pos.y)
end
