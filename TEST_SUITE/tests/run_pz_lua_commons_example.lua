-- Test Runner for pz_lua_commons_example scripts
-- Runs the examples in a plain Lua environment
-- Run with: lua TEST_SUITE/tests/run_pz_lua_commons_example.lua

local mock_pz = require("TEST_SUITE/tests/mock_pz")
mock_pz.setupGlobalEnvironment()

-- Find project root robustly
local info = debug.getinfo(1, "S")
local path = (info and info.source) and info.source:sub(2):gsub("\\", "/") or ""
local root = path:match("^(.*)/TEST_SUITE/")
root = root and (root .. "/") or ""

print("Project Root: " .. root)

-- Setup package.path for pz_lua_commons
package.path = package.path .. ";" .. root .. "pz_lua_commons/common/media/lua/shared/?.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons/common/media/lua/shared/?/init.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons/common/media/lua/client/?.lua"

-- Setup package.path for pz_lua_commons_example
package.path = package.path .. ";" .. root .. "pz_lua_commons_example/common/media/lua/shared/?.lua"
package.path = package.path
    .. ";"
    .. root
    .. "pz_lua_commons_example/common/media/lua/shared/?/init.lua"

-- Execute the test suite for examples
print("\n" .. string.rep("=", 70))
print("RUNNING EXAMPLES TEST SUITE")
print(string.rep("=", 70))

local success, example_test = pcall(require, "TEST_SUITE/tests/test_pz_lua_commons_example")
if not success then
    print("FAILED to load test_pz_lua_commons_example: " .. tostring(example_test))
    os.exit(1)
end

local results = example_test.run()

local total_passed = 0
local total_failed = 0
for _, result in ipairs(results) do
    if result.passed then
        total_passed = total_passed + 1
    else
        total_failed = total_failed + 1
        print("\n[FAILURE] " .. result.name)
        print("  " .. tostring(result.note))
    end
end

print("\n" .. string.rep("=", 70))
print("TEST SUMMARY")
print(string.rep("=", 70))
print("Passed: " .. total_passed)
print("Failed: " .. total_failed)
print("Total:  " .. (total_passed + total_failed))

if total_failed == 0 then
    print("\n[SUCCESS] All examples passed!")
    os.exit(0)
else
    print("\n[FAILURE] " .. total_failed .. " examples failed.")
    os.exit(1)
end
