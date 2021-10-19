local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.loop
local env = vim.env

local ft = require('floaterm.open')
local utils = require('floaterm.utils')
local preview_command = fn.executable('bat')
    and [[COLORTERM=truecolor bat --color=always -H {2} {1}]]
  or 'less {1}'
local fzf_command =
  [[fzf --bind="change:reload:rg --vimgrep --hidden {q}" -d : --with-nth=1,4 \
  --preview-window=right,70%,noborder,~3,+{2}+3/2 --preview="]] .. preview_command .. [["]]
local tempfile = nil
local actions = { split = 'ctrl-s', vsplit = 'ctrl-v', tabedit = 'ctrl-t' }
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
  local data = vim.split(lines[2], ':')
  cmd(string.format('%s %s', action, data[1]))
  api.nvim_win_set_cursor(0, { tonumber(data[2]), tonumber(data[3]) - 1 })
end

local function rg()
  tempfile = fn.tempname()
  local cwd = uv.cwd()
  local cwd_sub = cwd:gsub(env.HOME, '~')
  local keys = table.concat(vim.tbl_values(actions), ',')
  local command = fzf_command
    .. [[ --expect="]]
    .. keys
    .. [[" --header="]]
    .. cwd_sub
    .. [[ " > ]]
    .. tempfile
  local config = {
    command = command,
    on_exit = on_exit,
    name = 'rg',
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

local M = { rg = rg, init = init }

return M
