require "src/colliders"

Camera = {
    transform = {
        x = 0,
        y = 0,
        r = 0
    },
    scale = 4,
    minScale = 4,
    zoom = 0,
    minZoom = 0,
    maxZoom = 1,
    zoomSpeed = 0.02,
    speed = 0.5,
    offset = {
        x = 0,
        y = 0
    }
}

Camera.update = function()
    newPos = {
        x = Camera.transform.x,
        y = Camera.transform.y,
        w = Player.transform.w,
        h = Player.transform.h
    }
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        newPos.y = Camera.transform.y - Camera.speed
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        newPos.y = Camera.transform.y + Camera.speed
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        newPos.x = Camera.transform.x - Camera.speed
    end

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        newPos.x = Camera.transform.x + Camera.speed
    end
    
    if not Colliders.isColliding(newPos) then
        Camera.transform.x = newPos.x
        Camera.transform.y = newPos.y
    end

    if love.mouse.isDown(2) then
        if Camera.zoom < Camera.maxZoom then
            Camera.zoom = Camera.zoom + Camera.zoomSpeed
            Camera.scale = Camera.minScale + Camera.zoom
        end
    else
        if Camera.zoom > Camera.minZoom then
            Camera.zoom = Camera.zoom - Camera.zoomSpeed
            Camera.scale = Camera.minScale + Camera.zoom
        end
    end

    Camera.updateOffset()
end

Camera.updateOffset = function()
    Camera.offset.x = -Camera.transform.x + window.w / Camera.scale / 2
    Camera.offset.y = -Camera.transform.y + window.h / Camera.scale / 2
end
