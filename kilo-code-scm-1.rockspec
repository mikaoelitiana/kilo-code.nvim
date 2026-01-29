rockspec_format = "3.0"
package = "kilo-code"
version = "scm-1"
source = {
  url = "git+https://github.com/Kilo-Code/kilo-code-nvim.git",
}
description = {
  summary = "KiloCode integration for Neovim",
  detailed = [[
    A Neovim plugin that integrates KiloCode CLI into Neovim,
    providing a sidebar interface and automatic file change detection.
  ]],
  homepage = "https://github.com/Kilo-Code/kilo-code-nvim",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1",
}
test_dependencies = {
  "busted",
}
build = {
  type = "builtin",
  modules = {
    ["kilo_code"] = "lua/kilo_code/init.lua",
    ["kilo_code.config"] = "lua/kilo_code/config.lua",
    ["kilo_code.install"] = "lua/kilo_code/install.lua",
    ["kilo_code.sidebar"] = "lua/kilo_code/sidebar.lua",
    ["kilo_code.file_watcher"] = "lua/kilo_code/file_watcher.lua",
    ["kilo_code.utils"] = "lua/kilo_code/utils.lua",
  },
  copy_directories = {
    "doc",
    "plugin",
  },
}
