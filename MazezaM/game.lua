game = {}

function game.update(map_num_to_load)
    -- state variables
    local done = false
    local restart = false
    
    -- hook key handler
    local keyreleased = love.keyreleased
    love.keyreleased = function(key, uni)
        if 'left' == key then
            MZM.pdx, MZM.pdy =-1, 0
        elseif 'right' == key then
            MZM.pdx, MZM.pdy = 1, 0
        elseif 'up' == key then
            MZM.pdx, MZM.pdy = 0,-1
        elseif 'down' == key then
            MZM.pdx, MZM.pdy = 0, 1
        elseif 'r' == key then
            restart = true
        elseif 'escape' == key then
            done = true
        else
            keyreleased(key, uni)
        end
    end

    -- replace draw function
    love.graphics.setBackgroundColor(127, 127, 127)

    love.draw = game.draw
    MZM.load(map_num_to_load)
    
    -- frame loop
    while not (done or restart) do
        -- try move
        if MZM.pdx ~= 0 or MZM.pdy ~= 0 then
            local new_x, new_y = MZM.px + MZM.pdx, MZM.py + MZM.pdy
            
            local old_tile = MZM.tiles[MZM.py][MZM.px]
            local new_tile = MZM.tiles[new_y][new_x]
            
            -- if new pos is still inside the map
            if new_x > 0 and new_x < MZM.w + 1 and new_y > 0 and new_y < MZM.h + 1 then
                -- try row move if a movable tile is left or right of player
                if 2 == new_tile and MZM.pdx ~= 0 then
                    if MZM.pdx < 0 then
                        MZM.rotate_row_left(MZM.py, MZM.px)
                    else
                        MZM.rotate_row_right(MZM.py, MZM.px)
                    end
                    new_tile = MZM.tiles[new_y][new_x]
                end
                
                -- can move into an empty tile or the exit tile
                if 0 == new_tile or 4 == new_tile then
                    MZM.px, MZM.py = new_x, new_y
                end
            elseif 4 == old_tile then
                -- exit tile
                map_num_to_load = map_num_to_load + 1
                MZM.load(map_num_to_load)
            end
                    
            -- clear move
            MZM.pdx, MZM.pdy = 0, 0
        end
        
        coroutine.yield()
    end

    -- restore key handler
    love.keyreleased = keyreleased    

    if restart then 
        return map_num_to_load
    else
        return 0
    end
end

function game.draw()
    -- draw the title
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(MZM.title, 0, 14, 800, 'center')
    
    -- draw the maze
    for ri, row in ipairs(MZM.tiles) do
        for ci, tile in ipairs(row) do
            if 0 == tile then 
                love.graphics.setColor(127, 127, 127)
            elseif 1 == tile then
                love.graphics.setColor(0, 0, 0)
            elseif 2 == tile then
                love.graphics.setColor(255, 223, 0)
            elseif 3 == tile then
                love.graphics.setColor(143, 143, 143)
            elseif 4 == tile then
                love.graphics.setColor(111, 111, 111)
            end
            love.graphics.rectangle('fill', ci * 16, ri * 16, 16, 16)
        end
    end
    
    -- draw the player
    love.graphics.setColor(255, 127, 127)
    love.graphics.circle('fill', MZM.px * 16 + 8, MZM.py * 16 + 8, 6)
end
