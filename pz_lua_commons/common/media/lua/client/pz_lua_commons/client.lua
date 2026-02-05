local inspectlua, serpent, yon_30log

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

if not isServer() then
	inspectlua = safe_require("pz_lua_commons/kikito/inspectlua_v3_1_3/inspect")
	serpent = safe_require("pz_lua_commons/pkulchenko/serpent_0_30/serpent")
	yon_30log = safe_require("pz_lua_commons/yonaba/yon_30log_1_3_0/yon_30log")
end

if	not	inspectlua	then	warn_missing("inspectlua")	end
if	not	serpent		then	warn_missing("serpent")		end
if	not	yon_30log	then	warn_missing("30log")			end

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

safeLog("Client Loaded")
return pz_lua_commons
