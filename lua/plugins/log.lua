return {

  {
    'mtdl9/vim-log-highlighting',
    -- lazy = false,
    config = function() end,
  },

  {
    'Goose97/timber.nvim',
    version = 'main', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      vim.api.nvim_create_user_command('TimberClearLogs', function()
        require('timber.buffers').clear_captured_logs()
        require('timber.summary').clear()
      end, {})
      vim.cmd [[cab tc TimberClearLogs]]

      vim.keymap.set('n', '<leader>te', function()
        require('timber.buffers').open_float { silent = true }
        vim.diagnostic.open_float()
      end, { desc = 'Show timber buffer log' })

      vim.keymap.set('n', '<leader>tl', function()
        require('timber.summary').toggle()
      end, { desc = 'Open timber summary log' })

      require('timber').setup {
        log_templates = {
          default = {
            elixir = {
              [[Logger.info(~s|%watcher_marker_start#{inspect(%log_target, pretty: true)}%watcher_marker_end\n|)]],
              auto_import = [[require Logger]],
            },
            dart = { [[print('%watcher_marker_start %log_target: ${%log_target} %watcher_marker_end');]] },
          },
          plain = {
            lua = [[utils.log("%log_marker %insert_cursor")]],
            elixir = {
              [[Logger.info(~s|%watcher_marker_start %insert_cursor %watcher_marker_end\n|)]],
              auto_import = [[require Logger]],
            },
            dart = { [[print('%watcher_marker_start %insert_cursor %watcher_marker_end');]] },
          },
        },
        batch_log_templates = {
          default = {
            elixir = {
              [[Logger.info(~s|%watcher_marker_start#{inspect(%{%repeat<%log_target: %log_target><, >}, pretty: true)}%watcher_marker_end\n|)]],
              auto_import = [[require Logger]],
            },
            dart = { [[print('%watcher_marker_start %log_target: ${%log_target} %watcher_marker_end');]] },
          },
        },
        log_watcher = {
          enabled = true,
          sources = {
            dart_log = {
              name = 'Dart Log',
              type = 'filesystem',
              path = '/tmp/dart_debug.log',
              buffer = {
                syntax = 'dart',
              },
            },
            neotest = {
              name = 'Neotest',
              type = 'neotest',
              buffer = {
                syntax = 'timber-lua',
              },
            },
            pancake_work_debug = {
              name = 'pancake-work-api debug',
              type = 'filesystem',
              path = '/tmp/pancake_work_debug.log',
              buffer = {
                syntax = 'erlang',
              },
            },
          },
        },
      }
    end,
  },
}
