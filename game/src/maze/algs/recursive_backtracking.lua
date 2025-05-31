local Lume = require("lib.lume")

return function(rows, cols, seed)
	math.randomseed(seed or os.time())

	-- Ensure it is odd numbered
	if rows % 2 == 0 then rows = rows + 1 end
	if cols % 2 == 0 then cols = cols + 1 end

	-- Initialise variables
	local maze, tileMap, longestPath, currentPath = {}, {}, {}, {}

	for y = 1, rows do
		maze[y], tileMap[y] = {}, {}
		for x = 1, cols do
			maze[y][x] = 1
			tileMap[y][x] = 0
		end
	end

	local directions = {
		{ dx = 0,  dy = -2, opp = 8 },
		{ dx = 0,  dy = 2,  opp = 2 },
		{ dx = -2, dy = 0,  opp = 1 },
		{ dx = 2,  dy = 0,  opp = 4 },
	}

	local function carve(x, y)
		maze[y][x] = 0
		table.insert(currentPath, { x = x, y = y })
		if #currentPath > #longestPath then longestPath = Lume.clone(currentPath) end
		local dirs = Lume.shuffle({ 1, 2, 3, 4 })
		for _, i in ipairs(dirs) do
			local dir = directions[i]
			local nx, ny = x + dir.dx, y + dir.dy
			if ny > 0 and ny < rows and nx > 0 and nx < cols and maze[ny][nx] == 1 then
				maze[y + dir.dy / 2][x + dir.dx / 2] = 0
				carve(nx, ny)
			end
		end
		table.remove(currentPath)
	end

	carve(2, 2)

	for r = 1, rows do
		for c = 1, cols do
			if maze[r][c] == 1 then
				for _, dir in ipairs(directions) do
					local nr, nc = r + dir.dx / 2, c + dir.dy / 2
					if maze[nr] and maze[nr][nc] == 1 then
						tileMap[r][c] = tileMap[r][c] + dir.opp
					end
				end
			end
		end
	end

	return maze, longestPath, tileMap
end
