-- Example 4: Using yon_30log for OOP (Object-Oriented Programming)
-- 30log is a lightweight OOP library (30 lines) for class-based programming

local pz_commons = require("pz_lua_commons/client")
local log = pz_commons.yonaba.yon_30log

if not log then
    print("yon_30log not available")
    return
end

-- Create a base Entity class
local Entity = log("Entity")

function Entity:initialize(name, health)
    self.name = name
    self.health = health
    self.maxHealth = health
end

function Entity:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
    print(self.name .. " takes " .. amount .. " damage! Health: " .. self.health)
end

function Entity:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
    print(self.name .. " heals " .. amount .. " HP! Health: " .. self.health)
end

-- Create an NPC class that extends Entity
local NPC = Entity:extend("NPC")

function NPC:initialize(name, health, faction)
    Entity.initialize(self, name, health)
    self.faction = faction
end

function NPC:greet()
    print(self.name .. " (Faction: " .. self.faction .. ") greets you")
end

-- Create Player class that extends Entity
local Player = Entity:extend("Player")

function Player:initialize(name, health, level)
    Entity.initialize(self, name, health)
    self.level = level
    self.experience = 0
end

function Player:gainExperience(amount)
    self.experience = self.experience + amount
    if self.experience >= 100 then
        self.level = self.level + 1
        self.experience = 0
        print(self.name .. " reached level " .. self.level .. "!")
    end
end

-- Create instances
print("=== Class Creation ===")
local player = Player:new("Hero", 100, 1)
local npc = NPC:new("Guard", 50, "Town Guard")

print("\n=== Testing Entity Methods ===")
player:takeDamage(20)
npc:greet()
player:heal(10)

print("\n=== Testing Player Progression ===")
player:gainExperience(60)
player:gainExperience(50)

print("\n=== Checking Inheritance ===")
print("Is player an instance of Player? " .. tostring(player:instanceOf(Player)))
print("Is player an instance of Entity? " .. tostring(player:instanceOf(Entity)))
print("Is npc an instance of NPC? " .. tostring(npc:instanceOf(NPC)))
print("Is npc an instance of Entity? " .. tostring(npc:instanceOf(Entity)))
