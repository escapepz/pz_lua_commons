# PZ Lua Commons — Shared Module Guide

Complete reference for the **Shared** module of `pz_lua_commons`, covering the bundled Lua libraries for JSON processing, object-oriented programming, and event signaling. This guide reflects the actual test codebase in `pz_lua_commons_test`.

## Quick Start

```lua
-- Load dependencies
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD")

-- Load commons shared module
local pzc = require("pz_lua_commons_shared")

-- Access each library
local lunajson   = pzc.grafi_tt.lunajson        -- JSON (grafi-tt)
local middleclass = pzc.kikito.middleclass       -- OOP (kikito)
local jsonlua    = pzc.rxi.jsonlua              -- JSON alternative (rxi)
local signal     = pzc.vrld.hump.signal          -- Event signaling (vrld)
```

## Table of Contents

1. [Module Namespace](#module-namespace)
2. [Logging with pz_utils](#logging-with-pz_utils)
3. [lunajson (grafi_tt)](#lunajson-grafi_tt)
4. [middleclass (kikito)](#middleclass-kikito)
5. [jsonlua (rxi)](#jsonlua-rxi)
6. [hump.signal (vrld)](#humpsignal-vrld)
7. [Test Structure](#test-structure)
8. [Test Patterns](#test-patterns)
9. [Best Practices](#best-practices)

---

## Module Namespace

```
pzc                             -- require("pz_lua_commons_shared")
├── grafi_tt
│   └── lunajson                -- JSON encode/decode
├── kikito
│   └── middleclass             -- OOP class system
├── rxi
│   └── jsonlua                 -- Alternative JSON encode/decode
└── vrld
    └── hump
        └── signal              -- Event signaling system
```

| Library | Namespace Path | Purpose |
|---------|---------------|---------|
| **lunajson** | `pzc.grafi_tt.lunajson` | JSON encoding/decoding |
| **middleclass** | `pzc.kikito.middleclass` | Object-oriented programming |
| **jsonlua** | `pzc.rxi.jsonlua` | Alternative JSON library |
| **hump.signal** | `pzc.vrld.hump.signal` | Event signaling system |

---

## Logging with pz_utils

All test files use the `pz_utils` logging pattern:

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_TAG")

local function safeLog(msg, level)
    _logger:log(msg, level)
end

safeLog("Something happened")
```

---

## lunajson (grafi_tt)

High-performance JSON encoding and decoding for Lua.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `encode` | `obj: any, state: table\|nil` | `string` | Convert Lua value to JSON string |
| `decode` | `str: string` | `any` | Parse JSON string into Lua value |

### Basic Usage

```lua
local lunajson = pzc.grafi_tt.lunajson

-- Encode Lua table to JSON
local data = {
    name = "Player",
    health = 100,
    items = {"sword", "shield", "potion"}
}
local json_str = lunajson.encode(data)

-- Decode JSON string to Lua table
local decoded = lunajson.decode(json_str)
print(decoded.name)    -- "Player"
print(decoded.health)  -- 100
```

### Round-Trip (from test_shared.lua, Test 12)

The test suite validates that encode→decode preserves values:

```lua
local json = pzc.grafi_tt.lunajson
local test_data = { key = "value", num = 123 }

local success = pcall(function()
    local encoded = json.encode(test_data)
    local decoded = json.decode(encoded)
    assert(decoded.key == test_data.key)  -- string preserved
    assert(decoded.num == test_data.num)  -- number preserved
end)
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
        safeLog("JSON decode error: " .. tostring(result))
        return nil
    end
end
```

---

## middleclass (kikito)

Object-oriented programming framework for Lua using classes and inheritance.

### Basic Class Definition

```lua
local middleclass = pzc.kikito.middleclass

local Animal = middleclass('Animal')

function Animal:initialize(name)
    self.name = name
end

function Animal:speak()
    print(self.name .. " makes a sound")
end

local dog = Animal("Buddy")
dog:speak()  -- "Buddy makes a sound"
```

### Inheritance

```lua
local Dog = middleclass('Dog', Animal)

function Dog:initialize(name, breed)
    Animal.initialize(self, name)  -- Call parent constructor
    self.breed = breed
end

function Dog:speak()
    print(self.name .. " barks!")
end

local buddy = Dog("Buddy", "Golden Retriever")
buddy:speak()       -- "Buddy barks!"
print(buddy.breed)  -- "Golden Retriever"
```

### Type Checking

```lua
local Player = middleclass('Player')
local NPC = middleclass('NPC')

local player = Player("Alice")
print(player:is_a(Player))            -- true
print(player:is_a(NPC))               -- false
print(player:is_instance_of(Player))  -- true
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

Alternative JSON library with a simpler implementation.

### Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `encode` | `obj: any` | `string` | Convert Lua value to JSON |
| `decode` | `str: string` | `any` | Parse JSON string |

### Basic Usage

```lua
local json = pzc.rxi.jsonlua

local data = { name = "Item", count = 5 }
local json_str = json.encode(data)

local decoded = json.decode(json_str)
print(decoded.name)  -- "Item"
```

### Fallback Pattern

```lua
local lunajson = pzc.grafi_tt.lunajson
local jsonlua  = pzc.rxi.jsonlua

local function safe_json_encode(obj)
    local success, result = pcall(function()
        return lunajson.encode(obj)
    end)
    if not success then
        return jsonlua.encode(obj)
    end
    return result
end
```

---

## hump.signal (vrld)

Event signaling and subscription system for decoupled communication.

### API Reference

| Function | Parameters | Description |
|----------|-----------|-------------|
| `register` | `name: string, fn: function` | Register a callback for a named event |
| `emit` | `name: string, ...` | Fire a named event with arguments |
| `remove` | `name: string, fn: function` | Remove a specific callback |
| `clear` | `name: string` | Remove all callbacks for an event |
| `registerPattern` | `pattern: string, fn: function` | Register callback for events matching a Lua pattern |
| `emitPattern` | `pattern: string` | Emit all events matching a Lua pattern |
| `new` | — | Create a new independent signal instance |

### Basic Register and Emit

```lua
local signal = pzc.vrld.hump.signal

signal.register("game:started", function()
    print("Game has started!")
end)

signal.emit("game:started")
```

### Emit with Parameters

From test_signal.lua (Test 9):

```lua
signal.register("param_event", function(a, b, c)
    print(a, b, c)  -- 1, "hello", true
end)

signal.emit("param_event", 1, "hello", true)
```

### Multiple Callbacks (Test 10)

```lua
signal.register("multi_event", function() print("callback 1") end)
signal.register("multi_event", function() print("callback 2") end)

signal.emit("multi_event")  -- Both callbacks fire
```

### Remove and Clear (Tests 11–12)

```lua
local function on_event()
    print("Event fired")
end

-- Remove a specific callback
signal.register("my:event", on_event)
signal.remove("my:event", on_event)
signal.emit("my:event")  -- No output

-- Clear all callbacks for an event
signal.register("my:event", on_event)
signal.clear("my:event")
signal.emit("my:event")  -- No output
```

### Pattern Registration and Emit (Tests 13–14)

```lua
-- registerPattern: callback fires for any event matching the Lua pattern
signal.registerPattern("foo.*", function()
    print("A foo event occurred")
end)
signal.emit("foo_event")  -- Triggers the pattern callback

-- emitPattern: emit all events matching the pattern
signal.registerPattern("bar.*", function()
    print("A bar event occurred")
end)
signal.emitPattern("bar.*")  -- Triggers matching callbacks
```

### Independent Instances (Tests 15–16)

```lua
local instance_1 = signal.new()
local instance_2 = signal.new()

instance_1:register("my_event", function() print("instance 1") end)
instance_2:register("my_event", function() print("instance 2") end)

instance_1:emit("my_event")  -- Only "instance 1" prints
-- instance_2's callback is NOT called
```

---

## Test Structure

### File Layout

```
42/media/lua/shared/pz_lua_commons_test/
├── shared.lua           -- Entry point: loads pzc, smoke-tests lunajson availability
├── test_shared.lua      -- Shared modules test suite (13 tests)
└── test_signal.lua      -- Detailed hump.signal test suite (16 tests)
```

### shared.lua — Entry Point

Loads `pz_lua_commons_shared`, verifies it is reachable, and smoke-tests lunajson availability:

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_shared")
safeLog("Shared: Loaded")

if pzc.grafi_tt.lunajson then
    safeLog("TEST use lunajson")
end
```

### test_shared.lua — Shared Modules Test Suite (13 tests)

| Test | What It Validates |
|------|-------------------|
| 1 | `pzc` is a table |
| 2 | `pzc.grafi_tt` namespace exists |
| 3 | `pzc.kikito` namespace exists |
| 4 | `pzc.rxi` namespace exists |
| 5 | `pzc.vrld` namespace exists |
| 6 | `lunajson` is available and is a table |
| 7 | `middleclass` is available and is a table |
| 8 | `jsonlua` is available and is a table |
| 9 | `hump.signal` is available and is a table |
| 10 | `hump.signal.register` is a function |
| 11 | `hump.signal.emit` is a function |
| 12 | lunajson encode→decode round-trip preserves strings and numbers |
| 13 | hump.signal register + emit triggers callback |

### test_signal.lua — Signal Module Test Suite (16 tests)

| Test | What It Validates |
|------|-------------------|
| 1 | `signal` is a table |
| 2 | `signal.register` is a function |
| 3 | `signal.emit` is a function |
| 4 | `signal.remove` is a function |
| 5 | `signal.clear` is a function |
| 6 | `signal.emitPattern` is a function |
| 7 | `signal.registerPattern` is a function |
| 8 | Basic register and emit triggers callback |
| 9 | Emit passes parameters correctly (1, "hello", true) |
| 10 | Multiple distinct callbacks on same event both fire |
| 11 | `remove` prevents a removed callback from firing |
| 12 | `clear` prevents all cleared callbacks from firing |
| 13 | `registerPattern("foo.*", fn)` matches emitted `"foo_event"` |
| 14 | `emitPattern("bar.*")` triggers pattern-matched callbacks |
| 15 | `signal.new()` creates new table instances |
| 16 | New instances are independent — emitting on one does not fire the other |

---

## Test Patterns

### Module Export Convention

Every test file exports `{ run = run_tests }`:

```lua
local function run_tests()
    -- ... tests ...
    return test_results
end

return {
    run = run_tests,
}
```

### Assert Helpers

Each test file defines local assertion helpers that populate a `test_results` table:

```lua
local test_results = {}

local function assert_equal(actual, expected, test_name)
    if actual == expected then
        table.insert(test_results, { name = test_name, passed = true })
        return true
    else
        table.insert(test_results, {
            name = test_name,
            passed = false,
            expected = expected,
            actual = actual,
        })
        return false
    end
end

local function assert_type(value, expected_type, test_name)
    if type(value) == expected_type then
        table.insert(test_results, { name = test_name, passed = true })
        return true
    else
        table.insert(test_results, {
            name = test_name,
            passed = false,
            expected_type = expected_type,
            actual_type = type(value),
        })
        return false
    end
end

local function assert_not_nil(value, test_name)
    if value ~= nil then
        table.insert(test_results, { name = test_name, passed = true })
        return true
    else
        table.insert(test_results, { name = test_name, passed = false })
        return false
    end
end
```

### pcall Wrapping for Functional Tests

Functional tests (encode/decode, signal register/emit) are wrapped in `pcall` so a runtime error is caught as a test failure rather than aborting the suite:

```lua
local success = pcall(function()
    local encoded = json.encode(test_data)
    local decoded = json.decode(encoded)
    assert_equal(decoded.key, test_data.key, "preserves string values")
end)

if not success then
    table.insert(test_results, {
        name = "encode/decode works",
        passed = false,
    })
end
```

### Result Reporting

After all tests, results are logged with pass/fail counts:

```lua
safeLog("\n=== Test Results ===")
local passed = 0
local failed = 0
for _, result in ipairs(test_results) do
    if result.passed then
        safeLog("✓ " .. result.name)
        passed = passed + 1
    else
        safeLog("✗ " .. result.name)
        failed = failed + 1
    end
end
safeLog("Passed: " .. passed .. "/" .. (passed + failed))
```

---

## Best Practices

### 1. Use the Correct Require Paths

```lua
-- ✓ Correct
local pzc      = require("pz_lua_commons_shared")
local pz_utils = require("pz_utils_shared")

-- ✗ Wrong
-- require("pz_lua_commons/shared")
-- require("pz_utils/shared")
```

### 2. Check Library Availability

```lua
local pzc = require("pz_lua_commons_shared")

if pzc.grafi_tt.lunajson then
    safeLog("lunajson available")
else
    safeLog("lunajson not available - check installation")
end
```

### 3. Use Consistent JSON Library

```lua
-- Pick one and stick with it in your mod
local json = pzc.grafi_tt.lunajson  -- Recommended
-- Don't mix lunajson.encode with jsonlua.decode
```

### 4. Error Handling for JSON

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

### 5. Signal Naming Conventions

```lua
-- Use colon-separated names for clarity
signal.emit("module:action")          -- "player:died"
signal.emit("module:object:action")   -- "item:weapon:equipped"
```

### 6. Clean Up Signals

```lua
-- Clear before registering in tests to avoid leftover state
signal.clear("my_event")
signal.register("my_event", callback)
```

### 7. Use Independent Signal Instances for Isolation

```lua
-- Create a scoped instance so your mod doesn't interfere with others
local my_signals = signal.new()
my_signals:register("internal:event", handler)
my_signals:emit("internal:event")
```

---

## Module Capabilities Summary

### lunajson
- High-performance JSON encoding/decoding
- Full Lua data type support (strings, numbers, booleans, nil, tables)
- Handles nested structures
- Suitable for save files and data serialization

### middleclass
- Full OOP with classes and inheritance
- Mixins for code reuse
- Type checking (`is_a`, `is_instance_of`)
- Class methods and instance methods

### jsonlua
- Alternative JSON implementation
- Handles standard JSON types
- Fallback if lunajson is unavailable

### hump.signal
- Publish-subscribe event system
- Multiple listeners per signal
- Pattern-based registration and emission
- Independent instances via `signal.new()`
- Lightweight and decoupled communication

---

## API Quick Reference

```lua
local pzc = require("pz_lua_commons_shared")

-- lunajson
pzc.grafi_tt.lunajson.encode(obj)
pzc.grafi_tt.lunajson.decode(str)

-- middleclass
local MyClass = pzc.kikito.middleclass('MyClass')
local Sub = pzc.kikito.middleclass('Sub', MyClass)

-- jsonlua
pzc.rxi.jsonlua.encode(obj)
pzc.rxi.jsonlua.decode(str)

-- hump.signal
pzc.vrld.hump.signal.register(name, fn)
pzc.vrld.hump.signal.emit(name, ...)
pzc.vrld.hump.signal.remove(name, fn)
pzc.vrld.hump.signal.clear(name)
pzc.vrld.hump.signal.registerPattern(pattern, fn)
pzc.vrld.hump.signal.emitPattern(pattern)
pzc.vrld.hump.signal.new()
```

---

## Troubleshooting

### Module returns nil
Check that the require path is correct — it must be `require("pz_lua_commons_shared")`, not a slash-separated path.

### JSON encoding fails
Ensure all values are JSON-serializable (no functions, userdata, or circular references):
```lua
-- ✗ Functions can't be serialized
local data = { fn = function() end }

-- ✓ Only data
local data = { value = 42, name = "test" }
```

### Signal not firing
Verify that the signal name matches exactly between `register` and `emit`:
```lua
-- These DON'T match:
signal.register("player:died", fn)
signal.emit("player:death", ...)

-- Must be exact:
signal.register("player:died", fn)
signal.emit("player:died", ...)
```

### Leftover signal state in tests
Use `signal.clear(name)` before registering to avoid callbacks from previous test runs polluting results.
