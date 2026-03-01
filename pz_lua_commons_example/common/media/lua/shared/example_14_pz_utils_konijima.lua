-- Example 14: pz_utils - Konijima Utilities
-- Demonstrates convenience utilities for mod development in Project Zomboid

local pz_utils = require("pz_utils_shared")
local konijima = pz_utils.konijima.Utilities

-- Note: Some functions require Project Zomboid API context (isServer(), isClient(), etc.)
-- This example demonstrates API usage - some functions will only work in actual PZ game context

print("\n--- Konijima Utilities Examples ---")

-- ============================================================================
-- 1. ENVIRONMENT DETECTION
-- ============================================================================

print("\n--- Environment Detection ---")

-- Check game environment
local isSinglePlayer = konijima.IsSinglePlayer()
print("Is single player: " .. tostring(isSinglePlayer))

local isSPDebug = konijima.IsSinglePlayerDebug()
print("Is single player with debug: " .. tostring(isSPDebug))

local isClientOnly = konijima.IsClientOnly()
print("Is client only: " .. tostring(isClientOnly))

local isClientOrSP = konijima.IsClientOrSinglePlayer()
print("Is client or single player: " .. tostring(isClientOrSP))

local isServerOrSP = konijima.IsServerOrSinglePlayer()
print("Is server or single player: " .. tostring(isServerOrSP))

-- ============================================================================
-- 2. ADMIN/STAFF CHECKS
-- ============================================================================

print("\n--- Admin/Staff Permission Checks ---")

-- Client-side admin check (local player)
local isClientAdmin = konijima.IsClientAdmin()
print("Is client admin: " .. tostring(isClientAdmin))

-- Client-side staff check (admin or moderator)
local isClientStaff = konijima.IsClientStaff()
print("Is client staff: " .. tostring(isClientStaff))

-- Server-side admin check by player object or username
-- konijima.IsPlayerAdmin(playerObj) -- requires IsoPlayer object
-- konijima.IsPlayerAdmin("PlayerName") -- can also use username string

-- Server-side staff check (admin or moderator)
-- konijima.IsPlayerStaff(playerObj)
-- konijima.IsPlayerStaff("PlayerName")

-- ============================================================================
-- 3. CLIENT COMMANDS (for mods that use networking)
-- ============================================================================

print("\n--- Client-Server Communication ---")

-- Send a command from client to server
-- Usage: konijima.SendClientCommand(module, command, data)
-- Example:
-- konijima.SendClientCommand("MyMod", "RequestInfo", {target = "player1"})

-- Send a command from server to a specific client
-- Usage: konijima.SendServerCommandTo(targetPlayer, module, command, data)
-- Example (server only):
-- konijima.SendServerCommandTo(playerObj, "MyMod", "ReceiveInfo", {health = 100})

-- Send a command from server to all clients
-- Usage: konijima.SendServerCommandToAll(module, command, data)
-- Example (server only):
-- konijima.SendServerCommandToAll("MyMod", "GlobalAnnouncement", {message = "Server event"})

-- Send a command from server to clients in range
-- Usage: konijima.SendServerCommandToAllInRange(x, y, z, minDist, maxDist, module, command, data)
-- Example (server only):
-- konijima.SendServerCommandToAllInRange(100, 200, 0, 0, 20, "MyMod", "NearbyEvent", {})

print("Command functions available (use in actual game context)")

-- ============================================================================
-- 4. PLAYER UTILITIES
-- ============================================================================

print("\n--- Player Utilities ---")

-- Get player from username (only works with Project Zomboid API)
-- local player = konijima.GetPlayerFromUsername("PlayerName")

-- Check if a player is in range
-- Usage: konijima.IsPlayerInRange(playerObj, x, y, z, minDistance, maxDistance)
-- Example:
-- local inRange = konijima.IsPlayerInRange(playerObj, 100, 200, 0, 0, 10)
-- print("Player in range: " .. tostring(inRange))

print("Player functions available (use in actual game context)")

-- ============================================================================
-- 5. ELECTRICITY CHECK (Sandbox Variables)
-- ============================================================================

print("\n--- Electricity Utilities ---")

