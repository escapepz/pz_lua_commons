-- Example 9: Using Project Zomboid API - Shared functions
-- These functions are available in both client and server contexts

local pz_commons = require("pz_lua_commons/shared")

print("=== Project Zomboid Shared API ===")

-- Random number generation (safe and always available)
print("Random number examples:")
print("  Zombies spawning: " .. ZombRand(20) .. " zombies")
print("  Loot roll (0-100): " .. ZombRand(101))
print("  Range 10-30: " .. ZombRand(10, 30))
print("  Float 0.0-1.0: " .. string.format("%.2f", ZombRandFloat(0, 1)))

-- Safe world/cell access pattern
local function safeGetCell()
    local success, cell = pcall(function()
        return getCell()
    end)
    if success and cell then
        return cell
    else
        print("Cell context not available (expected in non-game context)")
        return nil
    end
end

-- Safe map operations
local function safeLoadMap(x, y)
    local success, result = pcall(function()
        local cell = getCell()
        if cell then
            cell:loadGridSquare(x, y)
            return true
        end
        return false
    end)
    if success and result then
        print("Map chunk loaded at " .. x .. ", " .. y)
        return true
    else
        print("Could not load map at " .. x .. ", " .. y)
        return false
    end
end

-- Safe timer operations
local function setGameTimer(timeMs, callback)
    local success = pcall(function()
        -- addGameTime would be available in actual game context
        print("Timer set for " .. timeMs .. "ms")
    end)
    return success
end

-- Safe broadcast messaging (multiplayer)
local function broadcastMessage(message)
    local success = pcall(function()
        -- sendCommand or broadcast would be used in actual multiplayer context
        print("Broadcasting: " .. message)
    end)
    return success
end

print("\n=== API Call Examples ===")
print("Safe API patterns demonstrated:")
print("  - Map loading (safeLoadMap)")
print("  - Game timer setup (setGameTimer)")
print("  - Broadcast messaging (broadcastMessage)")
print("  - Random generation (ZombRand, ZombRandFloat)")

-- Practical example: Event system using randomization
print("\n=== Event Simulation ===")
local events = {}

local function generateRandomEvent()
    local eventType = ZombRand(3)
    local eventId = "event_" .. ZombRand(10000)

    if eventType == 0 then
        return { id = eventId, type = "zombie_horde", size = ZombRand(5, 20) }
    elseif eventType == 1 then
        return { id = eventId, type = "supply_drop", items = ZombRand(3, 10) }
    else
        return { id = eventId, type = "weather_change", severity = ZombRandFloat(0, 1) }
    end
end

print("Generated random events:")
for i = 1, 3 do
    local event = generateRandomEvent()
    print("  Event " .. i .. ": " .. event.type)
    if event.size then
        print("    Size: " .. event.size)
    elseif event.items then
        print("    Items: " .. event.items)
    elseif event.severity then
        print("    Severity: " .. string.format("%.2f", event.severity))
    end
end
