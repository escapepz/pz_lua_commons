-- Example 11: Deep dive into yon_30log for OOP
-- 30log is a lightweight object-oriented programming library (30 lines)
-- It provides class creation, inheritance, mixins, and instance management

local pz_commons = require("pz_lua_commons/client")
local log = pz_commons.yonaba.yon_30log

if not log then
    print("yon_30log not available")
    return
end

print("=== 30log OOP System ===")

-- 1. Creating a simple class
local Animal = log("Animal")

function Animal:initialize(name, species)
    self.name = name
    self.species = species
    self.alive = true
end

function Animal:speak()
    print(self.name .. " (" .. self.species .. ") makes a sound")
end

function Animal:die()
    self.alive = false
    print(self.name .. " died")
end

-- 2. Create subclasses through inheritance
local Dog = Animal:extend("Dog")

function Dog:initialize(name, breed)
    Animal.initialize(self, name, "Canine")
    self.breed = breed
end

function Dog:speak()
    print(self.name .. " barks! Woof!")
end

function Dog:fetch()
    print(self.name .. " fetches the ball")
end

-- 3. Another subclass
local Cat = Animal:extend("Cat")

function Cat:initialize(name, color)
    Animal.initialize(self, name, "Feline")
    self.color = color
end

function Cat:speak()
    print(self.name .. " meows")
end

function Cat:scratch()
    print(self.name .. " scratches the furniture")
end

print("\n=== Creating Instances ===")
local dog = Dog:new("Buddy", "Golden Retriever")
local cat = Cat:new("Whiskers", "Orange")
local generic = Animal:new("Creature", "Unknown")

print("\n=== Testing Methods ===")
dog:speak()
dog:fetch()

cat:speak()
cat:scratch()

generic:speak()

print("\n=== Inheritance Chain ===")
print("dog is instance of Dog? " .. tostring(dog:instanceOf(Dog)))
print("dog is instance of Animal? " .. tostring(dog:instanceOf(Animal)))
print("cat is instance of Cat? " .. tostring(cat:instanceOf(Cat)))
print("cat is instance of Animal? " .. tostring(cat:instanceOf(Animal)))
print("generic is instance of Animal? " .. tostring(generic:instanceOf(Animal)))
print("generic is instance of Dog? " .. tostring(generic:instanceOf(Dog)))

print("\n=== Getting All Instances ===")
local allAnimals = Animal:instances()
print("Total Animal instances: " .. #allAnimals)

local allDogs = Dog:instances()
print("Total Dog instances: " .. #allDogs)

print("\n=== Checking Subclass Relationships ===")
print("Dog is subclass of Animal? " .. tostring(Dog:subclassOf(Animal)))
print("Cat is subclass of Animal? " .. tostring(Cat:subclassOf(Animal)))
print("Animal is subclass of Dog? " .. tostring(Animal:subclassOf(Dog)))

print("\n=== Getting All Subclasses ===")
local subclasses = Animal:subclasses()
print("Subclasses of Animal: " .. #subclasses)
for i, subclass in ipairs(subclasses) do
    print("  " .. i .. ": " .. subclass.name)
end

print("\n=== Type Checking ===")
print("log.isClass(Animal)? " .. tostring(log.isClass(Animal)))
print("log.isClass(dog)? " .. tostring(log.isClass(dog)))
print("log.isInstance(dog)? " .. tostring(log.isInstance(dog)))
print("log.isInstance(Dog)? " .. tostring(log.isInstance(Dog)))
