-- Example 9: Using Project Zomboid API - Player interactions
-- Demonstrates player-related functions in Zomboid

local pz_commons = require("pz_lua_commons/client")

print("=== Project Zomboid Player API Example ===")

-- Safe wrapper for player operations
local function safeGetPlayer()
    local success, player = pcall(function()
        return getPlayer()
    end)
    
    if success and player then
        return player
    else
        print("Could not retrieve player (may not be in game context)")
        return nil
    end
end

-- Safe inventory operations
local function safeGetInventory()
    local success, inventory = pcall(function()
        return getPlayer():getInventory()
    end)
    
    if success and inventory then
        return inventory
    else
        print("Could not retrieve inventory")
        return nil
    end
end

-- Safe character stats access
local function safeGetStats()
    local success, stats = pcall(function()
        local player = getPlayer()
        return {
            health = player:getHealth(),
            hunger = player:getStats():getHunger(),
            fatigue = player:getStats():getFatigue(),
            stress = player:getStats():getStress()
        }
    end)
    
    if success and stats then
        return stats
    else
        print("Could not retrieve player stats")
        return nil
    end
end

-- Display player information (pattern)
local function printPlayerInfo()
    print("\nPlayer Information:")
    print("  Username: (requires player context)")
    print("  Position: (x, y, z)")
    print("  Health: 0-100")
    print("  Hunger: affected by food consumption")
    print("  Fatigue: affected by exertion")
    print("  Stress: affected by zombie encounters")
end

printPlayerInfo()

-- Trading system example
local function initiateTrading(otherPlayer)
    local success = pcall(function()
        acceptTrading(getPlayer(), otherPlayer, true)
    end)
    
    if success then
        print("Trading initiated")
    else
        print("Could not initiate trading")
    end
end

-- XP system example
local function syncPlayerXp()
    local success = pcall(function()
        SyncXp(getPlayer())
    end)
    
    if success then
        print("Player XP synchronized")
    else
        print("Could not sync XP")
    end
end

print("\nExample player operations:")
print("  - Access player stats (health, hunger, fatigue, stress)")
print("  - Modify inventory items")
print("  - Initiate trading with other players")
print("  - Synchronize skill XP")
print("  - Get/set player position")
