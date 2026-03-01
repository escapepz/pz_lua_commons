# PZ Lua Commons - Complete Guide

Comprehensive guide to all modules in the **pz_lua_commons** framework for Project Zomboid mod development.

## Overview

**pz_lua_commons** provides three integrated modules:

| Module                      | Context | Require Path                        | Purpose               | Libraries                   |
| --------------------------- | ------- | ----------------------------------- | --------------------- | --------------------------- |
| **pz_utils**                | Shared  | `require("pz_utils_shared")`        | Utilities and helpers  | Escape, Konijima            |
| **pz_lua_commons (Shared)** | Shared  | `require("pz_lua_commons_shared")`  | Core libraries         | JSON, OOP, Events           |
| **pz_lua_commons (Client)** | Client  | `require("pz_lua_commons_client")`  | Debug/dev tools        | Inspect, Serialization, OOP |

## Module Hierarchy

```
pz_lua_commons/
├── pz_utils/
│   ├── escape/              (Escape Utilities)
│   │   ├── debounce
│   │   ├── event_management
│   │   ├── safe_logger
│   │   ├── safe_require
│   │   └── utilities
│   └── konijima/            (Konijima Utilities)
│       └── utilities
├── shared/                  (Shared Module)
│   └── pz_lua_commons/
│       ├── grafi-tt/        (lunajson)
│       ├── kikito/          (middleclass)
│       ├── rxi/             (jsonlua)
│       └── vrld/            (hump.signal)
└── client/                  (Client Module - CLIENT ONLY)
    └── pz_lua_commons/
        ├── kikito/          (inspectlua)
        ├── pkulchenko/      (serpent)
        └── yonaba/          (30log)
```

## Test Project File Structure

The `pz_lua_commons_test` project (mod id: `pz_lua_commons_test`, requires `\pz_lua_commons`) validates all library modules:

```
pz_lua_commons_test/
├── 42/
│   ├── mod.info                                        (id=pz_lua_commons_test, require=\pz_lua_commons)
│   ├── media/lua/client/pz_lua_commons_test/
│   │   ├── client.lua                                  (client entry point)
│   │   └── test_client.lua                             (client test suite — 10 tests)
│   ├── media/lua/shared/pz_lua_commons_test/
│   │   ├── shared.lua                                  (shared entry point)
│   │   ├── test_runner.lua                             (central test runner)
│   │   ├── test_safelogger.lua                         (SafeLogger test suite — 6 tests)
│   │   ├── test_shared.lua                             (shared modules test suite — ~13 tests)
│   │   └── test_signal.lua                             (hump.signal test suite — 16 tests)
│   └── media/lua/server/
│       └── .gitkeep
├── common/
│   ├── media/lua/shared/
│   │   ├── test_pz_utils_escape.lua                    (Escape utilities tests — ~30 tests)
│   │   └── test_pz_utils_konijima.lua                  (Konijima utilities tests — ~30 tests)
│   ├── icon.png
│   └── poster.png
├── PZ_LUA_COMMONS_CLIENT_GUIDE.md
├── PZ_LUA_COMMONS_SHARED_GUIDE.md
├── PZ_LUA_COMMONS_COMPLETE_GUIDE.md                    (this file)
└── PZ_UTILS_GUIDE.md
```

## Quick Start by Use Case

### I want to work with JSON data

```lua
local pzc = require("pz_lua_commons_shared")
local json = pzc.grafi_tt.lunajson

local data = {name = "player", health = 100}
local json_str = json.encode(data)
local restored = json.decode(json_str)
```

### I want to create classes and objects

```lua
local pzc = require("pz_lua_commons_shared")
local class = pzc.kikito.middleclass

local Player = class('Player')
function Player:initialize(name)
    self.name = name
end

local player = Player("Alice")
```

### I want to emit and listen to events

```lua
local pzc = require("pz_lua_commons_shared")
local signal = pzc.vrld.hump.signal

signal.register("player:died", function(name)
    print(name .. " died!")
end)

signal.emit("player:died", "Zombie")
```

