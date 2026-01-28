# Contributing to KiloCode.nvim

Thank you for your interest in contributing to KiloCode.nvim! This document provides guidelines for running the plugin locally, testing changes, and submitting contributions.

## Table of Contents

- [Development Setup](#development-setup)
- [Running the Plugin Locally](#running-the-plugin-locally)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)

## Development Setup

### Prerequisites

- **Neovim** >= 0.7.0
- **Git** for version control
- **LuaRocks** (optional, for running tests)
- **busted** (optional, for running tests)
- **luacheck** (optional, for linting)

### Clone the Repository

```bash
git clone https://github.com/mikaoelitiana/kilo-code.nvim.git
cd kilo-code.nvim
```

## Running the Plugin Locally

### Method 1: Direct Load (Recommended for Quick Testing)

We provide a `test_init.lua` file that sets up the plugin for local testing:

```bash
# From the project directory
nvim -u test_init.lua
```

This will:
- Load the plugin from the current directory
- Set up keymaps (`<leader>ko`, `<leader>kt`, `<leader>kc`)
- Display a notification when loaded

**Available Commands:**
- `:KiloCodeCheck` - Check if KiloCode CLI is installed
- `:KiloCodeOpen` - Open the sidebar
- `:KiloCodeToggle` - Toggle the sidebar
- `:KiloCodeClose` - Close the sidebar
- `:KiloCodeInstall` - Install KiloCode CLI

**Keymaps:**
- `<leader>ko` - Open KiloCode
- `<leader>kt` - Toggle KiloCode
- `<leader>kc` - Close KiloCode
- `<leader>ki` - Install KiloCode CLI

### Method 2: Using lazy.nvim

If you use lazy.nvim, point to your local clone:

```lua
-- In your Neovim config
{
  dir = "/path/to/kilo-code.nvim",  -- Your local path
  config = function()
    require("kilo_code").setup({
      auto_install = false,
      sidebar = {
        position = "right",
        width = 80,
      },
    })
  end,
}
```

### Method 3: Using packer.nvim

```lua
-- In your packer config
use {
  "/path/to/kilo-code.nvim",  -- Your local path
  config = function()
    require("kilo_code").setup()
  end,
}
```

### Method 4: Minimal Test Script

Create a minimal test file anywhere:

```lua
-- test_kilo.lua
vim.opt.runtimepath:prepend("/path/to/kilo-code.nvim")
require("kilo_code").setup()
-- Now test the plugin
```

Run with:
```bash
nvim -u test_kilo.lua
```

## Testing

### Running Tests

We use [busted](https://lunarmodules.github.io/busted/) for testing.

#### Install busted

```bash
luarocks install busted
```

#### Run All Tests

```bash
busted
```

#### Run Specific Test File

```bash
busted spec/config_spec.lua
busted spec/sidebar_spec.lua
```

#### Run with Verbose Output

```bash
busted -v
```

### Test Structure

Tests are organized in the `spec/` directory:

- `spec/init_spec.lua` - Tests for the main module
- `spec/config_spec.lua` - Tests for configuration
- `spec/utils_spec.lua` - Tests for utility functions
- `spec/install_spec.lua` - Tests for installation logic
- `spec/sidebar_spec.lua` - Tests for sidebar functionality
- `spec/file_watcher_spec.lua` - Tests for file watching

### Writing Tests

When adding new features, please include tests:

```lua
describe("my_new_feature", function()
  it("should do something", function()
    local result = my_module.do_something()
    assert.equals(expected, result)
  end)
end)
```

## Code Style

### Linting

We use [luacheck](https://github.com/lunarmodules/luacheck) for linting.

#### Install luacheck

```bash
luarocks install luacheck
```

#### Run Linter

```bash
luacheck lua/
```

### Code Formatting

- Use 2 spaces for indentation
- Maximum line length: 120 characters
- Follow existing code style
- Use descriptive variable names

### EditorConfig

The project includes an `.editorconfig` file. Please ensure your editor respects these settings.

## Submitting Changes

### Before Submitting

1. **Test your changes:**
   ```bash
   busted
   luacheck lua/
   ```

2. **Test manually:**
   ```bash
   nvim -u test_init.lua
   ```

3. **Update documentation** if needed (README.md, doc/kilo_code.txt)

### Commit Messages

Use clear, descriptive commit messages:

```
Add feature X to sidebar module

- Implement feature X
- Add tests for feature X
- Update documentation
```

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run tests and linting
5. Commit your changes (`git commit -am 'Add my feature'`)
6. Push to the branch (`git push origin feature/my-feature`)
7. Open a Pull Request

### Pull Request Checklist

- [ ] Tests pass (`busted`)
- [ ] Code passes linting (`luacheck lua/`)
- [ ] Manual testing completed
- [ ] Documentation updated (if needed)
- [ ] Commit messages are clear

## Debugging

### Enable Verbose Mode

```lua
vim.opt.verbose = 2
```

### Check Plugin State

```lua
-- In Neovim command line
:lua print(vim.inspect(require("kilo_code.config").get()))
:lua print(require("kilo_code").is_installed())
:lua print(require("kilo_code.install").get_version())
```

### View Messages

```vim
:messages
```

## Questions?

If you have questions about contributing, feel free to:
- Open an issue on GitHub
- Check existing issues and pull requests

Thank you for contributing!
