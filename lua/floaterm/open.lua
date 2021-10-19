local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt

local terms = {}
local _config = {
  command = nil,
  position = 'center',
  width = 0.8,
  height = 0.8,
  win_api = { style = 'minimal', relative = 'editor' },
}

local function on_exit(id, code)
  api.nvim_win_close(terms[id].window, true)
  api.nvim_buf_delete(terms[id].buffer, { force = true })
  if type(terms[id].on_exit) == 'function' then
    terms[id].on_exit(id, code)
  end
  terms[id] = nil
end

local function get_window_layout(config)
  local screen_w = opt.columns:get()
  local screen_h = opt.lines:get() - opt.cmdheight:get()
  local _width = screen_w * config.width
  local _height = screen_h * config.height
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
  return layouts[config.position]
end

local function open(config)
  local term = { on_exit = config.on_exit }
  local current_cfg = vim.deepcopy(_config)
  current_cfg = vim.tbl_deep_extend('force', current_cfg, config)
  term.buffer = api.nvim_create_buf(true, false)
  local win_options = vim.tbl_deep_extend(
    'force',
    current_cfg.win_api,
    get_window_layout(current_cfg)
  )
  term.window = api.nvim_open_win(term.buffer, true, win_options)
  current_cfg.on_exit = on_exit
  local job_id = fn.termopen(current_cfg.command, current_cfg)
  -- api.nvim_buf_set_name(config.buffer, _config.name or 'floaterm')
  if job_id == 0 then
    api.nvim_err_writeln('[floaterm] termopen() failed, invalid argument (or job table is full)')
    return
  elseif job_id == -1 then
    api.nvim_err_writeln('[floaterm] termopen() failed, command or shell is not executable')
    return
  end
  term.job_id = job_id
  terms[job_id] = term
  cmd('startinsert')
  return term
end

local M = { open = open }

return M
