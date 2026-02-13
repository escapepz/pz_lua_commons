-- Example 3: Using middleclass for object-oriented programming
-- middleclass provides class-based OOP with inheritance

local pz_commons = require("pz_lua_commons/shared")
local middleclass = pz_commons.kikito.middleclass

if not middleclass then
    print("middleclass not available")
    return
end

-- Define a base Character class
local Character = middleclass('Character')

function Character:initialize(name, health)
    self.name = name
    self.health = health
    self.maxHealth = health
end

function Character:takeDamage(amount)
    self.health = math.max(0, self.health - amount)
    print(self.name .. " takes " .. amount .. " damage! Health: " .. self.health)
end

function Character:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
    print(self.name .. " heals " .. amount .. " HP! Health: " .. self.health)
end

function Character:isDead()
    return self.health <= 0
end

-- Define a Warrior class that inherits from Character
local Warrior = middleclass('Warrior', Character)

function Warrior:initialize(name, health, armor)
    Character.initialize(self, name, health)
    self.armor = armor
end

function Warrior:takeDamage(amount)
    local mitigated = math.floor(amount * (1 - self.armor / 100))
    Character.takeDamage(self, mitigated)
end

function Warrior:powerAttack(target)
    print(self.name .. " performs a power attack on " .. target.name .. "!")
    target:takeDamage(50)
end

-- Create instances and use them
local player = Warrior("Hero", 100, 20)
local enemy = Character("Zombie", 30)

print("=== Battle Start ===")
player:powerAttack(enemy)
enemy:takeDamage(10)
player:takeDamage(25)
player:heal(20)
print("Player dead? " .. tostring(player:isDead()))
print("Enemy dead? " .. tostring(enemy:isDead()))
