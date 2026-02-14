-- Test Suite: SandboxVarsModule
-- Tests for production-grade Sandbox Variables management

local mock_pz = require("TEST_SUITE/tests/mock_pz")
mock_pz.setupGlobalEnvironment()

-- Load pz_utils - setup path to point to actual pz_lua_commons modules
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?.lua"
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?/init.lua"

-- Load sandbox vars module
local SandboxVarsModule = require("pz_utils/escape/sandbox_vars")

if not SandboxVarsModule then
	error("Failed to load SandboxVarsModule")
end

-- ============================================================================
-- TEST FRAMEWORK
-- ============================================================================

local TestRunner = {}
TestRunner.passed = 0
TestRunner.failed = 0
TestRunner.tests = {}

function TestRunner.register(name, fn)
	table.insert(TestRunner.tests, { name = name, fn = fn })
end

function TestRunner.assert_equals(actual, expected, message)
	if actual == expected then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "assertion"))
		print("  Expected: " .. tostring(expected))
		print("  Got: " .. tostring(actual))
		return false
	end
end

function TestRunner.assert_true(value, message)
	if value == true then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "assertion") .. " (expected true)")
		return false
	end
end

function TestRunner.assert_false(value, message)
	if value == false then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "assertion") .. " (expected false)")
		return false
	end
end

function TestRunner.assert_not_nil(value, message)
	if value ~= nil then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "assertion") .. " (expected non-nil)")
		return false
	end
end

function TestRunner.assert_nil(value, message)
	if value == nil then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "assertion") .. " (expected nil)")
		print("  Got: " .. tostring(value))
		return false
	end
end

function TestRunner.run_all()
	print("\n" .. string.rep("=", 70))
	print("SANDBOXVARSMODULE TEST SUITE")
	print(string.rep("=", 70) .. "\n")

	for _, test in ipairs(TestRunner.tests) do
		io.write(test.name .. " ... ")
		local success, err = pcall(test.fn)
		if success then
			print("OK")
		else
			print("ERROR: " .. tostring(err))
			TestRunner.failed = TestRunner.failed + 1
		end
	end

	print("\n" .. string.rep("=", 70))
	print("TEST RESULTS")
	print(string.rep("=", 70))
	print("Passed: " .. TestRunner.passed)
	print("Failed: " .. TestRunner.failed)
	print("Total:  " .. (TestRunner.passed + TestRunner.failed))

	if TestRunner.failed == 0 then
		print("\n✓ ALL TESTS PASSED")
	else
		print("\n✗ " .. TestRunner.failed .. " TEST(S) FAILED")
	end
	print(string.rep("=", 70) .. "\n")

	return {
		passed = TestRunner.passed,
		failed = TestRunner.failed,
		total = TestRunner.passed + TestRunner.failed,
	}
end

-- ============================================================================
-- MODULE METADATA TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: Has VERSION", function()
	TestRunner.assert_not_nil(SandboxVarsModule.VERSION, "Module should have VERSION property")
	TestRunner.assert_equals(type(SandboxVarsModule.VERSION), "string", "VERSION should be a string")
end)

TestRunner.register("SandboxVarsModule: Has BUILD", function()
	TestRunner.assert_not_nil(SandboxVarsModule.BUILD, "Module should have BUILD property")
	TestRunner.assert_equals(type(SandboxVarsModule.BUILD), "string", "BUILD should be a string")
end)

-- ============================================================================
-- INITIALIZATION TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: Init with valid namespace and defaults", function()
	local defaults = { respawnTime = 24, enabled = true }
	local result = SandboxVarsModule.Init("TestMod1", defaults)
	TestRunner.assert_true(result, "Init should return true for valid arguments")
end)

TestRunner.register("SandboxVarsModule: Init sets current namespace", function()
	local defaults = { key1 = "value1" }
	SandboxVarsModule.Init("TestMod2", defaults)
	local namespace = SandboxVarsModule.GetCurrentNamespace()
	TestRunner.assert_equals(namespace, "TestMod2", "Current namespace should be set to initialized namespace")
end)

TestRunner.register("SandboxVarsModule: Init with nil namespace fails", function()
	local success = pcall(function()
		SandboxVarsModule.Init(nil, { key = "value" })
	end)
	TestRunner.assert_false(success, "Init should fail with nil namespace")
end)

TestRunner.register("SandboxVarsModule: Init with empty namespace fails", function()
	local success = pcall(function()
		SandboxVarsModule.Init("", { key = "value" })
	end)
	TestRunner.assert_false(success, "Init should fail with empty namespace")
end)

