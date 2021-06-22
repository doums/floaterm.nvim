local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local terms = {}

local function on_exit(id, code)
  api.nvim_win_close(terms[id].window, true)
  api.nvim_buf_delete(terms[id].buffer, {force = true})
  if type(terms[id].on_exit) == 'function' then
    terms[id].on_exit(id, code)
  end
  terms[id] = nil
end

local function open_floating_term(_config)
  local config = {}
  if _config and _config.options then
    config.on_exit = _config.options.on_exit
  end
  config.buffer = api.nvim_create_buf(true, false)
  config.window = api.nvim_open_win(config.buffer, true, {
    relative = 'editor',
    width = 60,
    height = 20,
    row = 2,
    col = 2,
    style = 'minimal',
  })
  local term_config = vim.tbl_deep_extend('keep', {on_exit = on_exit},
                                          _config.options)
  local job_id = fn.termopen(_config.command, term_config)
  if job_id == 0 then
    api.nvim_err_writeln '[floaterm] termopen() failed, invalid argument (or job table is full)'
    return
  elseif job_id == -1 then
    api.nvim_err_writeln '[floaterm] termopen() failed, command or shell is not executable'
    return
  end
  config.job_id = job_id
  terms[job_id] = config
  cmd 'startinsert'
  return config
end

local M = {open_floating_term = open_floating_term}

return M
