# KiloCode.nvim

A Neovim plugin that integrates [KiloCode CLI](https://github.com/Kilo-Code/kilo-code) into Neovim, providing a sidebar interface and automatic file change detection.

## Features

- 🚀 **Sidebar Interface**: Open KiloCode in a dedicated sidebar terminal
- 📁 **File Watching**: Automatically detect and reload files modified by KiloCode
- ⚡ **Auto-installation**: Automatically install KiloCode CLI if not found
- 🔧 **Configurable**: Customize sidebar position, size, and behavior
- 📦 **Zero Dependencies**: Uses only Neovim's built-in APIs

## Requirements

- Neovim >= 0.7.0
- KiloCode CLI (will be auto-installed if not found and `auto_install` is enabled)
- npm (for auto-installation)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "Kilo-Code/kilo-code.nvim",
  config = function()
    require("kilo_code").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "Kilo-Code/kilo-code.nvim",
  config = function()
    require("kilo_code").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Kilo-Code/kilo-code.nvim'
```

Then in your `init.lua`:

```lua
require("kilo_code").setup()
```

## Configuration

```lua
require("kilo_code").setup({
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
  },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:KiloCodeOpen` | Open KiloCode sidebar |
| `:KiloCodeClose` | Close KiloCode sidebar |
| `:KiloCodeToggle` | Toggle KiloCode sidebar |
| `:KiloCodeInstall` | Install/Update KiloCode CLI |
| `:KiloCodeCheck` | Check KiloCode installation status |

## Lua API

```lua
local kilo_code = require("kilo_code")

-- Setup
kilo_code.setup({
  -- your configuration
})

-- Sidebar control
kilo_code.open_sidebar()
kilo_code.close_sidebar()
kilo_code.toggle_sidebar()

-- Installation
kilo_code.install()
if kilo_code.is_installed() then
  print(kilo_code.get_version())
end

-- Access submodules
kilo_code.config.get()           -- Get current configuration
kilo_code.sidebar.is_open()      -- Check if sidebar is open
kilo_code.file_watcher.start()   -- Start file watcher
```

## Troubleshooting

### KiloCode CLI not found

If auto-installation is disabled or fails, you can manually install KiloCode CLI:

```bash
npm install -g kilo-code
```

### File changes not detected

Ensure the file watcher is enabled in your configuration:

```lua
require("kilo_code").setup({
  file_watcher = {
    enabled = true,
  },
})
```

### Sidebar not opening

Check if KiloCode CLI is installed and accessible:

```vim
:KiloCodeCheck
```

## License

MIT
