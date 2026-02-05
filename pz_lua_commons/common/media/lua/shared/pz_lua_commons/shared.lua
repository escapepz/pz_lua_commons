local lunajson, middleclass, jsonlua, hump_signal

local function safe_require(path)
	local ok, _module = pcall(require, path)
	if ok then
		return _module
	end
	return nil
end

local safeLog = safe_require("pz_lua_commons/safelogger")
local function warn_missing(name)
	if isMultiplayer() then
		pcall(function()
			safeLog("missing module: " .. tostring(name), true)
		end)
	end
end

lunajson = safe_require("pz_lua_commons/grafi-tt/lunajson_1_2_3/lunajson")
middleclass = safe_require("pz_lua_commons/kikito/middleclass_v4_1_1/middleclass")
jsonlua = safe_require("pz_lua_commons/rxi/jsonlua_0_1_2/json")
hump_signal = safe_require("pz_lua_commons/vrld/hump/signal")

if	not	lunajson	then	warn_missing("lunajson")	end
if	not	middleclass	then	warn_missing("middleclass")	end
if	not	jsonlua		then	warn_missing("json")		end
if	not	hump_signal	then	warn_missing("hump.signal")	end

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

safeLog("Shared Loaded")
return pz_lua_commons