### I want to debug a table on client

```lua
if isServer() then return end
local pzc = require("pz_lua_commons_client")
local inspect = pzc.kikito.inspectlua

print(inspect({a = 1, b = {c = 2}}))
```

### I want to save/load configuration

```lua
if isServer() then return end
local pzc = require("pz_lua_commons_client")
local serpent = pzc.pkulchenko.serpent

local config = {debug = true, version = "1.0"}
local file = io.open("config.lua", "w")
file:write(serpent.dump(config))
file:close()
```

### I want debounced callbacks

```lua
local pz_utils = require("pz_utils_shared")
local Debounce = pz_utils.escape.Debounce

Debounce.Call("my_debounce", 5, function(args)
    print("Debounced!")
end)

-- In game loop: Debounce.Update()
```

### I want safe logging

```lua
local pz_utils = require("pz_utils_shared")
local SafeLogger = pz_utils.escape.SafeLogger

local logger = SafeLogger.new("MyMod")
logger:log("Hello world!", "INFO")
logger:log("Debug info", 20)  -- 20 = DEBUG
```

## Logging Pattern

All test files in this project use the same logging pattern:

```lua
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("TAG")
local function safeLog(msg, level)
    _logger:log(msg, level)
end
```

## Module Loading

### Safe Loading Pattern

```lua
local pz_utils = nil
local pzc_shared = nil
local pzc_client = nil

local success, result = pcall(function()
    pz_utils = require("pz_utils_shared")
end)

if success then
    success, result = pcall(function()
        pzc_shared = require("pz_lua_commons_shared")
    end)
end

if not isServer() then
    success, result = pcall(function()
        pzc_client = require("pz_lua_commons_client")
    end)
end

if pz_utils then
    local logger = pz_utils.escape.SafeLogger.new("MyMod")
    -- ...
end
```

## All Available Libraries

### pz_utils (via `require("pz_utils_shared")`)

#### Escape Utilities

Access via `pz_utils.escape` or `pz_utils[1]` (alternate indexing):

```lua
local pz_utils = require("pz_utils_shared")
local escape = pz_utils.escape

-- SafeLogger
local logger = escape.SafeLogger.new("ModName")
logger:log(msg)              -- default level
logger:log(msg, "INFO")      -- string level: TRACE, DEBUG, INFO, WARN, ERROR, FATAL
logger:log(msg, 30)          -- numeric level: 10=TRACE, 20=DEBUG, 30=INFO, 40=WARN, 50=ERROR, 60=FATAL

-- Debounce
escape.Debounce.Call(id, delay, callback, ...)
escape.Debounce.Update()            -- returns boolean
escape.Debounce.Cancel(id)          -- returns boolean
escape.Debounce.CancelAll()         -- returns count
escape.Debounce.IsActive(id)        -- returns boolean

-- EventManager
local event = escape.EventManager.createEvent(name)
event:Add(callback)
event:Remove(callback)
event:Trigger(...)
event:SetEnabled(bool)
event:IsEnabled()
event:GetListenerCount()
event:IsExecuting()

escape.EventManager.on(name, callback)      -- shorthand
escape.EventManager.off(name, callback)     -- shorthand
escape.EventManager.trigger(name, ...)      -- shorthand
escape.EventManager.getEventInfo(name)
escape.EventManager.getAllEventsInfo()

-- SafeRequire
escape.SafeRequire(path, label)             -- returns module or nil

-- Utilities
escape.Utilities.GetIRLTimestamp()           -- returns number
```

#### Konijima Utilities

