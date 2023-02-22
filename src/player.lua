require "src/core/func"
require "src/core/window"
require "src/game"
require "src/camera"

Player = {
    spriteSheet = love.graphics.newImage("images/player_spritesheet.png"),
    transform = {
        x = 0,
        y = 0,
        w = 16,
        h = 16
    },
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
    },
    health = 100,
    invincible = false,
    invincibility_frames = 100,
    invincibility_frame = 0
}
Player.animation = love.graphics.newQuad(0, 0, 16, 16, Player.spriteSheet)
Player.spriteSheet:setFilter("nearest", "nearest")

Player.draw = function()
    transform = love.math.newTransform(
        Player.transform.x,
        Player.transform.y,
        Camera.r,
        Camera.scale,
        Camera.scale,
        Player.transform.w / (Camera.scale ^ 2),
        Player.transform.h / (Camera.scale ^ 2)
    )

    love.graphics.draw(
        Player.spriteSheet,
        Player.animation,
        transform
    )
end

Player.update = function()
    Player.transform.x = (Window.w / 2) - ((Player.transform.w * Camera.scale) / 2)
    Player.transform.y = (Window.h / 2) - ((Player.transform.h * Camera.scale) / 2)

    Player.updateAnimation()

    if Player.invincible then
        if Player.invincibility_frame > Player.invincibility_frames then
            Player.invincibility_frame = 0
            Player.invincible = false
        else
            Player.invincibility_frame = Player.invincibility_frame + 1
        end
    end
end

Player.updateAnimation = function()
	local length = 0
    local playerAnimations = Player.animations
    local currentFrame = playerAnimations.current_animation_frame

    -- Update animation
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

    -- Update animation frame
    local count = 0
    if playerAnimations.current_animation == "idle" then
        count = Func.getTableLength(playerAnimations.idle)
    elseif playerAnimations.current_animation == "walk_up" then
        count = Func.getTableLength(playerAnimations.walk_up)
    elseif playerAnimations.current_animation == "walk_right" then
        count = Func.getTableLength(playerAnimations.walk_right)
    elseif playerAnimations.current_animation == "walk_down" then
        count = Func.getTableLength(playerAnimations.walk_down)
    elseif playerAnimations.current_animation == "walk_left" then
        count = Func.getTableLength(playerAnimations.walk_left)
    end

    local timer = Player.animations.animation_timer
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
    Player.animation = love.graphics.newQuad(
        currentFrameLocation.x * Player.transform.w,
        currentFrameLocation.y * Player.transform.h,
        Player.transform.w,
        Player.transform.h,
        Player.spriteSheet
    )
end

Player.setAnimation = function(animation)
    if (Player.animations.current_animation == animation) then
        return
    end

    Player.animations.current_animation = animation
    Player.animations.animation_timer = 0
    Player.animations.current_animation_frame = 0
end

Player.hit = function(damage)
    Player.invincible = true
    Player.health = Player.health - damage

    if Player.health <= 0 then
        Player.death()
    end
end

Player.death = function()
    Player.health = 0
    Map.layers.enemies.sprites = {}
    Game.run = false
end

return Player
