-- Main test entry point for client modules
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_CLIENT")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_client")

safeLog("Client: Loaded")

---@diagnostic disable-next-line: unnecessary-if
if pzc.kikito.inspectlua then
    -- use inspectlua
    safeLog("TEST use inspectlua")
end
