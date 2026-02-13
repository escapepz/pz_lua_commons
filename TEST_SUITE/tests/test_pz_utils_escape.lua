-- Test Suite: pz_utils Escape Utilities (Migrated from pz_lua_commons_test)
-- Tests for Debounce, EventManager, SafeLogger, SafeRequire, and Utilities

local mock_pz = require("TEST_SUITE/tests/mock_pz")
mock_pz.setupGlobalEnvironment()

-- Load pz_utils - setup path to point to actual pz_lua_commons modules
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?.lua"
package.path = package.path .. ";../../pz_lua_commons/common/media/lua/shared/?/init.lua"

-- Load escape utilities directly
local escape = require("pz_utils/escape/index")

if not escape then
	error("Failed to load escape utilities")
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

function TestRunner.run_all()
	print("\n" .. string.rep("=", 70))
	print("ESCAPE UTILITIES TEST SUITE")
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
-- SAFELOGGER TESTS
-- ============================================================================

TestRunner.register("Escape: SafeLogger init", function()
	escape.SafeLogger.init("TestModule")
	TestRunner.assert_not_nil(escape.SafeLogger, "SafeLogger should exist")
end)

TestRunner.register("Escape: SafeLogger log with numeric levels", function()
	escape.SafeLogger.log("Test message", 10) -- TRACE
	escape.SafeLogger.log("Test message", 20) -- DEBUG
	escape.SafeLogger.log("Test message", 30) -- INFO
	escape.SafeLogger.log("Test message", 40) -- WARN
	escape.SafeLogger.log("Test message", 50) -- ERROR
	escape.SafeLogger.log("Test message", 60) -- FATAL
	TestRunner.passed = TestRunner.passed + 1
end)

TestRunner.register("Escape: SafeLogger log with string levels", function()
	escape.SafeLogger.log("Test message", "TRACE")
	escape.SafeLogger.log("Test message", "DEBUG")
	escape.SafeLogger.log("Test message", "INFO")
	escape.SafeLogger.log("Test message", "WARN")
	escape.SafeLogger.log("Test message", "ERROR")
	escape.SafeLogger.log("Test message", "FATAL")
	TestRunner.passed = TestRunner.passed + 1
end)

TestRunner.register("Escape: SafeLogger log without level", function()
	escape.SafeLogger.log("Test message")
	TestRunner.passed = TestRunner.passed + 1
end)

-- ============================================================================
-- DEBOUNCE TESTS
-- ============================================================================

TestRunner.register("Escape: Debounce Call creates instance", function()
	local callCount = 0
	local callback = function(args)
		callCount = callCount + 1
	end

	escape.Debounce.Call("test_debounce_1", 5, callback, "arg1", "arg2")
	TestRunner.assert_true(escape.Debounce.IsActive("test_debounce_1"), "Debounce should be active after Call")
end)

TestRunner.register("Escape: Debounce reset timer", function()
	local callback = function(args) end

	escape.Debounce.Call("test_debounce_2", 5, callback, "arg1")
	local active1 = escape.Debounce.IsActive("test_debounce_2")

	escape.Debounce.Call("test_debounce_2", 5, callback, "arg2")
	local active2 = escape.Debounce.IsActive("test_debounce_2")

	TestRunner.assert_true(active1 and active2, "Debounce should remain active after reset")
end)

TestRunner.register("Escape: Debounce IsActive check", function()
	escape.Debounce.Cancel("test_debounce_3")

	local isActive = escape.Debounce.IsActive("test_debounce_3")
	TestRunner.assert_false(isActive, "Non-existent debounce should not be active")

	escape.Debounce.Call("test_debounce_3", 5, function() end)
	local isNowActive = escape.Debounce.IsActive("test_debounce_3")
	TestRunner.assert_true(isNowActive, "Debounce should be active after Call")
end)

TestRunner.register("Escape: Debounce Cancel", function()
	escape.Debounce.Call("test_debounce_4", 5, function() end)
	local cancelled = escape.Debounce.Cancel("test_debounce_4")

	TestRunner.assert_true(cancelled, "Cancel should return true for existing debounce")
	TestRunner.assert_false(escape.Debounce.IsActive("test_debounce_4"), "Debounce should be inactive after cancel")
end)

TestRunner.register("Escape: Debounce Cancel nonexistent", function()
	local cancelled = escape.Debounce.Cancel("nonexistent_debounce")
	TestRunner.assert_false(cancelled, "Cancel should return false for non-existent debounce")
end)

TestRunner.register("Escape: Debounce CancelAll", function()
	escape.Debounce.Call("cancel_test_1", 5, function() end)
	escape.Debounce.Call("cancel_test_2", 5, function() end)
	escape.Debounce.Call("cancel_test_3", 5, function() end)

	local count = escape.Debounce.CancelAll()
	TestRunner.assert_true(count >= 3, "CancelAll should cancel multiple debounces")
end)

TestRunner.register("Escape: Debounce Update returns boolean", function()
	local result = escape.Debounce.Update()
	TestRunner.assert_equals(type(result), "boolean", "Update should return boolean")
end)

-- ============================================================================
-- EVENTMANAGER TESTS
-- ============================================================================

TestRunner.register("Escape: EventManager createEvent", function()
	local event = escape.EventManager.createEvent("TestEvent1")
	TestRunner.assert_not_nil(event, "createEvent should return an event object")
	TestRunner.assert_equals(event.name, "TestEvent1", "Event should have correct name")
end)

TestRunner.register("Escape: EventManager get existing event", function()
	escape.EventManager.createEvent("TestEvent2")
	local event = escape.EventManager.createEvent("TestEvent2")

	TestRunner.assert_equals(event.name, "TestEvent2", "Should retrieve existing event")
end)

