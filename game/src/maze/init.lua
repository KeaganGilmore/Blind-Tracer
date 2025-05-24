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

local DIRS             = {
	{ dr = -1, dc = 0,  bit = 1 },
	{ dr = 1,  dc = 0,  bit = 4 },
	{ dr = 0,  dc = -1, bit = 8 },
	{ dr = 0,  dc = 1,  bit = 2 },
}

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

	self.grid = generator(rows, cols, seed)
	self:generateTileMap()
end

function Maze:generateTileMap()
	self.tileMap = {}

	for r = 1, self.rows do
		self.tileMap[r] = {}
		for c = 1, self.cols do
			self.tileMap[r][c] = 0
		end
	end

	for r = 1, self.rows do
		for c = 1, self.cols do
			if self.grid[r][c] == 1 then
				for _, dir in ipairs(DIRS) do
					local nr, nc = r + dir.dr, c + dir.dc
					if self.grid[nr] and self.grid[nr][nc] == 1 then
						self.tileMap[r][c] = self.tileMap[r][c] + dir.bit
					end
				end
			end
		end
	end
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

-- Draw the maze using quads
function Maze:draw()
	local scale = 0.3
	local tileSizeScaled = tileSize * scale

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
end

return Maze
