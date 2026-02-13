-- Test Suite: pz_utils Konijima Utilities (Migrated from pz_lua_commons_test)
-- Tests for Konijima environment, admin/staff, string utilities, and more

local mock_pz = require("TEST_SUITE/tests/mock_pz")
mock_pz.setupGlobalEnvironment()

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

function TestRunner.assert_type(value, expected_type, message)
	if type(value) == expected_type then
		TestRunner.passed = TestRunner.passed + 1
		return true
	else
		TestRunner.failed = TestRunner.failed + 1
		print("✗ " .. (message or "type assertion"))
		print("  Expected type: " .. expected_type)
		print("  Got type: " .. type(value))
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
	print("KONIJIMA UTILITIES TEST SUITE")
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
-- ENVIRONMENT DETECTION TESTS
-- ============================================================================

TestRunner.register("Konijima: IsSinglePlayer returns boolean", function()
	local result = mock_pz.konijima.IsSinglePlayer()
	TestRunner.assert_type(result, "boolean", "IsSinglePlayer should return boolean")
end)

TestRunner.register("Konijima: IsSinglePlayerDebug returns boolean", function()
	local result = mock_pz.konijima.IsSinglePlayerDebug()
	TestRunner.assert_type(result, "boolean", "IsSinglePlayerDebug should return boolean")
end)

TestRunner.register("Konijima: IsClientOnly returns boolean", function()
	local result = mock_pz.konijima.IsClientOnly()
	TestRunner.assert_type(result, "boolean", "IsClientOnly should return boolean")
end)

TestRunner.register("Konijima: IsClientOrSinglePlayer returns boolean", function()
	local result = mock_pz.konijima.IsClientOrSinglePlayer()
	TestRunner.assert_type(result, "boolean", "IsClientOrSinglePlayer should return boolean")
end)

TestRunner.register("Konijima: IsServerOrSinglePlayer returns boolean", function()
	local result = mock_pz.konijima.IsServerOrSinglePlayer()
	TestRunner.assert_type(result, "boolean", "IsServerOrSinglePlayer should return boolean")
end)

TestRunner.register("Konijima: Single player mode is true by default", function()
	TestRunner.assert_true(mock_pz.konijima.IsSinglePlayer(), "Should be single player in test mode")
end)

-- ============================================================================
-- ADMIN/STAFF PERMISSION TESTS (NOW FULLY MOCKABLE)
-- ============================================================================

TestRunner.register("Konijima: IsClientAdmin returns boolean", function()
	local result = mock_pz.konijima.IsClientAdmin()
	TestRunner.assert_type(result, "boolean", "IsClientAdmin should return boolean")
end)

TestRunner.register("Konijima: IsClientStaff returns boolean", function()
	local result = mock_pz.konijima.IsClientStaff()
	TestRunner.assert_type(result, "boolean", "IsClientStaff should return boolean")
end)

TestRunner.register("Konijima: Client admin status defaults to false", function()
	TestRunner.assert_false(mock_pz.konijima.IsClientAdmin(), "Default admin status should be false")
end)

TestRunner.register("Konijima: Client staff status defaults to false", function()
	TestRunner.assert_false(mock_pz.konijima.IsClientStaff(), "Default staff status should be false")
end)

TestRunner.register("Konijima: Can set client admin status", function()
	mock_pz.SetClientAdmin(true)
	TestRunner.assert_true(mock_pz.konijima.IsClientAdmin(), "Admin status should be true after setting")
	mock_pz.SetClientAdmin(false)
	TestRunner.assert_false(mock_pz.konijima.IsClientAdmin(), "Admin status should be false after unsetting")
end)

TestRunner.register("Konijima: Can set client staff status", function()
	mock_pz.SetClientStaff(true)
	TestRunner.assert_true(mock_pz.konijima.IsClientStaff(), "Staff status should be true after setting")
	mock_pz.SetClientStaff(false)
	TestRunner.assert_false(mock_pz.konijima.IsClientStaff(), "Staff status should be false after unsetting")
end)

TestRunner.register("Konijima: Can add/remove admins from list", function()
	mock_pz.AddAdmin("admin_user")
	TestRunner.assert_true(mock_pz.IsUserAdmin("admin_user"), "User should be in admin list after adding")

	mock_pz.RemoveAdmin("admin_user")
	TestRunner.assert_false(mock_pz.IsUserAdmin("admin_user"), "User should not be in admin list after removing")
end)

