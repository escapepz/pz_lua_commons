-- Example: Integration of pz_lua_commons into a PZ Environment
-- This demonstrates how to use the commons library modules in practical scenarios
-- Compatible with plain Lua + PZ stub definitions

local pz_commons = require("pz_lua_commons/shared")
local pz_utils = require("pz_utils/shared")

-- ============================================================================
-- 1. JSON SERIALIZATION WITH LUNAJSON
-- ============================================================================

print("\n=== JSON Serialization Example ===")

local lunajson = pz_commons.grafi_tt.lunajson
if lunajson then
	local data = {
		playerName = "Alice",
		inventory = { "axe", "flashlight", "supplies" },
		health = 75,
		isAlive = true,
	}

	local json_str = lunajson.encode(data)
	print("Encoded JSON: " .. json_str)

	local decoded = lunajson.decode(json_str)
	print("Decoded playerName: " .. decoded.playerName)
	print("Inventory count: " .. #decoded.inventory)
end

-- ============================================================================
-- 2. EVENT SIGNALING WITH HUMP.SIGNAL
-- ============================================================================

print("\n=== Event Signaling Example ===")

local signal = pz_commons.vrld.hump.signal
if signal then
	-- Create custom events
	signal.register("player_died")
	signal.register("item_picked_up")

	-- Subscribe to events
	signal.subscribe("player_died", function()
		print("Event received: Player has died")
	end)

	signal.subscribe("item_picked_up", function(itemName)
		print("Event received: Picked up " .. itemName)
	end)

	-- Emit events
	signal.emit("player_died")
	signal.emit("item_picked_up", "shotgun")
end

-- ============================================================================
-- 3. OOP WITH MIDDLECLASS
-- ============================================================================

print("\n=== OOP Example ===")

local middleclass = pz_commons.kikito.middleclass
if middleclass then
	-- Define a Survivor class
	local Survivor = middleclass("Survivor")

	function Survivor:initialize(name, health)
		self.name = name
		self.health = health
		self.inventory = {}
	end

	function Survivor:takeDamage(amount)
		self.health = math.max(0, self.health - amount)
		return self.health <= 0
	end

	function Survivor:addItem(item)
		table.insert(self.inventory, item)
	end

	function Survivor:getStatus()
		return {
			name = self.name,
			health = self.health,
			itemCount = #self.inventory,
		}
	end

	-- Create and use instances
	local survivor = Survivor("Bob", 100)
	survivor:addItem("water bottle")
	survivor:addItem("canned food")

	print("Survivor status: " .. survivor.name .. " (HP: " .. survivor.health .. ")")

	survivor:takeDamage(25)
	print("After damage: HP " .. survivor.health)

	local status = survivor:getStatus()
	print("Items: " .. status.itemCount)
end

-- ============================================================================
-- 4. DEBOUNCING WITH PZ_UTILS ESCAPE
-- ============================================================================

print("\n=== Debouncing Example ===")

local escape = pz_utils[1] or pz_utils.escape
if escape then
	local searchCounter = 0

	local onSearch = function(query)
		searchCounter = searchCounter + 1
		print("Searching for: " .. query .. " (call #" .. searchCounter .. ")")
	end

	-- Rapid calls to a debounced function
	escape.Debounce.Call("user_search", 5, onSearch, "zombie")
	escape.Debounce.Call("user_search", 5, onSearch, "zombie")
	escape.Debounce.Call("user_search", 5, onSearch, "zombie")

	print("Search debounce created and reset 3 times")
	print("Is debounce active? " .. tostring(escape.Debounce.IsActive("user_search")))
end

-- ============================================================================
-- 5. SAFE LOGGING
-- ============================================================================

print("\n=== Safe Logging Example ===")

local safeLogger = escape.SafeLogger
if safeLogger then
	safeLogger.init("MyMod")

	safeLogger.log("This is a trace message", 10)
	safeLogger.log("This is debug info", 20)
	safeLogger.log("Important information", 30)
	safeLogger.log("Warning: something unusual", 40)
	safeLogger.log("Error occurred", 50)
end

-- ============================================================================
-- 6. EVENT MANAGER
-- ============================================================================

print("\n=== Event Manager Example ===")

if escape.EventManager then
	-- Create a custom event
	local zombieEvent = escape.EventManager.createEvent("ZombieSpawned")

	-- Add listeners
	zombieEvent:Add(function(zombieData)
		print("Listener 1: Zombie spawned at " .. (zombieData.x or "unknown"))
	end)

	zombieEvent:Add(function(zombieData)
		print("Listener 2: Total zombies: " .. (zombieData.count or 0))
	end)

	-- Trigger the event
	zombieEvent:Trigger({ x = 100, y = 200, count = 5 })

	print("Event listeners: " .. zombieEvent:GetListenerCount())
end

-- ============================================================================
-- 7. COMBINED WORKFLOW
-- ============================================================================

print("\n=== Combined Workflow Example ===")

if middleclass and lunajson and escape.EventManager then
	-- Define a network packet class
	local NetworkPacket = middleclass("NetworkPacket")

	function NetworkPacket:initialize(command, data)
		self.command = command
		self.data = data
		self.timestamp = escape.Utilities.GetIRLTimestamp()
	end

	function NetworkPacket:serialize()
		return lunajson.encode({
			command = self.command,
			data = self.data,
			timestamp = self.timestamp,
		})
	end

	-- Create a packet event
	local packetEvent = escape.EventManager.createEvent("PacketReceived")

	packetEvent:Add(function(packet)
		print("Received packet: " .. packet.command .. " at " .. packet.timestamp)
	end)

	-- Create and send a packet
	local packet = NetworkPacket("PLAYER_MOVE", { x = 50, y = 100 })
	print("Serialized packet: " .. packet:serialize())
	packetEvent:Trigger(packet)
end

print("\n=== All Examples Complete ===\n")