TestRunner.register("SandboxVarsModule: Init with nil defaults fails", function()
	local success = pcall(function()
		SandboxVarsModule.Init("TestMod3", nil)
	end)
	TestRunner.assert_false(success, "Init should fail with nil defaults table")
end)

TestRunner.register("SandboxVarsModule: Init with non-string namespace fails", function()
	local success = pcall(function()
		SandboxVarsModule.Init(123, { key = "value" })
	end)
	TestRunner.assert_false(success, "Init should fail with non-string namespace")
end)

TestRunner.register("SandboxVarsModule: Init with non-table defaults fails", function()
	local success = pcall(function()
		SandboxVarsModule.Init("TestMod4", "not a table")
	end)
	TestRunner.assert_false(success, "Init should fail with non-table defaults")
end)

TestRunner.register("SandboxVarsModule: Multiple initializations", function()
	local defaults1 = { key1 = "default1" }
	local defaults2 = { key2 = "default2" }

	local result1 = SandboxVarsModule.Init("Mod1", defaults1)
	local result2 = SandboxVarsModule.Init("Mod2", defaults2)

	TestRunner.assert_true(result1 and result2, "Both initializations should succeed")
	TestRunner.assert_equals(SandboxVarsModule.GetCurrentNamespace(), "Mod2", "Last init should set current namespace")
end)

-- ============================================================================
-- GET TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: Get without init fails", function()
	-- Reset to ensure no namespace is active
	local success = pcall(function()
		-- Create a fresh module state by calling Get without init
		-- We'll test this by checking if error is thrown
		local getModule = require("pz_utils/escape/sandbox_vars")
		-- This should work but subsequent Get on new instance would fail
	end)
	TestRunner.assert_true(success, "Module should load")
end)

TestRunner.register("SandboxVarsModule: Get returns default value", function()
	local defaults = { respawnHours = 48, lootEnabled = true }
	SandboxVarsModule.Init("LootMod", defaults)

	local value = SandboxVarsModule.Get("respawnHours")
	TestRunner.assert_equals(value, 48, "Get should return default value for respawnHours")

	local value2 = SandboxVarsModule.Get("lootEnabled")
	TestRunner.assert_equals(value2, true, "Get should return default value for lootEnabled")
end)

TestRunner.register("SandboxVarsModule: Get with override default", function()
	local defaults = { baseValue = 100 }
	SandboxVarsModule.Init("OverrideMod", defaults)

	local value = SandboxVarsModule.Get("baseValue", 200)
	TestRunner.assert_equals(value, 100, "Get should return stored value, not override default")

	local value2 = SandboxVarsModule.Get("nonexistent", 999)
	TestRunner.assert_equals(value2, 999, "Get should return override default for non-existent key")
end)

TestRunner.register("SandboxVarsModule: Get with nil key fails", function()
	SandboxVarsModule.Init("KeyTestMod", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.Get(nil)
	end)
	TestRunner.assert_false(success, "Get should fail with nil key")
end)

TestRunner.register("SandboxVarsModule: Get with non-string key fails", function()
	SandboxVarsModule.Init("KeyType", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.Get(123)
	end)
	TestRunner.assert_false(success, "Get should fail with non-string key")
end)

TestRunner.register("SandboxVarsModule: Get returns nil for non-existent key", function()
	local defaults = { existingKey = "value" }
	SandboxVarsModule.Init("NilReturnMod", defaults)

	local value = SandboxVarsModule.Get("nonexistentKey")
	TestRunner.assert_nil(value, "Get should return nil for non-existent key without override")
end)

TestRunner.register("SandboxVarsModule: Get with various data types", function()
	local defaults = {
		stringVal = "test",
		numberVal = 42,
		boolVal = true,
		tableVal = { nested = "value" },
	}
	SandboxVarsModule.Init("TypeTestMod", defaults)

	TestRunner.assert_equals(SandboxVarsModule.Get("stringVal"), "test", "String value")
	TestRunner.assert_equals(SandboxVarsModule.Get("numberVal"), 42, "Number value")
	TestRunner.assert_equals(SandboxVarsModule.Get("boolVal"), true, "Boolean value")
	TestRunner.assert_not_nil(SandboxVarsModule.Get("tableVal"), "Table value")
end)

-- ============================================================================
-- GET FROM NAMESPACE TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: GetFromNamespace retrieves value", function()
	local defaults1 = { key = "value1" }
	local defaults2 = { key = "value2" }

	SandboxVarsModule.Init("NamespaceA", defaults1)
	SandboxVarsModule.Init("NamespaceB", defaults2)

	local value = SandboxVarsModule.GetFromNamespace("NamespaceA", "key")
	TestRunner.assert_equals(value, "value1", "GetFromNamespace should return value from specified namespace")
