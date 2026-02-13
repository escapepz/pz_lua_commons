-- Example 5: Combining multiple client utilities
-- Shows how to use multiple pz_lua_commons libraries together

local pz_commons = require("pz_lua_commons/client")
local inspect = pz_commons.kikito.inspectlua
local serpent = pz_commons.pkulchenko.serpent
local oon = pz_commons.yonaba.yon_30log

-- Create an Application class using 30log OOP
local Application = oon("Application")

function Application:initialize()
    self.running = true
    self.frame = 0
    self.player = {
        name = "Hero",
        level = 25,
        inventory = {"sword", "shield", "potion"}
    }
end

function Application:printState()
    print("Application state:")
    if inspect then
        print(inspect(self.player))
    end
end

function Application:update()
    self.frame = self.frame + 1
    self.player.level = self.player.level + 1
    self.player.inventory[4] = "crystal"
    print("Frame " .. self.frame .. " updated")
end

function Application:saveState()
    if serpent then
        local savedState = serpent.dump(self.player)
        print("State saved: " .. #savedState .. " bytes")
        return savedState
    end
end

-- Create and run application
print("=== Running Application ===")
local app = Application:new()
app:printState()
app:update()
app:saveState()
