return {

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  },

  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, _)
          return vim.startswith(name, '.')
        end,
        -- so you may want to set to false if you work with large directories.
        natural_order = false,
        sort = {
          -- sort order can be "asc" or "desc"
          -- see :help oil-columns to see which columns are sortable
          { 'type', 'asc' },
          { 'name', 'asc' },
        },
      },

      keymaps = {
        ['q'] = { 'actions.close', mode = 'n' },
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function(_, opts)
      require('oil').setup(opts)

      -- File explorer
      vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
    end,
  },
}
