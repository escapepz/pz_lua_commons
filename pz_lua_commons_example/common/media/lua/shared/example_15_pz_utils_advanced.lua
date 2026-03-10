-- Example 15: pz_utils - Advanced Patterns and Recipes
-- Demonstrates practical patterns for real-world mod development

local pz_utils = require("pz_utils_shared")
local escape = pz_utils.escape
local konijima = pz_utils.konijima.Utilities
local logger = escape.SafeLogger.new("AdvancedPatterns")

print("\n=== PZ Utils Advanced Patterns ===\n")

-- ============================================================================
-- PATTERN 1: DEBOUNCED EVENT SYSTEM
-- ============================================================================

print("--- Pattern 1: Debounced Event System ---")

-- Create an event that processes accumulated changes at intervals
local function createDebouncedEventProcessor(eventName, debounceId, delay)
    local accumulator = {}

    -- Create the base event
    local event = escape.EventManager.createEvent(eventName)

    -- Add a processor that accumulates and debounces
    local function addEvent(eventType, data)
        table.insert(accumulator, { type = eventType, data = data, time = os.time() })

        -- Debounce the processing
        escape.Debounce.Call(debounceId, delay, function(args)
            logger:log(
                "Processing " .. #accumulator .. " accumulated " .. eventName .. " events",
                "INFO"
            )

            -- Fire the actual event with accumulated data
            event:Trigger(accumulator)

            -- Clear accumulator
            accumulator = {}
        end)
    end

    return event, addEvent
end

-- Usage example
local playerStatsEvent, addPlayerStatChange =
    createDebouncedEventProcessor("PlayerStats", "stats_debounce", 10)

