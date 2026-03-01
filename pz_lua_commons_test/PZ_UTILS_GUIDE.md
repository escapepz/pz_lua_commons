# PZ Utils Guide — Complete Reference

This guide covers the `pz_utils` module and its two sub-libraries: **Escape Utilities** and **Konijima Utilities**, as reflected in the actual test codebase of `pz_lua_commons_test`.

## Quick Start

```lua
local pz_utils = require("pz_utils_shared")
local escape   = pz_utils[1] or pz_utils.escape
local konijima = pz_utils.konijima.Utilities
```

> **Note:** The require path is `"pz_utils_shared"` — not `"pz_lua_commons/shared"`.

## Table of Contents

1. [Escape Utilities](#escape-utilities)
    - [SafeLogger](#safelogger)
    - [Debounce](#debounce)
    - [EventManager](#eventmanager)
    - [SafeRequire](#saferequire)
    - [Utilities](#utilities)
2. [Konijima Utilities](#konijima-utilities)
    - [Environment Detection](#environment-detection)
    - [Permission Checks](#permission-checks)
    - [String Utilities](#string-utilities)
    - [Square Utilities](#square-utilities)
    - [Networking](#networking)
    - [Player Utilities](#player-utilities)
    - [Electricity](#electricity)
    - [Server Info](#server-info)
    - [Inventory](#inventory)
    - [Moveable Objects](#moveable-objects)
3. [Test Structure](#test-structure)
4. [Test Framework](#test-framework)
5. [Common Patterns](#common-patterns)
6. [Best Practices](#best-practices)

---

## Escape Utilities

Access: `pz_utils[1]` or `pz_utils.escape`

Escape utilities are designed for robust, error-tolerant mod development.

### SafeLogger

Defensive logging system with log levels.

#### Log Levels

| Level | Number |
| ----- | ------ |
| TRACE | 10     |
| DEBUG | 20     |
| INFO  | 30     |
| WARN  | 40     |
| ERROR | 50     |
| FATAL | 60     |

#### API

```lua
local logger = escape.SafeLogger.new("ModuleName")

logger:log("message", "INFO")     -- string level
logger:log("message", 30)         -- numeric level (INFO)
logger:log("message")             -- defaults to INFO
```

---

### Debounce

Delays callback execution until a period of inactivity has passed. Useful for rate-limiting expensive operations.

#### API

| Function    | Signature                                            | Returns   | Description                                             |
| ----------- | ---------------------------------------------------- | --------- | ------------------------------------------------------- |
| `Call`      | `(id: string, delay: number, callback: function, ...)`| `boolean` | Queue or reset a debounced call                         |
| `Update`    | `()`                                                 | `boolean` | Process all pending debounces (call once per game tick) |
| `Cancel`    | `(id: string)`                                       | `boolean` | Cancel a specific debounce (`false` if not found)       |
| `CancelAll` | `()`                                                | `number`  | Cancel all pending debounces, returns count cancelled   |
| `IsActive`  | `(id: string)`                                       | `boolean` | Check if debounce is waiting to execute                 |

#### Behavior

1. First call starts a timer (delay ticks)
2. Repeated calls with the same `id` reset the timer and accumulate arguments
3. After delay expires, executes callback once with accumulated arguments

#### Example

```lua
escape.Debounce.Call("player_move", 5, function(args)
    print("Player moved to: " .. tostring(args[1]))
end, "100", "200", "0")

-- In game loop (every tick)
escape.Debounce.Update()
```

---

### EventManager

Custom event system for publish-subscribe patterns. Events can be enabled/disabled and track listener count.

#### Top-Level API

| Function           | Signature                                   | Returns      | Description                        |
| ------------------ | ------------------------------------------- | ------------ | ---------------------------------- |
| `createEvent`      | `(name: string)`                            | `table`      | Create a new event or get existing |
| `on`               | `(eventName: string, callback: function)`   | `table`      | Shorthand to add listener          |
| `off`              | `(eventName: string, callback: function)`   | none         | Remove a listener                  |
| `trigger`          | `(eventName: string, ...)`                  | none         | Fire an event with arguments       |
| `getEventInfo`     | `(eventName: string)`                       | `table\|nil` | Get event metadata                 |
| `getAllEventsInfo`  | `()`                                        | `table`      | Get info for all events            |

Direct access to the event table: `escape.EventManager.events[name]`

#### Event Instance Methods

```lua
local event = escape.EventManager.createEvent("MyEvent")

event:Add(callback)                    -- Add listener
event:Remove(callback)                 -- Remove listener
event:Trigger(...)                     -- Fire event
event:SetEnabled(bool)                 -- Enable/disable
event:IsEnabled()                      -- Check if enabled
event:GetListenerCount()               -- Get listener count
event:IsExecuting()                    -- Check if currently firing
```

#### Example

```lua
local damageEvent = escape.EventManager.createEvent("PlayerDamage")

damageEvent:Add(function(damage, source)
    print("Took " .. damage .. " damage from " .. source)
end)

damageEvent:Trigger(25, "Zombie")
print("Listeners: " .. damageEvent:GetListenerCount())
```

---

### SafeRequire

Safely loads modules with error handling. Returns `nil` on failure.

```lua
local result = escape.SafeRequire("pz_utils/escape/utilities", "MyLabel")
if result then
    -- module loaded
end
```

---

### Utilities

Helper functions for real-world time tracking.

| Function          | Returns  | Description                  |
| ----------------- | -------- | ---------------------------- |
| `GetIRLTimestamp`  | `number` | Get Unix timestamp (seconds) |

```lua
local t = escape.Utilities.GetIRLTimestamp()  -- positive number
```

---

## Konijima Utilities

Access: `pz_utils.konijima.Utilities`

Project Zomboid-specific functionality.

### Environment Detection

```lua
konijima.IsSinglePlayer()           -- Not server, not client
konijima.IsSinglePlayerDebug()      -- Single player with debug enabled
konijima.IsClientOnly()             -- Client without server
konijima.IsClientOrSinglePlayer()   -- Client or single player
konijima.IsServerOrSinglePlayer()   -- Server or single player
```

All return `boolean`. `IsSinglePlayerDebug() == true` implies `IsSinglePlayer() == true`. Single player and client-only are mutually exclusive.

---

### Permission Checks

```lua
konijima.IsClientAdmin()            -- Is local player admin?
konijima.IsClientStaff()            -- Is local player admin or moderator?
```

Both return `boolean`. In single player, admin and staff status are identical.

---

### String Utilities

```lua
local parts = konijima.SplitString("apple,banana,cherry", ",")
-- Returns: {"apple", "banana", "cherry"}

konijima.SplitString("100|200|300", "|")    -- pipe delimiter
konijima.SplitString("hello", ",")          -- no match → {"hello"}
konijima.SplitString("", ",")              -- empty → table
konijima.SplitString("a,,c", ",")          -- consecutive → {"a", "", "c"}
```

---

### Square Utilities

```lua
local squareStr = konijima.SquareToString(square)   -- Returns "x|y|z"
local coords    = konijima.StringToSquare("100|200|0")
```

The coordinate string format is `"x|y|z"` using pipe delimiters — parseable with `SplitString`.

---

### Networking

#### Client → Server

```lua
konijima.SendClientCommand(module, command, data)
```

#### Server → Client(s)

```lua
konijima.SendServerCommandTo(player, module, command, data)
konijima.SendServerCommandToAll(module, command, data)
konijima.SendServerCommandToAllInRange(x, y, z, minDist, maxDist, module, command, data)
```

#### Example

```lua
konijima.SendServerCommandToAllInRange(
    100, 200, 0,           -- Center coordinates
    0, 20,                 -- Min/max distance
    "MyMod",               -- Module
    "Announcement",        -- Command
    {text = "Event nearby!"}
)
```

---

### Player Utilities

```lua
local player  = konijima.GetPlayerFromUsername("PlayerName")
local inRange = konijima.IsPlayerInRange(playerObj, x, y, z, minDist, maxDist)
```

`IsPlayerInRange` handles `nil` player gracefully, returning `false`.

---

### Electricity

```lua
local hasElectricity = konijima.SquareHasElectricity(square)
```

Handles `nil` square gracefully (does not crash).

---

### Server Info

```lua
local name = konijima.GetServerName()  -- returns string
```

---

### Inventory

```lua
local items = konijima.FindAllItemInInventoryByTag(inventory, "Food")
```

---

### Moveable Objects

```lua
local displayName = konijima.GetMoveableDisplayName(object)
```

Returns `nil` when passed `nil`.

---

## Test Structure

The test project has **three test files** across two directory trees. There are no example files in this project.

### File: `42/media/lua/shared/pz_lua_commons_test/test_safelogger.lua`

**Style:** Module-return pattern (`return { run = run_tests }`). Part of a test runner suite. Uses SafeLogger for its own output.

**6 tests:**

| # | Test | What it validates |
|---|------|-------------------|
| 1 | safeLog is a function | Type check on the wrapper |
| 2 | handles string messages | `safeLog("Test message")` doesn't crash |
| 3 | handles nil messages | `safeLog(nil)` doesn't crash |
| 4 | handles number messages | `safeLog(123)` doesn't crash |
| 5 | handles debug flag (true) | `safeLog("msg", true)` doesn't crash |
| 6 | handles debug=false | `safeLog("msg", false)` doesn't crash |

```lua
-- Pattern: module-return style
local function run_tests()
    local pz_utils = require("pz_utils_shared")
    local _logger = pz_utils.escape.SafeLogger.new("PZ_LUA_COMMONS_TEST_SAFE_LOGGER")
    local function safeLog(msg, level)
        _logger:log(msg, level)
    end
    -- ... tests using assert_equal / assert_type ...
    return test_results
end

return { run = run_tests }
```

### File: `common/media/lua/shared/test_pz_utils_escape.lua`

**Style:** Standalone (runs on require). Uses the inline test framework.

**Test sections:**

| Section | Tests |
|---------|-------|
| **SafeLogger** | init, log with numeric levels (10–60), log with string levels (TRACE/DEBUG/INFO/WARN/ERROR/FATAL), log without level |
| **Debounce** | Call creates instance, reset timer, IsActive, Cancel, Cancel nonexistent, CancelAll, Update returns boolean |
| **EventManager** | createEvent, get existing event, Add listener, multiple listeners, Remove listener, Trigger listeners, SetEnabled, IsEnabled, GetListenerCount, IsExecuting, shorthand on/off, getEventInfo, getAllEventsInfo |
| **SafeRequire** | valid module (`pz_utils/escape/utilities`), invalid module |
| **Utilities** | GetIRLTimestamp returns number, timestamp increases |

```lua
-- Pattern: standalone, runs immediately
local pz_utils = require("pz_utils_shared")
local escape = pz_utils[1] or pz_utils.escape

local tests = {}
-- ... test functions assigned to tests table ...

for testName, testFunc in pairs(tests) do
    io.write(testName .. " ... ")
    local success, err = pcall(testFunc)
    if success then print("OK")
    else print("ERROR: " .. tostring(err)); testsFailed = testsFailed + 1 end
end
```

### File: `common/media/lua/shared/test_pz_utils_konijima.lua`

**Style:** Standalone (runs on require). Uses the inline test framework.

**Test sections:**

| Section | Tests |
|---------|-------|
| **Environment Detection** | IsSinglePlayer, IsSinglePlayerDebug, IsClientOnly, IsClientOrSinglePlayer, IsServerOrSinglePlayer, mutual exclusivity checks |
| **Admin/Staff Permissions** | IsClientAdmin, IsClientStaff, admin/staff consistency in single player |
| **String Utilities** | SplitString basic, pipe delimiter, single delimiter, no delimiter, empty string, consecutive delimiters |
| **Square Utilities** | SquareToString format, StringToSquare parsing, roundtrip test |
| **Client Commands** | SendClientCommand, SendServerCommandTo, SendServerCommandToAll, SendServerCommandToAllInRange (existence and parameter acceptance) |
| **Player Utilities** | GetPlayerFromUsername, IsPlayerInRange (existence and nil handling) |
| **Electricity** | SquareHasElectricity (existence and nil handling) |
| **Server Info** | GetServerName (existence and return type) |
| **Inventory** | FindAllItemInInventoryByTag existence |
| **Moveable Objects** | GetMoveableDisplayName (existence and nil handling) |

---

## Test Framework

Both standalone test files (`test_pz_utils_escape.lua` and `test_pz_utils_konijima.lua`) use an identical inline framework:

### Assertion Functions

```lua
local function assert_equals(actual, expected, message)
    if actual == expected then
        testsPassed = testsPassed + 1
        return true
    else
        testsFailed = testsFailed + 1
        print("FAIL: " .. (message or "assertion") ..
              " - expected: " .. tostring(expected) ..
              " got: " .. tostring(actual))
        return false
    end
end

local function assert_true(value, message)
    return assert_equals(value, true, message)
end

local function assert_false(value, message)
    return assert_equals(value, false, message)
end

local function assert_type(value, expectedType, message)
    -- compares type(value) == expectedType
end

local function assert_not_nil(value, message)
    -- checks value ~= nil
end
```

### Test Runner

```lua
local tests = {}

tests.test_example = function()
    -- test body
end

for testName, testFunc in pairs(tests) do
    io.write(testName .. " ... ")
    local success, err = pcall(testFunc)
    if success then
        print("OK")
    else
        print("ERROR: " .. tostring(err))
        testsFailed = testsFailed + 1
    end
end

print("Passed: " .. testsPassed)
print("Failed: " .. testsFailed)
print("Total:  " .. (testsPassed + testsFailed))
```

### Module-Return Style (test_safelogger.lua)

The `42/` test uses a different pattern — a `run_tests` function wrapped in a module:

```lua
local function run_tests()
    -- ... assertions stored in test_results table ...
    return test_results
end

return { run = run_tests }
```

This allows a test runner to call `require("pz_lua_commons_test/test_safelogger").run()` and inspect the results programmatically. It also uses SafeLogger itself for output rather than `print`/`io.write`.

---

## Common Patterns

### Pattern 1: Debounced Event Processing

```lua
local accumulator = {}
local logger = escape.SafeLogger.new("EventProcessor")

escape.EventManager.on("RawEvent", function(data)
    table.insert(accumulator, data)

    escape.Debounce.Call("process", 5, function(args)
        logger:log("Processing " .. #accumulator .. " items", "INFO")
        accumulator = {}
    end)
end)
```

### Pattern 2: Admin Command Handler

```lua
local function executeAdminCommand(cmdName, ...)
    if not konijima.IsClientAdmin() then
        return false
    end
    konijima.SendClientCommand("MyMod", cmdName, {args = {...}})
    return true
end
```

### Pattern 3: Distance-Based Broadcasting

```lua
if konijima.IsServerOrSinglePlayer() then
    konijima.SendServerCommandToAllInRange(
        eventX, eventY, eventZ,
        0, 50,
        "MyMod", "NearbyEvent", {data = value}
    )
end
```

### Pattern 4: Safe Module Loading

```lua
local logger = escape.SafeLogger.new("ModuleLoader")
local myLib = escape.SafeRequire("my_lib/core", "MyLibrary")
if myLib then
    -- use library
else
    logger:log("Failed to load MyLibrary", "ERROR")
end
```

---

## Best Practices

1. **Always initialize SafeLogger** with your module name
2. **Call `Debounce.Update()`** every game tick in your main loop
3. **Use EventManager** for decoupled communication between systems
4. **Check permissions** before executing admin commands
5. **Handle nil returns** from Konijima functions — they fail gracefully
6. **Use distance checks** before sending server commands to reduce network traffic

---

## API Reference Quick Links

### Escape Utilities (`pz_utils.escape`)

- **SafeLogger** — `.new(name)` → `:log(msg, level)`
- **Debounce** — `.Call()`, `.Update()`, `.Cancel()`, `.CancelAll()`, `.IsActive()`
- **EventManager** — `.createEvent()`, `.on()`, `.off()`, `.trigger()`, `.getEventInfo()`, `.getAllEventsInfo()`, `.events[name]`
- **SafeRequire** — `(path, label)` → module or `nil`
- **Utilities** — `.GetIRLTimestamp()`

### Konijima Utilities (`pz_utils.konijima.Utilities`)

- **Environment** — `IsSinglePlayer`, `IsSinglePlayerDebug`, `IsClientOnly`, `IsClientOrSinglePlayer`, `IsServerOrSinglePlayer`
- **Permissions** — `IsClientAdmin`, `IsClientStaff`
- **Strings** — `SplitString(str, delimiter)`
- **Squares** — `SquareToString(square)`, `StringToSquare(str)`
- **Networking** — `SendClientCommand`, `SendServerCommandTo`, `SendServerCommandToAll`, `SendServerCommandToAllInRange`
- **Players** — `GetPlayerFromUsername`, `IsPlayerInRange`
- **Electricity** — `SquareHasElectricity`
- **Server** — `GetServerName`
- **Inventory** — `FindAllItemInInventoryByTag`
- **Display** — `GetMoveableDisplayName`

---

## Version Info

- **pz_utils version**: Based on eScape (Escape utilities) and Konijima utilities
- **PZ Compatibility**: 42.13+
- **Lua Version**: 5.1+

## License

These utilities are part of pz_lua_commons and are provided for modding Project Zomboid.

---

## Additional Resources

- Project Zomboid Modding: https://theindiestone.com/forums/
- eScape GitHub: https://github.com/escapepz
- Konijima Utilities Thread: https://theindiestone.com/forums/index.php?/topic/49989-utilities-class-for-modder/
