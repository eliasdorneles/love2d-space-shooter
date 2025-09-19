require("utils")
local vector = require("vendor/hump/vector")
local Timer = require("vendor/hump/timer")
local anim8 = require 'vendor/anim8'
local colors = require("colors")
local sprite = require("sprite")
local Rect = require("rect")

-- uncomment the lines below to allow hot-reloading
local lick = require("vendor/lick")
lick.reset = true

Meteor = {}
local meteorAngleRanges = list(range(-60, 60, 10))

function Meteor:new(image)
    self.__index = self
    local rect = Rect.fromImage(image, vector(math.random(0, WIN_WIDTH), -100))
    local hitbox_rect = rect:inflated(-20, -20)
    return setmetatable({
        image = image,
        rect = rect,
        hitbox_rect = hitbox_rect,
        speed = math.random(100, 350),
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

function Meteor:draw()
    love.graphics.draw(
        self.image, self.rect:getCenterX(), self.rect:getCenterY(),
        self.rotation, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

Star = {}

function Star:new(image, pos)
    self.__index = self
    return setmetatable({
        image = image,
        pos = pos,
        scale = math.random(3, 7) / 10
    }, self)
end

function Star:update() end

function Star:draw()
    love.graphics.draw(self.image, self.pos.x, self.pos.y, self.scale, self.scale)
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

function Laser:draw()
    love.graphics.draw(self.image, self.rect.pos.x, self.rect.pos.y)
end

Explosion = {}

function Explosion:new(image, pos)
    self.__index = self
    local g = anim8.newGrid(50, 50, image:getWidth(), image:getHeight())
    local animation = anim8.newAnimation(g('1-5', '1-5'), 0.05, 'pauseAtEnd')
    return setmetatable({
        image = image,
        animation = animation:clone(),
        pos = pos,
        is_dead = false,
    }, self)
end

function Explosion:update(dt)
    self.animation:update(dt)
    if self.animation.status == "paused" then
        self.is_dead = true
    end
end

function Explosion:draw()
    self.animation:draw(self.image, self.pos.x, self.pos.y)
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

function Player:draw()
    love.graphics.draw(self.image, self.rect.pos.x, self.rect.pos.y)
end

local function withColor(color, func, ...)
    local old_r, old_g, old_b, old_a = love.graphics.getColor()
    love.graphics.setColor(love.math.colorFromBytes(colors.color(color)))
    func(...)
    love.graphics.setColor(old_r, old_g, old_b, old_a)
end

local allSprites = sprite.Group:new()
local meteors = sprite.Group:new()
local lasers = sprite.Group:new()
local player = Player:new()
local Images = {}
local bigRect = Rect:new(0, 0)
local gameOver = false


function love.load()
    math.randomseed(os.time())

    -- TODO: set window title
    WIN_WIDTH, WIN_HEIGHT = love.graphics.getDimensions()
    bigRect.width, bigRect.height = WIN_WIDTH, WIN_HEIGHT
    bigRect:inflateInplace(500, 500)

    Images.laser = love.graphics.newImage("images/laser.png")
    Images.star = love.graphics.newImage("images/star.png")
    Images.player = love.graphics.newImage("images/player.png")
    Images.meteor = love.graphics.newImage("images/meteor.png")
    Images.explosion = love.graphics.newImage("images/explosion/spritesheet.png")

    player:init(Images.player)
    allSprites:add(player)

    for _ = 1, math.random(15, 20) do
        local pos = vector(math.random(0, WIN_WIDTH), math.random(0, WIN_HEIGHT))
        local star = Star:new(Images.star, pos)
        allSprites:add(star)
    end

    Timer.every(0.5, function()
        local meteor = Meteor:new(Images.meteor)
        meteors:add(meteor)
        allSprites:add(meteor)
    end)
end

local function handleGlobalEvents()
    if love.keyboard.isDown("space") and player.canShoot then
        player:shoot()
        -- TODO: play sound
        local laser = Laser:new(Images.laser, player.rect:getMidTop())
        allSprites:add(laser)
        lasers:add(laser)
        laser:start()
    end
end

local function handleCollisions()
    for meteor in meteors:iter() do
        if meteor.hitbox_rect:collideRect(player.hitbox_rect) then
            gameOver = true
        end

        if not bigRect:contains(meteor.rect) then
            meteor.is_dead = true
        end
        for laser in lasers:iter() do
            if meteor.hitbox_rect:collideRect(laser.rect) then
                laser.is_dead = true
                meteor.is_dead = true
                -- BOOOM!
                allSprites:add(Explosion:new(Images.explosion, meteor.rect:getCenter()))
                -- TODO: play sound
            end
        end
    end
end

function love.update(dt)
    if gameOver then
        -- TODO: allow restarting game
        return
    end
    Timer.update(dt)

    handleGlobalEvents()

    allSprites:update(dt)

    handleCollisions()

    meteors:cleanup()
    lasers:cleanup()
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

    allSprites:draw()

    -- TODO: display the score here instead of this
    love.graphics.printf(
        string.format("Lasers: %d, Meteors: %d", #lasers, #meteors),
        0, 10, WIN_WIDTH, "right")
end
