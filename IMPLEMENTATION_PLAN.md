# KiloCode Neovim Plugin - Implementation Plan

## Phase 1: Project Setup (Foundation)

### 1.1 Create Project Structure
```bash
# Create directory structure
mkdir -p kilo-code.nvim/{lua/kilo_code,plugin,doc,spec}
```

### 1.2 Copy Template Files
- [ ] Create `kilo-code-scm-1.rockspec` (rename from template)
- [ ] Create `.busted` configuration
- [ ] Create `.luacheckrc` for linting
- [ ] Create `.editorconfig`
- [ ] Create `.gitignore`

### 1.3 Create Initial Files
- [ ] `README.md` - Basic documentation
- [ ] `doc/kilo_code.txt` - Vim help documentation

**Deliverable:** Working project structure that passes `luarocks lint`

---

## Phase 2: Core Infrastructure

### 2.1 Configuration Module (`lua/kilo_code/config.lua`)

**Implementation:**
```lua
local M = {}

local defaults = {
  auto_install = true,
  install_path = nil,
  sidebar = {
    position = "right",
    width = 80,
    height = nil,
    auto_close = false,
  },
  file_watcher = {
    enabled = true,
    auto_reload = true,
    notify_on_change = true,
    debounce_ms = 100,
  },
  kilo_code = {
    binary = "kilo-code",
    args = {},
    env = {},
  }
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", defaults, opts or {})
  return M.options
end

function M.get()
  return M.options
end

return M
```

**Tests:** `spec/config_spec.lua`
- [ ] Test default configuration
- [ ] Test user option merging
- [ ] Test nested table merging

### 2.2 Utilities Module (`lua/kilo_code/utils.lua`)

**Key Functions:**
```lua
-- Platform detection
function M.get_os()
  return vim.loop.os_uname().sysname
end

-- Notification helper
function M.notify(msg, level)
  vim.notify("[KiloCode] " .. msg, level or vim.log.levels.INFO)
end

-- Check if command is executable
function M.is_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Debounce utility
function M.debounce(fn, ms)
  local timer = vim.loop.new_timer()
  return function(...)
    local args = {...}
    timer:stop()
    timer:start(ms, 0, vim.schedule_wrap(function()
      fn(unpack(args))
    end))
  end
end
```

**Tests:** `spec/utils_spec.lua`
- [ ] Test platform detection
- [ ] Test debounce functionality

**Deliverable:** Configuration and utilities modules with tests passing

---

## Phase 3: Installation Module

### 3.1 Installation Detection

**Implementation:**
```lua
local utils = require("kilo_code.utils")
local config = require("kilo_code.config")

local M = {}

function M.is_installed()
  local binary = config.get().kilo_code.binary
  return utils.is_executable(binary)
end

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
```

### 3.2 Auto-Installation Logic

**Implementation:**
```lua
function M.get_install_command()
  local os_name = utils.get_os()
  
  if os_name == "Darwin" then
    -- macOS - try npm first, then curl
    if utils.is_executable("npm") then
      return "npm install -g kilo-code"
    end
  elseif os_name == "Linux" then
    -- Linux - try npm
    if utils.is_executable("npm") then
      return "npm install -g kilo-code"
    end
  end
  
  return nil
end

function M.install(callback)
  if M.is_installed() then
    utils.notify("KiloCode is already installed")
    if callback then callback(true) end
    return true
  end
  
  local cmd = M.get_install_command()
  if not cmd then
    utils.notify("Could not determine installation method", vim.log.levels.ERROR)
    if callback then callback(false) end
    return false
  end
  
  utils.notify("Installing KiloCode...")
  
  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        utils.notify("KiloCode installed successfully")
        if callback then callback(true) end
      else
        utils.notify("Failed to install KiloCode", vim.log.levels.ERROR)
        if callback then callback(false) end
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          utils.notify("Install error: " .. table.concat(data, "\n"), vim.log.levels.WARN)
        end)
      end
    end
  })
  
  return true
end
```

