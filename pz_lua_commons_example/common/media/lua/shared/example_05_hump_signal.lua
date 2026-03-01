-- Example 5: Using hump.signal for event/signal system
-- hump.signal provides a publish-subscribe event system

local pz_commons = require("pz_lua_commons/shared")
local signal = pz_commons.vrld.hump.signal

if not signal then
	print("hump.signal not available")
	return
end

-- Define some game events
local function onPlayerSpawned(playerName, x, y)
	print("EVENT: Player '" .. playerName .. "' spawned at (" .. x .. ", " .. y .. ")")
end

local function onEnemyDefeated(enemyName, experience)
	print("EVENT: Enemy '" .. enemyName .. "' defeated! +XP: " .. experience)
end

local function onInventoryFull()
	print("EVENT: Inventory is full!")
end

-- Subscribe to events
signal.register("player:spawn", onPlayerSpawned)
signal.register("enemy:defeated", onEnemyDefeated)
signal.register("inventory:full", onInventoryFull)

print("=== Simulation ===")

-- Emit events
signal.emit("player:spawn", "Hero", 100, 200)
signal.emit("enemy:defeated", "Zombie", 50)
signal.emit("player:spawn", "Companion", 110, 210)
signal.emit("inventory:full")
signal.emit("enemy:defeated", "Skeleton", 75)

-- Subscribe to multiple events
local eventLog = {}
signal.register("player:spawn", function(name)
	table.insert(eventLog, "Player " .. name .. " joined")
end)

signal.emit("player:spawn", "NewPlayer", 120, 220)
print("\nEvent Log: " .. table.concat(eventLog, " | "))
