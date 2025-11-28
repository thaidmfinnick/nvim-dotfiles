return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load { paths = { './snippets' } }
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<C-y>'] = cmp.mapping.confirm { select = true },

          ['<C-Space>'] = cmp.mapping.complete {},

          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),

          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          vim.keymap.set({ 'i', 's' }, '<C-E>', function()
            if luasnip.choice_active() then
              luasnip.change_choice(1)
            end
          end, { silent = true }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = { 'L3MON4D3/LuaSnip' },
    version = '1.*',
    opts = {
      cmdline = {
        keymap = {
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<CR>'] = {},
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = { preselect = false },
          },
        },
      },
      completion = {
        keyword = {
          range = 'full',
        },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        accept = {
          dot_repeat = true,
          auto_brackets = {
            enabled = true,

            semantic_token_resolution = {
              enabled = false,
            },
          },
        },
        menu = {
          border = 'single',
          winhighlight = 'Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None',
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = 'single',
          },
        },
      },
      signature = { enabled = true },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      -- sources = {
      --   default = { 'path' },
      -- },
      snippets = { preset = 'luasnip' },
    },
    opts_extend = { 'sources.default' },
  },
}
