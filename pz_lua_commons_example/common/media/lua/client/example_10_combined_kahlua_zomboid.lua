-- Example 10: Combined Kahlua and Zomboid API usage
-- Shows practical integration of utilities and game API

local pz_commons = require("pz_lua_commons/client")

print("=== Combined Kahlua + Zomboid API ===")

-- Game session data using serialization
local sessionData = {
    playerId = "Player_" .. tostring(ZombRand(10000)),
    sessionStart = "2024-02-07",
    settings = {
        difficulty = "normal",
        pvp = true,
        sandbox = false
    },
    stats = {
        zombiesKilled = ZombRand(100),
        distanceTraveled = ZombRandFloat(0, 50),
        itemsCrafted = ZombRand(50)
    }
}

-- Serialize session data
local sessionString = serialize(sessionData, true, "  ")
print("Session Data:")
print(sessionString)

-- Use string operations on gameplay strings
local playerLog = "Player_killed_zombie, Player_crafted_item, Player_entered_building"
local actions = string.split(playerLog, ", ")
print("\nPlayer Actions:")
for i, action in ipairs(actions) do
    if string.contains(action, "killed") then
        print("  Combat: " .. action)
    elseif string.contains(action, "crafted") then
        print("  Crafting: " .. action)
    else
        print("  Movement: " .. action)
    end
end

-- Create a simple game settings manager
local GameSettings = {
    data = {
        soundVolume = 80,
        graphicsQuality = "high",
        difficultyLevel = "normal"
    }
}

function GameSettings:save()
    local settingsStr = serialize(self.data, true, "  ")
    print("\nSaving settings:")
    print(settingsStr)
    return settingsStr
end

function GameSettings:load(settingsStr)
    self.data = deserialize(settingsStr)
    print("Settings loaded successfully!")
end

function GameSettings:printSettings()
    print("\nCurrent Settings:")
    for key, value in pairs(self.data) do
        print("  " .. key .. ": " .. tostring(value))
    end
end

-- Use the settings manager
GameSettings:printSettings()
local saved = GameSettings:save()

-- Demonstrate table operations
print("\n=== Table Operations ===")
local inventory = {sword = 1, shield = 1, potion = 5}
print("Initial inventory (size " .. table.getn(inventory) .. "):")
for item, count in pairs(inventory) do
    print("  " .. item .. " x" .. count)
end

-- Add items
inventory.axe = 1
inventory.bow = 1
print("\nAfter adding items:")
for item, count in pairs(inventory) do
    print("  " .. item .. " x" .. count)
end

-- Check if inventory is empty
print("\nInventory empty? " .. tostring(table.isempty(inventory)))

-- Clear inventory
table.wipe(inventory)
print("After wipe - Inventory empty? " .. tostring(table.isempty(inventory)))

print("\n=== Debug Information ===")
-- Get debug info
print("Kahlua debug stack trace:")
print(pp({frame = "game_loop", tick = ZombRand(1000), players = ZombRand(4)}))
