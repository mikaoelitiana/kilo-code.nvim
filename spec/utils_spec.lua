--- Tests for utils module
local utils = require("kilo_code.utils")

describe("utils", function()
  describe("get_os", function()
    it("should return a string", function()
      local os_name = utils.get_os()
      assert.is_string(os_name)
    end)

    it("should return a valid OS name", function()
      local os_name = utils.get_os()
      local valid_os = {
        Darwin = true,
        Linux = true,
        Windows_NT = true,
      }
      assert.is_true(valid_os[os_name] ~= nil, "Expected valid OS name, got: " .. tostring(os_name))
    end)
  end)

  describe("is_executable", function()
    it("should return true for existing commands", function()
      -- 'vim' should be executable in Neovim
      assert.is_true(utils.is_executable("vim"))
    end)

    it("should return false for non-existing commands", function()
      assert.is_false(utils.is_executable("nonexistent_command_xyz"))
    end)
  end)

  describe("get_buffer_filepath", function()
    it("should return nil for unnamed buffer", function()
      -- Create a new unnamed buffer
      local bufnr = vim.api.nvim_create_buf(false, true)
      local filepath = utils.get_buffer_filepath(bufnr)
      assert.is_nil(filepath)
    end)
  end)

  describe("is_macos", function()
    it("should return boolean", function()
      local result = utils.is_macos()
      assert.is_boolean(result)
    end)
  end)

  describe("is_linux", function()
    it("should return boolean", function()
      local result = utils.is_linux()
      assert.is_boolean(result)
    end)
  end)

  describe("is_windows", function()
    it("should return boolean", function()
      local result = utils.is_windows()
      assert.is_boolean(result)
    end)
  end)

  describe("debounce", function()
    it("should return a function", function()
      local fn = function() end
      local debounced = utils.debounce(fn, 100)
      assert.is_function(debounced)
    end)
  end)
end)
