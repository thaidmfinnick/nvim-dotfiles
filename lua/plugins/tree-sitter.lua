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
}
