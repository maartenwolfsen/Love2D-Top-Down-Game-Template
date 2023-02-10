require "src/camera"
require "src/map"

Enemies = {}
Enemies.waves = {}
Enemies.spawners = {
	spawnSpeed = 500,
	spawnTimer = 0,
	maxEnemies = 10,
	spawn = true
}
Enemies.types = {
	enemy1 = {
		spritesheet = love.graphics.newImage("images/enemy_spritesheet.png"),
		transform = {
			x = 0,
			y = 0,
			w = 12,
			h = 12,
			r = 0
		},
		animations = {
	        animation_speed = 20,
	        animation_timer = 0,
	        current_animation = "walk_right",
	        current_animation_frame = 0,
	        walk_right = {
	            {x = 0, y = 0},
	            {x = 1, y = 0},
	            {x = 2, y = 0},
	            {x = 3, y = 0}
	        },
	        walk_left = {
	            {x = 0, y = 1},
	            {x = 1, y = 1},
	            {x = 2, y = 1},
	            {x = 3, y = 1}
	        }
		}
	}
}
Enemies.types.enemy1.animation = love.graphics.newQuad(
	0,
	0,
	Enemies.types.enemy1.transform.w,
	Enemies.types.enemy1.transform.h,
	Enemies.types.enemy1.spritesheet
)
Enemies.types.enemy1.spritesheet:setFilter("nearest", "nearest")

Enemies.addSpawner = function(spawner)
	table.insert(
		Enemies.spawners,
		spawner
	)
end

Enemies.spawn = function()
	local spawner = Enemies.getRandomSpawner()
	local e = Enemies.types.enemy1

	e.transform.x = spawner.x
	e.transform.y = spawner.y
	
	Map.addEnemy({
        image = e.spritesheet,
        animation = e.animation,
        transform = {
            x = e.transform.x,
            y = e.transform.x,
            w = e.transform.w,
            h = e.transform.h
        }
	})
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

return Enemies
