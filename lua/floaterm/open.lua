local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt

local terms = {}
local _config = {
  command = nil,
  layout = {position = 'center', width = 0.8, height = 0.8},
  window = {style = 'minimal', relative = 'editor'},
}

local function on_exit(id, code)
  api.nvim_win_close(terms[id].window, true)
  api.nvim_buf_delete(terms[id].buffer, {force = true})
  if type(terms[id].on_exit) == 'function' then
    terms[id].on_exit(id, code)
  end
  terms[id] = nil
end

local function get_window_options(layout)
  local screen_w = opt.columns:get()
  local screen_h = opt.lines:get() - opt.cmdheight:get()
  local _width = screen_w * layout.width
  local _height = screen_h * layout.height
  local width = math.floor(_width)
  local height = math.floor(_height)
  local center_y = (opt.lines:get() - _height) / 2
  local center_x = (screen_w - _width) / 2
  local layouts = {
    center = {
      anchor = 'NW',
      row = center_y,
      col = center_x,
      width = width,
      height = height,
    },
    bottom = {
      anchor = 'SW',
      row = screen_h,
      col = center_x,
      width = width,
      height = height,
    },
    top = {
      anchor = 'NW',
      row = 0,
      col = center_x,
      width = width,
      height = height,
    },
    left = {
      anchor = 'NW',
      row = center_y,
      col = 0,
      width = width,
      height = height,
    },
    right = {
      anchor = 'NE',
      row = center_y,
      col = screen_w,
      width = width,
      height = height,
    },
  }
  return layouts[layout.position]
end

local function open(config)
  -- print(vim.inspect(config))
  local term = {on_exit = config.on_exit}
  _config = vim.tbl_deep_extend('force', _config, config)
  term.buffer = api.nvim_create_buf(true, false)
  local window_options = vim.tbl_deep_extend('force', _config.window,
                                             get_window_options(_config.layout))
  term.window = api.nvim_open_win(term.buffer, true, window_options)
  local term_config = vim.tbl_deep_extend('keep', {on_exit = on_exit}, _config)
  local job_id = fn.termopen(_config.command, term_config)
  -- api.nvim_buf_set_name(config.buffer, _config.name or 'floaterm')
  if job_id == 0 then
    api.nvim_err_writeln '[floaterm] termopen() failed, invalid argument (or job table is full)'
    return
  elseif job_id == -1 then
    api.nvim_err_writeln '[floaterm] termopen() failed, command or shell is not executable'
    return
  end
  term.job_id = job_id
  terms[job_id] = term
  cmd 'startinsert'
  return term
end

local M = {open = open}

return M
