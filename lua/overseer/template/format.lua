local commands = {
  { name = 'Format: Dart', cmd = 'dart', args = { 'format', '.' }, ft = { 'dart' } },
  { name = 'Format: Elixir', cmd = 'mix', args = { 'format' }, ft = { 'elixir' } },
}

local templates = {}

for _, fmt in ipairs(commands) do
  table.insert(templates, {
    name = fmt.name,
    condition = {
      filetype = fmt.ft,
    },
    builder = function()
      return {
        cmd = { fmt.cmd },
        args = fmt.args,
        cwd = vim.fn.getcwd(),
      }
    end,
  })
end

return templates