**Tests:** `spec/install_spec.lua`
- [ ] Test installation detection
- [ ] Test version retrieval
- [ ] Test install command generation
- [ ] Mock jobstart for install testing

**Deliverable:** Installation module with auto-install capability

---

## Phase 4: Sidebar Module

### 4.1 Sidebar State Management

**Implementation:**
```lua
local config = require("kilo_code.config")
local utils = require("kilo_code.utils")

local M = {}

-- State
local state = {
  bufnr = nil,
  winnr = nil,
  job_id = nil,
  is_open = false,
}

function M.is_open()
  return state.is_open and state.winnr and vim.api.nvim_win_is_valid(state.winnr)
end
```

### 4.2 Sidebar Window Creation

**Implementation:**
```lua
function M.open()
  if M.is_open() then
    M.focus()
    return
  end
  
  local cfg = config.get().sidebar
  
  -- Create buffer if needed
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.bufnr, "buftype", "terminal")
    vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(state.bufnr, "filetype", "kilo-code")
  end
  
  -- Calculate dimensions
  local width = cfg.width or 80
  local height = cfg.height or vim.o.lines - 4
  
  -- Create window
  local split_cmd = cfg.position == "left" and "topleft" or "botright"
  vim.cmd(split_cmd .. " " .. width .. "vsplit")
  state.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.winnr, state.bufnr)
  
  -- Configure window
  vim.api.nvim_win_set_option(state.winnr, "winfixwidth", true)
  vim.api.nvim_win_set_option(state.winnr, "number", false)
  vim.api.nvim_win_set_option(state.winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(state.winnr, "signcolumn", "no")
  
  -- Start terminal if not already running
  if not state.job_id then
    local binary = config.get().kilo_code.binary
    local args = config.get().kilo_code.args or {}
    local cmd = binary .. " " .. table.concat(args, " ")
    
    state.job_id = vim.fn.termopen(cmd, {
      on_exit = function(_, code)
        state.job_id = nil
        if code ~= 0 then
          utils.notify("KiloCode exited with code " .. code, vim.log.levels.WARN)
        end
      end,
    })
    
    -- Set environment variables
    local env = config.get().kilo_code.env or {}
    for k, v in pairs(env) do
      vim.fn.setenv(k, v)
    end
  end
  
  state.is_open = true
  
  -- Enter insert mode in terminal
  vim.cmd("startinsert")
end
```

### 4.3 Sidebar Control Functions

**Implementation:**
```lua
function M.close()
  if not M.is_open() then
    return
  end
  
  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_win_close(state.winnr, true)
  end
  
  state.winnr = nil
  state.is_open = false
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

function M.focus()
  if M.is_open() then
    vim.api.nvim_set_current_win(state.winnr)
    vim.cmd("startinsert")
  end
end

function M.send_input(text)
  if state.job_id then
    vim.fn.chansend(state.job_id, text)
  end
end

function M.get_job_id()
  return state.job_id
end
```

**Tests:** `spec/sidebar_spec.lua`
- [ ] Test open/close/toggle
- [ ] Test window configuration
- [ ] Test terminal job creation

**Deliverable:** Functional sidebar with terminal integration

---

## Phase 5: File Watcher Module

### 5.1 File Watching Setup

**Implementation:**
```lua
local config = require("kilo_code.config")
local utils = require("kilo_code.utils")

local M = {}

-- State
local watchers = {}
local file_states = {}
local is_running = false

function M.start()
  if is_running then
    return
  end
  is_running = true
  
  -- Watch all existing buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath and filepath ~= "" then
        M.watch_file(filepath, bufnr)
      end
    end
  end
end

function M.stop()
  for filepath, watcher in pairs(watchers) do
    if watcher then
      watcher:stop()
      watcher:close()
    end
  end
  watchers = {}
  file_states = {}
  is_running = false
end
```

