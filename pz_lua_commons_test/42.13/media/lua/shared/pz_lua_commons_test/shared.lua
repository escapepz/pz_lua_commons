-- Main test entry point for shared modules
local safeLog = require("pz_lua_commons/safelogger")
local pzc = require("pz_lua_commons_shared")

safeLog("Shared: Loaded")

if pzc.grafi_tt.lunajson then
	-- use lunajson
	safeLog("TEST use lunajson")
end
