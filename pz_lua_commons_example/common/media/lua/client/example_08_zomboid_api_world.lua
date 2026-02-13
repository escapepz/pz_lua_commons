-- Example 8: Using Project Zomboid API - World interactions
-- Demonstrates common world manipulation functions available in Zomboid

local pz_commons = require("pz_lua_commons/client")

print("=== Project Zomboid World API Example ===")

-- Note: These functions require proper Zomboid environment
-- They are shown for reference when running in actual mod

-- Random number generation (always available)
print("Random numbers:")
print("  Random 0-10: " .. tostring(ZombRand(11)))
print("  Random 5-15: " .. tostring(ZombRand(5, 15)))
print("  Random float 0.0-1.0: " .. tostring(ZombRandFloat(0, 1)))

-- Safe usage pattern for world functions
local function safeGetSquare(x, y, z)
    -- getSquare requires proper world context
    -- This shows the pattern for safe API calls
    local success, result = pcall(function()
        return getCell():getGridSquare(x, y, z)
    end)
    
    if success and result then
        return result
    else
        print("Could not get square at (" .. x .. ", " .. y .. ", " .. z .. ")")
        return nil
    end
end

-- Safe command sending to server
local function sendServerCommand(command)
    local success, result = pcall(function()
        SendCommandToServer(command)
    end)
    
    if success then
        print("Command sent: " .. command)
    else
        print("Failed to send command: " .. command)
    end
end

-- Example usage (would work in actual mod context)
print("\nExample API calls (require mod context):")
print("  sendServerCommand('setWeather=rainy')")
print("  sendServerCommand('give=food,water,weapons')")

-- Sound API example
local function addWorldSound(radius, volume)
    -- This represents how to add sound at player location
    -- In real usage: AddWorldSound(player, radius, volume)
    print("Adding world sound at radius " .. radius .. " with volume " .. volume)
end

addWorldSound(30, 100)
