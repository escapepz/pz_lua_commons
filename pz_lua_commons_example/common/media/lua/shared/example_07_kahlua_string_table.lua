-- Example 7: Using Kahlua string and table extensions in shared context
-- Kahlua adds useful methods to Lua 5.1 string and table types

local pz_commons = require("pz_lua_commons/shared")

print("=== Kahlua String Extensions (Shared) ===")

-- string.trim() - Remove leading and trailing whitespace
local text = "  Hello World  "
print("Original: '" .. text .. "'")
print("Trimmed: '" .. string.trim(text) .. "'")

-- string.split() - Split string by pattern
local itemList = "sword,shield,potion,bread,water"
local items = string.split(itemList, ",")
print("\nSplit item list by comma:")
for i, item in ipairs(items) do
    print("  " .. i .. ": " .. string.trim(item))
end

-- string.contains() - Check if string contains substring
local playerCommand = "give_player_axe_and_food"
print("\nChecking string contains:")
print("Contains 'player': " .. tostring(string.contains(playerCommand, "player")))
print("Contains 'health': " .. tostring(string.contains(playerCommand, "health")))

-- Practical: Parse command parameters
local commandStr = "set_difficulty=normal, enable_pvp=true, max_players=4"
local params = string.split(commandStr, ", ")
print("\nParsed command parameters:")
for i, param in ipairs(params) do
    print("  [" .. i .. "] " .. string.trim(param))
end

print("\n=== Kahlua Table Extensions (Shared) ===")

-- table.isempty() - Check if table is empty
local emptyInventory = {}
local filledInventory = { axe = 1, bow = 3, arrows = 20 }
print("Is empty inventory empty? " .. tostring(table.isempty(emptyInventory)))
print("Is filled inventory empty? " .. tostring(table.isempty(filledInventory)))

-- table.wipe() - Clear all contents from a table
local playerCache = { player1 = "Alice", player2 = "Bob", player3 = "Charlie" }
print("\nBefore wipe: " .. table.getn(playerCache) .. " entries")
table.wipe(playerCache)
print(
    "After wipe: "
        .. table.getn(playerCache)
        .. " entries (empty: "
        .. tostring(table.isempty(playerCache))
        .. ")"
)

-- table.newarray() - Create array with initial values
local difficulties = table.newarray("easy", "normal", "hard", "nightmare")
print("\nDifficulty levels:")
for i, difficulty in ipairs(difficulties) do
    print("  [" .. i .. "] = " .. difficulty)
end

-- Practical: Safe table iteration
local gameConfig = {
    maxPlayers = 4,
    dayLength = 1440,
    respawnTime = 60,
    pvp = true,
}

print("\nGame configuration:")
for key, value in pairs(gameConfig) do
    print("  " .. key .. " = " .. tostring(value))
end
