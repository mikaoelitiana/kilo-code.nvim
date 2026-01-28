# KiloCode Neovim Plugin - Architecture Plan

## Overview

This document outlines the architecture for a Neovim plugin that integrates KiloCode CLI into Neovim, providing a sidebar interface and automatic file change detection.

## Project Structure

Based on the nvim-lua-plugin-template, the plugin will follow this structure:

```
kilo-code.nvim/
├── lua/
│   └── kilo_code/
│       ├── init.lua              -- Main entry point, configuration
│       ├── config.lua            -- Configuration management
│       ├── install.lua           -- KiloCode CLI installation logic
│       ├── sidebar.lua           -- Sidebar terminal buffer management
│       ├── file_watcher.lua      -- File change detection and auto-reload
│       └── utils.lua             -- Utility functions
├── plugin/
│   └── kilo_code.lua             -- Plugin initialization, commands, autocmds
├── doc/
│   └── kilo_code.txt             -- Vim help documentation
├── spec/
│   ├── init_spec.lua
│   ├── install_spec.lua
│   ├── sidebar_spec.lua
│   └── file_watcher_spec.lua
├── kilo-code-scm-1.rockspec      -- LuaRocks package specification
├── .busted                       -- Busted test configuration
├── .luacheckrc                   -- Luacheck configuration
├── .editorconfig                 -- Editor configuration
└── README.md                     -- User documentation
```

## Module Design

### 1. Core Module (`lua/kilo_code/init.lua`)

**Responsibilities:**
- Plugin initialization
- Public API exposure
- Configuration setup
- Module coordination

**Key Functions:**
- `setup(opts)` - Initialize plugin with user configuration
- `open_sidebar()` - Open/toggle the KiloCode sidebar
- `close_sidebar()` - Close the sidebar
- `toggle_sidebar()` - Toggle sidebar visibility
- `is_installed()` - Check if KiloCode CLI is installed

### 2. Configuration Module (`lua/kilo_code/config.lua`)

**Responsibilities:**
- Default configuration management
- User option merging
- Configuration validation

**Default Configuration:**
```lua
{
  -- Installation settings
  auto_install = true,              -- Auto-install KiloCode if not found
  install_path = nil,               -- Custom installation path (nil = default)
  
  -- Sidebar settings
  sidebar = {
    position = "right",             -- "left" or "right"
    width = 80,                     -- Width in columns
    height = nil,                   -- Height in rows (nil = full height)
    auto_close = false,             -- Auto-close on buffer switch
  },
  
  -- File watcher settings
  file_watcher = {
    enabled = true,                 -- Enable file change detection
    auto_reload = true,             -- Auto-reload changed buffers
    notify_on_change = true,        -- Show notification on external changes
    debounce_ms = 100,              -- Debounce time for file events
  },
  
  -- KiloCode CLI settings
  kilo_code = {
    binary = "kilo-code",           -- Binary name or path
    args = {},                      -- Additional CLI arguments
    env = {},                       -- Environment variables
  }
}
```

### 3. Installation Module (`lua/kilo_code/install.lua`)

**Responsibilities:**
- Detect if KiloCode CLI is installed
- Auto-install KiloCode if configured
- Handle different installation methods
- Platform-specific installation logic

**Key Functions:**
- `is_installed()` - Check if KiloCode binary exists and is executable
- `get_version()` - Get installed KiloCode version
- `install()` - Install KiloCode CLI
- `get_install_command()` - Get platform-specific install command

**Installation Methods:**
1. Check if `kilo-code` is in PATH
2. If not found and `auto_install = true`:
   - Detect OS (macOS, Linux)
   - Run appropriate installer (npm, curl, etc.)
   - Verify installation

### 4. Sidebar Module (`lua/kilo_code/sidebar.lua`)

**Responsibilities:**
- Create and manage sidebar terminal buffer
- Handle terminal job control
- Manage window positioning and sizing
- Handle sidebar state (open/closed/focused)

**Key Functions:**
- `open()` - Open sidebar with KiloCode CLI
- `close()` - Close sidebar window
- `toggle()` - Toggle sidebar visibility
- `focus()` - Focus sidebar window
- `is_open()` - Check if sidebar is open
- `send_input(text)` - Send input to KiloCode CLI
- `get_job_id()` - Get terminal job ID for communication

