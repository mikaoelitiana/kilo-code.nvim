-- Luacheck configuration for kilo-code.nvim

std = "luajit"
files["lua/"] = {
  globals = {
    "vim",
  },
}
files["spec/"] = {
  globals = {
    "vim",
    "describe",
    "it",
    "before_each",
    "after_each",
    "setup",
    "teardown",
    "assert",
    "spy",
    "mock",
    "stub",
  },
}

-- Ignore unused self in methods
self = false

-- Allow unused arguments (common in callbacks)
unused_args = false

-- Maximum line length
max_line_length = 120

-- Ignore some common warnings
ignore = {
  "212", -- Unused argument
  "631", -- Line is too long
}
