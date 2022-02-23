--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

-- default configuration
local _config = {
  -- The command to run as a job, if nil run the 'shell'.
  command = nil, -- string or list of string
  -- The placement in the editor of the floating window.
  layout = 'center', -- center | bottom | top | left | right
  -- The width/height of the window. Must be a value between 0.1
  -- and 1, 1 corresponds to 100% of the editor width/height.
  width = 0.8,
  height = 0.8,
  -- Offset in character cells of the window, relative to the
  -- layout.
  row = 0,
  col = 0,
  -- Options passed to nvim_open_win (:h nvim_open_win())
  -- You can use it to customize various things like border etc.
  win_api = { style = 'minimal', relative = 'editor' },
  -- Some mapping, exit: close the job and the window, normal:
  -- switch to normal mode
  keymaps = { exit = '<A-q>', normal = '<A-n>' },
  -- Terminal buffer name
  name = 'fterm',
  -- Background color, default use the color from NormalFloat
  bg_color = nil, -- as hex color string eg. #212121
  -- Border highlight group, default FloatBorder
  border_hl = nil,
  -- `on_exit` a optional function to call when the terminal's job
  -- exits. It will receive the job ID and exit code as argument.
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
