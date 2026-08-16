local M = {}

-- ---------- actions ----------
function M.close()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

local function return_to_origin()
  if vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  else
    vim.api.nvim_set_current_buf(origin_buf)
  end
end

function M.paste_timestamp()
  return_to_origin()
  local ts = date_str() .. "T" .. os.date("%H:%M") .. M.local_tz_suffix()
  vim.api.nvim_put({ ts }, "c", true, true)
  close()
end

M.paste_timestamp_now  = function ()
  local ts = os.date("%Y-%m-%dT%H:%M") .. M.local_tz_suffix()
  vim.api.nvim_put({ ts }, "c", true, true)
  M.close()
end

function M.open_daily_note()
  return_to_origin()
  local path = vim.fn.expand("~/pkb/" .. date_str() .. ".md")
  vim.cmd.edit(path)
  M.close()
end

return M
