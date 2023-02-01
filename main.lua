local sti = require "lib/sti"
local mapPos = { x = 0, y = 0 }
local speed = 2
local mapScale = 4
local window = {
  w = love.graphics.getWidth(),
  h = love.graphics.getHeight()
}
local playerImage = love.graphics.newImage("images/player.png")

function love.load()
  map = sti("maps/arena1.lua")
  player = {
    sprite = love.graphics.newImage("images/player.png"),
    x = 0,
    y = 0
  }
  
	map:addCustomLayer("Sprite Layer", 3)
	spriteLayer = map.layers["Sprite Layer"]
	spriteLayer.sprites = {
		player = {
			image = playerImage,
			x = 0,
			y = 0,
			r = 0,
      w = playerImage:getWidth() / (mapScale ^ 2),
      h = playerImage:getHeight() / (mapScale ^ 2)
		}
	}
  
	function spriteLayer:update(dt)
		for _, sprite in pairs(self.sprites) do
      if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        sprite.y = sprite.y - speed
      end

      if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        sprite.y = sprite.y + speed
      end

      if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        sprite.x = sprite.x - speed
      end

      if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        sprite.x = sprite.x + speed
      end
		end
	end
  
	function spriteLayer:draw()
		for _, sprite in pairs(self.sprites) do
			love.graphics.draw(
        sprite.image,         -- Sprite
        math.floor(sprite.x), -- X
        math.floor(sprite.y), -- Y
        sprite.r,             -- Rotation
        sprite.w,             -- Width
        sprite.h              -- Height
      )
		end
	end
end

function love.update(dt) 
	map:update(dt)
end

function love.draw()
  playerSprite = spriteLayer.sprites.player
  
  map:draw(
    -playerSprite.x + ((window.w / mapScale / 2) - (playerSprite.w * (mapScale * 2))),
    -playerSprite.y + ((window.h / mapScale / 2) - (playerSprite.h * (mapScale * 2))),
    mapScale
  )
end
