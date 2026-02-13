# PZ Lua Commons - Complete Guide

Comprehensive guide to all modules in the **pz_lua_commons** framework for Project Zomboid mod development.

## Overview

**pz_lua_commons** provides three integrated modules:

| Module                      | Context | Purpose               | Libraries                   |
| --------------------------- | ------- | --------------------- | --------------------------- |
| **pz_utils**                | Shared  | Utilities and helpers | Escape, Konijima            |
| **pz_lua_commons (Shared)** | Shared  | Core libraries        | JSON, OOP, Events           |
| **pz_lua_commons (Client)** | Client  | Debug/dev tools       | Inspect, Serialization, OOP |

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
│   ├── pz_lua_commons/
│   │   ├── grafi-tt/        (lunajson)
│   │   ├── kikito/          (middleclass)
│   │   ├── rxi/             (jsonlua)
│   │   └── vrld/            (hump.signal)
│   └── pz_utils/
└── client/                  (Client Module - CLIENT ONLY)
    └── pz_lua_commons/
        ├── kikito/          (inspectlua)
        ├── pkulchenko/      (serpent)
        └── yonaba/          (30log)
```

## Quick Start by Use Case

### I want to work with JSON data

```lua
local pz_commons = require("pz_lua_commons/shared")
local json = pz_commons.grafi_tt.lunajson

local data = {name = "player", health = 100}
local json_str = json.encode(data)
local restored = json.decode(json_str)
```

### I want to create classes and objects

```lua
local pz_commons = require("pz_lua_commons/shared")
local class = pz_commons.kikito.middleclass

local Player = class('Player')
function Player:initialize(name)
    self.name = name
end

local player = Player("Alice")
```

### I want to emit and listen to events

```lua
local pz_commons = require("pz_lua_commons/shared")
local signal = pz_commons.vrld.hump.signal

signal.register("player:died", function(name)
    print(name .. " died!")
end)

signal.emit("player:died", "Zombie")
```

### I want to debug a table on client

```lua
if isServer() then return end
local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua

print(inspect({a = 1, b = {c = 2}}))
```

### I want to save/load configuration

```lua
if isServer() then return end
local pz_commons = require("pz_lua_commons/client")
local serpent = pz_commons.pkulchenko.serpent

local config = {debug = true, version = "1.0"}
local file = io.open("config.lua", "w")
file:write(serpent.dump(config))
file:close()
```

### I want debounced callbacks

```lua
local pz_utils = require("pz_lua_commons/shared")
local debounce = pz_utils[1].Debounce or pz_utils.escape.Debounce

debounce.Call("my_debounce", 5, function(args)
    print("Debounced!")
end)

-- In game loop: debounce.Update()
```

### I want safe logging

```lua
local pz_utils = require("pz_lua_commons/shared")
local logger = pz_utils[1].SafeLogger or pz_utils.escape.SafeLogger

logger.init("MyMod")
logger.log("Hello world!", "INFO")
logger.log("Debug info", 20)  -- 20 = DEBUG
```

## Module Loading

### Safe Loading Pattern

```lua
-- Load all modules safely
local pz_utils = nil
local pz_commons_shared = nil
local pz_commons_client = nil

local success, result = pcall(function()
    pz_utils = require("pz_lua_commons/shared")  -- Gets pz_utils
end)

if success then
    success, result = pcall(function()
        pz_commons_shared = require("pz_lua_commons/shared")
    end)
end

if not isServer() then
    success, result = pcall(function()
        pz_commons_client = require("pz_lua_commons/client")
    end)
end

-- Now use safely
if pz_utils then
    local logger = pz_utils.escape.SafeLogger
    -- ...
end
```

## All Available Libraries

### Shared Libraries (Server + Client)

#### pz_utils - Escape Utilities

```lua
local escape = pz_utils[1] or pz_utils.escape

escape.Debounce.Call(id, delay, callback, ...)
escape.Debounce.Update()
escape.Debounce.Cancel(id)

escape.EventManager.createEvent(name)
escape.EventManager.trigger(name, ...)
escape.EventManager.on(name, callback)

escape.SafeLogger.init("ModName")
escape.SafeLogger.log(msg, level)

escape.SafeRequire(path, label)

escape.Utilities.GetIRLTimestamp()
```

#### pz_utils - Konijima Utilities

```lua
local konijima = pz_utils.konijima.Utilities

konijima.IsSinglePlayer()
konijima.IsClientAdmin()
konijima.IsPlayerAdmin(playerOrName)

konijima.SendClientCommand(module, cmd, data)
konijima.SendServerCommandTo(player, module, cmd, data)
konijima.SendServerCommandToAll(module, cmd, data)

konijima.IsPlayerInRange(player, x, y, z, minDist, maxDist)
konijima.SplitString(str, delimiter)
konijima.SquareToString(square)
konijima.StringToSquare(str)

