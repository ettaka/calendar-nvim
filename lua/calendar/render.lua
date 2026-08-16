local M = {}

-- ---------- rendering ----------
function M.render()
  local lines = {}
  table.insert(lines, os.date(" %B %Y", os.time {
    year = state.year,
    month = state.month,
    day = 1,
  }))
  table.insert(lines, " Su  Mo  Tu  We  Th  Fr  Sa")

  local start_wday = first_weekday(state.year, state.month)
  local week = {}

  local today = os.date("*t")
  local total_days = days_in_month(state.year, state.month)

  for _ = 1, start_wday do
    table.insert(week, "    ")
  end

  for day = 1, total_days do
    local label = string.format("%2d", day)

    if day == state.day then
      label = "[" .. string.format("%2d", day) .. "]"
    else
      if day == today.day
        and state.month == today.month
        and state.year == today.year then
        label = "•" .. string.format("%2d", day) .. " "
      else
        label = " " .. string.format("%2d", day) .. " "
      end
    end

    table.insert(week, label)

    if #week == 7 then
      table.insert(lines, table.concat(week, ""))
      week = {}
    end
  end

  if #week > 0 then
    table.insert(lines, table.concat(week, ""))
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return M
