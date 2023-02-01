local sti = require "lib/sti"
local mapPos = { x = 0, y = 0 }
local mapSpeed = 4
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
			x = 16,
			y = 16,
			r = 0,
      w = playerImage:getWidth(),
      h = playerImage:getHeight()
		}
	}
  
	function spriteLayer:update(dt)
		for _, sprite in pairs(self.sprites) do
      if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        sprite.y = sprite.y - 1
      end

      if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        sprite.y = sprite.y + 1
      end

      if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        sprite.x = sprite.x - 1
      end

      if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        sprite.x = sprite.x + 1
      end
		end
	end
  
	function spriteLayer:draw()
		for _, sprite in pairs(self.sprites) do
			local x = math.floor(sprite.x)
			local y = math.floor(sprite.y)
			local r = sprite.r
			love.graphics.draw(sprite.image, x, y, r)
		end
	end
end

function love.update(dt) 
	map:update(dt)
end

function love.draw()
  playerSprite = spriteLayer.sprites.player
  
	map:draw(
    -playerSprite.x + ((window.w / mapScale / 2) - (playerSprite.w / 2)),
    -playerSprite.y + ((window.h / mapScale / 2) - (playerSprite.h / 2)),
    mapScale
  )
  
  love.graphics.draw(
    player.sprite,
    math.floor(player.x),
    math.floor(player.y),
    0,
    1,
    1,
    player.sprite:getWidth(),
    player.sprite:getHeight()
  )
end
