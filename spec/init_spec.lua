--- Tests for main init module
local kilo_code = require("kilo_code")
local config = require("kilo_code.config")

describe("kilo_code", function()
  before_each(function()
    config.reset()
  end)

  describe("setup", function()
    it("should initialize the plugin", function()
      assert.has_no.errors(function()
        kilo_code.setup()
      end)
    end)

    it("should accept configuration options", function()
      kilo_code.setup({
        auto_install = false,
        sidebar = {
          position = "left",
        },
      })

      local opts = config.get()
      assert.is_false(opts.auto_install)
      assert.equals("left", opts.sidebar.position)
    end)
  end)

  describe("is_installed", function()
    it("should return boolean", function()
      local result = kilo_code.is_installed()
      assert.is_boolean(result)
    end)
  end)

  describe("get_version", function()
    it("should return nil or string", function()
      local version = kilo_code.get_version()
      assert.is_true(version == nil or type(version) == "string")
    end)
  end)

  describe("submodules", function()
    it("should expose config module", function()
      assert.is_table(kilo_code.config)
      assert.is_function(kilo_code.config.get)
    end)

    it("should expose sidebar module", function()
      assert.is_table(kilo_code.sidebar)
      assert.is_function(kilo_code.sidebar.open)
      assert.is_function(kilo_code.sidebar.close)
      assert.is_function(kilo_code.sidebar.toggle)
    end)

    it("should expose file_watcher module", function()
      assert.is_table(kilo_code.file_watcher)
      assert.is_function(kilo_code.file_watcher.start)
      assert.is_function(kilo_code.file_watcher.stop)
    end)

    it("should expose utils module", function()
      assert.is_table(kilo_code.utils)
      assert.is_function(kilo_code.utils.notify)
      assert.is_function(kilo_code.utils.get_os)
    end)
  end)
end)
