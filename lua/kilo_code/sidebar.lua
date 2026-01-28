--- Sidebar module for KiloCode terminal interface
local config = require("kilo_code.config")
local utils = require("kilo_code.utils")

local M = {}

-- State
local state = {
  bufnr = nil,
  winnr = nil,
  job_id = nil,
  is_open = false,
}

--- Check if sidebar is currently open
---@return boolean True if sidebar is open and window is valid
function M.is_open()
  return state.is_open and state.winnr and vim.api.nvim_win_is_valid(state.winnr)
end

--- Open the KiloCode sidebar
function M.open()
  if M.is_open() then
    M.focus()
    return
  end

  local cfg = config.get().sidebar

  -- Create buffer if needed
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(state.bufnr, "filetype", "kilo-code")
  end

  -- Calculate dimensions
  local width = cfg.width or 80

  -- Create window
  local split_cmd = cfg.position == "left" and "topleft" or "botright"
  vim.cmd(split_cmd .. " " .. width .. "vsplit")
  state.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.winnr, state.bufnr)

  -- Configure window
  vim.api.nvim_win_set_option(state.winnr, "winfixwidth", true)
  vim.api.nvim_win_set_option(state.winnr, "number", false)
  vim.api.nvim_win_set_option(state.winnr, "relativenumber", false)
  vim.api.nvim_win_set_option(state.winnr, "signcolumn", "no")

  -- Start terminal if not already running
  if not state.job_id then
    local binary = config.get().kilo_code.binary
    local args = config.get().kilo_code.args or {}
    local cmd = binary .. " " .. table.concat(args, " ")

    -- Set environment variables before starting terminal
    local env = config.get().kilo_code.env or {}
    for k, v in pairs(env) do
      vim.fn.setenv(k, v)
    end

    state.job_id = vim.fn.termopen(cmd, {
      on_exit = function(_, code)
        state.job_id = nil
        if code ~= 0 then
          utils.notify("KiloCode exited with code " .. code, vim.log.levels.WARN)
        end
      end,
    })
  end

  state.is_open = true

  -- Enter insert mode in terminal
  vim.cmd("startinsert")
end

--- Close the KiloCode sidebar
function M.close()
  if not M.is_open() then
    return
  end

  if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
    vim.api.nvim_win_close(state.winnr, true)
  end

  state.winnr = nil
  state.is_open = false
end

--- Toggle the KiloCode sidebar
function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

--- Focus the KiloCode sidebar
function M.focus()
  if M.is_open() then
    vim.api.nvim_set_current_win(state.winnr)
    vim.cmd("startinsert")
  end
end

--- Send input to the KiloCode terminal
---@param text string Text to send
function M.send_input(text)
  if state.job_id then
    vim.fn.chansend(state.job_id, text)
  end
end

--- Get the terminal job ID
---@return number|nil Job ID
function M.get_job_id()
  return state.job_id
end

--- Get the sidebar buffer number
---@return number|nil Buffer number
function M.get_bufnr()
  return state.bufnr
end

--- Get the sidebar window number
---@return number|nil Window number
function M.get_winnr()
  return state.winnr
end

return M
