-- MazezaM
MZM = {}

-- Parse the levels.mzm file
function MZM.read_levels_mzm()
    MZM.defs = {}
    
    local map = {}; map[' '] = 0; map['#'] = 1; map['$'] = 2; map['+'] = 3; map['*'] = 4
    local file_lines = love.filesystem.lines('levels.mzm')
    
    local current_title = ''
    for line in file_lines do
        if line:find('%s*;') then
            -- a comment, could contain title
            local _, e = line:find('Title:%s*')
            if e then current_title = line:sub(e + 1, -1) end
        elseif line:find('[#$+*]') then
            -- start of a mazezam definition
            local current_data = {{}}
            for c in line:gmatch('.') do table.insert(current_data[1], map[c]) end
            for line in file_lines do
                if not line:find('[#$+*]') then break end
                table.insert(current_data, {})
                for c in line:gmatch('.') do table.insert(current_data[#current_data], map[c]) end
            end
            table.insert(MZM.defs, { title = current_title, data = current_data })
        end
    end
end

function MZM.load(map_num_to_load)
    MZM.title = MZM.defs[map_num_to_load].title
    MZM.tiles = MZM.defs[map_num_to_load].data
    
    -- height is number of tables in the map_tiles table (one per row)
    MZM.h = #MZM.tiles
    
    -- width is length of the first table in the map_tiles table (assumed the same for each row)
    MZM.w = #MZM.tiles[1]
    
    -- reset player
    MZM.px, MZM.py = 0, 0
    MZM.pdx, MZM.pdy = 0, 0
    for ri, row in ipairs(MZM.tiles) do
        for ci, tile in ipairs(row) do
            if 3 == tile then 
                MZM.px, MZM.py = ci, ri 
                break
            end
        end
    end
    
    -- log message
    print('Loaded "' .. MZM.title .. '"')
end

-- try and rotate the movable blocks in row with player at index col
function MZM.rotate_row_left(row, col)
    local row_len = #MZM.tiles[row]
    local i
    -- search from pos to start of row to find leftmost movable tile
    for tile = col, 1, -1 do
        if 2 == MZM.tiles[row][tile] then
            i = tile
        end
    end
    
    -- if the space left of the leftmost movable tile is empty, shift the row
    if 0 == MZM.tiles[row][i - 1] then
        for tile = 2, row_len - 2 do
            MZM.tiles[row][tile] = MZM.tiles[row][tile + 1]
        end
        MZM.tiles[row][row_len - 1] = 0
    end
end

function MZM.rotate_row_right(row, col)
    local row_len = #MZM.tiles[row]
    local i
    -- search from pos to end of row to find rightmost movable tile
    for tile = col, row_len do
        if 2 == MZM.tiles[row][tile] then
            i = tile
        end
    end
    
    -- if the space right of the rightmost movable tile is empty, shift the row
    if 0 == MZM.tiles[row][i + 1] then
        for tile = row_len - 1, 3, -1 do
            MZM.tiles[row][tile] = MZM.tiles[row][tile - 1]
        end
        MZM.tiles[row][2] = 0
    end
end
