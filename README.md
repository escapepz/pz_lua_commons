# PZ Lua Commons

[![Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](https://github.com/escapepz/pz_lua_commons)
[![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-42-orange.svg)](https://projectzomboid.com/)
[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg0IDUuMzEzNTYgMTAuNjg1IDUuNjAwMSAxMS4wMzg0IDUuNjAwMUgxMy43NTg0QzE0LjExMTkgNS42MDAxIDE0LjM5ODQgNS4zMTM1NiAxNC4zOTg0IDQuOTYwMVYyLjI0MDFDMTQuMzk4NCAxLjg4NjY0IDE0LjExMTkgMS42MDAxIDEzLjc1ODQgMS42MDAxWiIgZmlsbD0iI2ZmZiIvPgo8cGF0aCBkPSJNNCAxMkwxMiA0TDQgMTJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/escapepz/pz_lua_commons)
[![DeepWiki](https://img.shields.io/badge/DeepWiki-_.svg?style=flat&color=6a0dad&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCI%2BPHBhdGggZD0iTTEyIDJMMiA3bDEwIDUgMTAtNS0xMC01eiIvPjxwYXRoIGQ9Ik0yIDE3bDEwIDUgMTAtNXBNMiAxMmwxMCA1IDEwLTUiLz48L3N2Zz4%3D&logoColor=ffffff)](https://deepwiki.com/escapepz/pz_lua_commons)

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
