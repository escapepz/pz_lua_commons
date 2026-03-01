-- Test Suite: pz_utils - Escape Utilities
-- Tests for Debounce, EventManager, SafeLogger, SafeRequire, and Utilities

local pz_utils = require("pz_utils_shared")
local escape = pz_utils[1] or pz_utils.escape

-- Simple test framework
local tests = {}
local testsPassed = 0
local testsFailed = 0

local function assert_equals(actual, expected, message)
    if actual == expected then
        testsPassed = testsPassed + 1
        return true
    else
        testsFailed = testsFailed + 1
        print("FAIL: " .. (message or "assertion") .. " - expected: " .. tostring(expected) .. " got: " .. tostring(actual))
        return false
    end
end

local function assert_true(value, message)
    return assert_equals(value, true, message)
end

local function assert_false(value, message)
    return assert_equals(value, false, message)
end

local function assert_not_nil(value, message)
    if value ~= nil then
        testsPassed = testsPassed + 1
        return true
    else
        testsFailed = testsFailed + 1
        print("FAIL: " .. (message or "assertion") .. " - expected non-nil value")
        return false
    end
end

-- ============================================================================
-- SAFELOGGER TESTS
-- ============================================================================

print("\n=== SafeLogger Tests ===\n")

tests.test_safelogger_init = function()
    local logger = escape.SafeLogger.new("TestModule")
    assert_not_nil(logger, "SafeLogger should exist")
end

tests.test_safelogger_log_with_numeric_level = function()
    -- Should not crash with numeric levels
    local logger = escape.SafeLogger.new("TestModule")
    logger:log("Test message", 10)  -- TRACE
    logger:log("Test message", 20)  -- DEBUG
    logger:log("Test message", 30)  -- INFO
    logger:log("Test message", 40)  -- WARN
    logger:log("Test message", 50)  -- ERROR
    logger:log("Test message", 60)  -- FATAL
    testsPassed = testsPassed + 1
end

tests.test_safelogger_log_with_string_level = function()
    local logger = escape.SafeLogger.new("TestModule")
    logger:log("Test message", "TRACE")
    logger:log("Test message", "DEBUG")
    logger:log("Test message", "INFO")
    logger:log("Test message", "WARN")
    logger:log("Test message", "ERROR")
    logger:log("Test message", "FATAL")
    testsPassed = testsPassed + 1
end

tests.test_safelogger_log_without_level = function()
    -- Should default to INFO (30)
    local logger = escape.SafeLogger.new("TestModule")
    logger:log("Test message")
    testsPassed = testsPassed + 1
end

-- ============================================================================
-- DEBOUNCE TESTS
-- ============================================================================

print("=== Debounce Tests ===\n")

tests.test_debounce_call_creates_instance = function()
    local callCount = 0
    local callback = function(args) callCount = callCount + 1 end
    
    escape.Debounce.Call("test_debounce_1", 5, callback, "arg1", "arg2")
    assert_true(escape.Debounce.IsActive("test_debounce_1"), "Debounce should be active after Call")
end

tests.test_debounce_reset_timer = function()
    local callback = function(args) end
    
    escape.Debounce.Call("test_debounce_2", 5, callback, "arg1")
    local active1 = escape.Debounce.IsActive("test_debounce_2")
    
    escape.Debounce.Call("test_debounce_2", 5, callback, "arg2")
    local active2 = escape.Debounce.IsActive("test_debounce_2")
    
    assert_true(active1 and active2, "Debounce should remain active after reset")
end

tests.test_debounce_is_active = function()
    escape.Debounce.Cancel("test_debounce_3")  -- Ensure clean state
    
    local isActive = escape.Debounce.IsActive("test_debounce_3")
    assert_false(isActive, "Non-existent debounce should not be active")
    
    escape.Debounce.Call("test_debounce_3", 5, function() end)
    local isNowActive = escape.Debounce.IsActive("test_debounce_3")
    assert_true(isNowActive, "Debounce should be active after Call")
end

