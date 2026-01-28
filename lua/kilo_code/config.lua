--- Configuration module for KiloCode
---@class KiloCodeConfig
local M = {}

--- Default configuration
---@type table
local defaults = {
  -- Installation settings
  auto_install = true, -- Auto-install KiloCode if not found
  install_path = nil, -- Custom installation path (nil = default)

  -- Sidebar settings
  sidebar = {
    position = "right", -- "left" or "right"
    width = 80, -- Width in columns
    height = nil, -- Height in rows (nil = full height)
    auto_close = false, -- Auto-close on buffer switch
  },

  -- File watcher settings
  file_watcher = {
    enabled = true, -- Enable file change detection
    auto_reload = true, -- Auto-reload changed buffers
    notify_on_change = true, -- Show notification on external changes
    debounce_ms = 100, -- Debounce time for file events
  },

  -- KiloCode CLI settings
  kilo_code = {
    binary = "kilo-code", -- Binary name or path
    args = {}, -- Additional CLI arguments
    env = {}, -- Environment variables
  },
}

--- Current options
---@type table
M.options = {}

--- Setup configuration with user options
---@param opts table|nil User configuration options
---@return table Merged configuration
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
  return M.options
end

--- Get current configuration
---@return table Current configuration
function M.get()
  return M.options
end

--- Reset configuration to defaults (useful for testing)
function M.reset()
  M.options = vim.deepcopy(defaults)
end

-- Initialize with defaults
M.options = vim.deepcopy(defaults)

return M
