require('MZM.lua')
require('menu.lua')
require('game.lua')

-- love callbacks
function love.load()
    update = coroutine.create(function()
        local map_num_to_load = 0
        while true do 
            map_num_to_load = game.update(menu.update(map_num_to_load))
        end
    end)
end

function love.update(dt)
    coroutine.resume(update, dt)
end

function love.keyreleased(key, uni)
    if 'escape' == key then
        love.event.push('q')
    end
end