### 5.2 File Watch Implementation

**Implementation:**
```lua
function M.watch_file(filepath, bufnr)
  if not config.get().file_watcher.enabled then
    return
  end
  
  if watchers[filepath] then
    return -- Already watching
  end
  
  -- Get initial file stats
  local stat = vim.loop.fs_stat(filepath)
  if stat then
    file_states[filepath] = {
      mtime = stat.mtime.sec,
      size = stat.size,
      bufnr = bufnr,
    }
  end
  
  -- Create fs_event watcher
  local watcher = vim.loop.new_fs_event()
  watchers[filepath] = watcher
  
  local function on_change(err, filename, events)
    if err then
      return
    end
    
    vim.schedule(function()
      M.handle_file_change(filepath, bufnr)
    end)
  end
  
  watcher:start(filepath, false, on_change)
end

function M.unwatch_file(filepath)
  local watcher = watchers[filepath]
  if watcher then
    watcher:stop()
    watcher:close()
    watchers[filepath] = nil
    file_states[filepath] = nil
  end
end
```

### 5.3 Change Detection and Reload

**Implementation:**
```lua
function M.handle_file_change(filepath, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    M.unwatch_file(filepath)
    return
  end
  
  local cfg = config.get().file_watcher
  
  -- Check if file still exists
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    -- File was deleted
    if cfg.notify_on_change then
      utils.notify("File deleted: " .. vim.fn.fnamemodify(filepath, ":t"))
    end
    return
  end
  
  -- Check if content actually changed
  local state_info = file_states[filepath]
  if state_info and state_info.mtime == stat.mtime.sec then
    return -- No change
  end
  
  -- Update stored state
  file_states[filepath] = {
    mtime = stat.mtime.sec,
    size = stat.size,
    bufnr = bufnr,
  }
  
  -- Check if buffer is modified
  local is_modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  
  if is_modified then
    -- Buffer has unsaved changes
    if cfg.notify_on_change then
      utils.notify(
        "File changed externally (buffer has unsaved changes): " .. vim.fn.fnamemodify(filepath, ":t"),
        vim.log.levels.WARN
      )
    end
    return
  end
  
  if cfg.auto_reload then
    M.reload_buffer(bufnr, filepath)
  elseif cfg.notify_on_change then
    utils.notify("File changed externally: " .. vim.fn.fnamemodify(filepath, ":t"))
  end
end

function M.reload_buffer(bufnr, filepath)
  -- Save cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  
  -- Reload buffer
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("checktime")
  end)
  
  -- Restore cursor position
  pcall(function()
    vim.api.nvim_win_set_cursor(0, cursor)
  end)
  
  if config.get().file_watcher.notify_on_change then
    utils.notify("Reloaded: " .. vim.fn.fnamemodify(filepath, ":t"))
  end
end
```

**Tests:** `spec/file_watcher_spec.lua`
- [ ] Test file watching start/stop
- [ ] Test change detection
- [ ] Test auto-reload behavior
- [ ] Test conflict handling (buffer modified)

**Deliverable:** File watcher with auto-reload capability

---

## Phase 6: Main Module and Plugin Integration

### 6.1 Main Module (`lua/kilo_code/init.lua`)

**Implementation:**
```lua
local config = require("kilo_code.config")
local install = require("kilo_code.install")
local sidebar = require("kilo_code.sidebar")
local file_watcher = require("kilo_code.file_watcher")
local utils = require("kilo_code.utils")

local M = {}

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

function M.close_sidebar()
  sidebar.close()
end

function M.toggle_sidebar()
  sidebar.toggle()
end

function M.is_installed()
  return install.is_installed()
end

function M.install()
  install.install()
end

-- Expose submodules for advanced users
M.config = config
M.sidebar = sidebar
M.file_watcher = file_watcher

return M
```

