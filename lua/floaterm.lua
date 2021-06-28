local find_file = require'floaterm.find_file'
local rg = require'floaterm.rg'

local function setup(config)
  find_file.init(config.find_file or config)
  rg.init(config.rg or config)
end

local M = {
  setup = setup,
  find_file = find_file.find_file,
  rg = rg.rg,
  open = require'floaterm.open'.open,
}

return M