TestRunner.register("Konijima: Can add/remove staff from list", function()
	mock_pz.AddStaff("staff_user")
	TestRunner.assert_true(mock_pz.IsUserStaff("staff_user"), "User should be in staff list after adding")

	mock_pz.RemoveStaff("staff_user")
	TestRunner.assert_false(mock_pz.IsUserStaff("staff_user"), "User should not be in staff list after removing")
end)

TestRunner.register("Konijima: GetAdminList returns table", function()
	mock_pz.AddAdmin("test_admin_1")
	mock_pz.AddAdmin("test_admin_2")

	local admin_list = mock_pz.GetAdminList()
	TestRunner.assert_type(admin_list, "table", "GetAdminList should return table")

	-- Count entries
	local count = 0
	for _ in pairs(admin_list) do
		count = count + 1
	end
	TestRunner.assert_true(count >= 2, "Admin list should contain at least 2 admins")

	-- Clean up
	mock_pz.RemoveAdmin("test_admin_1")
	mock_pz.RemoveAdmin("test_admin_2")
end)

TestRunner.register("Konijima: GetStaffList returns table", function()
	mock_pz.AddStaff("test_staff_1")
	local staff_list = mock_pz.GetStaffList()
	TestRunner.assert_type(staff_list, "table", "GetStaffList should return table")
	mock_pz.RemoveStaff("test_staff_1")
end)

-- ============================================================================
-- STRING UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: SplitString basic comma split", function()
	local result = mock_pz.konijima.SplitString("apple,banana,cherry", ",")
	TestRunner.assert_equals(#result, 3, "Should split into 3 parts")
	TestRunner.assert_equals(result[1], "apple", "First part should be 'apple'")
	TestRunner.assert_equals(result[2], "banana", "Second part should be 'banana'")
	TestRunner.assert_equals(result[3], "cherry", "Third part should be 'cherry'")
end)

TestRunner.register("Konijima: SplitString with pipe delimiter", function()
	local result = mock_pz.konijima.SplitString("100|200|300", "|")
	TestRunner.assert_equals(#result, 3, "Should split into 3 parts")
	TestRunner.assert_equals(result[1], "100", "First coordinate should be 100")
	TestRunner.assert_equals(result[2], "200", "Second coordinate should be 200")
	TestRunner.assert_equals(result[3], "300", "Third coordinate should be 300")
end)

TestRunner.register("Konijima: SplitString handles single delimiter", function()
	local result = mock_pz.konijima.SplitString("hello,world", ",")
	TestRunner.assert_equals(#result, 2, "Should split into 2 parts")
	TestRunner.assert_equals(result[1], "hello", "First part should be 'hello'")
	TestRunner.assert_equals(result[2], "world", "Second part should be 'world'")
end)

TestRunner.register("Konijima: SplitString without delimiter", function()
	local result = mock_pz.konijima.SplitString("hello", ",")
	TestRunner.assert_equals(#result, 1, "Should return 1 part")
	TestRunner.assert_equals(result[1], "hello", "Part should be original string")
end)

TestRunner.register("Konijima: SplitString empty string returns empty table", function()
	local result = mock_pz.konijima.SplitString("", ",")
	TestRunner.assert_type(result, "table", "Should return table for empty string")
end)

-- ============================================================================
-- SQUARE UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: SquareToString formats coordinates", function()
	local square = { x = 100, y = 200, z = 0 }
	local result = mock_pz.konijima.SquareToString(square)
	TestRunner.assert_equals(result, "100|200|0", "Should format as x|y|z")
end)

TestRunner.register("Konijima: StringToSquare parses coordinates", function()
	local result = mock_pz.konijima.StringToSquare("150|250|5")
	TestRunner.assert_type(result, "table", "Should return table")
	TestRunner.assert_equals(result.x, 150, "X coordinate should be 150")
	TestRunner.assert_equals(result.y, 250, "Y coordinate should be 250")
	TestRunner.assert_equals(result.z, 5, "Z coordinate should be 5")
end)

TestRunner.register("Konijima: Square roundtrip conversion", function()
	local original = "100|200|0"
	local square = mock_pz.konijima.StringToSquare(original)
	local result = mock_pz.konijima.SquareToString(square)
	TestRunner.assert_equals(result, original, "Roundtrip should preserve coordinates")
end)

-- ============================================================================
-- NETWORK COMMAND TESTS
-- ============================================================================

TestRunner.register("Konijima: SendClientCommand exists and is callable", function()
	TestRunner.assert_type(mock_pz.konijima.SendClientCommand, "function", "SendClientCommand should be a function")
end)

TestRunner.register("Konijima: SendClientCommand accepts parameters", function()
	local success, err = pcall(function()
		mock_pz.konijima.SendClientCommand("TestModule", "TestCommand", { data = "test" })
	end)
	TestRunner.assert_true(success, "SendClientCommand should handle parameters without error")
end)

TestRunner.register("Konijima: SendServerCommandTo exists and is callable", function()
	TestRunner.assert_type(mock_pz.konijima.SendServerCommandTo, "function", "SendServerCommandTo should be a function")
end)

TestRunner.register("Konijima: SendServerCommandToAll exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.SendServerCommandToAll,
		"function",
		"SendServerCommandToAll should be a function"
	)
end)

TestRunner.register("Konijima: SendServerCommandToAllInRange exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.SendServerCommandToAllInRange,
		"function",
		"SendServerCommandToAllInRange should be a function"
	)
end)

