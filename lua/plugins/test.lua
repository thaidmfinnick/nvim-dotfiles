return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'jfpedroza/neotest-elixir',
    'sidlatau/neotest-dart',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        -- Add your test adapters here
        -- For example, to add the Neotest Elixir adapter:
        require 'neotest-elixir' {
          post_process_command = function(cmd)
            return vim.iter({ { 'env', 'MIX_ENV=test' }, cmd }):flatten():totable()
          end,
        },
        require 'neotest-dart' {
          command = 'flutter', -- Command being used to run tests. Defaults to `flutter`
          -- Change it to `fvm flutter` if using FVM
          -- change it to `dart` for Dart only tests
          use_lsp = true, -- When set Flutter outline information is used when constructing test name.
          -- Useful when using custom test names with @isTest annotation
          custom_test_method_names = {},
        },
      },
      consumer = {
        timber = require('timber.watcher.sources.neotest').consumer,
      },
    }

    local neotest = require 'neotest'
    local map = vim.keymap.set
    map('n', '<leader>nr', function()
      neotest.run.run()
    end, { desc = 'Run nearest test' })
    map('n', '<leader>nf', function()
      neotest.run.run(vim.fn.expand '%')
    end, { desc = 'Run all tests in file' })
    map('n', '<leader>np', function()
      neotest.output_panel.toggle()
    end, { desc = '[T]oggle [P]anel: Neotest Output Panel' })

    map('n', '<leader>no', ':Neotest output<CR>', { desc = '[N]eotest [O]utput' })
  end,
}
