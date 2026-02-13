-- Example 2: Using lunajson for JSON encoding/decoding
-- lunajson provides fast JSON parsing and serialization

local pz_commons = require("pz_lua_commons/shared")
local lunajson = pz_commons.grafi_tt.lunajson

if not lunajson then
    print("lunajson not available")
    return
end

-- Example data
local gameData = {
    players = {
        {id = 1, name = "Alice", level = 30},
        {id = 2, name = "Bob", level = 25},
        {id = 3, name = "Charlie", level = 28}
    },
    world = {
        name = "Apocalypse",
        difficulty = "Hard",
        seed = 12345
    }
}

-- Encode to JSON string
local jsonString = lunajson.encode(gameData)
print("Encoded JSON:")
print(jsonString)

-- Decode JSON back to table
local decodedData = lunajson.decode(jsonString)
print("\nDecoded successfully!")
print("World name: " .. decodedData.world.name)
print("First player: " .. decodedData.players[1].name .. " (Level " .. decodedData.players[1].level .. ")")
