local M = {}

local date_str = require('calendar.helpers').date_str
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


return M
