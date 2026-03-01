# PZ Lua Commons - Client Module Guide

Complete reference for the **Client** module of `pz_lua_commons`, which provides client-side debugging, serialization, and object-oriented programming tools for Project Zomboid mod development.

## Quick Start

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD")

local pzc = require("pz_lua_commons_client")

-- Access each library
local inspect   = pzc.kikito.inspectlua      -- callable: inspect(table) → string
local serpent   = pzc.pkulchenko.serpent      -- serpent.dump(), serpent.load()
local _30log    = pzc.yonaba.yon_30log        -- _30log("ClassName") → class
```

## Important: Client-Only Module

This module **only loads on client-side**. The libraries will be `nil` on a dedicated server. Always guard usage:

```lua
if pzc.kikito.inspectlua then
    -- safe to use
end
```

## Table of Contents

1. [Project Structure](#project-structure)
2. [Available Libraries](#available-libraries)
3. [inspectlua (Kikito)](#inspectlua-kikito)
4. [serpent (pkulchenko)](#serpent-pkulchenko)
5. [30log (yonaba)](#30log-yonaba)
6. [Test Suite Reference](#test-suite-reference)
7. [Test Runner Pattern](#test-runner-pattern)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Project Structure

The `pz_lua_commons_test` mod validates the client module. Its file layout:

```
pz_lua_commons_test/
├── 42/
│   ├── mod.info
│   └── media/lua/client/pz_lua_commons_test/
│       ├── client.lua          -- Entry point: loads pzc, smoke-tests inspectlua
│       └── test_client.lua     -- Full test suite (10 tests)
├── PZ_LUA_COMMONS_CLIENT_GUIDE.md   (this file)
├── PZ_LUA_COMMONS_COMPLETE_GUIDE.md
├── PZ_LUA_COMMONS_SHARED_GUIDE.md
└── PZ_UTILS_GUIDE.md
```

### mod.info

```ini
id=pz_lua_commons_test
name=PZLuaCommons Test
poster=poster.png
icon=icon.png
require=\pz_lua_commons
```

The `require=\pz_lua_commons` line declares a hard dependency so the commons libraries are loaded first.

---

## Available Libraries

| Library | Namespace | Author | Purpose | Type |
|---------|-----------|--------|---------|------|
| **inspectlua** | `pzc.kikito.inspectlua` | Kikito | Table inspection / debugging | Debug |
| **serpent** | `pzc.pkulchenko.serpent` | pkulchenko | Data serialization | Serialization |
| **30log** | `pzc.yonaba.yon_30log` | yonaba | Object-oriented programming | OOP |

---

## inspectlua (Kikito)

Pretty-prints any Lua value into a human-readable string. The module itself is callable.

### Access

```lua
local pzc = require("pz_lua_commons_client")
local inspect = pzc.kikito.inspectlua   -- callable table
```

### API

| Call | Parameters | Returns | Description |
|------|-----------|---------|-------------|
| `inspect(obj)` | `obj: any` | `string` | Formatted string representation |
| `inspect(obj, opts)` | `obj: any, opts: table` | `string` | With formatting options |

### Basic Usage

```lua
local test_table = { a = 1, b = 2, c = { nested = true } }
local result = inspect(test_table)   -- returns a string
print(result)
```

### Options

```lua
-- Limit inspection depth
inspect(data, { depth = 1 })

-- Custom indent
inspect(data, { indent = "    " })

-- Custom newline
inspect(data, { newline = "\n" })
```

### Debugging Example

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD")

local pzc = require("pz_lua_commons_client")
local inspect = pzc.kikito.inspectlua

if inspect then
    local player_data = {
        name = "Alice",
        health = 95,
        inventory = { "sword", "shield", "potion" },
    }
    _logger:log(inspect(player_data))
end
```

---

## serpent (pkulchenko)

Serialization library for converting Lua values to string representation and back.

### Access

```lua
local pzc = require("pz_lua_commons_client")
local serpent = pzc.pkulchenko.serpent
```

### API

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `serpent.dump(obj)` | `obj: any` | `string` | Serialize to loadable Lua string |
| `serpent.load(str)` | `str: string` | `ok, value` | Deserialize from string |
| `serpent.line(obj)` | `obj: any` | `string` | One-line serialization |

### Basic Usage

```lua
local data = { x = 10, y = 20 }

-- Serialize
local dumped = serpent.dump(data)   -- returns a string
print(type(dumped))                 -- "string"

-- Deserialize
local ok, restored = serpent.load(dumped)
if ok then
    print(restored.x, restored.y)   -- 10  20
end
```

