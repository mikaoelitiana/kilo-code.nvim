--- Tests for config module
local config = require("kilo_code.config")

describe("config", function()
  before_each(function()
    config.reset()
  end)

  describe("setup", function()
    it("should use defaults when no options provided", function()
      config.setup()
      local opts = config.get()

      assert.is_true(opts.auto_install)
      assert.is_nil(opts.install_path)
      assert.equals("right", opts.sidebar.position)
      assert.equals(80, opts.sidebar.width)
      assert.is_true(opts.file_watcher.enabled)
      assert.is_true(opts.file_watcher.auto_reload)
      assert.equals("kilo-code", opts.kilo_code.binary)
    end)

    it("should merge user options with defaults", function()
      config.setup({
        auto_install = false,
        sidebar = {
          position = "left",
          width = 100,
        },
      })
      local opts = config.get()

      assert.is_false(opts.auto_install)
      assert.equals("left", opts.sidebar.position)
      assert.equals(100, opts.sidebar.width)
      -- Other defaults should remain
      assert.is_true(opts.file_watcher.enabled)
    end)

    it("should deeply merge nested tables", function()
      config.setup({
        file_watcher = {
          auto_reload = false,
        },
      })
      local opts = config.get()

      assert.is_false(opts.file_watcher.auto_reload)
      assert.is_true(opts.file_watcher.enabled) -- Should remain default
      assert.is_true(opts.file_watcher.notify_on_change) -- Should remain default
    end)
  end)

  describe("get", function()
    it("should return current configuration", function()
      config.setup({ auto_install = false })
      local opts = config.get()

      assert.is_false(opts.auto_install)
    end)
  end)

  describe("reset", function()
    it("should reset to defaults", function()
      config.setup({ auto_install = false })
      config.reset()
      local opts = config.get()

      assert.is_true(opts.auto_install)
    end)
  end)
end)
