--- Tests for sidebar module
local sidebar = require("kilo_code.sidebar")
local config = require("kilo_code.config")

describe("sidebar", function()
  before_each(function()
    config.reset()
    -- Close sidebar if open
    if sidebar.is_open() then
      sidebar.close()
    end
  end)

  after_each(function()
    -- Clean up
    if sidebar.is_open() then
      sidebar.close()
    end
  end)

  describe("is_open", function()
    it("should return false when not open", function()
      assert.is_false(sidebar.is_open())
    end)
  end)

  describe("open", function()
    it("should create a buffer", function()
      -- Note: This test requires KiloCode to be installed
      -- or will use a mock binary
      config.setup({
        kilo_code = {
          binary = "echo", -- Use echo as a mock binary
        },
      })

      sidebar.open()
      assert.is_number(sidebar.get_bufnr())
      assert.is_true(vim.api.nvim_buf_is_valid(sidebar.get_bufnr()))
    end)

    it("should create a window", function()
      config.setup({
        kilo_code = {
          binary = "echo",
        },
      })

      sidebar.open()
      assert.is_number(sidebar.get_winnr())
      assert.is_true(vim.api.nvim_win_is_valid(sidebar.get_winnr()))
    end)
  end)

  describe("close", function()
    it("should close the window", function()
      config.setup({
        kilo_code = {
          binary = "echo",
        },
      })

      sidebar.open()
      local winnr = sidebar.get_winnr()
      sidebar.close()
      assert.is_false(vim.api.nvim_win_is_valid(winnr))
    end)
  end)

  describe("toggle", function()
    it("should open when closed", function()
      config.setup({
        kilo_code = {
          binary = "echo",
        },
      })

      assert.is_false(sidebar.is_open())
      sidebar.toggle()
      assert.is_true(sidebar.is_open())
    end)

    it("should close when open", function()
      config.setup({
        kilo_code = {
          binary = "echo",
        },
      })

      sidebar.open()
      assert.is_true(sidebar.is_open())
      sidebar.toggle()
      assert.is_false(sidebar.is_open())
    end)
  end)

  describe("get_job_id", function()
    it("should return nil when not open", function()
      assert.is_nil(sidebar.get_job_id())
    end)
  end)
end)
