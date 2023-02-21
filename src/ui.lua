require "src/core/window"

Ui = {
	font = love.graphics.setNewFont("font/Symtext.ttf", 16),
	deathText = "Oh Dear, You're Dead!"
}

Ui.draw = function()
	love.graphics.rectangle("line", 20, 20, 204, 40)
	love.graphics.setColor(0,250,0)
	love.graphics.rectangle("fill", 22, 22, Player.health * 2, 36)
	love.graphics.setColor(255,255,255)
end

Ui.drawDeathScreen = function()
	love.graphics.setColor(0,0,0,0.5)
	love.graphics.rectangle("fill", 0, 0, Window.w, Window.h)
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Ui.font)
  	love.graphics.print(
  		Ui.deathText,
  		Window.w / 2,
  		Window.h / 2,
  		0,
  		1,
  		1,
  		Ui.font:getWidth(Ui.deathText) / 2,
  		Ui.font:getHeight() / 2
	)
end

return Ui
