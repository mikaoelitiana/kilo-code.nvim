--- File watcher module for detecting external file changes
local config = require("kilo_code.config")
local utils = require("kilo_code.utils")

local M = {}

-- State
local watchers = {}
local file_states = {}
local is_running = false

--- Start the file watcher
function M.start()
  if is_running then
    return
  end
  is_running = true

  -- Watch all existing buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local filepath = vim.api.nvim_buf_get_name(bufnr)
      if filepath and filepath ~= "" then
        M.watch_file(filepath, bufnr)
      end
    end
  end
end

--- Stop the file watcher
function M.stop()
  for filepath, watcher in pairs(watchers) do
    if watcher then
      watcher:stop()
      watcher:close()
    end
  end
  watchers = {}
  file_states = {}
  is_running = false
end

--- Watch a file for changes
---@param filepath string Path to the file
---@param bufnr number Buffer number associated with the file
function M.watch_file(filepath, bufnr)
  if not config.get().file_watcher.enabled then
    return
  end

  if watchers[filepath] then
    return -- Already watching
  end

  -- Get initial file stats
  local stat = vim.loop.fs_stat(filepath)
  if stat then
    file_states[filepath] = {
      mtime = stat.mtime.sec,
      size = stat.size,
      bufnr = bufnr,
    }
  end

  -- Create fs_event watcher
  local watcher = vim.loop.new_fs_event()
  watchers[filepath] = watcher

  local function on_change(err, _, _)
    if err then
      return
    end

    vim.schedule(function()
      M.handle_file_change(filepath, bufnr)
    end)
  end

  watcher:start(filepath, false, on_change)
end

--- Stop watching a file
---@param filepath string Path to the file
function M.unwatch_file(filepath)
  local watcher = watchers[filepath]
  if watcher then
    watcher:stop()
    watcher:close()
    watchers[filepath] = nil
    file_states[filepath] = nil
  end
end

--- Handle a file change event
---@param filepath string Path to the file
---@param bufnr number Buffer number
function M.handle_file_change(filepath, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    M.unwatch_file(filepath)
    return
  end

  local cfg = config.get().file_watcher

  -- Check if file still exists
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    -- File was deleted
    if cfg.notify_on_change then
      utils.notify("File deleted: " .. vim.fn.fnamemodify(filepath, ":t"))
    end
    return
  end

  -- Check if content actually changed
  local state_info = file_states[filepath]
  if state_info and state_info.mtime == stat.mtime.sec then
    return -- No change
  end

  -- Update stored state
  file_states[filepath] = {
    mtime = stat.mtime.sec,
    size = stat.size,
    bufnr = bufnr,
  }

  -- Check if buffer is modified
  local is_modified = vim.api.nvim_buf_get_option(bufnr, "modified")

  if is_modified then
    -- Buffer has unsaved changes
    if cfg.notify_on_change then
      utils.notify(
        "File changed externally (buffer has unsaved changes): " .. vim.fn.fnamemodify(filepath, ":t"),
        vim.log.levels.WARN
      )
    end
    return
  end

  if cfg.auto_reload then
    M.reload_buffer(bufnr, filepath)
  elseif cfg.notify_on_change then
    utils.notify("File changed externally: " .. vim.fn.fnamemodify(filepath, ":t"))
  end
end

--- Reload a buffer from disk
---@param bufnr number Buffer number
---@param filepath string Path to the file
function M.reload_buffer(bufnr, filepath)
  -- Check if buffer is the current buffer in any window
  local current_win = vim.api.nvim_get_current_win()
  local target_win = nil

  -- Find a window displaying this buffer
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      target_win = win
      break
    end
  end

  -- Save cursor position from the target window or current window
  local cursor = vim.api.nvim_win_get_cursor(target_win or current_win)

  -- Reload buffer
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("checktime")
  end)

  -- Restore cursor position in the target window
  pcall(function()
    vim.api.nvim_win_set_cursor(target_win or current_win, cursor)
  end)

  -- If the file was edited by KiloCode and is not visible, auto-open it
  local cfg = config.get().file_watcher
  if cfg.auto_open and not target_win then
    -- File is not open in any window, open it based on follow_mode
    if vim.fn.bufwinid(bufnr) == -1 then
      local cmd = "edit"
      if cfg.follow_mode == "split" then
        cmd = "split"
      elseif cfg.follow_mode == "vsplit" then
        cmd = "vsplit"
      elseif cfg.follow_mode == "tab" then
        cmd = "tabedit"
      end

      -- Store current window to return to it if needed
      local prev_win = current_win

      -- Open the file
      vim.cmd(cmd .. " " .. vim.fn.fnameescape(filepath))

      -- Restore cursor position
      pcall(function()
        vim.api.nvim_win_set_cursor(0, cursor)
      end)

      -- Optionally switch back to previous window (keep focus)
      -- Uncomment the next line if you want to keep focus on the original window
      -- vim.api.nvim_set_current_win(prev_win)
    end
  end

  if config.get().file_watcher.notify_on_change then
    utils.notify("Reloaded: " .. vim.fn.fnamemodify(filepath, ":t"))
  end
end

--- Check if the file watcher is running
---@return boolean True if running
function M.is_running()
  return is_running
end

--- Get the list of watched files
---@return table List of file paths being watched
function M.get_watched_files()
  local files = {}
  for filepath, _ in pairs(watchers) do
    table.insert(files, filepath)
  end
  return files
end

return M
