local inspectlua, serpent, yon_30log

local safe_require = require("pz_utils/escape/safe_require")
local SafeLogger = require("pz_utils/escape/safe_logger")

local safe_logger = SafeLogger.new("pz_lua_commons")

-- Strictly client-side only.
if not isServer() then
	inspectlua = safe_require("pz_lua_commons/kikito/inspectlua_v3_1_3/inspect", "inspectlua")
	serpent = safe_require("pz_lua_commons/pkulchenko/serpent_0_30/serpent", "serpent")
	yon_30log = safe_require("pz_lua_commons/yonaba/yon_30log_1_3_0/yon_30log", "30log")
end

local pz_lua_commons = {
	kikito = {
		inspectlua = inspectlua,
	},
	pkulchenko = {
		serpent = serpent,
	},
	yonaba = {
		yon_30log = yon_30log,
	},
}

safe_logger:log("Client Loaded", 20)
return pz_lua_commons
