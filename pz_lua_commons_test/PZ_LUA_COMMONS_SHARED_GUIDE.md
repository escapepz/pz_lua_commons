# PZ Lua Commons - Shared Module Guide

Complete reference for the **Shared** module of `pz_lua_commons`, which provides access to core Lua libraries for JSON processing, object-oriented programming, and event signaling.

## Quick Start

```lua
local pz_commons = require("pz_lua_commons/shared")

-- Access each library
local lunajson = pz_commons.grafi_tt.lunajson
local middleclass = pz_commons.kikito.middleclass
local jsonlua = pz_commons.rxi.jsonlua
local signal = pz_commons.vrld.hump.signal
```

## Table of Contents

1. [Available Libraries](#available-libraries)
2. [lunajson (Grafi-tt)](#lunajson-grafi-tt)
3. [middleclass (Kikito)](#middleclass-kikito)
4. [jsonlua (rxi)](#jsonlua-rxi)
5. [hump.signal (vrld)](#humpsignal-vrld)
6. [Practical Examples](#practical-examples)
7. [Best Practices](#best-practices)

---

## Available Libraries

| Library | Author | Purpose | Version |
|---------|--------|---------|---------|
| **lunajson** | Grafi-tt | JSON encoding/decoding | 1.2.3 |
| **middleclass** | Kikito | Object-oriented programming | 4.1.1 |
| **jsonlua** | rxi | Alternative JSON library | 0.1.2 |
| **hump.signal** | vrld | Event signaling system | Latest |

---

## lunajson (Grafi-tt)

High-performance JSON encoding and decoding for Lua.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `encode` | `obj: any, state: table\|nil` | `string` | Convert Lua value to JSON string |
| `decode` | `str: string` | `any` | Parse JSON string into Lua value |

### Basic Usage

```lua
local lunajson = pz_commons.grafi_tt.lunajson

-- Encode Lua table to JSON
local data = {
    name = "Player",
    health = 100,
    items = {"sword", "shield", "potion"}
}

local json_str = lunajson.encode(data)
print(json_str)
-- Output: {"name":"Player","health":100,"items":["sword","shield","potion"]}

-- Decode JSON string to Lua table
local decoded = lunajson.decode(json_str)
print(decoded.name)  -- "Player"
print(decoded.health)  -- 100
```

### Supported Data Types

```lua
-- Strings, numbers, booleans, nil
lunajson.encode({
    text = "Hello",
    count = 42,
    active = true,
    empty = nil
})

-- Tables (objects and arrays)
lunajson.encode({
    player = {
        name = "Alice",
        stats = {health = 100, mana = 50}
    },
    items = {1, 2, 3}
})

-- Nested structures
lunajson.encode({
    world = {
        regions = {
            {name = "Forest", level = 1},
            {name = "Dungeon", level = 5}
        }
    }
})
```

### Error Handling

```lua
local function safe_decode(json_str)
    local success, result = pcall(function()
        return lunajson.decode(json_str)
    end)
    
    if success then
        return result
    else
        print("JSON decode error: " .. tostring(result))
        return nil
    end
end

local data = safe_decode(invalid_json)
```

### Practical Use Cases

```lua
-- Save game data
local game_state = {
    player_level = 10,
    experience = 5000,
    inventory = {"health_potion", "mana_potion"},
    position = {x = 100, y = 200, z = 0}
}

local saved = lunajson.encode(game_state)
-- Save saved to file...

-- Load game data
local loaded = lunajson.decode(saved)
print("Loading player at level " .. loaded.player_level)
```

---

## middleclass (Kikito)

Object-oriented programming framework for Lua using classes and inheritance.

### Basic Class Definition

```lua
local middleclass = pz_commons.kikito.middleclass

-- Define a class
local Animal = middleclass('Animal')

function Animal:initialize(name)
    self.name = name
end

function Animal:speak()
    print(self.name .. " makes a sound")
end

-- Create instance
local dog = Animal("Buddy")
dog:speak()  -- "Buddy makes a sound"
```

### Inheritance

```lua
-- Create a subclass
local Dog = middleclass('Dog', Animal)

function Dog:initialize(name, breed)
    Animal.initialize(self, name)  -- Call parent constructor
    self.breed = breed
end

function Dog:speak()
    print(self.name .. " barks!")
end

-- Create instance
local buddy = Dog("Buddy", "Golden Retriever")
buddy:speak()  -- "Buddy barks!"
print(buddy.name)  -- "Buddy"
print(buddy.breed)  -- "Golden Retriever"
```

### Class Methods

```lua
local Player = middleclass('Player')

function Player:initialize(id, name)
    self.id = id
    self.name = name
    self.health = 100
end

-- Instance method
function Player:takeDamage(amount)
    self.health = self.health - amount
    return self.health <= 0
end

-- Class method (static)
function Player.create_admin(id, name)
    local player = Player(id, name)
    player.is_admin = true
    return player
end

-- Usage
local player1 = Player(1, "Alice")
local is_dead = player1:takeDamage(50)

local admin = Player.create_admin(2, "Bob")
```

### Multiple Inheritance

```lua
local Swimmer = middleclass('Swimmer')
function Swimmer:swim()
    print(self.name .. " swims gracefully")
end

local Flyer = middleclass('Flyer')
function Flyer:fly()
    print(self.name .. " flies through the air")
end

-- Multiple inheritance
local Duck = middleclass('Duck', Animal, Swimmer, Flyer)

local duck = Duck("Donald")
duck:speak()   -- From Animal
duck:swim()    -- From Swimmer
duck:fly()     -- From Flyer
```

### Type Checking

```lua
local Player = middleclass('Player')
local NPC = middleclass('NPC')

local player = Player("Alice")
local npc = NPC("Bob")

print(player:is_a(Player))   -- true
print(player:is_a(NPC))      -- false
print(player:is_instance_of(Player))  -- true

-- Check inheritance
if npc:is_a(Character) then
    print("NPC is a Character")
end
```

### Mixins

```lua
local Serializable = {}

function Serializable:to_string()
    return "Serializable object"
end

local Player = middleclass('Player')
Player:include(Serializable)

local player = Player("Alice")
print(player:to_string())  -- "Serializable object"
```

---

## jsonlua (rxi)

Alternative JSON library with different syntax and features.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `encode` | `obj: any` | `string` | Convert Lua value to JSON |
| `decode` | `str: string` | `any` | Parse JSON string |

### Basic Usage

```lua
local json = pz_commons.rxi.jsonlua

-- Encode
local data = {name = "Item", count = 5}
local json_str = json.encode(data)
print(json_str)

-- Decode
local decoded = json.decode(json_str)
print(decoded.name)  -- "Item"
```

### Differences from lunajson

```lua
-- Both libraries handle basic JSON similarly
-- Use jsonlua if you prefer its particular implementation
-- or as a fallback if one library fails

local pz_commons = require("pz_lua_commons/shared")
local lunajson = pz_commons.grafi_tt.lunajson
local json = pz_commons.rxi.jsonlua

-- Fallback pattern
local function safe_json_encode(obj)
    local success, result = pcall(function()
        return lunajson.encode(obj)
    end)
    
    if not success then
        -- Try alternative
        return json.encode(obj)
    end
    return result
end
```

---

## hump.signal (vrld)

Event signaling and subscription system for decoupled communication.

### Basic Functions

| Function | Parameters | Description |
|----------|-----------|-------------|
| `emit` | `signal_name: string, ...` | Fire a signal with arguments |
| `register` | `signal_name: string, fn: function` | Listen to a signal |
| `remove` | `signal_name: string, fn: function` | Stop listening |

### Emitting Signals

```lua
local signal = pz_commons.vrld.hump.signal

-- Emit a simple signal
signal.emit("game:started")

-- Emit with data
signal.emit("player:damaged", "Alice", 25)

-- Emit with multiple arguments
signal.emit("item:crafted", "sword", 1, {quality = "rare"})
```

### Registering Listeners

```lua
-- Register function
local function on_player_damage(player_name, damage)
    print(player_name .. " took " .. damage .. " damage")
end

signal.register("player:damaged", on_player_damage)

-- Emit the signal
signal.emit("player:damaged", "Bob", 50)
-- Output: "Bob took 50 damage"
```

### Anonymous Listeners

```lua
signal.register("player:levelup", function(name, level)
    print("Achievement: " .. name .. " reached level " .. level .. "!")
end)

signal.emit("player:levelup", "Alice", 10)
```

### Removing Listeners

```lua
local function on_event()
    print("Event fired")
end

signal.register("my:event", on_event)

-- Later, remove the listener
signal.remove("my:event", on_event)

signal.emit("my:event")  -- No output, listener was removed
```

### Common Signal Patterns

```lua
-- Game lifecycle signals
signal.emit("game:load")
signal.emit("game:init")
signal.emit("game:start")
signal.emit("game:pause")
signal.emit("game:resume")
signal.emit("game:stop")

-- Player signals
signal.emit("player:spawn", player_obj)
signal.emit("player:died", player_name, killer_name)
signal.emit("player:levelup", player_name, new_level)
signal.emit("player:item_pickup", player_name, item_name)

-- World signals
signal.emit("world:time_changed", hour, minute)
signal.emit("world:zombie_spawn", x, y, z, count)
signal.emit("world:item_dropped", item_name, x, y, z)
```

### Event Subscription Pattern

```lua
-- Create a game event system
local function setup_game_events()
    signal.register("player:damaged", function(player, damage)
        -- Update UI
        print("Health changed")
    end)
    
    signal.register("player:damaged", function(player, damage)
        -- Play sound effect
        print("Sound: damage")
    end)
    
    signal.register("player:damaged", function(player, damage)
        -- Log to statistics
        print("Stats: logged")
    end)
end

-- Trigger event
signal.emit("player:damaged", "Alice", 25)
```

---

## Practical Examples

### Example 1: Data Persistence with Classes

```lua
local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass
local lunajson = pz_commons.grafi_tt.lunajson

-- Define game character class
local Character = middleclass('Character')

function Character:initialize(name, level)
    self.name = name
    self.level = level
    self.experience = 0
    self.inventory = {}
end

function Character:gain_experience(amount)
    self.experience = self.experience + amount
    if self.experience >= 100 then
        self.level = self.level + 1
        self.experience = 0
    end
end

function Character:add_item(item)
    table.insert(self.inventory, item)
end

function Character:to_json()
    return lunajson.encode({
        name = self.name,
        level = self.level,
        experience = self.experience,
        inventory = self.inventory
    })
end

-- Usage
local hero = Character("Aragorn", 50)
hero:gain_experience(150)
hero:add_item("Anduril")
hero:add_item("Mithril Armor")

local saved = hero:to_json()
print(saved)
-- {"name":"Aragorn","level":51,"experience":50,"inventory":["Anduril","Mithril Armor"]}
```

### Example 2: Event-Driven Game State

```lua
local pz_commons = require("pz_lua_commons/shared")
local signal = pz_commons.vrld.hump.signal
local middleclass = pz_commons.kikito.middleclass

local Game = middleclass('Game')

function Game:initialize()
    self.running = false
    self.players = {}
end

function Game:start()
    self.running = true
    signal.emit("game:started")
end

function Game:add_player(name)
    table.insert(self.players, name)
    signal.emit("player:joined", name)
end

function Game:remove_player(name)
    for i, p in ipairs(self.players) do
        if p == name then
            table.remove(self.players, i)
            signal.emit("player:left", name)
            break
        end
    end
end

-- Setup listeners
signal.register("game:started", function()
    print("Game has started!")
end)

signal.register("player:joined", function(name)
    print(name .. " joined the game")
end)

signal.register("player:left", function(name)
    print(name .. " left the game")
end)

-- Usage
local game = Game()
game:add_player("Alice")
game:add_player("Bob")
game:start()
game:remove_player("Alice")
```

### Example 3: Data Serialization Pipeline

```lua
local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass
local lunajson = pz_commons.grafi_tt.lunajson
local signal = pz_commons.vrld.hump.signal

local ItemDatabase = middleclass('ItemDatabase')

function ItemDatabase:initialize()
    self.items = {}
end

function ItemDatabase:register_item(id, name, rarity)
    self.items[id] = {name = name, rarity = rarity}
    signal.emit("item:registered", id, name)
end

function ItemDatabase:export()
    return lunajson.encode(self.items)
end

function ItemDatabase:import(json_str)
    self.items = lunajson.decode(json_str)
    signal.emit("database:imported")
end

-- Setup
signal.register("item:registered", function(id, name)
    print("Registered: " .. name .. " (ID: " .. id .. ")")
end)

signal.register("database:imported", function()
    print("Database imported successfully")
end)

-- Usage
local db = ItemDatabase()
db:register_item("sword_01", "Iron Sword", "common")
db:register_item("shield_01", "Steel Shield", "uncommon")

local exported = db:export()
print("Exported: " .. exported)
```

---

## Best Practices

### 1. Always Check Library Availability

```lua
local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass

if not middleclass then
    print("ERROR: middleclass not available")
    return
end
```

### 2. Use Consistent JSON Library

```lua
-- Choose one and stick with it in your mod
local json = pz_commons.grafi_tt.lunajson  -- Recommended for performance
-- Don't mix lunajson.encode with jsonlua.decode
```

### 3. Error Handling for JSON

```lua
local function safe_decode(json_str)
    if not json_str or type(json_str) ~= "string" then
        return nil
    end
    
    local success, result = pcall(function()
        return lunajson.decode(json_str)
    end)
    
    if success and type(result) == "table" then
        return result
    end
    return nil
end
```

### 4. Use Classes for Complex Data

```lua
-- Good: Use classes for game objects with behavior
local Player = middleclass('Player')
function Player:initialize(name)
    self.name = name
    self.health = 100
end
function Player:take_damage(damage)
    self.health = self.health - damage
end

-- Avoid: Just using tables
local player = {name = "Alice", health = 100}
```

### 5. Signal Naming Conventions

```lua
-- Use colon-separated names for clarity
signal.emit("module:action")          -- "player:died"
signal.emit("module:object:action")   -- "item:weapon:equipped"

-- Avoid ambiguous names
-- BAD: signal.emit("damaged", player, amount)
-- GOOD: signal.emit("player:damaged", player, amount)
```

### 6. Lazy Load Libraries

```lua
local pz_commons = require("pz_lua_commons/shared")

-- Cache references if using frequently
local middleclass = pz_commons.kikito.middleclass
local signal = pz_commons.vrld.hump.signal

-- Define classes
local Player = middleclass('Player')
-- ... rest of code
```

### 7. Combine Classes with Signals

```lua
local Player = middleclass('Player')

function Player:initialize(name)
    self.name = name
    self.health = 100
end

function Player:take_damage(amount)
    self.health = self.health - amount
    signal.emit("player:health_changed", self.name, self.health)
    
    if self.health <= 0 then
        signal.emit("player:died", self.name)
    end
end

-- Listen to events
signal.register("player:died", function(name)
    print(name .. " has died")
end)
```

---

## Module Capabilities Summary

### lunajson
✓ High-performance JSON encoding/decoding
✓ Full Lua data type support
✓ Handles nested structures
✓ Suitable for save files and network data

### middleclass
✓ Full OOP with classes and inheritance
✓ Multiple inheritance support
✓ Mixins for code reuse
✓ Type checking (is_a, is_instance_of)
✓ Perfect for game objects with behavior

### jsonlua
✓ Alternative JSON implementation
✓ Handles standard JSON types
✓ Fallback if lunajson unavailable
✓ Different performance characteristics

### hump.signal
✓ Publish-subscribe event system
✓ Decoupled communication
✓ Support multiple listeners per signal
✓ Lightweight and efficient
✓ Great for game events and hooks

---

## Examples Reference

For complete working examples, see:
- `example_02_json_lunajson.lua`
- `example_03_middleclass_oop.lua`
- `example_04_json_jsonlua.lua`
- `example_05_hump_signal.lua`
- `example_06_combined_shared_utilities.lua`

## Testing Reference

For test coverage, see existing test files in `pz_lua_commons_test/common/media/lua/shared/`

---

## Troubleshooting

### Issue: Module returns nil
**Solution**: Check if library loaded successfully using safe_require
```lua
if not middleclass then
    print("middleclass failed to load")
end
```

### Issue: JSON encoding fails
**Solution**: Ensure all values are JSON-serializable (no functions, userdata)
```lua
-- BAD: Functions can't be serialized
local data = {fn = function() end}

-- GOOD: Only data
local data = {value = 42, name = "test"}
```

### Issue: Signal not firing
**Solution**: Verify signal name exactly matches between emit and register
```lua
-- These DON'T match:
signal.register("player:died", fn)
signal.emit("player:death", ...)

-- Must be exact:
signal.register("player:died", fn)
signal.emit("player:died", ...)
```

---

## Performance Tips

1. **Cache library references** at module load time
2. **Pre-define classes** rather than creating them on-demand
3. **Use lunajson** for better performance than jsonlua
4. **Reuse signal listeners** instead of registering/unregistering frequently
5. **Avoid deep JSON** nesting (keep it under 5 levels)

---

## API Quick Reference

```lua
local pz_commons = require("pz_lua_commons/shared")

-- lunajson
pz_commons.grafi_tt.lunajson.encode(obj)
pz_commons.grafi_tt.lunajson.decode(str)

-- middleclass
local Class = pz_commons.kikito.middleclass('ClassName')

-- jsonlua
pz_commons.rxi.jsonlua.encode(obj)
pz_commons.rxi.jsonlua.decode(str)

-- hump.signal
pz_commons.vrld.hump.signal.emit(name, ...)
pz_commons.vrld.hump.signal.register(name, fn)
pz_commons.vrld.hump.signal.remove(name, fn)
```
