local api = vim.api

local function check_exit_status(status)
  if status == 1 then
    print('[floaterm] No match')
    return false
  elseif status == 2 then
    api.nvim_err_writeln('[floaterm] Error')
    return false
  elseif status == 130 then
    return false
  end
  if not status == 0 then
    api.nvim_err_writeln('[floaterm] Exit status unknown')
    return false
  end
  return true
end

local M = { check_exit_status = check_exit_status }

return M
