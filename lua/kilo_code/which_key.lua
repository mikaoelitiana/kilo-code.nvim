--- Which-key integration module for KiloCode
---@class KiloCodeWhichKey
local M = {}

local config = require("kilo_code.config")

--- Check if which-key is available
---@return boolean
function M.is_available()
  local ok, _ = pcall(require, "which-key")
  return ok
end

--- Register keymaps with which-key
function M.register()
  if not M.is_available() then
    return
  end

  local wk = require("which-key")
  local cfg = config.get()

  if not cfg.which_key.enabled then
    return
  end

  local prefix = cfg.which_key.prefix
  local icons = cfg.which_key.icons

  -- Define the keymap group
  local mappings = {
    { prefix, group = "KiloCode", icon = icons.group },
    { prefix .. "o", "<cmd>KiloCodeOpen<cr>", desc = "Open sidebar", icon = icons.open },
    { prefix .. "c", "<cmd>KiloCodeClose<cr>", desc = "Close sidebar", icon = icons.close },
    { prefix .. "t", "<cmd>KiloCodeToggle<cr>", desc = "Toggle sidebar", icon = icons.toggle },
    { prefix .. "i", "<cmd>KiloCodeInstall<cr>", desc = "Install/Update CLI", icon = icons.install },
    { prefix .. "s", "<cmd>KiloCodeCheck<cr>", desc = "Check status", icon = icons.check },
  }

  -- Register with which-key (v3 API)
  wk.add(mappings)
end

--- Setup which-key integration
--- This should be called after the plugin is loaded
function M.setup()
  -- Defer registration to ensure which-key is loaded
  vim.schedule(function()
    M.register()
  end)
end

return M
