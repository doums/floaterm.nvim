local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop
local env = vim.env

local ft = require 'floaterm.open'
local utils = require 'floaterm.utils'
local preview_command = fn.executable('bat') and
                          'COLORTERM=truecolor bat --line-range :50 --color=always' or
                          'cat'
local fzf_command =
  [[fzf --multi --preview-window=right:70%:noborder --preview="]] ..
    preview_command .. [[ {}"]]
local tempfile = nil
local actions = {split = 'ctrl-s', vsplit = 'ctrl-v', tabedit = 'ctrl-t'}
local _config = {}

local function get_action(fzf_key)
  for action, value in pairs(actions) do
    if fzf_key == value then
      return action
    end
  end
  return ''
end

local function on_exit(_, code)
  if not utils.check_exit_status(code) then
    return
  end
  local lines = fn.readfile(tempfile)
  if vim.tbl_isempty(lines) then
    return
  end
  local action = get_action(lines[1])
  if #action == 0 then
    action = 'edit'
  end
  table.remove(lines, 1)
  cmd(string.format('%s %s', action, lines[1]))
  table.remove(lines, 1)
  for _, file in ipairs(lines) do
    cmd('badd ' .. file)
  end
end

local function find_file(directory)
  tempfile = fn.tempname()
  local cwd = uv.cwd()
  if directory and not fn.isdirectory(directory) then
    api.nvim_err_writeln('[floaterm] Not a valid directory')
    return
  elseif directory then
    cwd = directory
  end
  local cwd_sub = cwd:gsub(env.HOME, '~')
  local keys = table.concat(vim.tbl_values(actions), ',')
  local command = fzf_command .. [[ --expect="]] .. keys .. [[" --header="]] ..
                    cwd_sub .. [[ " > ]] .. tempfile
  local config = {
    command = command,
    on_exit = on_exit,
    name = 'find file',
    cwd = cwd,
  }
  config = vim.tbl_deep_extend('force', _config, config)
  ft.open(config)
end

local function init(config)
  if config then
    _config = vim.tbl_extend('force', _config, config)
  end
end

local M = {find_file = find_file, init = init}

return M
