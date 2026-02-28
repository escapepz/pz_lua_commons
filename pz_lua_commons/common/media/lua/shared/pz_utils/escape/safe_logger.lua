---@author eScape
-- https://github.com/escapepz
-- MyDefensiveMod.lua aka safe_logger.lua

-- LOCALIZING GLOBALS
local pcall, pairs, type, tostring, tonumber, print = pcall, pairs, type, tostring, tonumber, print
local string_upper = string.upper

-- CONSTANTS
local LOG_LEVELS = {
	TRACE = 10,
	DEBUG = 20,
	INFO = 30,
	WARN = 40,
	ERROR = 50,
	FATAL = 60,
}

local LOG_LEVEL_METHODS = {
	[10] = "debug",
	[20] = "debug",
	[30] = "info",
	[40] = "warn",
	[50] = "error",
	[60] = "fatal",
}

-- Reverse Lookup Table
local LEVEL_NAMES = {}
for name, val in pairs(LOG_LEVELS) do
	LEVEL_NAMES[val] = name
end

-- MODULE INTERFACE
---@class ESC_SafeLogger
local SafeLogger = {}

---@class ESC_SafeLogger_Instance
---@field moduleName string
---@field threshold integer
---@field logger function|nil
---@field log function

-- Create a new logger instance
---@param moduleName string
---@param threshold integer
---@return ESC_SafeLogger_Instance
function SafeLogger.new(moduleName, threshold)
	local instance = {
		moduleName = moduleName or "default",
		threshold = threshold or LOG_LEVELS.INFO,
		logger = nil,
	}

	-- Initialize ZUL if available
	local hasZUL, ZUL = pcall(require, "zul")
	if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
		local ok, result = pcall(ZUL.new, instance.moduleName)
		if ok and result then
			instance.logger = result
			pcall(instance.logger.debug, instance.logger, "ZUL detected and enabled")
		end
	end

	-- Log method for this instance
	function instance:log(msg, level)
		local numericLevel = tonumber(level)
		if not numericLevel and type(level) == "string" then
			numericLevel = LOG_LEVELS[string_upper(level)]
		end
		numericLevel = numericLevel or LOG_LEVELS.INFO

		if numericLevel < self.threshold then
			return
		end

		---@diagnostic disable-next-line: unnecessary-if
		if self.logger then
			local methodName = LOG_LEVEL_METHODS[numericLevel] or "info"
			local method = self.logger[methodName]
			if method then
				pcall(method, self.logger, msg)
			end
		else
			local levelName = LEVEL_NAMES[numericLevel] or "INFO"
			print("[" .. self.moduleName .. "] [" .. levelName .. "] " .. tostring(msg))
		end
	end

	-- Convenience methods
	function instance:trace(msg)
		self:log(msg, LOG_LEVELS.TRACE)
	end

	function instance:debug(msg)
		self:log(msg, LOG_LEVELS.DEBUG)
	end

	function instance:info(msg)
		self:log(msg, LOG_LEVELS.INFO)
	end

	function instance:warn(msg)
		self:log(msg, LOG_LEVELS.WARN)
	end

	function instance:error(msg)
		self:log(msg, LOG_LEVELS.ERROR)
	end

	function instance:fatal(msg)
		self:log(msg, LOG_LEVELS.FATAL)
	end

	return instance
end

return SafeLogger
