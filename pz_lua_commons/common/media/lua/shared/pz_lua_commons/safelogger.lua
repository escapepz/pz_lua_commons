-- MyDefensiveMod.lua aka safelogger.lua
local hasZUL, ZUL = pcall(require, "ZUL")
local logger = nil
local LOG_MODULE_NAME = "pz_lua_commons"

if hasZUL and type(ZUL) == "table" and type(ZUL.new) == "function" then
	local ok, result = pcall(ZUL.new, LOG_MODULE_NAME)
	if ok and result then
		logger = result
		---@diagnostic disable-next-line: need-check-nil
		pcall(function()
			logger:info("ZUL detected and enabled")
		end)
	end
end

local function safeLog(msg, debug)
	if not logger and not debug then
		print("[" .. LOG_MODULE_NAME .. "] " .. tostring(msg))
		return
	end

	if not logger then
		return
	end

	---@diagnostic disable-next-line: need-check-nil
	pcall(function()
		(debug and logger.debug or logger.info)(logger, msg)
	end)
end

return safeLog
