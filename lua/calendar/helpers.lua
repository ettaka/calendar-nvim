local M = {}

-- ---------- helpers ----------
function M.days_in_month(year, month)
  return tonumber(os.date("%d", os.time { year = year, month = month + 1, day = 0 }))
end

function M.first_weekday(year, month)
  return tonumber(os.date("%w", os.time { year = year, month = month, day = 1 }))
end

function M.date_str(state)
  return string.format("%04d-%02d-%02d", state.year, state.month, state.day)
end

function M.clamp_day(state)
  local max_day = M.days_in_month(state.year, state.month)
  if state.day > max_day then state.day = max_day end
  if state.day < 1 then state.day = 1 end
end

-- Maps total effort hours for a day to the corresponding Unicode indicator
function M.get_effort_indicator(hours)
  if not hours or hours < 2 then
    return ""
  elseif hours < 4 then
    return "░"
  elseif hours < 6 then
    return "▒"
  elseif hours < 8 then
    return "▓"
  else
    return "█"
  end
end

-- Fallback assignment if not set via setup()
local ok, calc = pcall(require, "pkb.effort_calculation")
M.get_tasks_duration = ok and calc.get_tasks_duration or nil

function M.get_day_effort(year, month, day)
  if type(M.get_tasks_duration) == "function" then
    return M.get_tasks_duration(year, month, day) or 0
  end
  return 0
end

-- Retrieves total planned task duration in hours for a specific date
-- (Integrate with your task provider/data source or state here)
function M.get_day_effort(year, month, day)
  if type(M.get_tasks_duration) == "function" then
    return M.get_tasks_duration(year, month, day) or 0
  end
  return 4
end

return M