### Save / Load Configuration

```lua
-- Save
local config = { version = "1.0", debug = true, max_items = 64 }
local file = io.open("config.lua", "w")
file:write(serpent.dump(config))
file:close()

-- Load
local file = io.open("config.lua", "r")
local content = file:read("*a")
file:close()
local ok, loaded_config = serpent.load(content)
```

---

## 30log (yonaba)

Minimal OOP library — "30 Lines Of Goodness". Creates classes with inheritance.

### Access

```lua
local pzc = require("pz_lua_commons_client")
local _30log = pzc.yonaba.yon_30log
```

### API

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `_30log("Name")` | `name: string` | `class` | Create a new class |
| `_30log.isClass(obj)` | `obj: any` | `boolean` | Check if value is a class |
| `_30log.isInstance(obj)` | `obj: any` | `boolean` | Check if value is an instance |
| `MyClass:new(...)` | variadic | `instance` | Instantiate a class |
| `instance:instanceOf(cls)` | `cls: class` | `boolean` | Check instance's class |

### Basic Usage

```lua
local MyClass = _30log("MyClass")

function MyClass:initialize(name)
    self.name = name
end

function MyClass:greet()
    return "Hello, I am " .. self.name
end

local obj = MyClass:new("Guard")
print(obj:greet())                    -- "Hello, I am Guard"
print(_30log.isClass(MyClass))        -- true
print(_30log.isInstance(obj))          -- true
print(obj:instanceOf(MyClass))        -- true
```

### Inheritance

```lua
local Animal = _30log("Animal")
function Animal:initialize(name)
    self.name = name
end

local Dog = Animal:extend("Dog")
function Dog:bark()
    return self.name .. " says woof!"
end

local d = Dog:new("Rex")
print(d:bark())                       -- "Rex says woof!"
print(d:instanceOf(Animal))           -- true
```

---

## Test Suite Reference

The test suite lives in `42/media/lua/client/pz_lua_commons_test/test_client.lua` and validates every library exposed by the client module.

### Entry Point — `client.lua`

`42/media/lua/client/pz_lua_commons_test/client.lua` is the mod's entry point. It:

1. Requires `pz_utils_shared` and creates a `SafeLogger`
2. Requires `pz_lua_commons_client` into `pzc`
3. Logs a load confirmation
4. Smoke-tests `pzc.kikito.inspectlua` availability

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_CLIENT")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_client")

safeLog("Client: Loaded")

if pzc.kikito.inspectlua then
    safeLog("TEST use inspectlua")
end
```

### Full Test Suite — `test_client.lua`

The file exports `{ run = run_tests }`. The `run_tests` function executes 10 tests organized into structural checks and functional checks.

#### Structural Tests (Tests 1–4)

| Test | Assertion | What it validates |
|------|-----------|-------------------|
| 1 | `assert_type(pzc, "table", ...)` | `pzc` loaded correctly |
| 2 | `assert_type(pzc.kikito, "table", ...)` | `kikito` namespace exists |
| 3 | `assert_type(pzc.pkulchenko, "table", ...)` | `pkulchenko` namespace exists |
| 4 | `assert_type(pzc.yonaba, "table", ...)` | `yonaba` namespace exists |

#### Library Availability Tests (Tests 5–7)

| Test | What it validates |
|------|-------------------|
| 5 | `pzc.kikito.inspectlua` is a table; checks for `.inspect` function or callable table |
| 6 | `pzc.pkulchenko.serpent` is a table; has `.dump` (function) and `.load` (function) |
| 7 | `pzc.yonaba.yon_30log` is a table; has `.isClass` (function) |

#### Functional Tests (Tests 8–10)

| Test | What it validates |
|------|-------------------|
| 8 | `inspect({ a = 1, b = 2, c = { nested = true } })` returns a `string` |
| 9 | `serpent.dump({ x = 10, y = 20 })` returns a `string` |
| 10 | `_30log("MyClass")` creates a class (`isClass` → true), `MyClass:new()` creates an instance (`isInstance` → true) |

Each functional test is wrapped in `pcall` so a failure in one library does not abort the suite.

### Module Export

```lua
return {
    run = run_tests,
}
```

---

## Test Runner Pattern

The test suite defines two assertion helpers and a results-collection pattern that can be reused in your own test modules.

### `assert_equal(actual, expected, test_name)`

Compares two values with `==`. Records pass/fail into `test_results`.

```lua
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
```

### `assert_type(value, expected_type, test_name)`

Checks `type(value) == expected_type`. Records pass/fail with the actual type on failure.

```lua
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
```

### `pcall` Wrapping for Functional Tests

Each functional test is wrapped so errors are caught without aborting:

```lua
local success = pcall(function()
    local test_table = { a = 1, b = 2, c = { nested = true } }
    local result = inspect(test_table)
    assert_type(result, "string", "inspectlua returns a string representation")
end)

