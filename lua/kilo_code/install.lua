--- Installation module for KiloCode CLI
local config = require("kilo_code.config")
local utils = require("kilo_code.utils")

local M = {}

--- Check if KiloCode CLI is installed
---@return boolean True if installed and executable
function M.is_installed()
  local binary = config.get().kilo_code.binary
  return utils.is_executable(binary)
end

--- Get the installed KiloCode version
---@return string|nil Version string or nil if not installed
function M.get_version()
  if not M.is_installed() then
    return nil
  end
  local binary = config.get().kilo_code.binary
  local handle = io.popen(binary .. " --version 2>&1")
  if handle then
    local version = handle:read("*a")
    handle:close()
    return version:gsub("%s+$", "")
  end
  return nil
end

--- Get the installation command for the current platform
---@return string|nil Installation command or nil if not supported
function M.get_install_command()
  local os_name = utils.get_os()

  if os_name == "Darwin" then
    -- macOS - try npm first
    if utils.is_executable("npm") then
      return "npm install -g @kilocode/cli"
    end
  elseif os_name == "Linux" then
    -- Linux - try npm
    if utils.is_executable("npm") then
      return "npm install -g @kilocode/cli"
    end
  end

  return nil
end

--- Install KiloCode CLI
---@param callback function|nil Optional callback function(success: boolean)
---@return boolean True if installation was started
function M.install(callback)
  if M.is_installed() then
    utils.notify("KiloCode is already installed")
    if callback then
      callback(true)
    end
    return true
  end

  local cmd = M.get_install_command()
  if not cmd then
    utils.notify("Could not determine installation method", vim.log.levels.ERROR)
    if callback then
      callback(false)
    end
    return false
  end

  utils.notify("Installing KiloCode...")

  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        utils.notify("KiloCode installed successfully")
        if callback then
          callback(true)
        end
      else
        utils.notify("Failed to install KiloCode", vim.log.levels.ERROR)
        if callback then
          callback(false)
        end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          utils.notify("Install error: " .. table.concat(data, "\n"), vim.log.levels.WARN)
        end)
      end
    end,
  })

  return true
end

return M
