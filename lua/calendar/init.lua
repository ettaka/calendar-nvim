local M = {}

M.HOME_TZ = "+02:00"  -- must match your notifier module

function M.setup(opts)
  opts = opts or {}
  if opts.HOME_TZ then
    M.HOME_TZ = opts.HOME_TZ
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

local helpers = require('helpers')
helpers.setup(M.HOME_TZ)
local days_in_month = helpers.days_in_month
local first_weekday = helpers.first_weekday
local clamp_day = helpers.clamp_day
local date_str = helpers.date_str
local render = require('render').render
local local_tz_suffix = helpers.local_tz_suffix

local close = require('actions').close
local paste_timestamp = require('actions').paste_timestamp
local paste_timestamp_now = require('actions').paste_timestamp_now
local open_daily_note = require('actions').open_daily_note

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
  vim.keymap.set("n", "h", function() state.day = state.day - 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "l", function() state.day = state.day + 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "k", function() state.day = state.day - 7 clamp_day() render() end, opts)
  vim.keymap.set("n", "j", function() state.day = state.day + 7 clamp_day() render() end, opts)

  -- view navigation
  vim.keymap.set("n", "H", function() state.year = state.year - 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "L", function() state.year = state.year + 1 clamp_day() render() end, opts)
  vim.keymap.set("n", "K", function()
    state.month = state.month - 1
    if state.month < 1 then state.month = 12 state.year = state.year - 1 end
    clamp_day()
    render()
  end, opts)
  vim.keymap.set("n", "J", function()
    state.month = state.month + 1
    if state.month > 12 then state.month = 1 state.year = state.year + 1 end
    clamp_day()
    render()
  end, opts)

  -- today
  vim.keymap.set("n", "t", function()
    local n = os.date("*t")
    state.year, state.month, state.day = n.year, n.month, n.day
    render()
  end, opts)

  -- actions
  vim.keymap.set("n", "<CR>", open_daily_note, opts)
  vim.keymap.set("n", "ts", paste_timestamp, opts)

  -- quit
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  render()
end

vim.keymap.set({"n", "i", "t"}, "<leader>ts", M.paste_timestamp_now, { desc = "Insert timestamp" })

return M
