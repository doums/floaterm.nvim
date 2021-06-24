local fd_init = require'floaterm.find_file'.init

local function setup(config)
  if config.find_file then
    fd_init(config.find_file)
  else
    fd_init(config)
  end
end

local M = {
  setup = setup,
  find_file = require'floaterm.find_file'.find_file,
  open = require'floaterm.open'.open,
}

return M
