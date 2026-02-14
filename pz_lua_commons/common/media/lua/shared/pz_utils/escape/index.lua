---@class EscapeUtils
local escape = {}

escape.Debounce = require("pz_utils/escape/debounce")
escape.EventManager = require("pz_utils/escape/event_management")
escape.SafeLogger = require("pz_utils/escape/safe_logger")
escape.SafeRequire = require("pz_utils/escape/safe_require")
escape.SandboxVarsModule = require("pz_utils/escape/sandbox_vars")
escape.Utilities = require("pz_utils/escape/utilities")

return escape
