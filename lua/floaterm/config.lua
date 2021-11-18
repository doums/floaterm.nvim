-- default configuration
local _config = {
  command = nil,
  layout = 'center',
  width = 0.8,
  height = 0.8,
  row = 0,
  col = 0,
  win_api = { style = 'minimal', relative = 'editor' },
  keymaps = { exit = '<A-q>', normal = '<A-n>' },
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
