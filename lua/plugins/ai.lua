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
      model = 'claude-opus-4.5',
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
  -- {
  --   'greggh/claude-code.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim', -- Required for git operations
  --   },
  --   config = function()
  --     require('claude-code').setup {
  --       window = {
  --         position = 'float',
  --         float = {
  --           width = '90%', -- Take up 90% of the editor width
  --           height = '90%', -- Take up 90% of the editor height
  --           row = 'center', -- Center vertically
  --           col = 'center', -- Center horizontally
  --           relative = 'editor',
  --           border = 'double', -- Use double border style
  --         },
  --       },
  --       keymaps = {
  --         toggle = {
  --           normal = '<leader>cc', -- Normal mode keymap for toggling Claude Code, false to disable
  --           terminal = '<leader>ct', -- Terminal mode keymap for toggling Claude Code, false to disable
  --           variants = {
  --             continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
  --             verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
  --           },
  --         },
  --         window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
  --         scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
  --       },
  --     }
  --   end,
  -- },
}
