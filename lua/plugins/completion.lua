return {
  {
    'saghen/blink.cmp',
    lazy = false,
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
        config = function()
          local ls = require 'luasnip'
          vim.keymap.set({ 'i', 's' }, '<C-e>', function()
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end, { silent = true })
        end,
      },
    },
    version = '1.*',
    opts = {
      keymap = {
        -- preset = 'default',
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<CR>'] = { 'select_accept_and_enter', 'fallback' },
        ['<C-s>'] = { 'show_and_insert', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      cmdline = {
        keymap = {
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
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
          selection = { preselect = true, auto_insert = true },
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
          auto_show_delay_ms = 300,
          window = {
            border = 'single',
          },
        },
      },
      signature = { enabled = true },
      appearance = {
        highlight_ns = vim.api.nvim_create_namespace 'blink_cmp',
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = '  ',
          Method = '  ',
          Function = '  ',
          Constructor = '  ',

          Field = '  ',
          Variable = '  ',
          Property = '  ',

          Class = '  ',
          Interface = '  ',
          Struct = '  ',
          Module = '  ',

          Unit = ' ',
          Value = '  ',
          Enum = '  ',
          EnumMember = '  ',

          Keyword = '  ',
          Constant = '  ',

          Snippet = '  ',
          Color = '  ',
          File = '  ',
          Reference = '  ',
          Folder = '  ',
          Event = ' ',
          Operator = '  ',
          TypeParameter = '  ',
        },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { 'sources.default' },
    config = function(_, opts)
      require('blink.cmp').setup(opts)
    end,
  },
}
