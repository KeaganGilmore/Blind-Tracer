-- local Maze  = require("src.maze")
local Start     = {}

local NW        = 256
local N         = 2
local NE        = 4
local W         = 8
local E         = 16
local SW        = 32
local S         = 64
local SE        = 128

local tileset   = love.graphics.newImage("src/maze/sheet.png")
local tilemap   = require("src.maze.tilemap")

local tilecoord = tilemap[W + S]

local quad      = love.graphics.newQuad((tilecoord.col - 1) * 128, (tilecoord.row - 1) * 128, 128, 128,
	tileset:getDimensions())


function Start:init()
	--self.maze = Maze(5, 5)
end

function Start:update(dt)
end

function Start:draw()
	--love.graphics.draw(tileset, quad, 0, 0)
end

return Start
