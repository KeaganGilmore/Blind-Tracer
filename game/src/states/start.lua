local Maze = require("src.maze")

local Start = {}

function Start:init()
	self.maze = Maze(21, 21)
	self:resizeMaze()
end

function Start:resizeMaze()
	local sW, sH = love.graphics.getDimensions()
	local size = math.min(sW, sH) * 0.9
	self.maze:setSize(size, size)
	local w, h = self.maze:getDisplayDimensions()
	self.maze:setPosition((sW - w) / 2, (sH - h) / 2)
end

function Start:update(dt)

end

function Start:draw()
	self.maze:draw()
end

function Start:mousepressed()
	-- self.maze = Maze(21, 21)
end

function Start:resize(w, h)
	self:resizeMaze()
end

return Start
