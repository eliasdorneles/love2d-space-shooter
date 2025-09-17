local colors = require("colors")
local vector = require("vendor/vector")
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
Timer = {}

function Timer:new(duration, callback, repeat_x_times)
    self.__index = self
    return setmetatable({
        duration = duration,
        callback = callback,
        repeat_x_times = repeat_x_times or -1,
        start_time = 0,
        count = 0,
        is_running = false,
    }, self)
end

function Timer:start()
    self.is_running = true
    self.start_time = love.timer.getTime()
end

function Timer:stop()
    self.is_running = false
    self.start_time = 0
end

function Timer:update()
    if not self.is_running then return end
    local current_time = love.timer.getTime()
    if current_time ~= 0 and current_time - self.start_time >= self.duration then
        if self.callback then
            self.callback()
        end
        self:stop()
        if self.repeat_x_times == -1 or self.count < self.repeat_x_times then
            self:start()
        end
        self.count = self.count + 1
    end
end

Meteor = {}

function Meteor:new(x, y, speed, direction)
    self.__index = self
    return setmetatable({
        x = x,
        y = y,
        speed = speed,
        direction = direction,
        is_dead = false,
    }, self)
end

function Meteor:move(dt)
    self.y = self.y + self.direction.y * self.speed * dt
    self.x = self.x + self.direction.x * self.speed * dt
end

function Meteor:update(dt)
    self:move(dt)
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
    local newMeteor = Meteor:new(
        math.random(0, WIN_WIDTH),
        0,
        math.random(100, 200),
        vector(uniform(-0.6, 0.6), 1)
    )
    table.insert(meteors, newMeteor)
end

local meteorTimer = Timer:new(1, addMeteor)

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

    meteorTimer:start()
end

function love.update(dt)
    meteorTimer:update()

    player:update(dt)

    local killLowerOffset = vector(-500, -500)
    local killUpperOffset = vector(WIN_WIDTH, WIN_HEIGHT) + vector(500, 500)
    for _, meteor in ipairs(meteors) do
        meteor:update(dt)
        if meteor.x < killLowerOffset.x or meteor.x > killUpperOffset.x
            or meteor.y < 0 or meteor.y > killUpperOffset.y
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
    for i = 1, #meteors do
        love.graphics.draw(Images.meteor, meteors[i].x, meteors[i].y)
    end

    love.graphics.draw(Images.player, player.x, player.y)
end
