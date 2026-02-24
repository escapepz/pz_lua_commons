# PZ Lua Commons

A curated collection of Lua libraries maintained for [Project Zomboid](https://projectzomboid.com/) modding. Includes purpose-built utilities (`pz_utils`) and established Lua libraries adapted for compatibility with the game.

## Purpose

**PZ Lua Commons** solves a common modding problem: code duplication. Instead of modders copying Lua libraries into each mod individually, this framework centralizes and maintains them, reducing:
- Duplicate file bloat across multiple mods
- Version conflicts when different mods bundle different versions
- Maintenance burden on modders
- Load-time overhead from redundant libraries

## What's Included

### Shared Libraries (Client & Server)

| Library | Author | Version | Purpose |
|---------|--------|---------|---------|
| **grafi-tt/lunajson** | grafi-tt | 1.2.3 | Fast JSON encoding/decoding |
| **rxi/json.lua** | rxi | v0.1.2 | JSON utilities |
| **kikito/middleclass** | kikito | v4.1.1 | Object-oriented programming support |
| **vrld/hump.signal** | vrld | latest | Event signaling and emitter system |
| **pz_utils/escape** | escape (maintained) | — | Event management, safe require, debouncing, logging, sandbox isolation |
| **pz_utils/konijima** | konijima (maintained) | — | General utility functions |

### Client Libraries

| Library | Author | Version | Purpose |
|---------|--------|---------|---------|
| **yonaba/30log** | Yonaba | 1.3.0 | Lightweight OOP library |
| **pkulchenko/serpent** | pkulchenko | 0.30 | Table serialization and introspection |
| **kikito/inspect.lua** | kikito | v3.1.3 | Debugging and table inspection utilities |

## Project Structure

```
pz_lua_commons/
├── common/
│   └── media/lua/
│       ├── shared/          # Server and client libraries
│       │   ├── pz_lua_commons/    # Shared library collection
│       │   ├── pz_utils/          # PZ-specific utilities
│       │   │   ├── escape/        # Event management, module loading, logging
│       │   │   └── konijima/      # General utilities
│       │   ├── pz_lua_commons_shared.lua
│       │   └── pz_utils_shared.lua
│       └── client/          # Client-only libraries
│           ├── pz_lua_commons/    # Client library collection
│           └── pz_lua_commons_client.lua
├── project.json             # PZ Studio configuration
├── package.json             # NPM scripts
└── workshop/                # Steam Workshop metadata
```

## Installation

### For Modders

1. Subscribe to **PZ Lua Commons** on the [Steam Workshop](https://steamcommunity.com/workshop/filedetails/?id=3334270098)
2. In your mod's `mod.info` or dependencies, reference it as a dependency
3. Load the library in your Lua code:

```lua
-- Shared code (server and client)
local pz_utils = require("pz_utils_shared")
local commons = require("pz_lua_commons_shared")

-- Client-only code
local commons_client = require("pz_lua_commons_client")
```

### For Developers

This project uses [**pzstudio**](https://github.com/escapepz/project-zomboid-studio) for seamless maintenance and builds. All development workflows follow pzstudio conventions.

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

4. Refer to [pzstudio documentation](https://github.com/escapepz/project-zomboid-studio) for detailed setup and advanced usage.

## Credits

This project maintains and adapts libraries authored by:
- **grafi-tt** - lunajson
- **pkulchenko** - serpent
- **kikito** - middleclass, inspect.lua
- **rxi** - json.lua, lume
- **Yonaba** - 30log
- **vrld** - hump
- **konijima** - General utilities

Original licenses and copyright notices are preserved with each library.

## License

MIT — See [LICENSE](LICENSE) for details.

---

**Maintained by**: escape  
**Last Updated**: February 2026
