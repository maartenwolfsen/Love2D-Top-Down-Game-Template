local sti = require "lib/sti"
require "src/func"
require "src/camera"
require "src/colliders"

Map = {
	object = sti("maps/arena1.lua"),
    layers = {}
}
Map.object:addCustomLayer("Enemies", 3)
Map.layers.enemies = Map.object.layers["Enemies"]
Map.layers.enemies.sprites = {}

Map.init = function()
    for index, layer in pairs(Map.object.layers) do
        if layer.type == "objectgroup" then
            if layer.name == "Spawners" then
                for objIndex, object in pairs(layer.objects) do
                    if object.name == "Player" then
                        Camera.x = object.x
                        Camera.y = object.y
                    elseif object.name == "Enemy" then
                        Enemies.addSpawner({
                            x = object.x,
                            y = object.y
                        })
                    end
                end
            elseif layer.name == "Colliders" then
                for objIndex, object in pairs(layer.objects) do
                    Colliders.add({
                        x = object.x,
                        y = object.y,
                        w = object.width,
                        h = object.height
                    })
                end
            end
            
            Map.object:removeLayer(index)
        end
    end

    function Map.layers.enemies:update(dt)
        for _, sprite in pairs(self.sprites) do
        end
    end

    function Map.layers.enemies:draw()
        for _, sprite in pairs(self.sprites) do
            love.graphics.draw(
                sprite.image,
                sprite.animation,
                love.math.newTransform(
                    sprite.transform.x,
                    sprite.transform.y,
                    0,
                    1,
                    1,
                    0,
                    0
                )
            )
        end
    end
end

Map.addEnemy = function(enemy)
    table.insert(
        Map.layers.enemies.sprites,
        enemy
    )
end

Map.update = function()
    Map.object:update(dt)
end

Map.draw = function()
    Map.object:draw(
        Camera.offset.x,
        Camera.offset.y,
        Camera.scale
    )
end

return Map
