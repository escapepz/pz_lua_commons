-- Example 11: Class-based networking with middleclass
-- Uses OOP to organize network protocol

local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass

if not middleclass then
    print("middleclass not available")
    return
end

print("=== Class-Based Networking ===")

-- Base Network Message class
local NetworkMessage = middleclass('NetworkMessage')

function NetworkMessage:initialize(messageType, playerId)
    self.messageType = messageType
    self.playerId = playerId
    self.timestamp = os.time()
end

function NetworkMessage:serialize()
    return serialize(self:toTable())
end

function NetworkMessage:toTable()
    return {
        type = self.messageType,
        playerId = self.playerId,
        timestamp = self.timestamp
    }
end

-- Player Update message class
local PlayerUpdateMessage = middleclass('PlayerUpdateMessage', NetworkMessage)

function PlayerUpdateMessage:initialize(playerId, x, y, z)
    NetworkMessage.initialize(self, "player_update", playerId)
    self.x = x
    self.y = y
    self.z = z
end

function PlayerUpdateMessage:toTable()
    local base = NetworkMessage.toTable(self)
    base.data = {
        x = self.x,
        y = self.y,
        z = self.z
    }
    return base
end

-- Item interaction message
local ItemActionMessage = middleclass('ItemActionMessage', NetworkMessage)

function ItemActionMessage:initialize(playerId, action, itemId, quantity)
    NetworkMessage.initialize(self, "item_action", playerId)
    self.action = action
    self.itemId = itemId
    self.quantity = quantity
end

function ItemActionMessage:toTable()
    local base = NetworkMessage.toTable(self)
    base.data = {
        action = self.action,
        itemId = self.itemId,
        quantity = self.quantity
    }
    return base
end

-- Combat action message
local CombatMessage = middleclass('CombatMessage', NetworkMessage)

function CombatMessage:initialize(playerId, targetId, weaponId, damage)
    NetworkMessage.initialize(self, "combat_action", playerId)
    self.targetId = targetId
    self.weaponId = weaponId
    self.damage = damage
end

function CombatMessage:toTable()
    local base = NetworkMessage.toTable(self)
    base.data = {
        targetId = self.targetId,
        weaponId = self.weaponId,
        damage = self.damage
    }
    return base
end

print("\n=== Message Creation and Serialization ===")

-- Create messages
local playerMsg = PlayerUpdateMessage("player_001", 100.5, 200.3, 0)
local itemMsg = ItemActionMessage("player_001", "drop", "weapon_axe", 1)
local combatMsg = CombatMessage("player_001", "zombie_456", "weapon_gun", 25)

print("Player Position Update:")
print(playerMsg:serialize())

print("\nItem Action:")
print(itemMsg:serialize())

print("\nCombat Action:")
print(combatMsg:serialize())

-- Message routing example
print("\n=== Message Router ===")
local MessageRouter = {}

function MessageRouter.route(messageStr)
    local msg = deserialize(messageStr)
    local msgType = msg.type
    
    if msgType == "player_update" then
        print("Routing player_update to position handler")
        print("  Player: " .. msg.playerId)
        print("  Position: (" .. msg.data.x .. ", " .. msg.data.y .. ")")
    elseif msgType == "item_action" then
        print("Routing item_action to inventory handler")
        print("  Action: " .. msg.data.action)
        print("  Item: " .. msg.data.itemId)
    elseif msgType == "combat_action" then
        print("Routing combat_action to damage handler")
        print("  Attacker: " .. msg.playerId)
        print("  Damage: " .. msg.data.damage)
    end
end

MessageRouter.route(playerMsg:serialize())
MessageRouter.route(combatMsg:serialize())
