# PZ Lua Commons

A curated collection of Lua libraries maintained for [Project Zomboid](https://projectzomboid.com/) modding. Includes purpose-built utilities (`pz_utils`) and established Lua libraries adapted for compatibility with Build 42.

## Purpose

**PZ Lua Commons** solves a common modding problem: code duplication. Instead of modders copying Lua libraries into each mod individually, this framework centralizes and maintains them, reducing:

- Duplicate file bloat across multiple mods
- Version conflicts when different mods bundle different versions
- Maintenance burden on modders
- Load-time overhead from redundant libraries

## What's Included

### Shared Libraries (Client & Server)

| Library                | Author                | Version | Purpose                                                                |
| ---------------------- | --------------------- | ------- | ---------------------------------------------------------------------- |
| **grafi-tt/lunajson**  | grafi-tt              | 1.2.3   | Fast JSON encoding/decoding                                            |
| **rxi/json.lua**       | rxi                   | v0.1.2  | JSON utilities                                                         |
| **kikito/middleclass** | kikito                | v4.1.1  | Object-oriented programming support                                    |
| **vrld/hump.signal**   | vrld                  | latest  | Event signaling and emitter system                                     |
| **pz_utils/escape**    | escape (maintained)   | —       | Event management, safe require, debouncing, logging, sandbox isolation |
| **pz_utils/konijima**  | konijima (maintained) | —       | General utility functions                                              |

### Client Libraries

| Library                | Author     | Version | Purpose                                  |
| ---------------------- | ---------- | ------- | ---------------------------------------- |
| **yonaba/30log**       | Yonaba     | 1.3.0   | Lightweight OOP library                  |
| **pkulchenko/serpent** | pkulchenko | 0.30    | Table serialization and introspection    |
| **kikito/inspect.lua** | kikito     | v3.1.3  | Debugging and table inspection utilities |

## Project Structure

This project follows the **pzstudio** workspace layout for Build 42 compatibility:

```
pz_lua_commons/
├── pz_lua_commons/          # Core framework mod
│   ├── common/              # Shared assets and Lua sources
│   │   └── media/lua/
│   │       ├── shared/      # Common libraries (pz_lua_commons, pz_utils)
│   │       └── client/      # Client-side only extensions
│   └── 42/                  # Build 42 metadata (mod.info)
├── pz_lua_commons_example/  # Example mod demonstrating usage
├── pz_lua_commons_test/     # Test suite for library validation
├── project.json             # pzstudio configuration
├── package.json             # Development & build scripts
└── workshop/                # Workshop metadata and staging
```

## Installation

### For Modders

1. Subscribe to **PZ Lua Commons** on the [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=3334270098)
2. In your mod's `mod.info` or dependencies, reference it as a dependency:
   - `id=pz_lua_commons`
3. Load the library in your Lua code:

```lua
-- Shared code (server and client)
local pz_utils = require("pz_utils_shared")
local commons = require("pz_lua_commons_shared")

-- Access utilities
local safeLog = pz_utils.escape.SafeLogger.new("MyMod")
safeLog:log("Hello World")
```

### For Developers

This project uses [**pzstudio**](https://github.com/escapepz/project-zomboid-studio) for maintenance and builds.

1. Clone the repository:

   ```bash
   git clone --recurse-submodules https://github.com/escapepz/pz_lua_commons.git
   cd pz_lua_commons
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Available commands (via pzstudio):
   ```bash
   npm run clean      # Clean build artifacts
   npm run build      # Clean and build
   npm run watch      # Build and watch for changes
   npm run update     # Update libraries and dependencies
   ```

## Credits

This project maintains and adapts libraries authored by:

- **grafi-tt** - lunajson
- **pkulchenko** - serpent
- **kikito** - middleclass, inspect.lua
- **rxi** - json.lua
- **Yonaba** - 30log
- **vrld** - hump
- **konijima** - General utilities

Original licenses and copyright notices are preserved with each library.

## License

MIT — See [LICENSE](LICENSE) for details.

---

**Maintained by**: escape  
**Last Updated**: March 2026