```lua
local pz_utils = require("pz_utils_shared")
local konijima = pz_utils.konijima.Utilities

-- Environment detection
konijima.IsSinglePlayer()                   -- returns boolean
konijima.IsSinglePlayerDebug()              -- returns boolean
konijima.IsClientOnly()                     -- returns boolean
konijima.IsClientOrSinglePlayer()           -- returns boolean
konijima.IsServerOrSinglePlayer()           -- returns boolean

-- Admin/staff permissions
konijima.IsClientAdmin()                    -- returns boolean
konijima.IsClientStaff()                    -- returns boolean
konijima.IsPlayerAdmin(playerOrName)

-- String utilities
konijima.SplitString(str, delimiter)        -- returns table

-- Square utilities
konijima.SquareToString(square)             -- returns "x|y|z"
konijima.StringToSquare(str)

-- Commands
konijima.SendClientCommand(module, cmd, data)
konijima.SendServerCommandTo(player, module, cmd, data)
konijima.SendServerCommandToAll(module, cmd, data)
konijima.SendServerCommandToAllInRange(x, y, z, minDist, maxDist, module, cmd, data)

-- Player utilities
konijima.GetPlayerFromUsername(username)
konijima.IsPlayerInRange(player, x, y, z, minDist, maxDist)

-- Electricity
konijima.SquareHasElectricity(square)

-- Server
konijima.GetServerName()                    -- returns string

-- Inventory
konijima.FindAllItemInInventoryByTag(inventory, tag)

-- Moveables
konijima.GetMoveableDisplayName(obj)
```

### Shared Libraries (via `require("pz_lua_commons_shared")`)

```lua
local pzc = require("pz_lua_commons_shared")
```

#### lunajson (`pzc.grafi_tt.lunajson`)

```lua
local lunajson = pzc.grafi_tt.lunajson

lunajson.encode(obj)       -- Lua table to JSON string
lunajson.decode(str)       -- JSON string to Lua table
```

#### middleclass (`pzc.kikito.middleclass`)

```lua
local class = pzc.kikito.middleclass

local Player = class('Player')
function Player:initialize(name) end

local p = Player("Alice")
p:is_a(Player)                      -- Type check
p:is_instance_of(Player)            -- Instance check
```

#### jsonlua (`pzc.rxi.jsonlua`)

```lua
local json = pzc.rxi.jsonlua

json.encode(obj)           -- Lua to JSON
json.decode(str)           -- JSON to Lua
```

#### hump.signal (`pzc.vrld.hump.signal`)

```lua
local signal = pzc.vrld.hump.signal

signal.register(name, fn)           -- Listen to event
signal.emit(name, ...)              -- Fire event
signal.remove(name, fn)             -- Stop listening
signal.clear(name)                  -- Remove all listeners for event
signal.emitPattern(pattern, ...)    -- Emit matching pattern
signal.registerPattern(pattern, fn) -- Register with pattern matching

local instance = signal.new()       -- Create independent signal instance
instance:register(name, fn)
instance:emit(name, ...)
```

### Client-Only Libraries (via `require("pz_lua_commons_client")`)

```lua
local pzc = require("pz_lua_commons_client")
```

#### inspectlua (`pzc.kikito.inspectlua`)

```lua
local inspect = pzc.kikito.inspectlua

local output = inspect({a = 1, b = {nested = true}})  -- returns string representation
print(output)
```

#### serpent (`pzc.pkulchenko.serpent`)

```lua
local serpent = pzc.pkulchenko.serpent

serpent.dump(table)          -- Full serialization (loadable Lua)
serpent.load(str)            -- Deserialize from dump output
serpent.line(table)          -- Single-line representation
serpent.block(table)         -- Multi-line representation
```

#### yon_30log (`pzc.yonaba.yon_30log`)

```lua
local _30log = pzc.yonaba.yon_30log

local MyClass = _30log("MyClass")
_30log.isClass(MyClass)              -- returns true
local instance = MyClass:new()
_30log.isInstance(instance)          -- returns true
```

## Test Runner Architecture

### Orchestration Flow

The `test_runner.lua` in `42/media/lua/shared/pz_lua_commons_test/` orchestrates all test suites:

