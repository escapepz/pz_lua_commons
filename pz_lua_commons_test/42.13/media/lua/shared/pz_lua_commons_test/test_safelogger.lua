-- Test suite for safelogger.lua

local function run_tests()
	local safeLog = require("pz_lua_commons/safelogger")
	local test_results = {}

	-- Helper function to run tests
	local function assert_equal(actual, expected, test_name)
		if actual == expected then
			table.insert(test_results, {name = test_name, passed = true})
			return true
		else
			table.insert(test_results, {
				name = test_name,
				passed = false,
				expected = expected,
				actual = actual
			})
			return false
		end
	end

	local function assert_type(value, expected_type, test_name)
		if type(value) == expected_type then
			table.insert(test_results, {name = test_name, passed = true})
			return true
		else
			table.insert(test_results, {
				name = test_name,
				passed = false,
				expected_type = expected_type,
				actual_type = type(value)
			})
			return false
		end
	end

	-- Test 1: safeLog is a function
	assert_type(safeLog, "function", "safeLog is a function")

	-- Test 2: safeLog handles string messages
	local success = pcall(function()
		safeLog("Test message")
	end)
	assert_equal(success, true, "safeLog handles string messages")

	-- Test 3: safeLog handles nil messages
	success = pcall(function()
		safeLog(nil)
	end)
	assert_equal(success, true, "safeLog handles nil messages")

	-- Test 4: safeLog handles number messages
	success = pcall(function()
		safeLog(123)
	end)
	assert_equal(success, true, "safeLog handles number messages")

	-- Test 5: safeLog with debug flag
	success = pcall(function()
		safeLog("Debug message", true)
	end)
	assert_equal(success, true, "safeLog handles debug flag")

	-- Test 6: safeLog with debug=false
	success = pcall(function()
		safeLog("Info message", false)
	end)
	assert_equal(success, true, "safeLog handles debug=false")

	-- Print test results
	safeLog("\n=== safelogger Test Results ===")
	local passed = 0
	local failed = 0
	for _, result in ipairs(test_results) do
		if result.passed then
			safeLog("✓ " .. result.name)
			passed = passed + 1
		else
			safeLog("✗ " .. result.name)
			if result.expected then
				safeLog("  Expected: " .. tostring(result.expected) .. ", Got: " .. tostring(result.actual))
			end
			failed = failed + 1
		end
	end
	safeLog("Passed: " .. passed .. "/" .. (passed + failed))

	return test_results
end

return {
	run = run_tests
}
