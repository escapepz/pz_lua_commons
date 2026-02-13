-- Example 6: Using Kahlua string and table extensions
-- Kahlua adds useful methods to Lua 5.1 string and table types

local pz_commons = require("pz_lua_commons/client")

print("=== Kahlua String Extensions ===")

-- string.trim() - Remove leading and trailing whitespace
local text = "  Hello World  "
print("Original: '" .. text .. "'")
print("Trimmed: '" .. string.trim(text) .. "'")

-- string.split() - Split string by pattern
local csv = "apple,banana,orange,grape"
local fruits = string.split(csv, ",")
print("\nSplit CSV by comma:")
for i, fruit in ipairs(fruits) do
    print("  " .. i .. ": " .. fruit)
end

-- string.contains() - Check if string contains substring
local message = "The quick brown fox jumps"
print("\nChecking string contains:")
print("Contains 'brown': " .. tostring(string.contains(message, "brown")))
print("Contains 'lazy': " .. tostring(string.contains(message, "lazy")))

print("\n=== Kahlua Table Extensions ===")

-- table.isempty() - Check if table is empty
local emptyTable = {}
local filledTable = {a = 1, b = 2}
print("Is empty table empty? " .. tostring(table.isempty(emptyTable)))
print("Is filled table empty? " .. tostring(table.isempty(filledTable)))

-- table.wipe() - Clear all contents from a table
local inventory = {sword = 1, shield = 1, potion = 5}
print("\nBefore wipe: " .. table.concat({inventory.sword, inventory.shield, inventory.potion}, ", "))
table.wipe(inventory)
print("After wipe (empty): " .. tostring(table.isempty(inventory)))

-- table.newarray() - Create array with initial values
local items = table.newarray("stone", "wood", "iron")
print("\nNewArray contents:")
for i, item in ipairs(items) do
    print("  [" .. i .. "] = " .. item)
end