tests.test_debounce_cancel = function()
    escape.Debounce.Call("test_debounce_4", 5, function() end)
    local cancelled = escape.Debounce.Cancel("test_debounce_4")
    
    assert_true(cancelled, "Cancel should return true for existing debounce")
    assert_false(escape.Debounce.IsActive("test_debounce_4"), "Debounce should be inactive after cancel")
end

tests.test_debounce_cancel_nonexistent = function()
    local cancelled = escape.Debounce.Cancel("nonexistent_debounce")
    assert_false(cancelled, "Cancel should return false for non-existent debounce")
end

tests.test_debounce_cancel_all = function()
    escape.Debounce.Call("cancel_test_1", 5, function() end)
    escape.Debounce.Call("cancel_test_2", 5, function() end)
    escape.Debounce.Call("cancel_test_3", 5, function() end)
    
    local count = escape.Debounce.CancelAll()
    assert_equals(count >= 3, true, "CancelAll should cancel multiple debounces")
end

tests.test_debounce_update_returns_boolean = function()
    local result = escape.Debounce.Update()
    assert_equals(type(result), "boolean", "Update should return boolean")
end

-- ============================================================================
-- EVENTMANAGER TESTS
-- ============================================================================

print("=== EventManager Tests ===\n")

tests.test_eventmanager_create_event = function()
    local event = escape.EventManager.createEvent("TestEvent1")
    assert_not_nil(event, "createEvent should return an event object")
    assert_equals(event.name, "TestEvent1", "Event should have correct name")
end

tests.test_eventmanager_get_existing_event = function()
    escape.EventManager.createEvent("TestEvent2")
    local event = escape.EventManager.createEvent("TestEvent2")
    
    assert_equals(event.name, "TestEvent2", "Should retrieve existing event")
end

tests.test_eventmanager_add_listener = function()
    local event = escape.EventManager.createEvent("TestEvent3")
    local callback = function() end
    
    event:Add(callback)
    assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")
end

tests.test_eventmanager_multiple_listeners = function()
    local event = escape.EventManager.createEvent("TestEvent4")
    
    event:Add(function() end)
    event:Add(function() end)
    event:Add(function() end)
    
    assert_equals(event:GetListenerCount(), 3, "Event should have 3 listeners")
end

tests.test_eventmanager_remove_listener = function()
    local event = escape.EventManager.createEvent("TestEvent5")
    local callback = function() end
    
    event:Add(callback)
    assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")
    
    event:Remove(callback)
    assert_equals(event:GetListenerCount(), 0, "Event should have 0 listeners after remove")
end

tests.test_eventmanager_trigger_listeners = function()
    local event = escape.EventManager.createEvent("TestEvent6")
    local callCount = 0
    
    event:Add(function(arg) 
        callCount = callCount + 1 
    end)
    event:Add(function(arg)
        callCount = callCount + 1
    end)
    
    event:Trigger("test")
    assert_equals(callCount, 2, "Trigger should call all listeners")
end

tests.test_eventmanager_set_enabled = function()
    local event = escape.EventManager.createEvent("TestEvent7")
    local callCount = 0
    
    event:Add(function() callCount = callCount + 1 end)
    event:SetEnabled(true)
    event:Trigger()
    
    local count1 = callCount
    
    event:SetEnabled(false)
    event:Trigger()
    
    assert_equals(callCount, count1, "Disabled event should not trigger listeners")
end

tests.test_eventmanager_is_enabled = function()
    local event = escape.EventManager.createEvent("TestEvent8")
    event:SetEnabled(true)
    assert_true(event:IsEnabled(), "Event should be enabled")
    
    event:SetEnabled(false)
    assert_false(event:IsEnabled(), "Event should be disabled")
end

tests.test_eventmanager_get_listener_count = function()
    local event = escape.EventManager.createEvent("TestEvent9")
    assert_equals(event:GetListenerCount(), 0, "New event should have 0 listeners")
    
    event:Add(function() end)
    assert_equals(event:GetListenerCount(), 1, "Event should have 1 listener")
