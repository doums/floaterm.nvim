local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt

local terms = {}
local defaults = {width = 0.5, height = 1}

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
  _config = vim.tbl_extend('keep', _config, defaults)
  local screen_w = opt.columns:get()
  local screen_h = opt.lines:get()
  local _width = screen_w * _config.width
  local _height = screen_h * _config.height
  local width = math.floor(_width)
  local height = math.floor(_height)
  local x = (screen_w - _width) / 2
  local y = 1
  local layouts = {
    bottom = {
      anchor = 'SE',
      row = screen_h - opt.cmdheight:get(),
      col = 0,
      width = width,
      height = height, -- calculated
    },
    top = {
      anchor = 'NE',
      row = 0,
      col = 0,
      width = width,
      height = height, -- calculated
    },
    left = {
      anchor = 'NW',
      row = 0,
      col = 0,
      width = width,
      height = height - opt.cmdheight:get(), -- calculated
    },
    right = {
      anchor = 'NE',
      row = 0,
      col = 0,
      width = width,
      height = height - opt.cmdheight:get(), -- calculated
    },
  }
  local window_config = vim.tbl_extend('force', {
    relative = 'editor',
    style = 'minimal',
  }, layouts.right)
  config.buffer = api.nvim_create_buf(true, false)
  config.window = api.nvim_open_win(config.buffer, true, window_config)
  local term_config = vim.tbl_deep_extend('keep', {on_exit = on_exit},
                                          _config.options)
  local job_id = fn.termopen(_config.command, term_config)
  -- api.nvim_buf_set_name(config.buffer, _config.name or 'floaterm')
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
