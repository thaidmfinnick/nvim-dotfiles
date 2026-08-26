-- Languages installed up front; anything else is installed on first open.
local ensure_installed = {
  'bash',
  'c',
  'diff',
  'eex',
  'elixir',
  'go',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}

local vim_regex_highlighting = { 'ruby' }
local no_indent = { 'ruby' }

return {

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      ts.setup()
      ts.install(ensure_installed)

      local function start(buf, lang)
        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        if vim.list_contains(vim_regex_highlighting, lang) then
          vim.bo[buf].syntax = 'on'
        end
        if not vim.list_contains(no_indent, lang) then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match)
          if not lang then
            return
          end

          if vim.list_contains(ts.get_installed 'parsers', lang) then
            start(event.buf, lang)
          elseif vim.list_contains(ts.get_available(), lang) then
            -- Replaces the old `auto_install` module.
            ts.install(lang):await(function(err)
              if not err and vim.api.nvim_buf_is_valid(event.buf) then
                vim.schedule(function()
                  start(event.buf, lang)
                end)
              end
            end)
          end
        end,
      })
    end,
  },

  { -- Treesitter-powered text objects: move and swap
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Jump forward to the textobject if the cursor is not already inside one.
          lookahead = true,
          selection_modes = {
            ['@function.outer'] = 'V',
            ['@class.outer'] = 'V',
          },
        },
        move = {
          -- Movements go on the jumplist, so <C-o> comes back.
          set_jumps = true,
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- Select. Only keys mini.ai does not already cover; it still owns the
      -- rest of the a/i prefix (see lua/plugins/mini_text.lua).
      local selections = {
        { 'am', '@function.outer', 'textobjects', 'outer function' },
        { 'im', '@function.inner', 'textobjects', 'inner function' },
        { 'ac', '@class.outer', 'textobjects', 'outer class' },
        { 'ic', '@class.inner', 'textobjects', 'inner class' },
        -- Captures from other query groups work too, e.g. `locals.scm`.
        { 'as', '@local.scope', 'locals', 'local scope' },
      }
      for _, sel in ipairs(selections) do
        local lhs, query, group, desc = sel[1], sel[2], sel[3], sel[4]
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, group)
        end, { desc = 'Select ' .. desc })
      end

      -- Move
      local movements = {
        { ']m', move.goto_next_start, '@function.outer', 'Next function start' },
        { ']]', move.goto_next_start, '@class.outer', 'Next class start' },
        { ']M', move.goto_next_end, '@function.outer', 'Next function end' },
        { '][', move.goto_next_end, '@class.outer', 'Next class end' },
        { '[m', move.goto_previous_start, '@function.outer', 'Previous function start' },
        { '[[', move.goto_previous_start, '@class.outer', 'Previous class start' },
        { '[M', move.goto_previous_end, '@function.outer', 'Previous function end' },
        { '[]', move.goto_previous_end, '@class.outer', 'Previous class end' },
        { ']a', move.goto_next_start, '@parameter.inner', 'Next parameter' },
        { '[a', move.goto_previous_start, '@parameter.inner', 'Previous parameter' },
        { ']i', move.goto_next_start, '@conditional.outer', 'Next conditional' },
        { '[i', move.goto_previous_start, '@conditional.outer', 'Previous conditional' },
        { ']l', move.goto_next_start, '@loop.outer', 'Next loop' },
        { '[l', move.goto_previous_start, '@loop.outer', 'Previous loop' },
      }
      for _, m in ipairs(movements) do
        local lhs, fn, query, desc = m[1], m[2], m[3], m[4]
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          fn(query, 'textobjects')
        end, { desc = desc })
      end

      -- Swap
      vim.keymap.set('n', '<leader>ps', function()
        swap.swap_next '@parameter.inner'
      end, { desc = '[P]arameter [S]wap next' })
      vim.keymap.set('n', '<leader>pS', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = '[P]arameter [S]wap previous' })
    end,
  },
}
