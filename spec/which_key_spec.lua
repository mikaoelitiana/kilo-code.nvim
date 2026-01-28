--- Tests for the which_key module
local which_key = require("kilo_code.which_key")
local config = require("kilo_code.config")

describe("which_key", function()
  before_each(function()
    config.reset()
    -- Mock which-key module
    package.loaded["which-key"] = nil
  end)

  after_each(function()
    package.loaded["which-key"] = nil
  end)

  describe("is_available", function()
    it("returns false when which-key is not installed", function()
      -- Ensure which-key is not loaded
      package.loaded["which-key"] = nil
      assert.is_false(which_key.is_available())
    end)

    it("returns true when which-key is installed", function()
      -- Mock which-key
      package.loaded["which-key"] = { add = function() end }
      assert.is_true(which_key.is_available())
    end)
  end)

  describe("register", function()
    it("does nothing when which-key is not available", function()
      -- Should not error
      assert.has_no.errors(function()
        which_key.register()
      end)
    end)

    it("registers keymaps when which-key is available", function()
      local add_called = false
      local added_mappings = nil

      -- Mock which-key
      package.loaded["which-key"] = {
        add = function(mappings)
          add_called = true
          added_mappings = mappings
        end,
      }

      which_key.register()

      assert.is_true(add_called)
      assert.is_table(added_mappings)
      assert.equals(6, #added_mappings)

      -- Check group mapping
      assert.equals("<leader>k", added_mappings[1][1])
      assert.equals("KiloCode", added_mappings[1].group)

      -- Check individual mappings
      assert.equals("<leader>ko", added_mappings[2][1])
      assert.equals("<cmd>KiloCodeOpen<cr>", added_mappings[2][2])
      assert.equals("Open sidebar", added_mappings[2].desc)
    end)

    it("does not register when which_key is disabled in config", function()
      config.setup({
        which_key = {
          enabled = false,
        },
      })

      local add_called = false
      package.loaded["which-key"] = {
        add = function()
          add_called = true
        end,
      }

      which_key.register()
      assert.is_false(add_called)
    end)

    it("uses custom prefix from config", function()
      config.setup({
        which_key = {
          prefix = "<leader>K",
        },
      })

      local added_mappings = nil
      package.loaded["which-key"] = {
        add = function(mappings)
          added_mappings = mappings
        end,
      }

      which_key.register()

      assert.equals("<leader>K", added_mappings[1][1])
      assert.equals("<leader>Ko", added_mappings[2][1])
    end)
  end)

  describe("setup", function()
    it("schedules registration", function()
      local register_called = false

      -- Mock which-key
      package.loaded["which-key"] = {
        add = function() end,
      }

      -- Override register to track calls
      local original_register = which_key.register
      which_key.register = function()
        register_called = true
      end

      which_key.setup()

      -- Should not be called immediately (scheduled)
      assert.is_false(register_called)

      -- Restore
      which_key.register = original_register
    end)
  end)
end)