```
test_runner.run()
  ├─ Load test modules via require()
  │   ├─ test_safelogger  (shared)
  │   ├─ test_shared      (shared)
  │   ├─ test_signal      (shared)
  │   └─ test_client      (client)
  │
  ├─ Run each suite's .run() method sequentially
  │   └─ Each returns array of { name, passed, [expected], [actual] }
  │
  ├─ Aggregate results per suite
  │   └─ Count passed/failed, determine PASS/FAIL status
  │
  └─ Print formatted summary
      ├─ Per-suite: "suite_name    : PASS (N/M)"
      ├─ Total: "TOTAL: X/Y tests passed"
      └─ Final: "✓ ALL TESTS PASSED" or "✗ N TEST(S) FAILED"
```

Return value:

```lua
{
    total_passed = number,
    total_failed = number,
    suites = {
        { name = "safelogger", results = {...} },
        { name = "shared",     results = {...} },
        { name = "signal",     results = {...} },
        { name = "client",     results = {...} },
    }
}
```

### Two Test Framework Styles

This project uses two distinct testing approaches:

#### Module-style (42/ tests)

Used by `test_safelogger`, `test_shared`, `test_signal`, and `test_client`. These are collected and orchestrated by `test_runner.lua`.

```lua
local function run_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("TAG")
    local function safeLog(msg, level) _logger:log(msg, level) end

    local test_results = {}

    local function assert_equal(actual, expected, test_name)
        if actual == expected then
            table.insert(test_results, { name = test_name, passed = true })
        else
            table.insert(test_results, { name = test_name, passed = false,
                expected = expected, actual = actual })
        end
    end

    -- ... tests that populate test_results ...

    return test_results
end

return { run = run_tests }
```

**Characteristics:**
- Returns `{ run = run_tests }` module table
- Uses SafeLogger for output
- Collects results into `test_results` array
- Returned results are aggregated by `test_runner`

#### Standalone-style (common/ tests)

Used by `test_pz_utils_escape` and `test_pz_utils_konijima`. These are self-executing scripts.

```lua
local pz_utils = require("pz_utils_shared")
local escape = pz_utils[1] or pz_utils.escape

local tests = {}
local testsPassed = 0
local testsFailed = 0

local function assert_equals(actual, expected, message)
    if actual == expected then
        testsPassed = testsPassed + 1
    else
        testsFailed = testsFailed + 1
        print("FAIL: " .. message)
    end
end

tests.test_something = function()
    -- test body
end

-- Self-executing runner
for testName, testFunc in pairs(tests) do
    io.write(testName .. " ... ")
    local success, err = pcall(testFunc)
    if success then print("OK") else print("ERROR: " .. tostring(err)) end
end

print("Passed: " .. testsPassed .. " Failed: " .. testsFailed)
```

**Characteristics:**
- Uses `print`/`io.write` for output (not SafeLogger)
- Maintains own `testsPassed`/`testsFailed` counters
- Self-executing: runs all tests on `require` / load
- Tests are functions stored in a `tests` table, iterated with `pairs`

## Test Suites Summary

| Suite | Location | Tests | What It Covers |
| --- | --- | --- | --- |
| **test_safelogger** | `42/.../test_safelogger.lua` | 6 | SafeLogger function type, string/nil/number messages, debug flag |
| **test_shared** | `42/.../test_shared.lua` | ~13 | Namespace checks (grafi_tt, kikito, rxi, vrld), library availability, lunajson encode/decode, signal register/emit |
| **test_signal** | `42/.../test_signal.lua` | 16 | Signal API surface (register/emit/remove/clear/emitPattern/registerPattern), params, multi-callback, independent instances |
| **test_client** | `42/.../test_client.lua` | 10 | Namespace checks (kikito, pkulchenko, yonaba), inspectlua/serpent/yon_30log availability and functionality |
| **test_pz_utils_escape** | `common/.../test_pz_utils_escape.lua` | ~30 | SafeLogger levels, Debounce CRUD (Call/IsActive/Cancel/CancelAll/Update), EventManager full API (create/Add/Remove/Trigger/SetEnabled/on/off/getEventInfo), SafeRequire, Utilities.GetIRLTimestamp |
| **test_pz_utils_konijima** | `common/.../test_pz_utils_konijima.lua` | ~30 | Environment detection (IsSinglePlayer/Debug/ClientOnly), admin/staff permissions, SplitString, square coordinate utilities, commands (SendClientCommand/SendServerCommand*), player utilities, electricity, server info, inventory, moveables |