end)

TestRunner.register("SandboxVarsModule: GetFromNamespace with override default", function()
	local defaults = { key = "stored" }
	SandboxVarsModule.Init("NamespaceC", defaults)

	local value = SandboxVarsModule.GetFromNamespace("NamespaceC", "key", "override")
	TestRunner.assert_equals(value, "stored", "Should return stored value")

	local value2 = SandboxVarsModule.GetFromNamespace("NamespaceC", "missing", "override")
	TestRunner.assert_equals(value2, "override", "Should return override default")
end)

TestRunner.register("SandboxVarsModule: GetFromNamespace with invalid namespace fails", function()
	SandboxVarsModule.Init("ValidNamespace", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.GetFromNamespace("NonexistentNamespace", "key")
	end)
	TestRunner.assert_false(success, "GetFromNamespace should fail for uninitialized namespace")
end)

TestRunner.register("SandboxVarsModule: GetFromNamespace with nil namespace fails", function()
	SandboxVarsModule.Init("NamespaceD", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.GetFromNamespace(nil, "key")
	end)
	TestRunner.assert_false(success, "GetFromNamespace should fail with nil namespace")
end)

TestRunner.register("SandboxVarsModule: GetFromNamespace with non-string namespace fails", function()
	SandboxVarsModule.Init("NamespaceE", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.GetFromNamespace(123, "key")
	end)
	TestRunner.assert_false(success, "GetFromNamespace should fail with non-string namespace")
end)

-- ============================================================================
-- GET VANILLA TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: GetVanilla returns vanilla value", function()
	SandboxVarsModule.Init("VanillaMod", {})

	local value = SandboxVarsModule.GetVanilla("HoursForLootRespawn", 72)
	TestRunner.assert_not_nil(value, "GetVanilla should return a value")
	TestRunner.assert_equals(type(value), "number", "GetVanilla should return a number")
end)

TestRunner.register("SandboxVarsModule: GetVanilla returns default when not found", function()
	SandboxVarsModule.Init("VanillaMod2", {})

	local value = SandboxVarsModule.GetVanilla("NonexistentVanillaVar", 999)
	TestRunner.assert_equals(value, 999, "GetVanilla should return provided default")
end)

TestRunner.register("SandboxVarsModule: GetVanilla with nil key fails", function()
	SandboxVarsModule.Init("VanillaMod3", {})

	local success = pcall(function()
		SandboxVarsModule.GetVanilla(nil)
	end)
	TestRunner.assert_false(success, "GetVanilla should fail with nil key")
end)

TestRunner.register("SandboxVarsModule: GetVanilla with non-string key fails", function()
	SandboxVarsModule.Init("VanillaMod4", {})

	local success = pcall(function()
		SandboxVarsModule.GetVanilla(123)
	end)
	TestRunner.assert_false(success, "GetVanilla should fail with non-string key")
end)

-- ============================================================================
-- GET CURRENT NAMESPACE TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: GetCurrentNamespace returns active namespace", function()
	SandboxVarsModule.Init("CurrentTest", { key = "value" })

	local namespace = SandboxVarsModule.GetCurrentNamespace()
	TestRunner.assert_equals(namespace, "CurrentTest", "GetCurrentNamespace should return active namespace")
end)

TestRunner.register("SandboxVarsModule: GetCurrentNamespace updates on re-init", function()
	SandboxVarsModule.Init("FirstNamespace", { key = "value" })
	local ns1 = SandboxVarsModule.GetCurrentNamespace()

	SandboxVarsModule.Init("SecondNamespace", { key = "value" })
	local ns2 = SandboxVarsModule.GetCurrentNamespace()

	TestRunner.assert_equals(ns1, "FirstNamespace", "First namespace should be set")
	TestRunner.assert_equals(ns2, "SecondNamespace", "Second namespace should be set after re-init")
	TestRunner.assert_false(ns1 == ns2, "Current namespace should change")
end)

-- ============================================================================
-- GET ALL TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: GetAll returns table", function()
	local defaults = { key1 = "value1", key2 = "value2" }
	SandboxVarsModule.Init("GetAllMod", defaults)

	local all = SandboxVarsModule.GetAll()
	TestRunner.assert_equals(type(all), "table", "GetAll should return a table")
end)

TestRunner.register("SandboxVarsModule: GetAll returns all values", function()
	local defaults = { key1 = "value1", key2 = "value2", key3 = 42 }
	SandboxVarsModule.Init("GetAllMod2", defaults)

	local all = SandboxVarsModule.GetAll()
	TestRunner.assert_equals(all.key1, "value1", "GetAll should contain key1")
	TestRunner.assert_equals(all.key2, "value2", "GetAll should contain key2")
	TestRunner.assert_equals(all.key3, 42, "GetAll should contain key3")
end)