### 6.2 Plugin Entry Point (`plugin/kilo_code.lua`)

**Implementation:**
```lua
-- Guard against multiple loads
if vim.g.loaded_kilo_code then
  return
end
vim.g.loaded_kilo_code = true

local kilo_code = require("kilo_code")
local file_watcher = require("kilo_code.file_watcher")

-- User commands
vim.api.nvim_create_user_command("KiloCodeOpen", function()
  kilo_code.open_sidebar()
end, { desc = "Open KiloCode sidebar" })

vim.api.nvim_create_user_command("KiloCodeClose", function()
  kilo_code.close_sidebar()
end, { desc = "Close KiloCode sidebar" })

vim.api.nvim_create_user_command("KiloCodeToggle", function()
  kilo_code.toggle_sidebar()
end, { desc = "Toggle KiloCode sidebar" })

vim.api.nvim_create_user_command("KiloCodeInstall", function()
  kilo_code.install()
end, { desc = "Install/Update KiloCode CLI" })

vim.api.nvim_create_user_command("KiloCodeCheck", function()
  if kilo_code.is_installed() then
    local version = require("kilo_code.install").get_version()
    vim.notify("[KiloCode] Installed: " .. (version or "unknown"))
  else
    vim.notify("[KiloCode] Not installed", vim.log.levels.WARN)
  end
end, { desc = "Check KiloCode installation status" })

-- Autocommands
local augroup = vim.api.nvim_create_augroup("KiloCode", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if filepath and filepath ~= "" then
      file_watcher.watch_file(filepath, args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup,
  callback = function(args)
    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if filepath and filepath ~= "" then
      file_watcher.unwatch_file(filepath)
    end
  end,
})
```

**Deliverable:** Complete plugin with commands and autocommands

---

## Phase 7: Documentation and Polish

### 7.1 README.md

Sections to include:
- [ ] Installation instructions (lazy.nvim, packer, etc.)
- [ ] Quick start guide
- [ ] Configuration reference
- [ ] Commands reference
- [ ] Troubleshooting

### 7.2 Vim Help Documentation (`doc/kilo_code.txt`)

Sections:
- [ ] Introduction
- [ ] Installation
- [ ] Configuration options
- [ ] Commands
- [ ] Lua API
- [ ] Troubleshooting

### 7.3 GitHub Workflows

- [ ] Lint workflow (luacheck)
- [ ] Test workflow (busted)
- [ ] Release workflow (luarocks)

**Deliverable:** Complete, documented, and tested plugin

---

## Milestones and Timeline

### Milestone 1: Foundation (Phase 1-2)
- Project structure
- Configuration system
- Utilities
- **Target:** Basic plugin loads without errors

### Milestone 2: Core Features (Phase 3-4)
- Installation detection and auto-install
- Sidebar with terminal
- **Target:** Can open sidebar and interact with KiloCode CLI

### Milestone 3: File Watching (Phase 5)
- File change detection
- Auto-reload
- **Target:** Files edited by KiloCode auto-reload in Neovim

### Milestone 4: Integration (Phase 6)
- Main module
- Commands
- Autocommands
- **Target:** Full user-facing functionality

### Milestone 5: Release (Phase 7)
- Documentation
- Tests
- CI/CD
- **Target:** Production-ready plugin

---

## Testing Commands

```bash
# Run linters
luacheck lua/

# Run tests
busted

# Test in Neovim
nvim --headless -c "lua require('kilo_code').setup()" -c "qa!"
```

## Key Design Decisions

1. **Terminal Buffer for Sidebar:** Uses Neovim's built-in terminal for maximum compatibility with KiloCode CLI's interactive features

2. **Libuv File Watching:** Uses `vim.loop.new_fs_event()` for efficient, native file watching without external dependencies

3. **Lazy Initialization:** Installation check and file watcher start on first use or explicit setup call

4. **Modular Architecture:** Each feature is isolated in its own module for maintainability and testing

