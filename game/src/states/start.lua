local Maze = require("src.maze")

local Start = {}

function Start:init()
	self.maze = Maze(21, 21)
end

function Start:update(dt)

end

function Start:draw()
	self.maze:draw()
end

function Start:mousepressed()
	self.maze = Maze(21, 21)
end

return Start