**Total: ~105 tests across 6 suites**

## Integration Pattern

A complete mod using pz_lua_commons with safe logging:

```lua
-- shared entry point
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_shared")
local signal = pzc.vrld.hump.signal
local json = pzc.grafi_tt.lunajson

-- Register events
signal.register("my_mod:data_changed", function(data)
    local encoded = json.encode(data)
    safeLog("Data changed: " .. encoded)
end)

-- Use debounce for expensive operations
local Debounce = pz_utils.escape.Debounce
Debounce.Call("save_config", 10, function()
    safeLog("Saving config...")
end)
```

## Client-Side Debug Module Pattern

```lua
-- client entry point
local pz_utils = require("pz_utils_shared")
local _logger = pz_utils.escape.SafeLogger.new("MY_MOD_CLIENT")
local function safeLog(msg, level)
    _logger:log(msg, level)
end

local pzc = require("pz_lua_commons_client")
local inspect = pzc.kikito.inspectlua
local serpent = pzc.pkulchenko.serpent

local Debug = {}

function Debug.snapshot(name)
    local snap = {
        time = os.time(),
        paused = isPaused()
    }
    safeLog(name .. ": " .. inspect(snap))
    return snap
end

function Debug.save(filename, data)
    local file = io.open(filename, "w")
    if file then
        file:write(serpent.dump(data))
        file:close()
    end
end

return Debug
```

## Performance Recommendations

### What's Lightweight

- ✓ Debounce — Very fast, O(n) per update where n = active debounces
- ✓ EventManager — Fast emit/receive, O(m) where m = listeners
- ✓ SafeLogger — Negligible when not triggered
- ✓ Utilities — Single calculation, instant return

### What's Medium Weight

- ⚠ middleclass — Class creation is fast, instance creation is normal Lua
- ⚠ 30log — Lightweight OOP framework, can use in production code
- ⚠ hump.signal — Signal emit is fast, register/remove are O(n)
- ⚠ JSON encode/decode — Depends on data size, can be slow for large objects

### What's Heavy/Debug Only

- ✗ inspect — For debugging only, slow on large tables
- ✗ serpent — Serialization is CPU intensive

### Optimization Tips

```lua
-- ✓ Cache library references at module level
local pz_utils = require("pz_utils_shared")
local pzc = require("pz_lua_commons_shared")
local escape = pz_utils.escape
local json = pzc.grafi_tt.lunajson

-- ✗ Don't: Require inside loops
-- for i = 1, 1000 do
--     local escape = require("pz_utils_shared").escape
-- end

-- ✓ Debounce expensive operations
escape.Debounce.Call("expensive_op", 10, expensive_function)

-- ✓ Use JSON for serialization, not inspect
local json_str = json.encode(data)

-- ✗ Don't: Use inspect for production code
-- local str = inspect(data)  -- Much slower

-- ✓ Pre-create classes
local Player = pzc.kikito.middleclass('Player')

-- ✗ Don't: Create classes in hot loops
-- for i = 1, 1000 do
--     local TempClass = class('Temp' .. i)
-- end
```

## Error Handling

### Safe Require Pattern

```lua
local function safe_require_lib(path)
    local ok, result = pcall(require, path)
    if ok and result then
        return result
    end
    return nil
end

local pzc = safe_require_lib("pz_lua_commons_shared")
if not pzc then
    print("Failed to load pz_lua_commons")
    return
end
```

### Safe JSON Pattern

```lua
local function safe_json_encode(obj)
    if not obj then return nil end

    local ok, result = pcall(function()
        return lunajson.encode(obj)
    end)

    if ok then
        return result
    else
        safeLog("JSON encode error: " .. tostring(result), "ERROR")
        return nil
    end
end
```

