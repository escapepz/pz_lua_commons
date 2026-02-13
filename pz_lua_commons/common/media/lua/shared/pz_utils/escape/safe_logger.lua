---@author eScape
-- https://github.com/escapepz
-- MyDefensiveMod.lua aka safe_logger.lua

-- 1. LOCALIZING GLOBALS: Cache these once at load time.
-- This converts global table lookups into fast register access.
local pcall, pairs, type, tostring, tonumber, print = pcall, pairs, type, tostring, tonumber, print
local string_upper = string.upper

-- 2. CONFIGURATION & CONSTANTS
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

local CURRENT_THRESHOLD = LOG_LEVELS.INFO -- Only log INFO and above

-- 3. OPTIMIZATION: Reverse Lookup Table
-- This replaces your 'for name, value in pairs' loop with a direct index lookup.
local LEVEL_NAMES = {}
for name, val in pairs(LOG_LEVELS) do
	LEVEL_NAMES[val] = name
end

-- 4. MODULE STATE
---@class ESC_SafeLogger
local SafeLogger = {}
local LOG_MODULE_NAME = "yourmodulename" -- Can be changed via init()
local logger = nil
local hasZUL = false
local ZUL = nil

-- 5. INITIALIZE LOGGER
local function initializeLogger()
	if not hasZUL then
		hasZUL, ZUL = pcall(require, "ZUL")
	end

	if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
		local ok, result = pcall(ZUL.new, LOG_MODULE_NAME)
		if ok and result then
			logger = result
			-- Use pcall directly with the function and arguments to avoid closure creation
			pcall(logger.info, logger, "ZUL detected and enabled")
		end
	else
		print("[" .. LOG_MODULE_NAME .. "] [safe_logger.lua] ZUL not found; use ZUL for better log level control.")
	end
end

-- 6. THE OPTIMIZED HOTPATH FUNCTION
local function safeLog(msg, logLevel)
	-- 1. PRELIMINARY NUMERIC RESOLUTION
	-- If logLevel is already a number (best for performance), we check it immediately.
	local numericLevel = tonumber(logLevel)

	-- 2. STRING RESOLUTION (Only if not a number)
	if not numericLevel and type(logLevel) == "string" then
		numericLevel = LOG_LEVELS[string_upper(logLevel)]
	end

	-- Fallback to INFO (30) if still nil
	numericLevel = numericLevel or 30

	-- 4. HEAVY LIFTING: Only happens if we are actually logging
	local l_logger = logger
	if not l_logger then
		-- THE GATE: Exit before doing ANY string concatenation or logger lookups
		if numericLevel < CURRENT_THRESHOLD then
			return
		end

		-- We only reach this string concat if we are actually printing to console
		local levelName = LEVEL_NAMES[numericLevel] or "INFO"
		print("[" .. LOG_MODULE_NAME .. "] [" .. levelName .. "] " .. tostring(msg))
		return
	end

	local methodName = LOG_LEVEL_METHODS[numericLevel] or "info"
	local method = l_logger[methodName]

	if method then
		pcall(method, l_logger, msg)
	end
end

--- Initialize SafeLogger with a module name
---@param moduleName string|nil
function SafeLogger.init(moduleName)
	LOG_MODULE_NAME = moduleName or LOG_MODULE_NAME
	initializeLogger()
end

--- Log a message with optional level
---@param msg any
---@param level string|number TRACE = 10 | DEBUG = 20 | INFO = 30 | WARN = 40 | ERROR = 50 | FATAL = 60
function SafeLogger.log(msg, level)
	safeLog(msg, level)
end

-- Initialize on require
-- initializeLogger()

return SafeLogger
