# Testing KiloCode.nvim Locally

This guide explains how to run and test the KiloCode.nvim plugin locally.

## Prerequisites

- Neovim >= 0.7.0
- Lua/LuaJIT (for running tests with busted)
- `kilo-code` CLI (optional, plugin can auto-install)

## Method 1: Direct Load in Neovim

The simplest way to test is to add the local plugin path to Neovim's runtimepath:

### Step 1: Create a test init file

Create `test_init.lua` in the project root:

```lua
-- test_init.lua
-- Add the current directory to runtimepath
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Load the plugin
require("kilo_code").setup({
  auto_install = false,  -- Set to true to test auto-installation
  sidebar = {
    position = "right",
    width = 80,
  },
  file_watcher = {
    enabled = true,
    auto_reload = true,
  },
})

-- Keymaps for testing
vim.keymap.set("n", "<leader>ko", ":KiloCodeOpen<CR>", { desc = "Open KiloCode" })
vim.keymap.set("n", "<leader>kt", ":KiloCodeToggle<CR>", { desc = "Toggle KiloCode" })
vim.keymap.set("n", "<leader>kc", ":KiloCodeClose<CR>", { desc = "Close KiloCode" })
```

### Step 2: Run Neovim with the test config

```bash
# From the project directory
nvim -u test_init.lua
```

### Step 3: Test the commands

Inside Neovim, try:
- `:KiloCodeCheck` - Check if KiloCode is installed
- `:KiloCodeOpen` - Open the sidebar
- `:KiloCodeToggle` - Toggle the sidebar
- `:KiloCodeClose` - Close the sidebar
- Use the keymaps `<leader>ko`, `<leader>kt`, `<leader>kc`

## Method 2: Using lazy.nvim (Recommended for Development)

If you use lazy.nvim as your plugin manager, you can point it to the local directory:

```lua
-- In your Neovim config (e.g., ~/.config/nvim/lua/plugins/kilo-code.lua)
return {
  dir = "/path/to/kilo-code.nvim",  -- Use local directory
  -- OR for production: "mikaoelitiana/kilo-code.nvim",
  config = function()
    require("kilo_code").setup({
      auto_install = true,
    })
  end,
}
```

## Method 3: Using packer.nvim

```lua
-- In your packer config
use {
  "/path/to/kilo-code.nvim",  -- Local path
  config = function()
    require("kilo_code").setup()
  end,
}
```

## Running Tests

### Install busted (if not already installed)

```bash
# Using LuaRocks
luarocks install busted

# Or using LuaRocks with LuaJIT
luarocks --lua-version=5.1 install busted
```

### Run the test suite

```bash
# From the project directory
busted

# Or with verbose output
busted -v

# Run specific test file
busted spec/config_spec.lua
```

### Run tests with Neovim's built-in test runner

```bash
# Using make (if you have a Makefile)
make test

# Or directly with nvim
nvim --headless -c "lua require('busted').run()" -c "qa!"
```

## Linting

### Install luacheck

```bash
luarocks install luacheck
```

### Run linter

```bash
# Check all Lua files
luacheck lua/

# Check with specific config
luacheck lua/ --config .luacheckrc
```

## Manual Testing Checklist

- [ ] Plugin loads without errors
- [ ] `:KiloCodeCheck` shows correct installation status
- [ ] `:KiloCodeOpen` creates a sidebar with terminal
- [ ] `:KiloCodeToggle` opens and closes the sidebar
- [ ] `:KiloCodeClose` closes the sidebar
- [ ] File changes are detected (if file_watcher is enabled)
- [ ] Auto-reload works when files are modified externally
- [ ] Configuration options are respected

## Debugging

### Enable verbose logging

Add to your test config:

```lua
vim.opt.verbose = 2  -- Show all messages
```

### Check for errors

```vim
:messages
```

### Test Lua modules directly

```lua
:lua print(vim.inspect(require("kilo_code.config").get()))
:lua print(require("kilo_code").is_installed())
:lua print(require("kilo_code.install").get_version())
```

## Troubleshooting

### "module 'kilo_code' not found"

Make sure the plugin directory is in Neovim's runtimepath:
```lua
vim.opt.runtimepath:prepend("/path/to/kilo-code.nvim")
```

### Tests fail with "attempt to index a nil value"

Ensure you're running tests with Neovim's Lua environment:
```bash
nvim --headless -c "lua require('busted').run()" -c "qa!"
```

### Sidebar doesn't open

Check if KiloCode CLI is installed:
```vim
:KiloCodeCheck
```

Or install it manually:
```bash
npm install -g @kilocode/cli
```
