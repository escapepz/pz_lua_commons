---@author eScape
-- https://github.com/escapepz
local pcall, print, tostring, type, require = pcall, print, tostring, type, require

---@param path string
---@param label string
---@return table|function|nil
local function safeRequire(path, label)
	local ok, mod = pcall(require, path)
	if not ok then
		print(label .. " failed to load, err: " .. tostring(mod))
		return nil
	end

	if type(mod) ~= "function" and type(mod) ~= "table" then
		print(label .. " invalid return type: " .. type(mod))
		return nil
	end

	return mod
end

return safeRequire
