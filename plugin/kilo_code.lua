--- Plugin entry point for KiloCode
-- This file is loaded when Neovim starts

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
    local version = kilo_code.get_version()
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
