local Class            = require("lib.middleclass")
local Maze             = Class("Maze")
local Path             = ... .. "."

-- Static configuration
Maze.static.algs       = { recursiveBacktracking = require(Path .. "algs.recursive_backtracking") }
Maze.static.tileSheet  = love.graphics.newImage(Path:gsub("%.", "/") .. "tile_sheet.png")
Maze.static.shaderFunc = require(Path .. "palette_shader")
Maze.static.tileLookup = require(Path .. "tile_map")
Maze.static.tileSize   = 128
Maze.static.tileQuads  = {}

-- Precompute quads from the tile map
do
	local sheetW, sheetH = Maze.static.tileSheet:getDimensions()
	for bitmask, pos in pairs(Maze.static.tileLookup) do
		local y = (pos[1] - 1) * Maze.tileSize
		local x = (pos[2] - 1) * Maze.tileSize
		Maze.static.tileQuads[bitmask] = love.graphics.newQuad(x, y, Maze.tileSize, Maze.tileSize, sheetW, sheetH)
	end
end

-- Constructor
function Maze:initialize(rows, cols, alg, seed)
	local generator = Maze.algs[alg or "recursiveBacktracking"]
	assert(generator, "Invalid algorithm: " .. tostring(alg))
	self.rows = rows
	self.cols = cols
	self.seed = seed
	self.grid, self.path, self.tileMap = generator(rows, cols, seed)
	self.displayScale = 0.3
	self.displayTileSize = nil
	self.x = 0
	self.y = 0
	self.canvas = love.graphics.newCanvas(self.cols * Maze.tileSize, self.rows * Maze.tileSize)

	-- Grid selection properties
	self.gridEnabled = false
	self.selectedCells = {}   -- Table to store multiple selected cells
	self.isDragging = false
	self.dragMode = "select"  -- Default mode is "select", toggles with right-click
	self.wasRightPressed = false -- Track right mouse button state for edge detection

	self:renderToCanvas()
end

function Maze:setPosition(x, y)
	self.x = x or 0
	self.y = y or 0
end

-- Enable/disable the selectable grid overlay
function Maze:setGridEnabled(enabled)
	self.gridEnabled = enabled
end

function Maze:isGridEnabled()
	return self.gridEnabled
end

-- Toggle between select and deselect modes
function Maze:toggleDragMode()
	if self.dragMode == "select" then
		self.dragMode = "deselect"
	else
		self.dragMode = "select"
	end
end

-- Get current drag mode
function Maze:getDragMode()
	return self.dragMode
end

-- Convert screen coordinates to grid coordinates
function Maze:screenToGrid(screenX, screenY)
	local effectiveTileSize = self:getEffectiveTileSize()
	local localX = screenX - self.x
	local localY = screenY - self.y

	if localX < 0 or localY < 0 then return nil, nil end

	local col = math.floor(localX / effectiveTileSize) + 1
	local row = math.floor(localY / effectiveTileSize) + 1

	if row >= 1 and row <= self.rows and col >= 1 and col <= self.cols then
		return row, col
	end

	return nil, nil
end

-- Convert grid coordinates to screen coordinates (top-left of cell)
function Maze:gridToScreen(row, col)
	if not row or not col or row < 1 or row > self.rows or col < 1 or col > self.cols then
		return nil, nil
	end

	local effectiveTileSize = self:getEffectiveTileSize()
	local screenX = self.x + (col - 1) * effectiveTileSize
	local screenY = self.y + (row - 1) * effectiveTileSize

	return screenX, screenY
end

-- Update drag selection
function Maze:update()
	if not self.gridEnabled then return end

	local mouseX, mouseY = love.mouse.getPosition()
	local isLeftPressed = love.mouse.isDown(1) -- Left mouse button
	local isRightPressed = love.mouse.isDown(2) -- Right mouse button
	local row, col = self:screenToGrid(mouseX, mouseY)

	-- Handle right-click to toggle drag mode
	if isRightPressed and not self.wasRightPressed then
		self:toggleDragMode()
	end
	self.wasRightPressed = isRightPressed

	if isLeftPressed and row and col then
		local cellKey = row .. "," .. col

		if not self.isDragging then
			-- Start dragging
			self.isDragging = true
		end

		-- Apply current drag mode
		if self.dragMode == "select" and not self.selectedCells[cellKey] then
			self.selectedCells[cellKey] = { row = row, col = col }
		elseif self.dragMode == "deselect" and self.selectedCells[cellKey] then
			self.selectedCells[cellKey] = nil
		end
	else
		-- Stop dragging when mouse is released
		self.isDragging = false
	end
end

-- Check if a specific cell is selected
function Maze:isCellSelected(row, col)
	local cellKey = row .. "," .. col
	return self.selectedCells[cellKey] ~= nil
end

-- Clear selection
function Maze:clearSelection()
	self.selectedCells = {}
end

-- Render the maze to the canvas (called once)
function Maze:renderToCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	for r = 1, self.rows do
		for c = 1, self.cols do
			local quad = Maze.tileQuads[self.tileMap[r][c]]
			if quad then love.graphics.draw(Maze.tileSheet, quad, (c - 1) * Maze.tileSize, (r - 1) * Maze.tileSize) end
			if self.path[r][c] == 1 then
				love.graphics.setColor(1, 0, 0, 0.5)
				love.graphics.rectangle("fill", (c - 1) * Maze.tileSize, (r - 1) * Maze.tileSize, Maze.tileSize,
					Maze.tileSize)
				love.graphics.setColor(1, 1, 1, 1)
			end
		end
	end
	love.graphics.setCanvas()
end

function Maze:getPosition()
	return self.x, self.y
end

function Maze:setScale(scale)
	self.displayScale = scale
	self.displayTileSize = nil
end

function Maze:setTileSize(tileSize)
	self.displayTileSize = tileSize
	self.displayScale = tileSize / Maze.tileSize
end

function Maze:setSize(width, height)
	local scaleX = width / (self.cols * Maze.tileSize)
	local scaleY = height / (self.rows * Maze.tileSize)
	local scale = math.min(scaleX, scaleY)
	self:setScale(scale)
end

function Maze:getEffectiveTileSize()
	return self.displayTileSize or (Maze.tileSize * self.displayScale)
end

function Maze:getDisplayDimensions()
	local effectiveTileSize = self:getEffectiveTileSize()
	return self.cols * effectiveTileSize, self.rows * effectiveTileSize
end

-- Draw the grid overlay
function Maze:drawGrid()
	if not self.gridEnabled then return end

	local effectiveTileSize = self:getEffectiveTileSize()

	-- Draw grid rectangles
	love.graphics.setColor(0.5, 0.5, 0.5, 0.3) -- Simple gray
	love.graphics.setLineWidth(1)

	for r = 1, self.rows do
		for c = 1, self.cols do
			local x = self.x + (c - 1) * effectiveTileSize
			local y = self.y + (r - 1) * effectiveTileSize
			love.graphics.rectangle("line", x, y, effectiveTileSize, effectiveTileSize)
		end
	end

	-- Draw selected cells
	love.graphics.setColor(0, 1, 0, 0.5) -- Simple green
	for key, cell in pairs(self.selectedCells) do
		local x, y = self:gridToScreen(cell.row, cell.col)
		if x and y then
			love.graphics.rectangle("fill", x, y, effectiveTileSize, effectiveTileSize)
		end
	end

	-- Reset color
	love.graphics.setColor(1, 1, 1, 1)
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
	love.graphics.draw(self.canvas, self.x, self.y, 0, self.displayScale, self.displayScale)
	self:drawGrid()
end

return Maze
