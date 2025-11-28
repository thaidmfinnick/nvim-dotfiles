return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      model = 'gpt-4.1',
      mappings = {
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<S-Tab>',
        },
      }, -- See Configuration section for options

      contexts = {
        file = {
          input = function(callback)
            local telescope = require 'telescope.builtin'
            local actions = require 'telescope.actions'
            local action_state = require 'telescope.actions.state'
            telescope.find_files {
              previewer = false,
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  callback(selection[1])
                end)
                return true
              end,
            }
          end,
        },
      },
    },
    config = function(_, opts)
      require('CopilotChat').setup(opts)
      -- You can set up keymaps here, or in your own keymaps.lua file
      vim.keymap.set('n', 'gmo', '<cmd>CopilotChat<cr>', { desc = 'Copilot Chat' })
    end,
  },
}
