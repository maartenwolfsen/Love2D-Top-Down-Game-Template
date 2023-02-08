require "src/camera"
require "src/player"
require "src/enemies"
require "src/bullets"

Debug = {}

Debug.draw = function()
    love.graphics.print("FPS: " ..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Player position: {x: "
        ..tostring(math.floor(Camera.x)).. "; y: "
        ..tostring(math.floor(Camera.y)).. "}", 10, 30)
    love.graphics.print("Map position: {x: "
        ..tostring(math.floor(Camera.offset.x)).. "; y: "
        ..tostring(math.floor(Camera.offset.y)).. "}", 10, 50)
    love.graphics.print("Animation | Anim: "
        ..Player.animations.current_animation.. "; Timer: "
        ..tostring(Player.animations.animation_timer).. "; Frame: "
        ..tostring(Player.animations.current_animation_frame), 10, 70)
    love.graphics.print("Camera | Scale: " ..tostring(Camera.scale), 10, 90)
    enemiesSize = 0
    for _ in pairs(Enemies.objects) do enemiesSize = enemiesSize + 1 end
    love.graphics.print("Enemies | Timer: "
        ..tostring(Enemies.spawners.spawnTimer).. "; Enemies: "
        ..tostring(enemiesSize), 10, 110)
    love.graphics.print("Bullets: " ..tostring(Func.getTableLength(Bullets.objects)), 10, 130)
end
