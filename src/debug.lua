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
    love.graphics.print("Enemies | Timer: " ..tostring(Enemies.spawners.spawnTimer)..
        "/" ..tostring(Enemies.spawners.spawnSpeed), 10, 230)
    love.graphics.print("Bullets: " ..tostring(Func.getTableLength(Map.layers.bullets.sprites)), 10, 130)

    for index, e in pairs(Map.layers.enemies.sprites) do
        love.graphics.print(
                "Health: " ..tostring(e.health)..
                " Collider: {x: " ..tostring(math.floor(e.collider.x))..
                ", y: " ..tostring(math.floor(e.collider.y)).. "}",
            10,
            230 + (index * 20)
        )
    end

    for index, b in pairs(Map.layers.bullets.sprites) do
        love.graphics.print(
            "  - Id: " ..tostring(b.id)..
                "; Timer: " ..tostring(b.bullet.destroy_timer)..
                "; R: " ..tostring(math.floor(math.deg(b.bullet.transform.r)))..
                "; Collider: {x: " ..tostring(math.floor(b.collider.x))..
                ", y: " ..tostring(math.floor(b.collider.y)).. "}",
            10,
            130 + (index * 20)
        )
    end
end