if not success then
    table.insert(test_results, {
        name = "inspectlua can inspect tables",
        passed = false,
    })
end
```

### Results Reporting

After all tests run, results are logged with pass/fail counts:

```lua
safeLog("\n=== Client Modules Test Results ===")
local passed = 0
local failed = 0
for _, result in ipairs(test_results) do
    if result.passed then
        safeLog("✓ " .. result.name)
        passed = passed + 1
    else
        safeLog("✗ " .. result.name)
        if result.note then
            safeLog("  Note: " .. result.note)
        end
        failed = failed + 1
    end
end
safeLog("Passed: " .. passed .. "/" .. (passed + failed))
```

---

## Best Practices

### 1. Cache Library References

```lua
local pzc     = require("pz_lua_commons_client")
local inspect = pzc.kikito.inspectlua
local serpent = pzc.pkulchenko.serpent
local _30log  = pzc.yonaba.yon_30log
```

### 2. Use SafeLogger, Not `print`

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD")

if inspect then
    _logger:log(inspect(some_table))
end
```

### 3. Guard Before Use

```lua
if pzc.kikito.inspectlua then
    -- safe
end

if pzc.pkulchenko.serpent then
    -- safe
end
```

### 4. Use `inspect` for Debugging Only

`inspect` is for development. Avoid calling it in hot paths or production loops.

### 5. Limit Inspection Depth

```lua
inspect(deep_table, { depth = 2 })
```

### 6. Wrap Functional Calls in `pcall`

Follow the test suite pattern — wrap library calls in `pcall` when stability matters:

```lua
local ok, err = pcall(function()
    local dumped = serpent.dump(data)
    -- ...
end)
if not ok then
    _logger:log("serpent error: " .. tostring(err))
end
```

---

## Troubleshooting

### Libraries are nil

**Cause**: Code running on server (client libraries not loaded).
**Solution**: Check context before using:

```lua
if pzc.kikito.inspectlua then
    -- use it
end
```

### inspect() not found

**Cause**: `inspectlua` is a callable table, not a plain function. Access it as `pzc.kikito.inspectlua`, then call it directly.

```lua
local inspect = pzc.kikito.inspectlua
local result = inspect({ a = 1 })   -- call it directly
```

### serpent.load() returns unexpected results

**Cause**: `serpent.load` returns two values: `ok` (boolean) and the deserialized value.

```lua
local ok, value = serpent.load(serialized_string)
if ok then
    -- use value
end
```

### Module not found

**Cause**: Missing dependency. Ensure `mod.info` includes `require=\pz_lua_commons`.

---

## API Quick Reference

```lua
local pzc = require("pz_lua_commons_client")

-- inspectlua (callable table)
local str = pzc.kikito.inspectlua(obj)
local str = pzc.kikito.inspectlua(obj, { depth = 2 })

-- serpent
local str       = pzc.pkulchenko.serpent.dump(obj)
local ok, value = pzc.pkulchenko.serpent.load(str)
local str       = pzc.pkulchenko.serpent.line(obj)

-- 30log
local MyClass  = pzc.yonaba.yon_30log("ClassName")
function MyClass:initialize(...) end
local instance = MyClass:new(...)
pzc.yonaba.yon_30log.isClass(MyClass)       -- true
pzc.yonaba.yon_30log.isInstance(instance)    -- true
instance:instanceOf(MyClass)                 -- true
```

---

## Module Capabilities Summary

### inspectlua
- ✓ Pretty-print any Lua value
- ✓ Customizable depth and formatting
- ✓ Callable table interface
- ✓ Handles nested data

### serpent
- ✓ Serialize Lua values to loadable strings
- ✓ Deserialize back with `serpent.load`
- ✓ One-line output with `serpent.line`
- ✓ Lua-native syntax

### 30log
- ✓ Minimal OOP ("30 Lines Of Goodness")
- ✓ Class creation, inheritance, mixins
- ✓ Type introspection (`isClass`, `isInstance`, `instanceOf`)
- ✓ Ultra-lightweight
