--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local opt = vim.opt
local uv = vim.loop

local _config = require('floaterm.config')

local terms = {}

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
      row = center_y + config.row,
      col = center_x + config.col,
      width = width,
      height = height,
    },
    bottom = {
      anchor = 'SW',
      row = screen_h - config.row,
      col = center_x + config.col,
      width = width,
      height = height,
    },
    top = {
      anchor = 'NW',
      row = 0 + config.row,
      col = center_x + config.col,
      width = width,
      height = height,
    },
    left = {
      anchor = 'NW',
      row = center_y + config.row,
      col = 0 + config.col,
      width = width,
      height = height,
    },
    right = {
      anchor = 'NE',
      row = center_y + config.row,
      col = screen_w - config.col,
      width = width,
      height = height,
    },
  }
  return layouts[config.layout]
end

local function create_keymaps(buffer, mapping)
  for lhs, rhs in pairs(mapping) do
    api.nvim_buf_set_keymap(buffer, 'n', lhs, rhs, { noremap = true })
    api.nvim_buf_set_keymap(buffer, 't', lhs, rhs, { noremap = true })
  end
end

local function open(config)
  config = vim.tbl_deep_extend(
    'force',
    vim.deepcopy(_config.get_config()),
    config or {}
  )
  local term = { on_exit = config.on_exit }
  term.buffer = api.nvim_create_buf(true, false)
  local win_options = config.win_api
  if config.layout then
    win_options = vim.tbl_deep_extend(
      'force',
      config.win_api,
      get_window_layout(config)
    )
  end
  term.window = api.nvim_open_win(term.buffer, true, win_options)
  if config.bg_color then
    -- api.nvim_set_hl(0, 'floatermWin', { guibg = config.bg_color })
    cmd('hi! floatermWin guibg=' .. config.bg_color)
    opt.winhighlight:prepend('NormalFloat:floatermWin,')
  end
  config.on_exit = on_exit
  local job_id = fn.termopen(config.command or { opt.shell:get() }, config)
  create_keymaps(term.buffer, {
    [config.keymaps.exit] = '<Cmd>call jobstop(' .. job_id .. ')<CR>',
    [config.keymaps.normal] = '<C-\\><C-N>',
  })
  api.nvim_buf_set_name(
    term.buffer,
    string.format('%s[%s]', config.name, uv.random(2))
  )
  if job_id == 0 then
    api.nvim_err_writeln(
      '[floaterm] termopen() failed, invalid argument (or job table is full)'
    )
    return
  elseif job_id == -1 then
    api.nvim_err_writeln(
      '[floaterm] termopen() failed, command or shell is not executable'
    )
    return
  end
  term.job_id = job_id
  terms[job_id] = term
  cmd('startinsert')
  return term
end

local M = { open = open }

return M
