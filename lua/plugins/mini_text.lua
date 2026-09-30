return {

  {
    'echasnovski/mini.nvim',
    init = function()
      vim.g.miniindentscope_disable = true
    end,
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.indentscope').setup {
        options = {
          indent_at_cursor = true,
        },
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()
    end,
  },

  {
    'gbprod/yanky.nvim',
    opts = {},
    config = function(_, opts)
      require('yanky').setup(opts)
      vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
      vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
      vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

      vim.keymap.set('n', '<c-p>', '<Plug>(YankyPreviousEntry)')
      vim.keymap.set('n', '<c-n>', '<Plug>(YankyNextEntry)')
    end,
  },

  {
    'gbprod/substitute.nvim',
    opts = {},
    config = function()
      require('substitute').setup()
      -- substitution keymap (<leader>s prefix keeps `s` free for mini.surround)
      vim.keymap.set('n', '<leader>sx', require('substitute').operator, { noremap = true, desc = 'Substitute operator' })
      vim.keymap.set('n', '<leader>sxx', require('substitute').line, { noremap = true, desc = 'Substitute line' })
      vim.keymap.set('x', '<leader>sx', require('substitute').visual, { noremap = true, desc = 'Substitute visual selection' })

      -- exchange keymaps
      vim.keymap.set('n', '<leader>sX', require('substitute.exchange').operator, { noremap = true, desc = 'Exchange operator' })
      vim.keymap.set('n', '<leader>sXX', require('substitute.exchange').line, { noremap = true, desc = 'Exchange line' })
      vim.keymap.set('x', 'X', require('substitute.exchange').visual, { noremap = true, desc = 'Exchange visual selection' })
    end,
  },
}
