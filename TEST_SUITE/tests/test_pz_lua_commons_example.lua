-- Test suite for pz_lua_commons_example
-- This suite runs the example scripts and verifies they don't crash

local function run_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_EXAMPLE")
    local function safeLog(msg, level)
        _logger:log(msg, level)
    end

    -- Get root directory
    local info = debug.getinfo(1, "S")
    local path = (info and info.source) and info.source:sub(2):gsub("\\", "/") or ""
    local root = path:match("^(.*)/TEST_SUITE/")
    root = root and (root .. "/") or ""

    local example_dir = root .. "pz_lua_commons_example/common/media/lua/shared/"

    -- List of example files to test
    local examples = {
        "example_01_basic_loading",
        "example_02_json_lunajson",
        "example_03_middleclass_oop",
        "example_04_json_jsonlua",
        "example_05_hump_signal",
        "example_06_combined_shared_utilities",
        "example_07_kahlua_string_table",
        "example_08_kahlua_serialization",
        "example_09_zomboid_api_shared",
        "example_10_network_protocol",
        "example_11_class_based_networking",
        "example_12_combined_shared_advanced",
        "example_13_pz_utils_escape",
        "example_14_pz_utils_konijima",
        "example_15_pz_utils_advanced",
    }

    local test_results = {}

    safeLog("\n=== Running pz_lua_commons_example Scripts ===")

    for _, example_name in ipairs(examples) do
        local success, err = pcall(function()
            -- Clear package.loaded to ensure fresh run if needed
            -- but since these are scripts, they might not return values
            -- We use require because they might be structured as modules
            -- or just files that we want to ensure load correctly.
            -- Actually, most of them use require("pz_lua_commons/shared")

            -- Force reload by clearing from package.loaded
            package.loaded[example_name] = nil
            require(example_name)
        end)

        if success then
            table.insert(test_results, { name = example_name, passed = true })
            safeLog("✓ " .. example_name)
        else
            table.insert(test_results, {
                name = example_name,
                passed = false,
                note = tostring(err),
            })
            safeLog("✗ " .. example_name .. " - FAILED: " .. tostring(err))
        end
    end

    local passed = 0
    local failed = 0
    for _, result in ipairs(test_results) do
        if result.passed then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end

    safeLog("\nExample Tests Summary:")
    safeLog("Passed: " .. passed .. "/" .. (passed + failed))

    return test_results
end

return {
    run = run_tests,
}
