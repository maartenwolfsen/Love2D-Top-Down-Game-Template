Ui = {}

Ui.draw = function()
	love.graphics.rectangle("line", 20, 20, 204, 40)
	love.graphics.setColor(0,250,0)
	love.graphics.rectangle("fill", 22, 22, Player.health * 2, 36)
	love.graphics.setColor(255,255,255)
end

return Ui
