local sti = require "lib/sti"
local colliders = require "src/colliders"
local enemies = require "src/enemies"
local bullets = require "src/bullets"
debug = true

function love.load()
    map = sti("maps/arena1.lua")
    
    window = {
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
    playerSpriteSheet = love.graphics.newImage("images/player_spritesheet.png")
    camera = {
        x = 0,
        y = 0,
        r = 0,
        scale = 4,
        minScale = 4,
        zoom = 0,
        minZoom = 0,
        maxZoom = 1,
        zoomSpeed = 0.02,
        speed = 0.5,
        offset = {
            x = 0,
            y = 0
        }
    }
    
    initMap()
    
    player = {
        spriteSheet = playerSpriteSheet,
        animation = love.graphics.newQuad(0, 0, 16, 16, playerSpriteSheet),
        x = 0,
        y = 0,
        w = 16,
        h = 16,
        animations = {
            animation_speed = 20,
            animation_timer = 0,
            current_animation = "idle",
            current_animation_frame = 0,
            idle = {
                {x = 2, y = 0}
            },
            walk_up = {
                {x = 0, y = 1},
                {x = 1, y = 1}
            },
            walk_right = {
                {x = 0, y = 2},
                {x = 1, y = 2}
            },
            walk_down = {
                {x = 0, y = 3},
                {x = 1, y = 3}
            },
            walk_left = {
                {x = 0, y = 4},
                {x = 1, y = 4}
            }
        }
    }
    bullets = {}
    player.spriteSheet:setFilter("nearest", "nearest")
    font = love.graphics.getFont()
end

function love.update(dt)
    newPos = {
        x = camera.x,
        y = camera.y,
        w = player.w,
        h = player.h
    }
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        newPos.y = camera.y - camera.speed
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        newPos.y = camera.y + camera.speed
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        newPos.x = camera.x - camera.speed
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        newPos.x = camera.x + camera.speed
    end
    
    if not colliders.isColliding(newPos) then
        camera.x = newPos.x
        camera.y = newPos.y
    end
    
    if ((love.keyboard.isDown("a") or love.keyboard.isDown("left"))
            and (love.keyboard.isDown("d") or love.keyboard.isDown("right")))
        or ((love.keyboard.isDown("w") or love.keyboard.isDown("up"))
            and (love.keyboard.isDown("s") or love.keyboard.isDown("down"))) then
        setAnimation("idle")
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        setAnimation("walk_left")
    elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        setAnimation("walk_right")
    elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        setAnimation("walk_up")
    elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        setAnimation("walk_down")
    else
        setAnimation("idle")
    end
    
    if love.mouse.isDown(2) then
        if camera.zoom < camera.maxZoom then
            camera.zoom = camera.zoom + camera.zoomSpeed
            camera.scale = camera.minScale + camera.zoom
        end
    else
        if camera.zoom > camera.minZoom then
            camera.zoom = camera.zoom - camera.zoomSpeed
            camera.scale = camera.minScale + camera.zoom
        end
    end
    
    if Enemies.spawners.spawn
        and Enemies.spawners.spawnTimer < Enemies.spawners.spawnSpeed then
        Enemies.spawners.spawnTimer = Enemies.spawners.spawnTimer + 1
    else
        enemiesSize = 0
        for _ in pairs(Enemies.objects) do enemiesSize = enemiesSize + 1 end
        if enemiesSize < Enemies.spawners.maxEnemies then
            Enemies.spawn()
            Enemies.spawners.spawnTimer = 0
        else
            Enemies.spawners.spawn = false
        end
    end

    updateCameraOffset()
    updatePlayerPos()
    Enemies.update(camera)
    updateAnimation()
    Bullets.update()
    map:update(dt)
end

function love.draw()    
    map:draw(
        camera.offset.x,
        camera.offset.y,
        camera.scale
    )
    
    transform = love.math.newTransform(
        player.x,
        player.y,
        camera.r,
        camera.scale,
        camera.scale,
        player.w / (camera.scale ^ 2),
        player.h / (camera.scale ^ 2)
    )
    
    love.graphics.draw(
        player.spriteSheet,     -- Sprite
        player.animation,       -- Quad
        transform               -- Transform
    )

    Bullets.draw()
    Enemies.draw(camera)
  
    if debug then
        love.graphics.print("FPS: " ..tostring(love.timer.getFPS( )), 10, 10)
        love.graphics.print("Player position: {x: "
            ..tostring(math.floor(camera.x)).. "; y: "
            ..tostring(math.floor(camera.y)).. "}", 10, 30)
        love.graphics.print("Map position: {x: "
            ..tostring(math.floor(camera.offset.x)).. "; y: "
            ..tostring(math.floor(camera.offset.y)).. "}", 10, 50)
        love.graphics.print("Animation | Anim: "
            ..player.animations.current_animation.. "; Timer: "
            ..tostring(player.animations.animation_timer).. "; Frame: "
            ..tostring(player.animations.current_animation_frame), 10, 70)
        love.graphics.print("Camera | Scale: " ..tostring(camera.scale), 10, 90)
        enemiesSize = 0
        for _ in pairs(Enemies.objects) do enemiesSize = enemiesSize + 1 end
        love.graphics.print("Enemies | Timer: "
            ..tostring(enemies.spawners.spawnTimer).. "; Enemies: "
            ..tostring(enemiesSize), 10, 110)
        love.graphics.print("Bullets: " ..tostring(getTableLength(bullets)), 10, 130)
    end
end

-- function love.run()
--     if love.math then
--         love.math.setRandomSeed(os.time())
--     end

--     if love.load then love.load(arg) end

--     local previous = love.timer.getTime()
--     local lag = 0.0
--     while true do
--         local current = love.timer.getTime()
--         local elapsed = current - previous
--         previous = current
--         lag = lag + elapsed

--         if love.event then
--             love.event.pump()
--             for name, a,b,c,d,e,f in love.event.poll() do
--                 if name == "quit" then
--                     if not love.quit or not love.quit() then
--                         return a
--                     end
--                 end
--                 love.handlers[name](a,b,c,d,e,f)
--             end
--         end

--         while lag >= TICKRATE do
--             if love.update then love.update(TICKRATE) end
--             lag = lag - TICKRATE
--         end

--         if love.graphics and love.graphics.isActive() then
--             love.graphics.clear(love.graphics.getBackgroundColor())
--             love.graphics.origin()
--             if love.draw then love.draw(lag / TICKRATE) end
--             love.graphics.present()
--         end
--     end
-- end

function love.mousepressed(x, y, button, istouch)
    if button ~= 1 then
        return
    end
    
    if Bullets.gun.can_shoot then
        Bullets.shoot(
            camera,
            {x = player.x, y = player.y},
            {x = x, y = y}
        )
    end
end

function initMap()
    for index, layer in pairs(map.layers) do
        if layer.type == "objectgroup" then
            if layer.name == "Spawners" then
                for objIndex, object in pairs(layer.objects) do
                    if object.name == "Player" then
                        camera.x = object.x
                        camera.y = object.y
                    elseif object.name == "Enemy" then
                        enemies.addSpawner({
                            x = object.x,
                            y = object.y
                        })
                    end
                end
            elseif layer.name == "Colliders" then
                for objIndex, object in pairs(layer.objects) do
                    colliders.add({
                        x = object.x,
                        y = object.y,
                        w = object.width,
                        h = object.height
                    })
                end
            end
            
            map:removeLayer(index)
        end
    end
end

function updateCameraOffset()
    camera.offset.x = -camera.x + window.w / camera.scale / 2
    camera.offset.y = -camera.y + window.h / camera.scale / 2
end

function updatePlayerPos()
    player.x = (window.w / 2) - ((player.w * camera.scale) / 2)
    player.y = (window.h / 2) - ((player.h * camera.scale) / 2)
end

function setAnimation(animation)
    if (player.animations.current_animation == animation) then
        return
    end
    
    player.animations.current_animation = animation
    player.animations.animation_timer = 0
    player.animations.current_animation_frame = 0
end

function updateAnimation()
    local length = 0
    local playerAnimations = player.animations
    local currentFrame = playerAnimations.current_animation_frame
    
    -- Update animation frame
    local count = 0
    if playerAnimations.current_animation == "idle" then
        count = getTableLength(playerAnimations.idle)
    elseif playerAnimations.current_animation == "walk_up" then
        count = getTableLength(playerAnimations.walk_up)
    elseif playerAnimations.current_animation == "walk_right" then
        count = getTableLength(playerAnimations.walk_right)
    elseif playerAnimations.current_animation == "walk_down" then
        count = getTableLength(playerAnimations.walk_down)
    elseif playerAnimations.current_animation == "walk_left" then
        count = getTableLength(playerAnimations.walk_left)
    end
    
    local timer = player.animations.animation_timer
    if (timer > playerAnimations.animation_speed) then
        playerAnimations.animation_timer = 0
        
        frame = playerAnimations.current_animation_frame
        if (frame >= count - 1) then
            playerAnimations.current_animation_frame = 0
        else
            playerAnimations.current_animation_frame = frame + 1
        end
    else
        playerAnimations.animation_timer = timer + 1
    end
    
    -- Update animation
    local currentFrameIndex = playerAnimations.current_animation_frame + 1
    local currentFrameLocation = playerAnimations.idle[currentFrameIndex]
    
    if playerAnimations.current_animation == "walk_up" then
        currentFrameLocation = playerAnimations.walk_up[currentFrameIndex]
    elseif playerAnimations.current_animation == "walk_right" then
        currentFrameLocation = playerAnimations.walk_right[currentFrameIndex]
    elseif playerAnimations.current_animation == "walk_down" then
        currentFrameLocation = playerAnimations.walk_down[currentFrameIndex]
    elseif playerAnimations.current_animation == "walk_left" then
        currentFrameLocation = playerAnimations.walk_left[currentFrameIndex]
    end

    -- Create animation quad
    player.animation = love.graphics.newQuad(
        currentFrameLocation.x * player.w,
        currentFrameLocation.y * player.h,
        player.w,
        player.h,
        playerSpriteSheet
    )
end

function getTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
