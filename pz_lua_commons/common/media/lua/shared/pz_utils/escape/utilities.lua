---@author eScape
-- https://github.com/escapepz
---@class ESC_Utilities
local Utilities = {}
local math_floor = math.floor
local os_time = os.time

--- [SHARED]
--- Return a numeric timestamp (seconds) for real-world (system) time
--- Returns an integer (math.floor)
function Utilities.GetIRLTimestamp()
	return math_floor(os_time())
end

return Utilities
