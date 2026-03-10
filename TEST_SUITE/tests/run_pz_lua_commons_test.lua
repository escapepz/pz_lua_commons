-- Test Runner for pz_lua_commons_test mod
-- Runs the in-game test suite in a plain Lua environment
-- Run with: lua TEST_SUITE/tests/run_pz_lua_commons_test.lua

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
package.path = package.path .. ";" .. root .. "pz_lua_commons/common/media/lua/client/?/init.lua"

-- Setup package.path for pz_lua_commons_test
-- Note: mod structure has both '42' and 'common' folders
package.path = package.path .. ";" .. root .. "pz_lua_commons_test/42/media/lua/shared/?.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons_test/42/media/lua/shared/?/init.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons_test/42/media/lua/client/?.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons_test/42/media/lua/client/?/init.lua"
package.path = package.path .. ";" .. root .. "pz_lua_commons_test/common/media/lua/shared/?.lua"
package.path = package.path
    .. ";"
    .. root
    .. "pz_lua_commons_test/common/media/lua/shared/?/init.lua"

-- Mock global PZ events if needed
_G.Events = {
    OnGameStart = { Add = function() end },
    OnTick = { Add = function() end },
}

-- Execute the test runner from the mod
print("\n" .. string.rep("=", 70))
print("LOADING MOD TEST RUNNER")
print(string.rep("=", 70))

local ok, test_runner = pcall(require, "pz_lua_commons_test/test_runner")
if not ok then
    print("FAILED to load test_runner: " .. tostring(test_runner))
    os.exit(1)
end

print("Test runner loaded successfully.\n")

local results = test_runner.run()

if results and results.total_failed == 0 then
    print("\n[SUCCESS] All mod tests passed!")
    os.exit(0)
else
    local failed = results and results.total_failed or "unknown"
    print("\n[FAILURE] " .. failed .. " tests failed.")
    os.exit(1)
end
