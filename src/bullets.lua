Bullets = {}

Bullets.gun = {
    bullet_speed = 4,
    bullet_sprite = love.graphics.newImage("images/bullet.png"),
    current_bullet_id = 0,
    shoot_speed = 30,
    shoot_timer = 0,
    can_shoot = true,
    sfx = {
    	shoot = love.audio.newSource("sfx/laserShoot.wav", "static")
    }
}
Bullets.objects = {}

Bullets.add = function(bullet)
	table.insert(
		Bullets.objects,
		bullet
	)
end

Bullets.draw = function()
    for index, b in pairs(Bullets.objects) do
        local bulletInstance = b.bullet
        love.graphics.draw(
            Bullets.gun.bullet_sprite,
            bulletInstance.x,
            bulletInstance.y,
            -bulletInstance.r,
            1,
            1,
            bulletInstance.w,
            bulletInstance.h
        )
        
        if debug then
            love.graphics.print(
            	"  - Id: " ..tostring(b.id)..
	            	"; Timer: " ..tostring(bulletInstance.destroy_timer)..
	            	"; R: " ..tostring(math.floor(math.deg(bulletInstance.r))),
            	10,
            	130 + (index * 20)
            )
        end
    end
end

Bullets.shoot = function(camera, playerPos, mousePos)
    local delta = {
        x = playerPos.x - mousePos.x,
        y = playerPos.y - mousePos.y
    }
    
    Bullets.add({
        id = Bullets.gun.current_bullet_id,
        bullet = {
            x = player.x + (player.w * camera.scale / 2),
            y = player.y + (player.h * camera.scale / 2),
            r = math.atan2(delta.x, delta.y),
            w = 20,
            h = 3,
            destroy_timer_limit = 150,
            destroy_timer = 0
        }
    })

    Bullets.gun.current_bullet_id = Bullets.gun.current_bullet_id + 1
    Bullets.gun.can_shoot = false
    love.audio.play(Bullets.gun.sfx.shoot)
end

Bullets.update = function()
    local count = 0
    for _ in pairs(Bullets.objects) do count = count + 1 end

    if count == 0 then
        return
    end
    
    for index, b in pairs(Bullets.objects) do
        local bulletInstance = b.bullet
        local x = bulletInstance.x + -math.sin(bulletInstance.r) * Bullets.gun.bullet_speed
        local y = bulletInstance.y + -math.cos(bulletInstance.r) * Bullets.gun.bullet_speed
        bulletInstance.x = x
        bulletInstance.y = y

        bulletInstance.destroy_timer = bulletInstance.destroy_timer + 1
        
        if bulletInstance.destroy_timer > bulletInstance.destroy_timer_limit then
            table.remove(Bullets.objects, index)
        end
    end
    
    if Bullets.gun.can_shoot == false then
        if Bullets.gun.shoot_timer > Bullets.gun.shoot_speed then
            Bullets.gun.can_shoot = true
            Bullets.gun.shoot_timer = 0
        else
            Bullets.gun.shoot_timer = Bullets.gun.shoot_timer + 1
        end
    end
end

return Bullets
