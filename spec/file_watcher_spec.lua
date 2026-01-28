--- Tests for file watcher module
local file_watcher = require("kilo_code.file_watcher")
local config = require("kilo_code.config")

describe("file_watcher", function()
  before_each(function()
    config.reset()
    file_watcher.stop()
  end)

  after_each(function()
    file_watcher.stop()
  end)

  describe("is_running", function()
    it("should return false when not started", function()
      assert.is_false(file_watcher.is_running())
    end)

    it("should return true when started", function()
      file_watcher.start()
      assert.is_true(file_watcher.is_running())
    end)

    it("should return false when stopped", function()
      file_watcher.start()
      file_watcher.stop()
      assert.is_false(file_watcher.is_running())
    end)
  end)

  describe("start", function()
    it("should start the file watcher", function()
      file_watcher.start()
      assert.is_true(file_watcher.is_running())
    end)

    it("should not error when called multiple times", function()
      file_watcher.start()
      file_watcher.start()
      assert.is_true(file_watcher.is_running())
    end)
  end)

  describe("stop", function()
    it("should stop the file watcher", function()
      file_watcher.start()
      file_watcher.stop()
      assert.is_false(file_watcher.is_running())
    end)

    it("should not error when called without starting", function()
      assert.has_no.errors(function()
        file_watcher.stop()
      end)
    end)
  end)

  describe("watch_file", function()
    it("should add file to watched list", function()
      config.setup({
        file_watcher = {
          enabled = true,
        },
      })

      local tmpfile = vim.fn.tempname()
      vim.fn.writefile({ "test content" }, tmpfile)

      file_watcher.start()
      local bufnr = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(bufnr, tmpfile)

      file_watcher.watch_file(tmpfile, bufnr)

      local watched = file_watcher.get_watched_files()
      assert.is_true(vim.tbl_contains(watched, tmpfile))

      -- Cleanup
      vim.fn.delete(tmpfile)
    end)

    it("should not watch when disabled", function()
      config.setup({
        file_watcher = {
          enabled = false,
        },
      })

      file_watcher.start()
      file_watcher.watch_file("/tmp/test.txt", 1)

      local watched = file_watcher.get_watched_files()
      assert.equals(0, #watched)
    end)
  end)

  describe("unwatch_file", function()
    it("should remove file from watched list", function()
      config.setup({
        file_watcher = {
          enabled = true,
        },
      })

      local tmpfile = vim.fn.tempname()
      vim.fn.writefile({ "test content" }, tmpfile)

      file_watcher.start()
      local bufnr = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_buf_set_name(bufnr, tmpfile)

      file_watcher.watch_file(tmpfile, bufnr)
      file_watcher.unwatch_file(tmpfile)

      local watched = file_watcher.get_watched_files()
      assert.is_false(vim.tbl_contains(watched, tmpfile))

      -- Cleanup
      vim.fn.delete(tmpfile)
    end)
  end)

  describe("get_watched_files", function()
    it("should return a table", function()
      local watched = file_watcher.get_watched_files()
      assert.is_table(watched)
    end)
  end)
end)
