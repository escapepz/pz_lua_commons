--- Production-grade Sandbox Variables Module
--- Build 42 compatible
--- All timing values are in real-world hours (IRL)
--- Can respect vanilla HoursForLootRespawn with multiplier
--- This module is the ONLY place SandboxVars is accessed for mods
---
--- Usage:
---   SandboxVarsModule.Init("ModName", { key1 = defaultValue1, key2 = defaultValue2 })
---   local value = SandboxVarsModule.Get("key1")
---   local vanilla = SandboxVarsModule.GetVanilla("HoursForLootRespawn")

local SandboxVarsModule = {}

-- Module metadata
SandboxVarsModule.VERSION = "1.0.0"
SandboxVarsModule.BUILD = "42+"

-- Local cache of sandbox variables per module
local SandboxConfigs = {}

-- Default values per module
local DefaultsPerModule = {}

-- Currently active module namespace
local CurrentNamespace = nil

--- Validate that SandboxVars exists
--- @return boolean True if valid
local function ValidateSandboxVars()
	if not SandboxVars then
		error("SandboxVars not available. Ensure this is called after SandboxVars initialization.")
		return false
	end
	return true
end

--- Initialize sandbox variables for a specific mod
--- @param namespace string The mod namespace (e.g., "DDDLootRespawn", "MyModName")
--- @param defaults table Default values for the configuration
--- @return boolean Success status
function SandboxVarsModule.Init(namespace, defaults)
	if not namespace or type(namespace) ~= "string" or namespace == "" then
		error("SandboxVarsModule.Init requires a valid namespace string")
		return false
	end

	if not defaults or type(defaults) ~= "table" then
		error("SandboxVarsModule.Init requires a defaults table")
		return false
	end

	if not ValidateSandboxVars() then
		return false
	end

	-- Ensure sandbox namespace exists
	SandboxVars[namespace] = SandboxVars[namespace] or {}

	-- Set as current namespace
	CurrentNamespace = namespace

	-- Initialize storage for this namespace
	SandboxConfigs[namespace] = {}
	DefaultsPerModule[namespace] = {}

	-- Cache values from SandboxVars and store defaults
	local cfg = SandboxVars[namespace]
	for key, defaultValue in pairs(defaults) do
		DefaultsPerModule[namespace][key] = defaultValue
		if cfg[key] == nil then
			SandboxConfigs[namespace][key] = defaultValue
		else
			SandboxConfigs[namespace][key] = cfg[key]
		end
	end

	return true
end

--- Get a sandbox variable value with default fallback
--- @param key string The variable name
--- @param defaultValue any Optional override default value
--- @return any The configuration value or default
function SandboxVarsModule.Get(key, defaultValue)
	if not CurrentNamespace then
		error("SandboxVarsModule not initialized. Call Init() first.")
		return nil
	end

	if not key or type(key) ~= "string" then
		error("SandboxVarsModule.Get requires a valid key string")
		return nil
	end

	local cfg = SandboxConfigs[CurrentNamespace]
	---@diagnostic disable-next-line: unnecessary-if
	if cfg and cfg[key] ~= nil then
		return cfg[key]
	end

	if defaultValue ~= nil then
		return defaultValue
	end

	local defaults = DefaultsPerModule[CurrentNamespace]
	---@diagnostic disable-next-line: unnecessary-if
	if defaults then
		return defaults[key]
	end

	return nil
end

--- Get a sandbox variable from a specific namespace
--- @param namespace string The mod namespace
--- @param key string The variable name
--- @param defaultValue any Optional override default value
--- @return any The configuration value or default
function SandboxVarsModule.GetFromNamespace(namespace, key, defaultValue)
	if not namespace or type(namespace) ~= "string" then
		error("GetFromNamespace requires a valid namespace string")
		return nil
	end

	if not SandboxConfigs[namespace] then
		error("Namespace '" .. namespace .. "' not initialized")
		return nil
	end

	local cfg = SandboxConfigs[namespace]
	---@diagnostic disable-next-line: unnecessary-if
	if cfg and cfg[key] ~= nil then
		return cfg[key]
	end

	if defaultValue ~= nil then
		return defaultValue
	end

	local defaults = DefaultsPerModule[namespace]
	---@diagnostic disable-next-line: unnecessary-if
	if defaults then
		return defaults[key]
	end

	return nil
end

--- Get vanilla sandbox variable (HoursForLootRespawn, DayLength, etc.)
--- @param key string The vanilla SandboxVars key
--- @param defaultValue any Optional default if key doesn't exist
--- @return any The vanilla sandbox value or default
function SandboxVarsModule.GetVanilla(key, defaultValue)
	if not ValidateSandboxVars() then
		return defaultValue
	end

	if not key or type(key) ~= "string" then
		error("GetVanilla requires a valid key string")
		return defaultValue
	end

	if SandboxVars[key] ~= nil then
		return SandboxVars[key]
	end

	return defaultValue
end

--- Get the current active namespace
--- @return string|nil The current namespace or nil if not initialized
function SandboxVarsModule.GetCurrentNamespace()
	return CurrentNamespace
end

local EMPTY_TABLE = {} -- Allocated once at load time

--- Get all configurations for a namespace
--- @param namespace string The mod namespace (optional, uses current if nil)
--- @return table The configuration table
function SandboxVarsModule.GetAll(namespace)
	namespace = namespace or CurrentNamespace
	if not namespace then
		error("No namespace specified and none currently active")
		return EMPTY_TABLE
	end

	if not SandboxConfigs[namespace] then
		error("Namespace '" .. namespace .. "' not initialized")
		return EMPTY_TABLE
	end

	return SandboxConfigs[namespace]
end

return SandboxVarsModule