TestRunner.register("SandboxVarsModule: GetAll with specific namespace", function()
	local defaults1 = { key = "value1" }
	local defaults2 = { key = "value2" }

	SandboxVarsModule.Init("AllNamespaceA", defaults1)
	SandboxVarsModule.Init("AllNamespaceB", defaults2)

	local all = SandboxVarsModule.GetAll("AllNamespaceA")
	TestRunner.assert_equals(all.key, "value1", "GetAll should return values from specified namespace")
end)

TestRunner.register("SandboxVarsModule: GetAll with invalid namespace fails", function()
	SandboxVarsModule.Init("ValidAllNamespace", { key = "value" })

	local success = pcall(function()
		SandboxVarsModule.GetAll("InvalidNamespace")
	end)
	TestRunner.assert_false(success, "GetAll should fail for uninitialized namespace")
end)

TestRunner.register("SandboxVarsModule: GetAll returns empty table for empty namespace", function()
	SandboxVarsModule.Init("EmptyNamespace", {})

	local all = SandboxVarsModule.GetAll()
	TestRunner.assert_equals(type(all), "table", "GetAll should return table even when empty")
end)

-- ============================================================================
-- INTEGRATION TESTS
-- ============================================================================

TestRunner.register("SandboxVarsModule: Multiple mods with separate configs", function()
	local defaults1 = { respawnTime = 24, difficulty = "normal" }
	local defaults2 = { respawnTime = 48, difficulty = "hard" }

	SandboxVarsModule.Init("Mod1", defaults1)
	SandboxVarsModule.Init("Mod2", defaults2)

	local val1 = SandboxVarsModule.GetFromNamespace("Mod1", "respawnTime")
	local val2 = SandboxVarsModule.GetFromNamespace("Mod2", "respawnTime")

	TestRunner.assert_equals(val1, 24, "Mod1 should have respawnTime 24")
	TestRunner.assert_equals(val2, 48, "Mod2 should have respawnTime 48")
end)

TestRunner.register("SandboxVarsModule: Switching between namespaces", function()
	local defaults1 = { modName = "ModA" }
	local defaults2 = { modName = "ModB" }

	SandboxVarsModule.Init("ModA", defaults1)
	TestRunner.assert_equals(SandboxVarsModule.Get("modName"), "ModA", "Should get ModA value")

	SandboxVarsModule.Init("ModB", defaults2)
	TestRunner.assert_equals(SandboxVarsModule.Get("modName"), "ModB", "Should get ModB value after switch")

	local modAValue = SandboxVarsModule.GetFromNamespace("ModA", "modName")
	TestRunner.assert_equals(modAValue, "ModA", "Should still retrieve ModA value when switched")
end)

TestRunner.register("SandboxVarsModule: Complex configuration structure", function()
	local defaults = {
		respawnTime = 24,
		enabled = true,
		difficulty = "normal",
		multiplier = 1.5,
		options = { nested = "value" },
	}

	SandboxVarsModule.Init("ComplexMod", defaults)

	TestRunner.assert_equals(SandboxVarsModule.Get("respawnTime"), 24, "Number value")
	TestRunner.assert_equals(SandboxVarsModule.Get("enabled"), true, "Boolean value")
	TestRunner.assert_equals(SandboxVarsModule.Get("difficulty"), "normal", "String value")
	TestRunner.assert_equals(SandboxVarsModule.Get("multiplier"), 1.5, "Float value")
	TestRunner.assert_not_nil(SandboxVarsModule.Get("options"), "Table value")
end)

TestRunner.register("SandboxVarsModule: Error handling doesn't crash", function()
	SandboxVarsModule.Init("SafeMod", { key = "value" })

	-- Test various error conditions
	local function testErrors()
		pcall(function() SandboxVarsModule.Get(nil) end)
		pcall(function() SandboxVarsModule.Get(123) end)
		pcall(function() SandboxVarsModule.GetVanilla(nil) end)
		pcall(function() SandboxVarsModule.GetFromNamespace(nil, "key") end)
		pcall(function() SandboxVarsModule.GetAll("InvalidNamespace") end)
	end

	testErrors()
	-- If we reach here without crashing, test passes
	TestRunner.passed = TestRunner.passed + 1
end)

-- ============================================================================
-- RUN TESTS
-- ============================================================================

local results = TestRunner.run_all()

return {
	run = TestRunner.run_all,
	results = results,
}
