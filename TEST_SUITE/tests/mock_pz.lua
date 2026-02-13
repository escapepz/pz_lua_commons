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
	}, Character)
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
    return false  -- Default: client-side for testing
end

function mock_pz.isClient()
    return true   -- Default: client-side for testing
end

function mock_pz.isSingleplayer()
    return true   -- Default: singleplayer for testing
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
        _handlers = {}
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
    if not self._handlers[event_name] then return end
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
end

return mock_pz
