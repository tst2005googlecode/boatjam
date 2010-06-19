handy_globals = {
    rads = 0,
}

-- love callbacks
function love.load()
    update = coroutine.create(function()
        while true do
            coroutine.yield()
        end
    end)
    
    draw = function()
    end
end

function love.update(dt)
    -- update handy globals
    handy_globals.rads = handy_globals.rads + dt
    while handy_globals.rads > 2 * math.pi do
        handy_globals.rads = handy_globals.rads - 2 * math.pi
    end
    
    coroutine.resume(update, dt)
end

function love.draw()
    love.graphics.scale(love.graphics.getWidth() / 480, love.graphics.getHeight() / 320)
    
    love.graphics.push()
    
    draw()
    
    love.graphics.pop()
end

function love.keyreleased(key, uni)
    if 'escape' == key then
        love.event.push('q')
    end
end
