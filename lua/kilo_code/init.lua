--- Main module for KiloCode Neovim plugin
---@class KiloCode
local M = {}

local config = require("kilo_code.config")
local install = require("kilo_code.install")
local sidebar = require("kilo_code.sidebar")
local file_watcher = require("kilo_code.file_watcher")
local utils = require("kilo_code.utils")

--- Setup the KiloCode plugin
---@param opts table|nil User configuration options
function M.setup(opts)
  config.setup(opts)

  -- Auto-install if configured
  if config.get().auto_install and not install.is_installed() then
    install.install(function(success)
      if success then
        utils.notify("KiloCode is ready to use!")
      end
    end)
  end

  -- Start file watcher if enabled
  if config.get().file_watcher.enabled then
    file_watcher.start()
  end
end

--- Open the KiloCode sidebar
function M.open_sidebar()
  if not install.is_installed() then
    if config.get().auto_install then
      install.install(function(success)
        if success then
          sidebar.open()
        end
      end)
    else
      utils.notify("KiloCode is not installed. Run :KiloCodeInstall", vim.log.levels.ERROR)
    end
    return
  end

  sidebar.open()
end

--- Close the KiloCode sidebar
function M.close_sidebar()
  sidebar.close()
end

--- Toggle the KiloCode sidebar
function M.toggle_sidebar()
  sidebar.toggle()
end

--- Check if KiloCode CLI is installed
---@return boolean True if installed
function M.is_installed()
  return install.is_installed()
end

--- Install or update KiloCode CLI
function M.install()
  install.install()
end

--- Get the KiloCode version
---@return string|nil Version string
function M.get_version()
  return install.get_version()
end

-- Expose submodules for advanced users
M.config = config
M.sidebar = sidebar
M.file_watcher = file_watcher
M.install_module = install
M.utils = utils

return M
