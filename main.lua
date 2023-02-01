local sti = require "lib/sti"

function love.load()
    map = sti("maps/arena1.lua")
    mapPos = {x = 0, y = 0}
    speed = 0.5
    mapScale = 4
    window = {
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
    playerSpriteSheet = love.graphics.newImage("images/player_spritesheet.png")
    player = {
        spriteSheet = playerSpriteSheet,
        animation = love.graphics.newQuad(0, 0, 16, 16, playerSpriteSheet),
        x = 0,
        y = 0,
        r = 0,
        w = 16,
        h = 16,
        animations = {
            animation_speed = 40,
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
    player.spriteSheet:setFilter("nearest", "nearest")
    font = love.graphics.getFont()
end

function love.update(dt)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player.y = player.y - speed
        setAnimation("walk_up")
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player.y = player.y + speed
        setAnimation("walk_down")
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player.x = player.x - speed
        setAnimation("walk_left")
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player.x = player.x + speed
        setAnimation("walk_right")
    end
    
    updateAnimationFrame()

    map:update(dt)
end

function love.draw()
    updateMapPos()
    map:draw(
        mapPos.x,
        mapPos.y,
        mapScale
    )

    transform = love.math.newTransform(
        (window.w / 2) - (player.w / 2),
        (window.h / 2) - (player.h / 2),
        player.r,
        mapScale,
        mapScale,
        player.w / (mapScale ^ 2),
        player.h / (mapScale ^ 2)
    )
    
    love.graphics.draw(
        player.spriteSheet,     -- Sprite
        player.animation,       -- Quad
        transform               -- Transform
    )
  
    love.graphics.print("FPS: " ..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Player position: {x: "
        ..tostring(math.floor(player.x)).. "; y: "
        ..tostring(math.floor(player.y)).. "}", 10, 30)
    love.graphics.print("Map position: {x: "
        ..tostring(math.floor(mapPos.x)).. "; y: "
        ..tostring(math.floor(mapPos.y)).. "}", 10, 50)
    love.graphics.print("Current player animation: " ..player.animations.current_animation, 10, 70)
    love.graphics.print("Player animation timer: " ..tostring(player.animations.animation_timer), 10, 90)
    love.graphics.print("Player animation frame: " ..tostring(player.animations.current_animation_frame), 10, 110)
end

function updateMapPos()
    mapPos.x = -player.x + ((window.w / mapScale / 2) - (player.w * (mapScale * 2)))
    mapPos.y = -player.y + ((window.h / mapScale / 2) - (player.h * (mapScale * 2)))
end

function setAnimation(animation)
    if (player.animations.current_animation == animation) then
        return
    end
    
    player.animations.current_animation = animation
    player.animations.animation_timer = 0
    player.animations.current_animation_frame = 0
end

function updateAnimationFrame()    
    local length = 0
    local playerAnimations = player.animations
    
    if (playerAnimations.current_animation == "idle") then
        return
    elseif (playerAnimations.current_animation == "walk_up") then
        for _ in pairs(playerAnimations.walk_up) do length = length + 1 end
    elseif (playerAnimations.current_animation == "walk_right") then
        for _ in pairs(playerAnimations.walk_right) do length = length + 1 end
    elseif (playerAnimations.current_animation == "walk_down") then
        for _ in pairs(playerAnimations.walk_down) do length = length + 1 end
    elseif (playerAnimations.current_animation == "walk_left") then
        for _ in pairs(playerAnimations.walk_left) do length = length + 1 end
    end
    
    local timer = player.animations.animation_timer
    if (timer > player.animations.animation_speed) then
        player.animations.animation_timer = 0
        
        frame = playerAnimations.current_animation_frame
        if (frame >= length) then
            player.animations.current_animation_frame = 0
        else
            player.animations.current_animation_frame = frame + 1
        end
    else
        player.animations.animation_timer = timer + 1
    end
end
