local Class = require("lib.middleclass")
local Maze = Class("Maze")

local algPath = (...) .. ".algs."

Maze.static.algs = {
	recursiveBacktracking = require(algPath .. "recursive_backtracking")
}

function Maze:initialize(rows, cols, alg, seed)
	self.rows = rows
	self.cols = cols
	self.seed = seed
	self.algorithm = Maze.algs[alg or "recursiveBacktracking"]
	assert(self.algorithm, "Invalid algorithm: " .. tostring(alg))
	self.grid = self.algorithm(rows, cols, seed)
end

function Maze:print()
	for y = 1, #self.grid do
		local row = ""
		for x = 1, #self.grid[y] do
			row = row .. (self.grid[y][x] == 1 and "#" or " ")
		end
		print(row)
	end
end

return Maze
