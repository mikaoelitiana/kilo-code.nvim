--- Utility functions for KiloCode
local M = {}

--- Get the current operating system
---@return string OS name ("Darwin", "Linux", "Windows_NT", etc.)
function M.get_os()
  return vim.loop.os_uname().sysname
end

--- Show a notification message
---@param msg string Message to display
---@param level number|nil Vim log level (vim.log.levels.INFO, WARN, ERROR, etc.)
function M.notify(msg, level)
  vim.notify("[KiloCode] " .. msg, level or vim.log.levels.INFO)
end

--- Check if a command is executable
---@param cmd string Command to check
---@return boolean True if command is executable
function M.is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

--- Get the file path for a buffer
---@param bufnr number|nil Buffer number (defaults to current buffer)
---@return string|nil File path or nil if no file
function M.get_buffer_filepath(bufnr)
  bufnr = bufnr or 0
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath and filepath ~= "" then
    return filepath
  end
  return nil
end

--- Debounce a function call
---@param fn function Function to debounce
---@param ms number Milliseconds to wait
---@return function Debounced function
function M.debounce(fn, ms)
  local timer = vim.loop.new_timer()
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(
      ms,
      0,
      vim.schedule_wrap(function()
        fn(unpack(args))
      end)
    )
  end
end

--- Check if running on macOS
---@return boolean True if on macOS
function M.is_macos()
  return M.get_os() == "Darwin"
end

--- Check if running on Linux
---@return boolean True if on Linux
function M.is_linux()
  return M.get_os() == "Linux"
end

--- Check if running on Windows
---@return boolean True if on Windows
function M.is_windows()
  return M.get_os() == "Windows_NT"
end

return M
