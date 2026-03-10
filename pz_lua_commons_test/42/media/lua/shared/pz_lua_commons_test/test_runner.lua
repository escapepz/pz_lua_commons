-- Test runner for all pz_lua_commons tests

local function run_all_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_RUNNER")
    local function safeLog(msg, level)
        _logger:log(msg, level)
    end

    safeLog("\n" .. string.rep("=", 60))
    safeLog("PZ LUA COMMONS - TEST SUITE")
    safeLog(string.rep("=", 60) .. "\n")

    local all_results = {}

    -- Load test modules
    local test_safelogger = require("pz_lua_commons_test/test_safelogger")
    local test_shared = require("pz_lua_commons_test/test_shared")
    local test_signal = require("pz_lua_commons_test/test_signal")
    local test_client = require("pz_lua_commons_test/test_client")

    -- Run test_safelogger
    safeLog("Running: test_safelogger")
    safeLog("-" .. string.rep("-", 58))
    local safelogger_results = test_safelogger.run()
    table.insert(all_results, { name = "safelogger", results = safelogger_results })

    -- Run test_shared
    safeLog("\n\nRunning: test_shared")
    safeLog("-" .. string.rep("-", 58))
    local shared_results = test_shared.run()
    table.insert(all_results, { name = "shared", results = shared_results })

    -- Run test_signal
    safeLog("\n\nRunning: test_signal")
    safeLog("-" .. string.rep("-", 58))
    local signal_results = test_signal.run()
    table.insert(all_results, { name = "signal", results = signal_results })

    -- Run test_client
    safeLog("\n\nRunning: test_client")
    safeLog("-" .. string.rep("-", 58))
    local client_results = test_client.run()
    table.insert(all_results, { name = "client", results = client_results })

    -- Summary
    safeLog("\n" .. string.rep("=", 60))
    safeLog("TEST SUMMARY")
    safeLog(string.rep("=", 60) .. "\n")

    local total_passed = 0
    local total_failed = 0

    for _, suite in ipairs(all_results) do
        local passed = 0
        local failed = 0

        for _, result in ipairs(suite.results) do
            if result.passed then
                passed = passed + 1
            else
                failed = failed + 1
            end
        end

        total_passed = total_passed + passed
        total_failed = total_failed + failed

        local status = failed == 0 and "PASS" or "FAIL"
        safeLog(string.format("%-20s: %s (%d/%d)", suite.name, status, passed, passed + failed))
    end

    safeLog("\n" .. string.rep("-", 60))
    safeLog(string.format("TOTAL: %d/%d tests passed", total_passed, total_passed + total_failed))

    if total_failed == 0 then
        safeLog("✓ ALL TESTS PASSED")
    else
        safeLog("✗ " .. total_failed .. " TEST(S) FAILED")
    end

    safeLog(string.rep("=", 60) .. "\n")

    return {
        total_passed = total_passed,
        total_failed = total_failed,
        suites = all_results,
    }
end

return {
    run = run_all_tests,
}
