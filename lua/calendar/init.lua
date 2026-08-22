local M = {}

local helpers = require('calendar.helpers')

function M.setup(opts)
  opts = opts or {}
  if opts.get_tasks_duration then
    helpers.get_tasks_duration = opts.get_tasks_duration
  end
end

-- State
local state = {
  year = nil,
  month = nil,
  day = nil,
}

local buf, win
local origin_buf, origin_win

local clamp_day = helpers.clamp_day
local render = require('calendar.render').render

local close = require('calendar.actions').close
local paste_timestamp = require('calendar.actions').paste_timestamp
local paste_timestamp_now = require('calendar.actions').paste_timestamp_now
local open_daily_note = require('calendar.actions').open_daily_note

-- ---------- open ----------

function M.open()
  local now = os.date("*t")
  state.year, state.month, state.day = now.year, now.month, now.day

  origin_buf = vim.api.nvim_get_current_buf()
  origin_win = vim.api.nvim_get_current_win()

  buf = vim.api.nvim_create_buf(false, true)

  local width, height = 28, 8
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  local opts = { buffer = buf, silent = true }

  -- day focus
  vim.keymap.set("n", "h", function() state.day = state.day - 1 clamp_day(state) render(state, buf) end, opts)
  vim.keymap.set("n", "l", function() state.day = state.day + 1 clamp_day(state) render(state, buf) end, opts)
  vim.keymap.set("n", "k", function() state.day = state.day - 7 clamp_day(state) render(state, buf) end, opts)
  vim.keymap.set("n", "j", function() state.day = state.day + 7 clamp_day(state) render(state, buf) end, opts)

  -- view navigation
  vim.keymap.set("n", "H", function() state.year = state.year - 1 clamp_day(state) render(state, buf) end, opts)
  vim.keymap.set("n", "L", function() state.year = state.year + 1 clamp_day(state) render(state, buf) end, opts)
  vim.keymap.set("n", "K", function()
    state.month = state.month - 1
    if state.month < 1 then state.month = 12 state.year = state.year - 1 end
    clamp_day(state)
    render(state, buf)
  end, opts)
  vim.keymap.set("n", "J", function()
    state.month = state.month + 1
    if state.month > 12 then state.month = 1 state.year = state.year + 1 end
    clamp_day(state)
    render(state, buf)
  end, opts)

  -- today
  vim.keymap.set("n", "t", function()
    local n = os.date("*t")
    state.year, state.month, state.day = n.year, n.month, n.day
    render(state, buf)
  end, opts)

  -- actions
  vim.keymap.set("n", "<CR>", function() open_daily_note(state, origin_win, origin_buf, win) end, opts)
  vim.keymap.set("n", "ts", function() paste_timestamp(state, origin_win, origin_buf, win) end, opts)

  -- quit
  vim.keymap.set("n", "q", function() close(win) end, opts)
  vim.keymap.set("n", "<Esc>", function() close(win) end, opts)

  render(state, buf)
end

return M
