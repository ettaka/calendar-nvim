local M = {}

local date_str = require('calendar.helpers').date_str
local helpers = require('calendar.helpers')

-- ---------- actions ----------
function M.close(win)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

local function return_to_origin(origin_win, origin_buf)
  if vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  else
    vim.api.nvim_set_current_buf(origin_buf)
  end
end

function M.open_daily_note(state, origin_win, origin_buf, win)
  return_to_origin(origin_win, origin_buf)
  local path = vim.fn.expand("~/pkb/" .. date_str(state) .. ".md")
  vim.cmd.edit(path)
  M.close(win)
end

function M.paste_timestamp(state, origin_win, origin_buf, win)
  return_to_origin(origin_win, origin_buf)
  local ts = date_str(state) .. "T" .. os.date("%H:%M") .. require('timestamps.parser').local_tz_suffix()
  vim.api.nvim_put({ ts }, "c", true, true)
  M.close(win)
end

function M.open_agenda(state)
  local date_text = date_str(state)
  local tasks = helpers.get_day_agenda(state.year, state.month, state.day)

  local lines = { " Agenda for " .. date_text, "────────────────────────────" }
  if type(tasks) == "table" and #tasks > 0 then
    for _, task in ipairs(tasks) do
      table.insert(lines, " • " .. task)
    end
  else
    table.insert(lines, "  (No agenda items found)")
  end

  local width, height = 42, math.min(#lines + 2, 15)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Agenda ",
    title_pos = "center",
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q", function() M.close(win) end, opts)
  vim.keymap.set("n", "<Esc>", function() M.close(win) end, opts)
end


return M
