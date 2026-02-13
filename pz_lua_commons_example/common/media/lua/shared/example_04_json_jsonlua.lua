-- Example 4: Using jsonlua (alternative JSON library)
-- jsonlua provides another JSON implementation with different characteristics

local pz_commons = require("pz_lua_commons/shared")
local json = pz_commons.rxi.jsonlua

if not json then
    print("jsonlua not available")
    return
end

-- Example configuration data
local config = {
    version = "1.0.0",
    settings = {
        graphicsQuality = "high",
        soundVolume = 0.8,
        language = "en",
        enableMods = true
    },
    keybinds = {
        moveForward = "w",
        moveBackward = "s",
        moveLeft = "a",
        moveRight = "d",
        jump = "space"
    }
}

-- Encode to JSON
local jsonText = json.encode(config)
print("Configuration as JSON:")
print(jsonText)

-- Decode JSON back
local loadedConfig = json.decode(jsonText)
print("\nLoaded configuration:")
print("Version: " .. loadedConfig.version)
print("Graphics Quality: " .. loadedConfig.settings.graphicsQuality)
print("Sound Volume: " .. loadedConfig.settings.soundVolume)
print("Jump key: " .. loadedConfig.keybinds.jump)
