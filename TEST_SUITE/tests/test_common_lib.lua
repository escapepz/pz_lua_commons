-- Test Suite: pz_lua_commons Integration Tests
-- Validates that pz_lua_commons integrates correctly with Project Zomboid stub definitions
-- Run with: lua test_common_lib.lua

---@type table
ArrayList = nil
---@type table
HashMap = nil
---@type table
Vector2f = nil
---@type table
Vector3f = nil
---@type table
GameState = nil
---@type table
Item = nil
---@type table
Character = nil
---@type table
Coroutine = nil
---@type table
Registry = nil

---@type function
isServer = nil
---@type function
isClient = nil
---@type function
isSingleplayer = nil

local mock_pz = require("TEST_SUITE/tests/mock_pz")
mock_pz.setupGlobalEnvironment()

-- Adjust package.path to load commons from project structure
-- From TEST_SUITE/tests, go up 2 levels to project root, then into pz_lua_commons
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?.lua"
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?/init.lua"
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/client/?.lua"
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/client/?/init.lua"

local pz_commons = require("pz_lua_commons/shared")
local pz_utils = require("pz_utils/shared")
local pz_commons_client = nil

-- Try to load client modules (requires isServer/isClient globals)
local ok, result = pcall(function()
	return require("pz_lua_commons/client")
end)
if ok then
	pz_commons_client = result
end

-- ============================================================================
-- TEST FRAMEWORK
-- ============================================================================

local TestRunner = {}
TestRunner.tests = {}
TestRunner.passed = 0
TestRunner.failed = 0
TestRunner.errors = {}

function TestRunner.register(name, fn)
	table.insert(TestRunner.tests, { name = name, fn = fn })
end

function TestRunner.assert_equals(actual, expected, message)
	if actual == expected then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		local err = string.format(
			"FAIL: %s\n  Expected: %s\n  Got: %s",
			message or "assertion",
			tostring(expected),
			tostring(actual)
		)
		table.insert(TestRunner.errors, err)
		return false
	end
end

function TestRunner.assert_true(value, message)
	return TestRunner.assert_equals(value, true, message or "expected true")
end

function TestRunner.assert_false(value, message)
	return TestRunner.assert_equals(value, false, message or "expected false")
end

function TestRunner.assert_not_nil(value, message)
	if value ~= nil then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		table.insert(TestRunner.errors, "FAIL: " .. (message or "assertion") .. " - expected non-nil")
		return false
	end
end

function TestRunner.assert_is_type(value, expectedType, message)
	local actualType = type(value)
	return TestRunner.assert_equals(
		actualType,
		expectedType,
		message or string.format("expected type %s, got %s", expectedType, actualType)
	)
end

function TestRunner.run()
	print("\n" .. string.rep("=", 70))
	print("PZ_LUA_COMMONS INTEGRATION TEST SUITE")
	print(string.rep("=", 70) .. "\n")

	for _, test in ipairs(TestRunner.tests) do
		io.write(string.format("%-50s ", test.name))
		local success, err = pcall(test.fn)
		if success then
			print("OK")
		else
			print("ERROR")
			TestRunner.failed = TestRunner.failed + 1
			table.insert(TestRunner.errors, "ERROR in " .. test.name .. ": " .. tostring(err))
		end
	end

	print("\n" .. string.rep("=", 70))
	print("TEST RESULTS")
	print(string.rep("=", 70))
	print(string.format("Passed: %d", TestRunner.passed))
	print(string.format("Failed: %d", TestRunner.failed))
	print(string.format("Total:  %d", TestRunner.passed + TestRunner.failed))

	if #TestRunner.errors > 0 then
		print("\n" .. string.rep("-", 70))
		print("FAILURES:")
		print(string.rep("-", 70))
		for _, err in ipairs(TestRunner.errors) do
			print(err)
		end
	end

	print("\n" .. string.rep("=", 70))
	if TestRunner.failed == 0 then
		print("OK - ALL TESTS PASSED")
	else
		print("UHOH - SOME TESTS FAILED")
	end
	print(string.rep("=", 70) .. "\n")

	return TestRunner.failed == 0
