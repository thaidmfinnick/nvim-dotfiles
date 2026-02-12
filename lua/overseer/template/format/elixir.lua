return {
  name = 'Format: Elixir',
  builder = function()
    return {
      cmd = { 'mix' },
      args = { 'format' },
      cwd = vim.fn.getcwd(),
    }
  end,
  condition = {
    filetype = { 'elixir' },
  },
}
