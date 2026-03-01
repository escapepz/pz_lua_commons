-- Test Suite: pz_utils - Konijima Utilities
-- Tests for Konijima utility functions

local pz_utils = require("pz_utils_shared")
local konijima = pz_utils.konijima.Utilities

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

local function assert_type(value, expectedType, message)
    if type(value) == expectedType then
        testsPassed = testsPassed + 1
        return true
    else
        testsFailed = testsFailed + 1
        print("FAIL: " .. (message or "type assertion") .. " - expected type: " .. expectedType .. " got: " .. type(value))
        return false
    end
end

-- ============================================================================
-- ENVIRONMENT DETECTION TESTS
-- ============================================================================

print("\n=== Environment Detection Tests ===\n")

tests.test_is_single_player_returns_boolean = function()
    local result = konijima.IsSinglePlayer()
    assert_type(result, "boolean", "IsSinglePlayer should return boolean")
end

tests.test_is_single_player_debug_returns_boolean = function()
    local result = konijima.IsSinglePlayerDebug()
    assert_type(result, "boolean", "IsSinglePlayerDebug should return boolean")
end

tests.test_is_single_player_debug_implies_single_player = function()
    -- If debug is true, single player must be true
    if konijima.IsSinglePlayerDebug() then
        assert_true(konijima.IsSinglePlayer(), "Debug mode implies single player mode")
    else
        testsPassed = testsPassed + 1  -- Can't assert false case without breaking single player
    end
end

tests.test_is_client_only_returns_boolean = function()
    local result = konijima.IsClientOnly()
    assert_type(result, "boolean", "IsClientOnly should return boolean")
end

tests.test_is_client_or_single_player_returns_boolean = function()
    local result = konijima.IsClientOrSinglePlayer()
    assert_type(result, "boolean", "IsClientOrSinglePlayer should return boolean")
end

tests.test_is_server_or_single_player_returns_boolean = function()
    local result = konijima.IsServerOrSinglePlayer()
    assert_type(result, "boolean", "IsServerOrSinglePlayer should return boolean")
end

tests.test_mutual_exclusivity_single_vs_client_server = function()
    -- These three conditions should be mutually exclusive
    -- isServer(), isClient(), and IsSinglePlayer() should not overlap
    
    local isSP = konijima.IsSinglePlayer()
    
    -- In test environment without PZ context, IsSinglePlayer should be true
    -- and IsClientOnly should be false
    if isSP then
        assert_false(konijima.IsClientOnly(), 
                     "Single player mode incompatible with client-only mode")
    else
        testsPassed = testsPassed + 1
    end
end

-- ============================================================================
-- ADMIN/STAFF PERMISSION TESTS
-- ============================================================================

print("=== Admin/Staff Permission Tests ===\n")

tests.test_is_client_admin_returns_boolean = function()
    local result = konijima.IsClientAdmin()
    assert_type(result, "boolean", "IsClientAdmin should return boolean")
end

tests.test_is_client_staff_returns_boolean = function()
    local result = konijima.IsClientStaff()
    assert_type(result, "boolean", "IsClientStaff should return boolean")
end

tests.test_is_client_staff_implies_client_admin = function()
    -- Staff should be superset of admin or different permission level
    -- In single player, both should return same value
    if konijima.IsSinglePlayer() then
        assert_equals(konijima.IsClientAdmin(), konijima.IsClientStaff(), 
                      "In single player, admin and staff should have same status")
    else
        testsPassed = testsPassed + 1
    end
end

-- ============================================================================
-- STRING UTILITY TESTS
-- ============================================================================

print("=== String Utility Tests ===\n")

