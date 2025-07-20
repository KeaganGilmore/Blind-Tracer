local Maze = require("src.maze")

local Start = {}

function Start:init()
end

function Start:enter()
	-- Create a new maze every time the state is entered
	self.maze = Maze(21, 21)
	self.maze:setGridEnabled(false)
	self.maze:setSelectionEnabled(true)
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
	if self.maze then -- Add safety check in case update is called before enter
		self.maze:update()
	end
end

function Start:draw()
	if self.maze then -- Add safety check in case draw is called before enter
		self.maze:draw()
	end
end

function Start:resize(w, h)
	if self.maze then -- Add safety check in case resize is called before enter
		self:resizeMaze()
	end
end

function Start:keypressed(key, scancode, isrepeat)
	if key == "space" then
		if self.maze and self.maze:isSelectionCorrectPath() then
			Gamestate.switch(States["test"])
		end
	end
end

return Start
