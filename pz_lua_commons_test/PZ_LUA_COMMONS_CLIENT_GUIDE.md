# PZ Lua Commons - Client Module Guide

Complete reference for the **Client** module of `pz_lua_commons`, which provides client-side debugging, serialization, and object-oriented programming tools for Project Zomboid mod development.

## Quick Start

```lua
-- Client-side only (will not load on server)
if isServer() then return end

local pz_commons = require("pz_lua_commons/client")

-- Access each library
local inspect = pz_commons.kikito.inspectlua
local serpent = pz_commons.pkulchenko.serpent
local yon30log = pz_commons.yonaba.yon_30log
```

## Important: Client-Only Module

This module **only loads on client-side**. It includes the following guard:

```lua
if not isServer() then
    -- Libraries load here
end
```

This means the module is safe to require, but libraries will be `nil` on server. Always check:

```lua
if inspect then
    -- Use inspect safely
end
```

## Table of Contents

1. [Available Libraries](#available-libraries)
2. [inspectlua (Kikito)](#inspectlua-kikito)
3. [serpent (pkulchenko)](#serpent-pkulchenko)
4. [30log (yonaba)](#30log-yonaba)
5. [Practical Examples](#practical-examples)
6. [Best Practices](#best-practices)

---

## Available Libraries

| Library | Author | Purpose | Type |
|---------|--------|---------|------|
| **inspectlua** | Kikito | Table inspection and debugging | Debug |
| **serpent** | pkulchenko | Data serialization | Serialization |
| **30log** | yonaba | Object-oriented programming | OOP |

---

## inspectlua (Kikito)

Advanced table inspection tool for debugging. Pretty-prints Lua tables with formatting and depth control.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `inspect` | `obj: any, options: table\|nil` | `string` | Return formatted string representation |

### Basic Usage

```lua
local inspect = pz_commons.kikito.inspectlua

if not inspect then
    print("inspectlua not available (server context?)")
    return
end

local player_data = {
    name = "Alice",
    health = 95,
    inventory = {"sword", "shield", "potion"}
}

print(inspect(player_data))
```

### Output Example

```
{
  health = 95,
  inventory = {
    1 = "sword",
    2 = "shield",
    3 = "potion"
  },
  name = "Alice"
}
```

### Options

```lua
-- Limit depth of nested tables
inspect(player_data, {depth = 1})

-- Custom newline
inspect(player_data, {newline = "\n"})

-- Custom indent
inspect(player_data, {indent = "  "})

-- Combine options
local formatted = inspect(player_data, {
    depth = 2,
    indent = "    ",
    newline = "\n"
})
```

### Debugging Examples

```lua
-- Inspect a table
local my_table = {a = 1, b = {c = 2, d = 3}}
print(inspect(my_table))

-- Inspect function behavior
local function process_data(data)
    print("Received:")
    print(inspect(data))
    return data.value * 2
end

process_data({value = 42, extra = "info"})

-- Compare two structures
local expected = {x = 1, y = 2}
local actual = {x = 1, y = 3}

print("Expected: " .. inspect(expected))
print("Actual: " .. inspect(actual))

-- Dump function result
local result = some_function()
if type(result) == "table" then
    print("Function returned: " .. inspect(result))
end
```

### Practical Use Cases

```lua
-- Debug player state
local player = getPlayer()
if player then
    print("Player state:")
    print(inspect({
        name = player:getUsername(),
        health = player:getHealth(),
        stamina = player:getStamina()
    }))
end

-- Debug inventory
local inventory = player:getInventory()
if inventory then
    print("Inventory contents:")
    print(inspect({
        size = inventory:getSize(),
        item_count = inventory:getItemCount()
    }))
end

-- Debug game state
print("Game snapshot:")
print(inspect({
    time = os.time(),
    paused = isPaused(),
    debug = isDebugEnabled()
}))
```

### Advanced Debugging

```lua
-- Create debug helper
local function debug_table(name, tbl, depth)
    depth = depth or 2
    print("\n=== " .. name .. " ===")
    print(inspect(tbl, {depth = depth}))
    print("Type: " .. type(tbl))
    if type(tbl) == "table" then
        print("Size: " .. #tbl)
    end
end

-- Usage
debug_table("Player Data", player_data, 3)

-- Compare values
local function assert_table_equals(expected, actual, name)
    if inspect(expected) ~= inspect(actual) then
        print("MISMATCH in " .. name)
        print("Expected: " .. inspect(expected))
        print("Actual: " .. inspect(actual))
        return false
    end
    return true
end
```

---

## serpent (pkulchenko)

Powerful serialization library for converting Lua values to human-readable strings and back.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `dump` | `obj: any, options: table\|nil` | `string` | Serialize to string |
| `load` | `str: string` | `function` | Load serialized data |
| `line` | `obj: any, options: table\|nil` | `string` | One-line serialization |

### Basic Serialization

```lua
local serpent = pz_commons.pkulchenko.serpent

if not serpent then
    print("serpent not available")
    return
end

-- Dump: Serialize to readable format
local data = {
    player = "Alice",
    level = 50,
    stats = {strength = 18, dexterity = 15}
}

local serialized = serpent.dump(data)
print(serialized)
```

### Output Example

```lua
{
  level = 50,
  player = "Alice",
  stats = {
    dexterity = 15,
    strength = 18
  }
}
```

### Loading Data

```lua
-- Load: Convert string back to Lua value
local serialized = serpent.dump(data)

-- Get as a function
local loaded_fn = serpent.load(serialized)
local restored = loaded_fn()  -- Call the function to get the value

print(restored.player)  -- "Alice"
print(restored.level)   -- 50
```

### Options

```lua
-- Compact format (single line)
local compact = serpent.line(data)
print(compact)

-- Custom comment handling
local with_comments = serpent.dump(data, {
    comment = true,
    sortkeys = true
})
```

### Complex Data Serialization

```lua
-- Nested structures
local complex = {
    name = "World",
    regions = {
        {id = 1, name = "Forest", difficulty = "easy"},
        {id = 2, name = "Dungeon", difficulty = "hard"}
    },
    settings = {
        version = "1.0",
        enabled = true,
        config = {
            max_players = 4,
            timeout = 300
        }
    }
}

local serialized = serpent.dump(complex)
print(serialized)

-- Restore from serialized
local restored = serpent.load(serialized)()
print("Restored first region: " .. restored.regions[1].name)
```

### Comparison: JSON vs Serpent

```lua
-- JSON (lunajson) - standard format, universal
local json = lunajson.encode(data)
-- Result: {"name":"Alice","level":50,...}

-- Serpent - Lua-native, more expressive
local serpent_str = serpent.dump(data)
-- Result: {name = "Alice", level = 50, ...}

-- Use JSON for:
-- - Network communication
-- - Cross-language compatibility
-- - Standard data interchange

-- Use Serpent for:
-- - Lua-only data persistence
-- - Readable config files
-- - Debug output
```

### File I/O with Serpent

```lua
-- Save to file
local function save_data(filepath, data)
    local file = io.open(filepath, "w")
    if not file then
        print("Failed to open file: " .. filepath)
        return false
    end
    
    file:write(serpent.dump(data))
    file:close()
    return true
end

-- Load from file
local function load_data(filepath)
    local file = io.open(filepath, "r")
    if not file then
        print("File not found: " .. filepath)
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    local success, result = pcall(function()
        return serpent.load(content)()
    end)
    
    return success and result or nil
end

-- Usage
local player_data = {name = "Alice", level = 50}
save_data("player.lua", player_data)

local restored = load_data("player.lua")
print(inspect(restored))
```

### Practical Use Cases

```lua
-- Configuration files
local config = {
    mod_version = "1.0",
    debug_mode = true,
    features = {
        enable_logging = true,
        enable_ui = true,
        max_concurrent = 10
    }
}

-- Save config
save_data("config.lua", config)

-- Game state snapshot
local game_state = {
    timestamp = os.time(),
    players = {
        {name = "Alice", health = 100, x = 100, y = 200},
        {name = "Bob", health = 75, x = 150, y = 200}
    },
    world = {
        difficulty = "normal",
        biome = "forest"
    }
}

local state_str = serpent.dump(game_state)
print(state_str)
```

---

## 30log (yonaba)

Ultra-lightweight OOP framework for Lua ("30 Lines Of Goodness"). Provides classes, inheritance, and mixins in a minimal, elegant implementation.

### Basic Class Definition

```lua
local yon30log = pz_commons.yonaba.yon_30log

if not yon30log then
    print("30log not available")
    return
end

-- Create a class
local Player = yon30log("Player")

function Player:initialize(name, level)
    self.name = name
    self.level = level
    self.health = 100
end

function Player:take_damage(amount)
    self.health = self.health - amount
    print(self.name .. " took " .. amount .. " damage")
end

-- Create instance
local player = Player:new("Alice", 50)
player:take_damage(25)
```

### Inheritance

```lua
local Character = yon30log("Character")

function Character:initialize(name)
    self.name = name
    self.health = 100
end

-- Subclass using extend()
local Knight = Character:extend("Knight")

function Knight:initialize(name, armor)
    Character.initialize(self, name)
    self.armor = armor
    self.defense = 15
end

function Knight:take_damage(amount)
    local reduced = math.max(1, amount - self.defense)
    self.health = self.health - reduced
end

-- Usage
local knight = Knight:new("Aragorn", "plate")
knight:take_damage(20)
```

### Simple and Elegant

30log achieves full OOP functionality in minimal code:

```lua
local Player = yon30log("Player")

function Player:initialize(name)
    self.name = name
    self.level = 1
end

function Player:level_up()
    self.level = self.level + 1
    print(self.name .. " reached level " .. self.level)
end

function Player:get_info()
    return {name = self.name, level = self.level}
end

-- Create and use
local hero = Player:new("Alice")
hero:level_up()
```

30log's strength is its compact, elegant implementation - about 30 lines of code providing full OOP.

### Mixins and Composition

```lua
-- Define mixins
local Damageable = {}
function Damageable:take_damage(amount)
    self.health = self.health - amount
end

local Healable = {}
function Healable:heal(amount)
    self.health = math.min(100, self.health + amount)
end

-- Create class with mixins using with()
local Player = yon30log("Player")
Player:with(Damageable)
Player:with(Healable)

function Player:initialize(name)
    self.name = name
    self.health = 100
end

-- Usage
local player = Player:new("Alice")
player:take_damage(25)
player:heal(10)
```

### Comparison with middleclass

```lua
-- middleclass (from shared module)
local MiddlePlayer = middleclass('Player')
function MiddlePlayer:initialize(name) end

-- 30log (from client module)
local Log30Player = yon30log("Player")
function Log30Player:initialize(name) end

-- Use middleclass for:
-- - Shared code (server + client)
-- - Full-featured OOP
-- - Core game logic

-- Use 30log for:
-- - Client-side code
-- - Compact OOP ("30 Lines Of Goodness")
-- - Simple class hierarchies
```

### Type Checking and Instance Management

```lua
local Enemy = yon30log("Enemy")

function Enemy:initialize(name, type)
    self.name = name
    self.type = type
    self.health = 50
end

-- Create instances
local zombie = Enemy:new("Zombie", "undead")
local skeleton = Enemy:new("Skeleton", "undead")

-- Type checking with instanceOf()
if zombie:instanceOf(Enemy) then
    print("Zombie is an Enemy instance")
end

-- Get all instances of a class
local all_enemies = Enemy:instances()
print("Total enemies: " .. #all_enemies)

-- Check if something is a class
if yon30log.isClass(Enemy) then
    print("Enemy is a valid class")
end

-- Check if something is an instance
if yon30log.isInstance(zombie) then
    print("Zombie is an instance")
end
```

---

## Practical Examples

### Example 1: Debug Helper Module

```lua
local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua

if not inspect then
    error("inspectlua required for debug helpers")
end

local Debug = {}

function Debug.log_table(name, tbl, depth)
    depth = depth or 2
    print("\n[DEBUG] " .. name)
    print(inspect(tbl, {depth = depth}))
end

function Debug.log_player(player)
    if not player then return end
    Debug.log_table("Player", {
        name = player:getUsername(),
        health = player:getHealth(),
        x = player:getX(),
        y = player:getY(),
        z = player:getZ()
    }, 1)
end

function Debug.log_inventory(inventory)
    if not inventory then return end
    Debug.log_table("Inventory", {
        size = inventory:getSize(),
        count = inventory:getItemCount()
    }, 1)
end

return Debug
```

### Example 2: Configuration Manager

```lua
local pz_commons = require("pz_lua_commons/client")
local serpent = pz_commons.pkulchenko.serpent

if not serpent then
    error("serpent required for config manager")
end

local ConfigManager = {}
ConfigManager.filepath = "modconfig.lua"

function ConfigManager:load()
    local file = io.open(self.filepath, "r")
    if not file then
        return {}
    end
    
    local content = file:read("*all")
    file:close()
    
    local success, result = pcall(function()
        return serpent.load(content)()
    end)
    
    return success and result or {}
end

function ConfigManager:save(config)
    local file = io.open(self.filepath, "w")
    if not file then
        print("Failed to save config")
        return false
    end
    
    file:write(serpent.dump(config))
    file:close()
    return true
end

function ConfigManager:get(key, default)
    local config = self:load()
    return config[key] or default
end

return ConfigManager
```

### Example 3: Entity Management with 30log

```lua
local pz_commons = require("pz_lua_commons/client")
local yon30log = pz_commons.yonaba.yon_30log

if not yon30log then
    error("30log required for entity management")
end

local Entity = yon30log("Entity")

function Entity:initialize(name, x, y, z)
    self.name = name
    self.x = x
    self.y = y
    self.z = z
    self.active = true
    print("Entity spawned at (" .. x .. ", " .. y .. ", " .. z .. ")")
end

function Entity:move_to(x, y, z)
    self.x = x
    self.y = y
    self.z = z
    print(self.name .. " moved to (" .. x .. ", " .. y .. ", " .. z .. ")")
end

function Entity:destroy()
    self.active = false
    print("Entity destroyed: " .. self.name)
end

-- Usage
local entity = Entity:new("NPC", 100, 200, 0)
entity:move_to(110, 210, 0)
entity:destroy()
```

### Example 4: Combined Debug and Serialization

```lua
local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua
local serpent = pz_commons.pkulchenko.serpent

if not inspect or not serpent then
    error("Both inspectlua and serpent required")
end

local GameDebugger = {}

function GameDebugger.snapshot(name)
    local snap = {
        timestamp = os.time(),
        paused = isPaused(),
        debug = isDebugEnabled()
    }
    
    print("\n[SNAPSHOT] " .. name)
    print(inspect(snap))
    
    return snap
end

function GameDebugger.save_snapshot(filename, snap)
    local file = io.open(filename, "w")
    if file then
        file:write(serpent.dump(snap))
        file:close()
        return true
    end
    return false
end

function GameDebugger.compare_snapshots(snap1, snap2)
    print("\n[COMPARISON]")
    print("Snapshot 1:")
    print(inspect(snap1, {depth = 1}))
    print("\nSnapshot 2:")
    print(inspect(snap2, {depth = 1}))
end

return GameDebugger
```

---

## Best Practices

### 1. Always Check Client Context

```lua
local pz_commons = require("pz_lua_commons/client")

-- Check availability before using
if not pz_commons.kikito.inspectlua then
    print("WARNING: Client libraries not available (server?)")
    return
end
```

### 2. Use inspect for Debugging

```lua
local function debug_player_state()
    local player = getPlayer()
    if player then
        print(inspect({
            name = player:getUsername(),
            health = player:getHealth()
        }))
    end
end
```

### 3. Use serpent for Config

```lua
-- Save mod configuration
local config = {
    version = "1.0",
    enabled = true,
    settings = {
        debug = true,
        max_items = 64
    }
}

local file = io.open("config.lua", "w")
file:write(serpent.dump(config))
file:close()
```

### 4. Use 30log for Client Classes

```lua
-- Create game entities with 30log
local NPC = yon30log("NPC")

function NPC:initialize(name)
    self.name = name
end

function NPC:greet()
    print("Hello, I am " .. self.name)
end

local npc = NPC:new("Guard")
npc:greet()
```

### 5. Safe Library Access

```lua
local function get_library(path)
    local pz_commons = require("pz_lua_commons/client")
    local lib = pz_commons
    
    for part in path:gmatch("[^.]+") do
        if lib then
            lib = lib[part]
        else
            return nil
        end
    end
    
    return lib
end

local inspect = get_library("kikito.inspectlua")
```

### 6. Combine Libraries Effectively

```lua
-- Debug data with inspect, serialize with serpent
local data = {/* ... */}

-- View formatted
print(inspect(data))

-- Save to file
local file = io.open("data.lua", "w")
file:write(serpent.dump(data))
file:close()
```

---

## Complete Example: Debug Console

```lua
local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua
local serpent = pz_commons.pkulchenko.serpent

if not inspect or not serpent then
    error("Debug console requires inspectlua and serpent")
end

local DebugConsole = {}
DebugConsole.commands = {}

function DebugConsole:register_command(name, fn)
    self.commands[name] = fn
end

function DebugConsole:execute(cmd, ...)
    if not self.commands[cmd] then
        print("Unknown command: " .. cmd)
        return
    end
    
    local success, result = pcall(self.commands[cmd], ...)
    
    if success then
        if result then
            print(inspect(result))
        end
    else
        print("Error: " .. tostring(result))
    end
end

-- Register built-in commands
DebugConsole:register_command("player", function()
    return {
        name = getPlayer():getUsername(),
        health = getPlayer():getHealth()
    }
end)

DebugConsole:register_command("save_state", function()
    local state = {timestamp = os.time()}
    local file = io.open("debug_state.lua", "w")
    file:write(serpent.dump(state))
    file:close()
    return "State saved"
end)

return DebugConsole
```

---

## Module Capabilities Summary

### inspectlua
✓ Pretty-print any Lua table
✓ Customizable depth and formatting
✓ Perfect for debugging
✓ Shows structure clearly
✓ Handles nested data well

### serpent
✓ Serialize Lua to readable format
✓ Deserialize back from string
✓ Save/load configuration
✓ More compact than JSON
✓ Lua-native syntax

### 30log
✓ Compact OOP with classes ("30 Lines Of Goodness")
✓ Inheritance and mixins support
✓ Ultra-lightweight implementation
✓ Fast and elegant
✓ Perfect for client-side entity classes

---

## Examples Reference

For complete working examples, see:
- `example_02_inspect_debug.lua`
- `example_03_serpent_serialize.lua`
- `example_04_logging.lua`
- `example_05_combined_utilities.lua`
- `example_11_30log_oop.lua`

---

## Troubleshooting

### Issue: Libraries are nil
**Cause**: Code running on server (client libraries not loaded)
**Solution**:
```lua
if isServer() then
    print("Client libraries not available on server")
    return
end
```

### Issue: inspect() function not found
**Cause**: Module might not have loaded
**Solution**:
```lua
if not pz_commons.kikito.inspectlua then
    print("inspectlua unavailable")
    return
end
```

### Issue: serpent.load() not working
**Cause**: Invalid Lua syntax in saved file
**Solution**:
```lua
local success, result = pcall(function()
    return serpent.load(content)()
end)

if not success then
    print("Failed to load: " .. tostring(result))
end
```

---

## Performance Tips

1. **Cache library references** at module load
2. **Use inspect only for debugging**, not production
3. **Limit inspect depth** when tables are complex
4. **Serialize only when needed**, not every frame
5. **Use 30log freely** - it's ultra-lightweight ("30 Lines Of Goodness")

---

## API Quick Reference

```lua
local pz_commons = require("pz_lua_commons/client")

-- inspectlua
pz_commons.kikito.inspectlua(obj, {depth = 2})

-- serpent
pz_commons.pkulchenko.serpent.dump(obj)
pz_commons.pkulchenko.serpent.load(str)()
pz_commons.pkulchenko.serpent.line(obj)

-- 30log
local MyClass = pz_commons.yonaba.yon_30log("ClassName")
function MyClass:initialize(...) end
local instance = MyClass:new(...)
instance:instanceOf(MyClass)
MyClass:instances()
```

---

## Additional Notes

- Client libraries are **client-side only**
- Safe to require everywhere, but will return nil on server
- Combine with shared libraries (middleclass) as needed
- Perfect for mod development and debugging
- Use with Project Zomboid client API for full power