-- Listen to the debounced event
playerStatsEvent:Add(function(changes)
    logger:log("Processing " .. #changes .. " stat changes in batch", "INFO")
    for _, change in ipairs(changes) do
        logger:log("  - " .. change.type .. ": " .. tostring(change.data), "DEBUG")
    end
end)

-- Simulate rapid stat changes
addPlayerStatChange("health", 95)
addPlayerStatChange("hunger", 75)
addPlayerStatChange("fatigue", 60)

-- ============================================================================
-- PATTERN 2: COMMAND DISPATCHER WITH EVENT MANAGER
-- ============================================================================

print("\n--- Pattern 2: Command Dispatcher ---")

-- Create a command dispatcher that routes commands to handlers
local CommandDispatcher = {}

function CommandDispatcher.new()
    local dispatcher = {
        handlers = {},
        eventManager = escape.EventManager,
    }

    function dispatcher:register(commandName, handler)
        logger:log("Registering command: " .. commandName, "DEBUG")
        self.handlers[commandName] = handler

        -- Create event for the command
        self.eventManager.createEvent("cmd_" .. commandName)
    end

    function dispatcher:execute(commandName, ...)
        if not self.handlers[commandName] then
            logger:log("Unknown command: " .. commandName, "WARN")
            return false
        end

        logger:log("Executing command: " .. commandName, "DEBUG")
        local success, result = pcall(self.handlers[commandName], ...)

        if success then
            self.eventManager.trigger("cmd_" .. commandName, result)
            return true
        else
            logger:log("Command failed: " .. commandName .. " - " .. tostring(result), "ERROR")
            return false
        end
    end

    return dispatcher
end

-- Usage
local dispatcher = CommandDispatcher.new()

dispatcher:register("heal", function(playerName, amount)
    logger:log("Healing " .. playerName .. " for " .. amount, "INFO")
    return { status = "success", healed = amount }
end)

dispatcher:register("kill", function(playerName)
    logger:log("Removing " .. playerName, "WARN")
    return { status = "eliminated" }
end)

-- Listen to command events
escape.EventManager.on("cmd_heal", function(result)
    logger:log("Heal result: " .. result.status, "INFO")
end)

-- Execute commands
dispatcher:execute("heal", "Player1", 50)
dispatcher:execute("kill", "Zombie42")

-- ============================================================================
-- PATTERN 3: STATE MACHINE WITH EVENTS
-- ============================================================================

print("\n--- Pattern 3: State Machine ---")

local StateMachine = {}

function StateMachine.new(initialState)
    local sm = {
        state = initialState or "idle",
        transitions = {},
        onStateChange = escape.EventManager.createEvent("StateChange"),
    }

    function sm:defineTransition(from, to, condition)
        if not self.transitions[from] then
            self.transitions[from] = {}
        end
        table.insert(self.transitions[from], {
            to = to,
            condition = condition or function()
                return true
            end,
        })
    end

    function sm:update()
        if not self.transitions[self.state] then
            return false
        end

        for _, transition in ipairs(self.transitions[self.state]) do
            if transition.condition() then
                local oldState = self.state
                self.state = transition.to
                logger:log("State transition: " .. oldState .. " -> " .. self.state, "DEBUG")
                self.onStateChange:Trigger(oldState, self.state)
                return true
            end
        end

        return false
    end

    return sm
end

-- Usage
local playerState = StateMachine.new("alive")

playerState:defineTransition("alive", "injured", function()
    return math.random(1, 10) == 1 -- 10% chance
end)
playerState:defineTransition("injured", "dead", function()
    return math.random(1, 5) == 1 -- 20% chance
end)
playerState:defineTransition("dead", "alive", function()
    return false -- Can't resurrect
end)

-- Listen to state changes
playerState.onStateChange:Add(function(from, to)
    logger:log("Player state changed: " .. from .. " => " .. to, "INFO")
end)

-- Simulate a few state checks
for i = 1, 3 do
    playerState:update()
end

-- ============================================================================
-- PATTERN 4: CACHED PROPERTY WITH INVALIDATION
-- ============================================================================

print("\n--- Pattern 4: Cached Property with Invalidation ---")

local CachedProperty = {}

function CachedProperty.new(getter, ttl)
    local prop = {
        getter = getter,
        ttl = ttl or 60, -- Cache for 60 ticks by default
        value = nil,
        age = 0,
        invalidateEvent = escape.EventManager.createEvent("PropertyInvalidated"),
    }

    function prop:get()
        if self.value == nil or self.age >= self.ttl then
            logger:log("Recomputing cached property", "DEBUG")
            self.value = self.getter()
            self.age = 0
        else
            self.age = self.age + 1
        end
        return self.value
    end

    function prop:invalidate()
        logger:log("Invalidating cached property", "DEBUG")
        self.value = nil
        self.age = 0
        self.invalidateEvent:Trigger()
    end

    return prop
end

-- Usage
local playerHealthCache = CachedProperty.new(function()
    logger:log("Fetching player health from server", "INFO")
    return 100
end, 20)

logger:log("Health: " .. playerHealthCache:get(), "INFO")
logger:log("Health (cached): " .. playerHealthCache:get(), "INFO")

playerHealthCache:invalidate()
logger:log("Health (after invalidation): " .. playerHealthCache:get(), "INFO")

-- ============================================================================
-- PATTERN 5: DEPENDENCY INJECTION CONTAINER
-- ============================================================================

print("\n--- Pattern 5: Dependency Injection ---")

local Container = {}

function Container.new()
    local container = {
        services = {},
        singletons = {},
    }

    function container:register(name, factory, isSingleton)
        logger:log("Registering service: " .. name, "DEBUG")
        self.services[name] = {
            factory = factory,
            singleton = isSingleton or false,
        }
    end

    function container:get(name)
        local service = self.services[name]
        if not service then
            logger:log("Service not found: " .. name, "ERROR")
            return nil
        end

        -- Return cached singleton or create new instance
        if service.singleton then
            if not self.singletons[name] then
                self.singletons[name] = service.factory(self)
            end
            return self.singletons[name]
        else
            return service.factory(self)
        end
    end

    return container
end

-- Usage
local ioc = Container.new()

-- Register services
ioc:register("logger", function()
    return escape.SafeLogger
end, true) -- Singleton

ioc:register("eventManager", function()
    return escape.EventManager
end, true) -- Singleton

ioc:register("debouncer", function()
    return escape.Debounce
end, true) -- Singleton

-- Use services
local containerLogger = ioc:get("logger")
local loggerInstance = containerLogger.new("ContainerLogger")
loggerInstance:log("Service resolved from container", "INFO")

-- ============================================================================
-- PATTERN 6: VALIDATION WRAPPER WITH SAFE EXECUTION
-- ============================================================================

print("\n--- Pattern 6: Validated Execution ---")

local ValidatedCommand = {}
ValidatedCommand.__index = ValidatedCommand

function ValidatedCommand.new(name)
    local self = setmetatable({
        name = name,
        validators = {},
        onSuccess = escape.EventManager.createEvent("cmd_" .. name .. "_success"),
        onFailure = escape.EventManager.createEvent("cmd_" .. name .. "_failure"),
    }, ValidatedCommand)
    return self
end

function ValidatedCommand:addValidator(name, fn)
    table.insert(self.validators, { name = name, fn = fn })
    return self
end

function ValidatedCommand:execute(context)
    -- Run all validators
    for _, validator in ipairs(self.validators) do
        local valid, error = validator.fn(context)
        if not valid then
            logger:log("Validation failed: " .. validator.name .. " - " .. tostring(error), "WARN")
            self.onFailure:Trigger({ validator = validator.name, error = error })
            return false
        end
    end

    logger:log("All validations passed for " .. self.name, "DEBUG")
    self.onSuccess:Trigger(context)
    return true
end

-- Usage
local teleportCmd = ValidatedCommand.new("teleport")

teleportCmd:addValidator("admin_check", function(ctx)
    if not konijima.IsClientAdmin() then
        return false, "Not admin"
    end
    return true
end)

teleportCmd:addValidator("coords_check", function(ctx)
    if not ctx.x or not ctx.y or not ctx.z then
        return false, "Missing coordinates"
    end
    return true
end)

teleportCmd.onSuccess:Add(function(ctx)
    logger:log("Teleporting to " .. ctx.x .. ", " .. ctx.y .. ", " .. ctx.z, "INFO")
end)

teleportCmd.onFailure:Add(function(err)
    logger:log("Teleport failed: " .. tostring(err), "ERROR")
end)

-- Execute with valid context
teleportCmd:execute({ x = 100, y = 200, z = 0 })

-- ============================================================================
-- PATTERN 7: ASYNC-LIKE OPERATIONS WITH DEBOUNCE
-- ============================================================================

print("\n--- Pattern 7: Deferred Processing ---")

local DeferredOperation = {}

function DeferredOperation.new(id, delayTicks)
    return {
        id = id,
        delay = delayTicks,
        _queue = {},
        onComplete = escape.EventManager.createEvent("deferred_" .. id .. "_complete"),

        queue = function(self, operation)
            table.insert(self._queue, operation)

            -- Debounce the execution
            escape.Debounce.Call(self.id, self.delay, function(args)
                logger:log("Processing " .. #self._queue .. " deferred operations", "INFO")

                for _, op in ipairs(self._queue) do
                    local success, result = pcall(op)
                    self.onComplete:Trigger({ success = success, result = result })
                end

                self._queue = {}
            end)
        end,
    }
end

-- Usage
local saveOp = DeferredOperation.new("game_save", 30)

saveOp.onComplete:Add(function(result)
    if result.success then
        logger:log("Operation completed successfully", "INFO")
    else
        logger:log("Operation failed", "ERROR")
    end
end)

-- Queue multiple operations
saveOp:queue(function()
    logger:log("Saving player data...", "DEBUG")
end)

saveOp:queue(function()
    logger:log("Saving world data...", "DEBUG")
end)

logger:log("Queued 2 deferred operations", "INFO")

print("\n=== All advanced patterns demonstrated ===\n")
