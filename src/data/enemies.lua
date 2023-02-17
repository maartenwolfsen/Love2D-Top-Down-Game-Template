EnemyData = {
	enemy1 = {
		spritesheet = love.graphics.newImage("images/enemy_spritesheet.png"),
		health = 40,
		speed = 3,
		damage = 10,
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

return EnemyData
