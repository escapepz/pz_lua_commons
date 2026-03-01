# PZ Lua Commons Testing Suite

Complete integration test suite for validating `pz_lua_commons` compatibility with Project Zomboid Build 42 stub definitions.

## Overview

The **TEST_SUITE** provides a plain-Lua environment that mocks essential Project Zomboid engine APIs. This allows for rapid development and validation of libraries without requiring the full game runtime or complex setup.

## Deliverables

| File                           | Purpose                              | Location    |
| ------------------------------ | ------------------------------------ | ----------- |
| `test_common_lib.lua`          | Core integration tests (50+ tests)   | `tests/`    |
| `test_pz_utils_escape.lua`     | escape utility tests (32 tests)      | `tests/`    |
| `test_pz_utils_konijima.lua`   | konijima utility tests (39 tests)    | `tests/`    |
| `test_sandbox_vars_module.lua` | Sandbox variable module tests        | `tests/`    |
| `mock_pz.lua`                  | Comprehensive PZ API mocks and stubs | `tests/`    |
| `example_usage.lua`            | Real-world integration patterns      | `examples/` |

## Quick Test Run

To execute the full suite, run the following commands from the `TEST_SUITE/tests` directory:

```bash
lua test_common_lib.lua
lua test_pz_utils_escape.lua
lua test_pz_utils_konijima.lua
lua test_sandbox_vars_module.lua
```

Expected: **All tests pass** (120+ total tests, 0 failed).

## What's Tested

### Core Libraries

- **lunajson**: JSON encoding/decoding accuracy and round-trip consistency.
- **middleclass**: OOP patterns, inheritance, and instance management.
- **hump.signal**: Event signaling, subscriptions, and pattern matching.
- **pz_utils.escape**: SafeLogger, Debounce, EventManager, and SafeRequire.
- **pz_utils.konijima**: Environment detection, administrative checks, and utility functions.

### Integration Workflows

- **JSON + OOP**: Serialization and deserialization of custom class instances.
- **Events + Logging**: Verification of event-driven logging systems.
- **Mocks + Commons**: Validation that shared libraries work seamlessly with PZ stub objects.

### Stub Compatibility

- **Collections**: `ArrayList` and `HashMap` behavior.
- **Geometry**: `Vector2f` and `Vector3f` distance and position calculations.
- **Game Objects**: `Character`, `Item`, `Registry`, and `GameState` mock interactions.

## Architecture

### Mocking Strategy (mock_pz.lua)

The suite uses minimal, contract-based mocks that:

1. **Match exact stub signatures**: Method names and parameter counts match `projectzomboid_lua_stub.xml`.
2. **Implement stub behavior**: Mocks behave like their Java counterparts (e.g., `ArrayList:add` returns boolean).
3. **Environment Globals**: Mocks provide necessary PZ globals (`isServer`, `isClient`, `isSingleplayer`).

### Rule: No Invented APIs

Tests strictly enforce the use of official stub-defined methods.

- **Allowed**: `character:takeDamage(25)`, `character:isAlive()`.
- **Forbidden**: `character:setHealth(50)` (not in official stubs).

### Environment Audit

The following PZ-specific globals are mocked to ensure module loading and utility execution:

- `isServer()` / `isClient()` / `isSingleplayer()`
- `getPlayer()` / `getOnlinePlayers()`
- `instanceof(obj, class)`
- `sendClientCommand()` / `sendServerCommand()`
- `triggerEvent()`

## Files Explained

### `mock_pz.lua`

The backbone of the test environment. It injects PZ-specific classes and functions into the global scope. It handles Java-style collections (`ArrayList`, `HashMap`) and engine objects using Lua tables to simulate their behavior.

### `test_common_lib.lua`

The primary integration suite. It loads the full `pz_lua_commons` and `pz_utils` packages and verifies that all sub-libraries are available and functional within the mocked environment.

### `test_pz_utils_konijima.lua`

A specialized suite for testing environment-aware utilities. It includes 39 tests covering admin/staff permission logic, string processing, and coordinate parsing.

### `example_usage.lua`

A reference file demonstrating how to use the framework in a real mod. It's a "live" documentation of best practices combining JSON, OOP, and events.

## Extending Tests

### Add a New Test Case

```lua
TestRunner.register("Feature: description", function()
    local result = someFunction()
    TestRunner.assert_equals(result, expected, "message")
end)
```

### Add a New Stub Mock

1. Define the class in `mock_pz.lua`.
2. Implement the methods based on the official stub definition.
3. Expose it via `mock_pz.setupGlobalEnvironment()`.

## Troubleshooting

- **"module not found"**: Ensure `package.path` includes the library source directories.
- **"undefined global 'isServer'"**: Call `mock_pz.setupGlobalEnvironment()` before requiring libraries.
- **Test fails but code works in PZ**: Check if you are using an "invented" API that works in the real game but isn't in the official stubs (stubs are the baseline for compatibility).

---

**Last Updated**: March 2026  
**Status**: ✓ All tests passing (120+ cases)  
**Compatibility**: Build 42 (current)
