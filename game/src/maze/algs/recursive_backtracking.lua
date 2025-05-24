return function(rows, cols, seed)
	math.randomseed(seed or os.time())

	if rows % 2 == 0 then rows = rows + 1 end
	if cols % 2 == 0 then cols = cols + 1 end

	local maze = {}
	for y = 1, rows do
		maze[y] = {}
		for x = 1, cols do
			maze[y][x] = 1
		end
	end

	local directions = {
		{ dx = 0,  dy = -2 },
		{ dx = 0,  dy = 2 },
		{ dx = -2, dy = 0 },
		{ dx = 2,  dy = 0 },
	}

	local function shuffle(tbl)
		for i = #tbl, 2, -1 do
			local j = math.random(i)
			tbl[i], tbl[j] = tbl[j], tbl[i]
		end
	end

	local function carve(x, y)
		maze[y][x] = 0
		local dirs = { 1, 2, 3, 4 }
		shuffle(dirs)
		for _, i in ipairs(dirs) do
			local dir = directions[i]
			local nx, ny = x + dir.dx, y + dir.dy
			if ny > 0 and ny < rows and nx > 0 and nx < cols and maze[ny][nx] == 1 then
				maze[y + dir.dy / 2][x + dir.dx / 2] = 0
				carve(nx, ny)
			end
		end
	end

	carve(2, 2)
	return maze
end
