---@author eScape
-- https://github.com/escapepz
-- media\lua\server\ -- utils\event_management.lua
-- Centralized Custom Event Manager
-- Manages custom events and controls when built-in periodic events are triggered

---@class ESC_EventManager
local EventManager = {}
EventManager.events = {}

-- Cache hot path functions to avoid repeated table lookups
local _pcall = pcall
local _ipairs = ipairs
local _table_insert = table.insert
local _table_remove = table.remove
local _tostring = tostring

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

		---Add a listener callback to this event
		---@param self table
		---@param callback function
		---@return table self
		Add = function(self, callback)
			if type(callback) ~= "function" then
				error("EventManager: callback must be a function for event '" .. self.name .. "'")
			end
			_table_insert(self.listeners, callback)
			return self
		end,

		---Remove a listener callback from this event
		---@param self table
		---@param callback function
		---@return table self
		Remove = function(self, callback)
			for i, listener in _ipairs(self.listeners) do
				if listener == callback then
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

			for _, callback in _ipairs(self.listeners) do
				local success, err = _pcall(callback, ...)
				if not success then
					print("ERROR in event '" .. self.name .. "': " .. _tostring(err))
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
function EventManager.on(eventName, callback)
	local event = EventManager.getOrCreateEvent(eventName)
	return event:Add(callback)
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
	for name, event in pairs(EventManager.events) do
		_table_insert(info, {
			name = name,
			enabled = event.enabled,
			listeners = event:GetListenerCount(),
		})
	end
	return info
end

return EventManager