TestRunner.register("Escape: EventManager add listener", function()
	local event = escape.EventManager.createEvent("TestEvent3")
	local callback = function() end

	event:Add(callback)
	TestRunner.assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")
end)

TestRunner.register("Escape: EventManager multiple listeners", function()
	local event = escape.EventManager.createEvent("TestEvent4")

	event:Add(function() end)
	event:Add(function() end)
	event:Add(function() end)

	TestRunner.assert_equals(event:GetListenerCount(), 3, "Event should have 3 listeners")
end)

TestRunner.register("Escape: EventManager remove listener", function()
	local event = escape.EventManager.createEvent("TestEvent5")
	local callback = function() end

	event:Add(callback)
	TestRunner.assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")

	event:Remove(callback)
	TestRunner.assert_equals(event:GetListenerCount(), 0, "Event should have 0 listeners after remove")
end)

TestRunner.register("Escape: EventManager trigger listeners", function()
	local event = escape.EventManager.createEvent("TestEvent6")
	local callCount = 0

	event:Add(function(arg)
		callCount = callCount + 1
	end)
	event:Add(function(arg)
		callCount = callCount + 1
	end)

	event:Trigger("test")
	TestRunner.assert_equals(callCount, 2, "Trigger should call all listeners")
end)

TestRunner.register("Escape: EventManager SetEnabled", function()
	local event = escape.EventManager.createEvent("TestEvent7")
	local callCount = 0

	event:Add(function()
		callCount = callCount + 1
	end)
	event:SetEnabled(true)
	event:Trigger()

	local count1 = callCount

	event:SetEnabled(false)
	event:Trigger()

	TestRunner.assert_equals(callCount, count1, "Disabled event should not trigger listeners")
end)

TestRunner.register("Escape: EventManager IsEnabled", function()
	local event = escape.EventManager.createEvent("TestEvent8")
	event:SetEnabled(true)
	TestRunner.assert_true(event:IsEnabled(), "Event should be enabled")

	event:SetEnabled(false)
	TestRunner.assert_false(event:IsEnabled(), "Event should be disabled")
end)

TestRunner.register("Escape: EventManager GetListenerCount", function()
	local event = escape.EventManager.createEvent("TestEvent9")
	TestRunner.assert_equals(event:GetListenerCount(), 0, "New event should have 0 listeners")

	event:Add(function() end)
	TestRunner.assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")
end)

TestRunner.register("Escape: EventManager IsExecuting", function()
	local event = escape.EventManager.createEvent("TestEvent10")
	TestRunner.assert_false(event:IsExecuting(), "Event should not be executing initially")

	event:Add(function()
		-- Event is executing here, but we can't test this from callback
	end)
end)

TestRunner.register("Escape: EventManager shorthand on", function()
	local callCount = 0
	escape.EventManager.on("ShorthandTest1", function()
		callCount = callCount + 1
	end)

	escape.EventManager.trigger("ShorthandTest1")
	TestRunner.assert_equals(callCount, 1, "Shorthand 'on' should register listener")
end)

TestRunner.register("Escape: EventManager shorthand off", function()
	local callback = function() end
	escape.EventManager.on("ShorthandTest2", callback)

	TestRunner.assert_equals(
		escape.EventManager.events["ShorthandTest2"]:GetListenerCount(),
		1,
		"Should have 1 listener"
	)

	escape.EventManager.off("ShorthandTest2", callback)
	TestRunner.assert_equals(
		escape.EventManager.events["ShorthandTest2"]:GetListenerCount(),
		0,
		"Should have 0 listeners after off"
	)
end)

TestRunner.register("Escape: EventManager getEventInfo", function()
	escape.EventManager.createEvent("TestEvent11")
	local event = escape.EventManager.events["TestEvent11"]
	event:Add(function() end)

	local info = escape.EventManager.getEventInfo("TestEvent11")
	TestRunner.assert_not_nil(info, "getEventInfo should return info table")
	TestRunner.assert_equals(info.listeners, 1, "Info should show 1 listener")
end)

TestRunner.register("Escape: EventManager getAllEventsInfo", function()
	local allInfo = escape.EventManager.getAllEventsInfo()
	TestRunner.assert_equals(type(allInfo), "table", "getAllEventsInfo should return table")
end)

-- ============================================================================
-- SAFEREQ UIRE TESTS
-- ============================================================================

TestRunner.register("Escape: SafeRequire valid module", function()
	local result = escape.SafeRequire("pz_utils/escape/utilities", "TestModule")
	TestRunner.assert_not_nil(result, "SafeRequire should load valid module")
end)

TestRunner.register("Escape: SafeRequire invalid module", function()
	local result = escape.SafeRequire("nonexistent/module/path", "InvalidModule")
	TestRunner.assert_equals(result, nil, "SafeRequire should return nil for invalid module")
end)

-- ============================================================================
-- UTILITIES TESTS
-- ============================================================================

TestRunner.register("Escape: Utilities GetIRLTimestamp", function()
	local timestamp = escape.Utilities.GetIRLTimestamp()
	TestRunner.assert_equals(type(timestamp), "number", "GetIRLTimestamp should return number")
	TestRunner.assert_true(timestamp > 0, "Timestamp should be positive")
end)

TestRunner.register("Escape: Utilities GetIRLTimestamp increases", function()
	local timestamp1 = escape.Utilities.GetIRLTimestamp()
	local timestamp2 = escape.Utilities.GetIRLTimestamp()

	TestRunner.assert_true(timestamp2 >= timestamp1, "Timestamp should increase or stay same")
end)

-- ============================================================================
-- RUN TESTS
-- ============================================================================

local results = TestRunner.run_all()

return {
	run = TestRunner.run_all,
	results = results,
}