-- Check if a square has electricity
-- Usage: konijima.SquareHasElectricity(square)
-- This takes into account:
--   - Exterior generators (if AllowExteriorGenerator is true)
--   - Electricity shutdown modifier
-- Example:
-- local square = getCell():getGridSquare(100, 200, 0)
-- local hasPower = konijima.SquareHasElectricity(square)
-- print("Square has electricity: " .. tostring(hasPower))

print("Electricity check available (use in actual game context)")

-- ============================================================================
-- 6. SERVER NAME UTILITY
-- ============================================================================

print("\n--- Server Information ---")

-- Get server name or save file name
-- local serverName = konijima.GetServerName()
-- Returns the public server name or single-player save name
-- print("Server name: " .. serverName)

print("Server name function available (use in actual game context)")

-- ============================================================================
-- 7. STRING UTILITIES
-- ============================================================================

print("\n--- String Utilities ---")

-- Split a string by delimiter
local text = "apple,banana,orange"
local fruits = konijima.SplitString(text, ",")
print("Split string result:")
for i, fruit in ipairs(fruits) do
	print("  " .. i .. ": " .. fruit)
end

-- Split with different delimiter
local coordinates = "100|200|0"
local coords = konijima.SplitString(coordinates, "|")
print("Split coordinates: " .. coords[1] .. ", " .. coords[2] .. ", " .. coords[3])

-- ============================================================================
-- 8. SQUARE/GRID UTILITIES
-- ============================================================================

print("\n--- Grid Square Utilities ---")

-- Convert square to string representation
-- Usage: konijima.SquareToString(square)
-- local square = getCell():getGridSquare(100, 200, 0)
-- local squareStr = konijima.SquareToString(square)
-- print("Square string: " .. squareStr) -- Output: "100|200|0"

-- Convert string back to square object
-- Usage: konijima.StringToSquare(string)
-- local reconstructedSquare = konijima.StringToSquare("100|200|0")

print("Square conversion functions available (use in actual game context)")

-- ============================================================================
-- 9. INVENTORY UTILITIES
-- ============================================================================

print("\n--- Inventory Search ---")

-- Find all items in inventory by tag
-- Usage: konijima.FindAllItemInInventoryByTag(inventory, tag)
-- Example:
-- local inventory = playerObj:getInventory()
-- local food = konijima.FindAllItemInInventoryByTag(inventory, "Food")
-- print("Found " .. food:size() .. " food items")

print("Inventory search available (use in actual game context)")

-- ============================================================================
-- 10. MOVEABLE OBJECT UTILITIES
-- ============================================================================

print("\n--- Moveable Object Utilities ---")

-- Get display name of a moveable object
-- Usage: konijima.GetMoveableDisplayName(obj)
-- Returns translated display name with group and custom name if available
-- Example:
-- local objName = konijima.GetMoveableDisplayName(someObject)
-- print("Object display name: " .. (objName or "Unknown"))

print("Moveable object utilities available (use in actual game context)")

-- ============================================================================
-- 11. PRACTICAL EXAMPLE - Permission-Based Action
-- ============================================================================

print("\n--- Practical Example: Permission-Based Action ---")

local function executeAdminCommand(commandName, targetPlayer)
	-- Check if client is admin (single player or online admin)
	if konijima.IsClientAdmin() then
		print("Admin executing command: " .. commandName)
		-- Send command to server
		konijima.SendClientCommand("MyMod", commandName, { target = targetPlayer })
	else
		print("Permission denied: Admin only command")
	end
end

-- In actual game, this would check real admin status
executeAdminCommand("KickPlayer", "PlayerName")

-- ============================================================================
-- 12. PRACTICAL EXAMPLE - Distance-Based Notification
-- ============================================================================

print("\n--- Practical Example: Distance-Based Event ---")

local function notifyPlayersInRange(eventX, eventY, eventZ, maxRange, message)
	-- Server would send command only to players in range
	if konijima.IsServerOrSinglePlayer() then
		-- In real context, would iterate through online players
		print("Would notify players within " .. maxRange .. " blocks")
		-- konijima.SendServerCommandToAllInRange(eventX, eventY, eventZ, 0, maxRange,
		--                                         "MyMod", "Notification", {msg = message})
	end
end

notifyPlayersInRange(100, 200, 0, 20, "Event happening nearby!")

print("\n--- All Konijima Utilities examples completed ---")
