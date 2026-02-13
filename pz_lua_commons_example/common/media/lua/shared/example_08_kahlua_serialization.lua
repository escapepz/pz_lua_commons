-- Example 8: Using Kahlua serialization in shared context
-- Kahlua provides serialize/deserialize for cross-client/server data transfer

local pz_commons = require("pz_lua_commons/shared")

print("=== Kahlua Serialization (Shared) ===")

-- Create game world data
local worldData = {
    version = "1.0.0",
    seed = 42,
    difficulty = "normal",
    worldTime = 1440,
    buildings = {
        "farm_001",
        "house_002",
        "warehouse_003"
    }
}

-- Serialize to compact format (good for network transmission)
local compactSerialized = serialize(worldData)
print("Compact serialized (network transmission):")
print(compactSerialized)

-- Serialize with formatting (good for storage/debugging)
print("\nFormatted serialized (storage):")
local formatted = serialize(worldData, true, "  ")
print(formatted)

-- Deserialize and verify
local restored = deserialize(compactSerialized)
print("\nDeserialized successfully!")
print("World version: " .. restored.version)
print("World seed: " .. restored.seed)
print("World difficulty: " .. restored.difficulty)
print("Building count: " .. table.getn(restored.buildings))

-- Practical: Player state save/load
local playerState = {
    id = "player_123",
    name = "Hero",
    level = 25,
    position = {x = 100, y = 200, z = 0},
    inventory = {
        {itemId = "weapon_axe", quantity = 1},
        {itemId = "ammo_9mm", quantity = 45},
        {itemId = "food_canned", quantity = 12}
    },
    stats = {
        health = 100,
        fatigue = 50,
        hunger = 30,
        stress = 10
    }
}

-- Save player state
local savedState = serialize(playerState, true, "  ")
print("\n=== Player State Serialization ===")
print(savedState)

-- Load and verify
local loadedState = deserialize(serialize(playerState))
print("\nPlayer loaded:")
print("  Name: " .. loadedState.name)
print("  Level: " .. loadedState.level)
print("  Position: (" .. loadedState.position.x .. ", " .. loadedState.position.y .. ")")
print("  Inventory items: " .. table.getn(loadedState.inventory))
print("  Health: " .. loadedState.stats.health)

-- Pretty printing
print("\n=== Pretty Print ===")
print(pp(worldData))