end

tests.test_eventmanager_is_executing = function()
    local event = escape.EventManager.createEvent("TestEvent10")
    assert_false(event:IsExecuting(), "Event should not be executing initially")
    
    event:Add(function()
        -- Event is executing here, but we can't test this from callback
    end)
end

tests.test_eventmanager_shorthand_on = function()
    local callCount = 0
    escape.EventManager.on("ShorthandTest1", function()
        callCount = callCount + 1
    end)
    
    escape.EventManager.trigger("ShorthandTest1")
    assert_equals(callCount, 1, "Shorthand 'on' should register listener")
end

tests.test_eventmanager_shorthand_off = function()
    local callback = function() end
    escape.EventManager.on("ShorthandTest2", callback)
    
    assert_equals(escape.EventManager.events["ShorthandTest2"]:GetListenerCount(), 1, 
                  "Should have 1 listener")
    
    escape.EventManager.off("ShorthandTest2", callback)
    assert_equals(escape.EventManager.events["ShorthandTest2"]:GetListenerCount(), 0, 
                  "Should have 0 listeners after off")
end

tests.test_eventmanager_get_event_info = function()
    escape.EventManager.createEvent("TestEvent11")
    local event = escape.EventManager.events["TestEvent11"]
    event:Add(function() end)
    
    local info = escape.EventManager.getEventInfo("TestEvent11")
    assert_not_nil(info, "getEventInfo should return info table")
    assert_equals(info.listeners, 1, "Info should show 1 listener")
end

tests.test_eventmanager_get_all_events_info = function()
    local allInfo = escape.EventManager.getAllEventsInfo()
    assert_equals(type(allInfo), "table", "getAllEventsInfo should return table")
end

-- ============================================================================
-- SAFEREQ UIRE TESTS
-- ============================================================================

print("=== SafeRequire Tests ===\n")

tests.test_saferequ ire_valid_module = function()
    local result = escape.SafeRequire("pz_utils/escape/utilities", "TestModule")
    assert_not_nil(result, "SafeRequire should load valid module")
end

tests.test_saferequ ire_invalid_module = function()
    local result = escape.SafeRequire("nonexistent/module/path", "InvalidModule")
    assert_equals(result, nil, "SafeRequire should return nil for invalid module")
end

-- ============================================================================
-- UTILITIES TESTS
-- ============================================================================

print("=== Utilities Tests ===\n")

tests.test_utilities_get_irl_timestamp = function()
    local timestamp = escape.Utilities.GetIRLTimestamp()
    assert_equals(type(timestamp), "number", "GetIRLTimestamp should return number")
    assert_true(timestamp > 0, "Timestamp should be positive")
end

tests.test_utilities_get_irl_timestamp_increases = function()
    local timestamp1 = escape.Utilities.GetIRLTimestamp()
    -- Small delay - in real scenario would be more noticeable
    local timestamp2 = escape.Utilities.GetIRLTimestamp()
    
    assert_true(timestamp2 >= timestamp1, "Timestamp should increase or stay same")
end

-- ============================================================================
-- RUN ALL TESTS
-- ============================================================================

print("\n" .. string.rep("=", 50))
print("RUNNING ALL TESTS")
print(string.rep("=", 50) .. "\n")

for testName, testFunc in pairs(tests) do
    io.write(testName .. " ... ")
    local success, err = pcall(testFunc)
    if success then
        print("OK")
    else
        print("ERROR: " .. tostring(err))
        testsFailed = testsFailed + 1
    end
end

-- Print results
print("\n" .. string.rep("=", 50))
print("TEST RESULTS")
print(string.rep("=", 50))
print("Passed: " .. testsPassed)
print("Failed: " .. testsFailed)
print("Total:  " .. (testsPassed + testsFailed))

if testsFailed == 0 then
    print("\n✓ All tests passed!")
else
    print("\n✗ Some tests failed!")
end

print(string.rep("=", 50) .. "\n")
