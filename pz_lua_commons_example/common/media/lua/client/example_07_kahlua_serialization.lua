-- Example 7: Using Kahlua serialization functions
-- Kahlua provides serialize/deserialize for data persistence

local pz_commons = require("pz_lua_commons/client")

print("=== Kahlua Serialization ===")

-- Create complex data structure
local playerData = {
    name = "Hero",
    level = 25,
    experience = 1500,
    inventory = {
        "sword",
        "shield",
        "health_potion",
    },
    stats = {
        health = 100,
        mana = 50,
        stamina = 75,
    },
    position = {
        x = 100,
        y = 200,
        z = 0,
    },
}

-- Serialize to string
local serialized = serialize(playerData)
print("Serialized data (compact):")
print(serialized)

-- Serialize with formatting (multiline)
print("\nSerialized data (formatted):")
local formatted = serialize(playerData, true, "  ")
print(formatted)

-- Deserialize back to table
local deserialized = deserialize(serialized)
print("\nDeserialized successfully!")
print("Player name: " .. deserialized.name)
print("Player level: " .. deserialized.level)
print("First inventory item: " .. deserialized.inventory[1])
print("Health stat: " .. deserialized.stats.health)

-- Pretty print using pp()
print("\nPretty printed:")
print(pp(playerData))