TestRunner.register("Konijima: SendServerCommandToAllInRange accepts parameters", function()
	local success, err = pcall(function()
		mock_pz.konijima.SendServerCommandToAllInRange(
			100,
			200,
			0,
			0,
			20,
			"TestModule",
			"TestCommand",
			{ data = "test" }
		)
	end)
	TestRunner.assert_true(success, "SendServerCommandToAllInRange should accept valid parameters")
end)

-- ============================================================================
-- PLAYER UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: GetPlayerFromUsername exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.GetPlayerFromUsername,
		"function",
		"GetPlayerFromUsername should be a function"
	)
end)

TestRunner.register("Konijima: IsPlayerInRange exists and is callable", function()
	TestRunner.assert_type(mock_pz.konijima.IsPlayerInRange, "function", "IsPlayerInRange should be a function")
end)

TestRunner.register("Konijima: IsPlayerInRange returns false for nil player", function()
	local result = mock_pz.konijima.IsPlayerInRange(nil, 100, 200, 0, 0, 10)
	TestRunner.assert_false(result, "IsPlayerInRange with nil player should return false")
end)

-- ============================================================================
-- ELECTRICITY UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: SquareHasElectricity exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.SquareHasElectricity,
		"function",
		"SquareHasElectricity should be a function"
	)
end)

TestRunner.register("Konijima: SquareHasElectricity handles nil gracefully", function()
	local success, err = pcall(function()
		mock_pz.konijima.SquareHasElectricity(nil)
	end)
	TestRunner.assert_true(success, "SquareHasElectricity should handle nil without error")
end)

-- ============================================================================
-- SERVER INFORMATION TESTS
-- ============================================================================

TestRunner.register("Konijima: GetServerName exists and is callable", function()
	TestRunner.assert_type(mock_pz.konijima.GetServerName, "function", "GetServerName should be a function")
end)

TestRunner.register("Konijima: GetServerName returns string", function()
	local result = mock_pz.konijima.GetServerName()
	TestRunner.assert_type(result, "string", "GetServerName should return string")
end)

-- ============================================================================
-- INVENTORY UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: FindAllItemInInventoryByTag exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.FindAllItemInInventoryByTag,
		"function",
		"FindAllItemInInventoryByTag should be a function"
	)
end)

TestRunner.register("Konijima: FindAllItemInInventoryByTag returns table", function()
	local result = mock_pz.konijima.FindAllItemInInventoryByTag(nil, "test_tag")
	TestRunner.assert_type(result, "table", "FindAllItemInInventoryByTag should return table")
end)

-- ============================================================================
-- MOVEABLE OBJECT UTILITY TESTS
-- ============================================================================

TestRunner.register("Konijima: GetMoveableDisplayName exists and is callable", function()
	TestRunner.assert_type(
		mock_pz.konijima.GetMoveableDisplayName,
		"function",
		"GetMoveableDisplayName should be a function"
	)
end)

TestRunner.register("Konijima: GetMoveableDisplayName returns nil for nil input", function()
	local result = mock_pz.konijima.GetMoveableDisplayName(nil)
	TestRunner.assert_equals(result, nil, "GetMoveableDisplayName with nil should return nil")
end)

TestRunner.register("Konijima: GetMoveableDisplayName returns name for valid object", function()
	local obj = { displayName = "Test Object" }
	local result = mock_pz.konijima.GetMoveableDisplayName(obj)
	TestRunner.assert_equals(result, "Test Object", "Should return displayName from object")
end)

-- ============================================================================
-- RUN TESTS
-- ============================================================================

local results = TestRunner.run_all()

return {
	run = TestRunner.run_all,
	results = results
}
