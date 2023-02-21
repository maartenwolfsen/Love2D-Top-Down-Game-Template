Game = {
	run = true,
	score = 0
}

Game.addScore = function(score)
	Game.score = Game.score + score
end

return Game
