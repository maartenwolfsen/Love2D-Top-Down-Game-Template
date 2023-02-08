local DEBUG = true

require "src/func"
require "src/colliders"
require "src/enemies"
require "src/bullets"
require "src/player"
require "src/camera"
require "src/map"
if DEBUG then
    require "src/debug"
end

local TICKRATE = 1/144

function love.load()
    window = {
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
    
    Map.init()
    font = love.graphics.getFont()
end

function love.update(dt)
    Camera.update()
    Player.update()
    Enemies.update()
    Bullets.update()
    Map.object:update(dt)
end

function love.draw()
    Map.object:draw(
        Camera.offset.x,
        Camera.offset.y,
        Camera.scale
    )
    Bullets.draw()
    Enemies.draw()
    Player.draw()
  
    if debug then
        Debug.draw()
    end
end

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.load then love.load(arg) end

    local previous = love.timer.getTime()
    local lag = 0.0
    while true do
        local current = love.timer.getTime()
        local elapsed = current - previous
        previous = current
        lag = lag + elapsed

        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        while lag >= TICKRATE do
            if love.update then love.update(TICKRATE) end
            lag = lag - TICKRATE
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw(lag / TICKRATE) end
            love.graphics.present()
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button ~= 1 then
        return
    end
    
    if Bullets.gun.can_shoot then
        Bullets.shoot(
            Camera,
            {
                x = Player.x,
                y = Player.y,
                h = Player.h,
                w = Player.w
            },
            {
                x = x,
                y = y
            }
        )
    end
end