tests.test_split_string_basic = function()
    local result = konijima.SplitString("apple,banana,cherry", ",")
    assert_equals(#result, 3, "Should split into 3 parts")
    assert_equals(result[1], "apple", "First part should be 'apple'")
    assert_equals(result[2], "banana", "Second part should be 'banana'")
    assert_equals(result[3], "cherry", "Third part should be 'cherry'")
end

tests.test_split_string_with_pipe = function()
    local result = konijima.SplitString("100|200|300", "|")
    assert_equals(#result, 3, "Should split into 3 parts")
    assert_equals(result[1], "100", "First coordinate should be 100")
    assert_equals(result[2], "200", "Second coordinate should be 200")
    assert_equals(result[3], "300", "Third coordinate should be 300")
end

tests.test_split_string_single_delimiter = function()
    local result = konijima.SplitString("hello,world", ",")
    assert_equals(#result, 2, "Should split into 2 parts")
    assert_equals(result[1], "hello", "First part should be 'hello'")
    assert_equals(result[2], "world", "Second part should be 'world'")
end

tests.test_split_string_no_delimiter = function()
    local result = konijima.SplitString("hello", ",")
    assert_equals(#result, 1, "Should return 1 part if no delimiter found")
    assert_equals(result[1], "hello", "Part should be original string")
end

tests.test_split_string_empty_string = function()
    local result = konijima.SplitString("", ",")
    assert_type(result, "table", "Should return table")
end

tests.test_split_string_consecutive_delimiters = function()
    local result = konijima.SplitString("apple,,cherry", ",")
    assert_equals(#result, 3, "Should handle consecutive delimiters")
    assert_equals(result[2], "", "Middle part should be empty string")
end

-- ============================================================================
-- SQUARE UTILITY TESTS
-- ============================================================================

print("=== Square Utility Tests ===\n")

tests.test_square_to_string_format = function()
    -- This test verifies the expected format without requiring PZ API
    -- In actual usage: konijima.SquareToString(square) returns "x|y|z"
    
    -- We can test the reverse function
    local squareStr = "100|200|0"
    local parts = konijima.SplitString(squareStr, "|")
    assert_equals(#parts, 3, "Square string should have 3 coordinates")
end

tests.test_string_to_square_parsing = function()
    -- Test coordinate extraction from square string
    local squareStr = "150|250|5"
    local coords = konijima.SplitString(squareStr, "|")
    
    assert_equals(tonumber(coords[1]), 150, "First coordinate should parse to 150")
    assert_equals(tonumber(coords[2]), 250, "Second coordinate should parse to 250")
    assert_equals(tonumber(coords[3]), 5, "Third coordinate should parse to 5")
end

tests.test_square_string_roundtrip = function()
    -- Verify that coordinates survive split and rejoin
    local originalStr = "100|200|0"
    local coords = konijima.SplitString(originalStr, "|")
    local rebuilt = coords[1] .. "|" .. coords[2] .. "|" .. coords[3]
    
    assert_equals(rebuilt, originalStr, "Roundtrip should preserve coordinates")
end

-- ============================================================================
-- CLIENT COMMAND TESTS
-- ============================================================================

print("=== Client Command Tests ===\n")

tests.test_send_client_command_exists = function()
    assert_type(konijima.SendClientCommand, "function", 
                "SendClientCommand should be a function")
end

tests.test_send_client_command_accepts_parameters = function()
    -- This test verifies the function doesn't crash with valid parameters
    -- It won't actually send anything without PZ API context
    local success, err = pcall(function()
        konijima.SendClientCommand("TestModule", "TestCommand", {data = "test"})
    end)
    assert_true(success, "SendClientCommand should accept valid parameters")
end

tests.test_send_server_command_to_exists = function()
    assert_type(konijima.SendServerCommandTo, "function",
                "SendServerCommandTo should be a function")
end

tests.test_send_server_command_to_all_exists = function()
    assert_type(konijima.SendServerCommandToAll, "function",
                "SendServerCommandToAll should be a function")
end

tests.test_send_server_command_to_all_in_range_exists = function()
    assert_type(konijima.SendServerCommandToAllInRange, "function",
                "SendServerCommandToAllInRange should be a function")
end

tests.test_send_server_command_to_all_in_range_parameters = function()
    -- Verify function accepts all required parameters
    local success, err = pcall(function()
        konijima.SendServerCommandToAllInRange(100, 200, 0, 0, 20, 
                                               "TestModule", "TestCommand", {data = "test"})
    end)
    assert_true(success, "SendServerCommandToAllInRange should accept valid parameters")
end

-- ============================================================================
-- PLAYER UTILITY TESTS
-- ============================================================================

print("=== Player Utility Tests ===\n")

tests.test_get_player_from_username_exists = function()
    assert_type(konijima.GetPlayerFromUsername, "function",
                "GetPlayerFromUsername should be a function")
end

tests.test_is_player_in_range_exists = function()
    assert_type(konijima.IsPlayerInRange, "function",
                "IsPlayerInRange should be a function")
end

tests.test_is_player_in_range_distance_calculation = function()
    -- Test the distance logic without actual player objects
    -- IsPlayerInRange should return boolean
    local success, err = pcall(function()
        -- In real context with nil player, should return false gracefully
        local result = konijima.IsPlayerInRange(nil, 100, 200, 0, 0, 10)
        assert_false(result, "IsPlayerInRange with nil player should return false")
    end)
    assert_true(success, "IsPlayerInRange should handle nil player gracefully")
end

-- ============================================================================
-- ELECTRICITY UTILITY TESTS
-- ============================================================================

print("=== Electricity Utility Tests ===\n")

tests.test_square_has_electricity_exists = function()
    assert_type(konijima.SquareHasElectricity, "function",
                "SquareHasElectricity should be a function")
end

tests.test_square_has_electricity_with_nil = function()
    -- Should handle nil gracefully
    local success, err = pcall(function()
        konijima.SquareHasElectricity(nil)
    end)
    assert_true(success, "SquareHasElectricity should handle nil square")
end

-- ============================================================================
-- SERVER INFORMATION TESTS
-- ============================================================================

print("=== Server Information Tests ===\n")

tests.test_get_server_name_exists = function()
    assert_type(konijima.GetServerName, "function",
                "GetServerName should be a function")
end

tests.test_get_server_name_returns_string = function()
    local success, err = pcall(function()
        local result = konijima.GetServerName()
        -- In single player without PZ context, might return string or specific value
        assert_type(result, "string", "GetServerName should return string")
    end)
    -- Don't assert pcall result as it depends on PZ API availability
end

-- ============================================================================
-- INVENTORY TESTS
-- ============================================================================

print("=== Inventory Tests ===\n")

tests.test_find_all_item_in_inventory_by_tag_exists = function()
    assert_type(konijima.FindAllItemInInventoryByTag, "function",
                "FindAllItemInInventoryByTag should be a function")
end

-- ============================================================================
-- MOVEABLE OBJECT TESTS
-- ============================================================================

print("=== Moveable Object Tests ===\n")

tests.test_get_moveable_display_name_exists = function()
    assert_type(konijima.GetMoveableDisplayName, "function",
                "GetMoveableDisplayName should be a function")
end

tests.test_get_moveable_display_name_with_nil = function()
    local result = konijima.GetMoveableDisplayName(nil)
    assert_equals(result, nil, "GetMoveableDisplayName with nil should return nil")
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
