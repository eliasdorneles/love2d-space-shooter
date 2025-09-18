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


Game = {}

function Game:new()
    self.__index = self
    return setmetatable({
        player = Player:new(),
        starPositions = {},
        meteors = {},
        bigRect = Rect:new(0, 0),
        images = {},
    }, self)
end

function Game:init(images)
    self.images = images
    self.bigRect.width, self.bigRect.height = WIN_WIDTH, WIN_HEIGHT
    self.bigRect:inflateInplace(500, 500)
    for i = 1, math.random(15, 20) do
        self.starPositions[i] = {
            x = math.random(0, WIN_WIDTH),
            y = math.random(0, WIN_HEIGHT),
            scale = math.random(3, 7) / 10
        }
    end

    self.player.pos = vector(WIN_WIDTH / 2 - self.images.player:getWidth() / 2, WIN_HEIGHT - 200)

    Timer.every(1, function() self:addMeteor() end)
end

function Game:addMeteor()
    table.insert(self.meteors, Meteor:new())
end

function Game:update(dt)
    self.player:update(dt)

    for _, meteor in ipairs(self.meteors) do
        meteor:update(dt)

        local meteorRect = Rect:new(meteor.pos.x, meteor.pos.y, self.images.meteor:getWidth(),
            self.images.meteor:getHeight())
        if not self.bigRect:contains(meteorRect) then
            print('meteor killed')
            meteor.is_dead = true
        end
    end

    self.meteors = filterDead(self.meteors)
end

function Game:draw()
    for _, starPos in ipairs(self.starPositions) do
        love.graphics.draw(self.images.star, starPos.x, starPos.y, starPos.scale, starPos.scale)
    end
    for _, meteor in ipairs(self.meteors) do
        love.graphics.draw(self.images.meteor, meteor.pos.x, meteor.pos.y, meteor.rotation, 1, 1,
            self.images.meteor:getWidth() / 2,
            self.images.meteor:getHeight() / 2)
    end

    love.graphics.draw(self.images.player, self.player.pos.x, self.player.pos.y)
end

-- the game object
local game = Game:new()

function love.load()
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()

    local images = {}
    images.player = love.graphics.newImage("images/player.png")
    images.meteor = love.graphics.newImage("images/meteor.png")
    images.laser = love.graphics.newImage("images/laser.png")
    images.star = love.graphics.newImage("images/star.png")

    game:init(images)
end

function love.update(dt)
    Timer.update(dt)
    game:update(dt)
end

function love.draw()
    withColor("#100040", function()
        love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    end)

    if love.timer.getTime() < 5 then
        love.graphics.printf("Get Ready!", 0, WIN_HEIGHT / 2 - 50, WIN_WIDTH, "center")
        love.graphics.printf("Use SPACE to shoot and move with arrow keys", 0, WIN_HEIGHT / 2, WIN_WIDTH, "center")
    end

    game:draw()
end
