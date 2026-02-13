-- Example 6: Combining multiple shared utilities
-- Shows how to use all shared libraries together in a game scenario

local pz_commons = require("pz_lua_commons/shared")
local lunajson = pz_commons.grafi_tt.lunajson
local middleclass = pz_commons.kikito.middleclass
local json = pz_commons.rxi.jsonlua
local signal = pz_commons.vrld.hump.signal

-- Define a Player class using middleclass
local Player = middleclass('Player')

function Player:initialize(id, name, level)
    self.id = id
    self.name = name
    self.level = level
    self.experience = 0
end

function Player:gainExperience(amount)
    self.experience = self.experience + amount
    if self.experience >= 100 then
        self.level = self.level + 1
        self.experience = 0
        signal.emit("player:levelup", self.name, self.level)
    end
end

function Player:toJSON()
    return lunajson.encode({
        id = self.id,
        name = self.name,
        level = self.level,
        experience = self.experience
    })
end

-- Create players
local player1 = Player(1, "Alice", 10)
local player2 = Player(2, "Bob", 10)

-- Subscribe to level up events
signal.register("player:levelup", function(name, level)
    print("ACHIEVEMENT: " .. name .. " reached level " .. level .. "!")
end)

print("=== Game Session ===")
print("Players created:")
print(player1:toJSON())
print(player2:toJSON())

-- Simulate gameplay
player1:gainExperience(60)
player1:gainExperience(50)  -- Will level up

player2:gainExperience(80)
player2:gainExperience(30)  -- Will level up

-- Save player data as JSON
local playersData = {
    players = {
        lunajson.decode(player1:toJSON()),
        lunajson.decode(player2:toJSON())
    }
}

local savedJSON = json.encode(playersData)
print("\nSaved game data:")
print(savedJSON)