end

-- ============================================================================
-- MODULE LOADING TESTS
-- ============================================================================

TestRunner.register("Module loading: pz_lua_commons exists", function()
	TestRunner.assert_not_nil(pz_commons, "pz_commons should be loaded")
end)

TestRunner.register("Module loading: pz_utils exists", function()
	TestRunner.assert_not_nil(pz_utils, "pz_utils should be loaded")
end)

TestRunner.register("Module loading: lunajson available", function()
	TestRunner.assert_not_nil(pz_commons.grafi_tt.lunajson, "lunajson should be available")
end)

TestRunner.register("Module loading: middleclass available", function()
	TestRunner.assert_not_nil(pz_commons.kikito.middleclass, "middleclass should be available")
end)

TestRunner.register("Module loading: hump.signal available", function()
	TestRunner.assert_not_nil(pz_commons.vrld.hump.signal, "hump.signal should be available")
end)

TestRunner.register("Module loading: client module loads with isClient", function()
	TestRunner.assert_not_nil(pz_commons_client, "pz_commons_client should be loaded (uses isServer check)")
end)

TestRunner.register("Module loading: isServer/isClient globals work", function()
	TestRunner.assert_is_type(isServer(), "boolean", "isServer should return boolean")
	TestRunner.assert_is_type(isClient(), "boolean", "isClient should return boolean")
	TestRunner.assert_false(isServer(), "test environment should be client-side")
	TestRunner.assert_true(isClient(), "test environment should be client-side")
end)

-- ============================================================================
-- LUNAJSON TESTS (JSON serialization)
-- ============================================================================

TestRunner.register("lunajson: encode basic table", function()
	local lunajson = pz_commons.grafi_tt.lunajson
	local data = { name = "test", value = 42 }
	local encoded = lunajson.encode(data)
	TestRunner.assert_is_type(encoded, "string", "encoded should be string")
end)

TestRunner.register("lunajson: decode JSON string", function()
	local lunajson = pz_commons.grafi_tt.lunajson
	local json = '{"name":"Alice","health":75}'
	local decoded = lunajson.decode(json)
	TestRunner.assert_equals(decoded.name, "Alice", "decoded name should match")
	TestRunner.assert_equals(decoded.health, 75, "decoded health should match")
end)

