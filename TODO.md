patch rxi/lume

# pz_lua_commons Project - TODO List

## Core Framework Improvements

- [x] **SafeLogger Refactor**: Refactor `pz_utils.escape.SafeLogger` (in `pz_lua_commons`) to support multiple instances.
    - **Current Issue**: It is a global singleton, causing topic collisions when multiple mods/modules call `.init()`.
    - **Proposed Solution**: Convert to a Class/Constructor pattern (e.g., `SafeLogger:new(topic)`) or delegate to a multi-instance library like `ZUL`.

## Example Rules & Tests
