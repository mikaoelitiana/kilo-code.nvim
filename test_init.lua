-- test_init.lua
-- Test configuration for running KiloCode.nvim locally

-- Add the current directory to runtimepath
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Load the plugin
require("kilo_code").setup({
  auto_install = false, -- Set to true to test auto-installation
  sidebar = {
    position = "right",
    width = 80,
  },
  file_watcher = {
    enabled = true,
    auto_reload = true,
    notify_on_change = true,
  },
})

-- Keymaps for testing
vim.keymap.set("n", "<leader>ko", ":KiloCodeOpen<CR>", { desc = "Open KiloCode" })
vim.keymap.set("n", "<leader>kt", ":KiloCodeToggle<CR>", { desc = "Toggle KiloCode" })
vim.keymap.set("n", "<leader>kc", ":KiloCodeClose<CR>", { desc = "Close KiloCode" })
vim.keymap.set("n", "<leader>ki", ":KiloCodeInstall<CR>", { desc = "Install KiloCode CLI" })

-- Print a message to confirm loading
vim.notify("KiloCode.nvim loaded! Try :KiloCodeCheck or <leader>ko", vim.log.levels.INFO)
