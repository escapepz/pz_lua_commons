local lunajson, middleclass, jsonlua, hump_signal

local safe_require = require("pz_utils/escape/safe_require")
local SafeLogger = require("pz_utils/escape/safe_logger")
local safe_logger = SafeLogger.new("pz_lua_commons")

lunajson = safe_require("pz_lua_commons/grafi-tt/lunajson_1_2_3/lunajson", "lunajson")
middleclass = safe_require("pz_lua_commons/kikito/middleclass_v4_1_1/middleclass", "middleclass")
jsonlua = safe_require("pz_lua_commons/rxi/jsonlua_0_1_2/json", "json")
hump_signal = safe_require("pz_lua_commons/vrld/hump/signal", "hump.signal")

local pz_lua_commons = {
	grafi_tt = {
		lunajson = lunajson,
	},
	kikito = {
		middleclass = middleclass,
	},
	rxi = {
		jsonlua = jsonlua,
	},
	vrld = {
		hump = {
			signal = hump_signal,
		},
	},
}

safe_logger:log("Shared Loaded", 20)
return pz_lua_commons
