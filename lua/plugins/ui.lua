return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>h', group = 'Git [H]unk' },
        { '<leader>h_', hidden = true },
        { '<leader>r', group = '[R]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>w_', hidden = true },
      }
      -- visual mode
      require('which-key').add { '<leader>h', desc = 'Git [H]unk', mode = 'v' }
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    config = function(_, _)
      local function file_length()
        return vim.api.nvim_buf_line_count(0)
      end

      local function file_info()
        local path = vim.fn.expand '%:p' -- full file path
        local status = vim.bo.modified and '●' or '✓'
        return path .. ' ' .. status
      end

      require('lualine').setup {
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            'diff',
            'diagnostics',
            {
              function()
                local fp = vim.fn.expand '%:p'
                local package_name = fp:match 'packages/([^/]+)/'
                package_name = package_name:gsub('jfc%-global%-', '')
                return package_name or ''
              end,
            },
          },
          lualine_c = { file_info },
          lualine_x = { 'filesize', 'filetype' },
          lualine_y = { 'g:flutter_tools_decorations.app_version', file_length },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'filesize', 'filetype' },
          lualine_y = { file_length },
          lualine_z = { 'location' },
        },
      }
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '/',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
}
