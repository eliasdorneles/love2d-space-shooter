local vector = require("vendor/hump/vector")
local Timer = require("vendor/hump/timer")
local colors = require("colors")
local Rect = require("rect")

local lick = require("vendor/lick")
lick.reset = true

local function uniform(a, b)
    return a + (b - a) * math.random()
end

local function random_choice(list)
    return list[math.random(1, #list)]
end

local function list_range(start, stop, step)
    local list = {}
    local count = 1
    for i = start, stop, step do
        list[count] = i
        count = count + 1
    end
    return list
end


Meteor = {}
local meteorAngleRanges = list_range(-60, 60, 10)

function Meteor:new(image)
    self.__index = self
    local rect = Rect.fromImage(image, vector(math.random(0, WIN_WIDTH), -100))
    local hitbox_rect = rect:inflated(-20, -20)
    return setmetatable({
        image = image,
        rect = rect,
        hitbox_rect = hitbox_rect,
        speed = math.random(100, 400),
        direction = vector(uniform(-0.6, 0.6), uniform(0.8, 1)),
        rotation_speed = math.rad(random_choice(meteorAngleRanges)),
        rotation = 0,
        is_dead = false,
    }, self)
end

function Meteor:update(dt)
    self.rect.pos = self.rect.pos + self.direction * self.speed * dt
    self.hitbox_rect:setCenter(self.rect:getCenter())
    self.rotation = self.rotation + self.rotation_speed * dt
end

Laser = {}

function Laser:new(image, pos)
    self.__index = self

    local rect = Rect.fromImage(image, vector())
    rect:setMidBottom(pos)

    return setmetatable({
        image = image,
        rect = rect,
        speed = 600,
        direction = vector(0, -1),
        is_dead = false,
    }, self)
end

function Laser:start()
    Timer.after(1, function()
        self.is_dead = true
    end)
end

function Laser:update(dt)
    self.rect.pos = self.rect.pos + self.direction * self.speed * dt
end

Player = {}

function Player:new()
    self.__index = self
    return setmetatable({
        speed = 200,
        direction = vector(),
        canShoot = true,
    }, self)
end

function Player:init(image)
    self.image = image
    self.rect = Rect.fromImage(image, vector(WIN_WIDTH / 2 - image:getWidth() / 2, WIN_HEIGHT - 200))
    self.hitbox_rect = self.rect:inflated(-10, -25)
    self:update_hitbox()
end

function Player:update_hitbox()
    self.hitbox_rect:setCenter(self.rect:getCenter())
    self.hitbox_rect.pos.y = self.hitbox_rect.pos.y + 15
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
    self:update_hitbox()
end

function Player:shoot()
    self.canShoot = false
    Timer.after(0.4, function()
        self.canShoot = true
    end)
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
local lasers = {}
local bigRect = Rect:new(0, 0)
local gameOver = false


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

local function handleGlobalEvents()
    if love.keyboard.isDown("space") and player.canShoot then
        player:shoot()
        local laser = Laser:new(Images.laser, player.rect:getMidTop())
        table.insert(lasers, laser)
        laser:start()
    end
end

function love.update(dt)
    if gameOver then return end
    Timer.update(dt)

    player:update(dt)

    handleGlobalEvents()

    for _, laser in ipairs(lasers) do
        laser:update(dt)
    end
    for _, meteor in ipairs(meteors) do
        meteor:update(dt)

        if meteor.hitbox_rect:collideRect(player.hitbox_rect) then
            gameOver = true
        end

        if not bigRect:contains(meteor.rect) then
            meteor.is_dead = true
        end
        for _, laser in ipairs(lasers) do
            if meteor.hitbox_rect:collideRect(laser.rect) then
                laser.is_dead = true
                meteor.is_dead = true
                print('TODO: display explosion')
            end
        end
    end

    meteors = filterDead(meteors)
    lasers = filterDead(lasers)
end

function love.draw()
    withColor("#100040", function()
        love.graphics.rectangle("fill", 0, 0, WIN_WIDTH, WIN_HEIGHT)
    end)

    if gameOver then
        love.graphics.printf("GAME OVER", 0, WIN_HEIGHT / 2, WIN_WIDTH, "center")
        return
    end

    if love.timer.getTime() < 5 then
        love.graphics.printf("Get Ready!", 0, WIN_HEIGHT / 2 - 50, WIN_WIDTH, "center")
        love.graphics.printf("Use SPACE to shoot and move with arrow keys", 0, WIN_HEIGHT / 2, WIN_WIDTH, "center")
    end

    for _, starPos in ipairs(starPositions) do
        love.graphics.draw(Images.star, starPos.x, starPos.y, starPos.scale, starPos.scale)
    end
    for _, meteor in ipairs(meteors) do
        -- local boxRect = meteor.hitbox_rect
        -- love.graphics.rectangle("line", boxRect.pos.x, boxRect.pos.y, boxRect.width, boxRect.height)

        love.graphics.draw(meteor.image, meteor.rect:getCenterX(), meteor.rect:getCenterY(), meteor.rotation, 1, 1,
            meteor.image:getWidth() / 2,
            meteor.image:getHeight() / 2)
    end

    love.graphics.printf(
        string.format("Lasers: %d, Meteors: %d", #lasers, #meteors),
        0, 10, WIN_WIDTH, "right")

    for _, laser in ipairs(lasers) do
        love.graphics.draw(laser.image, laser.rect.pos.x, laser.rect.pos.y)
    end

    -- local boxRect = player.hitbox_rect
    -- love.graphics.rectangle("line", boxRect.pos.x, boxRect.pos.y, boxRect.width, boxRect.height)
    love.graphics.draw(player.image, player.rect.pos.x, player.rect.pos.y)
end
