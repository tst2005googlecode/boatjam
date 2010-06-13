menu = {
    -- values shared between update and draw
    selected = 1,
    rads = 0,
}

function menu.update(map_num_to_load)
    -- refresh the level data
    MZM.read_levels_mzm()
    
    -- early out if reloading the current map
    if map_num_to_load > 0 then
        return map_num_to_load
    end
    
    -- state variables
    local done = false
    
    -- hook key handler
    local keyreleased = love.keyreleased
    love.keyreleased = function(key, uni)
        if 'return' == key then
            done = true
        elseif 'up' == key then
            menu.selected = menu.selected - 1
        elseif 'down' == key then        
            menu.selected = menu.selected + 1
        else
            keyreleased(key, uni)
        end
    end
    
    -- replace draw function
    love.graphics.setBackgroundColor(0, 0, 0)
    
    love.draw = menu.draw
    
    -- frame loop
    while not done do
        if menu.selected < 1 then menu.selected = 1 elseif menu.selected > #MZM.defs then menu.selected = #MZM.defs end
        menu.rads = menu.rads + coroutine.yield()
        while menu.rads > 2 * math.pi do menu.rads = menu.rads - 2 * math.pi end
    end
    
    -- restore key handler
    love.keyreleased = keyreleased
    
    return menu.selected
end

function menu.draw()
    for i, v in ipairs(MZM.defs) do
        if menu.selected == i then
            love.graphics.setColor(255, 255, 0)
        else
            local val = (math.sin(menu.rads + i) + 1) * 64 + 127
            love.graphics.setColor(val, val, val)
        end
        love.graphics.print(v.title, 16, 12 * i + 16)
    end
end
