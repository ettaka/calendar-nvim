local M = {}

M.HOME_TZ = "+02:00"  -- must match your notifier module

function M.setup(HOME_TZ)
  HOME_TZ = HOME_TZ or M.HOME_TZ
end

-- ---------- helpers ----------
function M.days_in_month(year, month)
  return tonumber(os.date("%d", os.time { year = year, month = month + 1, day = 0 }))
end

function M.first_weekday(year, month)
  return tonumber(os.date("%w", os.time { year = year, month = month, day = 1 }))
end

function M.clamp_day(state)
  local max_day = M.days_in_month(state.year, state.month)
  if state.day > max_day then state.day = max_day end
  if state.day < 1 then state.day = 1 end
end

function M.date_str(state)
  return string.format("%04d-%02d-%02d", state.year, state.month, state.day)
end

M.local_tz_suffix = function (home_tz)
  local z = os.date("%z") -- e.g. "+0200"

  local sign, hh, mm = z:match("([%+%-])(%d%d)(%d%d)")
  if not sign then return "" end

  local formatted = string.format("%s%s:%s", sign, hh, mm)

  if formatted == "+00:00" then
    return "Z"
  elseif formatted == home_tz then
    return "H"
  else
    return formatted
  end
end


return M
