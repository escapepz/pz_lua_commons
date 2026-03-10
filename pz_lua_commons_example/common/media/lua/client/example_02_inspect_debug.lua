-- Example 2: Using inspectlua for debugging
-- inspectlua provides detailed inspection of Lua objects/tables

local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua

if not inspect then
    print("inspectlua not available")
    return
end

-- Example table
local testTable = {
    name = "TestObject",
    value = 42,
    nested = {
        x = 10,
        y = 20,
    },
    list = { 1, 2, 3, 4, 5 },
}

-- Use inspect to pretty-print the table
print("Inspecting table:")
print(inspect(testTable))

-- Inspect with depth option
print("\nInspecting with limited depth:")
print(inspect(testTable, { depth = 1 }))
