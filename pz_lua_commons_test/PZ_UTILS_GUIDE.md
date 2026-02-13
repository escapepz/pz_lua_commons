# PZ Utils Guide - Complete Reference

This guide covers the `pz_utils` module and its two sub-libraries: **Escape Utilities** and **Konijima Utilities**.

## Quick Start

```lua
local pz_utils = require("pz_lua_commons/shared")
local escape = pz_utils[1] or pz_utils.escape
local konijima = pz_utils.konijima.Utilities
```

## Table of Contents

1. [Escape Utilities](#escape-utilities)
    - [Debounce](#debounce)
    - [EventManager](#eventmanager)
    - [SafeLogger](#safelogger)
    - [SafeRequire](#saferequire)
    - [Utilities](#utilities)
2. [Konijima Utilities](#konijima-utilities)
    - [Environment Detection](#environment-detection)
    - [Permission Checks](#permission-checks)
    - [Networking](#networking)
    - [Player & Grid Utilities](#player--grid-utilities)
3. [Examples](#examples)
4. [Testing](#testing)

---

## Escape Utilities

Escape utilities are designed for robust, error-tolerant mod development.

### Debounce

Delays callback execution until a period of inactivity has passed. Useful for rate-limiting expensive operations.

#### Functions

| Function    | Parameters                                           | Returns   | Description                                             |
| ----------- | ---------------------------------------------------- | --------- | ------------------------------------------------------- |
| `Call`      | `id: string, delay: number, callback: function, ...` | `boolean` | Queue or reset a debounced call                         |
| `Update`    | none                                                 | `boolean` | Process all pending debounces (call once per game tick) |
| `Cancel`    | `id: string`                                         | `boolean` | Cancel a specific debounce                              |
| `CancelAll` | none                                                 | `number`  | Cancel all pending debounces, returns count             |
| `IsActive`  | `id: string`                                         | `boolean` | Check if debounce is waiting to execute                 |

#### Behavior

1. First call starts a timer (delay ticks)
2. Repeated calls reset timer and accumulate arguments
3. After delay expires, executes callback once with accumulated arguments

#### Example

```lua
-- Debounce player movement handling
escape.Debounce.Call("player_move", 5, function(args)
    print("Player moved to: " .. tostring(args[1]))
end, "100", "200", "0")

-- In game loop (every tick)
escape.Debounce.Update()
```

---

### EventManager

Custom event system for publish-subscribe patterns. Events can be enabled/disabled and track listener count.

#### Functions

| Function           | Parameters                              | Returns      | Description                        |
| ------------------ | --------------------------------------- | ------------ | ---------------------------------- |
| `createEvent`      | `name: string`                          | `table`      | Create a new event or get existing |
| `getOrCreateEvent` | `name: string`                          | `table`      | Get existing event or create new   |
| `on`               | `eventName: string, callback: function` | `table`      | Shorthand to add listener          |
| `trigger`          | `eventName: string, ...`                | none         | Fire an event with arguments       |
| `off`              | `eventName: string, callback: function` | none         | Remove a listener                  |
| `getEventInfo`     | `eventName: string`                     | `table\|nil` | Get event metadata                 |
| `getAllEventsInfo` | none                                    | `table`      | Get info for all events            |

#### Event Methods

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
-- Create event
local damageEvent = escape.EventManager.createEvent("PlayerDamage")

-- Add listeners
damageEvent:Add(function(damage, source)
    print("Took " .. damage .. " damage from " .. source)
end)

-- Trigger event
damageEvent:Trigger(25, "Zombie")

-- Check state
print("Listeners: " .. damageEvent:GetListenerCount())
```

---

### SafeLogger

Defensive logging system with log levels. Automatically detects ZUL (Zomboid Utilities Library) if available.

#### Log Levels

| Level | Number | Method |
| ----- | ------ | ------ |
| TRACE | 10     | debug  |
| DEBUG | 20     | debug  |
| INFO  | 30     | info   |
| WARN  | 40     | warn   |
| ERROR | 50     | error  |
| FATAL | 60     | fatal  |

#### Functions

| Function | Parameters                        | Description                 |
| -------- | --------------------------------- | --------------------------- |
| `init`   | `moduleName: string\|nil`         | Initialize with module name |
| `log`    | `msg: any, level: string\|number` | Log a message               |

#### Example

```lua
escape.SafeLogger.init("MyMod")

escape.SafeLogger.log("Starting mod", "INFO")
escape.SafeLogger.log("Debug info", 20)        -- TRACE
escape.SafeLogger.log("Warning: low memory", "WARN")
escape.SafeLogger.log("Critical error", 60)    -- FATAL
```

---

### SafeRequire

Safely loads modules with error handling. Returns `nil` on failure.

#### Example

```lua
local myModule = escape.SafeRequire("path/to/module", "ModuleName")
if myModule then
    print("Module loaded successfully")
else
    print("Failed to load module")
end
```

---

### Utilities

Helper functions for real-world time tracking.

#### Functions

| Function          | Returns  | Description                  |
| ----------------- | -------- | ---------------------------- |
| `GetIRLTimestamp` | `number` | Get Unix timestamp (seconds) |

#### Example

```lua
local timestamp = escape.Utilities.GetIRLTimestamp()
print("Current time: " .. timestamp)
```

---

## Konijima Utilities

Konijima utilities provide Project Zomboid-specific functionality.

### Environment Detection

Determine the game environment (single player, client, server).

```lua
konijima.IsSinglePlayer()           -- Not server, not client
konijima.IsSinglePlayerDebug()      -- Single player with debug enabled
konijima.IsClientOnly()             -- Client without server
konijima.IsClientOrSinglePlayer()   -- Client or single player
konijima.IsServerOrSinglePlayer()   -- Server or single player
```

---

### Permission Checks

#### Client-Side (Local Player)

```lua
konijima.IsClientAdmin()            -- Is local player admin?
konijima.IsClientStaff()            -- Is local player admin or moderator?
```

#### Server-Side (Remote Players)

```lua
-- By player object
konijima.IsPlayerAdmin(playerObj)

-- By username
konijima.IsPlayerAdmin("PlayerName")

-- Check for staff (admin or moderator)
konijima.IsPlayerStaff(playerObjOrUsername)
```

---

### Networking

Commands for client-server communication.

#### Client → Server

```lua
konijima.SendClientCommand(module, command, data)
-- Example:
konijima.SendClientCommand("MyMod", "RequestInfo", {target = "player1"})
```

#### Server → Client(s)

```lua
-- To specific client
konijima.SendServerCommandTo(targetPlayer, module, command, data)

-- To all clients
konijima.SendServerCommandToAll(module, command, data)

-- To clients in range
konijima.SendServerCommandToAllInRange(x, y, z, minDist, maxDist, module, command, data)
```

#### Example

```lua
-- Server broadcasts announcement to all players within 20 blocks
konijima.SendServerCommandToAllInRange(
    100, 200, 0,           -- Center coordinates
    0, 20,                 -- Min/max distance
    "MyMod",               -- Module
    "Announcement",        -- Command
    {text = "Event nearby!"}
)
```

---

### Player & Grid Utilities

#### Player Operations

```lua
-- Get player by username (server only)
local player = konijima.GetPlayerFromUsername("PlayerName")

-- Check if player is in range
local inRange = konijima.IsPlayerInRange(playerObj, x, y, z, minDist, maxDist)
```

#### Grid Square Operations

```lua
-- Convert square to string
local squareStr = konijima.SquareToString(square)  -- Returns: "100|200|0"

-- Parse string to coordinates
local coords = konijima.StringToSquare("100|200|0")
```

#### Helper Functions

```lua
-- Split string by delimiter
local parts = konijima.SplitString("apple,banana,orange", ",")
-- Returns: {"apple", "banana", "orange"}

-- Check if square has electricity
local hasElectricity = konijima.SquareHasElectricity(square)

-- Get server/save name
local serverName = konijima.GetServerName()

-- Find items by tag
local foodItems = konijima.FindAllItemInInventoryByTag(inventory, "Food")

-- Get object display name
local displayName = konijima.GetMoveableDisplayName(object)
```

---

## Examples

### Example Files

1. **example_13_pz_utils_escape.lua** - Escape utilities with practical examples
2. **example_14_pz_utils_konijima.lua** - Konijima utilities with Project Zomboid context
3. **example_15_pz_utils_advanced.lua** - Advanced patterns:
    - Debounced event system
    - Command dispatcher
    - State machine
    - Cached properties
    - Dependency injection
    - Validated execution
    - Deferred operations

### Running Examples

```bash
-- Load in Project Zomboid with mod installed
require("path/to/example_XX_pz_utils_*.lua")
```

---

## Testing

### Test Files

1. **test_pz_utils_escape.lua** - Tests for Escape utilities
2. **test_pz_utils_konijima.lua** - Tests for Konijima utilities

### Running Tests

```bash
-- In Project Zomboid or Lua environment
require("path/to/test_pz_utils_*.lua")
```

### Test Coverage

#### Escape Tests

- SafeLogger initialization and logging at all levels
- Debounce creation, activation, cancellation
- Event creation, listener management, triggering
- SafeRequire for valid and invalid modules
- Utilities timestamp functions

#### Konijima Tests

- Environment detection functions
- Permission/admin check functions
- Networking functions existence
- String splitting with various delimiters
- Player and grid utilities
- Error handling with nil inputs

---

## Common Patterns

### Pattern 1: Debounced Event Processing

```lua
local accumulator = {}

escape.EventManager.on("RawEvent", function(data)
    table.insert(accumulator, data)

    escape.Debounce.Call("process", 5, function(args)
        escape.SafeLogger.log("Processing " .. #accumulator .. " items", "INFO")
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

### Pattern 3: Distance-Based Action

```lua
if konijima.IsServerOrSinglePlayer() then
    konijima.SendServerCommandToAllInRange(
        eventX, eventY, eventZ,
        0, 50,  -- Within 50 blocks
        "MyMod", "NearbyEvent", {data = value}
    )
end
```

### Pattern 4: Safe Module Loading

```lua
local myLib = escape.SafeRequire("my_lib/core", "MyLibrary")
if myLib then
    -- Use library
else
    escape.SafeLogger.log("Failed to load MyLibrary", "ERROR")
end
```

---

## Best Practices

1. **Always initialize SafeLogger** with your module name
2. **Call Debounce.Update()** every game tick in your main loop
3. **Use EventManager** for decoupled communication between systems
4. **Check permissions** before executing admin commands
5. **Handle nil returns** from Konijima functions (they're designed to fail gracefully)
6. **Use distance checks** before sending server commands to reduce network traffic
7. **Cache frequently accessed data** with proper invalidation
8. **Validate user input** before processing commands

---

## API Reference Quick Links

### Escape Utilities

- Debounce: Rate-limiting callbacks
- EventManager: Publish-subscribe events
- SafeLogger: Defensive logging with levels
- SafeRequire: Safe module loading
- Utilities: Helper functions

### Konijima Utilities

- Environment checks: Game mode detection
- Permissions: Admin/staff validation
- Networking: Client-server communication
- Player utilities: Player lookups and range checks
- Grid utilities: Coordinate and square operations
- Inventory: Item searching by tag
- Display: Object name translation

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
