return {
  {
    'Goose97/alternative.nvim',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('alternative').setup {
        keymaps = {
          -- Set to false to disable the default keymap for specific actions
          -- alternative_next = false,
          alternative_next = '<C-.>',
          alternative_prev = '<C-,>',
        },
        rules = {
          'general.boolean_flip',
          'general.number_increment_decrement',
          ['general.compare_operator_flip'] = {
            preview = true,
          },
          'elixir.function_definition_variants',
          'elixir.if_condition_flip',
          'elixir.if_expression_variants',
          'elixir.pipe_first_function_argument',
        },
      }
    end,
  },

  {
    'yujinyuz/gitpad.nvim',
    config = function()
      require('gitpad').setup {
        on_attach = function(bufnr)
          vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>wq<CR>', { noremap = true, silent = true })
        end,
      }
    end,
    keys = {
      {
        '<leader>pp',
        function()
          -- won't work if not in git repo
          local project_name = vim.fn.system 'basename $(git rev-parse --show-toplevel)'
          require('gitpad').toggle_gitpad { title = project_name }
        end,
        desc = 'gitpad project',
      },
      {
        '<leader>pb',
        function()
          require('gitpad').toggle_gitpad_branch { title = 'Branch notes' }
        end,
        desc = 'gitpad branch',
      },
      {
        '<leader>pv',
        function()
          require('gitpad').toggle_gitpad_branch { window_type = 'split', split_win_opts = { split = 'right' } }
        end,
        desc = 'gitpad branch vertical split',
      },

      -- Daily notes
      {
        '<leader>pd',
        function()
          local date_filename = 'daily-' .. os.date '%Y-%m-%d.md'
          require('gitpad').toggle_gitpad { filename = date_filename } -- or require('gitpad').toggle_gitpad({ filename = date_filename, title = 'Daily notes' })
        end,
        desc = 'gitpad daily notes',
      },
      -- Per file notes
      {
        '<leader>pf',
        function()
          local filename = vim.fn.expand '%:p' -- or just use vim.fn.bufname()
          if filename == '' then
            vim.notify 'empty bufname'
            return
          end
          filename = vim.fn.pathshorten(filename, 2) .. '.md'
          require('gitpad').toggle_gitpad { filename = filename } -- or require('gitpad').toggle_gitpad({ filename = filename, title = 'Current file notes' })
        end,
        desc = 'gitpad per file notes',
      },
    },
  },

  {
    'nanotee/zoxide.vim',
    version = '*', -- recommended, use latest release instead of latest commit
  },

  {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function(_, _)
      require('aerial').setup {
        on_attach = function(bufnr)
          vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
        end,
      }
      vim.keymap.set('n', '<leader>l', '<cmd>AerialToggle left<CR>')
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'Goose97/typist.nvim',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('typist').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  {
    'stevearc/overseer.nvim',
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer Run' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Overseer Toggle' },
    },
  },
}
