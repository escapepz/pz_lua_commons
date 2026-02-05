-- Test suite for client.lua modules

local function run_tests()
	local safeLog = require("pz_lua_commons/safelogger")
	local pzc = require("pz_lua_commons_client")

	local test_results = {}

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

	-- Test 1: pzc is a table
	assert_type(pzc, "table", "pzc is a table")

	-- Test 2: pzc has kikito namespace
	assert_type(pzc.kikito, "table", "pzc.kikito exists")

	-- Test 3: pzc has pkulchenko namespace
	assert_type(pzc.pkulchenko, "table", "pzc.pkulchenko exists")

	-- Test 4: pzc has yonaba namespace
	assert_type(pzc.yonaba, "table", "pzc.yonaba exists")

	-- Test 5: inspectlua is available in kikito
	if pzc.kikito.inspectlua then
		assert_type(pzc.kikito.inspectlua, "table", "inspectlua is available and is a table")
		
		-- Test 5a: inspectlua has inspect method
		if pzc.kikito.inspectlua.inspect then
			assert_type(pzc.kikito.inspectlua.inspect, "function", "inspectlua has inspect method")
		elseif type(pzc.kikito.inspectlua) == "function" then
			table.insert(test_results, {name = "inspectlua is callable", passed = true})
		end
	else
		table.insert(test_results, {
			name = "inspectlua is available (optional)",
			passed = false,
			note = "inspectlua not available - check installation"
		})
	end

	-- Test 6: serpent is available in pkulchenko
	if pzc.pkulchenko.serpent then
		assert_type(pzc.pkulchenko.serpent, "table", "serpent is available and is a table")
		
		-- Test 6a: serpent has dump method
		if pzc.pkulchenko.serpent.dump then
			assert_type(pzc.pkulchenko.serpent.dump, "function", "serpent has dump method")
		end
		
		-- Test 6b: serpent has load method
		if pzc.pkulchenko.serpent.load then
			assert_type(pzc.pkulchenko.serpent.load, "function", "serpent has load method")
		end
	else
		table.insert(test_results, {
			name = "serpent is available (optional)",
			passed = false,
			note = "serpent not available - check installation"
		})
	end

	-- Test 7: yon_30log is available in yonaba
	if pzc.yonaba.yon_30log then
		assert_type(pzc.yonaba.yon_30log, "table", "yon_30log is available and is a table")
		
		-- Test 7a: yon_30log has new method
		if pzc.yonaba.yon_30log.new then
			assert_type(pzc.yonaba.yon_30log.new, "function", "yon_30log has new method")
		end
	else
		table.insert(test_results, {
			name = "yon_30log is available (optional)",
			passed = false,
			note = "yon_30log not available - check installation"
		})
	end

	-- Test 8: Test inspectlua basic functionality if available
	if pzc.kikito.inspectlua then
		local inspect = pzc.kikito.inspectlua
		local success = pcall(function()
			local test_table = {a = 1, b = 2, c = {nested = true}}
			local result = inspect(test_table)
			assert_type(result, "string", "inspectlua returns a string representation")
		end)
		
		if not success then
			table.insert(test_results, {
				name = "inspectlua can inspect tables",
				passed = false
			})
		end
	end

	-- Test 9: Test serpent dump if available
	if pzc.pkulchenko.serpent then
		local serpent = pzc.pkulchenko.serpent
		local success = pcall(function()
			local test_table = {x = 10, y = 20}
			local dumped = serpent.dump(test_table)
			assert_type(dumped, "string", "serpent.dump returns a string")
		end)
		
		if not success then
			table.insert(test_results, {
				name = "serpent dump works",
				passed = false
			})
		end
	end

	-- Test 10: Test yon_30log logger creation if available
	if pzc.yonaba.yon_30log then
		local log = pzc.yonaba.yon_30log
		local success = pcall(function()
			local logger = log.new("test_logger")
			assert_type(logger, "table", "yon_30log.new creates a logger table")
		end)
		
		if not success then
			table.insert(test_results, {
				name = "yon_30log can create loggers",
				passed = false
			})
		end
	end

	-- Print test results
	safeLog("\n=== Client Modules Test Results ===")
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
	run = run_tests
}
