---@type table|function|nil
local konijima_utilities

local escape = require("pz_utils/escape/index")

local SafeLogger = escape.SafeLogger
local safe_logger = SafeLogger.new("pz_utils")

konijima_utilities = escape.SafeRequire("pz_utils/konijima/utilities", "konijima")

local pz_utils = {
    escape = escape,
    konijima = {
        Utilities = konijima_utilities,
    },
}

safe_logger:log("Shared Loaded", 20)
return pz_utils
