Enemies = {}

Enemies.objects = {}
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

Enemies.add = function(enemy)
	table.insert(
		Enemies.objects,
		enemy
	)
end

Enemies.addSpawner = function(spawner)
	table.insert(
		Enemies.spawners,
		spawner
	)
end

Enemies.spawn = function()
	local spawner = Enemies.getRandomSpawner()
	local enemyInstance = Enemies.types.enemy1

	enemyInstance.transform.x = spawner.x
	enemyInstance.transform.y = spawner.y

	Enemies.add(enemyInstance)
end

Enemies.getRandomSpawner = function()
	return Enemies.spawners[math.random(#Enemies.spawners)]
end

Enemies.draw = function(camera)
    for index, e in pairs(Enemies.objects) do        
        love.graphics.draw(
            e.spritesheet,
            e.animation,
            love.math.newTransform(
                camera.offset.x - e.transform.x,
                camera.offset.y - e.transform.y,
                e.transform.r,
                camera.scale,
                camera.scale,
                e.transform.w,
                e.transform.h
            )
        )
    end
end

Enemies.update = function(camera)
    for index, e in pairs(Enemies.objects) do
    end
end

return Enemies
