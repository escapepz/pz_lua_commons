# How to Implement a Test Suite for Project Zomboid Lua 5.1 (Kahlua2)

A complete practical guide for building robust test suites for Project Zomboid mods using Lua 5.1 with the Kahlua2 VM.

---

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
3. [Architecture](#architecture)
4. [Implementation Steps](#implementation-steps)
5. [Test Framework](#test-framework)
6. [Mock/Stub Strategy](#mockstub-strategy)
7. [Testing Patterns](#testing-patterns)
8. [Best Practices](#best-practices)
9. [Examples](#examples)
10. [Troubleshooting](#troubleshooting)

---

## Overview

### Why Test Project Zomboid Mods?

Project Zomboid runs Lua 5.1 code via the Kahlua2 Java VM bridge. Testing without the game runtime is challenging because:

- **No Direct Runtime Access**: Can't run PZ code in plain Lua
- **Complex API Surface**: Game APIs have Java classes (ArrayList, HashMap, etc.)
- **Integration Complexity**: Libraries interact with PZ engine objects

### The Solution: Stub-Based Testing

Create a test environment that:

1. **Mocks** the PZ Java APIs with Lua equivalents
2. **Validates** libraries work with those mocks
3. **Ensures** code will work in actual PZ runtime
4. **Runs** in plain Lua without game installation

---

## Core Concepts

### 1. Stubs vs Mocks

| Term | Meaning | Used For |
|------|---------|----------|
| **Stub** | Minimal implementation matching a real API contract | Defining what methods exist |
| **Mock** | Stub that tracks calls and validates behavior | Testing how code uses APIs |
| **Fake** | Working implementation for testing (not real) | Replacing expensive operations |

In PZ testing, we create **mocks** that implement **stub contracts**.

### 2. Contract-Based Design

A "contract" is the interface specification:

```lua
-- Stub contract for ArrayList
ArrayList contract:
  - add(item) -> boolean
  - get(index) -> Object
  - size() -> number
  - remove(index) -> Object

-- Mock implementation must match this contract exactly
```

### 3. Kahlua2 Limitations

Lua 5.1 via Kahlua2 has constraints:

- **No metatables** for userdata (Java objects)
- **Limited standard library** (no io, debug, etc.)
- **Strict type coercion** rules
- **No external module loading** (must be sandboxed)

Test strategy accounts for these:

- Use pure Lua objects for mocks
- Avoid stdlib functions Kahlua2 doesn't support
- Test with actual library loads as they run in PZ

---

## Architecture

### Directory Structure

```
TEST_SUITE/
├── tests/
│   ├── mock_pz.lua                 # PZ API stubs
│   ├── test_common_lib.lua         # Main test suite
│   ├── test_pz_utils_escape.lua    # Utility tests
│   ├── test_pz_utils_konijima.lua  # Utility tests
│   └── test_sandbox_vars_module.lua # Sandbox tests
├── examples/
│   └── example_usage.lua           # Real-world patterns
├── TESTING_SUITE.md                # Quick reference
├── TEST_ARCHITECTURE.md            # Detailed architecture
└── IMPLEMENTATION_GUIDE.md         # This file
```

### Components

#### 1. **mock_pz.lua** - The Stub Layer

Provides minimal implementations of PZ APIs:

```lua
-- Collections
ArrayList, HashMap

-- Geometry
Vector2f, Vector3f

-- Game Objects
Character, Item, GameState

-- Utilities
GetTickCount(), GetCurrentTimeMs()
```

#### 2. **test_*.lua** - Test Suites

Organized test files by module:

- `test_common_lib.lua` - Main integration tests (50+ cases)
- `test_pz_utils_escape.lua` - Logging/escaping utilities
- `test_pz_utils_konijima.lua` - Array/table utilities
- `test_sandbox_vars_module.lua` - Sandbox variable tests

#### 3. **example_usage.lua** - Reference Implementation

Demonstrates real-world patterns:

- JSON serialization
- Event systems
- OOP patterns
- Logging and debouncing
- Multi-library workflows

---

## Implementation Steps

### Step 1: Create Test Framework

Create a simple test runner in `tests/test_framework.lua`:

```lua
-- test_framework.lua
-- Minimal test framework for PZ Lua testing

local TestRunner = {
    tests = {},
    passed = 0,
    failed = 0,
    errors = {}
}

function TestRunner.register(name, testFunc)
    table.insert(TestRunner.tests, {
        name = name,
        func = testFunc
    })
end

function TestRunner.assert_equals(actual, expected, message)
    if actual ~= expected then
        error(string.format(
            "%s\n  Expected: %s\n  Got: %s",
            message, tostring(expected), tostring(actual)
        ))
    end
end

function TestRunner.assert_true(value, message)
    if not value then
        error(message)
    end
end

function TestRunner.assert_not_nil(value, message)
    if value == nil then
        error(message)
    end
end

function TestRunner.assert_is_type(value, expectedType, message)
    if type(value) ~= expectedType then
        error(string.format(
            "%s\n  Expected type: %s\n  Got type: %s",
            message, expectedType, type(value)
        ))
    end
end

function TestRunner.run()
    print(string.rep("=", 70))
    print("TEST SUITE")
    print(string.rep("=", 70))
    print()
    
    for _, test in ipairs(TestRunner.tests) do
        local status, err = pcall(test.func)
        local result = status and "OK" or "FAIL"
        
        if status then
            TestRunner.passed = TestRunner.passed + 1
            print(string.format("%-50s %s", test.name, result))
        else
            TestRunner.failed = TestRunner.failed + 1
            print(string.format("%-50s %s", test.name, result))
            table.insert(TestRunner.errors, {
                name = test.name,
                error = err
            })
        end
    end
    
    print()
    print(string.rep("=", 70))
    print("TEST RESULTS")
    print(string.rep("=", 70))
    print(string.format("Passed: %d", TestRunner.passed))
    print(string.format("Failed: %d", TestRunner.failed))
    print(string.format("Total:  %d", TestRunner.passed + TestRunner.failed))
    print()
    
    if TestRunner.failed > 0 then
        print("FAILURES:")
        for _, failure in ipairs(TestRunner.errors) do
            print(string.format("\n%s:", failure.name))
            print(failure.error)
        end
        return false
    else
        print("✓ ALL TESTS PASSED")
        return true
    end
end

return TestRunner
```

### Step 2: Create Mock/Stub Layer

Create `tests/mock_pz.lua` with minimal implementations of PZ APIs. Refer to the Architecture section above for examples of ArrayList and Vector2f stubs. Key points:

- Implement ONLY methods used by your code
- Match method signatures exactly
- Use Lua tables (not Java objects)
- Provide `setupGlobalEnvironment()` to inject globals

### Step 3: Create Test Suite

Create `tests/test_common_lib.lua`:

```lua
-- test_common_lib.lua
-- Integration tests for pz_lua_commons

-- Setup paths
local testDir = debug.getinfo(1).source:match("@?(.*/)")
package.path = testDir .. "?.lua;" .. package.path
package.path = testDir .. "../../pz_lua_commons/common/media/lua/shared/?.lua;" .. package.path

-- Load test framework and mocks
local TestRunner = require("test_framework")
local mock_pz = require("mock_pz")
mock_pz.setupGlobalEnvironment()

-- Load the actual modules to test
local pz_commons = require("pz_lua_commons/shared")
local pz_utils = require("pz_utils/shared")

-- ============================================================================
-- MODULE LOADING TESTS
-- ============================================================================

TestRunner.register("Module loading: pz_lua_commons exists", function()
    TestRunner.assert_not_nil(pz_commons, "pz_commons should exist")
end)

TestRunner.register("Module loading: pz_utils exists", function()
    TestRunner.assert_not_nil(pz_utils, "pz_utils should exist")
end)

TestRunner.register("Module loading: lunajson available", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    TestRunner.assert_not_nil(lunajson, "lunajson should be available")
end)

-- ============================================================================
-- LIBRARY TESTS
-- ============================================================================

TestRunner.register("lunajson: encode basic table", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    local data = { x = 1, y = 2 }
    local encoded = lunajson.encode(data)
    TestRunner.assert_is_type(encoded, "string", "encoded should be string")
end)

TestRunner.register("lunajson: decode valid json", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    local json = '{"x":1,"y":2}'
    local decoded = lunajson.decode(json)
    TestRunner.assert_equals(decoded.x, 1, "decoded.x should be 1")
    TestRunner.assert_equals(decoded.y, 2, "decoded.y should be 2")
end)

TestRunner.register("middleclass: create class", function()
    local middleclass = pz_commons.kikito.middleclass
    local Animal = middleclass("Animal")
    
    function Animal:initialize(name)
        self.name = name
    end
    
    local dog = Animal("Buddy")
    TestRunner.assert_equals(dog.name, "Buddy", "dog name should be Buddy")
end)

TestRunner.register("middleclass: inheritance", function()
    local middleclass = pz_commons.kikito.middleclass
    local Animal = middleclass("Animal")
    
    function Animal:initialize(name)
        self.name = name
    end
    
    function Animal:speak()
        return "sound"
    end
    
    local Dog = middleclass("Dog", Animal)
    
    function Dog:speak()
        return "woof"
    end
    
    local dog = Dog("Buddy")
    TestRunner.assert_equals(dog:speak(), "woof", "dog should speak woof")
    TestRunner.assert_equals(dog.name, "Buddy", "dog should have name")
end)

TestRunner.register("hump.signal: emit event", function()
    local signal = pz_commons.vrld.hump_signal
    local result = nil
    
    signal.register("test_event", function(value)
        result = value
    end)
    
    signal.emit("test_event", 42)
    TestRunner.assert_equals(result, 42, "event should pass value")
end)

-- ============================================================================
-- STUB COMPATIBILITY TESTS
-- ============================================================================

TestRunner.register("Stub: ArrayList works", function()
    local list = ArrayList.new()
    list:add("item1")
    list:add("item2")
    TestRunner.assert_equals(list:size(), 2, "ArrayList size should be 2")
end)

TestRunner.register("Stub: Vector2f distance", function()
    local v1 = Vector2f.new(0, 0)
    local v2 = Vector2f.new(3, 4)
    local dist = v1:distance(v2)
    TestRunner.assert_equals(dist, 5, "distance should be 5")
end)

-- ============================================================================
-- INTEGRATION TESTS
-- ============================================================================

TestRunner.register("Integration: JSON + ArrayList", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    local list = ArrayList.new()
    
    list:add("apple")
    list:add("banana")
    
    local json = lunajson.encode({ items = list:toArray() })
    TestRunner.assert_is_type(json, "string", "should serialize to JSON")
end)

TestRunner.register("Integration: OOP + ArrayList", function()
    local middleclass = pz_commons.kikito.middleclass
    local Inventory = middleclass("Inventory")
    
    function Inventory:initialize()
        self.items = ArrayList.new()
    end
    
    function Inventory:addItem(item)
        self.items:add(item)
    end
    
    function Inventory:size()
        return self.items:size()
    end
    
    local inv = Inventory()
    inv:addItem("sword")
    inv:addItem("shield")
    TestRunner.assert_equals(inv:size(), 2, "inventory should have 2 items")
end)

-- Run all tests
TestRunner.run()
```

### Step 4: Add to Your Mod

In your mod's main script:

```lua
-- mod.lua
-- Include test suite if running in test mode

if IS_TEST_MODE then
    local testDir = "path/to/TEST_SUITE/tests"
    package.path = package.path .. ";" .. testDir .. "/?.lua"
    
    local TestRunner = require("test_framework")
    local test_suite = require("test_common_lib")
    -- Tests will be registered and run
end

-- Normal mod code continues...
local pz_commons = require("pz_lua_commons/shared")
```

---

## Lua 5.1 Runtime Setup

### Lua 5.1 vs LuaJIT - Which Should I Use?

**Short Answer**: **Use Lua 5.1, NOT LuaJIT**

#### Key Differences

| Aspect | Lua 5.1 | LuaJIT |
|--------|---------|--------|
| **Kahlua2 Compatibility** | ✓ 100% | ✗ Limited |
| **Project Zomboid Support** | ✓ Yes (native) | ✗ No |
| **Syntax** | Lua 5.1 standard | Lua 5.1 + extensions |
| **Speed** | Standard | 10-40x faster (JIT) |
| **Use Case** | **Testing PZ mods** | Game dev, performance |

#### Why Lua 5.1 for Kahlua2?

**Kahlua2** is a Java-based Lua Virtual Machine that **implements exactly Lua 5.1 semantics**.

```
Your mod code → Kahlua2 (Java VM) → Runs Lua 5.1 code
Your tests   → Lua 5.1 interpreter → Emulates Kahlua2 behavior
```

**LuaJIT incompatibilities with Kahlua2/PZ:**

1. **FFI (Foreign Function Interface)**: Not available in Kahlua2
   ```lua
   -- LuaJIT only - will FAIL in PZ
   local ffi = require("ffi")  -- Not supported by Kahlua2
   ```

2. **JIT-specific optimizations**: Won't apply in Kahlua2
   ```lua
   -- LuaJIT might optimize, but Kahlua2 doesn't
   for i = 1, 1000000 do ... end
   ```

3. **Different standard library**: Some modules differ
   ```lua
   -- Different behavior between LuaJIT and Kahlua2
   string.format behavior
   table.sort stability
   math operations
   ```

4. **Bytecode incompatibility**: Can't mix bytecode
   ```lua
   -- Compiled with LuaJIT → Won't load in Kahlua2
   -- Compiled with Lua 5.1 → Will load in Kahlua2
   ```

#### When Testing, You Need Lua 5.1 Because:

1. **Exact behavior match**: Tests pass locally → will pass in PZ
2. **Same stdlib**: No surprises when code runs in-game
3. **Kahlua2 compliance**: Your mocks are validated against correct VM
4. **Sandbox limitations**: Test with same restrictions as PZ

#### Example: Why This Matters

```lua
-- test.lua
local val = 0.1 + 0.2
print(val == 0.3)  -- Different in LuaJIT vs Lua 5.1 vs Kahlua2

-- In Lua 5.1:
-- false (floating point precision)

-- In LuaJIT:
-- might be true (JIT optimizations)

-- In Kahlua2:
-- false (matches Lua 5.1)

-- Your test MUST use Lua 5.1 to match PZ behavior
```

#### Decision Tree

```
Do you need to test code for Project Zomboid?
├─ YES → Use Lua 5.1 ✓
└─ NO
   ├─ Need maximum performance? → Use LuaJIT
   ├─ Need standard Lua? → Use Lua 5.4+
   └─ Need exact PZ compatibility? → Use Lua 5.1 ✓
```

#### Summary

- **For PZ mod testing**: Lua 5.1 (this guide)
- **For general Lua dev**: Lua 5.4 or LuaJIT
- **For this project**: **Lua 5.1 only**

---

### Installation by Platform

Project Zomboid uses Lua 5.1 via Kahlua2, so your test environment should match.

#### Windows

**Option 1: Pre-built Binary (Recommended)**

1. Download from https://github.com/rjpcomputing/luaforwindows
   - Get the latest `lua-5.1.x` release
   - Extract to `C:\lua` or `C:\tools\lua`

2. Verify installation:
   ```cmd
   lua -v
   ```
   Should output: `Lua 5.1.x -- Copyright...`

3. Add to PATH:
   - Press `Win + X` → System
   - Click "Environment variables"
   - Click "Path" → Edit
   - Click "New" → Add `C:\lua\bin` (or your install path)
   - Restart terminal/VSCode

**Option 2: Compile from Source**

1. Install MinGW or Visual Studio Build Tools
2. Download source: https://www.lua.org/download.html
3. Extract and open Developer Command Prompt:
   ```cmd
   cd lua-5.1.5
   mingw32-make
   ```

**Option 3: Package Manager**

```powershell
# Using Scoop
scoop install lua51

# Using Chocolatey
choco install lua51
```

#### macOS

```bash
# Using Homebrew
brew install lua@5.1

# Verify
lua5.1 -v

# Link to 'lua' command (optional)
ln -s /usr/local/bin/lua5.1 /usr/local/bin/lua
```

#### Linux (Ubuntu/Debian)

```bash
# Install Lua 5.1
sudo apt-get install lua5.1

# Verify
lua5.1 -v

# Link to 'lua' command (optional)
sudo update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.1 1
```

#### Linux (Fedora/RHEL)

```bash
# Install
sudo dnf install lua

# Verify version
lua -v
```

### Verify Installation

Test your Lua 5.1 installation:

```bash
# Check version
lua -v
# Output: Lua 5.1.5  Copyright (c) 1994-2012 Lua.org, PUC-Rio

# Check interactive mode
lua
```

In interactive mode:

```lua
Lua 5.1.5  Copyright (c) 1994-2012 Lua.org, PUC-Rio
> print("Hello from Lua 5.1")
Hello from Lua 5.1
> = 2 + 2
4
> os.exit()
```

### Configure PATH

Ensure `lua` command is globally accessible:

**Windows (PowerShell)**:

```powershell
# Check current PATH
$env:Path -split ';'

# Test lua is available
lua -v

# If not found, add to PATH:
$luaPath = "C:\lua\bin"  # Adjust to your path
[System.Environment]::SetEnvironmentVariable("Path", "$env:Path;$luaPath", "Machine")
# Restart PowerShell
```

**Windows (Command Prompt)**:

```cmd
:: Check PATH
echo %PATH%

:: Test lua
lua -v

:: If not found, use Windows GUI:
:: Settings > Environment Variables > Edit PATH > Add C:\lua\bin
```

**macOS/Linux**:

```bash
# Check if lua is in PATH
which lua

# Or check lua5.1
which lua5.1

# Test it works
lua -v
```

### VSCode Integration

Configure VSCode to find your Lua runtime:

**1. Update launch.json**

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug All Tests",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/tests/test_common_lib.lua",
            "cwd": "${workspaceFolder}/TEST_SUITE/tests",
            "stopOnEntry": false,
            "luaVersion": "5.1",
            "luaPath": "lua"  // or full path like "C:\\lua\\bin\\lua.exe"
        }
    ]
}
```

**2. Update settings.json**

```json
{
    "Lua.runtime.version": "Lua 5.1",
    "Lua.runtime.path": [
        "?.lua",
        "?/init.lua",
        "lua/?.lua",
        "lua/?/init.lua"
    ],
    "Lua.diagnostics.globals": [
        "require",
        "module",
        "_G",
        "GetTickCount",
        "GetCurrentTimeMs",
        "ArrayList",
        "HashMap",
        "Vector2f",
        "Vector3f"
    ]
}
```

**3. Configure Debugger Extension**

Install **Lua Debug** extension (actboy168):

1. Open Extensions (`Ctrl+Shift+X`)
2. Search "lua-debug" or "actboy168"
3. Install and reload VSCode

### Test the Setup

Create a test file `verify_lua.lua`:

```lua
-- verify_lua.lua
-- Verify Lua 5.1 installation and test framework

print("=== Lua 5.1 Verification ===")
print("Lua version: " .. _VERSION)
print("Lua path: " .. package.path)
print()

-- Check Lua version is 5.1
local major, minor = _VERSION:match("Lua (%d+)%.(%d+)")
assert(major == "5" and minor == "1", "Must be Lua 5.1")
print("✓ Lua version is 5.1")

-- Test basic features
local function test_basics()
    local t = {1, 2, 3}
    assert(#t == 3, "Table length should work")
    
    local function greet(name)
        return "Hello, " .. name
    end
    assert(greet("World") == "Hello, World", "Functions should work")
    
    print("✓ Basic Lua features work")
end

test_basics()

-- Test module loading
local function test_modules()
    -- Test that table library works
    assert(table.insert, "table.insert should exist")
    assert(table.remove, "table.remove should exist")
    print("✓ Standard library modules work")
end

test_modules()

-- Test string functions
local function test_strings()
    assert(string.sub("hello", 1, 2) == "he", "string.sub should work")
    assert(string.format("%d", 42) == "42", "string.format should work")
    print("✓ String functions work")
end

test_strings()

-- Test math functions
local function test_math()
    assert(math.sqrt(4) == 2, "math.sqrt should work")
    assert(math.floor(3.7) == 3, "math.floor should work")
    print("✓ Math functions work")
end

test_math()

print()
print("=== All verifications passed ===")
print("Your Lua 5.1 environment is ready for testing!")
```

Run verification:

```bash
cd TEST_SUITE
lua verify_lua.lua
```

Expected output:

```
=== Lua 5.1 Verification ===
Lua version: Lua 5.1.5
Lua path: ?.lua;?/init.lua;...

✓ Lua version is 5.1
✓ Basic Lua features work
✓ Standard library modules work
✓ String functions work
✓ Math functions work

=== All verifications passed ===
Your Lua 5.1 environment is ready for testing!
```

### Test with Framework

Verify test framework works with your Lua:

```bash
cd TEST_SUITE/tests
lua test_common_lib.lua
```

Should see:

```
======================================================================
TEST SUITE
======================================================================

Module loading: pz_lua_commons exists              OK
Module loading: pz_utils exists                   OK
...
```

### Environment Variables

Set up environment variables for convenience:

**Windows (PowerShell)**:

```powershell
# Add to PowerShell profile
$PROFILE

# Edit file, add:
$env:LUA_PATH = "C:\lua\bin"
$env:LUA_HOME = "C:\lua"

# Verify
$env:LUA_PATH
```

**macOS/Linux**:

```bash
# Add to ~/.bashrc or ~/.zshrc
export LUA_HOME=/usr/local/opt/lua@5.1
export LUA_BIN=$LUA_HOME/bin
export PATH=$LUA_BIN:$PATH

# Reload shell
source ~/.bashrc
# or
source ~/.zshrc

# Verify
echo $LUA_PATH
```

### Troubleshooting

**Problem: "lua command not found"**

Solution:

```bash
# Find where lua is installed
which lua
which lua5.1

# If found, add to PATH (see platform-specific steps above)

# If not found, reinstall:
# Windows: Download from luaforwindows.com
# macOS: brew install lua@5.1
# Linux: apt-get install lua5.1
```

**Problem: "Wrong Lua version (have X.X, need 5.1)"**

Solution:

```bash
# Check installed version
lua -v

# You may have multiple versions installed
which lua51

# Create symlink or alias
# Windows: mklink lua.exe lua51.exe
# macOS/Linux: ln -s /usr/bin/lua5.1 /usr/bin/lua
```

**Problem: "Lua works but VSCode debugger doesn't"**

Solution:

1. Install Lua Debug extension: https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug
2. Update `.vscode/launch.json` with correct path:
   ```json
   "luaPath": "C:\\lua\\bin\\lua.exe"  // Windows (use full path)
   "luaPath": "/usr/local/bin/lua"      // macOS
   "luaPath": "/usr/bin/lua5.1"         // Linux
   ```

**Problem: "Tests fail with module not found"**

Solution:

1. Verify package.path includes test directories:
   ```bash
   lua -e "print(package.path)"
   ```

2. Update paths in test file:
   ```lua
   local testDir = debug.getinfo(1).source:match("@?(.*/)")
   package.path = testDir .. "?.lua;" 
                .. testDir .. "../../pz_lua_commons/common/media/lua/shared/?.lua;"
                .. package.path
   ```

3. Test module loading:
   ```bash
   cd TEST_SUITE/tests
   lua -e "require('mock_pz')" && echo "Success"
   ```

---

## VSCode Configuration

### Setup for Test Execution

Configure VSCode to run and debug tests with keyboard shortcuts and task runners.

### 1. tasks.json - Run Tests

Create `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run All Tests",
            "type": "shell",
            "command": "lua",
            "args": ["test_common_lib.lua"],
            "options": {
                "cwd": "${workspaceFolder}/TEST_SUITE/tests"
            },
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "problemMatcher": [],
            "group": {
                "kind": "test",
                "isDefault": true
            }
        },
        {
            "label": "Run Utils Tests",
            "type": "shell",
            "command": "lua",
            "args": ["test_pz_utils_escape.lua"],
            "options": {
                "cwd": "${workspaceFolder}/TEST_SUITE/tests"
            },
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Run Array Tests",
            "type": "shell",
            "command": "lua",
            "args": ["test_pz_utils_konijima.lua"],
            "options": {
                "cwd": "${workspaceFolder}/TEST_SUITE/tests"
            },
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Run Sandbox Tests",
            "type": "shell",
            "command": "lua",
            "args": ["test_sandbox_vars_module.lua"],
            "options": {
                "cwd": "${workspaceFolder}/TEST_SUITE/tests"
            },
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            },
            "problemMatcher": []
        }
    ]
}
```

**Key Settings**:

| Setting | Purpose |
|---------|---------|
| `"label"` | Task name shown in VSCode |
| `"type": "shell"` | Run as shell command |
| `"command": "lua"` | Execute `lua` binary |
| `"args"` | Arguments to lua (test file) |
| `"cwd"` | Working directory for test |
| `"presentation"` | How to show output |
| `"group": "test"` | Mark as test task |
| `"isDefault": true` | Run on `Ctrl+Shift+B` |

**Usage**:

- Press `Ctrl+Shift+B` to run default task (All Tests)
- Press `Ctrl+Shift+P` → "Tasks: Run Task" to select specific test
- Output appears in integrated terminal

### 2. launch.json - Debug Tests

Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug All Tests",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/tests/test_common_lib.lua",
            "cwd": "${workspaceFolder}/TEST_SUITE/tests",
            "stopOnEntry": false
        },
        {
            "name": "Debug Utils Tests",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/tests/test_pz_utils_escape.lua",
            "cwd": "${workspaceFolder}/TEST_SUITE/tests",
            "stopOnEntry": false
        },
        {
            "name": "Debug Array Tests",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/tests/test_pz_utils_konijima.lua",
            "cwd": "${workspaceFolder}/TEST_SUITE/tests",
            "stopOnEntry": false
        },
        {
            "name": "Debug Sandbox Tests",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/tests/test_sandbox_vars_module.lua",
            "cwd": "${workspaceFolder}/TEST_SUITE/tests",
            "stopOnEntry": false
        },
        {
            "name": "Debug Example",
            "type": "lua",
            "request": "launch",
            "program": "${workspaceFolder}/TEST_SUITE/examples/example_usage.lua",
            "cwd": "${workspaceFolder}",
            "stopOnEntry": false
        }
    ]
}
```

**Key Settings**:

| Setting | Purpose |
|---------|---------|
| `"name"` | Configuration shown in Run menu |
| `"type": "lua"` | Use Lua debugger |
| `"request": "launch"` | Start new process |
| `"program"` | Test file to debug |
| `"cwd"` | Working directory |
| `"stopOnEntry"` | Stop at first line (true/false) |

**Usage**:

- Press `F5` to start debugging (first config)
- Click "Run" → select config from dropdown
- Set breakpoints by clicking line numbers
- Step through code with F10/F11
- View variables in left panel

### 3. Required Extensions

Install VSCode extensions for Lua debugging:

**Extensions.json** - Auto-install on workspace load:

```json
{
    "recommendations": [
        "actboy168.lua-debug",
        "sumneko.lua",
        "dwenegar.simple-lua-debug"
    ]
}
```

**Install Manually**:

1. Press `Ctrl+Shift+X` (Extensions)
2. Search and install:
   - **Lua Debug** (actboy168) - For debugging
   - **Lua** (sumneko) - For IntelliSense

### 4. Keybindings for Testing

Add to `.vscode/keybindings.json`:

```json
[
    {
        "key": "ctrl+shift+b",
        "command": "workbench.action.tasks.runTask",
        "args": "Run All Tests"
    },
    {
        "key": "f5",
        "command": "workbench.action.debug.start"
    },
    {
        "key": "shift+f5",
        "command": "workbench.action.debug.stop"
    },
    {
        "key": "ctrl+alt+t",
        "command": "workbench.action.terminal.new"
    }
]
```

### 5. Workflow Example

**Run tests from VSCode**:

1. Open test file: `TEST_SUITE/tests/test_common_lib.lua`
2. Press `Ctrl+Shift+B` → Runs all tests in terminal
3. View output in integrated terminal
4. If test fails, check error message

**Debug tests from VSCode**:

1. Open test file
2. Click line number to set breakpoint (red dot)
3. Press `F5` → Starts debugger
4. Pauses at breakpoint
5. Step through with F10
6. View variables in "Variables" panel
7. Press F5 again to continue

**Custom keybindings**:

| Key | Action |
|-----|--------|
| `Ctrl+Shift+B` | Run default test task |
| `F5` | Start debugging |
| `Shift+F5` | Stop debugging |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |

### 6. settings.json for Lua

Configure `.vscode/settings.json` to ensure Lua 5.1 is used for IntelliSense and debugging:

```json
{
    "Lua.runtime.version": "Lua 5.1",
    "lua.debug.settings.luaVersion": "lua51",
    "Lua.diagnostics.globals": [
        "require",
        "module",
        "_G",
        "GetTickCount",
        "GetCurrentTimeMs",
        "ArrayList",
        "HashMap",
        "Vector2f",
        "Vector3f",
        "Character",
        "Item",
        "GameState"
    ],
    "Lua.workspace.library": [
        "${workspaceFolder}/pz_lua_commons/common/media/lua/shared",
        "${workspaceFolder}/TEST_SUITE/tests"
    ],
    "Lua.workspace.ignoreDir": [
        ".git",
        ".vscode",
        "node_modules",
        ".tmp"
    ],
    "editor.formatOnSave": true,
    "files.trimFinalNewlines": true,
    "files.trimTrailingWhitespace": true
}
```

**Key Settings Explained**:

| Setting | Purpose |
|---------|---------|
| `"Lua.runtime.version": "Lua 5.1"` | IntelliSense uses Lua 5.1 stdlib |
| `"lua.debug.settings.luaVersion": "lua51"` | **Debugger uses Lua 5.1** (critical for Kahlua2) |
| `"Lua.diagnostics.globals"` | Custom PZ API globals (no "undefined" warnings) |
| `"Lua.workspace.library"` | Where to find library files for completion |
| `"Lua.workspace.ignoreDir"` | Don't scan these directories |

**Why These Settings Matter**:

1. **`lua.debug.settings.luaVersion`** ensures the debugger matches your installed Lua 5.1
2. **`Lua.runtime.version`** ensures IntelliSense suggests only Lua 5.1 features
3. **`Lua.diagnostics.globals`** prevents false warnings about PZ APIs like `ArrayList`, `Character`, etc.
4. **`Lua.workspace.library`** enables autocomplete for your commons libraries

**Complete Example with Kahlua2 PZ APIs**:

```json
{
    "Lua.runtime.version": "Lua 5.1",
    "lua.debug.settings.luaVersion": "lua51",
    "Lua.diagnostics.globals": [
        "require",
        "module",
        "_G",
        
        // Kahlua2/PZ APIs
        "GetTickCount",
        "GetCurrentTimeMs",
        "ArrayList",
        "HashMap",
        "Vector2f",
        "Vector3f",
        "Character",
        "Item",
        "GameState",
        "Registry",
        "Coroutine",
        
        // Commons libraries
        "pz_commons",
        "pz_utils",
        "middleclass",
        "lunajson",
        "signal",
        "SafeLogger",
        "Debounce",
        "EventManager"
    ],
    "Lua.workspace.library": [
        "${workspaceFolder}/pz_lua_commons/common/media/lua/shared",
        "${workspaceFolder}/TEST_SUITE/tests"
    ],
    "Lua.workspace.ignoreDir": [
        ".git",
        ".vscode",
        "node_modules",
        ".tmp",
        "workshop"
    ],
    "Lua.format.enable": false,
    "editor.formatOnSave": true,
    "files.trimFinalNewlines": true,
    "files.trimTrailingWhitespace": true,
    "[lua]": {
        "editor.defaultFormatter": "sumneko.lua",
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    }
}
```

**Verify Your Setup**:

After updating `settings.json`:

1. Reload VSCode: `Ctrl+Shift+P` → "Developer: Reload Window"
2. Open a test file: `TEST_SUITE/tests/test_common_lib.lua`
3. Hover over `ArrayList` or other PZ globals
   - Should show no "undefined" warnings
   - IntelliSense should work
4. Press `F5` to debug
   - Debugger should start without errors
   - Should use your installed Lua 5.1

**Troubleshooting settings.json**:

**Problem**: "lua.debug.settings.luaVersion not recognized"

**Solution**: Make sure you have the **Lua Debug** extension installed:
```bash
# From VSCode Extensions (Ctrl+Shift+X), search and install:
# "Lua Debug" by actboy168
```

**Problem**: IntelliSense shows "undefined global" for ArrayList, HashMap, etc.

**Solution**: Add to `Lua.diagnostics.globals` in settings.json (shown above)

**Problem**: Debugger says "wrong Lua version"

**Solution**: Specify full path in `launch.json`:
```json
{
    "luaPath": "C:\\lua\\bin\\lua.exe",  // Windows
    "luaVersion": "5.1"
}
```

---

## Test Framework

### Assertion API

```lua
-- Equality check
TestRunner.assert_equals(actual, expected, "message")

-- Boolean check
TestRunner.assert_true(value, "message")

-- Nil check
TestRunner.assert_not_nil(value, "message")

-- Type check
TestRunner.assert_is_type(value, "string", "should be string")

-- Custom assertion
local function assert_contains(list, item, message)
    for _, v in ipairs(list) do
        if v == item then return end
    end
    error(message)
end
```

### Test Registration

```lua
TestRunner.register("Feature: description", function()
    -- Test code here
    local result = someFunction()
    TestRunner.assert_equals(result, expected, "should return expected")
end)
```

### Running Tests

```bash
cd TEST_SUITE/tests
lua test_common_lib.lua
```

Output:

```
======================================================================
TEST SUITE
======================================================================

Module loading: pz_lua_commons exists              OK
Module loading: pz_utils exists                   OK
lunajson: encode basic table                      OK
...

======================================================================
TEST RESULTS
======================================================================
Passed: 50
Failed: 0
Total:  50

✓ ALL TESTS PASSED
```

---

## Mock/Stub Strategy

### 1. Contract-Based Mocks

Define what the stub must do:

```lua
-- Stub contract for Item
-- class Item {
--     String getName()
--     int getWeight()
--     int getValue()
-- }

-- Mock implementation
local Item = {}
Item.__index = Item

function Item.new(name, weight, value)
    return setmetatable({
        _name = name,
        _weight = weight,
        _value = value
    }, Item)
end

function Item:getName()
    return self._name
end

function Item:getWeight()
    return self._weight
end

function Item:getValue()
    return self._value
end

return Item
```

### 2. Minimal Implementation

Only implement what's actually used:

```lua
-- BAD: Over-implementation
function Item:setName(name) end
function Item:setWeight(weight) end
function Item:setDurability(d) end
function Item:repair() end
function Item:isWeapon() end
-- ... 10 more methods

-- GOOD: Only what's tested
function Item:getName()
    return self._name
end

function Item:getWeight()
    return self._weight
end
```

### 3. Behavior Matching

Mock behavior must match real stub:

```lua
-- Stub behavior: ArrayList add always returns boolean
function ArrayList:add(item)
    table.insert(self._items, item)
    return true  -- Matches stub contract
end

-- Test verifies this
local result = list:add("item")
TestRunner.assert_equals(type(result), "boolean")
```

### 4. Java Collection Mocks

Map common Java classes:

```lua
-- ArrayList -> Lua table wrapper
function ArrayList:toArray()
    return self._items
end

function ArrayList:iterator()
    -- Simple iterator
    local index = 0
    return function()
        index = index + 1
        return self._items[index]
    end
end

-- HashMap -> Lua table wrapper
function HashMap:keySet()
    local keys = {}
    for k in pairs(self._map) do
        table.insert(keys, k)
    end
    return keys
end

function HashMap:entrySet()
    local entries = {}
    for k, v in pairs(self._map) do
        table.insert(entries, { key = k, value = v })
    end
    return entries
end
```

### 5. Global Setup

Inject mocks into global scope:

```lua
-- mock_pz.lua
function mock_pz.setupGlobalEnvironment()
    _G.ArrayList = ArrayList
    _G.HashMap = HashMap
    _G.Vector2f = Vector2f
    _G.Vector3f = Vector3f
    _G.Character = Character
    _G.Item = Item
    _G.GameState = GameState
    _G.GetTickCount = GetTickCount
    _G.GetCurrentTimeMs = GetCurrentTimeMs
end

-- In test file
local mock_pz = require("mock_pz")
mock_pz.setupGlobalEnvironment()

-- Now ArrayList, Vector2f, etc. are globally available
```

---

## Testing Patterns

### Pattern 1: Unit Testing a Library

Test individual library features in isolation:

```lua
TestRunner.register("lunajson: handle nested tables", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    
    local data = {
        user = {
            name = "Bob",
            age = 30,
            inventory = {"sword", "shield"}
        }
    }
    
    local json = lunajson.encode(data)
    local decoded = lunajson.decode(json)
    
    TestRunner.assert_equals(decoded.user.name, "Bob")
    TestRunner.assert_equals(decoded.user.age, 30)
    TestRunner.assert_equals(#decoded.user.inventory, 2)
end)
```

### Pattern 2: Testing with Mocks

Test code that uses game objects:

```lua
TestRunner.register("Integration: Inventory with ArrayList", function()
    -- Create mock objects
    local inv = ArrayList.new()
    
    -- Populate
    inv:add(Item.new("sword", 5, 100))
    inv:add(Item.new("shield", 8, 75))
    
    -- Test
    TestRunner.assert_equals(inv:size(), 2)
    local item1 = inv:get(1)
    TestRunner.assert_equals(item1:getName(), "sword")
end)
```

### Pattern 3: Testing Real Library + Mocks

Test that real libraries work with mock objects:

```lua
TestRunner.register("Integration: JSON serialize mock objects", function()
    local lunajson = pz_commons.grafi_tt.lunajson
    
    -- Create mock
    local char = Character.new("Player", 100, 100)
    
    -- Use real library with mock
    local data = {
        name = char:getName(),
        health = char:getHealth(),
        position = {
            x = char:getX(),
            y = char:getY()
        }
    }
    
    local json = lunajson.encode(data)
    
    -- Verify
    TestRunner.assert_is_type(json, "string")
    local decoded = lunajson.decode(json)
    TestRunner.assert_equals(decoded.name, "Player")
end)
```

### Pattern 4: Testing OOP with Mocks

Test classes that use game APIs:

```lua
TestRunner.register("Integration: Custom class with mock objects", function()
    local middleclass = pz_commons.kikito.middleclass
    
    -- Define custom class using mocks
    local Survivor = middleclass("Survivor")
    
    function Survivor:initialize(name, maxHealth)
        self.name = name
        self.character = Character.new(name, maxHealth, maxHealth)
        self.inventory = ArrayList.new()
    end
    
    function Survivor:takeDamage(amount)
        self.character:takeDamage(amount)
        return self.character:isAlive()
    end
    
    function Survivor:addItem(item)
        self.inventory:add(item)
    end
    
    -- Test the class
    local survivor = Survivor("Bob", 100)
    
    survivor:addItem(Item.new("water", 1, 10))
    TestRunner.assert_equals(survivor.inventory:size(), 1)
    
    survivor:takeDamage(50)
    TestRunner.assert_equals(survivor.character:getHealth(), 50)
end)
```

### Pattern 5: Event Testing

Test event systems:

```lua
TestRunner.register("Integration: Event system with mocks", function()
    local signal = pz_commons.vrld.hump_signal
    local EventManager = pz_utils.escape.EventManager
    
    -- Setup event listeners
    local events = EventManager.new()
    local itemAdded = nil
    
    signal.register("item_added", function(item)
        itemAdded = item
    end)
    
    -- Trigger event with mock object
    local item = Item.new("potion", 2, 50)
    signal.emit("item_added", item)
    
    -- Verify
    TestRunner.assert_equals(itemAdded:getName(), "potion")
end)
```

---

## Best Practices

### 1. Test Organization

Group related tests:

```lua
-- ✓ GOOD: Clear sections
-- ============================================================================
-- LOADING TESTS
-- ============================================================================
TestRunner.register("Load: pz_commons", function() ... end)
TestRunner.register("Load: pz_utils", function() ... end)

-- ============================================================================
-- LIBRARY TESTS
-- ============================================================================
TestRunner.register("Library: lunajson encode", function() ... end)
TestRunner.register("Library: lunajson decode", function() ... end)

-- ============================================================================
-- STUB TESTS
-- ============================================================================
TestRunner.register("Stub: ArrayList operations", function() ... end)

-- ✗ BAD: Random order
TestRunner.register("Some test 1", function() ... end)
TestRunner.register("Random test 2", function() ... end)
TestRunner.register("Another test 1", function() ... end)
```

### 2. Clear Test Names

Use consistent naming:

```lua
-- ✓ GOOD: {Category}: {Feature} {Behavior}
TestRunner.register("Library: lunajson encodes basic types", function()
TestRunner.register("Stub: ArrayList removes items correctly", function()
TestRunner.register("Integration: JSON + ArrayList serialize", function()

-- ✗ BAD: Vague names
TestRunner.register("test 1", function()
TestRunner.register("thing works", function()
TestRunner.register("check it", function()
```

### 3. One Assertion Focus

Each test should focus on one thing:

```lua
-- ✓ GOOD: One responsibility
TestRunner.register("ArrayList: add returns true", function()
    local list = ArrayList.new()
    local result = list:add("item")
    TestRunner.assert_equals(result, true)
end)

TestRunner.register("ArrayList: add increases size", function()
    local list = ArrayList.new()
    list:add("item")
    TestRunner.assert_equals(list:size(), 1)
end)

-- ✗ BAD: Multiple concerns
TestRunner.register("ArrayList: add works", function()
    local list = ArrayList.new()
    local result = list:add("item")
    TestRunner.assert_equals(result, true)
    TestRunner.assert_equals(list:size(), 1)
    TestRunner.assert_equals(list:get(1), "item")
    -- If this fails, which part broke?
end)
```

### 4. Mock Contract Validation

Always verify mocks match stubs:

```lua
-- Document what stub defines
-- Stub contract for ArrayList:
--   add(item) -> boolean
--   get(index) -> Object | nil
--   size() -> number
--   remove(index) -> Object | nil

-- Verify mock matches contract
TestRunner.register("Stub Contract: ArrayList.add returns boolean", function()
    local list = ArrayList.new()
    local result = list:add("item")
    TestRunner.assert_is_type(result, "boolean")
end)

TestRunner.register("Stub Contract: ArrayList.get returns Object or nil", function()
    local list = ArrayList.new()
    list:add("item")
    local result = list:get(1)
    TestRunner.assert_not_nil(result)
    TestRunner.assert_equals(result, "item")
    
    local notFound = list:get(999)
    TestRunner.assert_equals(notFound, nil)
end)
```

### 5. Path Management

Handle paths consistently:

```lua
-- ✓ GOOD: Relative to test file
local testDir = debug.getinfo(1).source:match("@?(.*/)")
package.path = testDir .. "?.lua;" .. package.path

-- Add commons path
package.path = testDir .. "../../pz_lua_commons/common/media/lua/shared/?.lua;" 
             .. package.path

-- ✗ BAD: Hardcoded absolute paths
package.path = "C:\\Users\\Bob\\Project\\TEST_SUITE\\tests\\?.lua;" .. package.path
-- Breaks on different machines
```

### 6. Error Messages

Provide clear error context:

```lua
-- ✓ GOOD: Descriptive
TestRunner.assert_equals(list:size(), 2, 
    "ArrayList should contain 2 items after adding twice")

TestRunner.assert_equals(char:getHealth(), 75,
    "Character health should be 75 after taking 25 damage from 100")

-- ✗ BAD: Vague
TestRunner.assert_equals(list:size(), 2)
TestRunner.assert_equals(char:getHealth(), 75)
```

### 7. Setup and Teardown

Clean state between tests:

```lua
-- Create helper for test setup
local function setupTestCharacter(name, health)
    return Character.new(name, health, health)
end

-- Use in tests
TestRunner.register("Character: takes damage", function()
    local char = setupTestCharacter("Bob", 100)
    char:takeDamage(25)
    TestRunner.assert_equals(char:getHealth(), 75)
end)

TestRunner.register("Character: tracks position", function()
    local char = setupTestCharacter("Alice", 100)
    char:setPosition(10, 20)
    TestRunner.assert_equals(char:getX(), 10)
    TestRunner.assert_equals(char:getY(), 20)
end)
```

---

## Examples

### Complete Test File

See `examples/example_usage.lua` for real-world patterns:

```lua
-- example_usage.lua
-- Real-world integration patterns for PZ mods

local pz_commons = require("pz_lua_commons/shared")
local lunajson = pz_commons.grafi_tt.lunajson
local middleclass = pz_commons.kikito.middleclass
local signal = pz_commons.vrld.hump_signal
local SafeLogger = pz_utils.escape.SafeLogger
local Debounce = pz_utils.escape.Debounce

-- ============================================================================
-- EXAMPLE 1: JSON Serialization
-- ============================================================================

local function exportPlayerData(player)
    local data = {
        name = player:getName(),
        health = player:getHealth(),
        position = {
            x = player:getX(),
            y = player:getY()
        },
        inventory = {}
    }
    
    for i = 1, player:getInventorySize() do
        local item = player:getInventoryItem(i)
        table.insert(data.inventory, {
            name = item:getName(),
            weight = item:getWeight()
        })
    end
    
    return lunajson.encode(data)
end

-- ============================================================================
-- EXAMPLE 2: OOP with Middleclass
-- ============================================================================

local Character = middleclass("Character")

function Character:initialize(name, maxHealth)
    self.name = name
    self.maxHealth = maxHealth
    self.health = maxHealth
    self.equipment = {}
end

function Character:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
end

function Character:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
end

function Character:isAlive()
    return self.health > 0
end

-- ============================================================================
-- EXAMPLE 3: Event System
-- ============================================================================

local EventDispatcher = middleclass("EventDispatcher")

function EventDispatcher:initialize()
    self.listeners = {}
end

function EventDispatcher:on(event, callback)
    signal.register(event, callback)
end

function EventDispatcher:emit(event, ...)
    signal.emit(event, ...)
end

-- ============================================================================
-- EXAMPLE 4: Logging and Debouncing
-- ============================================================================

local logger = SafeLogger.new("MyMod", "DEBUG")
local debouncedSave = Debounce.new(5000, function()
    logger:info("Saving game state")
    -- Save logic
end)

-- Register debounced function
signal.register("player_moved", function()
    logger:debug("Player moved")
    debouncedSave:call()
end)

-- ============================================================================
-- EXAMPLE 5: Combined Workflow
-- ============================================================================

local Inventory = middleclass("Inventory")

function Inventory:initialize(owner)
    self.owner = owner
    self.items = {}
    self.logger = SafeLogger.new("Inventory")
end

function Inventory:addItem(item)
    table.insert(self.items, item)
    self.logger:info(string.format(
        "Added %s to %s inventory",
        item:getName(),
        self.owner:getName()
    ))
    signal.emit("inventory_changed", self)
end

function Inventory:toJSON()
    local data = {}
    for _, item in ipairs(self.items) do
        table.insert(data, {
            name = item:getName(),
            weight = item:getWeight()
        })
    end
    return lunajson.encode(data)
end

-- Use in test
local function testCompleteWorkflow()
    local player = Character("Hero", 100)
    local inventory = Inventory(player)
    
    inventory:addItem(MockItem("sword", 10))
    inventory:addItem(MockItem("shield", 8))
    
    local json = inventory:toJSON()
    local data = lunajson.decode(json)
    
    assert(#data == 2, "Should have 2 items")
    assert(data[1].name == "sword", "First item should be sword")
end
```

---

## Troubleshooting

### Problem: "module not found"

**Cause**: Incorrect package path

**Solution**:

```lua
-- Add correct path before require
local testDir = debug.getinfo(1).source:match("@?(.*/)")
package.path = testDir .. "?.lua;" 
             .. testDir .. "../../pz_lua_commons/common/media/lua/shared/?.lua;"
             .. package.path

local pz_commons = require("pz_lua_commons/shared")
```

### Problem: Tests pass locally but fail in PZ

**Cause**: Using non-stub APIs or Kahlua2-incompatible features (see "Kahlua2 Limitations" in Core Concepts)

**Solution**:

1. Check `TEST_ARCHITECTURE.md` for stub contract rules
2. Verify method exists in actual PZ stub documentation
3. Avoid unsupported features listed in Core Concepts
4. Add test case for the failing pattern

### Problem: Mock behavior differs from PZ

**Cause**: Mock doesn't match actual stub implementation

**Solution**:

1. Update mock_pz.lua to match actual stub
2. Add test case verifying new behavior
3. Document the contract at top of mock:

```lua
-- ArrayList mock
-- Based on: projectzomboid_lua_stub.xml
-- Contract:
--   new() -> ArrayList
--   add(item) -> boolean
--   get(index) -> Object|nil
--   etc.

local ArrayList = {}
```

---

## Getting Started

### Quick Implementation Checklist

1. Create `mock_pz.lua` with stub implementations
2. Create `test_framework.lua` with assertion helpers
3. Create `test_*.lua` files with organized tests using `TestRunner.register()`
4. Run: `cd TEST_SUITE/tests && lua test_common_lib.lua`
5. Verify all tests pass (0 failures)
6. Add more tests as you add features

### Next Steps

1. Copy `TEST_SUITE/tests/mock_pz.lua` as base
2. Adapt mocks for your specific mod APIs
3. Create test file following patterns in Testing Patterns section
4. Add tests incrementally as you develop
5. Run before committing code
6. Update mocks when PZ stub changes