konijima.FindAllItemInInventoryByTag(inventory, tag)
konijima.GetMoveableDisplayName(obj)
```

#### pz_commons (Shared) - lunajson

```lua
local lunajson = pz_commons.grafi_tt.lunajson

lunajson.encode(obj)       -- Lua to JSON string
lunajson.decode(str)       -- JSON string to Lua
```

#### pz_commons (Shared) - middleclass

```lua
local class = pz_commons.kikito.middleclass

local Player = class('Player')
function Player:initialize(name) end

local dog = Player("Alice")
dog:is_a(Player)                    -- Type check
dog:is_instance_of(Player)          -- Instance check
```

#### pz_commons (Shared) - jsonlua

```lua
local json = pz_commons.rxi.jsonlua

json.encode(obj)           -- Lua to JSON
json.decode(str)           -- JSON to Lua
```

#### pz_commons (Shared) - hump.signal

```lua
local signal = pz_commons.vrld.hump.signal

signal.emit(name, ...)     -- Fire event
signal.register(name, fn)  -- Listen to event
signal.remove(name, fn)    -- Stop listening
```

### Client-Only Libraries (Client Side Only)

#### pz_commons (Client) - inspectlua

```lua
local inspect = pz_commons.kikito.inspectlua

inspect(obj)               -- Pretty-print table
inspect(obj, {depth = 2})  -- With options
```

#### pz_commons (Client) - serpent

```lua
local serpent = pz_commons.pkulchenko.serpent

serpent.dump(obj)          -- Serialize to string
serpent.load(str)()        -- Load from string
serpent.line(obj)          -- One-line format
```

#### pz_commons (Client) - 30log (Ultra-lightweight OOP)

```lua
local yon30log = pz_commons.yonaba.yon_30log

local Class = yon30log("ClassName")
function Class:initialize(arg) end

local instance = Class:new(arg)
-- Use like any OOP class
```

## Common Workflows

### Workflow 1: Multiplayer Command Execution

```lua
-- Client side
local konijima = require("pz_lua_commons/shared").konijima.Utilities

-- Send command to server
konijima.SendClientCommand("MyMod", "KillZombie", {x = 100, y = 200, z = 0})

-- Server side
local escape = require("pz_lua_commons/shared").escape or require("pz_lua_commons/shared")[1]
escape.EventManager.on("OnServerCommand", function(module, command, data)
    if module == "MyMod" and command == "KillZombie" then
        -- Execute command
        escape.SafeLogger.log("Zombie killed at " .. data.x, "INFO")
    end
end)
```

### Workflow 2: Save/Load Game Data

```lua
-- Shared code
local pz_commons = require("pz_lua_commons/shared")
local json = pz_commons.grafi_tt.lunajson
local class = pz_commons.kikito.middleclass

local Player = class('Player')
function Player:initialize(name, level)
    self.name = name
    self.level = level
end

-- Client: Save
local player = Player("Alice", 50)
local saved = json.encode({
    name = player.name,
    level = player.level
})
-- Save `saved` to file

-- Client/Server: Load
local loaded = json.decode(saved)
local restored_player = Player(loaded.name, loaded.level)
```

### Workflow 3: Event-Driven Game Loop

```lua
local pz_utils = require("pz_lua_commons/shared")
local signal = require("pz_lua_commons/shared").vrld.hump.signal
local debounce = pz_utils.escape.Debounce

-- Setup
signal.register("player:move", function(x, y, z)
    print("Player moved")
end)

-- Game loop
function update_game()
    -- ... game logic ...

    debounce.Call("player_move", 5, function(args)
        signal.emit("player:move", args[1], args[2], args[3])
    end, player_x, player_y, player_z)

    debounce.Update()
end
```

### Workflow 4: Debug Helper on Client

```lua
if isServer() then return end

local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua
local serpent = pz_commons.pkulchenko.serpent

local Debug = {}

function Debug.snapshot(name)
    local snap = {
        time = os.time(),
        paused = isPaused()
    }
    print(name .. ": " .. inspect(snap))
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

- ✓ Debounce - Very fast, O(n) per update where n = active debounces
- ✓ EventManager - Fast emit/receive, O(m) where m = listeners
- ✓ SafeLogger - Negligible when not triggered
- ✓ Utilities - Single calculation, instant return

### What's Medium Weight

- ⚠ middleclass - Class creation is fast, instance creation is normal Lua
- ⚠ 30log - Lightweight OOP framework, can use in production code
- ⚠ hump.signal - Signal emit is fast, register/remove are O(n)
- ⚠ JSON encode/decode - Depends on data size, can be slow for large objects

### What's Heavy/Debug Only

- ✗ inspect - For debugging only, slow on large tables
- ✗ serpent - Serialization is CPU intensive

### Optimization Tips

