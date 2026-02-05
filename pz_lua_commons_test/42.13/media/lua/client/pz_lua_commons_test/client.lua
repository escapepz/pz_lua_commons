local safeLog = require("pz_lua_commons/safelogger")
local pzc = require("pz_lua_commons_client")
---@diagnostic disable-next-line: unnecessary-if
if pzc.kikito.inspectlua then
	-- use inspectlua
	safeLog("TEST use inspectlua")
end
