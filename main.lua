math.randomseed(os.time())
local lp = love.physics
local camera = require "camera"
local window = {
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight()
}

local imageStore = {}

function drawImage(actor)
    local sprite = actor.sprite
    love.graphics.draw(sprite.image, actor.x, actor.y, 0, actor.sx*sprite.scale, sprite.scale, sprite.w/2, sprite.h)
end

function getSprite(name, scale)
    if (imageStore[name] == nil) then
        imageStore[name] = love.graphics.newImage("images/"..name)
    end
    local image = imageStore[name]
    return {
        image = image,
        w = image:getWidth(),
        h = image:getHeight(),
        scale = scale or 1
    }
end

function initActor(entity, x, y, sprite, canMove)
    entity.initX = x or 0
    entity.initY = y or 0
    entity.x = x or 0
    entity.y = y or 0
    entity.vy = 0
    entity.sx = 1
    entity.sprite = sprite
    entity.canMove = canMove
    return entity
end

local enemies = {}
local lulu = {} -- lulu le champi
local stage = {
    name = nil,
    state = nil
}

local forestBg = {
    getSprite("foret2.png", 0.7)
}

function paralax(camera, initX, initY, sprite)
    local result = math.floor((camera.x - initX) / (sprite.w * sprite.scale))
    local x = initX + result * sprite.w * sprite.scale
    love.graphics.draw(sprite.image, x, initY, 0, sprite.scale, sprite.scale, 0, sprite.h)
    love.graphics.draw(sprite.image, x + sprite.w * sprite.scale, initY, 0, sprite.scale, sprite.scale, 0, sprite.h)
end

function updateLulu(dt)
    lulu.y = lulu.y - lulu.vy * dt

    if not lulu.canMove then return end

    if love.keyboard.isDown("a") then
        lulu.x = lulu.x - 1
        lulu.sx = -1
    end
    if love.keyboard.isDown("s") then
        lulu.x = lulu.x + 1
        lulu.sx = 1
    end
end

function love.load()
    lp.setMeter(100)
    world = lp.newWorld(0, 0, false)

    initActor(lulu, 100, window.h, getSprite("lulu.png", 0.2), false);
    changeStage("awakening_forest", "getting_out_the_ground");

    camera:load()
end

function changeStage(name, state)
    stage.name = name
    stage.state = state
end

function checkStage(name, state)
    return stage.name == name and stage.state == state
end

-- awakening_forest
local push_counter = 0
local push_counter_to_get_out = 200

function love.update(dt)
    world:update(dt)
    if checkStage("awakening_forest", "getting_out_the_ground") then
        function shake()
            local amplitude = 1
            return math.random(0, amplitude * 2) - amplitude, math.random(0, amplitude * 2) - amplitude
        end
        camera:setShake(shake)
        -- make like a plop (jump and stuff)
        if love.keyboard.isDown("space") then
            push_counter = math.min(push_counter + 1, push_counter_to_get_out)
            camera:shake(0.2)
        else
            push_counter = math.max(push_counter - 1, 0)
        end
        lulu.y = lulu.initY - push_counter / 2
        if push_counter == push_counter_to_get_out then stage.state = "popping_out_the_ground" end
    end

    if checkStage("awakening_forest", "popping_out_the_ground") then
        -- to fix, put in loading function
        if lulu.vy == 0 then lulu.vy = 900 end
        lulu.vy = lulu.vy - 3000 * dt
        local floorY = window.h - 74
        if lulu.vy < 0 and lulu.y > floorY then
            lulu.y = floorY
            lulu.vy = 0
            stage.state = "walking_in_the_forest"
        end
    end

    if checkStage("awakening_forest", "walking_in_the_forest") then
        lulu.canMove = true
    end

    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        if enemy.dead then
            enemy.body:destroy()
            table.remove(enemies, i)
        end
    end

    updateLulu(dt)
    camera:follow(lulu.x - window.w/4, lulu.y - window.h * 0.8)
    camera:update(dt)
end

function love.draw()
    --GAME
    love.graphics.setBackgroundColor(1, 0.9, 0.9)
    love.graphics.setColor(1, 1, 1)
    camera:set()
        local floorY = window.h - 74
        paralax(camera, -100, floorY, forestBg[1])

        drawImage(lulu)
        love.graphics.setColor(139/255, 69/255, 19/255)
        love.graphics.rectangle("fill", -100, floorY, 20000, 1000)
    camera:unset()

    --DEBUG
    love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.print("laser.timer: "..laser.timer, 5, 5)
end
