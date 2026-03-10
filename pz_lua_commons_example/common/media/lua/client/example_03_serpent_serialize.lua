-- Example 3: Using serpent for table serialization
-- serpent converts Lua tables to readable string format

local pz_commons = require("pz_lua_commons/client")
local serpent = pz_commons.pkulchenko.serpent

if not serpent then
    print("serpent not available")
    return
end

-- Example data structure
local gameConfig = {
    version = "1.0",
    maxPlayers = 4,
    settings = {
        difficulty = "normal",
        pvp = true,
        respawnTime = 30,
    },
    weapons = { "axe", "gun", "knife" },
}

-- Serialize table to string
local serialized = serpent.dump(gameConfig)
print("Serialized config:")
print(serialized)

-- Load serialized data back
local loadedConfig = serpent.load(serialized)
print("\nLoaded back successfully!")
print("Version: " .. loadedConfig.version)
print("Max Players: " .. loadedConfig.maxPlayers)
