-- Example 10: Network protocol using shared serialization
-- Demonstrates client-server communication patterns using pz_lua_commons

local pz_commons = require("pz_lua_commons/shared")

print("=== Network Protocol Example ===")

-- Protocol message structure
local MessageType = {
    PLAYER_UPDATE = "player_update",
    ITEM_TRANSFER = "item_transfer",
    WORLD_STATE = "world_state",
    PLAYER_ACTION = "player_action",
}

-- Message builder
local function createMessage(messageType, data)
    return {
        type = messageType,
        timestamp = os.time(),
        data = data,
    }
end

-- Serialize message for transmission
local function serializeMessage(msg)
    return serialize(msg)
end

-- Deserialize received message
local function deserializeMessage(msgStr)
    return deserialize(msgStr)
end

-- Example: Player position update
print("\n=== Player Position Update ===")
local playerPosMsg = createMessage(MessageType.PLAYER_UPDATE, {
    playerId = "player_001",
    x = 100.5,
    y = 200.3,
    z = 0,
    direction = "north",
})

local serializedPos = serializeMessage(playerPosMsg)
print("Serialized player update:")
print(serializedPos)

-- Simulate network transmission and reception
local receivedPos = deserializeMessage(serializedPos)
print("\nReceived message:")
print("  Type: " .. receivedPos.type)
print("  Player: " .. receivedPos.data.playerId)
print("  Position: (" .. receivedPos.data.x .. ", " .. receivedPos.data.y .. ")")

-- Example: Item transfer between players
print("\n=== Item Transfer ===")
local itemTransferMsg = createMessage(MessageType.ITEM_TRANSFER, {
    fromPlayer = "player_001",
    toPlayer = "player_002",
    items = {
        { id = "weapon_axe", quantity = 1 },
        { id = "food_canned", quantity = 5 },
        { id = "ammo_9mm", quantity = 30 },
    },
})

print("Item transfer message:")
print(serializeMessage(itemTransferMsg))

-- Example: World state broadcast
print("\n=== World State Broadcast ===")
local worldStateMsg = createMessage(MessageType.WORLD_STATE, {
    gameTime = 1440,
    weather = "rainy",
    temperature = 15,
    activeZombies = ZombRand(50, 500),
    activePlayers = 4,
})

local serializedWorld = serializeMessage(worldStateMsg)
print("World state message (first 100 chars):")
print(string.sub(serializedWorld, 1, 100) .. "...")

-- Example: Action message
print("\n=== Player Action ===")
local actionMsg = createMessage(MessageType.PLAYER_ACTION, {
    playerId = "player_001",
    action = "craft_item",
    recipe = "wooden_spear",
    duration = 30,
})

print("Action message:")
print(serializeMessage(actionMsg))

-- Protocol handler pattern
print("\n=== Message Handler Pattern ===")
local MessageHandler = {}

function MessageHandler.handle(msgStr)
    local msg = deserializeMessage(msgStr)

    if msg.type == MessageType.PLAYER_UPDATE then
        print("Handling player update from " .. msg.data.playerId)
    elseif msg.type == MessageType.ITEM_TRANSFER then
        print("Handling item transfer from " .. msg.data.fromPlayer)
    elseif msg.type == MessageType.WORLD_STATE then
        print("Handling world state update")
    elseif msg.type == MessageType.PLAYER_ACTION then
        print("Handling player action: " .. msg.data.action)
    end

    return true
end

-- Simulate message processing
local testMsg = serializeMessage(playerPosMsg)
MessageHandler.handle(testMsg)
