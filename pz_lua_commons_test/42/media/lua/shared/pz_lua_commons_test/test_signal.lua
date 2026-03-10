---@diagnostic disable: need-check-nil
-- Test suite for hump.signal module

local function run_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_SIGNAL")
    local function safeLog(msg, level)
        _logger:log(msg, level)
    end

    local pzc = require("pz_lua_commons_shared")
    local signal = pzc.vrld.hump.signal

    local test_results = {}

    local function assert_equal(actual, expected, test_name)
        if actual == expected then
            table.insert(test_results, { name = test_name, passed = true })
            return true
        else
            table.insert(test_results, {
                name = test_name,
                passed = false,
                expected = expected,
                actual = actual,
            })
            return false
        end
    end

    local function assert_type(value, expected_type, test_name)
        if type(value) == expected_type then
            table.insert(test_results, { name = test_name, passed = true })
            return true
        else
            table.insert(test_results, {
                name = test_name,
                passed = false,
                expected_type = expected_type,
                actual_type = type(value),
            })
            return false
        end
    end

    if not signal then
        safeLog("WARN: hump.signal not available, skipping signal tests")
        return test_results
    end

    -- Test 1: signal module is a table
    assert_type(signal, "table", "signal is a table")

    -- Test 2: signal has register method
    assert_type(signal.register, "function", "signal has register method")

    -- Test 3: signal has emit method
    assert_type(signal.emit, "function", "signal has emit method")

    -- Test 4: signal has remove method
    assert_type(signal.remove, "function", "signal has remove method")

    -- Test 5: signal has clear method
    assert_type(signal.clear, "function", "signal has clear method")

    -- Test 6: signal has emitPattern method
    assert_type(signal.emitPattern, "function", "signal has emitPattern method")

    -- Test 7: signal has registerPattern method
    assert_type(signal.registerPattern, "function", "signal has registerPattern method")

    -- Test 8: Basic register and emit
    local callback_called = false
    local callback = function()
        callback_called = true
    end

    signal.register("test_event", callback)
    signal.emit("test_event")
    assert_equal(callback_called, true, "register/emit triggers callback")

    -- Test 9: Emit with parameters
    local received_params = {}
    local param_callback = function(a, b, c)
        received_params = { a, b, c }
    end

    signal.clear("param_event")
    signal.register("param_event", param_callback)
    signal.emit("param_event", 1, "hello", true)
    assert_equal(received_params[1], 1, "emit passes first parameter correctly")
    assert_equal(received_params[2], "hello", "emit passes second parameter correctly")
    assert_equal(received_params[3], true, "emit passes third parameter correctly")

    -- Test 10: Multiple callbacks for same event
    local call_count = 0
    local counter1 = function()
        call_count = call_count + 1
    end
    local counter2 = function()
        call_count = call_count + 1
    end

    signal.clear("multi_event")
    signal.register("multi_event", counter1)
    signal.register("multi_event", counter2)
    signal.emit("multi_event")
    assert_equal(call_count, 2, "multiple distinct callbacks are all called")

    -- Test 11: Remove callback
    local removable_called = false
    local removable_callback = function()
        removable_called = true
    end

    signal.clear("remove_event")
    signal.register("remove_event", removable_callback)
    signal.remove("remove_event", removable_callback)
    signal.emit("remove_event")
    assert_equal(removable_called, false, "removed callback is not called")

    -- Test 12: Clear event
    local clear_called = false
    local clear_callback = function()
        clear_called = true
    end

    signal.clear("clear_event")
    signal.register("clear_event", clear_callback)
    signal.clear("clear_event")
    signal.emit("clear_event")
    assert_equal(clear_called, false, "cleared callbacks are not called")

    -- Test 13: Pattern registration
    local pattern_called = false
    local pattern_callback = function()
        pattern_called = true
    end

    signal.clear("foo_event")
    signal.clear("foo_bar")
    signal.registerPattern("foo.*", pattern_callback)
    signal.emit("foo_event")
    assert_equal(pattern_called, true, "pattern registration registers matching events")

    -- Test 14: Pattern emit
    local pattern_emit_called = false
    local pattern_emit_callback = function()
        pattern_emit_called = true
    end

    signal.clear("bar_event")
    signal.registerPattern("bar.*", pattern_emit_callback)
    signal.emitPattern("bar.*")
    assert_equal(pattern_emit_called, true, "emitPattern triggers pattern-matched callbacks")

    -- Test 15: New instance creation
    local instance_1 = signal.new()
    local instance_2 = signal.new()
    assert_type(instance_1, "table", "signal.new() creates a new instance")
    assert_type(instance_2, "table", "signal.new() creates multiple instances")

    -- Test 16: New instances are independent
    local inst1_called = false
    local inst2_called = false

    local inst1_callback = function()
        inst1_called = true
    end
    local inst2_callback = function()
        inst2_called = true
    end

    instance_1:register("independent_event", inst1_callback)
    instance_2:register("independent_event", inst2_callback)
    instance_1:emit("independent_event")

    assert_equal(inst1_called, true, "instance 1 callback called on instance 1 emit")
    assert_equal(inst2_called, false, "instance 2 callback not called on instance 1 emit")

    -- Print test results
    safeLog("\n=== Signal Module Test Results ===")
    local passed = 0
    local failed = 0
    for _, result in ipairs(test_results) do
        if result.passed then
            safeLog("✓ " .. result.name)
            passed = passed + 1
        else
            safeLog("✗ " .. result.name)
            if result.expected then
                safeLog(
                    "  Expected: "
                        .. tostring(result.expected)
                        .. ", Got: "
                        .. tostring(result.actual)
                )
            end
            failed = failed + 1
        end
    end
    safeLog("Passed: " .. passed .. "/" .. (passed + failed))

    return test_results
end

return {
    run = run_tests,
}
