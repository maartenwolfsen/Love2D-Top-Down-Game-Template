require "src/camera"
require "src/player"
require "src/map"

Bullets = {
    bullet_speed = 4,
    sprite = love.graphics.newImage("images/bullet.png"),
    current_bullet_id = 0,
    shoot_speed = 30,
    shoot_timer = 0,
    can_shoot = true,
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
                x = Camera.x,
                y = Camera.y,
                w = Bullets.sprite:getWidth(),
                h = Bullets.sprite:getHeight()
            },
            r = math.atan2(Player.x - mousePos.x, Player.y - mousePos.y),
            destroy_timer_limit = 150,
            destroy_timer = 0
        }
    }
    
    Bullets.add(b)
    Bullets.current_bullet_id = Bullets.current_bullet_id + 1
    Bullets.can_shoot = false
    love.audio.play(Bullets.sfx.shoot)
end

Bullets.update = function()
    -- local count = 0
    -- for _ in pairs(Bullets.objects) do count = count + 1 end

    -- if count == 0 then
    --     return
    -- end
    
    -- for index, b in pairs(Bullets.objects) do
    --     local bulletInstance = b.bullet
    --     local x = bulletInstance.pos.x + -math.sin(bulletInstance.r) * Bullets.gun.bullet_speed
    --     local y = bulletInstance.pos.y + -math.cos(bulletInstance.r) * Bullets.gun.bullet_speed
    --     bulletInstance.pos.x = x
    --     bulletInstance.pos.y = y

    --     bulletInstance.destroy_timer = bulletInstance.destroy_timer + 1
        
    --     if bulletInstance.destroy_timer > bulletInstance.destroy_timer_limit then
    --         table.remove(Bullets.objects, index)
    --     end
    -- end
    
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
    for _, sprite in pairs(self.sprites) do
    end
end

function Map.layers.bullets:draw()
    for _, sprite in pairs(self.sprites) do
        local b = sprite.bullet

        print(b.transform.x)
        print(b.transform.y)

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