TestRunner.register("lunajson: round-trip encode/decode", function()
	local lunajson = pz_commons.grafi_tt.lunajson
	local original = { items = { "axe", "gun" }, count = 2, alive = true }
	local encoded = lunajson.encode(original)
	local decoded = lunajson.decode(encoded)
	TestRunner.assert_equals(decoded.count, original.count, "count should match")
	TestRunner.assert_equals(#decoded.items, #original.items, "items length should match")
end)

-- ============================================================================
-- MIDDLECLASS TESTS (OOP)
-- ============================================================================

TestRunner.register("middleclass: create basic class", function()
	local middleclass = pz_commons.kikito.middleclass
	local Animal = middleclass("Animal")
	TestRunner.assert_not_nil(Animal, "class should be created")
end)

TestRunner.register("middleclass: instantiate class", function()
	local middleclass = pz_commons.kikito.middleclass
	local Dog = middleclass("Dog")
	function Dog:initialize(name)
		self.name = name
	end
	local dog = Dog("Buddy")
	TestRunner.assert_equals(dog.name, "Buddy", "instance property should be set")
end)

TestRunner.register("middleclass: call instance method", function()
	local middleclass = pz_commons.kikito.middleclass
	local Player = middleclass("Player")
	function Player:initialize(name, hp)
		self.name = name
		self.hp = hp
	end
	function Player:takeDamage(amount)
		self.hp = self.hp - amount
		return self.hp
	end
	local p = Player("Bob", 100)
	local remaining = p:takeDamage(20)
	TestRunner.assert_equals(remaining, 80, "damage calculation should be correct")
end)

TestRunner.register("middleclass: class inheritance", function()
	local middleclass = pz_commons.kikito.middleclass
	local Character = middleclass("Character")
	function Character:initialize(name)
		self.name = name
	end
	local Zombie = middleclass("Zombie", Character)
	function Zombie:initialize(name, threat)
		Character.initialize(self, name)
		self.threat = threat
	end
	local z = Zombie("Walker", 5)
	TestRunner.assert_equals(z.name, "Walker", "inherited property should work")
	TestRunner.assert_equals(z.threat, 5, "subclass property should work")
end)

-- ============================================================================
-- HUMP.SIGNAL TESTS (Event system)
-- ============================================================================
-- Uses real hump.signal library - no mocks needed

TestRunner.register("hump.signal: register event", function()
	-- Use real hump.signal with correct API
	local signal = pz_commons.vrld.hump.signal
	local handler = function() end
	signal.register("test_real_event", handler)
	TestRunner.passed = TestRunner.passed + 1
end)

TestRunner.register("hump.signal: subscribe to event", function()
	local signal = pz_commons.vrld.hump.signal
	local called = false
	local handler = function()
		called = true
	end
	signal.register("test_sub", handler)
	signal.emit("test_sub")
	TestRunner.assert_true(called, "event callback should be called")
end)

TestRunner.register("hump.signal: event with arguments", function()
	local signal = pz_commons.vrld.hump.signal
	local receivedValue = nil
	local handler = function(value)
		receivedValue = value
	end
	signal.register("test_args", handler)
	signal.emit("test_args", 42)
	TestRunner.assert_equals(receivedValue, 42, "event argument should be passed")
end)

TestRunner.register("hump.signal: multiple subscribers", function()
	local signal = pz_commons.vrld.hump.signal
	local count = 0
	signal.register("test_multi", function()
		count = count + 1
	end)
	signal.register("test_multi", function()
		count = count + 1
	end)
	signal.register("test_multi", function()
		count = count + 1
	end)
	signal.emit("test_multi")
	TestRunner.assert_equals(count, 3, "all subscribers should be called")
end)

-- ============================================================================
-- PZ_UTILS ESCAPE TESTS
-- ============================================================================

TestRunner.register("pz_utils: escape module loaded", function()
	local escape = pz_utils[1] or pz_utils.escape
	TestRunner.assert_not_nil(escape, "escape module should be loaded")
end)

TestRunner.register("pz_utils: SafeLogger available", function()
	local escape = pz_utils[1] or pz_utils.escape
	TestRunner.assert_not_nil(escape.SafeLogger, "SafeLogger should be available")
end)

TestRunner.register("pz_utils: escape.SafeLogger.new callable", function()
	local escape = pz_utils[1] or pz_utils.escape
	local logger = escape.SafeLogger.new("TestModule")
	TestRunner.passed = TestRunner.passed + 1
end)

TestRunner.register("pz_utils: SafeLogger:log with numeric level", function()
	local escape = pz_utils[1] or pz_utils.escape
	local logger = escape.SafeLogger.new("TestModule")
	logger:log("Test message", 30)
	TestRunner.passed = TestRunner.passed + 1
end)

TestRunner.register("pz_utils: Debounce.IsActive", function()
	local escape = pz_utils[1] or pz_utils.escape
	escape.Debounce.Cancel("test_active")
	local inactive = escape.Debounce.IsActive("test_active")
	TestRunner.assert_false(inactive, "debounce should be inactive initially")
end)

TestRunner.register("pz_utils: Debounce.Call creates active debounce", function()
	local escape = pz_utils[1] or pz_utils.escape
	local called = false
	escape.Debounce.Call("test_call", 999, function()
		called = true
	end)
	TestRunner.assert_true(escape.Debounce.IsActive("test_call"), "debounce should be active after Call")
end)

TestRunner.register("pz_utils: Debounce.Cancel", function()
	local escape = pz_utils[1] or pz_utils.escape
	escape.Debounce.Call("test_cancel", 5, function() end)
	local cancelled = escape.Debounce.Cancel("test_cancel")
	TestRunner.assert_true(cancelled, "cancel should return true")
	TestRunner.assert_false(escape.Debounce.IsActive("test_cancel"), "debounce should be inactive after cancel")
end)

TestRunner.register("pz_utils: EventManager.createEvent", function()
	local escape = pz_utils[1] or pz_utils.escape
	local event = escape.EventManager.createEvent("test_event_" .. os.time())
	TestRunner.assert_not_nil(event, "event should be created")
end)

TestRunner.register("pz_utils: EventManager.createEvent returns same event", function()
	local escape = pz_utils[1] or pz_utils.escape
	local eventName = "persist_test_" .. os.time()
	local event1 = escape.EventManager.createEvent(eventName)
	local event2 = escape.EventManager.createEvent(eventName)
	TestRunner.assert_equals(event1, event2, "should return same event instance")
end)

TestRunner.register("pz_utils: Event Add listener", function()
	local escape = pz_utils[1] or pz_utils.escape
	local event = escape.EventManager.createEvent("add_test_" .. os.time())
	local callback = function() end
	event:Add(callback)
	TestRunner.assert_equals(event:GetListenerCount(), 1, "should have 1 listener")
end)

TestRunner.register("pz_utils: Event Trigger calls listeners", function()
	local escape = pz_utils[1] or pz_utils.escape
	local event = escape.EventManager.createEvent("trigger_test_" .. os.time())
	local count = 0
	event:Add(function()
		count = count + 1
	end)
	event:Add(function()
		count = count + 1
	end)
	event:Trigger()
	TestRunner.assert_equals(count, 2, "trigger should call all listeners")
end)

TestRunner.register("pz_utils: Event.Remove listener", function()
	local escape = pz_utils[1] or pz_utils.escape
	local event = escape.EventManager.createEvent("remove_test_" .. os.time())
	local callback = function() end
	event:Add(callback)
	event:Add(function() end)
	event:Remove(callback)
	TestRunner.assert_equals(event:GetListenerCount(), 1, "should have 1 listener after remove")
end)

TestRunner.register("pz_utils: Event SetEnabled", function()
	local escape = pz_utils[1] or pz_utils.escape
	local event = escape.EventManager.createEvent("enable_test_" .. os.time())
	event:SetEnabled(true)
	TestRunner.assert_true(event:IsEnabled(), "event should be enabled")
	event:SetEnabled(false)
	TestRunner.assert_false(event:IsEnabled(), "event should be disabled")
end)

TestRunner.register("pz_utils: Utilities.GetIRLTimestamp", function()
	local escape = pz_utils[1] or pz_utils.escape
	local t = escape.Utilities.GetIRLTimestamp()
	TestRunner.assert_is_type(t, "number", "timestamp should be number")
	TestRunner.assert_true(t > 0, "timestamp should be positive")
end)

-- ============================================================================
-- INTEGRATION TESTS
-- ============================================================================

TestRunner.register("Integration: JSON + OOP workflow", function()
	local lunajson = pz_commons.grafi_tt.lunajson
	local middleclass = pz_commons.kikito.middleclass

	local Item = middleclass("Item")
	function Item:initialize(name, weight)
		self.name = name
		self.weight = weight
	end

	local item = Item("water bottle", 1.5)
	local json = lunajson.encode({ name = item.name, weight = item.weight })
	local decoded = lunajson.decode(json)

	TestRunner.assert_equals(decoded.name, "water bottle", "name should match")
	TestRunner.assert_equals(decoded.weight, 1.5, "weight should match")
end)

TestRunner.register("Integration: Events + Logging", function()
	local signal = pz_commons.vrld.hump.signal
	local escape = pz_utils[1] or pz_utils.escape

	local logged = false
	local logger = escape.SafeLogger.new("TestModule")
	signal.register("test_log_event", function(msg)
		logger:log(msg, 30)
		logged = true
	end)

	signal.emit("test_log_event", "integration test message")
	TestRunner.assert_true(logged, "event should have been logged")
end)

TestRunner.register("Integration: Debounce with OOP", function()
	local middleclass = pz_commons.kikito.middleclass
	local escape = pz_utils[1] or pz_utils.escape

	local Searcher = middleclass("Searcher")
	function Searcher:initialize()
		self.lastQuery = nil
	end
	function Searcher:search(query)
		self.lastQuery = query
	end

	local searcher = Searcher()
	local cb = function(q)
		searcher:search(q)
	end

	escape.Debounce.Call("search_debounce", 999, cb, "zombie")
	TestRunner.assert_true(escape.Debounce.IsActive("search_debounce"), "debounce should be active")
end)

TestRunner.register("Integration: Mock PZ ArrayList with commons", function()
	local middleclass = pz_commons.kikito.middleclass

	local Inventory = middleclass("Inventory")
	function Inventory:initialize()
		self.items = ArrayList.new()
	end
	function Inventory:addItem(item)
		self.items:add(item)
	end
	function Inventory:getCount()
		return self.items:size()
	end

	local inv = Inventory()
	inv:addItem("axe")
	inv:addItem("gun")

	TestRunner.assert_equals(inv:getCount(), 2, "inventory should have 2 items")
end)

TestRunner.register("Integration: Mock PZ Character with commons", function()
	local middleclass = pz_commons.kikito.middleclass

	local GameCharacter = middleclass("GameCharacter")
	function GameCharacter:initialize(name)
		self.name = name
		self.pzCharacter = Character.new(name, 100, 200)
	end
	function GameCharacter:takeDamage(amount)
		self.pzCharacter:takeDamage(amount)
		return self.pzCharacter:isAlive()
	end

	local gc = GameCharacter("Alice")
	local alive = gc:takeDamage(30)
	TestRunner.assert_true(alive, "character should still be alive")
	TestRunner.assert_equals(gc.pzCharacter:getHealth(), 70, "health should be 70")
end)

-- ============================================================================
-- STUB COMPATIBILITY TESTS
-- ============================================================================

TestRunner.register("Stub: ArrayList functional", function()
	local list = ArrayList.new()
	list:add("item1")
	list:add("item2")
	TestRunner.assert_equals(list:size(), 2, "ArrayList size should be 2")
	TestRunner.assert_equals(list:get(1), "item1", "ArrayList get should work")
end)

TestRunner.register("Stub: Vector2f distance calculation", function()
	local v1 = Vector2f.new(0, 0)
	local v2 = Vector2f.new(3, 4)
	local dist = v1:distance(v2)
	TestRunner.assert_equals(dist, 5, "distance should be 5")
end)

TestRunner.register("Stub: Character health management", function()
	local char = Character.new("Bob", 100, 100)
	char:takeDamage(25)
	TestRunner.assert_equals(char:getHealth(), 75, "health after damage should be 75")
	TestRunner.assert_true(char:isAlive(), "character should still be alive")
end)

TestRunner.register("Stub: Item with inventory", function()
	local item1 = Item.new("axe", 5, 50)
	local item2 = Item.new("gun", 3, 100)
	TestRunner.assert_equals(item1:getName(), "axe", "item name should be axe")
	TestRunner.assert_equals(item2:getWeight(), 3, "item weight should be 3")
end)

TestRunner.register("Stub: Registry functionality", function()
	local reg = Registry.new()
	reg:register("key1", "value1")
	TestRunner.assert_equals(reg:get("key1"), "value1", "registry get should work")
end)

-- ============================================================================
-- RUN ALL TESTS
-- ============================================================================

local success = TestRunner.run()
os.exit(success and 0 or 1)
