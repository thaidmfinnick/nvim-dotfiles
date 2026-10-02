return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      word_diff = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 500,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },

      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        -- Open the diff in a new tab; `q` closes the tab
        local function diff_in_tab(base)
          vim.cmd 'tab split'
          local tab = vim.api.nvim_get_current_tabpage()
          gitsigns.diffthis(base)
          vim.defer_fn(function()
            if not vim.api.nvim_tabpage_is_valid(tab) then
              return
            end
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              local b = vim.api.nvim_win_get_buf(win)
              vim.keymap.set('n', 'q', function()
                pcall(vim.keymap.del, 'n', 'q', { buffer = b })
                vim.cmd 'tabclose'
              end, { buffer = b, nowait = true, desc = 'Close diff tab' })
            end
          end, 100)
        end
        map('n', '<leader>hd', function()
          diff_in_tab()
        end, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          diff_in_tab '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Default branch: origin/HEAD, else first of develop/main/master that exists on origin
        local function default_branch()
          local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':h')
          local function git(...)
            local r = vim.system({ 'git', '-C', cwd, ... }, { text = true }):wait()
            return r.code == 0 and vim.trim(r.stdout) or nil
          end
          local head = git('symbolic-ref', '--short', 'refs/remotes/origin/HEAD')
          if head and head ~= '' then
            return head
          end
          for _, name in ipairs { 'develop', 'main', 'master' } do
            if git('rev-parse', '--verify', '--quiet', 'refs/remotes/origin/' .. name) then
              return 'origin/' .. name
            end
          end
        end
        -- Review: compare current file against the default branch
        map('n', '<leader>hB', function()
          -- Signs/hunks (]c, <leader>hp...) now relative to default branch; run again to reset
          local base = not vim.g.gitsigns_review and default_branch() or nil
          if not vim.g.gitsigns_review and not base then
            return vim.notify('No default branch found on origin', vim.log.levels.WARN)
          end
          vim.g.gitsigns_review = base ~= nil
          gitsigns.change_base(base, true)
          vim.notify('Gitsigns base: ' .. (base or 'index'))
        end, { desc = 'git toggle signs [B]ase default branch' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
        map('n', '<leader>gb', ':Gitsign blame<CR>', { noremap = true, silent = true, desc = '[G]itsign [b]lame' })
      end,
    },
  },

  {
    'sindrets/diffview.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'lewis6991/gitsigns.nvim',
    },
    config = function()
      local opts = {
        hooks = {
          -- Show silver-lining drafts inline in diff buffers
          diff_buf_win_enter = function(bufnr)
            vim.schedule(function()
              if package.loaded['silver-lining.comment'] then
                require('silver-lining.comment').render_drafts(bufnr)
              end
            end)
          end,
          -- Focus the diff window instead of the file panel when a view opens
          view_opened = function(view)
            vim.defer_fn(function()
              local win = view.cur_layout and view.cur_layout:get_main_win()
              if win and win:is_valid() then
                win:focus()
              end
            end, 50)
          end,
        },
        keymaps = {
          view = {
            ['q'] = '<cmd>DiffviewClose<CR>', -- Close Diffview
            ['o'] = require('custom.difftastic').open_difftastic,
          },
          file_panel = {
            ['q'] = '<cmd>DiffviewClose<CR>',
          },
          file_history_panel = {
            ['q'] = '<cmd>DiffviewClose<CR>',
            ['<S-o>'] = function()
              local actions = require 'diffview.actions'
              actions.copy_hash()
              local unnamed_content = vim.fn.getreg '+'
              vim.fn.system(string.format('gh browse %s', unnamed_content))
            end,
          },
        },
      }
      require('diffview').setup(opts)
    end,
    keys = {
      { 'do', '<cmd>DiffviewOpen<cr>', mode = { 'n' }, desc = 'Repo Diffview', nowait = true },
      { 'dr', '<cmd>DiffviewOpen origin/develop...HEAD<cr>', mode = { 'n' }, desc = 'Review PR (current branch vs develop)' },
      { 'dh', '<cmd>DiffviewFileHistory<cr>', mode = { 'n' }, desc = 'Repo history' },
      { 'df', '<cmd>DiffviewFileHistory --follow %<cr>', mode = { 'n' }, desc = 'Current file history' },
      {
        'dl',
        function()
          local current_line = vim.fn.line '.'
          local file = vim.fn.expand '%'
          local cmd = string.format('DiffviewFileHistory --follow -L%s,%s:%s', current_line, current_line, file)
          vim.cmd(cmd)
        end,
        mode = { 'n' },
        desc = 'Line history',
      },
      {
        'dr',
        "<Esc><Cmd>'<,'>DiffviewFileHistory --follow<CR>",
        -- function()
        --   local start_line = vim.fn.line "'<"
        --   local end_line = vim.fn.line "'>"
        --   local file = vim.fn.expand '%'
        --   local cmd = string.format('DiffviewFileHistory --follow -L%d,%d:%s', start_line, end_line, file)
        --   vim.cmd(cmd)
        -- end,
        mode = { 'v' },
        desc = 'Range history',
      },
    },
  },
}
