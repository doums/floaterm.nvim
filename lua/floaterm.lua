local _config = require('floaterm.config')
local open = require('floaterm.open')

local function setup(config)
  _config.init(config)
end

local M = {
  setup = setup,
  open = open.open,
}

return M
