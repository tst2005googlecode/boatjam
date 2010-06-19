handy_globals = {
    rads = 0,
	offs = 0,
}

game_over = true

-- Wave control
wave_control = {
	x = 16,
	y = 16,
	w = 160,
}

-- wave functions have a period of 16 units
wfs = {
	saw = function (x) local i, f = math.modf(x * 0.125) return (f * 2 - 1) end, -- sawtooth
	sqr = function (x) local i, f = math.modf(x * 0.125) return ((i % 2) * 2 - 1) end, -- square
	sin = function (x) return math.sin(x * math.pi * 0.125) end, -- sin
	tri = function (x) local i, f = math.modf(x * 0.125) return -2 * (((i % 2) - 0.5) * (f * 2 - 1)) end, -- triangle
}

function reset_wave_control()
	wc_tbl = {
		{ func = wfs.saw, scale = 1, on = false },
		{ func = wfs.sqr, scale = 1, on = false },
		{ func = wfs.sin, scale = 1, on = false },
		{ func = wfs.tri, scale = 1, on = false },
		{ func = wfs.saw, scale = 0.5, on = false },
		{ func = wfs.sqr, scale = 0.5, on = false },
		{ func = wfs.sin, scale = 0.5, on = false },
		{ func = wfs.tri, scale = 0.5, on = false },
	}
end

function draw_wave(func, scale, offs, x, y, w, h)
	for i = 0, w - 1 do
		local y1, y2 = func(i) * scale * h * 0.5, func(i + 1) * scale * h * 0.5
		love.graphics.line(x + offs + i, y + y1, x + offs + i + 1, y + y2)
		love.graphics.line(x + offs + i + w, y + y1, x + offs + i + 1 + w, y + y2)
	end
	
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', x, y - h, -w, h * 2)
	love.graphics.rectangle('fill', x + w, y - h, x + 2 * w, h * 2)
	love.graphics.setColor(r, g, b, a)
end

function draw_wave_control()
	for i, wct in ipairs(wc_tbl) do
		local xo = wave_control.x
		local yo = wave_control.y + i * 32

		local offs = 0
		if wct.on then
			love.graphics.setColor(255, 255, 255)
			offs = -16 * handy_globals.offs
		else
			love.graphics.setColor(63, 63, 63)
		end

		draw_wave(wct.func, wct.scale, offs, xo, yo, wave_control.w, 16)
	end
end

-- KILLBOTS!
kb_trk = {
	x = 216,
	y = 16,
	w = 248,
}

kb_w = 16
kb_h = 16
kb_spd = 0.1

function reset_killbots()
	kb_tbl = {}
	table.insert(kb_tbl, 
		new_killbot(
			{
				{func = wfs.sqr, scale = 1},
			}
		))
	table.insert(kb_tbl, 
		new_killbot(
			{
				{func = wfs.sqr, scale = 1}, 
				{func = wfs.tri, scale = 0.5},
			}
		))
	table.insert(kb_tbl, 
		new_killbot(
			{
				{func = wfs.sin, scale = 1}, 
				{func = wfs.sin, scale = 0.5},
			}
		))
end

function new_killbot(waves)
	local new_kb = {}
	new_kb.t = 0
	new_kb.waves = waves
	new_kb.on = true
	return new_kb
end

function update_killbots(dt)
	local game_over = false
	for i, kb in ipairs(kb_tbl) do
		kb.t = kb.t + kb_spd * dt
		if kb.t >= 1 then
			game_over = true
		end
	end
	
	return game_over
end

function draw_killbots()
	for i, kb in ipairs(kb_tbl) do
		local x = (1 - kb.t) * kb_trk.x + kb.t * (kb_trk.x + kb_trk.w - kb_w)
		local y = kb_trk.y + 3 * i * kb_h

		-- draw body
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('fill', x, y, kb_w, kb_h)
		
		local offs = 0
		if kb.on then
			offs = -16 * handy_globals.offs
		end

		-- draw control signals
		love.graphics.setColor(255, 255, 255)
		for k, wf in ipairs(kb.waves) do
			draw_wave(wf.func, wf.scale, offs, x - 0.5 * kb_w, y - kb_h, 2 * kb_w, kb_h)
		end
	end
end

-- love callbacks
function love.load()
	reset_wave_control()
	reset_killbots()
end

function love.update(dt)
    -- update handy globals
    handy_globals.rads = handy_globals.rads + dt
    while handy_globals.rads > 2 * math.pi do
        handy_globals.rads = handy_globals.rads - 2 * math.pi
    end
	
	handy_globals.offs = handy_globals.offs + 4 * dt
	while handy_globals.offs > 1 do
		handy_globals.offs = handy_globals.offs - 1
	end

	if not game_over then
		game_over = update_killbots(dt)
	end
end

function love.draw()
    love.graphics.scale(love.graphics.getWidth() / 480, love.graphics.getHeight() / 320)
    
    love.graphics.push()
    
	draw_wave_control()
	draw_killbots()
	
	if game_over then
		love.graphics.printf('Game over, man! GAME OVER! *ahem* Press R to restart', 0, 304, 480, 'center')
	end
    
    love.graphics.pop()
end

function love.keyreleased(key, uni)
    if 'escape' == key then
        love.event.push('q')
	elseif 'r' == key then
		if game_over then
			reset_wave_control()
			reset_killbots()
			game_over = false
		end
	elseif '1' == key then
		wc_tbl[1].on = not wc_tbl[1].on
	elseif '2' == key then
		wc_tbl[2].on = not wc_tbl[2].on
	elseif '3' == key then
		wc_tbl[3].on = not wc_tbl[3].on
	elseif '4' == key then
		wc_tbl[4].on = not wc_tbl[4].on
	elseif '5' == key then
		wc_tbl[5].on = not wc_tbl[5].on
	elseif '6' == key then
		wc_tbl[6].on = not wc_tbl[6].on
	elseif '7' == key then
		wc_tbl[7].on = not wc_tbl[7].on
	elseif '8' == key then
		wc_tbl[8].on = not wc_tbl[8].on
    end
end
