---@author eScape
-- https://github.com/escapepz
---@class ESC_Debounce
local Debounce = {}

---@type table<string, {timer: number, delay: number, accumulator: table, callback: function}>
local debounceInstances = {}

local pairs = pairs

--- Create or get a debounced function
--- Delays callback execution until a period of inactivity
---
--- The debounce mechanism:
--- 1. First call starts a timer (delay ticks)
--- 2. Repeated calls reset timer and accumulate arguments
--- 3. After delay expires, executes callback once with all accumulated arguments
---
---@param id string -- Unique identifier for this debounce instance
---@param delay number -- Delay in ticks before callback executes
---@param callback function -- Function to call after delay (receives accumulated arguments table)
---@param ... any -- Additional arguments to accumulate
---@return boolean -- Returns true if instance was created/reset
function Debounce.Call(id, delay, callback, ...)
    if not debounceInstances[id] then
        debounceInstances[id] = {
            timer = 0,
            delay = delay,
            accumulator = {},
            callback = callback,
        }
    end

    local instance = debounceInstances[id]
    instance.timer = 0 -- Reset timer on each call
    instance.delay = delay
    instance.callback = callback

    -- Accumulate all arguments
    instance.accumulator = { ... }

    return true
end

--- Update all active debounce instances (call this every game tick)
--- Increments timers and executes callbacks when delay expires
---
---@return boolean -- Returns true if any debounce was executed
function Debounce.Update()
    local executed = false

    for id, instance in pairs(debounceInstances) do
        instance.timer = instance.timer + 1

        if instance.timer >= instance.delay then
            ---@diagnostic disable-next-line: unnecessary-if
            -- Execute callback with accumulated arguments
            if instance.callback then
                instance.callback(instance.accumulator)
            end

            -- Clean up instance
            debounceInstances[id] = nil
            executed = true
        end
    end

    return executed
end

--- Cancel a pending debounce
---
---@param id string -- Unique identifier of the debounce instance to cancel
---@return boolean -- Returns true if instance was cancelled
function Debounce.Cancel(id)
    ---@diagnostic disable-next-line: unnecessary-if
    if debounceInstances[id] then
        debounceInstances[id] = nil
        return true
    end
    return false
end

--- Cancel all pending debounces
---
---@return number -- Returns count of cancelled instances
function Debounce.CancelAll()
    local count = 0
    for id in pairs(debounceInstances) do
        debounceInstances[id] = nil
        count = count + 1
    end
    return count
end

--- Check if a debounce instance is active
---
---@param id string -- Unique identifier of the debounce instance
---@return boolean -- Returns true if instance is active and waiting
function Debounce.IsActive(id)
    return debounceInstances[id] ~= nil
end

return Debounce