### Safe Event Pattern

```lua
local pzc = require("pz_lua_commons_shared")
local signal = pzc.vrld.hump.signal

signal.register("important:event", function(...)
    local ok, err = pcall(function()
        -- Your code here
    end)

    if not ok then
        safeLog("Event handler error: " .. tostring(err), "ERROR")
    end
end)
```

## Documentation Files

| File                                 | Purpose                                        |
| ------------------------------------ | ---------------------------------------------- |
| **PZ_UTILS_GUIDE.md**                | Complete guide to pz_utils (Escape & Konijima) |
| **PZ_LUA_COMMONS_SHARED_GUIDE.md**   | Complete guide to Shared module                |
| **PZ_LUA_COMMONS_CLIENT_GUIDE.md**   | Complete guide to Client module                |
| **PZ_LUA_COMMONS_COMPLETE_GUIDE.md** | This file — overview and workflows             |

## FAQ

### Q: Can I use client libraries on server?

**A:** No, they're guard-checked with `if not isServer()`. They will be nil on server.

### Q: Which JSON library is faster?

**A:** lunajson is generally faster for large objects. Use as default, jsonlua as fallback.

### Q: What's the difference between middleclass and 30log?

**A:** Both are OOP frameworks. middleclass is shared (server+client), designed for production code. 30log is client-only with built-in instance logging capability. Use middleclass for core logic, 30log for client-side entities.

### Q: Do I need pz_utils if I'm using pz_lua_commons?

**A:** pz_utils is a separate require (`require("pz_utils_shared")`). Use it if you want debounce, safe logging, event management, or konijima utilities.

### Q: Can I mix shared and client code?

**A:** Yes, shared code runs everywhere. Client code guards itself from server.

### Q: What happens if a library fails to load?

**A:** SafeRequire returns nil. Always check: `if lib then ... end`

### Q: How do I enable safe logging?

**A:** Create a logger instance: `local logger = SafeLogger.new("ModName")` then use `logger:log(message, level)`.

### Q: Can I create custom events?

**A:** Yes, use hump.signal: `signal.register("custom:event", fn)` or EventManager: `escape.EventManager.on("custom:event", fn)`

### Q: How do I handle networking?

**A:** Use Konijima's `SendClientCommand`, `SendServerCommandTo`, `SendServerCommandToAll`, and `SendServerCommandToAllInRange` functions.

### Q: What's the difference between `pz_utils.escape` and `pz_utils[1]`?

**A:** They're alternate ways to access the same Escape utilities table. `pz_utils.escape` is the named key, `pz_utils[1]` is the numeric index. Both work.

---

## Getting Started Checklist

- [ ] Read this overview document
- [ ] Choose which modules you need
- [ ] Check relevant guide (PZ_UTILS_GUIDE, SHARED_GUIDE, or CLIENT_GUIDE)
- [ ] Read the test files for API reference and usage patterns
- [ ] Use the correct require paths in your mod
- [ ] Build on top of the patterns

## Support Resources

- Project Zomboid Modding: https://theindiestone.com/forums/
- GitHub Issues: Check the pz_lua_commons repository
- Test Files: Located in `pz_lua_commons_test/` (this project)

## Version Information

- **pz_utils**: Based on eScape and Konijima utilities
- **lunajson**: v1.2.3 by Grafi-tt
- **middleclass**: v4.1.1 by Kikito
- **jsonlua**: v0.1.2 by rxi
- **hump.signal**: Latest by vrld
- **inspectlua**: v3.1.3 by Kikito
- **serpent**: v0.30 by pkulchenko
- **30log**: v1.3.0 by yonaba

## License

These modules and libraries are provided for Project Zomboid modding. See individual library licenses for details.

---

**Last Updated**: 2026-03-01
**Framework Version**: pz_lua_commons
**For**: Project Zomboid Build 41.60+