**Implementation Details:**
- Use `:terminal` to spawn KiloCode CLI
- Create vertical split with configurable width
- Use `termopen()` or `jobstart()` with terminal buffer
- Set buffer options: `buftype=nofile`, `bufhidden=hide`, `swapfile=false`
- Window options: `winfixwidth`, `number=false`, `relativenumber=false`

### 5. File Watcher Module (`lua/kilo_code/file_watcher.lua`)

**Responsibilities:**
- Monitor files for external changes
- Auto-reload buffers when changed by KiloCode
- Handle buffer modified state conflicts
- Debounce file events

**Key Functions:**
- `start()` - Start watching files
- `stop()` - Stop watching files
- `watch_file(filepath)` - Add file to watch list
- `unwatch_file(filepath)` - Remove file from watch list
- `check_changes()` - Check for external changes
- `reload_buffer(bufnr)` - Reload buffer content

**Implementation Details:**
- Use Neovim's `uv.fs_event` (libuv) for file watching
- Track file modification times
- Compare buffer content hash or modification time
- Handle `autoread` option integration
- Debounce rapid successive changes
- Prompt user if buffer has unsaved changes

### 6. Utilities Module (`lua/kilo_code/utils.lua`)

**Responsibilities:**
- Common utility functions
- Platform detection
- Path manipulation
- Notification helpers

**Key Functions:**
- `get_os()` - Detect operating system
- `notify(msg, level)` - Show notification
- `is_executable(cmd)` - Check if command is executable
- `get_buffer_filepath(bufnr)` - Get file path for buffer
- `debounce(fn, ms)` - Debounce function calls

## Plugin Entry Point (`plugin/kilo_code.lua`)

**Responsibilities:**
- Define user commands
- Set up autocommands
- Initialize plugin on startup

**User Commands:**
- `:KiloCodeOpen` - Open KiloCode sidebar
- `:KiloCodeClose` - Close KiloCode sidebar
- `:KiloCodeToggle` - Toggle KiloCode sidebar
- `:KiloCodeInstall` - Install/Update KiloCode CLI
- `:KiloCodeCheck` - Check KiloCode installation status

**Autocommands:**
- `BufReadPost` - Add file to watcher
- `BufDelete` - Remove file from watcher
- `BufWritePost` - Update file modification tracking
- `CursorHold` - Periodic check for external changes

## Data Flow

### Opening Sidebar

```
User runs :KiloCodeToggle
    ↓
init.toggle_sidebar()
    ↓
install.is_installed()
    ↓
[if not installed] → install.install()
    ↓
sidebar.open()
    ↓
Create terminal buffer → termopen("kilo-code")
    ↓
Create vertical split window
    ↓
file_watcher.start() (if enabled)
```

### File Change Detection

```
KiloCode modifies file
    ↓
file_watcher detects change (uv.fs_event)
    ↓
Check if buffer is loaded
    ↓
[if buffer modified] → Notify user, offer reload
[if auto_reload enabled] → Reload buffer
    ↓
Update buffer content
```

## Integration Points

### KiloCode CLI Integration

- Spawn KiloCode as terminal job
- Communicate via terminal input/output
- Pass current file context via environment variables or arguments
- Handle CLI exit codes

### Neovim API Usage

- `vim.api.nvim_create_buf()` - Create sidebar buffer
- `vim.api.nvim_open_win()` - Open sidebar window
- `vim.api.nvim_create_autocmd()` - Set up autocommands
- `vim.api.nvim_create_user_command()` - Define commands
- `vim.loop.new_fs_event()` - File watching
- `vim.fn.termopen()` / `vim.fn.jobstart()` - Terminal/job management

## Error Handling

- Wrap operations in `pcall()` for error recovery
- Notify user of installation failures
- Graceful degradation if KiloCode CLI unavailable
- Handle terminal job failures
- Validate configuration options

## Testing Strategy

- Unit tests for each module using busted
- Mock Neovim API for isolated testing
- Integration tests for file watcher
- Test installation logic with mocked commands

## Future Enhancements

- RPC communication with KiloCode for richer integration
- Custom UI instead of terminal buffer (floating window with custom renderer)
- Telescope integration for file selection
- LSP-style code actions from KiloCode suggestions
- Session persistence for KiloCode context
