---@type table|function|nil
local konijima_utilities

local escape = require("pz_utils/escape/index")

escape.SafeLogger.init("pz_utils")

konijima_utilities = escape.SafeRequire("pz_utils/konijima/utilities", "konijima")

local pz_utils = {
	escape = escape,
	konijima = {
		Utilities = konijima_utilities,
	},
}

escape.SafeLogger.log("Shared Loaded", 20)
return pz_utils
