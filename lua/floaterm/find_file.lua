local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop
local env = vim.env

local ft = require 'floaterm.open_floating_term'
local utils = require 'floaterm.utils'
local preview_command = fn.executable('bat') and
                          'COLORTERM=truecolor bat --line-range :50 --color=always' or
                          'cat'
local fzf_command =
  [[fzf --multi --preview-window=right:70%:noborder --preview="]] ..
    preview_command .. [[ {}"]]
local tempfile = nil
local actions = {split = 'ctrl-s', vsplit = 'ctrl-v', tab = 'ctrl-t'}

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
  table.remove(lines, 1)
  if action == '' then
    cmd('edit ' .. lines[1])
  elseif action == 'split' then
    cmd('split ' .. lines[1])
  elseif action == 'vsplit' then
    cmd('vsplit ' .. lines[1])
  elseif action == 'tab' then
    cmd('tabedit ' .. lines[1])
  end
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
  local path_items = vim.split(cwd_sub, '/')
  local tail = path_items[#path_items] or cwd_sub
  local keys = table.concat(vim.tbl_values(actions), ',')
  local command = fzf_command .. [[ --expect="]] .. keys .. [[" --prompt="]] ..
                    tail .. [[ " > ]] .. tempfile
  local config = {
    command = command,
    on_exit = on_exit,
    name = 'find file',
    cwd = cwd,
    layout = {position = 'top', width = 1, height = 0.6}
  }
  ft.open_floating_term(config)
end

local M = {find_file = find_file}

return M
