-- Define bitmask directions for clarity
local NW = 256
local N  = 2
local NE = 4
local W  = 8
local E  = 16
local SW = 32
local S  = 64
local SE = 128

-- Lookup table: bitmask -> {row = _, col = _}
return {
	-- Cardinal and isolated
	[S]                                 = { row = 1, col = 1 },
	[N + S]                             = { row = 2, col = 1 },
	[N]                                 = { row = 3, col = 1 },
	[1]                                 = { row = 4, col = 1 }, -- No connections (Wall)

	-- Maze outline (no diagonals)
	[E + S]                             = { row = 1, col = 2 },
	[E + W + S]                         = { row = 1, col = 3 },
	[S + W]                             = { row = 1, col = 4 },

	[N + S + E]                         = { row = 2, col = 2 },
	[N + S + E + W]                     = { row = 2, col = 3 },
	[N + S + W]                         = { row = 2, col = 4 },

	[N + E]                             = { row = 3, col = 2 },
	[N + E + W]                         = { row = 3, col = 3 },
	[N + W]                             = { row = 3, col = 4 },

	[E]                                 = { row = 4, col = 2 },
	[E + W]                             = { row = 4, col = 3 },
	[W]                                 = { row = 4, col = 4 },

	-- Complex with diagonals
	[N + E + S + W + NW]                = { row = 1, col = 5 },
	[E + S + W + SE]                    = { row = 1, col = 6 },
	[E + S + W + SW]                    = { row = 1, col = 7 },
	[N + E + S + W + NE]                = { row = 1, col = 8 },

	[N + E + S + SE]                    = { row = 2, col = 5 },
	[N + E + S + W + NE + SE + SW]      = { row = 2, col = 6 },
	[N + E + S + W + NW + SE + SW]      = { row = 2, col = 7 },
	[N + E + S + SW]                    = { row = 2, col = 8 },

	[N + E + S + NE]                    = { row = 3, col = 5 },
	[N + E + S + W + NE + SE + NW]      = { row = 3, col = 6 },
	[N + E + S + W + NE + NW + SW]      = { row = 3, col = 7 },
	[N + S + W + NW]                    = { row = 3, col = 8 },

	[N + E + S + W + SW]                = { row = 4, col = 5 },
	[N + E + W + NE]                    = { row = 4, col = 6 },
	[N + E + W + NW]                    = { row = 4, col = 7 },
	[N + E + S + W + SE]                = { row = 4, col = 8 },

	-- Final block
	[E + S + SE]                        = { row = 1, col = 9 },
	[N + E + S + W + SE + SW]           = { row = 1, col = 10 },
	[E + S + W + SE + SW]               = { row = 1, col = 11 },
	[W + S + SW]                        = { row = 1, col = 12 },

	[N + E + S + NE + SE]               = { row = 2, col = 9 },
	[N + E + S + W + SW + NE]           = { row = 2, col = 10 },
	[0]                                 = { row = 2, col = 11 }, -- No connections (Path)
	[N + E + S + W + SW + NW]           = { row = 2, col = 12 },

	[N + E + S + W + NE + SE]           = { row = 3, col = 9 },
	[N + E + S + W + NE + SE + SW + NW] = { row = 3, col = 10 }, -- all connections
	[N + E + S + W + SE + NW]           = { row = 3, col = 11 },
	[N + S + W + SW + NW]               = { row = 3, col = 12 },

	[N + E + NE]                        = { row = 4, col = 9 },
	[N + E + W + NE + NW]               = { row = 4, col = 10 },
	[N + E + S + W + NW + NE]           = { row = 4, col = 11 },
	[N + W + NW]                        = { row = 4, col = 12 },
}
