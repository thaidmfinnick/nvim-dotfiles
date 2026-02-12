return {
  name = 'Format: Dart',
  builder = function()
    return {
      cmd = { 'dart' },
      args = { 'format', '.' },
      cwd = vim.fn.getcwd(),
    }
  end,
  condition = {
    -- A string or list of strings
    -- Only matches when current buffer is one of the listed filetypes
    filetype = { 'dart' },
  },
}
