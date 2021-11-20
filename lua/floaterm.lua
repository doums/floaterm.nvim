--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local _config = require('floaterm.config')
local open = require('floaterm.open')

vim.cmd([[command Fterm lua require('floaterm').open()]])

local function setup(config)
  _config.init(config)
end

local M = {
  setup = setup,
  open = open.open,
}

return M
