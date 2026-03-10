---@diagnostic disable: need-check-nil
-- Test suite for shared.lua modules

local function run_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_SHARED")
    local function safeLog(msg, level)
        _logger:log(msg, level)
    end

    local pzc = require("pz_lua_commons_shared")

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

    local function assert_not_nil(value, test_name)
        if value ~= nil then
            table.insert(test_results, { name = test_name, passed = true })
            return true
        else
            table.insert(test_results, { name = test_name, passed = false })
            return false
        end
    end

    -- Test 1: pzc is a table
    assert_type(pzc, "table", "pzc is a table")

    -- Test 2: pzc has grafi_tt namespace
    assert_type(pzc.grafi_tt, "table", "pzc.grafi_tt exists")

    -- Test 3: pzc has kikito namespace
    assert_type(pzc.kikito, "table", "pzc.kikito exists")

    -- Test 4: pzc has rxi namespace
    assert_type(pzc.rxi, "table", "pzc.rxi exists")

    -- Test 5: pzc has vrld namespace
    assert_type(pzc.vrld, "table", "pzc.vrld exists")

    -- Test 6: lunajson is available in grafi_tt
    if pzc.grafi_tt.lunajson then
        assert_type(pzc.grafi_tt.lunajson, "table", "lunajson is available and is a table")
    else
        table.insert(test_results, {
            name = "lunajson is available (optional)",
            passed = false,
            note = "lunajson not available - check installation",
        })
    end

    -- Test 7: middleclass is available in kikito
    if pzc.kikito.middleclass then
        assert_type(pzc.kikito.middleclass, "table", "middleclass is available and is a table")
    else
        table.insert(test_results, {
            name = "middleclass is available (optional)",
            passed = false,
            note = "middleclass not available - check installation",
        })
    end

    -- Test 8: jsonlua is available in rxi
    if pzc.rxi.jsonlua then
        assert_type(pzc.rxi.jsonlua, "table", "jsonlua is available and is a table")
    else
        table.insert(test_results, {
            name = "jsonlua is available (optional)",
            passed = false,
            note = "jsonlua not available - check installation",
        })
    end

    -- Test 9: hump.signal is available in vrld
    if pzc.vrld.hump and pzc.vrld.hump.signal then
        assert_type(pzc.vrld.hump.signal, "table", "hump.signal is available and is a table")

        -- Test 10: hump.signal has register method
        if pzc.vrld.hump.signal.register then
            assert_type(
                pzc.vrld.hump.signal.register,
                "function",
                "hump.signal has register method"
            )
        end

        -- Test 11: hump.signal has emit method
        if pzc.vrld.hump.signal.emit then
            assert_type(pzc.vrld.hump.signal.emit, "function", "hump.signal has emit method")
        end
    else
        table.insert(test_results, {
            name = "hump.signal is available (optional)",
            passed = false,
            note = "hump.signal not available - check installation",
        })
    end

    -- Test 12: Test lunajson encode/decode if available
    if pzc.grafi_tt.lunajson then
        local json = pzc.grafi_tt.lunajson
        local test_data = { key = "value", num = 123 }

        local success = pcall(function()
            local encoded = json.encode(test_data)
            local decoded = json.decode(encoded)
            assert_equal(
                decoded.key,
                test_data.key,
                "lunajson encode/decode preserves string values"
            )
            assert_equal(decoded.num, test_data.num, "lunajson encode/decode preserves numbers")
        end)

        if not success then
            table.insert(test_results, {
                name = "lunajson encode/decode works",
                passed = false,
            })
        end
    end

    -- Test 13: Test hump.signal basic functionality if available
    if pzc.vrld.hump.signal then
        local signal = pzc.vrld.hump.signal
        local signal_triggered = false

        local success = pcall(function()
            local function callback()
                signal_triggered = true
            end
            signal.register("test_event", callback)
            signal.emit("test_event")

            assert_equal(signal_triggered, true, "hump.signal can register and emit events")
        end)

        if not success then
            table.insert(test_results, {
                name = "hump.signal register/emit works",
                passed = false,
            })
        end
    end

    -- Print test results
    safeLog("\n=== Shared Modules Test Results ===")
    local passed = 0
    local failed = 0
    for _, result in ipairs(test_results) do
        if result.passed then
            safeLog("✓ " .. result.name)
            passed = passed + 1
        else
            safeLog("✗ " .. result.name)
            if result.note then
                safeLog("  Note: " .. result.note)
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
