-- Example 13: pz_utils - Escape Utilities (Debounce, EventManager, SafeLogger, SafeRequire, Utilities)
-- Demonstrates the escape utilities library for reliable mod development

-- Load pz_utils
local pz_utils = require("pz_lua_commons/shared")
local escape = pz_utils[1] or pz_utils.escape

-- ============================================================================
-- 1. SAFELOGGER EXAMPLE - Defensive Logging
-- ============================================================================

print("\n--- SafeLogger Examples ---")

-- Initialize SafeLogger with a module name
escape.SafeLogger.init("MyAwesomeMod")

-- Log at different levels (TRACE=10, DEBUG=20, INFO=30, WARN=40, ERROR=50, FATAL=60)
escape.SafeLogger.log("This is a trace message", 10)       -- TRACE
escape.SafeLogger.log("Debug information", 20)             -- DEBUG
escape.SafeLogger.log("Informational message", 30)         -- INFO
escape.SafeLogger.log("Warning: something unusual", 40)    -- WARN
escape.SafeLogger.log("An error occurred", 50)             -- ERROR
escape.SafeLogger.log("Critical failure", 60)              -- FATAL

-- Using string log levels (case insensitive)
escape.SafeLogger.log("Another debug message", "DEBUG")
escape.SafeLogger.log("Another info message", "info")

-- ============================================================================
-- 2. DEBOUNCE EXAMPLE - Rate Limiting Callbacks
-- ============================================================================

print("\n--- Debounce Examples ---")

-- Create a debounced function that will only execute after 5 ticks of inactivity
local function onPlayerMove(args)
    escape.SafeLogger.log("Player moved! Arguments: " .. tostring(#args) .. " items", "INFO")
end

-- Simulate rapid calls to the same debounced function
for i = 1, 10 do
    escape.Debounce.Call("player_move", 5, onPlayerMove, "x", "y", "z")
    escape.SafeLogger.log("Debounce call #" .. i .. " - move request queued", 20)
end

-- Check if debounce is active
local isActive = escape.Debounce.IsActive("player_move")
escape.SafeLogger.log("Debounce 'player_move' is active: " .. tostring(isActive), "INFO")

-- In a game loop, you would call Update every tick to process debounces
-- escape.Debounce.Update()

-- Cancel a specific debounce
escape.Debounce.Cancel("player_move")
escape.SafeLogger.log("Cancelled debounce 'player_move'", "INFO")

-- ============================================================================
-- 3. EVENTMANAGER EXAMPLE - Custom Event System
-- ============================================================================

print("\n--- EventManager Examples ---")

-- Create or get an event
local playerDamageEvent = escape.EventManager.createEvent("OnPlayerDamage")
escape.SafeLogger.log("Created event: OnPlayerDamage", "INFO")

-- Add multiple listeners to the event
local function onDamage1(damage, source)
    escape.SafeLogger.log("Listener 1: Player took " .. damage .. " damage from " .. source, "INFO")
end

local function onDamage2(damage, source)
    escape.SafeLogger.log("Listener 2: ALERT! Damage detected: " .. damage, "WARN")
end

playerDamageEvent:Add(onDamage1)
playerDamageEvent:Add(onDamage2)

escape.SafeLogger.log("Added 2 listeners to OnPlayerDamage event", "INFO")
escape.SafeLogger.log("Event has " .. playerDamageEvent:GetListenerCount() .. " listeners", "INFO")

-- Trigger the event
escape.SafeLogger.log("Triggering OnPlayerDamage event...", "INFO")
playerDamageEvent:Trigger(25, "Zombie")

-- Test shorthand API
escape.EventManager.on("OnZombieSpawn", function(x, y, z)
    escape.SafeLogger.log("Zombie spawned at: " .. x .. ", " .. y .. ", " .. z, "DEBUG")
end)

escape.EventManager.trigger("OnZombieSpawn", 100, 200, 0)

-- Disable an event
playerDamageEvent:SetEnabled(false)
escape.SafeLogger.log("Disabled OnPlayerDamage event", "INFO")

-- Try triggering disabled event (won't trigger listeners)
playerDamageEvent:Trigger(50, "Hunter")
escape.SafeLogger.log("Event triggered but disabled - no listeners executed", "DEBUG")

-- Get event info
local eventInfo = escape.EventManager.getEventInfo("OnPlayerDamage")
escape.SafeLogger.log("OnPlayerDamage info: enabled=" .. tostring(eventInfo.enabled) .. 
                      ", listeners=" .. eventInfo.listeners, "INFO")

-- ============================================================================
-- 4. SAFEEREQUIRE EXAMPLE - Safe Module Loading
-- ============================================================================

print("\n--- SafeRequire Examples ---")

-- SafeRequire is used internally but you can also call it directly
-- It safely loads modules with error handling
local validModule = escape.SafeRequire("pz_utils/escape/utilities", "TestModule")
if validModule then
    escape.SafeLogger.log("Successfully loaded utilities module", "INFO")
else
    escape.SafeLogger.log("Failed to load utilities module", "ERROR")
end

-- Attempting to load a non-existent module returns nil
local invalidModule = escape.SafeRequire("some/invalid/path", "InvalidModule")
escape.SafeLogger.log("Invalid module result: " .. tostring(invalidModule), "DEBUG")

-- ============================================================================
-- 5. UTILITIES EXAMPLE - Helper Functions
-- ============================================================================

print("\n--- Utilities Examples ---")

-- Get the real-world timestamp (in seconds)
local timestamp = escape.Utilities.GetIRLTimestamp()
escape.SafeLogger.log("Current IRL timestamp: " .. timestamp, "INFO")

-- This can be used to track time-based events
local startTime = escape.Utilities.GetIRLTimestamp()
escape.SafeLogger.log("Started timer at: " .. startTime, "DEBUG")

-- ============================================================================
-- 6. COMBINED WORKFLOW EXAMPLE
-- ============================================================================

print("\n--- Combined Workflow Example ---")

-- Setup event-driven damage handling with debounced processing
local damageQueue = {}

escape.EventManager.on("RawDamage", function(playerName, damage)
    table.insert(damageQueue, {player = playerName, damage = damage, time = os.time()})
    
    -- Debounce the processing of accumulated damage
    escape.Debounce.Call("process_damage", 3, function(args)
        escape.SafeLogger.log("Processing " .. #damageQueue .. " damage events", "INFO")
        damageQueue = {}
    end)
end)

-- Simulate damage events
for i = 1, 5 do
    escape.EventManager.trigger("RawDamage", "Player" .. i, 10 + i)
end

escape.SafeLogger.log("Queued 5 damage events - will process after 3 ticks of inactivity", "INFO")

-- ============================================================================
-- 7. SAFE REMOVAL EXAMPLE - Clean Up Event Listeners
-- ============================================================================

print("\n--- Event Listener Management Example ---")

local function myListener(data)
    escape.SafeLogger.log("MyListener called with: " .. tostring(data), "DEBUG")
end

local cleanupEvent = escape.EventManager.getOrCreateEvent("MyCleanup")
cleanupEvent:Add(myListener)

escape.SafeLogger.log("Added listener, count: " .. cleanupEvent:GetListenerCount(), "INFO")

-- Remove the listener
cleanupEvent:Remove(myListener)
escape.SafeLogger.log("Removed listener, count: " .. cleanupEvent:GetListenerCount(), "INFO")

print("\n--- All pz_utils examples completed ---")
