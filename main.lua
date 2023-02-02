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
    playerPos = {x = (window.w / 2) - (player.w / 2), y = (window.h / 2) - (player.h / 2)}
    transform = love.math.newTransform(
        playerPos.x,
        playerPos.y,
        player.r,
        mapScale,
        mapScale,
        player.w / (mapScale ^ 2),
        player.h / (mapScale ^ 2)
    )
    gun = {
        bullet_speed = 4,
        bullet_sprite = love.graphics.newImage("images/bullet.png"),
        current_bullet_id = 0
    }
    bullets = {}
    player.spriteSheet:setFilter("nearest", "nearest")
    font = love.graphics.getFont()
    sfxLaser = love.audio.newSource("sfx/laserShoot.wav", "static")
end

function love.update(dt)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player.y = player.y - speed
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player.y = player.y + speed
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player.x = player.x - speed
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player.x = player.x + speed
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
    
    updateAnimation()
    updateBullets()
    map:update(dt)
end

function love.draw()
    updateMapPos()
    map:draw(
        mapPos.x,
        mapPos.y,
        mapScale
    )
    
    love.graphics.draw(
        player.spriteSheet,     -- Sprite
        player.animation,       -- Quad
        transform               -- Transform
    )
    
    for index, b in pairs(bullets) do
        local bulletInstance = b.bullet
        love.graphics.draw(
            gun.bullet_sprite,
            bulletInstance.x,
            bulletInstance.y,
            -bulletInstance.r,
            1,
            1,
            bulletInstance.w,
            bulletInstance.h
        )
        
        love.graphics.print("  - Id: "
            ..tostring(b.id).. "; Timer: "
            ..tostring(bulletInstance.destroy_timer).. "; R: "
            ..tostring(math.floor(math.deg(bulletInstance.r))), 10, 130 + (index * 20)
        )
    end
  
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
    love.graphics.print("Bullets: " ..tostring(getTableLength(bullets)), 10, 130)
end

function love.mousepressed(x, y, button, istouch)
    addBullet(x, y)
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

function updateBullets()
    if getTableLength(bullets) == 0 then
        return
    end
    
    for index, b in pairs(bullets) do
        local bulletInstance = b.bullet
        bulletInstance.x = bulletInstance.x + -math.sin(bulletInstance.r) * gun.bullet_speed
        bulletInstance.y = bulletInstance.y + -math.cos(bulletInstance.r) * gun.bullet_speed
        
        bulletInstance.destroy_timer = bulletInstance.destroy_timer + 1
        
        if bulletInstance.destroy_timer > bulletInstance.destroy_timer_limit then
            table.remove(bullets, index)
        end
    end
end

function addBullet(x, y)
    local delta = {
        x = playerPos.x - x,
        y = playerPos.y - y
    }
    
    table.insert(bullets, {
        id = gun.current_bullet_id,
        bullet = {
            x = (window.w / 2) + 20,
            y = window.h / 2 + 3,
            r = math.atan2(delta.x, delta.y),
            w = 20,
            h = 3,
            destroy_timer_limit = 150,
            destroy_timer = 0
        }
    })

    gun.current_bullet_id = gun.current_bullet_id + 1
    sfxLaser:play()
end

function getTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
