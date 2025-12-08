return {

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  },

  {
    'stevearc/oil.nvim',
    opts = {
      float = {
        -- Padding around the floating window
        padding = 2,
        -- max_width and max_height can be integers or a float between 0 and 1
        -- max_width = 0,
        -- max_height = 0,
        -- 1. Add a border here (options: "rounded", "single", "double", "solid", "shadow")
        border = 'rounded',
        win_options = {
          winblend = 0,
        },

        get_win_title = function(winid)
          local buf = vim.api.nvim_win_get_buf(winid)
          local name = vim.api.nvim_buf_get_name(buf)

          -- Oil buffer names start with "oil://", we strip that for a clean path
          if name:sub(1, 6) == 'oil://' then
            name = name:sub(7)
          end

          -- Return the path (optional: add spaces for padding)
          return ' ' .. name .. ' '
        end,

        -- preview_split: Split direction: "auto", "left", "right", "above", "below".
        preview_split = 'auto',

        override = function(conf)
          return conf
        end,
      },
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
          return vim.startswith(name, '.')
        end,

        natural_order = false,
        sort = {
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
