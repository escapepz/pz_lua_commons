---@author eScape
-- https://github.com/escapepz
-- pz_lua_commons\common\media\lua\shared\pz_utils\escape\event_management.lua
-- Centralized Custom Event Manager
-- Manages custom events and controls when built-in periodic events are triggered

---@class ESC_EventManager
local EventManager = {}
EventManager.events = {}

-- Cache hot path functions to avoid repeated table lookups
local _pcall = pcall
local _pairs = pairs
local _ipairs = ipairs
local _print = print
local _type, _error = type, error
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort
local _tostring = tostring
local _math_floor = math.floor

---Create a new custom event
---@param name string Event name
---@return table event
function EventManager.createEvent(name)
	if EventManager.events[name] then
		return EventManager.events[name]
	end

	local event = {
		name = name,
		listeners = {},
		enabled = true,
		_executing = false,
		maxListeners = nil,
		_pruneCallback = nil,

		---Add a listener with binary insertion (maintains sort by priority)
		---@param self table
		---@param callback function
		---@param priority number Optional priority (default 0, higher executes first)
		---@return table self
		Add = function(self, callback, priority)
			priority = priority or 0

			if _type(callback) ~= "function" then
				_error("EventManager: callback must be a function for event '" .. self.name .. "'")
			end

			-- Binary search for insertion point (higher priority first)
			local left, right = 1, #self.listeners
			local insertPos = #self.listeners + 1

			while left <= right do
				local mid = _math_floor((left + right) / 2)
				if self.listeners[mid].p < priority then
					insertPos = mid
					right = mid - 1
				else
					left = mid + 1
				end
			end

			_table_insert(self.listeners, insertPos, { f = callback, p = priority })

			self:_prune()
			return self
		end,

		---Add a listener with simple insertion (full sort)
		---@param self table
		---@param callback function
		---@param priority number Optional priority (default 0, higher executes first)
		---@return table self
		AddSimple = function(self, callback, priority)
			priority = priority or 0

			if _type(callback) ~= "function" then
				_error("EventManager: callback must be a function for event '" .. self.name .. "'")
			end

			_table_insert(self.listeners, { f = callback, p = priority })

			-- Sort all listeners by priority (higher first)
			_table_sort(self.listeners, function(a, b)
				return a.p > b.p
			end)

			self:_prune()
			return self
		end,

		---Remove a listener callback from this event
		---@param self table
		---@param callback function
		---@return table self
		Remove = function(self, callback)
			for i, listener in _ipairs(self.listeners) do
				if listener.f == callback then
					_table_remove(self.listeners, i)
					break
				end
			end
			return self
		end,

		---Trigger the event, calling all registered listeners
		---@param self table
		---@vararg any Additional arguments to pass to listeners
		Trigger = function(self, ...)
			if not self.enabled then
				return
			end

			self._executing = true

			for _, listener in _ipairs(self.listeners) do
				local success, err = _pcall(listener.f, ...)
				if not success then
					_print("ERROR in event '" .. self.name .. "': " .. _tostring(err))
				end
			end

			self._executing = false
		end,

		---Enable or disable the event
		---@param self table
		---@param enabled boolean
		---@return table self
		SetEnabled = function(self, enabled)
			self.enabled = enabled
			return self
		end,

		---Check if event is enabled
		---@param self table
		---@return boolean
		IsEnabled = function(self)
			return self.enabled
		end,

		---Get listener count
		---@param self table
		---@return number
		GetListenerCount = function(self)
			return #self.listeners
		end,

		---Check if event is currently executing
		---@param self table
		---@return boolean
		IsExecuting = function(self)
			return self._executing
		end,

		---Set maximum listener count for this event (enables pruning)
		---@param self table
		---@param count number Maximum listeners allowed
		---@return table self
		SetMaxListeners = function(self, count)
			self.maxListeners = count
			self:_prune()
			return self
		end,

		---Set custom pruning callback (called when a listener is removed due to maxListeners)
		---@param self table
		---@param callback function Called with (removed_listener_obj, event)
		---@return table self
		SetPruneCallback = function(self, callback)
			self._pruneCallback = callback
			return self
		end,

		---Internal: prune listeners if maxListeners exceeded
		---@param self table
		_prune = function(self)
			if not self.maxListeners or #self.listeners <= self.maxListeners then
				return
			end

			local removed = _table_remove(self.listeners)

			-- Call user callback if set
			if self._pruneCallback then
				self._pruneCallback(removed, self)
			end
		end,
	}

	EventManager.events[name] = event
	return event
end

---Get an existing event or create a new one
---@param name string Event name
---@return table event
function EventManager.getOrCreateEvent(name)
	return EventManager.events[name] or EventManager.createEvent(name)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

---Initialize the event manager
function EventManager.initialize()
	-- Event manager is ready
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

---Get or create an event and add a listener (shorthand)
---@param eventName string Event name
---@param callback function Listener function
---@param priority number Optional priority (default 0, higher executes first)
function EventManager.on(eventName, callback, priority)
	local event = EventManager.getOrCreateEvent(eventName)
	return event:Add(callback, priority)
end

---Manually trigger an event
---@param eventName string Event name
---@vararg any Arguments to pass to listeners
function EventManager.trigger(eventName, ...)
	local event = EventManager.events[eventName]
	---@diagnostic disable-next-line: unnecessary-if
	if event then
		event:Trigger(...)
	end
end

---Remove a listener from an event (shorthand)
---@param eventName string Event name
---@param callback function Listener function
function EventManager.off(eventName, callback)
	local event = EventManager.events[eventName]
	---@diagnostic disable-next-line: unnecessary-if
	if event then
		event:Remove(callback)
	end
end

---Set maximum listener count for an event (shorthand)
---@param eventName string Event name
---@param count number Maximum listeners allowed
function EventManager.setMaxListeners(eventName, count)
	local event = EventManager.getOrCreateEvent(eventName)
	return event:SetMaxListeners(count)
end

---Get event info for debugging
---@param eventName string Event name
---@return table|nil
function EventManager.getEventInfo(eventName)
	local event = EventManager.events[eventName]
	---@diagnostic disable-next-line: unnecessary-if
	if event then
		return {
			name = event.name,
			enabled = event.enabled,
			listeners = event:GetListenerCount(),
		}
	end
	return nil
end

---Get all events info
---@return table
function EventManager.getAllEventsInfo()
	local info = {}
	for name, event in _pairs(EventManager.events) do
		_table_insert(info, {
			name = name,
			enabled = event.enabled,
			listeners = event:GetListenerCount(),
		})
	end
	return info
end

return EventManager
