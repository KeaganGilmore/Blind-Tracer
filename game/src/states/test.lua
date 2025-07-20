local Test = {}

function Test:initialize()

end

function Test:update()

end

function Test:draw()
	love.graphics.print("Correct Solution")
end

function Test:keypressed(key, scancode, isrepeat)
	Gamestate.switch(States["start"])
end

return Test
