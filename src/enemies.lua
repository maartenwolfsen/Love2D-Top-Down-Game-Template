require "src/camera"
require "src/map"
require "src/data/enemies"

Enemies = {}
Enemies.waves = {}
Enemies.spawners = {
	spawnSpeed = 500,
	spawnTimer = 0,
	maxEnemies = 10,
	spawn = true
}
EnemyData.enemy1.animation = love.graphics.newQuad(
	0,
	0,
	EnemyData.enemy1.transform.w,
	EnemyData.enemy1.transform.h,
	EnemyData.enemy1.spritesheet
)
EnemyData.enemy1.spritesheet:setFilter("nearest", "nearest")

Map.object:addCustomLayer("Enemies", 3)
Map.layers.enemies = Map.object.layers["Enemies"]
Map.layers.enemies.sprites = {}

Enemies.addSpawner = function(spawner)
	table.insert(
		Enemies.spawners,
		spawner
	)
end

Enemies.spawn = function()
	local spawner = Enemies.getRandomSpawner()
	local e = EnemyData.enemy1

	e.transform.x = spawner.x
	e.transform.y = spawner.y

	local enemy = {
        image = e.spritesheet,
        animation = e.animation,
        health = e.health,
        speed = e.speed,
        damage = e.damage,
        transform = {
            x = e.transform.x,
            y = e.transform.x,
            w = e.transform.w,
            h = e.transform.h
        }
	}
	enemy.collider = enemy.transform
	
	Enemies.addEnemy(enemy)
end

Enemies.addEnemy = function(enemy)
    table.insert(
        Map.layers.enemies.sprites,
        enemy
    )
end

Enemies.getRandomSpawner = function()
	return Enemies.spawners[math.random(#Enemies.spawners)]
end

Enemies.update = function()
    if Enemies.spawners.spawn
        and Enemies.spawners.spawnTimer < Enemies.spawners.spawnSpeed then
        Enemies.spawners.spawnTimer = Enemies.spawners.spawnTimer + 1
    else
        enemiesSize = 0
        for _ in pairs(Map.layers.enemies.sprites) do enemiesSize = enemiesSize + 1 end
        if enemiesSize < Enemies.spawners.maxEnemies then
            Enemies.spawn()
            Enemies.spawners.spawnTimer = 0
        else
            Enemies.spawners.spawn = false
        end
    end
end

Enemies.death = function(index)
    Game.addScore(10)
    table.remove(Map.layers.enemies.sprites, index)
end

function Map.layers.enemies:update(dt)
    for _, sprite in pairs(self.sprites) do
    	for index, b in pairs(Map.layers.bullets.sprites) do
    		if Colliders.isCollidingWith(sprite.collider, b.collider) then
    			sprite.health = sprite.health - Bullets.damage

    			if sprite.health <= 0 then
                    Enemies.death(_)
    			end

            	table.remove(Map.layers.bullets.sprites, index)
    		end
    	end

        if Colliders.isCollidingWith(
            sprite.collider,
            {
                x = Camera.transform.x,
                y = Camera.transform.y,
                w = Player.transform.w,
                h = Player.transform.h
            }
        ) then
            if not Player.invincible then
                Player.hit(sprite.damage)
            end
        end

    	local transform = sprite.transform
    	transform.r = Func.getAngleOfTwoPoints(
    		sprite.transform,
    		Camera.transform
    	)
    	sprite.transform = Func.moveForward(
    		transform,
	    	sprite.speed / 10
		)
        sprite.collider.x = sprite.transform.x
        sprite.collider.y = sprite.transform.y
    end
end

function Map.layers.enemies:draw()
    for _, sprite in pairs(self.sprites) do
        love.graphics.draw(
            sprite.image,
            sprite.animation,
            love.math.newTransform(
                sprite.transform.x,
                sprite.transform.y,
                0,
                1,
                1,
                0,
                0
            )
        )
    end
end

return Enemies
