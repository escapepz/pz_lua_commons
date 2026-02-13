-- Example 12: Advanced combined usage of all shared utilities
-- Demonstrates a game server session manager using pz_lua_commons

local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass
local signal = pz_commons.vrld.hump.signal

if not middleclass or not signal then
    print("Required libraries not available")
    return
end

print("=== Advanced Game Server Session Manager ===")

-- Game session class
local GameSession = middleclass('GameSession')

function GameSession:initialize(sessionId, difficulty)
    self.sessionId = sessionId
    self.difficulty = difficulty
    self.createdAt = os.time()
    self.players = {}
    self.worldState = {
        time = 0,
        weather = "clear",
        zombieCount = ZombRand(100, 500)
    }
end

function GameSession:addPlayer(playerId, playerName)
    self.players[playerId] = {
        id = playerId,
        name = playerName,
        joinedAt = os.time(),
        level = 1,
        experience = 0
    }
    signal.emit("player:joined", playerId, playerName)
end

function GameSession:removePlayer(playerId)
    local playerName = self.players[playerId] and self.players[playerId].name or "Unknown"
    self.players[playerId] = nil
    signal.emit("player:left", playerId, playerName)
end

function GameSession:updateWorldState(worldData)
    for key, value in pairs(worldData) do
        self.worldState[key] = value
    end
    signal.emit("world:updated")
end

function GameSession:getPlayerCount()
    local count = 0
    for _ in pairs(self.players) do
        count = count + 1
    end
    return count
end

function GameSession:serialize()
    return serialize({
        sessionId = self.sessionId,
        difficulty = self.difficulty,
        createdAt = self.createdAt,
        playerCount = self:getPlayerCount(),
        worldState = self.worldState
    }, true, "  ")
end

-- Event subscriptions
signal.register("player:joined", function(playerId, playerName)
    print("  [EVENT] Player joined: " .. playerName .. " (" .. playerId .. ")")
end)

signal.register("player:left", function(playerId, playerName)
    print("  [EVENT] Player left: " .. playerName)
end)

signal.register("world:updated", function()
    print("  [EVENT] World state updated")
end)

-- Create and manage session
print("\n=== Creating Game Session ===")
local session = GameSession("session_001", "normal")

print("Adding players...")
session:addPlayer("p001", "Alice")
session:addPlayer("p002", "Bob")
session:addPlayer("p003", "Charlie")

print("\nCurrent players: " .. session:getPlayerCount())

print("\nUpdating world state...")
session:updateWorldState({
    time = 1440,
    weather = "rainy",
    zombieCount = ZombRand(200, 800)
})

print("\nRemoving player...")
session:removePlayer("p002")

print("\nFinal player count: " .. session:getPlayerCount())

-- Session persistence
print("\n=== Session Serialization ===")
local serialized = session:serialize()
print(serialized)

-- Parse command line with string operations
print("\n=== Command Processing ===")
local commands = {
    "set_difficulty=hard, enable_pvp=true",
    "spawn_zombies=50, area=warehouse",
    "teleport_player=p001, x=100, y=200, z=0"
}

for _, cmdStr in ipairs(commands) do
    print("\nProcessing: " .. cmdStr)
    local params = string.split(cmdStr, ", ")
    for i, param in ipairs(params) do
        local parts = string.split(string.trim(param), "=")
        if parts[1] and parts[2] then
            print("  - " .. string.trim(parts[1]) .. " => " .. string.trim(parts[2]))
        end
    end
end

-- Inventory management using tables
print("\n=== Multi-Player Inventory System ===")
local inventories = {
    p001 = {sword = 1, shield = 1, potion = 5},
    p002 = {bow = 1, arrows = 30, food = 10},
    p003 = {gun = 1, ammo = 45}
}

print("Current inventories:")
for playerId, inventory in pairs(inventories) do
    if not table.isempty(inventory) then
        print("  " .. playerId .. ":")
        for item, quantity in pairs(inventory) do
            print("    - " .. item .. " x" .. quantity)
        end
    end
end

-- Trade between players
print("\nTrade: p001 gives sword to p002")
if inventories.p001.sword and inventories.p001.sword > 0 then
    inventories.p001.sword = inventories.p001.sword - 1
    inventories.p002.sword = (inventories.p002.sword or 0) + 1
    print("Trade completed!")
end

-- Compact inventory for storage
print("\nCompact inventory format for storage:")
local compactInventory = serialize(inventories)
print(compactInventory)

print("\n=== Session Complete ===")
