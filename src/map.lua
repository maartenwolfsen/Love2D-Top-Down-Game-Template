local sti = require "lib/sti"
require "src/camera"
require "src/enemies"
require "src/colliders"

Map = {
	object = sti("maps/arena1.lua")
}

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
end

return Map