require "src/core/func"
require "src/camera"
require "src/player"
require "src/map"

Bullets = {
    speed = 3,
    sprite = love.graphics.newImage("images/bullet.png"),
    current_bullet_id = 0,
    shoot_speed = 30,
    shoot_timer = 0,
    can_shoot = true,
    damage = 10,
    sfx = {
        shoot = love.audio.newSource("sfx/laserShoot.wav", "static")
    }
}
Bullets.animation = love.graphics.newQuad(0, 0, 1, 5, Bullets.sprite)
Bullets.sprite:setFilter("nearest", "nearest")

Map.object:addCustomLayer("Bullets", 4)
Map.layers.bullets = Map.object.layers["Bullets"]
Map.layers.bullets.sprites = {}

Bullets.add = function(bullet)
	table.insert(
		Map.layers.bullets.sprites,
		bullet
	)
end

Bullets.shoot = function(mousePos)
    local b = {
        id = Bullets.current_bullet_id,
        bullet = {
            transform = {
                x = Camera.transform.x,
                y = Camera.transform.y,
                w = Bullets.sprite:getWidth(),
                h = Bullets.sprite:getHeight(),
                r = Func.getAngleOfTwoPoints(
                    Player.transform,
                    mousePos
                )
            },
            destroy_timer_limit = 150,
            destroy_timer = 0
        }
    }

    local t = b.bullet.transform
    b.collider = {
        x = t.x,
        y = t.y,
        w = t.w,
        h = t.h
    }
    
    Bullets.add(b)
    Bullets.current_bullet_id = Bullets.current_bullet_id + 1
    Bullets.can_shoot = false
    love.audio.play(Bullets.sfx.shoot)
end

Bullets.update = function()
    if Bullets.can_shoot == false then
        if Bullets.shoot_timer > Bullets.shoot_speed then
            Bullets.can_shoot = true
            Bullets.shoot_timer = 0
        else
            Bullets.shoot_timer = Bullets.shoot_timer + 1
        end
    end
end

function Map.layers.bullets:update(dt)
    for _, b in pairs(self.sprites) do
        local bulletInstance = b.bullet
        
        bulletInstance.transform = Func.moveForward(
            bulletInstance.transform,
            Bullets.speed
        )

        bulletInstance.destroy_timer = bulletInstance.destroy_timer + 1
        
        if bulletInstance.destroy_timer > bulletInstance.destroy_timer_limit then
            table.remove(Map.layers.bullets.sprites, _)
        end

        b.collider.x = bulletInstance.transform.x
        b.collider.y = bulletInstance.transform.y
    end
end

function Map.layers.bullets:draw()
    for _, sprite in pairs(self.sprites) do
        local b = sprite.bullet

        love.graphics.draw(
            Bullets.sprite,
            Bullets.animation,
            love.math.newTransform(
                b.transform.x,
                b.transform.y,
                0,
                1,
                1,
                0,
                0
            )
        )
    end
end

return Bullets
