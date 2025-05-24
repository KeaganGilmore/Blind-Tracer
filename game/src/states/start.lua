local Maze = require("src.maze")

local Start = {}

function Start:init()
	self.maze = Maze(21, 21)
	self.maze:print()
end

function Start:update(dt)

end

function Start:draw()
	self.maze:draw()
end

return Start
