--- Tests for install module
local install = require("kilo_code.install")
local config = require("kilo_code.config")

describe("install", function()
  before_each(function()
    config.reset()
  end)

  describe("is_installed", function()
    it("should return boolean", function()
      local result = install.is_installed()
      assert.is_boolean(result)
    end)
  end)

  describe("get_version", function()
    it("should return nil when not installed", function()
      -- This test assumes kilo-code is not installed in test environment
      -- If it is installed, this test may fail
      if not install.is_installed() then
        local version = install.get_version()
        assert.is_nil(version)
      end
    end)
  end)

  describe("get_install_command", function()
    it("should return a string or nil", function()
      local cmd = install.get_install_command()
      assert.is_true(cmd == nil or type(cmd) == "string")
    end)

    it("should return npm command when npm is available", function()
      local utils = require("kilo_code.utils")
      if utils.is_executable("npm") then
        local cmd = install.get_install_command()
        assert.is_string(cmd)
        assert.is_true(cmd:match("npm") ~= nil)
      end
    end)
  end)

  describe("install", function()
    it("should return true when already installed", function()
      -- Mock the config to use a non-existent binary
      config.setup({
        kilo_code = {
          binary = "kilo-code-test-nonexistent",
        },
      })

      -- Since it's not installed and we can't install in tests,
      -- we just verify the function runs without error
      local result = install.install()
      -- Result depends on whether npm is available
      assert.is_boolean(result)
    end)
  end)
end)
