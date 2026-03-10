-- Main test entry point for shared modules
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_shared")

safeLog("Shared: Loaded")

if pzc.grafi_tt.lunajson then
    -- use lunajson
    safeLog("TEST use lunajson")
end
