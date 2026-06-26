return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opt = {},
  config = function(_, _)
    function set_size(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end

    require('toggleterm').setup {
      size = set_size,
      open_mapping = [[tj]],
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = 'horizontal',
      close_on_exit = true,
      shell = vim.o.shell,
    }

    local Terminal = require('toggleterm.terminal').Terminal
    local map = vim.keymap.set
    local lazygit = Terminal:new { cmd = 'lazygit', hidden = true, direction = 'float' }

    map('n', 'lg', function()
      lazygit:toggle()
    end, { desc = 'Toggle LazyGit', noremap = true, silent = true })
    local function focus_term(id)
      local term = require('toggleterm.terminal').get(id)
      term:focus()
    end

    map('n', '1to', function()
      focus_term(1)
    end, { desc = 'Focus terminal #1' })
    map('n', '2to', function()
      focus_term(2)
    end, { desc = 'Focus terminal #2' })
    map('n', '3to', function()
      focus_term(3)
    end, { desc = 'Focus terminal #3' })
  end,
}
