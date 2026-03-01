-- Mock PZ Stub Module
-- Provides minimal Project Zomboid engine API surface for plain Lua testing
-- Matches stub definitions exactly: https://github.com/PZ-Umbrella/Umbrella

local mock_pz = {}

-- ============================================================================
-- GLOBAL FUNCTIONS
-- ============================================================================

-- Print function - basic logging
function print(...)
	io.write(table.concat({ ... }, "\t") .. "\n")
end

-- Table utilities (standard Lua)
table.insert = table.insert
table.remove = table.remove
table.concat = table.concat

-- Kahlua table extensions
function table.isempty(t)
	return next(t) == nil
end

function table.wipe(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

function table.newarray(...)
	return { ... }
end

function table.getn(t)
	return #t
end

-- Math functions (standard Lua)
math.max = math.max
math.min = math.min
math.floor = math.floor
math.ceil = math.ceil
math.abs = math.abs

-- String utilities
string.sub = string.sub
string.len = string.len
string.format = string.format
string.lower = string.lower
string.upper = string.upper
string.rep = string.rep

-- Kahlua string extensions
function string.trim(s)
	return s:match("^%s*(.-)%s*$")
end

function string.split(s, delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(s, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(s, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(s, delimiter, from)
	end
	table.insert(result, string.sub(s, from))
	return result
end

function string.contains(s, sub)
	return string.find(s, sub, 1, true) ~= nil
end

-- ============================================================================
-- KAHLUA VM STUBS
-- ============================================================================

local Coroutine = {}
Coroutine.__index = Coroutine

function Coroutine.new()
	return setmetatable({}, Coroutine)
end

function Coroutine:resume()
	return true
end

function Coroutine:getCallStack()
	return {}
end

mock_pz.Coroutine = Coroutine

-- ============================================================================
-- BASIC JAVA OBJECT STUBS
-- ============================================================================

-- ArrayList stub for Java collection compatibility
local ArrayList = {}
ArrayList.__index = ArrayList

function ArrayList.new()
	local self = setmetatable({
		_items = {},
	}, ArrayList)
	return self
end

function ArrayList:add(item)
	table.insert(self._items, item)
	return true
end

function ArrayList:remove(index)
	return table.remove(self._items, index)
end

function ArrayList:get(index)
	return self._items[index]
end

function ArrayList:size()
	return #self._items
end

function ArrayList:toArray()
	return self._items
end

mock_pz.ArrayList = ArrayList

-- HashMap stub
local HashMap = {}
HashMap.__index = HashMap

function HashMap.new()
	local self = setmetatable({
		_map = {},
	}, HashMap)
	return self
end

function HashMap:put(key, value)
	self._map[key] = value
	return value
end

function HashMap:get(key)
	return self._map[key]
end

function HashMap:remove(key)
	local val = self._map[key]
	self._map[key] = nil
	return val
end

function HashMap:size()
	local count = 0
	for _ in pairs(self._map) do
		count = count + 1
	end
	return count
end

function HashMap:keySet()
	local keys = {}
	for k in pairs(self._map) do
		table.insert(keys, k)
	end
	return keys
end

mock_pz.HashMap = HashMap

-- ============================================================================
-- VECTOR STUBS (For game world operations)
-- ============================================================================

local Vector2f = {}
Vector2f.__index = Vector2f

function Vector2f.new(x, y)
	return setmetatable({ x = x or 0, y = y or 0 }, Vector2f)
end

function Vector2f:getX()
	return self.x
end

function Vector2f:getY()
	return self.y
end

function Vector2f:set(x, y)
	self.x = x
	self.y = y
	return self
end

function Vector2f:distance(other)
	local dx = self.x - other.x
	local dy = self.y - other.y
	return math.sqrt(dx * dx + dy * dy)
end

mock_pz.Vector2f = Vector2f

local Vector3f = {}
Vector3f.__index = Vector3f

function Vector3f.new(x, y, z)
	return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vector3f)
end

function Vector3f:getX()
	return self.x
end

function Vector3f:getY()
	return self.y
end

function Vector3f:getZ()
	return self.z
end

function Vector3f:set(x, y, z)
	self.x = x
	self.y = y
	self.z = z
	return self
end

function Vector3f:distance(other)
	local dx = self.x - other.x
	local dy = self.y - other.y
	local dz = self.z - other.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

mock_pz.Vector3f = Vector3f

-- ============================================================================
-- GAME STATE STUBS
-- ============================================================================

local GameState = {}
GameState.__index = GameState

function GameState.new()
	return setmetatable({
		_isPaused = false,
		_gameTime = 0,
	}, GameState)
end

function GameState:isPaused()
	return self._isPaused
end

function GameState:setPaused(paused)
	self._isPaused = paused
end

function GameState:getGameTime()
	return self._gameTime
end

function GameState:setGameTime(time)
	self._gameTime = time
end

mock_pz.GameState = GameState

-- ============================================================================
-- ITEM STUBS
-- ============================================================================

local Item = {}
Item.__index = Item

function Item.new(name, weight, value)
	return setmetatable({
		_name = name,
		_weight = weight or 1.0,
		_value = value or 0,
		_count = 1,
	}, Item)
end

function Item:getName()
	return self._name
end

function Item:getWeight()
	return self._weight
end

function Item:getValue()
	return self._value
end

function Item:getCount()
	return self._count
end

function Item:setCount(count)
	self._count = math.max(1, count)
end

mock_pz.Item = Item

-- ============================================================================
-- CHARACTER STUBS
-- ============================================================================

local Character = {}
Character.__index = Character

function Character.new(name, x, y)
	return setmetatable({
		_name = name,
		_x = x or 0,
		_y = y or 0,
		_health = 100,
		_inventory = {},
		_isAlive = true,
		_accessLevel = "None",
	}, Character)
end

function Character:isAccessLevel(level)
	if level == "Admin" then
		return self._accessLevel == "Admin"
	elseif level == "Moderator" then
		return self._accessLevel == "Admin" or self._accessLevel == "Moderator"
	end
	return true
end

function Character:getUsername()
	return self._name
end

function Character:getName()
	return self._name
end

function Character:getX()
	return self._x
end

function Character:getY()
	return self._y
end

function Character:setPosition(x, y)
	self._x = x
	self._y = y
end

function Character:getHealth()
	return self._health
end

function Character:setHealth(health)
	self._health = math.max(0, health)
	self._isAlive = self._health > 0
end

function Character:takeDamage(amount)
	self:setHealth(self._health - amount)
	return not self._isAlive
end

function Character:isAlive()
	return self._isAlive
end

function Character:addItem(item)
	table.insert(self._inventory, item)
end

function Character:getInventoryItems()
	return self._inventory
end

function Character:getInventorySize()
	return #self._inventory
end

mock_pz.Character = Character

-- ============================================================================
-- UTIL FUNCTIONS FOR TIME
-- ============================================================================

function mock_pz.GetTickCount()
	return os.time() * 1000
end

function mock_pz.GetCurrentTimeMs()
	return os.time() * 1000
end

-- ============================================================================
-- SERVER/CLIENT ENVIRONMENT CHECKS
-- ============================================================================

function mock_pz.isServer()
	return false -- Default: client-side for testing
end

function mock_pz.isClient()
	return true -- Default: client-side for testing
end

function mock_pz.isSingleplayer()
	return true -- Default: singleplayer for testing
end

-- ============================================================================
-- REGISTRY STUBS
-- ============================================================================

local Registry = {}
Registry.__index = Registry

function Registry.new()
	return setmetatable({
		_entries = {},
	}, Registry)
end

function Registry:register(id, value)
	self._entries[id] = value
end

function Registry:get(id)
	return self._entries[id]
end

function Registry:unregister(id)
	self._entries[id] = nil
end

function Registry:getAll()
	return self._entries
end

mock_pz.Registry = Registry

-- ============================================================================
-- INITIALIZATION HELPER
-- ============================================================================

-- ============================================================================
-- SIGNAL SYSTEM MOCK (for hump.signal compatibility)
-- ============================================================================

local SignalRegistry = {}
SignalRegistry.__index = SignalRegistry

function SignalRegistry.new()
	return setmetatable({
		_handlers = {},
	}, SignalRegistry)
end

function SignalRegistry:register(event_name, handler)
	if not self._handlers[event_name] then
		self._handlers[event_name] = {}
	end
	self._handlers[event_name][handler] = handler
	return handler
end

function SignalRegistry:emit(event_name, ...)
	if not self._handlers[event_name] then
		return
	end
	for handler in pairs(self._handlers[event_name]) do
		handler(...)
	end
end

function SignalRegistry:unsubscribe(event_name, handler)
	if self._handlers[event_name] then
		self._handlers[event_name][handler] = nil
	end
end

mock_pz.SignalRegistry = SignalRegistry

-- ============================================================================
-- ADMIN/STAFF PERMISSION SYSTEM (Konijima utilities)
-- ============================================================================

-- Admin/Staff status (mockable)
local admin_list = {} -- Set of admin names
local staff_list = {} -- Set of staff names
local client_is_admin = false
local client_is_staff = false

-- Add admin (for testing)
function mock_pz.AddAdmin(username)
	admin_list[username] = true
end

-- Remove admin
function mock_pz.RemoveAdmin(username)
	admin_list[username] = nil
end

-- Add staff
function mock_pz.AddStaff(username)
	staff_list[username] = true
end

-- Remove staff
function mock_pz.RemoveStaff(username)
	staff_list[username] = nil
end

-- Get admin list
function mock_pz.GetAdminList()
	local list = {}
	for name, _ in pairs(admin_list) do
		table.insert(list, name)
	end
	return list
end

-- Get staff list
function mock_pz.GetStaffList()
	local list = {}
	for name, _ in pairs(staff_list) do
		table.insert(list, name)
	end
	return list
end

-- Check if specific user is admin
function mock_pz.IsUserAdmin(username)
	return admin_list[username] or false
end

-- Check if specific user is staff
function mock_pz.IsUserStaff(username)
	return staff_list[username] or false
end

-- Set client admin status (for testing)
function mock_pz.SetClientAdmin(is_admin)
	client_is_admin = is_admin or false
end

-- Set client staff status (for testing)
function mock_pz.SetClientStaff(is_staff)
	client_is_staff = is_staff or false
end

-- Get client admin status
function mock_pz.GetClientAdmin()
	return client_is_admin
end

-- Get client staff status
function mock_pz.GetClientStaff()
	return client_is_staff
end

-- ============================================================================
-- SANDBOX VARIABLES MOCK
-- ============================================================================

-- SandboxVars mock for testing mod configurations
local SandboxVars = {}

-- Add some default vanilla sandbox variables for testing
SandboxVars.HoursForLootRespawn = 72
SandboxVars.DayLength = 1
SandboxVars.StartYear = 1993
SandboxVars.StartMonth = 7
SandboxVars.StartDay = 9

-- Initialize mod-specific namespace
function SandboxVars:InitModNamespace(namespace)
	if not self[namespace] then
		self[namespace] = {}
	end
	return self[namespace]
end

-- Get or create a mod namespace
function SandboxVars:GetModNamespace(namespace)
	if not self[namespace] then
		self[namespace] = {}
	end
	return self[namespace]
end

-- Set a value in a mod namespace
function SandboxVars:SetModValue(namespace, key, value)
	if not self[namespace] then
		self[namespace] = {}
	end
	self[namespace][key] = value
end

-- Get a value from a mod namespace
function SandboxVars:GetModValue(namespace, key, defaultValue)
	if not self[namespace] then
		return defaultValue
	end
	return self[namespace][key] or defaultValue
end

mock_pz.SandboxVars = SandboxVars

-- ============================================================================
-- KONIJIMA UTILITIES MOCKS
-- ============================================================================

-- Konijima namespace
mock_pz.konijima = {}

-- Client environment checks
function mock_pz.konijima.IsSinglePlayer()
	return true -- Default: single player for testing
end

function mock_pz.konijima.IsSinglePlayerDebug()
	return false
end

function mock_pz.konijima.IsClientOnly()
	return not mock_pz.isServer()
end

function mock_pz.konijima.IsClientOrSinglePlayer()
	return mock_pz.konijima.IsClientOnly() or mock_pz.konijima.IsSinglePlayer()
end

function mock_pz.konijima.IsServerOrSinglePlayer()
	return mock_pz.isServer() or mock_pz.konijima.IsSinglePlayer()
end

-- Admin/Staff checks
function mock_pz.konijima.IsClientAdmin()
	return client_is_admin
end

function mock_pz.konijima.IsClientStaff()
	return client_is_staff
end

-- String utilities
function mock_pz.konijima.SplitString(str, delimiter)
	if not str or str == "" then
		return {}
	end

	local result = {}
	local pattern = "([^" .. delimiter .. "]*)"
	for match in string.gmatch(str .. delimiter, pattern .. delimiter) do
		table.insert(result, match)
	end
	return result
end

-- Square utilities
function mock_pz.konijima.SquareToString(square)
	if not square then
		return nil
	end
	return square.x .. "|" .. square.y .. "|" .. square.z
end

function mock_pz.konijima.StringToSquare(str)
	if not str then
		return nil
	end
	local parts = mock_pz.konijima.SplitString(str, "|")
	if #parts >= 3 then
		return {
			x = tonumber(parts[1]),
			y = tonumber(parts[2]),
			z = tonumber(parts[3]),
		}
	end
	return nil
end

-- Network commands (no-ops for testing)
function mock_pz.konijima.SendClientCommand(module, command, args)
	-- Mock: just succeed
	return true
end

function mock_pz.konijima.SendServerCommandTo(player, module, command, args)
	-- Mock: just succeed
	return true
end

function mock_pz.konijima.SendServerCommandToAll(module, command, args)
	-- Mock: just succeed
	return true
end

function mock_pz.konijima.SendServerCommandToAllInRange(x, y, z, minx, maxx, module, command, args)
	-- Mock: just succeed
	return true
end

-- Player utilities
function mock_pz.konijima.GetPlayerFromUsername(username)
	-- Mock: return nil (no player in test environment)
	return nil
end

function mock_pz.konijima.IsPlayerInRange(player, x, y, startX, endX, distance)
	-- Mock: return false if no player
	if not player then
		return false
	end
	return true -- Assume in range if player exists
end

-- Electricity utilities
function mock_pz.konijima.SquareHasElectricity(square)
	-- Mock: return false by default
	return false
end

-- Server information
function mock_pz.konijima.GetServerName()
	return "Test Server"
end

-- Inventory utilities
function mock_pz.konijima.FindAllItemInInventoryByTag(inventory, tag)
	-- Mock: return empty list
	return {}
end

-- Moveable object utilities
function mock_pz.konijima.GetMoveableDisplayName(moveable)
	-- Mock: return nil for invalid input
	if not moveable then
		return nil
	end
	return moveable.displayName or "Object"
end

function mock_pz.setupGlobalEnvironment()
	-- Make common functions global for testing
	_G.print = print
	_G.ArrayList = ArrayList
	_G.HashMap = HashMap
	_G.Vector2f = Vector2f
	_G.Vector3f = Vector3f
	_G.GameState = GameState
	_G.Item = Item
	_G.Character = Character
	_G.Coroutine = Coroutine
	_G.Registry = Registry
	_G.GetTickCount = mock_pz.GetTickCount
	_G.GetCurrentTimeMs = mock_pz.GetCurrentTimeMs
	_G.isServer = mock_pz.isServer
	_G.isClient = mock_pz.isClient
	_G.isSingleplayer = mock_pz.isSingleplayer
	_G.SandboxVars = mock_pz.SandboxVars

	-- Kahlua/PZ globals
	_G.serialize = function(t)
		-- Basic mock: return a JSON-like string if jsonlua is available, else just a placeholder
		local ok, json = pcall(require, "pz_lua_commons/rxi/jsonlua_0_1_2/json")
		if ok and json then
			return json.encode(t)
		end
		return "{serialize_mock}"
	end

	_G.deserialize = function(s)
		if s == "{serialize_mock}" then
			return {}
		end
		local ok, json = pcall(require, "pz_lua_commons/rxi/jsonlua_0_1_2/json")
		if ok and json then
			return json.decode(s)
		end
		return {}
	end

	_G.pp = function(t)
		return tostring(t)
	end

	_G.ZombRand = function(max)
		return math.random(0, max - 1)
	end

	_G.ZombRandFloat = function(min, max)
		return min + math.random() * (max - min)
	end

	_G.getPlayer = function()
		return Character.new("Hero")
	end

	_G.instanceof = function(obj, className)
		if not obj then
			return false
		end
		-- Basic mock: if it looks like an IsoPlayer, say it is
		if className == "IsoPlayer" then
			return true
		end
		return false
	end

	_G.isDebugEnabled = function()
		return false
	end

	_G.sendClientCommand = function() end
	_G.sendServerCommand = function() end
	_G.triggerEvent = function() end

	_G.IsoUtils = {
		DistanceTo = function(x1, y1, z1, x2, y2, z2)
			local dx = x1 - x2
			local dy = y1 - y2
			local dz = z1 - z2
			return math.sqrt(dx * dx + dy * dy + dz * dz)
		end,
	}

	_G.GameTime = {
		getInstance = function()
			return {
				getNightsSurvived = function()
					return 0
				end,
			}
		end,
	}

	_G.getWorld = function()
		return {
			getWorld = function()
				return "test_world"
			end,
		}
	end

	_G.getSaveInfo = function(world)
		return {
			gameMode = "SinglePlayer",
			saveName = world,
		}
	end
end

return mock_pz
