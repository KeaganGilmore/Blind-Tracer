local Class            = require("lib.middleclass")
local Maze             = Class("Maze")
local Path             = ...

-- Static configuration
local tileSize         = 128
local tileSheetPath    = Path:gsub("%.", "/") .. "/tile_sheet.png"

Maze.static.algs       = { recursiveBacktracking = require(Path .. ".algs.recursive_backtracking") }
Maze.static.tileSheet  = love.graphics.newImage(tileSheetPath)
Maze.static.tileLookup = require(Path .. ".tile_map")
Maze.static.tileQuads  = {}
Maze.static.tileSize   = tileSize

-- Precompute quads from the tile map
do
	local sheetW, sheetH = Maze.static.tileSheet:getDimensions()
	for bitmask, pos in pairs(Maze.static.tileLookup) do
		local y = (pos[1] - 1) * tileSize
		local x = (pos[2] - 1) * tileSize
		Maze.static.tileQuads[bitmask] = love.graphics.newQuad(x, y, tileSize, tileSize, sheetW, sheetH)
	end
end

-- Constructor
function Maze:initialize(rows, cols, alg, seed)
	self.rows = rows
	self.cols = cols
	self.seed = seed
	local generator = Maze.algs[alg or "recursiveBacktracking"]
	assert(generator, "Invalid algorithm: " .. tostring(alg))
	self.grid, self.path, self.tileMap = generator(rows, cols, seed)
end

-- Print the maze to console
function Maze:print()
	for r = 1, self.rows do
		local row = self.grid[r]
		local line = {}
		for c = 1, self.cols do
			line[#line + 1] = (row[c] == 1) and "#" or " "
		end
		print(table.concat(line))
	end
end

function Maze:draw()
	local scale = 0.3
	local tileSizeScaled = tileSize * scale

	-- Draw maze tiles
	for r = 1, self.rows do
		for c = 1, self.cols do
			local quad = Maze.static.tileQuads[self.tileMap[r][c]]
			if quad then
				love.graphics.draw(
					Maze.static.tileSheet,
					quad,
					(c - 1) * tileSizeScaled,
					(r - 1) * tileSizeScaled,
					0, scale, scale
				)
			end
		end
	end

	-- Draw the longest path as a red line
	if self.path and #self.path > 1 then
		love.graphics.setColor(1, 0, 0, 0.8) -- Red, semi-transparent

		for i = 1, #self.path - 1 do
			local a = self.path[i]
			local b = self.path[i + 1]

			local ax = (a.x - 0.5) * tileSizeScaled
			local ay = (a.y - 0.5) * tileSizeScaled
			local bx = (b.x - 0.5) * tileSizeScaled
			local by = (b.y - 0.5) * tileSizeScaled

			love.graphics.line(ax, ay, bx, by)
		end

		love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
	end
end

return Maze
