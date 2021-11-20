--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

-- default configuration
local _config = {
  -- The command to run as a job, if `nil` run a `'shell'`.
  command = nil, -- string or list of string
  -- The placement in the editor of the floating window.
  layout = 'center', -- center | bottom | top | left | right
  -- The width/height of the window. Must be a value between
  -- `0.1` and `1`, `1` corresponds to 100% of the editor
  -- width/height.
  width = 0.8,
  height = 0.8,
  -- Offset in character cells of the window, relative to the
  -- layout.
  row = 0,
  col = 0,
  -- Options passed to `nvim_open_win` (`:h nvim_open_win()`)
  win_api = { style = 'minimal', relative = 'editor' },
  -- Some mapping
  keymaps = { exit = '<A-q>', normal = '<A-n>' },
  -- Terminal buffer name
  name = 'fterm',
}

local function init(config)
  if config then
    _config = vim.tbl_deep_extend('force', _config, config)
  end
end

local function get_config()
  return _config
end

local M = { get_config = get_config, init = init }
return M
