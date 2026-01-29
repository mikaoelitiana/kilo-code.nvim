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

--- Detect the system theme (dark or light mode)
--- Uses macOS defaults on Darwin, gsettings on Linux, and registry on Windows
---@return "dark"|"light"|nil The detected theme, or nil if detection failed
function M.detect_system_theme()
  local os_name = M.get_os()

  if os_name == "Darwin" then
    -- macOS: Use defaults command to check AppleInterfaceStyle
    local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and result:match("Dark") then
        return "dark"
      else
        return "light"
      end
    end
  elseif os_name == "Linux" then
    -- Linux: Try gsettings (GNOME/GTK) first, then xdg-desktop-portal
    local handle = io.popen("gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null")
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and (result:lower():match("dark") or result:lower():match("black")) then
        return "dark"
      elseif result then
        return "light"
      end
    end

    -- Fallback: Try xdg-desktop-portal
    handle = io.popen(
      'dbus-send --session --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:org.freedesktop.appearance string:color-scheme 2>/dev/null | grep -q "uint32 1" && echo "dark" || echo "light"'
    )
    if handle then
      local result = handle:read("*a")
      handle:close()
      result = result:gsub("%s+", "")
      if result == "dark" then
        return "dark"
      elseif result == "light" then
        return "light"
      end
    end
  elseif os_name == "Windows_NT" then
    -- Windows: Check registry for AppsUseLightTheme
    local handle = io.popen(
      'reg query "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v AppsUseLightTheme 2>nul | findstr /C:"0x0"'
    )
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result and result ~= "" then
        return "dark"
      else
        return "light"
      end
    end
  end

  return nil
end

--- Get the theme to use based on configuration and system detection
---@param theme_config table Theme configuration from config
---@return string The theme value to pass to KiloCode CLI
function M.get_effective_theme(theme_config)
  theme_config = theme_config or {}

  if theme_config.auto_detect ~= false then
    local system_theme = M.detect_system_theme()
    if system_theme == "dark" then
      return theme_config.dark or "dark"
    elseif system_theme == "light" then
      return theme_config.light or "light"
    end
  end

  -- Default to dark theme if auto-detection is disabled or failed
  return theme_config.dark or "dark"
end

return M
