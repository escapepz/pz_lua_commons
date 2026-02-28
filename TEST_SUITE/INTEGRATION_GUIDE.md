# Integration Guide: pz_lua_commons with Project Zomboid

## Quick Start

### Files Structure
```
project/
├── examples/
│   └── example_usage.lua          # Real-world integration patterns
├── tests/
│   ├── mock_pz.lua                # PZ stub implementations for testing
│   └── test_common_lib.lua        # Comprehensive test suite (50+ tests)
└── TEST_ARCHITECTURE.md            # How tests ensure compatibility
```

## What Each File Does

### `example_usage.lua`
**Purpose**: Shows practical usage of all pz_lua_commons libraries with Project Zomboid

**Demonstrates**:
1. JSON serialization with lunajson
2. Event systems with hump.signal
3. Object-oriented programming with middleclass
4. Debouncing and logging with pz_utils
5. Combined workflows using multiple libraries

**Run in PZ**: Include as a mod script. Safe to use in actual gameplay.

### `mock_pz.lua`
**Purpose**: Provides minimal stub implementations for PZ APIs in plain Lua

**Includes**:
- `ArrayList`, `HashMap` (Java collections)
- `Vector2f`, `Vector3f` (geometry)
- `Character`, `Item` (game objects)
- `GameState`, `Registry` (utilities)

**Why needed**: Allows tests to run without PZ runtime. Each mock matches the actual stub definition exactly.

### `test_common_lib.lua`
**Purpose**: Validates pz_lua_commons works with PZ stub definitions

**Test Coverage**:
- Module loading (5 tests)
- JSON processing (3 tests)
- OOP patterns (5 tests)
- Event handling (4 tests)
- Utilities (15+ tests)
- Integration workflows (5 tests)
- Stub compatibility (5 tests)

**Run**: `lua test_common_lib.lua` from `tests/` directory

## Compatibility Guarantee

If tests pass ✓, then:
1. All libraries load correctly
2. Libraries work together without conflicts
3. Mock implementations match stub contracts
4. Code will work in actual PZ without modification
5. No invented/undocumented APIs are used

## Key Rules Applied

### 1. Only Use Stub-Defined Methods
```lua
-- ✓ GOOD - defined in stub
character:takeDamage(25)
character:isAlive()
character:addItem(item)

-- ✗ BAD - not in stub definition
character:setHealth(50)
character:giveAllItems()
```

### 2. Mocks Match Stubs Exactly
```lua
-- Mock implements exactly what stub defines
function Character:takeDamage(amount)
    self:setHealth(self._health - amount)
    return not self._isAlive
end

-- Tests verify this works
TestRunner.assert_true(char:takeDamage(30))
```

### 3. No Runtime-Specific Code
```lua
-- ✓ GOOD - works in plain Lua + PZ
local data = {name = "Alice", hp = 100}
local json = lunajson.encode(data)

-- ✗ BAD - requires PZ runtime
getPlayer():say("Hello")  -- undefined in plain Lua
```

## Test Architecture

### Test Categories

**1. Module Loading Tests**
Ensure all libraries load from the correct paths without errors.

**2. Library-Specific Tests**
For each library (lunajson, middleclass, hump.signal, pz_utils), verify:
- Core functions work
- Method signatures match expectations
- Return types are correct
- Edge cases are handled

**3. Integration Tests**
Combine multiple libraries to validate they work together:
- JSON + OOP: Serialize custom classes
- Events + Logging: Log event emissions
- Debounce + OOP: Debounce method calls
- Mocks + Commons: Use stub objects with commons libraries

**4. Stub Compatibility Tests**
Verify mock implementations correctly model stub behavior:
- ArrayList add/get/size
- Vector2f distance calculation
- Character health management
- Item properties
- Registry get/set

## How to Verify Compatibility

### Run Tests
```bash
cd TEST_SUITE/tests
lua test_common_lib.lua
```

Expected output:
```
======================================================================
PZ_LUA_COMMONS INTEGRATION TEST SUITE
======================================================================
Module loading: pz_lua_commons exists           OK
Module loading: pz_utils exists                 OK
lunajson: encode basic table                    OK
lunajson: decode JSON string                    OK
...
Passed: 50
Failed: 0

✓ ALL TESTS PASSED
======================================================================
```

### Test One Feature
```bash
lua -c "
  package.path = package.path .. ';../pz_lua_commons/common/media/lua/shared/?.lua'
  local pz_commons = require('pz_lua_commons/shared')
  local data = {test = 'value'}
  local json = pz_commons.grafi_tt.lunajson.encode(data)
  print('Encoded: ' .. json)
"
```

### Use in Your Mod
```lua
-- my_mod.lua
local pz_commons = require("pz_lua_commons/shared")
local pz_utils = require("pz_utils/shared")

-- All tested functions available
local json = pz_commons.grafi_tt.lunajson.encode({test = true})
local logger = pz_utils.escape.SafeLogger.new("MyMod")
logger:log("Mod loaded", 20)
```

## Troubleshooting

### "Module not found" error
**Cause**: Package path not configured correctly

**Fix**:
```lua
package.path = package.path .. ";pz_lua_commons/common/media/lua/shared/?.lua"
local pz_commons = require("pz_lua_commons/shared")
```

### Tests fail with "undefined method"
**Cause**: Stub definition was updated or mock incomplete

**Fix**:
1. Check if actual PZ stub has the method
2. Add to mock_pz.lua matching stub signature
3. Add test for the new method
4. Run `lua test_common_lib.lua` to verify

### Code works in test but not in PZ
**Cause**: Using plain Lua function that doesn't exist in PZ

**Fix**:
1. Check TEST_ARCHITECTURE.md rule #4 (No invented APIs)
2. Replace with stub-defined equivalent
3. Add integration test for the pattern
4. Verify with actual PZ runtime

## Example: Adding New Stub Support

If you need to support a new PZ API:

**1. Add mock to `mock_pz.lua`:**
```lua
local NewClass = {}
NewClass.__index = NewClass

function NewClass.new()
    return setmetatable({}, NewClass)
end

function NewClass:someMethod()
    -- Implementation
end

mock_pz.NewClass = NewClass
```

**2. Add test to `test_common_lib.lua`:**
```lua
TestRunner.register("Stub: NewClass method call", function()
    local obj = NewClass.new()
    obj:someMethod()
    TestRunner.passed = TestRunner.passed + 1
end)
```

**3. Add example to `example_usage.lua`:**
```lua
-- Usage example for NewClass with commons
```

**4. Run tests:**
```bash
lua test_common_lib.lua
```

## References

- **Stub definitions**: projectzomboid_lua_stub.xml
- **Test framework**: test_common_lib.lua (simple custom assertions)
- **Library docs**: 
  - lunajson: JSON encoding/decoding
  - middleclass: OOP class system
  - hump.signal: Event signaling
  - pz_utils.escape: SafeLogger, Debounce, EventManager

## Support

If tests pass but PZ integration fails:
1. Check the test output for failures
2. Review TEST_ARCHITECTURE.md section "How Tests Ensure Stub Compatibility"
3. Verify actual PZ method signatures match mocks
4. Add failing case to test suite and fix
