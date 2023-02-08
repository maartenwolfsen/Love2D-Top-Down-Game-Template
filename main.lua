local sti = require "lib/sti"
require "src/colliders"
require "src/enemies"
require "src/bullets"
require "src/player"
require "src/func"
local TICKRATE = 1/144
debug = true

function love.load()
    map = sti("maps/arena1.lua")
    window = {
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
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

    font = love.graphics.getFont()
end

function love.update(dt)
    newPos = {
        x = camera.x,
        y = camera.y,
        w = Player.w,
        h = Player.h
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
    
    if not Colliders.isColliding(newPos) then
        camera.x = newPos.x
        camera.y = newPos.y
    end
    
    if ((love.keyboard.isDown("a") or love.keyboard.isDown("left"))
            and (love.keyboard.isDown("d") or love.keyboard.isDown("right")))
        or ((love.keyboard.isDown("w") or love.keyboard.isDown("up"))
            and (love.keyboard.isDown("s") or love.keyboard.isDown("down"))) then
        Player.setAnimation("idle")
    elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        Player.setAnimation("walk_left")
    elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        Player.setAnimation("walk_right")
    elseif love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        Player.setAnimation("walk_up")
    elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        Player.setAnimation("walk_down")
    else
        Player.setAnimation("idle")
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
    Player.update(camera)
    Enemies.update(camera)
    Bullets.update()
    map:update(dt)
end

function love.draw()
    map:draw(
        camera.offset.x,
        camera.offset.y,
        camera.scale
    )
    Bullets.draw()
    Enemies.draw(camera)
    Player.draw(camera)
  
    if debug then
        love.graphics.print("FPS: " ..tostring(love.timer.getFPS( )), 10, 10)
        love.graphics.print("Player position: {x: "
            ..tostring(math.floor(camera.x)).. "; y: "
            ..tostring(math.floor(camera.y)).. "}", 10, 30)
        love.graphics.print("Map position: {x: "
            ..tostring(math.floor(camera.offset.x)).. "; y: "
            ..tostring(math.floor(camera.offset.y)).. "}", 10, 50)
        love.graphics.print("Animation | Anim: "
            ..Player.animations.current_animation.. "; Timer: "
            ..tostring(Player.animations.animation_timer).. "; Frame: "
            ..tostring(Player.animations.current_animation_frame), 10, 70)
        love.graphics.print("Camera | Scale: " ..tostring(camera.scale), 10, 90)
        enemiesSize = 0
        for _ in pairs(Enemies.objects) do enemiesSize = enemiesSize + 1 end
        love.graphics.print("Enemies | Timer: "
            ..tostring(Enemies.spawners.spawnTimer).. "; Enemies: "
            ..tostring(enemiesSize), 10, 110)
        love.graphics.print("Bullets: " ..tostring(Func.getTableLength(Bullets.objects)), 10, 130)
    end
end

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.load then love.load(arg) end

    local previous = love.timer.getTime()
    local lag = 0.0
    while true do
        local current = love.timer.getTime()
        local elapsed = current - previous
        previous = current
        lag = lag + elapsed

        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        while lag >= TICKRATE do
            if love.update then love.update(TICKRATE) end
            lag = lag - TICKRATE
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw(lag / TICKRATE) end
            love.graphics.present()
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button ~= 1 then
        return
    end
    
    if Bullets.gun.can_shoot then
        Bullets.shoot(
            camera,
            {
                x = Player.x,
                y = Player.y,
                h = Player.h,
                w = Player.w
            },
            {
                x = x,
                y = y
            }
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
                        Enemies.addSpawner({
                            x = object.x,
                            y = object.y
                        })
                    end
                end
            elseif layer.name == "Colliders" then
                for objIndex, object in pairs(layer.objects) do
                    Colliders.add({
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