```lua
-- ✓ Cache library references
local escape = require("pz_lua_commons/shared").escape

-- ✗ Don't: Require every time
-- for i = 1, 1000 do
--     local escape = require("pz_lua_commons/shared").escape
-- end

-- ✓ Debounce expensive operations
escape.Debounce.Call("expensive_op", 10, expensive_function)

-- ✗ Don't: Call directly every frame
-- for i = 1, 1000 do
--     expensive_operation()
-- end

-- ✓ Use JSON for serialization, not inspect
local json_str = json.encode(data)

-- ✗ Don't: Use inspect for production code
-- local str = inspect(data)  -- Much slower

-- ✓ Pre-create classes
local Player = class('Player')

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

local pz_commons = safe_require_lib("pz_lua_commons/shared")
if not pz_commons then
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
        print("JSON encode error: " .. tostring(result))
        return nil
    end
end
```

### Safe Event Pattern

```lua
signal.register("important:event", function(...)
    local ok, err = pcall(function()
        -- Your code here
    end)

    if not ok then
        logger.log("Event handler error: " .. tostring(err), "ERROR")
    end
end)
```

## Documentation Files

| File                                 | Purpose                                        |
| ------------------------------------ | ---------------------------------------------- |
| **PZ_UTILS_GUIDE.md**                | Complete guide to pz_utils (Escape & Konijima) |
| **PZ_LUA_COMMONS_SHARED_GUIDE.md**   | Complete guide to Shared module                |
| **PZ_LUA_COMMONS_CLIENT_GUIDE.md**   | Complete guide to Client module                |
| **PZ_LUA_COMMONS_COMPLETE_GUIDE.md** | This file - overview and workflows             |

## Examples Available

### Shared Examples

- `example_01_basic_loading.lua` - Loading pz_lua_commons
- `example_02_json_lunajson.lua` - JSON with lunajson
- `example_03_middleclass_oop.lua` - Object-oriented programming
- `example_04_json_jsonlua.lua` - JSON with jsonlua
- `example_05_hump_signal.lua` - Event signaling
- `example_06_combined_shared_utilities.lua` - Combined shared libraries

### Client Examples

- `example_01_basic_loading.lua` - Loading pz_lua_commons/client
- `example_02_inspect_debug.lua` - Table inspection
- `example_03_serpent_serialize.lua` - Data serialization
- `example_04_logging.lua` - Logging patterns
- `example_05_combined_utilities.lua` - Combined utilities
- `example_11_30log_oop.lua` - 30log classes

### pz_utils Examples

- `example_13_pz_utils_escape.lua` - Escape utilities demo
- `example_14_pz_utils_konijima.lua` - Konijima utilities demo
- `example_15_pz_utils_advanced.lua` - Advanced patterns

## Tests Available

### Shared Tests

- `test_pz_utils_escape.lua` - Tests for Escape utilities
- `test_pz_utils_konijima.lua` - Tests for Konijima utilities

## FAQ

### Q: Can I use client libraries on server?

**A:** No, they're guard-checked with `if not isServer()`. They will be nil on server.

### Q: Which JSON library is faster?

**A:** lunajson is generally faster for large objects. Use as default, jsonlua as fallback.

### Q: What's the difference between middleclass and 30log?

**A:** Both are OOP frameworks. middleclass is shared (server+client), designed for production code. 30log is client-only with built-in instance logging capability. Use middleclass for core logic, 30log for client-side entities.

### Q: Do I need pz_utils if I'm using pz_lua_commons?

**A:** pz_utils is separate. Use if you want debounce, safe logging, or konijima utilities.

### Q: Can I mix shared and client code?

**A:** Yes, shared code runs everywhere. Client code guards itself from server.

### Q: What happens if a library fails to load?

**A:** SafeRequire returns nil. Always check: `if lib then ... end`

### Q: How do I enable safe logging?

**A:** Call `SafeLogger.init("ModName")` once at startup.

### Q: Can I create custom events?

**A:** Yes, use EventManager: `signal.register("custom:event", fn)`

### Q: How do I handle networking?

**A:** Use Konijima's SendClientCommand and SendServerCommand functions.

---

## Getting Started Checklist

- [ ] Read this overview document
- [ ] Choose which modules you need
- [ ] Check relevant guide (pz_utils, shared, or client)
- [ ] Look at example files
- [ ] Read the test files for API reference
- [ ] Try the examples in your mod
- [ ] Build on top of the patterns

## Support Resources

- Project Zomboid Modding: https://theindiestone.com/forums/
- GitHub Issues: Check the pz_lua_commons repository
- Example Files: Located in pz_lua_commons_example/
- Test Files: Located in pz_lua_commons_test/

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

**Last Updated**: 2026-02-13
**Framework Version**: pz_lua_commons
**For**: Project Zomboid Build 41.60+
